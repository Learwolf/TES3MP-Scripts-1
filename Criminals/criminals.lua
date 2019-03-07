------------------
-- Version: 1.1 --
------------------

-- Settings
local bountyThresholds = {500, 1000, 5000} -- thresholds for different criminal levels
local bountyTitles = {"Thief","Criminal","Fugitive"} -- names for different levels
local wantedMessages = {"has been declared a thief.","is now a wanted criminal.","has a death warrant. This criminal scum shall be killed on sight."} -- custom messages to display when player reaches each criminal level (with [notice] <playername> prefix)
local displayGlobalWanted = true -- whether or not to display the global messages in chat when a player's wanted status changes
local displayGlobalClearedBounty = true -- whether or not to display a global message when a player clears their bounty
local displayGlobalBountyClaim = true -- whether or not to display a global message when another player claims a bounty
local bountyItem = "gold_001" -- item used as bounty, in case you use a custom currency
require("color")

local Methods = {}
-- update variables on login/register
Methods.OnConnect = function(pid)
    criminals.DefineData(pid)
    criminals.GetNewCriminalLevel(pid)
end

-- return formatted prefix
Methods.GetPrefix = function(pid)
    local criminalLevel = criminals.GetCriminalLevel(pid)
    local prefix = ""
    if criminalLevel ~= 0 then
        prefix = color.Salmon .. "["
        if bountyTitles[criminalLevel] ~= nil then
            prefix = prefix .. bountyTitles[criminalLevel]
        else
          prefix = prefix .. "N'wah"
        end
        prefix = prefix .. "]" .. color.Default
    end
    return prefix
end

-- calculate current criminal level
Methods.GetCriminalLevel = function(pid)
    local bounty = tes3mp.GetBounty(pid)
    local criminalLevel = 0
    local i
    for i = 1, #bountyThresholds do
        if bounty >= bountyThresholds[i] then
            criminalLevel = criminalLevel + 1
        end
    end
    return criminalLevel
end

-- check if criminal level is updated
Methods.GetNewCriminalLevel = function(pid)
    local criminal = criminals.GetCriminalLevel(pid)
    local previousCriminal = Players[pid].data.customVariables.Skvysh.criminal
    if criminal == previousCriminal then -- if current level is the same as previous one, we dont want to do any updates
        criminal = -1
    else
        Players[pid].data.customVariables.Skvysh.criminal = criminal -- store new criminal level as previous one
    end
    return criminal
end

-- display messages regarding criminal level changes
Methods.UpdateBounty = function(pid)
    local message
    local playerName = tes3mp.GetName(pid)
    local criminal = criminals.GetNewCriminalLevel(pid)
    if criminal > 0 then
        if displayGlobalWanted == true then
            message = color.Crimson .. "[Alert] " .. color.Brown .. playerName .. " " .. color.Default
            if wantedMessages[criminal] ~= nil then
                message = message .. wantedMessages[criminal] .. "\n"
            else
                message = message .. "is an n'wah at large.\n"
            end
            tes3mp.SendMessage(pid, message, true)
        end
    elseif criminal == 0 then
        if displayGlobalClearedBounty == true then
            message = color.Green .. "[Notice] " .. color.Brown .. playerName .. " " .. color.Default
            message = message .. "has cleared their bounty.\n"
            tes3mp.SendMessage(pid, message, true)
        end
    end
end

-- award the bounty to the killer, lower bounty of the killed player, display messages
Methods.ProcessBountyReward = function(pid, killerPid)
    local playerName = tes3mp.GetName(pid)
    local killerName = tes3mp.GetName(killerPid)
    local currentBounty = tes3mp.GetBounty(pid)
    local newBounty
    local reward
    local message
    if pid ~= killerPid then -- don't want players clearing their own bounty by suicide
        if currentBounty > 499 then -- don't want newbies losing gold over petty theft
        if bountyItem ~= "" then
            if tableHelper.containsKeyValue(Players[pid].data.inventory, "refId", bountyItem, true) then
                itemIndex = tableHelper.getIndexByNestedKeyValue(Players[pid].data.inventory, "refId", bountyItem)
                itemCount = Players[pid].data.inventory[itemIndex].count -- find how much gold the player has
            else
                itemCount = 0
            end
            if itemCount >= currentBounty then -- if a bounty can be fully cleared, do so
                    newBounty = 0
                    reward = currentBounty
                else
                    newBounty = currentBounty - itemCount -- otherwise, clear it only partially
                    reward = itemCount
                end
            local structuredItem = { refId = bountyItem, count = reward, charge = -1 } -- give the reward to the killer
            table.insert(Players[killerPid].data.inventory, structuredItem)
            if itemCount ~= 0 then -- if the player actually has gold
                    Players[pid].data.inventory[itemIndex].count = Players[pid].data.inventory[itemIndex].count - reward --remove the gold
                    if Players[pid].data.inventory[itemIndex].count == 0 then
                        Players[pid].data.inventory[itemIndex] = nil
                    end
                    if displayGlobalBountyClaim == true then -- display messages
                        message = color.Green .. "[Notice] " .. color.Brown .. killerName .. color.Default .. " has claimed a bounty of " .. tostring(reward) .. " by killing " .. color.Brown .. Players[pid].name .. color.Default .. ".\n"
                        tes3mp.SendMessage(pid, message, true)
                    else
                        message = color.Brown .. "You" .. color.Default .. " have claimed a bounty of " .. tostring(reward) .. " by killing " .. color.Brown .. Players[pid].name .. color.Default .. ".\n"
                        tes3mp.SendMessage(killerPid, message, false)
                    end
                    if newBounty == 0 then -- display additional message to let people know the player is no longer a criminal
                        if displayGlobalClearedBounty == true then
                            message = color.Green .. "[Notice] " .. color.Brown .. playerName .. " " .. color.Default
                            message = message .. "no longer has a bounty on their head.\n"
                            tes3mp.SendMessage(pid, message, true)
                        end
                    end
                    Players[pid].data.fame.bounty = newBounty -- set new bounty
                    tes3mp.SetBounty(pid, newBounty)
                    tes3mp.SendBounty(pid)
                    Players[pid]:LoadInventory() -- save inventories for both players
                    Players[pid]:LoadEquipment()
                    Players[pid]:Save()
                    Players[killerPid]:LoadInventory()
                    Players[killerPid]:LoadEquipment()
                    Players[killerPid]:Save()
                    criminals.GetNewCriminalLevel(pid)
                end
        end
    end
    end
end

-- define custom variable if there is none, return it if it exists
Methods.DefineData = function(pid)
    local data = Players[pid].data.customVariables
    if data.Skvysh == nil then
        data.Skvysh = {}
    end
    if data.Skvysh.criminal == nil then
        data.Skvysh.criminal = 0
    end
    return data.Skvysh.criminal
end

return Methods
