# Changelog

## 2019-03-10

### [v2.1.6][v2.1.6]

* Optimization

## 2019-03-09

### [v2.1.5][v2.1.5]

* Small bugfixes

## 2019-03-05

### [v2.1.4][v2.1.4]

* Another title color of the mod

### [v2.1.3][v2.1.3]

* Fast fix for desync

## 2019-03-04

### [v2.1.2][v2.1.2]

* Changed: another dependencies

## 2019-03-02

### [v2.1.1][v2.1.1]

* Fixed: locale "en"

## 2019-03-01

### [v2.1.0][v2.1.0]

* Updated for Factorio 0.17
* Added module «[Event listener][Event listener]»
* Updated localization
* Bugfixes
* Code refactoring

## 2019-01-31

### [v2.0.0][v2.0.0]

* Deleted: PvP scenario (use "[Pack scenarios][Pack scenarios]")
* Deleted: changes in evolution factor from research and etc (use "[Soft evolution][Soft evolution]")
* Added: compability with scenarios
* Added: New settings
* Added: mod interface
* Improved localization
* Improved performance
* A lot of bugfixes
* Refactoring (not finished)
* Uploaded to GitLab

### 2018-04-19

#### [v1.3.18][v1.3.18]

* Fixed: [crash if entity is not valid](https://mods.factorio.com/mod/pack-scenarios/discussion/5ad787fb7037c100097dc235)

#### In scenario PvP:

* Changed: scenario diplomacy/PvP updated from scenario PvP factorio 0.16.36
* Minor and major fixes

### 2018-03-23

#### [v1.3.17][v1.3.17]

#### In scenario PvP:

* Fixed: disabled items
* Minor fixes
* Added: support export on battle surface grid equipment of car, "electric energy interface", partial parameters of "programmable speaker"
* Added: mode "genocide of biters" - kill all biters spawner. The faction that killed the most is winner.
* Changed: scenario pack-scenarios/PvP updated from scenario PvP factorio 0.16.33

### 2018-03-08

#### [v1.3.16][v1.3.16]

* Fixed: crash if close request diplomacy and list diplomacy
* Fixed: command /cancel-stance

#### In scenario PvP:

* Added: (In gui objective) information about "сhare chart data"
* Added: (In gui objective) information about "Disband teams on loss"
* Added: In team config "Team area artillery can be mined" = bool
* Added: Game master
* Added: Extended change surface, can copy and paste entity: not minable/operable/destructible
* Added: In game config "Disable color check for teams?" = bool
* Changed: scenario diplomacy/PvP updated from scenario PvP factorio 0.16.28
* Changed: Tiles of rocket silo "hazard concrete" replaced by "refined hazard concrete"
* Changed: Starting chest "steel chest" replaced by "logistic chest passive provider"
* Changed: Admin frame, button deleted when player was demoted and to create admin button when player promoted
* Deleted: Decorations
* Fixed: Notification on the destruction of the rocket silo
* Fixed: Preset diplomacy
* Fixed: now in modes "production score" and "oil harvest" takes into account only the teams PvP

### 2018-03-03

#### [v1.3.15][v1.3.15]

* Added: mod settings: map:
 Allow the player to mining an object from the allied faction?

#### In scenario PvP:

* Changed: scenario Diplomacy/PvP updated from scenario PvP factorio 0.16.27
* Fixed: change surface (not everything was copied)

### 2018-02-04

#### [v1.3.14][v1.3.14]

#### In scenario PvP:

* Changed: enable all recipes when changing surface before starting a round

#### [v1.3.13][v1.3.13]

#### In scenario PvP:

* Added: change surface **(unstable)**
* Changed: Choose the type of ammo the turrets will start with (supports mods)

### 2018-02-01

#### [v1.3.12][v1.3.12]

#### In scenario PvP:

* Changed: scenario Diplomacy/PvP updated from scenario PvP factorio 0.16.21

### 2018-01-28

#### [v1.3.11][v1.3.11]

#### In scenario PvP:

* Added: ban a player if he destroyed his own a missile silo in the modes "conquest", "last silo standing"

#### [v1.3.8][v1.3.8] 

#### In scenario PvP:

* Fixed: disabled items
* Changed: objective frame 

### 2018-01-26

#### [v1.3.7][v1.3.7]

* Added: mod settings: map: Show all factions - hides in diplomacy the factions without players
* Fixed and changed: description with translation if you damage to an object another faction (allied or neutral).

#### [v1.3.6][v1.3.6]

* Fixed: scenario PvP: description command /change-force

#### [v1.3.5][v1.3.5]

* Changed: scenario Diplomacy/PvP updated from scenario PvP factorio 0.16.19

### 2018-01-25

#### [v1.3.4][v1.3.4]

* Added: Customized mod settings: map:
HP to change the relationship for damage to an object - to change the state relationship when damage to an object >= HP with low probability

### 2018-01-24

#### [v1.3.3][v1.3.3]

* Added: mod settings: startup:
* Added: Count science pack for the technology of power armor MK2
* Added: Count science pack for the technology of uranium ammo
* Fixed: If the faction has not researched the technology "logistics 2", then it is not taken into account (time is also not taken into account).

#### In scenario PvP:

* Fixed: crash if player pick team

### 2018-01-23

#### [v1.3.2][v1.3.2]

* Changed: scenario Diplomacy/PvP updated from scenario PvP factorio 0.16.17 and fixed disabled items.
* Removed: (scenario PvP) Round not started if there online is ANY admin (temporarily?)
* Removed: (scenario PvP) Count disabled items (do not need)

### 2018-01-21

#### [v1.3.1][v1.3.1]

* Added: Customized mod settings: map:
 HP to change relationships when killed object - to change the state relationship when killing an object> = HP
 HP to change relationships when mined object - to change the state relationship when mined an object> = HP

### 2018-01-20

#### [v1.3.0][v1.3.0]

* Added: mod settings: startup:
* Added: HP "rocket silo"
* Added: Make invisible all object on map
* Added: Count science pack for the technology of tanks
* Changed: description mod

#### In scenario PvP added:

* Red color for a team
* Cheat mode
* Count disabled items
* Delete information of players who do not play at all
* Give poison capsule at startup
* Round not started if there online is ANY admin (but there are difficulties...)
* Command /change_force [<username>] * the first N minutes you can change the faction. Only for "players pick team" (60 minutes) and "Auto-assign" (30 minutes)

### 2018-01-16

#### [v1.2.2][v1.2.2]

* Changed: the balanced factor of evolution has increased
* Changed: not taken into account those who have not reached the technology "logistics 2"
* Changed: description mod

### 2018-01-15

#### [v1.2.1][v1.2.1]

* Changed: description mod

#### [v1.2.0][v1.2.0] 

* Added: A balanced evolution from research (+-time, +-players, +number of missiles launched) without/with losing the past evolution Also, the settings have been added to the balanced evolution factor.
* Added: (**not tested**) scenario Diplomacy/PvP from scenario PvP Factorio, but diplomacy privilege don't working.
* Changed: description mod
* Fixed: (scenario PvP) function: disable items for all
p.s. I have **many surprises** for the scenario ;)

### 2018-01-14

#### [v1.1.4][v1.1.4]

* Fixed: message "unknown player: username"

### 2018-01-13

#### [v1.1.3][v1.1.3]

* Fixed: cancel a diplomacy request and after a change in diplomacy

### 2018-01-12

#### v1.1.2* (Removed because there is a critical bug)

* Changed: mod description
* **NOT** Fixed: cancel a diplomacy request and after a change in diplomacy

### 2018-01-11

#### [v1.1.1][v1.1.1]

* Added: command /cancel-stance
* Fixed: description command /check-stance
* Fixed: After frequent changes diplomacy remain requests diplomacy
* Fixed: variable "other_force", "force" now local

### 2018-01-07

#### [v1.1.0][v1.1.0]

* Added: Customizable protection from theft of electricity
* Changed: description of the commands
* Changed: message for all when changing stance diplomacy
* Changed: description mod
* Changed: auto-diplomacy, forbidden_entity = (any turret, any wagon, locomotive, car, roboport, radar, rocket-silo)
If you mined entity.type = (forbidden_entity) another factions become enemy.
If you destroy entity.type = (forbidden_entity or player) another factions become enemy, else neutral (if you are not already enemies).

### 2018-01-05

#### [v1.0.0][v1.0.0]

* First release for 0.16

[Event listener]: https://gitlab.com/ZwerOxotnik/event-listener
[Pack scenarios]: https://forums.factorio.com/viewtopic.php?f=190&t=64631
[Soft evolution]: https://forums.factorio.com/viewtopic.php?f=190&t=64653
[v2.1.6]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_2.1.6.zip
[v2.1.5]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_2.1.5.zip
[v2.1.4]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_2.1.4.zip
[v2.1.3]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_2.1.3.zip
[v2.1.2]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_2.1.2.zip
[v2.1.1]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_2.1.1.zip
[v2.1.0]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_2.1.0.zip
[v2.0.0]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_2.0.0.zip
[v1.3.18]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.18.zip
[v1.3.17]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.17.zip
[v1.3.16]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.16.zip
[v1.3.15]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.15.zip
[v1.3.14]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.14.zip
[v1.3.13]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.13.zip
[v1.3.12]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.12.zip
[v1.3.11]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.11.zip
[v1.3.8]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.8.zip
[v1.3.7]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.7.zip
[v1.3.5]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.6.zip
[v1.3.6]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.5.zip
[v1.3.4]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.4.zip
[v1.3.3]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.3.zip
[v1.3.2]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.2.zip
[v1.3.1]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.1.zip
[v1.3.0]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.3.0.zip
[v1.2.2]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.2.2.zip
[v1.2.1]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.2.1.zip
[v1.2.0]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.2.0.zip
[v1.1.4]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.1.4.zip
[v1.1.3]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.1.3.zip
[v1.1.1]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.1.1.zip
[v1.1.0]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.1.0.zip
[v1.0.0]: https://mods.factorio.com/api/downloads/data/mods/2416/diplomacy_1.0.0.zip
