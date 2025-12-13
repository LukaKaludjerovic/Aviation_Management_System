namespace aerosense.controllers;

using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

[ApiController]
[Route("api/aircraft-type")]
[Authorize]
public class AicraftTypeController : ControllerBase
{
    [HttpGet]
    [Route("active")]
    public IActionResult ListActive()
    {
        var ctx = new AerosenseContext();

        var aircraftTypes = ctx.AircraftTypes
            .Where(at => at.WFSDate == null)
            .ToList();

        return Ok(aircraftTypes);
    }

    [HttpGet]
    [Route("historic")]
    public IActionResult ListHistoric()
    {
        var ctx = new AerosenseContext();

        var aircraftTypes = ctx.AircraftTypes
            .Where(at => at.WFSDate != null)
            .ToList();

        return Ok(aircraftTypes);
    }

    [HttpPost]
    public IActionResult Create([FromBody] AircraftType aircraftType)
    {
        var ctx = new AerosenseContext();

        ctx.AircraftTypes.Add(aircraftType);
        ctx.SaveChanges();

        return Ok(aircraftType);
    }

    [HttpPut]
    public IActionResult Update([FromBody] AircraftType aircraftType)
    {
        var ctx = new AerosenseContext();

        ctx.AircraftTypes.Update(aircraftType);
        ctx.SaveChanges();

        return Ok(aircraftType);
    }

    [HttpDelete]
    [Route("{id}")]
    public IActionResult Delete(int id)
    {
        try
        {
            var ctx = new AerosenseContext();

            var aircraftType = ctx.AircraftTypes.FirstOrDefault(at => at.Id == id);

            if (aircraftType == null)
            {
                return NotFound("Aircraft type not found".ToResponseError());
            }

            ctx.AircraftTypes.Remove(aircraftType);
            ctx.SaveChanges();

            return Ok();
        }
        catch (DbUpdateException ex)
        {
            if (ex.InnerException is SqlException sqlEx && sqlEx.Number == 547)
            {
                return BadRequest("Aircraft Type cannot be deleted because it is used elsewhere in the app".ToResponseError());
            }
            else
            {
                throw;
            }
        }
    }
}