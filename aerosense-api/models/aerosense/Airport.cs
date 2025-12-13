namespace aerosense.models.aerosense;

public class Airport
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public string? City { get; set; }

    public string? Country { get; set; }

    public string? IATACode { get; set; }

    public double Latitude { get; set; }

    public double Longitude { get; set; }
}