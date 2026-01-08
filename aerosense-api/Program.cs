namespace aerosense;

using aerosense.authorization;
using Microsoft.AspNetCore.Authentication;
using Microsoft.ML;
using MaintenanceDurationServices = MaintenanceDuration.Predictor.services;
using RouteBlockTimeServices = RouteBlockTime.Predictor.services;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        var mlContext = new MLContext(seed: 42);
        var maintenanceDurationModelPath = Path.Combine(builder.Environment.ContentRootPath, "models/ml/maintenance_model.zip");
        var routeBlockTimeModelPath = Path.Combine(builder.Environment.ContentRootPath, "models/ml/route_blocktime_model.zip");

        Console.WriteLine("Training maintenance duration ML model...");
        MaintenanceDurationServices.TrainingService.TrainAndSave(mlContext, maintenanceDurationModelPath);
        Console.WriteLine("Model trained and saved to " + maintenanceDurationModelPath);

        Console.WriteLine("Training route blocktime ML model...");
        RouteBlockTimeServices.TrainingService.TrainAndSave(mlContext, routeBlockTimeModelPath);
        Console.WriteLine("Model trained and saved to " + routeBlockTimeModelPath);

        mlContext.Model.Load(maintenanceDurationModelPath, out _);
        mlContext.Model.Load(routeBlockTimeModelPath, out _);

        builder.Services.AddSingleton(sp => new MaintenanceDurationServices.PredictionService(maintenanceDurationModelPath));
        builder.Services.AddSingleton(sp => new RouteBlockTimeServices.PredictionService(routeBlockTimeModelPath));

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
