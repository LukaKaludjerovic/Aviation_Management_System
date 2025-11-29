namespace aerosense.authorization;

using aerosense.models.aerosense;
using Microsoft.AspNetCore.Mvc;

[ModelBinder(BinderType = typeof(AuthModelBinder))]
public class Auth
{
    public Auth(string token, List<string> permissions, User user)
    {
        this.Token = token;
        this.Permissions = permissions;
        this.User = user;
    }

    public User User { get; set; }

    public string Token { get; set; }

    public List<string> Permissions { get; set; } = [];

    public DateTime LastActivity { get; set; } = DateTime.Now;

    public bool Allowed(string permission)
    {
        return Permissions.Contains(permission);
    }
}