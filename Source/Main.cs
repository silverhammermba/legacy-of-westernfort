using RimWorld;
using Verse;

namespace LegacyOfWesternfort
{
    [StaticConstructorOnStartup]
    public static class HelloWorld
    {
        static HelloWorld()
        {
            Log.Message("hello, world!");
        }
    }
}
