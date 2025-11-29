namespace aerosense.authorization;

using Microsoft.AspNetCore.Mvc.ModelBinding;

public class AuthModelBinder : IModelBinder
{
    public Task BindModelAsync(ModelBindingContext bindingContext)
    {
        var httpContext = bindingContext.ActionContext.HttpContext;

        string token = httpContext.Request.Headers["Authorization"].FirstOrDefault() ?? string.Empty;
        bindingContext.Result = ModelBindingResult.Success(AuthStorage.Get(token));

        return Task.CompletedTask;
    }
}