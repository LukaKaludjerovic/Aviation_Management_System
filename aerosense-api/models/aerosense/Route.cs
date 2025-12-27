namespace aerosense.models.aerosense;

public class Route
{
    public int Id { get; set; }

    public Airport? Origin { get; set; }

    public Airport? Destination { get; set; }

    public double Distance { get; set; }

    public int BlockTime { get; set; }

    public List<RouteDetail> RouteDetails { get; set; } = [];

    public DateTime? CommencedAt { get; set; }

    public DateTime? TerminatedAt { get; set; }
}