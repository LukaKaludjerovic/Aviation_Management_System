namespace MaintenanceDuration.Predictor.utilities;

using MaintenanceDuration.Predictor.models;

public static class DataGenerator
{
    private static readonly Random Rand = new (42);

    public static IEnumerable<MaintenanceData> GenerateTestSet(int count)
    {
        for (int i = 0; i < count; i++)
        {
            yield return Generate();
        }
    }

    public static MaintenanceData Generate()
    {
        var checkType = Pick(["A", "C", "D", string.Empty]);

        var corrosion = checkType != "A" && Chance(0.2);
        var lgReplace = checkType == "D" && Chance(0.15);
        var cabinReconf = checkType != "A" && Chance(0.1);

        var hasStructuralInspection = Chance(0.9) ? 1 : 0;
        var hasCorrosionTreatment = corrosion ? 1 : 0;
        var hasWingInspection = Chance(0.6) ? 1 : 0;
        var hasLandingGearInspection = Chance(0.95) ? 1 : 0;
        var hasLandingGearReplacement = lgReplace ? 1 : 0;
        var hasEngineBorescope = Chance(0.5) ? 1 : 0;
        var hasAPUInspection = Chance(0.4) ? 1 : 0;
        var hasAvionicsUpdate = Chance(0.3) ? 1 : 0;
        var hasCabinReconfiguration = cabinReconf ? 1 : 0;

        var workScore =
            (corrosion ? 8 : 0) +
            (lgReplace ? 9 : 0) +
            (cabinReconf ? 10 : 0);

        float workDays = 0;
        if (hasStructuralInspection == 1)
        {
            workDays += 2f;
        }

        if (hasCorrosionTreatment == 1)
        {
            workDays += 3f;
        }

        if (hasWingInspection == 1)
        {
            workDays += 1.5f;
        }

        if (hasLandingGearInspection == 1)
        {
            workDays += 2f;
        }

        if (hasLandingGearReplacement == 1)
        {
            workDays += 4f;
        }

        if (hasEngineBorescope == 1)
        {
            workDays += 2f;
        }

        if (hasAPUInspection == 1)
        {
            workDays += 1.5f;
        }

        if (hasAvionicsUpdate == 1)
        {
            workDays += 1f;
        }

        if (hasCabinReconfiguration == 1)
        {
            workDays += 3f;
        }

        var businessSeatsOptions = new[] { 0, 0, 0, 0, 0, 18, 21, 22 };
        var economySeatsOptions = new[] { 70, 72, 118, 144, 180, 250, 236, 240 };
        var aircraftTypeOptions = new[] { "ATR 72-600", "Embraer ERJ-195", "Airbus A319-100", "Airbus A320-200", "Airbus A330-200" };

        var seatsPicked = Rand.Next(8);
        int aircraftPicked;

        if (seatsPicked <= 1)
        {
            aircraftPicked = 0;
        }
        else if (seatsPicked >= 5)
        {
            aircraftPicked = 4;
        }
        else
        {
            aircraftPicked = seatsPicked - 1;
        }

        var aircraftType = aircraftTypeOptions[aircraftPicked];
        var businessSeats = businessSeatsOptions[seatsPicked];
        var economySeats = economySeatsOptions[seatsPicked];

        var checkFactor = CalculateCheckFactor(aircraftType, checkType);
        var baseAircraftDays = AircraftBaseDays(aircraftType);
        var seatDays = SeatFactor(businessSeats, economySeats);

        var days =
            baseAircraftDays +
            seatDays +
            checkFactor +
            workDays +
            ((float)Rand.NextDouble() * 2.5f);

        return new MaintenanceData()
        {
            AircraftType = aircraftType,

            BusinessSeats = businessSeats,
            EconomySeats = economySeats,

            HasStructuralInspection = hasStructuralInspection,
            HasCorrosionTreatment = hasCorrosionTreatment,
            HasWingInspection = hasWingInspection,
            HasLandingGearInspection = hasLandingGearInspection,
            HasLandingGearReplacement = hasLandingGearReplacement,
            HasEngineBorescope = hasEngineBorescope,
            HasAPUInspection = hasAPUInspection,
            HasAvionicsUpdate = hasAvionicsUpdate,
            HasCabinReconfiguration = hasCabinReconfiguration,

            TotalWorkScore = workScore + checkFactor,
            CheckType = checkType,
            DaysToComplete = days,
        };
    }

    private static bool Chance(double p)
    {
        return Rand.NextDouble() < p;
    }

    private static T Pick<T>(T[] values)
    {
        return values[Rand.Next(values.Length)];
    }

    private static float CalculateCheckFactor(string aircraftType, string checkType)
    {
        int checkFactor;
        if (aircraftType.Contains("ATR"))
        {
            checkFactor = checkType switch
            {
                "A" => 4,
                "C" => 10,
                "D" => 20,
                _ => 0,
            };

            return checkFactor;
        }

        if (aircraftType.Contains("ERJ"))
        {
            checkFactor = checkType switch
            {
                "A" => 5,
                "C" => 12,
                "D" => 24,
                _ => 0,
            };

            return checkFactor;
        }

        if (aircraftType.Contains("A319"))
        {
            checkFactor = checkType switch
            {
                "A" => 6,
                "C" => 13,
                "D" => 26,
                _ => 0,
            };

            return checkFactor;
        }

        if (aircraftType.Contains("A320"))
        {
            checkFactor = checkType switch
            {
                "A" => 6,
                "C" => 14,
                "D" => 28,
                _ => 0,
            };

            return checkFactor;
        }

        if (aircraftType.Contains("A330"))
        {
            checkFactor = checkType switch
            {
                "A" => 9,
                "C" => 18,
                "D" => 40,
                _ => 0,
            };

            return checkFactor;
        }

        checkFactor = checkType switch
        {
            "A" => 7,
            "C" => 14,
            "D" => 30,
            _ => 0,
        };

        return checkFactor;
    }

    private static float AircraftBaseDays(string aircraftType)
    {
        if (aircraftType.Contains("ATR"))
        {
            return 3f;
        }

        if (aircraftType.Contains("ERJ"))
        {
            return 4f;
        }

        if (aircraftType.Contains("A319"))
        {
            return 5f;
        }

        if (aircraftType.Contains("A320"))
        {
            return 6f;
        }

        if (aircraftType.Contains("A330"))
        {
            return 9f;
        }

        return 5f;
    }

    private static float SeatFactor(int business, int economy)
    {
        return (business * 0.15f) + (economy * 0.05f);
    }
}