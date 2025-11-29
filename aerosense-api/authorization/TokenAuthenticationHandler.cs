namespace aerosense.authorization;

using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

public class TokenAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    public TokenAuthenticationHandler(IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder)
    : base(options, logger, encoder)
    {
    }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var endpoint = Context.GetEndpoint();

        if (endpoint == null)
        {
            if (Context.Request.Path.ToString().StartsWith("/app"))
            {
                return Task.FromResult(AuthenticateResult.NoResult());
            }
        }

        if (endpoint != null)
        {
            var allowAnonymous = endpoint?.Metadata?.GetMetadata<IAllowAnonymous>();

            if (allowAnonymous != null)
            {
                return Task.FromResult(AuthenticateResult.NoResult());
            }
        }

        var token = Request.Headers.Authorization.FirstOrDefault();

        if (token != null)
        {
            var auth = AuthStorage.Get(token);

            if (auth != null)
            {
                auth.LastActivity = DateTime.Now;

                var identity = new ClaimsIdentity(Array.Empty<Claim>(), "Token");
                var claimsPrincipal = new ClaimsPrincipal(identity);

                return Task.FromResult(AuthenticateResult.Success(new AuthenticationTicket(claimsPrincipal, Scheme.Name)));
            }
        }

        Response.StatusCode = 401;

        return Task.FromResult(AuthenticateResult.Fail("Unauthorized."));
    }
}