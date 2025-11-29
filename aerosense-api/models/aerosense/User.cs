namespace aerosense.models.aerosense;

public class User
{
    public int Id { get; set; }

    public string? FirstName { get; set; }

    public string? LastName { get; set; }

    public string? UserName { get; set; }

    public string? Password { get; set; }

    public Role? Role { get; set; }

    public string? AllowedFunctions { get; set; }

    public string? ForbiddenFunctions { get; set; }

    public DateTime? DeletedTimestamp { get; set; }
}