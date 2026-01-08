namespace RouteBlockTime.Predictor.services;

using Microsoft.ML;
using Microsoft.ML.Trainers.FastTree;
using RouteBlockTime.Predictor.models;
using RouteBlockTime.Predictor.utilities;

public static class TrainingService
{
    public static void TrainAndSave(MLContext mlContext, string modelPath)
    {
        var data = Enumerable
            .Range(0, 5000)
            .Select(_ => DataGenerator.Generate());

        var dataView = mlContext.Data
            .LoadFromEnumerable(data);

        var pipeline = mlContext.Transforms
            .Concatenate(
                "Features",
                nameof(RouteData.DistanceKm),
                nameof(RouteData.DeltaLongitude),
                nameof(RouteData.AbsDeltaLatitude),
                nameof(RouteData.IsEastbound),
                nameof(RouteData.TurbopropProbability))
            .Append(mlContext.Regression.Trainers.FastTree(
                new FastTreeRegressionTrainer.Options
                {
                    NumberOfTrees = 200,
                    NumberOfLeaves = 20,
                    MinimumExampleCountPerLeaf = 10,
                }));

        var model = pipeline.Fit(dataView);

        mlContext.Model.Save(model, dataView.Schema, modelPath);
    }
}