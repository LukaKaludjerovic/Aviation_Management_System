namespace aerosense.models.aerosense;

public class Role
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public string? AllowedFunctions { get; set; }

    public DateTime? DeletedTimestamp { get; set; }
}