Based on the Celaeno book series by Jane Fletcher, this mod seeks to interpret
the setting of the books hundreds of years after their conclusion.

## TODO

* Healer sense
  * [Rimworld of Magic](https://github.com/TorannD/TMagic) adds ranged,
    pawn-targeting spells such as "Brand: Fitness" that work without any
    expansion. It looks like it uses weapon-targeting logic
  * [Jec's Tools'](https://github.com/jecrell/JecsTools) `CompAbilityUser` could
    be a foundation for this, but it would be nice to not add the dependency
  * AbilityDefs are built-in. But core only has abstract ones: Data/Core/Defs/AbilityDefs/AbilityDefs.xml
  * If Royalty is installed, the implementation should use the existing psi
    system
  * Cloning/imprinting for animals
      * If Biotech is installed, this should work on humans
        * Probably really tricky, but making healer sense based on genetics
          would be cool
  * If Ideology is installed, it would be cool to have cermonies/rituals tied
    into this
    * Could add an ideology around cloning humans/imprinting animals
  * Ability to purchase cloning/imprinting when trading
  * Most advanced healer sense can kill on touch
* Female-only domestic animals
* Alien species
  * Snow lion
  * Mountain cat
  * Bird species?
  * Rodent species?
  * Remove non-domestic earth species
  * Alien/Earth species are mutually poisonous
