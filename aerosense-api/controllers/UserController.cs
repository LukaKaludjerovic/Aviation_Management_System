namespace aerosense.controllers;

using aerosense.authorization;
using aerosense.extensions;
using aerosense.models.aerosense;
using aerosense.models.context;
using aerosense.utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

[ApiController]
[Route("api/user")]
[Authorize]
public class UserController : ControllerBase
{
    [HttpGet]
    public IActionResult List()
    {
        var ctx = new AerosenseContext();

        var users = ctx.Users
            .Include(u => u.Role)
            .Where(u => u.DeletedTimestamp == null)
            .ToList();

        foreach (var user in users)
        {
            user.Password = null;
        }

        return Ok(users);
    }

    [HttpPost]
    public IActionResult Create([FromBody] User user)
    {
        if (string.IsNullOrWhiteSpace(user.Password))
        {
            return BadRequest("User must have password".ToResponseError());
        }

        var ctx = new AerosenseContext();

        var existingUser = ctx.Users.FirstOrDefault(u => u.UserName == user.UserName);

        if (existingUser != null)
        {
            return BadRequest("User with same username already exists".ToResponseError());
        }

        user.Password = EncryptUtils.HashPassword(user.Password);

        if (user.Role != null)
        {
            ctx.Attach(user.Role);
        }

        ctx.Users.Add(user);
        ctx.SaveChanges();

        user.Password = null;

        return Ok(user);
    }

    [HttpPut]
    public IActionResult Update([FromBody] User user)
    {
        var ctx = new AerosenseContext();

        var dbUser = ctx.Users.FirstOrDefault(u => u.Id == user.Id);

        if (dbUser == null)
        {
            return NotFound("User not found".ToResponseError());
        }

        dbUser.FirstName = user.FirstName;
        dbUser.LastName = user.LastName;
        dbUser.UserName = user.UserName;
        dbUser.Role = user.Role;
        dbUser.AllowedFunctions = user.AllowedFunctions;
        dbUser.ForbiddenFunctions = user.ForbiddenFunctions;

        ctx.SaveChanges();

        dbUser.Password = null;

        return Ok(dbUser);
    }

    [HttpPut]
    [Route("change-password")]
    public IActionResult ChangePassword(Auth auth, [FromBody] ChangePasswordRequest changePasswordRequest)
    {
        if (changePasswordRequest.OldPassword == null || changePasswordRequest.NewPassword == null)
        {
            return BadRequest("Old password is not correct".ToResponseError());
        }

        var ctx = new AerosenseContext();

        var user = ctx.Users.FirstOrDefault(u => u.Id == auth.User.Id);

        if (user == null || string.IsNullOrWhiteSpace(user.Password))
        {
            return NotFound("User not found".ToResponseError());
        }

        if (!EncryptUtils.VerifyPassword(changePasswordRequest.OldPassword, user.Password))
        {
            return BadRequest("Old password is not correct".ToResponseError());
        }

        user.Password = EncryptUtils.HashPassword(changePasswordRequest.NewPassword);

        ctx.SaveChanges();

        return Ok();
    }

    [HttpDelete]
    [Route("{userId}")]
    public IActionResult Delete(int userId)
    {
        var ctx = new AerosenseContext();

        var user = ctx.Users.FirstOrDefault(u => u.Id == userId);

        if (user == null)
        {
            return NotFound("User not found".ToResponseError());
        }

        user.DeletedTimestamp = DateTime.Now;

        ctx.SaveChanges();

        return Ok();
    }

    public class ChangePasswordRequest
    {
        public string? OldPassword { get; set; }

        public string? NewPassword { get; set; }
    }
}