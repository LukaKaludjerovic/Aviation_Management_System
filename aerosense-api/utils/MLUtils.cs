namespace aerosense.utils;

using System.Text.RegularExpressions;
using aerosense.models.aerosense;
using MaintenanceDuration.Predictor.models;

public static class MLUtils
{
    public static MaintenanceData? ConvertMaintenanceToMaintenanceData(Maintenance maintenance)
    {
        if (maintenance.Aircraft == null ||
            maintenance.Aircraft.Configuration == null ||
            maintenance.Aircraft.Type == null ||
            maintenance.Description == null)
        {
            return null;
        }

        var businessSeats = 0;
        var economySeats = 0;

        var match = Regex.Match(maintenance.Aircraft.Configuration, @"C(?<C>\d+)?Y(?<Y>\d+)|Y(?<Yonly>\d+)");
        if (match.Success)
        {
            if (match.Groups["Y"].Success)
            {
                businessSeats = match.Groups["C"].Success ? int.Parse(match.Groups["C"].Value) : 0;
                economySeats = int.Parse(match.Groups["Y"].Value);
            }
            else if (match.Groups["Yonly"].Success)
            {
                businessSeats = 0;
                economySeats = int.Parse(match.Groups["Yonly"].Value);
            }
        }

        var mlMaintenance = new MaintenanceData()
        {
            AircraftType = maintenance.Aircraft.Type.Name,
            BusinessSeats = businessSeats,
            EconomySeats = economySeats,
            HasStructuralInspection = maintenance.Description.Contains("Structural Inspection", StringComparison.CurrentCultureIgnoreCase) ? 1 : 0,
            HasCorrosionTreatment = maintenance.Description.Contains("Corrosion Treatment", StringComparison.CurrentCultureIgnoreCase) ? 1 : 0,
            HasWingInspection = maintenance.Description.Contains("Wing Inspection", StringComparison.CurrentCultureIgnoreCase) ? 1 : 0,
            HasLandingGearInspection = maintenance.Description.Contains("Landing Gear Inspection", StringComparison.CurrentCultureIgnoreCase) ? 1 : 0,
            HasLandingGearReplacement = maintenance.Description.Contains("Landing Gear Replacement", StringComparison.CurrentCultureIgnoreCase) ? 1 : 0,
            HasEngineBorescope = maintenance.Description.Contains("Engine Borescope", StringComparison.CurrentCultureIgnoreCase) ? 1 : 0,
            HasAPUInspection = maintenance.Description.Contains("APU Inspection", StringComparison.CurrentCultureIgnoreCase) ? 1 : 0,
            HasAvionicsUpdate = maintenance.Description.Contains("Avionics Update", StringComparison.CurrentCultureIgnoreCase) ? 1 : 0,
            HasCabinReconfiguration = maintenance.Description.Contains("Cabin Reconfiguration", StringComparison.CurrentCultureIgnoreCase) ? 1 : 0,
        };

        var checkType = string.Empty;

        if (maintenance.Description.Contains("D Check", StringComparison.CurrentCultureIgnoreCase))
        {
            checkType = "D";
        }
        else if (maintenance.Description.Contains("C Check", StringComparison.CurrentCultureIgnoreCase))
        {
            checkType = "C";
        }
        else if (maintenance.Description.Contains("A Check", StringComparison.CurrentCultureIgnoreCase))
        {
            checkType = "A";
        }

        mlMaintenance.CheckType = checkType;

        mlMaintenance.TotalWorkScore = CalculateTotalWorkScore(mlMaintenance);

        return mlMaintenance;
    }

    private static int CalculateTotalWorkScore(MaintenanceData mlMaintenance)
    {
        bool corrosion = mlMaintenance.CheckType != "A" && mlMaintenance.HasCorrosionTreatment == 1;
        bool lgReplace = mlMaintenance.CheckType == "D" && mlMaintenance.HasLandingGearReplacement == 1;
        bool cabinReconf = mlMaintenance.CheckType != "A" && mlMaintenance.HasCabinReconfiguration == 1;

        var workScore =
            (corrosion ? 8 : 0) +
            (lgReplace ? 9 : 0) +
            (cabinReconf ? 10 : 0);

        var checkFactor = CalculateCheckFactor(mlMaintenance.AircraftType, mlMaintenance.CheckType);

        return workScore + checkFactor;
    }

    private static int CalculateCheckFactor(string? aircraftType, string? checkType)
    {
        if (aircraftType == null || checkType == null)
        {
            return 0;
        }

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
}