# Diplomacy

Read this in another language | [English](/README.md) | [Русский](/docs/ru/README.md)
|---|---|---|

## Quick Links

[Changelog](CHANGELOG.md) | [Contributing](CONTRIBUTING.md)
|---|---|

## Contents

* [Overview](#overview)
    * [Auto-diplomacy][#auto-diplomacy]
* [Mod settings][#mod-settings]
    * [For maps][#for-maps]
    * [Startup][#startup]
* [Future plans][future-plans]
* [Issues](#issue)
* [Features](#feature)
* [Installing](#installing)
* [Dependencies](#dependencies)
    * [Embedded](#embedded)
* [Special thanks](#special-thanks)
* [License](#license)

## Overview

Adds modified version diplomacy, scenario from PvP and are added diplomatic request, commands needful, auto-diplomacy customizable protection from theft of electricity, customized settings balance.
Compatible with custom PvP scenario (not default). UPS friendly.

I recommend using with mods: [secondary chat][secondary chat] as it is possible write to allies;
[Tiny pole][Tiny pole] if the protection from theft of electricity disabled;
Is it difficult to find enemy players? Use [Dirty talk][Dirty talk];
For balance evolution factor between teams [Soft evolution][Soft evolution];
For a custom "PvP" scenario [Pack scenarios][Pack scenarios].

## Auto-diplomacy

forbidden_entity = (any turret, any wagon, locomotive, car, roboport, radar, rocket-silo)

If you mined entity.type = (forbidden_entity) **OR** entity.max_health >= settings.global["diplomacy-HP-forbidden-entity-on-mined"].value  another faction become enemy.

If you destroy entity.type = (forbidden_entity or player) **OR** entity.max_health >= settings.global["diplomacy-HP-forbidden-entity-on-killed"].value another faction become enemy, else neutral (if you are not already enemies).

If you damage to the entity.max_health >= settings.global["diplomacy-HP-forbidden-entity-on-damage"].value another faction become enemy with low probability.

## Mod settings

### For maps

| Description | Parameters | (Default) |
| ----------- | ---------- | --------- |
| Protection from theft of electricity - does not allow enemy to connect to someone else's electricity | boolean | true |
| Show all factions - hides in diplomacy the factions without players | boolean | false |
| HP to change relationships when killed an object - to change the state relationships when killing an object> = HP | 1-100000000000 | 300 |
| HP to change relationships when mined an object - to change the state relationships when mined an object> = HP | 1-100000000000 | 300 |
| HP to change the relationship for damage to an object - to change the state relationship when damage to the object >= HP with low probability | 1-100000000000 | 300 |
| Allow the player to mining an object from the allied faction | boolean | false |
| Auto-diplomacy when dealing damage - checks damage and changes relationships between factions | boolean | true |
| Diplomatic privilege - which players are able to change teams diplomatic stance towards other teams. All players: Every player on the team. Team leader: The connected player who has been on the team longest. | ["all players", "team leader"] | all players |

### Startup

| Description | Parameters | (Default) |
| ----------- | ---------- | --------- |
| Hide markers of each objects on map | boolean | false |
| HP of rocket silo - to change HP of rocket silo | 1-10000000000 | 50000 |
| Count science pack for the technology of tanks | 1-10000000000 | 1000 |
| Count science pack for the technology of power armor MK2 | 1-10000000000 | 1000 |
| Count science pack for the technology of uranium ammo | 1-10000000000 | 1800 |

## Future plans

* Diplomatic request queue
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
* rename the mod directory to soft-evolution_*versionnumber*, where *versionnumber* is the version of the mod that you've downloaded (e.g., 2.0.0)

## Dependencies

### Embedded

* Event listener: [mods.factorio.com](https://mods.factorio.com/mod/event-listener), [GitLab](https://gitlab.com/ZwerOxotnik/event-listener), [homepage](https://forums.factorio.com/viewtopic.php?f=190&t=64621)


## Special thanks

* **Plov** - tester

## License

Please read [Terms of Service and information](/Terms of Service and information) and [LICENSE](/LICENSE)

[Tiny pole]: https://mods.factorio.com/mod/TinyPole
[secondary chat]: https://mods.factorio.com/mods/ZwerOxotnik/secondary-chat
[Pack scenarios]: https://mods.factorio.com/mod/pack-scenarios
[Soft evolution]: https://mods.factorio.com/mod/soft-evolution
[Dirty talk]: https://mods.factorio.com/mod/dirty-talk
[issues]: https://gitlab.com/ZwerOxotnik/soft-evolution/issues
[mod portal]: https://mods.factorio.com/mod/soft-evolution/discussion
[homepage]: https://forums.factorio.com/viewtopic.php?f=190
[Factorio]: https://factorio.com/
