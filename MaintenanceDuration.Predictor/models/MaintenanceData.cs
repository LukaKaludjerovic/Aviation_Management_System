namespace MaintenanceDuration.Predictor.models;

using Microsoft.ML.Data;

public class MaintenanceData
{
    public string? AircraftType { get; set; }

    public float BusinessSeats { get; set; }
    public float EconomySeats { get; set; }

    public float HasStructuralInspection { get; set; }
    public float HasCorrosionTreatment { get; set; }
    public float HasWingInspection { get; set; }
    public float HasLandingGearInspection { get; set; }
    public float HasLandingGearReplacement { get; set; }
    public float HasEngineBorescope { get; set; }
    public float HasAPUInspection { get; set; }
    public float HasAvionicsUpdate { get; set; }
    public float HasCabinReconfiguration { get; set; }

    public float TotalWorkScore { get; set; }

    public string? CheckType { get; set; }

    [ColumnName("Label")]
    public float DaysToComplete { get; set; }
}