using HarmonyLib;
using RimWorld;
using System.Reflection;
using Verse;

namespace LegacyOfWesternfort
{
    [StaticConstructorOnStartup]
    public static class Base
    {
        public const string ID = "com.rimworld.mod.silverhammermba.legacyofwesternfort";

        public static Harmony patcher;

        static Base()
        {
            patcher = new Harmony(ID);
            patcher.PatchAll(Assembly.GetExecutingAssembly());
        }
    }
}
