using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aerosense.Migrations
{
    /// <inheritdoc />
    public partial class AircraftTypeRange : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Range",
                table: "AircraftTypes",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "Aircraft",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Registration = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TypeId = table.Column<int>(type: "int", nullable: true),
                    Configuration = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    FirstFlight = table.Column<DateTime>(type: "date", nullable: true),
                    EISDate = table.Column<DateTime>(type: "date", nullable: true),
                    WFSDate = table.Column<DateTime>(type: "date", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Aircraft", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Aircraft_AircraftTypes_TypeId",
                        column: x => x.TypeId,
                        principalTable: "AircraftTypes",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Aircraft_TypeId",
                table: "Aircraft",
                column: "TypeId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Aircraft");

            migrationBuilder.DropColumn(
                name: "Range",
                table: "AircraftTypes");
        }
    }
}
