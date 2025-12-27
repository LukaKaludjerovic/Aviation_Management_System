namespace aerosense.utils;

using aerosense.models.aerosense;

public static class GeoUtils
{
    private const double EarthRadiusKm = 6371.0;

    public static int GreatCircleDistance(Airport origin, Airport destination)
    {
        var latitudeDifferenceRad = ToRadians(destination.Latitude - origin.Latitude);
        var longitudeDifferenceRad = ToRadians(destination.Longitude - origin.Longitude);

        var originLatitudeRad = ToRadians(origin.Latitude);
        var destinationLatitudeRad = ToRadians(destination.Latitude);

        var haversineFormulaValue =
            Math.Pow(Math.Sin(latitudeDifferenceRad / 2), 2) + (
            Math.Cos(originLatitudeRad) *
            Math.Cos(destinationLatitudeRad) *
            Math.Pow(Math.Sin(longitudeDifferenceRad / 2), 2));

        double angularDistanceRad = 2 * Math.Asin(Math.Sqrt(haversineFormulaValue));

        var greatCircleDistanceKm = EarthRadiusKm * angularDistanceRad;

        var roundedGCD = (int)Math.Ceiling(greatCircleDistanceKm);

        return roundedGCD;
    }

    private static double ToRadians(double degrees)
    {
        var radians = degrees * Math.PI / 180.0;

        return radians;
    }
}