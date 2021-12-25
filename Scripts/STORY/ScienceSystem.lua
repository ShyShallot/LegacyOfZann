require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZFunctions")
require("LOZGalacticFuncs")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
	ServiceRate = 1
	Define_State("State_Init", State_Init);
    science_research_lock_time = 70
    science_research_locked = false
    last_researched_week = 0
    fall_behind_threshold = 20
    tech_upgrades = {
        ["tech_2_upgrade"] = Find_Object_Type("DS_Primary_Hyperdrive"), 
        ["tech_3_upgrade"] = Find_Object_Type("DS_Shield_Gen"),
        ["tech_4_upgrade"] = Find_Object_Type("DS_Superlaser_Core"),
        ["tech_5_upgrade"] = Find_Object_Type("DS_Durasteel")
    }
end

function State_Init(message)
	if message == OnEnter then
        DebugMessage("%s -- Setting Init Values", tostring(Script))
        GlobalValue.Set("Science_Level", 0)
        GlobalValue.Set("Next_Tech_Up_At", 0)
        GlobalValue.Set("Science_Increased", 0)
        GlobalValue.Set("Tech_Upgrade_Dones", 0)
        player = Find_Player("Empire")
        tech_level = player.Get_Tech_Level()
        if(tech_level == 5) then
            ScriptExit()
        end
        plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_EMPIRE_SCIENCE_LIB.XML")
        event = plot.Get_Event("Empire_Science_Dis")
        event.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_BODY", fall_behind_threshold)
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
        tech_level = player.Get_Tech_Level()
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

function Lock_Tech_Levels()
    local tech_2 = Find_Object_Type("DS_Primary_Hyperdrive")
    player.Lock_Tech(tech_2)
    local tech_3 = Find_Object_Type("DS_Shield_Gen")
    player.Lock_Tech(tech_3)
    local tech_4 = Find_Object_Type("DS_Superlaser_Core")
    player.Lock_Tech(tech_4)
    local tech_5 = Find_Object_Type("DS_Durasteel")
    player.Lock_Tech(tech_5)
end

function Set_Level()
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
    event = plot.Get_Event("Empire_Science_Dis")
    DebugMessage("%s", tostring(event))
    dialog = "Custom\\Dialog_Empire_Science"
    DebugMessage("%s", tostring(dialog))
    event.Clear_Dialog_Text()
    event.Add_Dialog_Text("Current Science Level: " .. tostring(level))
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
function Unlock_Science_Research() -- This code is modified from the AOTR Interventions Timer, cause using Sleep would pause our entire script which we dont wanna do
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
    if Dirty_Floor(last_researched_week +  fall_behind_threshold) == CurrentWeekRounded() or Dirty_Floor(last_researched_week + fall_behind_threshold) - CurrentWeekRounded() < 1 then
        DebugMessage("%s -- Player Has Fell Behind", tostring(Script))
        Story_Event("SCIENCE_FELL_BEHIND")
        Fall_Tech_Level()
        Sleep(1)
        Set_Level()
        Sleep(1)
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
    if previous_tech_level == 0 then
        return
    end
    Story_Event("SET_TO_TECH_LEVEL_".. tostring(previous_tech_level))
end