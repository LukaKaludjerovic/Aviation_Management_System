namespace aerosense.models.aerosense;

public class RouteDetail
{
    public int Id { get; set; }

    public int RouteId { get; set; }

    public string? FlightNumber { get; set; }

    public string? DaysOfWeek { get; set; }

    public string? Departure { get; set; }

    public string? Arrival { get; set; }

    public AircraftType? AircraftType { get; set; }
}