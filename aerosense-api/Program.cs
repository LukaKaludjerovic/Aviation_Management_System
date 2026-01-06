namespace aerosense;

using aerosense.authorization;
using Microsoft.AspNetCore.Authentication;
using MaintenanceDuration.Predictor.services;
using Microsoft.ML;
using MaintenanceDuration.Predictor.models;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        var mlContext = new MLContext(seed: 42);
        var modelPath = Path.Combine(builder.Environment.ContentRootPath, "models/ml/maintenance_model.zip");

        Console.WriteLine("Training maintenance duration ML model...");
        TrainingService.TrainAndSave(mlContext, modelPath);
        Console.WriteLine("Model trained and saved to " + modelPath);

        var model = mlContext.Model.Load(modelPath, out _);

        builder.Services.AddSingleton(sp => new PredictionService(modelPath));

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
