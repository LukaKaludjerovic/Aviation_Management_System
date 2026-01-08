namespace RouteBlockTime.Predictor.utilities;

public static class AircraftUtil
{
    public static float TurbopropProbability(float distanceKm)
    {
        if (distanceKm <= 300f)
        {
            return 1f;
        }

        if (distanceKm >= 750f)
        {
            return 0f;
        }

        return 1f - ((distanceKm - 300f) / (750f - 300f));
    }
}