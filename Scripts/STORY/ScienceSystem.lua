require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZFunctions")
require("LOZGalacticFuncs")
-- Author: ShyShallot
-- This Script Handles the Science System for the Empire
-- Do not use the Science system with the AI as thats a fuck ton of more bullshit, we can just have the AI tech normally via upgrades
-- Thats why the Tech Upgrades are only locked from the script
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
	ServiceRate = 1 
	Define_State("State_Init", State_Init);
    science_research_lock_time = 70 -- This is the Time that the research upgrade is locked for after constructing it
    science_research_locked = false
    last_researched_week = 0 -- You cant have this 1 as it might fuck with things :)
    fall_behind_threshold = 20 -- The amount of Weeks the player has to do any Research tasks
    tech_upgrades = { -- Create an Array with data values so that we dont have to have like 5 billion if else statements
        ["tech_2_upgrade"] = Find_Object_Type("DS_Primary_Hyperdrive"), 
        ["tech_3_upgrade"] = Find_Object_Type("DS_Shield_Gen"),
        ["tech_4_upgrade"] = Find_Object_Type("DS_Superlaser_Core"),
        ["tech_5_upgrade"] = Find_Object_Type("DS_Durasteel")
    }
end

function State_Init(message)
	if message == OnEnter then
        DebugMessage("%s -- Setting Init Values", tostring(Script))
        GlobalValue.Set("Science_Level", 0) -- We need these as global values, 1 so that we can set them from any other script and 2 so that they can be as easily changes as a normal var
        GlobalValue.Set("Next_Tech_Up_At", 0)
        GlobalValue.Set("Science_Increased", 0)
        GlobalValue.Set("Tech_Upgrade_Dones", 0)
        player = Find_Player("Empire") -- define are player so that we can actually do things :) Also i think the Faction Name has to be exact from the XML definiton but too lazy to check
        tech_level = player.Get_Tech_Level() -- Get our Tech Level so that we can properly define our starting Science Level
        if(tech_level == 5) then
            ScriptExit()
        end
        plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_EMPIRE_SCIENCE_LIB.XML") -- Please note that the .XML HAS TO BE CAPITILIZED if not it wont find the file
        event = plot.Get_Event("Empire_Science_Dis")
        Sleep(1)
        Set_Level()
        Sleep(1)
        Set_Display_Level(GlobalValue.Get("Science_Level"), GlobalValue.Get("Next_Tech_Up_At"))
        Lock_Tech_Levels()
	end
    if message == OnUpdate then
        DebugMessage("%s -- In OnUpdate", tostring(Script))
        DebugMessage("Current Week: %s", tostring(CurrentWeekRounded()))
        DebugMessage("Last Researched Week: %s", tostring(last_researched_week))
        Is_Player_Falling_Behind()
        tech_level = player.Get_Tech_Level() -- update our Tech Level to make sure of any time it changes
        if(tech_level == 5) then
            ScriptExit()
        end
        cur_level = GlobalValue.Get("Science_Level")
        next_level = GlobalValue.Get("Next_Tech_Up_At")
        DebugMessage("%s -- Current Level: %s, Next Level: %s", tostring(Script), tostring(cur_level), tostring(next_level))
        if GlobalValue.Get("Tech_Upgrade_Dones") == 1 then
            DebugMessage("%s -- Tech Upgrade Finished setting level vals", tostring(Script))
            Set_Level()
            Sleep(1)
            Set_Display_Level(GlobalValue.Get("Science_Level"), GlobalValue.Get("Next_Tech_Up_At"))
            GlobalValue.Set("Tech_Upgrade_Dones", 0)
        end
        if GlobalValue.Get("Science_Increased") == 1 then
            DebugMessage("%s -- Science Was Advanced", tostring(Script))
            last_researched_week = CurrentWeekRounded()
            Game_Message("Next Research will be available in " .. science_research_lock_time .. " Seconds.")
            GlobalValue.Set("Science_Increased", 0)
            Set_Display_Level(cur_level, next_level)
            research_object = Find_Object_Type("Science_Research")
            player.Lock_Tech(research_object)
            science_research_locked = true
            Create_Thread("Unlock_Science_Research")
        end
        if cur_level == next_level then
            Make_Finalizer_Avail()
        end
        Set_Display_Level(GlobalValue.Get("Science_Level"), GlobalValue.Get("Next_Tech_Up_At")) -- we update the display level cause of other functions in it that update last research time and stuff
        Sleep(1)
    end
end

function Lock_Tech_Levels() -- This isnt really needed as a sepearte function but too lazy to move stuff around
    for i=2,5,1 do -- Start at 2 as that is the first tech upgrade and stop at 5
        player.Lock_Tech(tech_upgrades["tech_" .. i .. "_upgrade"]) -- .. is to combine 2 strings but since i isnt a string but rather a number it gets auto converted into a string
    end
end

function Set_Level() -- Function for Handeling Science Value shit whenever our Tech Level changes, also gets run on script startup
    DebugMessage("%s -- Setting up Science Level Vals", tostring(Script))
    if tech_level == 1 then
        GlobalValue.Set("Next_Tech_Up_At", 5)
    elseif tech_level == 2 then
        GlobalValue.Set("Science_Level", 5)
        GlobalValue.Set("Next_Tech_Up_At", 10)
    elseif tech_level == 3 then
        GlobalValue.Set("Science_Level", 10)
        GlobalValue.Set("Next_Tech_Up_At", 15)
    elseif tech_level == 4 then
        GlobalValue.Set("Science_Level", 15)
        GlobalValue.Set("Next_Tech_Up_At", 20)
    end
    DebugMessage("%s -- Science Vals: %s, %s", tostring(Script), GlobalValue.Get("Science_Level"), GlobalValue.Get("Next_Tech_Up_At"))
end

function Set_Display_Level(level, next_level)
    DebugMessage("%s -- Setting Display Vals", tostring(Script))
    event = plot.Get_Event("Empire_Science_Dis") -- We need the Science Display event so that we can add the Dynamic Text from the Script
    DebugMessage("%s", tostring(event))
    dialog = "Custom\\Dialog_Empire_Science" -- This isnt really ever used but might become useful who knows
    DebugMessage("%s", tostring(dialog))
    event.Clear_Dialog_Text()
    event.Add_Dialog_Text("Current Science Level: " .. tostring(level)) -- I know that the concat shit auto converts numbers to string but programming paranoia hits when you have to restart the game over and over
    event.Add_Dialog_Text("Next Level Until Tech Level Increase: " .. tostring(next_level))
    if last_researched_week == 0 then
        last_researched_week_s = "None"
        event.Add_Dialog_Text("Weeks Since Last Research: ".. tostring(last_researched_week_s))
    else
        event.Add_Dialog_Text("Weeks Since Last Research: ".. tostring(last_researched_week))
    end
    if tech_level == 1 then
        Story_Event("ACTIVATE_SCIENCE_DISPLAY")
        return
    end
    event.Add_Dialog_Text("Weeks Until Tech Behind: " .. tostring((last_researched_week + fall_behind_threshold) - CurrentWeekRounded()))

    Story_Event("ACTIVATE_SCIENCE_DISPLAY")
end

function Make_Finalizer_Avail()
    if tech_level == 5 then
        return
    end
    next_tech = tech_level + 1
    player.Unlock_Tech(tech_upgrades["tech_" .. next_tech.. "_upgrade"])
end

-- Credit to MaxiM
function Unlock_Science_Research() -- This code is modified from the AOTR Interventions Timer, cause using Sleep would pause our entire script for a long period of time which we dont wanna do
    local counter = 0
    local research_object = Find_Object_Type("Science_Research")
    while science_research_locked do
        if counter == science_research_lock_time then
            player.Unlock_Tech(research_object)
            science_research_locked = false
        end
        Sleep(1)
        counter = counter + 1
    end
end

function Is_Player_Falling_Behind()
    DebugMessage("%s -- Fall Behind Week: %s", tostring(Script), tostring(last_researched_week +  fall_behind_threshold))
    if Dirty_Floor(last_researched_week +  fall_behind_threshold) == CurrentWeekRounded() or Dirty_Floor(last_researched_week + fall_behind_threshold) - CurrentWeekRounded() < 1 then -- The reason its like this is cause there was some issues with Week Timings and Shit so its just a backup check
        DebugMessage("%s -- Player Has Fell Behind", tostring(Script))
        Story_Event("SCIENCE_FELL_BEHIND")
        Fall_Tech_Level() -- We could remove the function but too lazy to do so, plus looks a bit cleaner :)
        Sleep(1) -- Give Some Time to make sure that the players Tech Level is properly dropped
        Set_Level()
        Sleep(1) -- Give some time to properly make sure levels are set for tech level
        Set_Display_Level(GlobalValue.Get("Science_Level"), GlobalValue.Get("Next_Tech_Up_At"))
        Sleep(10)
        Story_Event("REMOVE_FELL_BEHIND")
    end
    if Dirty_Floor(last_researched_week + (fall_behind_threshold / 2)) == CurrentWeekRounded() then
        DebugMessage("%s -- Player is Falling Behind", tostring(Script))
        Story_Event("SCIENCE_FALLING_BEHIND")
        Sleep(10)
        Story_Event("REMOVE_FALLING_BEHIND")
    end
end

function Fall_Tech_Level()
    previous_tech_level = tech_level - 1
    if previous_tech_level < 1 then -- We dont/cant decrease the players Tech Level below Tech Level 1 since it doesnt exist, unless we use this for Rebels
        return
    end
    Story_Event("SET_TO_TECH_LEVEL_".. previous_tech_level) -- The Set_Tech_Level function didnt work so we have to use a Story_Event instead
end

function Research_Mission_Handler() -- Todo, cause just having research upgrade stuff would be boring and too linear with less chances of fucking up :)
    -- Put Code Here :)
end