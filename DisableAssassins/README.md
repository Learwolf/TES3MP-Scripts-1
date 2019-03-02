## DisableAssassins
### VERSION 1.0

Although there are many ways to disable or delay DB assassins to either reduce abuse of the easy-to-acquire expensive equipment or stop new players from constantly dying to them, this script combines multiple possibile approaches into one and allows you to select the option you think suits you best.

## INSTALLING INSTRUCTIONS

1) Copy `disableAssassins.lua` to `.../tes3mp/mp-stuff/scripts`.

2) Open `serverCore.lua` with a text editor.

3) Add `disableAssassins = require("disableAssassins")` at the top, along with all other included scripts.

4) Save and close `serverCore.lua`. Open `eventHandler.lua`. Find `Players[pid]:SaveLevel()`. Below `Players[pid]:SaveStatsDynamic()`, add `disableAssassins.OnLevelUp(pid)`.

5) Save and close `eventHandler.lua`. Open `\player\base.lua`. Find
```
if config.shareJournal == true then
    WorldInstance:LoadJournal(self.pid)
else
    self:LoadJournal()
end
```
and below it add `disableAssassins.OnLogin(self.pid)`.

6) Find
```
if config.shareTopics == true then
    WorldInstance:LoadTopics(self.pid)
end

WorldInstance:LoadKills(self.pid)
```
and below it add `disableAssassins.OnLogin(self.pid)`.

7) Save and close `base.lua`. Open `\world\base.lua`. Find `local refId = tes3mp.GetKillRefId(pid, index)` and below it add `disableAssassins.OnKill(pid, refId)`.

8) Save and close `base.lua`. Open `disableAssassins.lua` and edit the variables above based on your preferences.

## FEATURES AND FUNCTIONALITY

The script which triggers spawning of DB assassins is [dbattackScript](https://pastebin.com/raw/ykvj6Yhz). It first calculates the "severeness" of the attack based on player's level and then rolls the dice to determine whether or not the attack actually happens. Each time an assassin or assassins attack you, a variable `attackonce` is incremented by one. This number determines the lower range of trigger, while your level is associated with the upper range. Therefore, your own level can be used as a limit for how many assassins can spawn, with at most 10 occurances for the highest level threshold (although the odds get smaller the more times the spawn triggers). However, since TES3MP does not save/load game variables, restarting the game resets `attackonce` value and can trigger the spawns again.

This script determines when you kill an assassin and increments a custom variable. On login, the `attackonce` value is set to this custom variable's value, to "load" your progress in the `dbattackScript`. Moreover, one can choose to simply add journal entries for `tr_dbattack` quest all the way to `60`, which ends spawning of the assassins. Alternatively, by manipulating `attackonce` value, one can disable spawning of assassins until certain conditions (for example - level) are met.

## SETTINGS:

### Settings found in the script
|Variable|Description|
|:----|:-----|
|setting|Determines how the script handles assassins. Set value to 1 to add journal entries to disable spawning of assassins on login. Set value to 2 to mimic the default behaviour and track the number of assassin spawns (based on kills) to eventually stop spawning them. Set value to 3 to set `attackonce` value to `initialKills` value on login instead. Set setting value to 4 to require minimum level before assassins can spawn.|
|minLevel|Minimum level required for assassins to begin spawning for a player. Only applicable if `setting` is set to 4.|
|initialKills|Initial value of `attackonce` to use if setting is 3 or 4.|

## CHANGELOG:
### 1.0:
Initial upload of the script.