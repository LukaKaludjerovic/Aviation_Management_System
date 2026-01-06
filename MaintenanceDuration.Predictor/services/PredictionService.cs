namespace MaintenanceDuration.Predictor.services;

using MaintenanceDuration.Predictor.models;
using MaintenanceDuration.Predictor.utilities;
using Microsoft.ML;

public class PredictionService
{
    private readonly MLContext _mlContext;
    private readonly ITransformer _model;
    private readonly PredictionEngine<MaintenanceData, MaintenancePrediction> _engine;

    public PredictionService(string modelPath)
    {
        _mlContext = new MLContext(seed: 1);

        _model = _mlContext.Model.Load(modelPath, out var schema);

        _engine = _mlContext.Model.CreatePredictionEngine<MaintenanceData, MaintenancePrediction>(_model);
    }

    public float Predict(MaintenanceData input)
    {
        var prediction = _engine.Predict(input);

        return prediction.Score;
    }

    public (double rmse, double r2) Evaluate(int testSetSize)
    {
        var testData = DataGenerator.GenerateTestSet(testSetSize);
        var testDataView = _mlContext.Data.LoadFromEnumerable(testData);
        var predictions = _model.Transform(testDataView);
        var metrics = _mlContext.Regression.Evaluate(predictions);

        return (metrics.RootMeanSquaredError, metrics.RSquared);
    }
}