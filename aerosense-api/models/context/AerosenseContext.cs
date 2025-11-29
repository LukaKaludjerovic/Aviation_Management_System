namespace aerosense.models.context;

using models.aerosense;
using Microsoft.EntityFrameworkCore;
public class AerosenseContext : DbContext
{
    public DbSet<User> Users { get; set; } = null!;

    public DbSet<Role> Roles { get; set; } = null!;

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseSqlServer("Server=localhost;Database=aerosense;User Id=sa;Password=Luka2905;TrustServerCertificate=True;");
        }
    }
}
