namespace aerosense.controllers;

using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using aerosense.utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

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
    public IActionResult Create([FromBody] Route route)
    {
        var ctx = new AerosenseContext();

        if (route.Origin == null || route.Destination == null)
        {
            return BadRequest("Origin and Destination Airports are required".ToResponseError());
        }

        ctx.Airports.Attach(route.Origin);
        ctx.Airports.Attach(route.Destination);

        route.Distance = GeoUtils.GreatCircleDistance(route.Origin, route.Destination);

        ctx.Routes.Add(route);
        ctx.SaveChanges();

        return Ok(route);
    }

    [HttpPut]
    public IActionResult Update([FromBody] Route route)
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

        dbRoute.Origin = route.Origin;
        dbRoute.Destination = route.Destination;
        dbRoute.Distance = route.Distance;
        dbRoute.BlockTime = route.BlockTime;
        dbRoute.RouteDetails = route.RouteDetails;
        dbRoute.CommencedAt = route.CommencedAt;

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