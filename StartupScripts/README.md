# Startup Scripts
## VERSION 1.2.2

The script attempts to load as much of the missing objects, variables and anything else that would otherwise be lost after a relog. The variables and entities are adjusted based on player's journal and is independent of the journal sharing progress. Current fixes addressed by the script are documented below and one can expect the list to expand in the future.

## KNOWN ISSUES

Your estate choice in Raven Rock questline will not be saved. Instead, every time you load the game after completing the quest, the position will be assigned based on variable in the script. Edit that variable if you wish to change the position of the estate for everyone on the server (regardless of journal sync).

Since the Great House strongholds are all controled by a single variable, it is possible for people to access other houses' strongholds and wreak havoc, screwing up several quests for other players. There is no way to avoid this without constantly resetting cells or using instances. Moreover, doing the stronghold questline in multiple houses can mess up the loading process and lead you to lower/higher tier stronghold than intended. This behaviour is, in general, unexpected by the game, although the in-game scripts would prevent this issue from arising in a normal fashion. However, since the variables are set manually, this can lead to issues. In short - do not do stronghold questline in multiple houses in one journal.

Startup script, which disables a bunch of entities in 60 cells, will not execute if at least one of them is already loaded. Either delete all the cells and relog or, if for some reason one of the cells **has** to remain between resets, delete it from the `startupCells` variable found at the top. In a similar manner, TES3MP 0.7.0 requires running `BMStartUpScript`, if none of the associated cells are created yet.

If you use a synchronyzed journal, one player progressing in the main Bloodmoon questline will result in all players having werewolf status given to them upon logging in. This is because the only way to know whether a player should be a werewolf or not is through specific quest entries.

The charGen disabling has been tested only briefly. Message box about character record will keep reappearing every time you log in and have it in your inventory. Moreover, the script has no idea about the playstyle of the server. As such, the record will be added only once to player's inventory on login, tracked by custom variable.

## INSTALLING INSTRUCTIONS

1) Copy `startupData.json` (from a folder above) to `.../tes3mp/mp-stuff/data`.

2) Copy `startupScripts.lua` to `.../tes3mp/mp-stuff/scripts`.

3) Open `serverCore.lua` with a text editor.

4) Add `startupScripts = require("startupScripts")` at the top of the file along with other included scripts.

5) Find `logicHandler.PushPlayerList(Players)` and below it add `startupScripts.Initialize()`.

6) Find `function OnPlayerCellChange(pid)` and below it add `startupScripts.OnCellChange(pid)`.

7) Save `serverCore.lua` and close it. Open `eventHandler.lua`.

8) Find `Players[pid].name = playerName` and below it add `startupScripts.RunStartup(pid)`.

9) Save `eventHandler.lua` and close it. Open `/player/base.lua`.

10) Find `if self.hasAccount ~= false then` and below it add `startupScripts.OnLogin(self.pid)`.

11) Find `if config.defaultSpawnCell ~= nil then` and above it add `startupScripts.OnLogin(self.pid)`.

12) Save `base.lua` and close it.

13) (OPTIONAL) Open `startupScripts` and change settings values at the beginning of the script. See the comments in the script for more details.

14) (OPTIONAL) See below for enabling `Census and Excise Office`.

## FEATURES
### Base game:

• Strongholds built through Great House questlines will persist and the building timer progress will be loaded.

• NPCs and objects in 60 cells affected by `Startup` script in TES3 are disabled on server initialization (when a first player connects to a server with no cell data) or enabled/disabled individually for each player when entering each affected cell if the journal is not synchronyzed between players.

• Vampire state and clan depending on which clan you joined (tracked by an entry added to your spellbook).

• All bound items are removed upon loggin in, since they may or may not be stuck in your inventory between sessions.

• Time progress for Boethiah's shrine quest as well as mage's guild expulsion will now be loaded.

• Census and Excise Office can be optionally re-enabled, allowing to talk to NPCs and complete few associated quests.

### Tribunal:

• It should now be possible to properly challenge Karrod and disable his scripted regen, as well as keep track of whether you weakened him beforehand or not.

• `bladefixScript` regarding Trueflame repair should be properly started even after relog.

• A fix for auto-goodbye when talking to NPCs in Mournhold after relogging once the `MournholdAttack` quest was started has been added.

### Bloodmoon:

• RavenRock in Solstheim island, including choice of person you side with and the service, will be loaded properly.

• Progress for individual and cumulative stones in Skaal Test of Loyalty quest will be properly loaded, allowing to relog in between individual stone quests.

• Werewolf state, depending on how far you are in the questline, as well as some variables for related quests and the claw damage rewarded after first Hircine's quest.

• `BMStartUpScript` will be executed if no associated cells are created yet, to disable some of the NPCs and objects, as intended.

• Current wait time progress for colony construction will be set based on the time the journal entry was added and the server time.

## ENABLING CENSUS AND EXCISE OFFICE
Since the variables are not saved in the current TES3MP version, Census and Excise Office had to be disabled because the NPCs would trigger CharGen scripts, resetting your profile. However, by setting the right values on login, the NPCs can be "tricked" into thinking you have already completed the CharGen process. To do so, first edit `startupScripts.lua` by changing value of `disableCharGen` to true (and `giveChargenSheet`, optionally, since you need the sheet to properly start the main questline as well as unlock the 100-lock door in the office). Then, edit `contentFixer.lua` and remove the following lines:
```
refNumDeletionsByCell["Seyda Neen, Census and Excise Office"] = { 119636 }
refNumDeletionsByCell["-1, -9"] = { 268178, 297457, 297459, 297460, 299125 }
refNumDeletionsByCell["-2, -9"] = { 172848, 172850, 172852, 289104, 297461, 397559 }
refNumDeletionsByCell["-2, -10"] = { 297463, 297464, 297465, 297466 }
```
and
```
if cell == "Seyda Neen, Census and Excise Office" then
    tes3mp.MessageBox(pid, -1, "Everything from the default character generation is currently " ..
            "broken in multiplayer. You'll have to avoid that area for now.")
    return false
end
```

With those lines deleted, NPCs will not be removed and you will not be forcibly moved outside when moving into the office.

## ADDING MORE FIXES
You are welcome to modify the `startupData.json` file to properly set more variables, disable/enable more objects and so on. Use the initial data as a guide for formatting the json. You can use this to include the loading of variables for mods, if you server uses them and the mods use them.

## CHANGELOG:
### SCRIPT CHANGELOG:
#### 1.2.2:
My mind can't believe what I see
My heart is bleeding
The story will not finish here
This is not the end

#### 1.2.1:
Fix crashes on register.
Fix scripts not being executed on register.

#### 1.2:
Add capability to load waiting progress for quests that require to come back after a period of time.
Add capability to disable charGen scripts.
Add capability to track mage's guild expulsion timer to some extent.
Move stronghold data to `onLogin` format to work with timers.
Rename custom variables to use the new format.

#### 1.1:
Fix issue with `Startup` script being run at incorrect time.

#### 1.0:
Initial release of the script for TES3MP 0.7.0.

### CHANGELOG FOR THE DATA FILE:
#### 1.2:
Added necessary information for quests where waiting is needed.

#### 1.1:
Added information about bm_stones, tr_blade and tr_champion quests.

#### 1.0:
Initial definition of data file.