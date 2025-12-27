using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aerosense.Migrations
{
    /// <inheritdoc />
    public partial class RouteDetailDaysOfWeek : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DayOfWeek",
                table: "RouteDetail");

            migrationBuilder.AddColumn<string>(
                name: "DaysOfWeek",
                table: "RouteDetail",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DaysOfWeek",
                table: "RouteDetail");

            migrationBuilder.AddColumn<int>(
                name: "DayOfWeek",
                table: "RouteDetail",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }
    }
}
