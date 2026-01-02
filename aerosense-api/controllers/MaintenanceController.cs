namespace aerosense.controllers;

using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

[ApiController]
[Route("api/maintenance")]
[Authorize]
public class MaintenanceController : ControllerBase
{
    [HttpGet]
    [Route("pending")]
    public IActionResult ListPending()
    {
        var ctx = new AerosenseContext();

        var maintenance = ctx.Maintenance
            .Include(m => m.Aircraft)
            .Where(m => m.CompletedAt == null)
            .ToList();

        return Ok(maintenance);
    }

    [HttpGet]
    [Route("completed")]
    public IActionResult ListCompleted()
    {
        var ctx = new AerosenseContext();

        var maintenance = ctx.Maintenance
            .Include(m => m.Aircraft)
            .Where(m => m.CompletedAt != null)
            .ToList();

        return Ok(maintenance);
    }

    [HttpPost]
    public IActionResult Create([FromBody] Maintenance maintenance)
    {
        var ctx = new AerosenseContext();

        if (maintenance.Aircraft != null)
        {
            ctx.Aircraft.Attach(maintenance.Aircraft);
        }

        if (maintenance.ScheduledFor != null)
        {
            maintenance.ExpectedCompletitionDate = maintenance.ScheduledFor.Value.AddDays(14);
        }

        ctx.Maintenance.Add(maintenance);
        ctx.SaveChanges();

        return Ok(maintenance);
    }

    [HttpPut]
    public IActionResult Update([FromBody] Maintenance maintenance)
    {
        var ctx = new AerosenseContext();

        var dbMaintenance = ctx.Maintenance
            .Include(m => m.Aircraft)
            .FirstOrDefault(m => m.Id == maintenance.Id);

        if (dbMaintenance == null)
        {
            return NotFound("Maintenance not found".ToResponseError());
        }

        dbMaintenance.Aircraft = maintenance.Aircraft;
        dbMaintenance.Description = maintenance.Description;
        dbMaintenance.ScheduledFor = maintenance.ScheduledFor;

        if (maintenance.ScheduledFor != null)
        {
            maintenance.ExpectedCompletitionDate = maintenance.ScheduledFor.Value.AddDays(14);
        }

        ctx.SaveChanges();

        return Ok(dbMaintenance);
    }

    [HttpPut]
    [Route("{id}/complete")]
    public IActionResult Complete(int id)
    {
        var ctx = new AerosenseContext();

        var maintenance = ctx.Maintenance.FirstOrDefault(m => m.Id == id);

        if (maintenance == null)
        {
            return NotFound("Maintenance not found".ToResponseError());
        }

        maintenance.CompletedAt = DateTime.Now;

        ctx.SaveChanges();

        return Ok();
    }

    [HttpDelete]
    [Route("{id}")]
    public IActionResult Delete(int id)
    {
        var ctx = new AerosenseContext();

        var maintenance = ctx.Maintenance.FirstOrDefault(m => m.Id == id);

        if (maintenance == null)
        {
            return NotFound("Maintenance not found".ToResponseError());
        }

        if (maintenance.ScheduledFor <= DateTime.Now)
        {
            return BadRequest("Maintenance has already started".ToResponseError());
        }

        ctx.Maintenance.Remove(maintenance);
        ctx.SaveChanges();

        return Ok();
    }
}