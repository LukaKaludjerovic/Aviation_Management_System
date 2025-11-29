namespace aerosense.authorization;

public class AuthStorage
{
    private static Dictionary<string, Auth> auths = [];

    public static Auth? Get(string token)
    {
        if (auths.ContainsKey(token))
        {
            return auths[token];
        }

        return null;
    }

    public static void Put(Auth auth)
    {
        if (auths.ContainsKey(auth.Token))
        {
            auths.Remove(auth.Token);
        }

        auths.Add(auth.Token, auth);
    }

    public static void Delete(Auth auth)
    {
        if (auths.ContainsKey(auth.Token))
        {
            auths.Remove(auth.Token);
        }
    }
}