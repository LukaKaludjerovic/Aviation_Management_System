namespace aerosense.utils;

using System.Security.Cryptography;
using System.Text;

public static class EncryptUtils
{
    private const string Salt = "AeroSenseAMOS";

    public static string HashPassword(string password)
    {
        var combined = password + Salt;
        var bytes = Encoding.UTF8.GetBytes(combined);
        var hash = SHA256.HashData(bytes);

        return Convert.ToBase64String(hash);
    }

    public static bool VerifyPassword(string password, string hash)
    {
        var hashedInput = HashPassword(password);

        return hashedInput == hash;
    }

    public static string GenerateToken(string username, string password)
    {
        var combined = username + password + Salt;
        var bytes = Encoding.UTF8.GetBytes(combined);
        var hash = SHA256.HashData(bytes);

        return Convert.ToBase64String(hash);
    }
}