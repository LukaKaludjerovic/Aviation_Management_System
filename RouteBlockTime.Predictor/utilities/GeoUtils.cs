namespace RouteBlockTime.Predictor.utilities;

public static class GeoUtils
{
    private const double EarthRadiusKm = 6371.0;

    public static float GreatCircleDistance(float lat1, float lon1, float lat2, float lon2)
    {
        var latitudeDifferenceRad = ToRadians(lat2 - lat1);
        var longitudeDifferenceRad = ToRadians(lon2 - lon1);

        var originLatitudeRad = ToRadians(lat1);
        var destinationLatitudeRad = ToRadians(lat2);

        var haversineFormulaValue =
            Math.Pow(Math.Sin(latitudeDifferenceRad / 2), 2) + (
            Math.Cos(originLatitudeRad) *
            Math.Cos(destinationLatitudeRad) *
            Math.Pow(Math.Sin(longitudeDifferenceRad / 2), 2));

        double angularDistanceRad = 2 * Math.Asin(Math.Sqrt(haversineFormulaValue));

        var greatCircleDistanceKm = EarthRadiusKm * angularDistanceRad;

        return (float)greatCircleDistanceKm;
    }

    private static double ToRadians(double degrees)
    {
        var radians = degrees * Math.PI / 180.0;

        return radians;
    }
}