namespace RouteBlockTime.Predictor.models;

using Microsoft.ML.Data;

public class RouteData
{
    public float DistanceKm { get; set; }

    public float DeltaLongitude { get; set; }

    public float AbsDeltaLatitude { get; set; }

    public float IsEastbound { get; set; }

    public float TurbopropProbability { get; set; }

    [ColumnName("Label")]
    public float BlockTimeMinutes { get; set; }
}