namespace aerosense.models.aerosense;

public class Aircraft
{
    public int Id { get; set; }

    public int MSN { get; set; }

    public string? Registration { get; set; }

    public AircraftType? Type { get; set; }

    public string? Configuration { get; set; }

    public DateTime? FirstFlight { get; set; }

    public DateTime? EISDate { get; set; }

    public DateTime? WFSDate { get; set; }
}