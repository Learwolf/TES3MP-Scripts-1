## Criminals
### Version: 1.1

![Example of the script in action](https://i.imgur.com/9wvbkro.png)

![Another example of the script in action](https://i.imgur.com/RKjTDpf.png)

The script enhances the bounty system by adding global messages when people reach certain tresholds of bounty (defined at the top of the script) or when they manage to clear their name. It also adds the ability to award the bounty to players who kill the criminals. Finally, it is possible to append prefixes to the chat messages sent by criminals, to let others know they indeed broke the law.


## INSTALLING INSTRUCTIONS

1) Put `criminals.lua` file in `...\tes3mp\mp-stuff\scripts\` folder.

2) Open `serverCore.lua` and add `criminals = require("criminals")` at the top along with other `require` lines.

3) Save `server.lua`, open `eventHandler.lua`.

4) Find `Players[pid]:SaveBounty()` and add `criminals.UpdateBounty(pid)` below it.

5) (OPTIONAL) Find `message = config.rankColors.moderator .. "[Mod] " .. message`. Below the `end` line add:
```
            local prefix = criminals.GetPrefix(pid)
            message = prefix .. message
```
to add prefixes to in-game chat messages.

6) Save `eventHandler.lua` and open `\player\base.lua`.

7) Find `self:LoadCell()` and above it add `criminals.OnConnect(self.pid)`.

8) Find `if config.defaultSpawnCell ~= nil then` and above it add `criminals.OnConnect(self.pid)`.

9) Find `local killerPid = tes3mp.GetPlayerKillerPid(self.pid)` and below it add `criminals.ProcessBountyReward(self.pid, killerPid)`.

10) Save `base.lua` and start the server. Try committing a crime serious enough to be detected by the script to ensure that everything is working as intended.

## SETTINGS

### Changes you can make in the script
|Variable|Description|
|:----|:-----|
|bountyThresholds|Bounty threshold values for each criminal level.|
|bountyTitles|Titles for each criminal level, used in prefix.|
|wantedMessages|Messages to display along with `[Notice] <playername>` every time a player reaches a new criminal level.|
|displayGlobalWanted|Whether or not to display a message when a player becomes wanted.|
|displayGlobalClearedBounty|Whether or not to display a message when a player clears their name.|
|displayGlobalBountyClaim|Whether or not to display a message when a player claims a bounty by killing another player.|
|bountyItem|Item used as bounty (normally gold).|

Other messages displayed in chat can be found in various functions in the script. 
## KNOWN ISSUES

The chat prefixes, although completely optional, can interfere with other scripts that add prefixes. Consult `#scripting_help` channel on TES3MP discord server if you happen to use another script which adds prefixes for a solution.

## CHANGELOG:
### 1.1:
[Fix crashes due to undefined custom variable.](https://github.com/quickstraw/tes3mp-scripts)

Allow custom bounty thresholds and titles without rewriting entire script.

### 1.0:
Script updated for 0.7.x.