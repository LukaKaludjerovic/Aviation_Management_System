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
[Route("api/auth")]
[Authorize]
public class AuthController : ControllerBase
{
    [HttpPost]
    [Route("login")]
    [AllowAnonymous]
    public IActionResult Login([FromBody] LoginRequest loginRequest)
    {
        var ctx = new AerosenseContext();

        var username = loginRequest.Username;
        var password = loginRequest.Password;

        var user = ctx.Users
            .Include(u => u.Role)
            .Where(u => u.DeletedTimestamp == null)
            .FirstOrDefault(u => u.UserName == username);

        if (user == null || user.UserName == null || user.Password == null)
        {
            return Unauthorized("Incorrect username or password".ToResponseError());
        }

        if (!EncryptUtils.VerifyPassword(password, user.Password))
        {
            return Unauthorized("Incorrect username or password".ToResponseError());
        }

        var permissions = new List<string>();

        if (user.Role != null && user.Role.AllowedFunctions != null)
        {
            var rolePermissions = user.Role
                .AllowedFunctions
                .Split(",", StringSplitOptions.RemoveEmptyEntries);

            permissions.AddRange(rolePermissions);
        }

        var allowedPermissions = (user.AllowedFunctions ?? string.Empty)
            .Split(",", StringSplitOptions.RemoveEmptyEntries);

        var forbiddenPermissions = (user.ForbiddenFunctions ?? string.Empty)
            .Split(",", StringSplitOptions.RemoveEmptyEntries);

        permissions.AddRange(allowedPermissions);

        permissions.RemoveAll(p => forbiddenPermissions.Contains(p));

        if (!permissions.Contains(Permission.AppLogin))
        {
            return Unauthorized("User does not have right to log into app".ToResponseError());
        }

        var token = EncryptUtils.GenerateToken(user.UserName, user.Password);

        var auth = new Auth(token, permissions, user);

        AuthStorage.Put(auth);

        auth.User.Password = null;
        return Ok(auth);
    }

    [HttpPost]
    [Route("logout")]
    public IActionResult Logout()
    {
        var token = HttpContext.Request.Headers.Authorization.FirstOrDefault();

        var auth = AuthStorage.Get(token ?? string.Empty);

        if (auth == null)
        {
            return NotFound("User not found".ToResponseError());
        }

        AuthStorage.Delete(auth);

        return Ok();
    }

    public class LoginRequest
    {
        public string Username { get; set; } = string.Empty;

        public string Password { get; set; } = string.Empty;
    }
}