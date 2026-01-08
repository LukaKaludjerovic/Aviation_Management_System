namespace MaintenanceDuration.Predictor.services;

using MaintenanceDuration.Predictor.models;
using MaintenanceDuration.Predictor.utilities;
using Microsoft.ML;

public class PredictionService
{
    private readonly MLContext mlContext;
    private readonly ITransformer model;
    private readonly PredictionEngine<MaintenanceData, MaintenancePrediction> engine;

    public PredictionService(string modelPath)
    {
        mlContext = new MLContext(seed: 1);

        model = mlContext.Model.Load(modelPath, out var schema);

        engine = mlContext.Model.CreatePredictionEngine<MaintenanceData, MaintenancePrediction>(model);
    }

    public float Predict(MaintenanceData input)
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