namespace MaintenanceDuration.Predictor.services;

using MaintenanceDuration.Predictor.utilities;
using Microsoft.ML;
using Microsoft.ML.Trainers.FastTree;

public class TrainingService
{
    public static void TrainAndSave(MLContext mlContext, string modelPath)
    {
        var data = Enumerable
            .Range(0, 3000)
            .Select(_ => DataGenerator.Generate());
        
        var dataView = mlContext.Data
            .LoadFromEnumerable(data);
        
        var pipeline = mlContext.Transforms.Categorical
            .OneHotEncoding("AircraftTypeEncoded", "AircraftType")
            .Append(mlContext.Transforms.Categorical.OneHotEncoding("CheckTypeEncoded", "CheckType"))
            .Append(mlContext.Transforms.Concatenate(
                "Features",
                "AircraftTypeEncoded",
                "BusinessSeats",
                "EconomySeats",
                "HasStructuralInspection",
                "HasCorrosionTreatment",
                "HasWingInspection",
                "HasLandingGearInspection",
                "HasLandingGearReplacement",
                "HasEngineBorescope",
                "HasAPUInspection",
                "HasAvionicsUpdate",
                "HasCabinReconfiguration",
                "TotalWorkScore"))
            .Append(mlContext.Regression.Trainers.FastTree(
                new FastTreeRegressionTrainer.Options
                {
                    NumberOfTrees = 200,
                    NumberOfLeaves = 20,
                    MinimumExampleCountPerLeaf = 5
                }
            ));
        
        var model = pipeline.Fit(dataView);
        
        mlContext.Model.Save(model, dataView.Schema, modelPath);
    }
}