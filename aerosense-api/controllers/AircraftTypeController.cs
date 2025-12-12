namespace aerosense.controllers;

using aerosense.models.aerosense;
using aerosense.models.context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/aircraft-type")]
[Authorize]
public class AicraftTypeController : ControllerBase
{
    [HttpGet]
    public IActionResult List()
    {
        var ctx = new AerosenseContext();

        var aircraftTypes = ctx.AircraftTypes
            .Where(at => at.WFSDate == null)
            .ToList();

        return Ok(aircraftTypes);
    }
}