namespace RouteBlockTime.Predictor.utilities;

using RouteBlockTime.Predictor.models;

public static class DataGenerator
{
    private record Region(float minLat, float maxLat, float minLon, float maxLon, string name);

    private static readonly Region[] Continents =
    {
        new (15f, 72f, -170f, -50f, "North America"),
        new (-55f, 15f, -85f, -30f, "South America"),
        new (35f, 72f, -10f, 40f, "Europe"),
        new (-35f, 35f, -20f, 55f, "Africa"),
        new (5f, 80f, 40f, 180f, "Asia"),
        new (-50f, 0f, 110f, 180f, "Australia/Oceania"),
    };

    private static readonly Random Rand = new (42);

    public static IEnumerable<RouteData> GenerateTestSet(int count)
    {
        for (int i = 0; i < count; i++)
        {
            yield return Generate();
        }
    }

    public static RouteData Generate()
    {
        Region origin = Pick(Continents);
        Region destination = Pick(Continents);

        float originLat = RandomRange(origin.minLat, origin.maxLat);
        float originLon = RandomRange(origin.minLon, origin.maxLon);

        float destLat = RandomRange(destination.minLat, destination.maxLat);
        float destLon = RandomRange(destination.minLon, destination.maxLon);

        float distanceKm = GeoUtils.GreatCircleDistance(originLat, originLon, destLat, destLon);

        float deltaLon = destLon - originLon;
        float isEastbound = deltaLon > 0 ? 1 : 0;

        float absDeltaLat = Math.Abs(destLat - originLat);

        float turbopropProb = AircraftUtil.TurbopropProbability(distanceKm);

        float blockTime;

        if (distanceKm < 300)
        {
            blockTime = 40f + (distanceKm * 0.08f);

            blockTime += RandomNoise(4f);
        }
        else if (distanceKm < 3500)
        {
            bool isAtr = Rand.NextDouble() < turbopropProb;

            float speedKmh = isAtr ? 260f : 650f;

            float cruiseMinutes = distanceKm / speedKmh * 60f;

            float windFactor = distanceKm < 800f ? 0.02f : 0.04f;

            float windMinutes = isEastbound == 1f
                ? -cruiseMinutes * windFactor
                : cruiseMinutes * windFactor;

            float fixedMinutes = isAtr
                ? (distanceKm < 800f ? 25f : 30f)
                : (distanceKm < 800f ? 30f : 35f);

            blockTime =
                fixedMinutes +
                cruiseMinutes +
                windMinutes +
                RandomNoise(5f);
        }
        else
        {
            float longHaulBlockSpeed = 720f;

            float cruiseMinutes = distanceKm / longHaulBlockSpeed * 60f;

            float windMinutes = isEastbound == 1f ? -distanceKm / 250 : distanceKm / 250;

            blockTime = cruiseMinutes +
                windMinutes +
                RandomNoise(10f);
        }

        return new RouteData
        {
            DistanceKm = distanceKm,
            DeltaLongitude = deltaLon,
            AbsDeltaLatitude = absDeltaLat,
            IsEastbound = isEastbound,
            TurbopropProbability = turbopropProb,
            BlockTimeMinutes = blockTime,
        };
    }

    private static float RandomRange(float min, float max)
    {
        return min + ((float)Rand.NextDouble() * (max - min));
    }

    private static float RandomNoise(float offset)
    {
        return (((float)Rand.NextDouble() * 2f) - 1f) * offset;
    }

    private static T Pick<T>(T[] values)
    {
        return values[Rand.Next(values.Length)];
    }
}