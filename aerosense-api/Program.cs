namespace aerosense;

using aerosense.authorization;
using Microsoft.AspNetCore.Authentication;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        builder.Services
            .AddAuthentication("TokenAuthentication")
            .AddScheme<AuthenticationSchemeOptions, TokenAuthenticationHandler>("TokenAuthentication", null);

        builder.Services.AddAuthorization();
        builder.Services.AddControllers();

        var app = builder.Build();

        app.UseHttpsRedirection()
            .UseAuthentication()
            .UseAuthorization();

        app.MapControllers();
        app.Map("api/**", HandleApiFallback);

        app.Run();
    }

    private static Task HandleApiFallback(HttpContext context)
    {
        context.Response.StatusCode = StatusCodes.Status404NotFound;

        return Task.CompletedTask;
    }
}
