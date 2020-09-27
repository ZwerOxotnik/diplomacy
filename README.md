# Diplomacy

Read this in another language | [English](/README.md) | [Русский](/docs/ru/README.md)
|---|---|---|

## Quick Links

* [Changelog](CHANGELOG.md)

## Contents

* [Overview](#overview)
    * [Auto-diplomacy](#autodiplomacy)
* [Mod settings](#mod-settings)
    * [For maps](#for-maps)
    * [Startup](#startup)
* [Future plans](#future-plans)
* [Issues](#issue)
* [Features](#feature)
* [Installing](#installing)
* [Dependencies](#dependencies)
    * [Required](#required)
    * [Optional](#optional)
* [Special thanks](#special-thanks)
* [License](#license)

## Overview

Adds advanced diplomacy system, diplomatic requests, needful commands, auto-diplomacy, customizable protection from theft of electricity and customized settings balance, etc etc.
Compatible with any PvP scenario. High performance.

I recommend using with mods: [secondary chat][secondary chat] as it is possible write to allies;
[Tiny pole][Tiny pole] if the protection from theft of electricity disabled;
Is it difficult to find enemy players? Use [Dirty talk][Dirty talk];
For balance evolution factor between teams [Soft evolution][Soft evolution];
For a custom "PvP" scenario [Pack scenarios][Pack scenarios].

## <a name="autodiplomacy"></a> Auto-diplomacy

forbidden_entity = (any turret, any wagon, locomotive, car, roboport, radar, rocket-silo)

If you mined entity.type = (forbidden_entity) **OR** entity.max_health >= settings.global["diplomacy-HP-forbidden-entity-on-mined"].value  another faction become enemy.

If you destroy entity.type = (forbidden_entity or player) **OR** entity.max_health >= settings.global["diplomacy-HP-forbidden-entity-on-killed"].value another faction become enemy, else neutral (if you are not already enemies).

If you damage to the entity.max_health >= settings.global["diplomacy-HP-forbidden-entity-on-damage"].value another faction become enemy with low probability.

## <a name="mod settings"></a> Mod settings

### <a name="for-maps"></a> For maps

| Description | Parameters | (Default) |
| ----------- | ---------- | --------- |
| Protection from theft of electricity - does not allow enemies to connect to someone else's electricity | boolean | true |
| Show all factions - Hides in diplomacy factions without playersHides in diplomacy factions without players | boolean | false |
| Required HP for changing relationships for a killed object - changes state relationships when killed an entity HP >= this parameter value | 1-100000000000 | 300 |
| Required HP for changing relationships for a mined object - changes state relationships when mined an object HP >= this parameter value | 1-100000000000 | 300 |
| Required HP for changing relationships for damage to an object - changes state relationships when damage to the object HP >= this parameter value (happens with low probability) | 1-100000000000 | 300 |
| Allow players mine objects from allied factions | boolean | false |
| Auto-diplomacy when dealing damage - checks damage and changes relationships between factions | boolean | true |
| Diplomatic privilege - which players are able to change teams diplomatic stance towards other teams. All players: Every player on the team. Team leader: The connected player who has been on the team longest. | ["all players", "team leader"] | all players |
| Building Prohibition Radius - you can't build near enemies within this radius | 0-25 | 3 |

### <a name="startup"></a> Startup

| Description | Parameters | (Default) |
| ----------- | ---------- | --------- |
| Hide all object markers on map | boolean | false |
| HP of rocket silo - to change HP of rocket silo | 1-10000000000 | 50000 |
| Count science pack for the technology of tanks | 1-10000000000 | 1000 |
| Count science pack for the technology of power armor MK2 | 1-10000000000 | 1000 |
| Count science pack for the technology of uranium ammo | 1-10000000000 | 1800 |

## <a name="future-plans"></a> Future plans

* diplomatic request queue
* Short demonstration video
* Add in "diplomacy" blacklist for factions and scenarios, which will contain the factions/players
* Add in "balanced evolution factor" blacklist for scenarios, which will contain the factions
* Mod settings the map transform in gui of the game
* Faction menu
* Player can exit factions
* Add gui to view the relationship between each other's factions

## <a name="issue"></a> Found an Issue?

Please report any issues or a mistake in the documentation, you can help us by [submitting an issue][issues] to our GitLab Repository or on [mods.factorio.com][mod portal] or on [forums.factorio.com][homepage].

## <a name="feature"></a> Want a Feature?

You can *request* a new feature by [submitting an issue][issues] to our GitLab Repository or on [mods.factorio.com][mod portal] or on [forums.factorio.com][homepage].

## Installing

If you have downloaded a zip archive:

* simply place it in your mods directory.

For more information, see [Installing Mods on the Factorio wiki](https://wiki.factorio.com/index.php?title=Installing_Mods).

If you have downloaded the source archive (GitLab):

* copy the mod directory into your factorio mods directory
* rename the mod directory to diplomacy_*versionnumber*, where *versionnumber* is the version of the mod that you've downloaded (e.g., 2.9.0)

## Dependencies

### Required

* [Event listener](https://mods.factorio.com/mod/event-listener)

### Optional

* [Chat of extended interaction](https://mods.factorio.com/mod/secondary-chat)

## Special thanks

* **Plov** - tester

## License

Please read files [/Terms-of-Service-and-information.txt](/Terms-of-Service-and-information.txt) and [/LICENSE](/LICENSE).

[Tiny pole]: https://mods.factorio.com/mod/TinyPole
[secondary chat]: https://mods.factorio.com/mods/ZwerOxotnik/secondary-chat
[Pack scenarios]: https://mods.factorio.com/mod/pack-scenarios
[Soft evolution]: https://mods.factorio.com/mod/soft-evolution
[Dirty talk]: https://mods.factorio.com/mod/dirty-talk
[issues]: https://gitlab.com/ZwerOxotnik/diplomacy/issues
[mod portal]: https://mods.factorio.com/mod/diplomacy/discussion
[homepage]: https://forums.factorio.com/viewtopic.php?f=190&t=64630
[Factorio]: https://factorio.com/
