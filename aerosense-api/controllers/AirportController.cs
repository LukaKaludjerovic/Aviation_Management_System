namespace aerosense.controllers;

using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/airport")]
[Authorize]
public class AirportController : ControllerBase
{
    [HttpGet]
    public IActionResult List()
    {
        var ctx = new AerosenseContext();

        var airports = ctx.Airports.ToList();

        return Ok(airports);
    }

    [HttpPost]
    public IActionResult Create([FromBody] Airport airport)
    {
        var ctx = new AerosenseContext();

        ctx.Airports.Add(airport);
        ctx.SaveChanges();

        return Ok(airport);
    }

    [HttpPut]
    public IActionResult Update([FromBody] Airport airport)
    {
        var ctx = new AerosenseContext();

        ctx.Airports.Update(airport);
        ctx.SaveChanges();

        return Ok(airport);
    }

    [HttpDelete]
    [Route("{id}")]
    public IActionResult Delete(int id)
    {
        var ctx = new AerosenseContext();

        var airport = ctx.Airports.FirstOrDefault(at => at.Id == id);

        if (airport == null)
        {
            return NotFound("Airport not found".ToResponseError());
        }

        ctx.Airports.Remove(airport);
        ctx.SaveChanges();

        return Ok();
    }
}