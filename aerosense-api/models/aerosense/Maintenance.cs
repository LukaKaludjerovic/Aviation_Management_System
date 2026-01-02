namespace aerosense.models.aerosense;

public class Maintenance
{
    public int Id { get; set; }

    public Aircraft? Aircraft { get; set; }

    public string? Description { get; set; }

    public DateTime? ScheduledFor { get; set; }

    public DateTime? ExpectedCompletitionDate { get; set; }

    public DateTime? CompletedAt { get; set; }
}