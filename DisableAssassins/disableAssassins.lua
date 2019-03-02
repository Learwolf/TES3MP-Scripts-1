local Methods = {}
--[[Setting defines how the assassins disbaled
1: script checks if the journal entries associated with the quest are present and if not - adds them to the journal to completely
skip having assassins.
2: track how many assassins the player kills and store it in a custom variable. Load the value on login.
3: set assassin spawn occurance to initialKills, which is by default max-1, so players would only see the assassins spawn once.
4: set the appropriate script value to 10 and disable assassins from spawning if player's level is below minLevel value.
Set the value to initialKills instead if above the level requirement.
]]
local setting = 1
-- Minimum level to start having assassins appear if setting == 4
local minLevel = 20
--[[Initial occurance value to use. Only applicable when setting is 3 or 4. The higher the value, the smaller the odds. Odds are 0
at 10, 1% at 9, 11% at 8 and so on. Odds are also affected by player's level - low level will have odds of 0 with values
of 3 and up, for example. In a way, it can be used to delay assassin spawn before certain level is reached, although a separate
setting does it better.]]
local initialKills = 0

-- Check how to handle the script based on setting when player joins the game
Methods.OnLogin = function(pid)
    local data = disableAssassins.DefineData(pid)
    local level = Players[pid].data.stats.level
    if setting == 1 then
        disableAssassins.CheckJournal(pid)
    elseif setting == 2 then
        disableAssassins.LoadKills(pid, data)
    elseif setting == 3 then
        if data.disableAssassins < initialKills then
            data.disableAssassins = initialKills
        end
        disableAssassins.LoadKills(pid, data)
    elseif setting == 4 then
        if level < minLevel then
            -- set it to something very unlikely to occur naturally and disable spawning
            data.disableAssassins = 999
        end
        disableAssassins.LoadKills(pid, data)
    end
end

-- Find customVariables based on journal sharing setting, define saved variable
Methods.DefineData = function(pid)
    local data
    if config.shareJournal then
      data = WorldInstance.data.customVariables
    else
      data = Players[pid].data.customVariables
    end
    if data.Skvysh == nil then
        data.Skvysh = {}
    end
    if data.Skvysh.disableAssassins == nil then
        data.Skvysh.disableAssassins = 0
    end
    return data.Skvysh
end

-- Check if the target killed was an assassin and count it as an occurance for later sessions
Methods.OnKill = function(pid, refId)
    local assassins = {"db_assassin1b", "db_assassin1", "db_assassin2", "db_assassin3", "db_assassin4"}
    local isAssassin = false
    local data = disableAssassins.DefineData(pid)
    if tableHelper.containsValue(assassins, refId, false) then
        isAssassin = true
    end
    if isAssassin then
        data.disableAssassins = data.disableAssassins + 1
    end
end

-- Check if journal already has the quest done and ask to add the entries if not
Methods.CheckJournal = function(pid)
    local journal
    local found = false
    if config.shareJournal then
        journal = WorldInstance.data.journal
    else
        journal = Players[pid].data.journal
    end
    for key, value in pairs(journal) do
        if journal[key].quest == "tr_dbattack" then
            if journal[key].index == 60 then
                found = true
            end
        end
    end
    if found == false then
        disableAssassins.AddJournal(pid)
        disableAssassins.AddTopic(pid)
    end
end

-- Add journal entries to end the attacks and allow teleportation to Mournhold
Methods.AddJournal = function(pid)
    logicHandler.RunConsoleCommandOnPlayer(pid, "Journal TR_DBAttack 10")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Journal TR_DBAttack 30")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Journal TR_DBAttack 40")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Journal TR_DBAttack 50")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Journal TR_DBAttack 60")
end

-- add topics regarding the quest
Methods.AddTopic = function(pid)
    logicHandler.RunConsoleCommandOnPlayer(pid, "AddTopic \"Dark Brotherhood\"")
    logicHandler.RunConsoleCommandOnPlayer(pid, "AddTopic \"transport to Mournhold\"")
    logicHandler.RunConsoleCommandOnPlayer(pid, "AddTopic \"transport to Vvardenfell\"")
end

-- Set occurance value through console based on stored value
Methods.LoadKills = function(pid, data)
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set dbAttackScript.attackonce to " .. data.disableAssassins)
end

-- When a player levels up, check if they passed the threshold and set occurance count to initialKills if that is the case
Methods.OnLevelUp = function(pid)
    local data = disableAssassins.DefineData(pid)
    local level = Players[pid].data.stats.level
    if level >= minLevel then
        -- if it was disabled before through the script
        if data.disableAssassins >= 999 then
            data.disableAssassins = initialKills
            disableAssassins.LoadKills(pid, data)
        end
    end
end

return Methods
