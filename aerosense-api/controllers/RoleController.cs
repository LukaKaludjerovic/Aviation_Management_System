namespace aerosense.controllers;

using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/role")]
public class RoleController : ControllerBase
{
    [HttpGet]
    public IActionResult List()
    {
        var ctx = new AerosenseContext();

        var roles = ctx.Roles
            .Where(r => r.DeletedTimestamp == null)
            .ToList();

        return Ok(roles);
    }

    [HttpPost]
    public IActionResult Create([FromBody] Role role)
    {
        var ctx = new AerosenseContext();

        ctx.Roles.Add(role);
        ctx.SaveChanges();

        return Ok(role);
    }

    [HttpPut]
    public IActionResult Update([FromBody] Role role)
    {
        var ctx = new AerosenseContext();

        ctx.Roles.Update(role);
        ctx.SaveChanges();

        return Ok(role);
    }

    [HttpDelete]
    [Route("{roleId}")]
    public IActionResult Delete(int roleId)
    {
        var ctx = new AerosenseContext();

        var role = ctx.Roles.FirstOrDefault(r => r.Id == roleId);

        if (role == null)
        {
            return NotFound("Role not found".ToResponseError());
        }

        role.DeletedTimestamp = DateTime.Now;

        ctx.SaveChanges();

        return Ok();
    }
}