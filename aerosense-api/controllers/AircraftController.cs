namespace aerosense.controllers;

using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

[ApiController]
[Route("api/aircraft")]
[Authorize]
public class AircraftController : ControllerBase
{
    [HttpGet]
    [Route("active")]
    public IActionResult ListActive()
    {
        var ctx = new AerosenseContext();

        var aircraft = ctx.Aircraft
            .Include(a => a.Type)
            .Where(a => a.WFSDate == null)
            .ToList();

        return Ok(aircraft);
    }

    [HttpGet]
    [Route("historic")]
    public IActionResult ListHistoric()
    {
        var ctx = new AerosenseContext();

        var aircraft = ctx.Aircraft
            .Include(a => a.Type)
            .Where(a => a.WFSDate != null)
            .ToList();

        return Ok(aircraft);
    }

    [HttpPost]
    public IActionResult Create([FromBody] Aircraft aircraft)
    {
        var ctx = new AerosenseContext();

        ctx.Aircraft.Add(aircraft);
        ctx.SaveChanges();

        return Ok(aircraft);
    }

    [HttpPut]
    public IActionResult Update([FromBody] Aircraft aircraft)
    {
        var ctx = new AerosenseContext();

        ctx.Aircraft.Update(aircraft);
        ctx.SaveChanges();

        return Ok(aircraft);
    }

    [HttpPut]
    [Route("{id}/retire")]
    public IActionResult Retire(int id)
    {
        var ctx = new AerosenseContext();

        var aircraft = ctx.Aircraft
            .Include(a => a.Type)
            .FirstOrDefault(a => a.Id == id);

        if (aircraft == null)
        {
            return NotFound("Aircraft not found".ToResponseError());
        }

        aircraft.WFSDate = DateTime.Now;

        if (aircraft.Type != null)
        {
            RetireType(ctx, id, aircraft.Type);
        }

        ctx.SaveChanges();

        return Ok();
    }

    [HttpDelete]
    [Route("{id}")]
    public IActionResult Delete(int id)
    {
        var ctx = new AerosenseContext();

        var aircraft = ctx.Aircraft.FirstOrDefault(a => a.Id == id);

        if (aircraft == null)
        {
            return NotFound("Aircraft not found".ToResponseError());
        }

        ctx.Aircraft.Remove(aircraft);
        ctx.SaveChanges();

        return Ok();
    }

    private static void RetireType(AerosenseContext ctx, int aircraftId, AircraftType aircraftType)
    {
        var aircraft = ctx.Aircraft
            .Where(a => a.Id != aircraftId && a.WFSDate != null && a.Type != null && a.Type.Id == aircraftType.Id)
            .FirstOrDefault();

        if (aircraft != null)
        {
            return;
        }

        aircraftType.WFSDate = DateTime.Now;
    }
}