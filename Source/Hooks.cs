using HarmonyLib;
using RimWorld;
using System.Collections.Generic;
using System.Linq;
using System.Runtime;
using Verse;

namespace LegacyOfWesternfort
{
    // using https://github.com/Llyme/RW_CustomPawnGeneration as a starting point

    [HarmonyPatch(typeof(ParentRelationUtility), "SetFather")]
    public static class ParentRelationUtility_SetFather
    {
        [HarmonyPriority(Priority.Last)]
        [HarmonyPrefix]
        public static bool Patch(this Pawn pawn, Pawn newFather)
        {
            // Ignore limitations of being a father (gender.)

            if (newFather != null)
                pawn.relations.AddDirectRelation(PawnRelationDefOf.Parent, newFather);

            return false;
        }
    }


    [HarmonyPatch(typeof(ParentRelationUtility), "GetFather")]
    public static class Patch_ParentRelationUtility_GetFather
    {
        [HarmonyPriority(Priority.Last)]
        [HarmonyPostfix]
        public static void Patch(this Pawn pawn, ref Pawn __result)
        {
            if (__result != null)
                return;

            if (!pawn.RaceProps.IsFlesh)
                return;

            // If parents are both females, get the 2nd one.
            // N.B. in-game both relations are listed as "Mother". I'm guessing the string used is gender-based
            IEnumerable<DirectPawnRelation> directRelations = pawn.relations.DirectRelations.Where(v => v.def == PawnRelationDefOf.Parent);
            DirectPawnRelation male = directRelations.FirstOrDefault(v => v.otherPawn.gender != Gender.Female);

            if (male != null)
            {
                __result = male.otherPawn;
                return;
            }

            DirectPawnRelation mother = directRelations.FirstOrDefault(v => v.otherPawn.gender != Gender.Male);
            __result = directRelations.FirstOrDefault(v => v != mother)?.otherPawn;
        }
    }

    // for some reason we patch the gender right before generating the pawn's age
    [HarmonyPatch(typeof(PawnGenerator), "GenerateRandomAge")]
    public static class Patch_PawnGenerator_GenerateRandomAge
    {
        [HarmonyPriority(Priority.Last)]
        [HarmonyPrefix]
        public static void Prefix(Pawn pawn, PawnGenerationRequest request)
        {
            pawn.gender = Gender.Female;
        }
    }
}
