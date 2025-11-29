namespace aerosense.extensions;

public static class ResponseExtensions
{
    public static object ToResponseError(this string message)
    {
        return new
        {
            error = message,
        };
    }
}