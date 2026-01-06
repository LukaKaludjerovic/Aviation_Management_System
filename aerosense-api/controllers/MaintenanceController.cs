namespace aerosense.controllers;

using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using aerosense.utils;
using MaintenanceDuration.Predictor.services;
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
    public IActionResult Create([FromBody] Maintenance maintenance, [FromServices] PredictionService predictor)
    {
        var ctx = new AerosenseContext();

        if (maintenance.Aircraft != null)
        {
            ctx.Aircraft.Attach(maintenance.Aircraft);
        }

        var mlData = MLUtils.ConvertMaintenanceToMaintenanceData(maintenance);
        var predictedDays = 25;

        if (mlData != null)
        {
            predictedDays = (int)Math.Ceiling(predictor.Predict(mlData));
        }

        if (maintenance.ScheduledFor != null)
        {
            maintenance.ExpectedCompletitionDate = maintenance.ScheduledFor.Value.AddDays(predictedDays);
        }

        ctx.Maintenance.Add(maintenance);
        ctx.SaveChanges();

        return Ok(maintenance);
    }

    [HttpPut]
    public IActionResult Update([FromBody] Maintenance maintenance, [FromServices] PredictionService predictor)
    {
        var ctx = new AerosenseContext();

        var dbMaintenance = ctx.Maintenance
            .Include(m => m.Aircraft)
            .ThenInclude(a => a!.Type)
            .FirstOrDefault(m => m.Id == maintenance.Id);

        if (dbMaintenance == null)
        {
            return NotFound("Maintenance not found".ToResponseError());
        }

        if (dbMaintenance.ScheduledFor <= DateTime.Now)
        {
            return BadRequest("Maintence has already started".ToResponseError());
        }

        var needsToPredict = maintenance.Description != dbMaintenance.Description;

        if (maintenance.Aircraft != null && dbMaintenance.Aircraft != null)
        {
            needsToPredict |= maintenance.Aircraft.Configuration != dbMaintenance.Aircraft.Configuration;

            if (maintenance.Aircraft.Type != null && dbMaintenance.Aircraft.Type != null)
            {
                needsToPredict |= maintenance.Aircraft.Type.Code != dbMaintenance.Aircraft.Type.Code;
            }
        }

        if (maintenance.Aircraft != null)
        {
            dbMaintenance.Aircraft = ctx.Aircraft
                .Include(a => a.Type)
                .FirstOrDefault(a => a.Id == maintenance.Aircraft.Id);
        }

        dbMaintenance.Description = maintenance.Description;
        dbMaintenance.ScheduledFor = maintenance.ScheduledFor;

        var expectedDateNotChanged = maintenance.ExpectedCompletitionDate == dbMaintenance.ExpectedCompletitionDate;

        if (expectedDateNotChanged)
        {
            if (needsToPredict && dbMaintenance.ExpectedCompletitionDate != null && dbMaintenance.ScheduledFor != null)
            {
                var mlData = MLUtils.ConvertMaintenanceToMaintenanceData(dbMaintenance);
                var predictedDays = 0;

                if (mlData != null)
                {
                    predictedDays = (int)Math.Ceiling(predictor.Predict(mlData));
                }

                dbMaintenance.ExpectedCompletitionDate = dbMaintenance.ScheduledFor.Value.AddDays(predictedDays);
            }
        }
        else
        {
            dbMaintenance.ExpectedCompletitionDate = maintenance.ExpectedCompletitionDate;
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