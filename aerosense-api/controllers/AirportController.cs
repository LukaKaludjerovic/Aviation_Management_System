namespace aerosense.controllers;

using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

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
        try
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
        catch (DbUpdateException ex)
        {
            if (ex.InnerException is SqlException sqlEx && sqlEx.Number == 547)
            {
                return BadRequest("Airport cannot be deleted because it is used elsewhere in the app".ToResponseError());
            }
            else
            {
                throw;
            }
        }
    }
}