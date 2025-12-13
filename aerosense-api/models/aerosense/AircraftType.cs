namespace aerosense.models.aerosense;

public class AircraftType
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public string? Code { get; set; }

    public int Range { get; set; }

    public DateTime? EISDate { get; set; }

    public DateTime? WFSDate { get; set; }
}