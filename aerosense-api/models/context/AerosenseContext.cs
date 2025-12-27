namespace aerosense.models.context;

using models.aerosense;
using Microsoft.EntityFrameworkCore;

public class AerosenseContext : DbContext
{
    public DbSet<User> Users { get; set; } = null!;

    public DbSet<Role> Roles { get; set; } = null!;

    public DbSet<AircraftType> AircraftTypes { get; set; } = null!;

    public DbSet<Airport> Airports { get; set; } = null!;

    public DbSet<Aircraft> Aircraft { get; set; } = null!;

    public DbSet<Route> Routes { get; set; } = null!;

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseSqlServer("Server=localhost;Database=aerosense;User Id=sa;Password=Luka2905;TrustServerCertificate=True;");
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AircraftType>()
            .Property(at => at.EISDate)
            .HasColumnType("date");

        modelBuilder.Entity<AircraftType>()
            .Property(at => at.WFSDate)
            .HasColumnType("date");

        modelBuilder.Entity<Aircraft>()
            .Property(a => a.FirstFlight)
            .HasColumnType("date");

        modelBuilder.Entity<Aircraft>()
            .Property(a => a.EISDate)
            .HasColumnType("date");

        modelBuilder.Entity<Aircraft>()
            .Property(a => a.WFSDate)
            .HasColumnType("date");

        modelBuilder.Entity<Route>()
            .Property(r => r.CommencedAt)
            .HasColumnType("date");

        modelBuilder.Entity<Route>()
            .Property(r => r.TerminatedAt)
            .HasColumnType("date");
    }
}
