using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aerosense.Migrations
{
    /// <inheritdoc />
    public partial class AircraftMSN : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "MSN",
                table: "Aircraft",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "MSN",
                table: "Aircraft");
        }
    }
}
