namespace aerosense.controllers;

using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using aerosense.utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RouteBlockTime.Predictor.services;

[ApiController]
[Route("api/route")]
[Authorize]
public class RouteController : ControllerBase
{
    [HttpGet]
    [Route("current")]
    public IActionResult ListCurrent()
    {
        var ctx = new AerosenseContext();

        var routes = ctx.Routes
            .Include(r => r.Origin)
            .Include(r => r.Destination)
            .Include(r => r.RouteDetails)
            .ThenInclude(rd => rd.AircraftType)
            .Where(r => r.TerminatedAt == null)
            .ToList();

        return Ok(routes);
    }

    [HttpGet]
    [Route("historic")]
    public IActionResult ListHistoric()
    {
        var ctx = new AerosenseContext();

        var routes = ctx.Routes
            .Include(r => r.Origin)
            .Include(r => r.Destination)
            .Include(r => r.RouteDetails)
            .ThenInclude(rd => rd.AircraftType)
            .Where(r => r.TerminatedAt != null)
            .ToList();

        return Ok(routes);
    }

    [HttpPost]
    public IActionResult Create([FromBody] Route route, [FromServices] PredictionService predictor)
    {
        var ctx = new AerosenseContext();

        if (route.Origin == null || route.Destination == null)
        {
            return BadRequest("Origin and Destination Airports are required".ToResponseError());
        }

        ctx.Airports.Attach(route.Origin);
        ctx.Airports.Attach(route.Destination);

        route.Distance = GeoUtils.GreatCircleDistance(route.Origin, route.Destination);

        var mlData = MLUtils.ConvertRouteToRouteData(route);
        var predictedBlockTime = 0;

        if (mlData != null)
        {
            predictedBlockTime = (int)Math.Ceiling(predictor.Predict(mlData));
        }

        route.BlockTime = predictedBlockTime;

        ctx.Routes.Add(route);
        ctx.SaveChanges();

        return Ok(route);
    }

    [HttpPut]
    public IActionResult Update([FromBody] Route route, [FromServices] PredictionService predictor)
    {
        var ctx = new AerosenseContext();

        var dbRoute = ctx.Routes
            .Include(r => r.Origin)
            .Include(r => r.Destination)
            .Include(r => r.RouteDetails)
            .ThenInclude(rd => rd.AircraftType)
            .FirstOrDefault(r => r.Id == route.Id);

        if (dbRoute == null)
        {
            return NotFound("Route not found".ToResponseError());
        }

        var needsToPredict = false;

        if (route.Origin != null && dbRoute.Origin != null)
        {
            needsToPredict |= dbRoute.Origin.IATACode != route.Origin.IATACode;
        }

        if (route.Destination != null && dbRoute.Destination != null)
        {
            needsToPredict |= dbRoute.Destination.IATACode != route.Destination.IATACode;
        }

        if (route.Origin != null)
        {
            dbRoute.Origin = ctx.Airports.FirstOrDefault(a => a.Id == route.Origin.Id);
        }

        if (route.Destination != null)
        {
            dbRoute.Destination = ctx.Airports.FirstOrDefault(a => a.Id == route.Destination.Id);
        }

        if (route.Origin != null && route.Destination != null)
        {
            dbRoute.Distance = GeoUtils.GreatCircleDistance(route.Origin, route.Destination);
        }

        dbRoute.RouteDetails = route.RouteDetails;
        dbRoute.CommencedAt = route.CommencedAt;

        var blockTimeNotChanged = route.BlockTime == dbRoute.BlockTime;

        if (blockTimeNotChanged)
        {
            if (needsToPredict)
            {
                var mlData = MLUtils.ConvertRouteToRouteData(dbRoute);
                var predictedBlockTime = 0;

                if (mlData != null)
                {
                    predictedBlockTime = (int)Math.Ceiling(predictor.Predict(mlData));
                }

                dbRoute.BlockTime = predictedBlockTime;
            }
        }
        else
        {
            dbRoute.BlockTime = route.BlockTime;
        }

        ctx.SaveChanges();

        return Ok(route);
    }

    [HttpPut]
    [Route("{id}/terminate")]
    public IActionResult Terminate(int id)
    {
        var ctx = new AerosenseContext();

        var route = ctx.Routes.FirstOrDefault(r => r.Id == id);

        if (route == null)
        {
            return NotFound("Route not found".ToResponseError());
        }

        route.TerminatedAt = DateTime.Now;

        ctx.SaveChanges();

        return Ok();
    }

    [HttpDelete]
    [Route("{id}")]
    public IActionResult Delete(int id)
    {
        var ctx = new AerosenseContext();

        var route = ctx.Routes.FirstOrDefault(r => r.Id == id);

        if (route == null)
        {
            return NotFound("Route not found".ToResponseError());
        }

        if (route.CommencedAt <= DateTime.Now)
        {
            return BadRequest("Route has already commenced, use Terminate instead".ToResponseError());
        }

        ctx.Routes.Remove(route);
        ctx.SaveChanges();

        return Ok();
    }
}