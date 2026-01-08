namespace RouteBlockTime.Predictor.services;

using Microsoft.ML;
using RouteBlockTime.Predictor.models;
using RouteBlockTime.Predictor.utilities;

public class PredictionService
{
    private readonly MLContext mlContext;
    private readonly ITransformer model;
    private readonly PredictionEngine<RouteData, RoutePrediction> engine;

    public PredictionService(string modelPath)
    {
        mlContext = new MLContext(seed: 1);

        model = mlContext.Model.Load(modelPath, out var schema);

        engine = mlContext.Model.CreatePredictionEngine<RouteData, RoutePrediction>(model);
    }

    public float Predict(RouteData input)
    {
        var prediction = engine.Predict(input);

        return prediction.Score;
    }

    public (double rmse, double r2) Evaluate(int testSetSize)
    {
        var testData = DataGenerator.GenerateTestSet(testSetSize);
        var testDataView = mlContext.Data.LoadFromEnumerable(testData);
        var predictions = model.Transform(testDataView);
        var metrics = mlContext.Regression.Evaluate(predictions);

        return (metrics.RootMeanSquaredError, metrics.RSquared);
    }
}