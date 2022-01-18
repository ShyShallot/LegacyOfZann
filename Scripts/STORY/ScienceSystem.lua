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
    science_research_data = { -- simplified the science funding data into array, dont know why i didnt do this in the first place
        ["lock_time"] = WeekTime() * 3,
        ["locked"] = false,
        ["active"] = false,
        ["cooldown_active"] = false
    }
    last_researched_week = 0 -- You cant have this 1 as it might fuck with things :)
    fall_behind_threshold = 20 -- The amount of Weeks the player has to do any Research tasks
    tech_upgrades = { -- Create an Array with data values so that we dont have to have like 5 billion if else statements
        ["tech_2_upgrade"] = Find_Object_Type("DS_Primary_Hyperdrive"), 
        ["tech_3_upgrade"] = Find_Object_Type("DS_Shield_Gen"),
        ["tech_4_upgrade"] = Find_Object_Type("DS_Superlaser_Core"),
        ["tech_5_upgrade"] = Find_Object_Type("DS_Durasteel"),
        ["research_upgrade"] = Find_Object_Type("Science_Research")
    }
    research_mission_data = {
        ["chance"] = 0.65, -- 55% chance for a mission
        ["active"] = false,
        ["missions"] = {
            "Send_Tarkin_To_Planet",
            "Build_A_Unit"
        },
        ["cooldown_active"] = false,
        ["cooldown_time"] = WeekTime() * 5 -- lock missions for 5 weeks
    }
    research_mission_units = {
        ["Prototype_Titan_ISD"] = Find_Object_Type("Titan_Star_Destroyer_Prototype"),
        ["MK2_Star_Destroyer"] = Find_Object_Type("Star_Destroyer_2_Prototype"),
        ["Stealth_TIE_Prototype"] = Find_Object_Type("TIE_Phantom_Squadron_Prototype")
    }
    level_data = {
        [1] = {
            ["Science_Level"] = 0,
            ["Next_Tech_Up_At"] = 5
        },
        [2] = {
            ["Science_Level"] = 5,
            ["Next_Tech_Up_At"] = 10
        },
        [3] = {
            ["Science_Level"] = 10,
            ["Next_Tech_Up_At"] = 15
        },
        [4] = {
            ["Science_Level"] = 15,
            ["Next_Tech_Up_At"] = 20
        },
        [5] = {
            ["Science_Level"] = 20,
            ["Next_Tech_Up_At"] = 25 -- Unused, only to not break any system
        },
        level = function()
            return GlobalValue.Get("Science_Level")
        end,
        Next_Level = function()
            return GlobalValue.Get("Next_Tech_Up_At")
        end,
        Add_Level = function(inc)
            if not inc then
                inc = level_data["Mission_Increase"]
            end
            local newLevel = level_data.level() + inc
            GlobalValue.Set("Science_Level", newLevel)
        end,
        Set_Level = function(tech_level)
            GlobalValue.Set("Science_Level", level_data[tech_level]["Science_Level"])
        end,
        Set_Next_Level = function(tech_level)
            GlobalValue.Set("Next_Tech_Up_At", level_data[tech_level]["Next_Tech_Up_At"])
        end,
        ["Mission_Increase"] = 1 -- Just to have a default global value, if you want you can change this var to whatever u want
    }
    current_mission = {}
    any_research_cooldown = false 
    research_cooldown = WeekTime() * 3
end

function State_Init(message)
	if message == OnEnter then
        DebugMessage("%s -- Setting Init Values", tostring(Script))
        GlobalValue.Set("Science_Level", 0) -- We need these as global values, 1 so that we can set them from any other script and 2 so that they can be as easily changes as a normal var
        GlobalValue.Set("Next_Tech_Up_At", 0) -- Although we a func for this in our level_data we dont have one to init
        GlobalValue.Set("Science_Increased", 0)
        GlobalValue.Set("Tech_Upgrade_Done", 0)
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
        Set_Display_Level(level_data.level(), level_data.Next_Level())
        Lock_Tech_Levels()
        Toggle_Research_Upgrade(true)
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
        cur_level = level_data.level()
        next_level = level_data.Next_Level()
        DebugMessage("%s -- Current Level: %s, Next Level: %s", tostring(Script), tostring(cur_level), tostring(next_level))
        if GlobalValue.Get("Tech_Upgrade_Done") == 1 then
            DebugMessage("%s -- Tech Upgrade Finished setting level vals", tostring(Script))
            Set_Level()
            Sleep(1)
            Set_Display_Level(level_data.level(), level_data.Next_Level())
            GlobalValue.Set("Tech_Upgrade_Done", 0)
        end
        if GlobalValue.Get("Science_Increased") == 1 then
            DebugMessage("%s -- Science Was Advanced", tostring(Script))
            last_researched_week = CurrentWeekRounded()
            Game_Message("Next Research will be available in " .. science_research_data["lock_time"] / WeekTime()  .. " Weeks.")
            GlobalValue.Set("Science_Increased", 0)
            Set_Display_Level(cur_level, next_level)
            Toggle_Research_Upgrade(true)
            Create_Thread("Unlock_Science_Research")
            Create_Thread("Research_Cooldown")
        end
        if cur_level == next_level then
            Make_Finalizer_Avail()
        end
        Set_Display_Level(level_data.level(), level_data.Next_Level()) -- we update the display level cause of other functions in it that update last research time and stuff
        Science_Level_Chooser()
        Check_Current_Mission()
        Sleep(1)
    end
end

function Lock_Tech_Levels() -- This isnt really needed as a sepearte function but too lazy to move stuff around
    for i=2,5,1 do -- Start at 2 as that is the first tech upgrade and stop at 5
        player.Lock_Tech(tech_upgrades["tech_" .. i .. "_upgrade"]) -- .. is to combine 2 strings but since i isnt a string but rather a number it gets auto converted into a string
    end
end

function Toggle_Research_Upgrade(bool)
    if bool then
        player.Lock_Tech(tech_upgrades["research_upgrade"])
        science_research_data["active"] = false
        science_research_data["locked"] = true
    else
        player.Unlock_Tech(tech_upgrades["research_upgrade"])
        science_research_data["active"] = true
        science_research_data["locked"] = false
    end
end

function Set_Level() -- Function for Handeling Science Value shit whenever our Tech Level changes, also gets run on script startup
    DebugMessage("%s -- Setting up Science Level Vals", tostring(Script))
    level_data.Set_Next_Level(tech_level)
    level_data.Set_Level(tech_level)
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
        event.Add_Dialog_Text("Last Week Research Happened: None")
    else
        event.Add_Dialog_Text("Last Week Research Happened: ".. tostring(last_researched_week))
    end
    event.Add_Dialog_Text("Weeks Until Tech Behind: " .. tostring((last_researched_week + fall_behind_threshold) - CurrentWeekRounded()))
    if science_research_data["active"] then
        event.Add_Dialog_Text("Science Research Funding is Now Available.")
    elseif any_research_cooldown then
        event.Add_Dialog_Text("Research Funding and Missions are On Cooldown for " .. (last_researched_week + (research_cooldown / WeekTime()) - CurrentWeekRounded()) .. " Weeks.")
    else
        event.Add_Dialog_Text("Science Research Funding is Not Available, Check for any Active Science Missions.")
    end
    Story_Event("ACTIVATE_SCIENCE_DISPLAY")
end

function Make_Finalizer_Avail()
    if tech_level == 5 then
        return
    end
    next_tech = tech_level + 1
    player.Unlock_Tech(tech_upgrades["tech_" .. next_tech.. "_upgrade"])
end

function Unlock_Science_Research()
    science_research_data["cooldown_active"] = true
    Sleep(science_research_data["lock_time"])
    Toggle_Research_Upgrade()
    Game_Message("Research Funding is now Available, Check a planet with a Research Facility")
    science_research_data["cooldown_active"] = false
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
    DebugMessage("%s -- Research Missions Table Length: %s", tostring(Script), tostring(table.getn(research_mission_data["missions"])))
    local random_mission = GameRandom(1, table.getn(research_mission_data["missions"]))
    DebugMessage("%s -- Random Mission: %s", tostring(Script), tostring(random_mission))
    _G[research_mission_data["missions"][random_mission]]()
end

function Build_A_Unit()
    DebugMessage("%s -- Running Build A Unit Mission", tostring(Script))
    research_mission_data["active"] = Toggle_Research_Upgrade
    local randomUnitIndex = Game_Random(1, table.getn(research_mission_units))
    local randomUnit = research_mission_units[randomUnitIndex]
    if type(randomUnit) == nil or type(randomUnit) == "nil" then
        ScriptError("%s -- Error Cant Find Unit: %s, either unit doesnt exist in files or is miss-spelled in the array.", tostring(Script), tostring(randomUnit))
        return
    end
    local build_amount = 1
    DebugMessage("%s -- Selected Random Unit: %s", tostring(Script), tostring(randomUnit))
    local curWeek = CurrentWeekRounded()
    current_mission = {["mission"] = "Build_Prototype_Unit_00", ["flag"] = "Build_Prototype_Unit_01", ["goal"] = randomUnit, ["start"] = curWeek, ["timetocomplete"] = 20, ["reward"] = "Build_Prototype_Unit_03", ["failfunc"] = "Proto_Fail", ["winfunc"] = "Proto_Complete"}
    proto_dialog = plot.Get_Event(current_mission["mission"])
    proto_dialog.Clear_Dialog_Text()
    proto_dialog.Add_Dialog_Text("Prototype Unit to Contruct: " .. tostring(Return_Name(randomUnit)))
    proto_dialog.Add_Dialog_Text("Amount to Construct: " .. build_amount)
    proto_dialog.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_TIME_LIMIT", tostring(current_mission["timetocomplete"]))
    proto_dialog.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_MISSION_STATUS", "In Progress")
    proto_mission = plot.Get_Event(current_mission["flag"])
    proto_mission.Set_Event_Parameter(0, randomUnit)
    proto_mission.Set_Event_Parameter(1, build_amount)
    Sleep(1)
    Story_Event("START_PROTOUNIT_MISSION")
end

function Send_Tarkin_To_Planet()
    DebugMessage("%s -- Running Sending Tarkin to Planet Mission", tostring(Script))
    research_mission_data["active"] = true
    local tarkin = Find_First_Object("Grand_Moff_Tarkin")
    local planets = FindPlanet.Get_All_Planets()
    DebugMessage("%s -- Planets: %s", tostring(Script), tostring(planets))
    local imperial_planets = {}
    for i, p in pairs(planets) do
        if TestValid(p) and Return_Faction(p) == "EMPIRE" then
            table.insert(imperial_planets, p)
            DebugMessage("%s -- Adding %s to Imperial Planet List", tostring(Script), tostring(p))
        end
    end
    local random_planet_index = GameRandom(1, table.getn(imperial_planets))
    DebugMessage("%s -- Random Planet Index: %s", tostring(Script), tostring(random_planet_index))
    local random_planet = imperial_planets[random_planet_index]
    if tarkin.Get_Planet_Location().Get_Type().Get_Name() == random_planet then
        DebugMessage("%s -- Random Planet is Equal to Tarkins Current Planet, Recalcuating", tostring(Script))
        local random_planet_index = GameRandom(1, table.getn(imperial_planets))
        DebugMessage("%s -- Random Planet Index: %s", tostring(Script), tostring(random_planet_index))
        local random_planet = imperial_planets[random_planet_index]
    end
    DebugMessage("%s -- Selected Planet: %s", tostring(Script), tostring(random_planet))
    DebugMessage("%s -- Running Mission Start Story Event", tostring(Script))
    tarkin_event_text = plot.Get_Event("Send_Tarkin_To_Planet_Start")
    tarkin_dialog = "Custom\\Dialog_Empire_Science"
    curWeek = CurrentWeekRounded()
    current_mission = {["mission"] = "Send_Tarkin_To_Planet_Start", ["flag"] = "Has_Tarkin_Arrived", ["goal"] = Return_Name(random_planet), ["start"] = curWeek, ["timetocomplete"] = 12, ["reward"] = "SEND_TARKIN_COMPLETE", ["failfunc"] = "Tarkin_Fail", ["winfunc"] = "Tarkin_Succeed"}
    DebugMessage("%s -- Current Mission Array: %s", tostring(Script), tostring(current_mission))
    tarkin_event_text.Set_Dialog(tarkin_dialog)
    tarkin_event_text.Clear_Dialog_Text()
    DebugMessage("%s -- Clearing Dialog Text", tostring(Script))
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_PLANET_LOCATION", Return_Name(random_planet))
    DebugMessage("%s -- Setting Assigned Planet Text", tostring(Script))
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_TIME_LIMIT", tostring(current_mission["timetocomplete"]))
    DebugMessage("%s -- Adding Weeks to Compelte Mission: %s", tostring(Script), tostring(current_mission["timetocomplete"]))
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_MISSION_STATUS", "In Progress")
    Story_Event("START_TARKIN_MISSION")
end


function Recover_Resources()
    DebugMessage("%s -- Running Recover Resources Mission", tostring(Script))
end

function Calculate_Credit_Return(factor)
    local credits = 2000
    if tech_level == 2 then
        credits = 1750
    elseif tech_level == 3 then
        credits = 1650
    elseif tech_level == 4 then
        credits = 1500
    end -- We dont need one for Tech 5 as the script doesnt run at that point
    local diff = player.Get_Difficulty()
    local multi = 1
    if diff == "Easy" then -- Since we had the multiplier set to 1 on normal diff no need to check if we on that difficulty only modify it if its another one
        multi = 0.8
    elseif diff == "Hard" then
        multi = 1.5
    end
    if not factor then -- Set a default factor if the func was not fed one
        factor = 1
    end
    return tonumber(Dirty_Floor(credits * multi * factor))
end

function Check_Current_Mission()
    DebugMessage("%s -- Checking Mission Status", tostring(Script))
    if research_mission_data["active"] then
        DebugMessage("%s -- Mission Active Checking Story Flag", tostring(Script))
        --DebugMessage("%s -- CurrentWeek Type: %s, Mission Start Time Type: %s, Mission Time to Complete Type: %s", tostring(Script), tostring(type(CurrentWeekRounded())), tostring(type(current_mission["start"])), tostring(type(current_mission["timetocomplete"])))
        DebugMessage("%s -- Week Threshold to Complete Mission: %s", tostring(Script), tostring(current_mission["start"] + current_mission["timetocomplete"]))
        DebugMessage("%s -- Mission Status: %s", tostring(Script), tostring(Check_Mission_Status(current_mission["flag"])))
        if Check_Mission_Status(current_mission["flag"]) and CurrentWeekRounded() <= current_mission["start"] + current_mission["timetocomplete"] then
            DebugMessage("%s -- Player Has Completed the Mission", tostring(Script))
            local credits_to_give = Calculate_Credit_Return(1) -- Calculate the amount of Credits to give based off Difficulty, Tech Level, and a given Factor
            if current_mission["winfunc"] then
                _G[current_mission["winfunc"]](credits_to_give)
            end
            player.Give_Money(credits_to_give)
            if current_mission["reward"] then
                Story_Event(current_mission["reward"])
            end
            Create_Thread("Remove_Story_Mission", current_mission["mission"])
            level_data.Add_Level() -- Due to the way the function works if there is no value provided it falls back to the default increase value which is defined in the level_data array
            current_mission = {}
            research_mission_data["active"] = false
            Mission_Cooldown()
            last_researched_week = CurrentWeekRounded()
            Create_Thread("Research_Cooldown")
            return -- since we reset current_mission we have to return so that the if statement for checking if we failed the mission gets canceled
        end
        if CurrentWeekRounded() > (current_mission["start"] + current_mission["timetocomplete"]) then
            DebugMessage("%s -- Player has failed the mission", tostring(Script))
            if current_mission["failfunc"] then
                _G[current_mission["failfunc"]]()
            end
            Mission_Fail()
            current_mission = {}
            research_mission_data["active"] = false
            Mission_Cooldown()
            Create_Thread("Research_Cooldown")
        end
    end
end

function Mission_Fail()
    Create_Thread("Remove_Story_Mission", current_mission["mission"])
    level_data.Add_Level(-1)
end

function Mission_Cooldown()
    if not research_mission_data["cooldown_active"] then
        Create_Thread("Unlock_Missions")
    end
end

function Unlock_Missions() -- Cooldown Thread thing
    Game_Message("Missions On Cooldown for " .. research_mission_data["cooldown_time"] / WeekTime() .. " Weeks")
    research_mission_data["cooldown_active"] = true
    Sleep(research_mission_data["cooldown_time"])
    research_mission_data["cooldown_active"] = false
    Game_Message("Missions No Longer on Cooldown")
end

function Science_Level_Chooser() -- This function is a fucking mess and i dont fully understand it but it works so whatever
    Sleep(1)
    DebugMessage("%s -- Current Status's: General Cooldown: %s, Mission Active: %s, Missions On Cooldown: %s, Research Funding Locked: %s, Research Funding Active: %s, Research Funding on Cooldown: %s", tostring(Script), tostring(any_research_cooldown), tostring(research_mission_data["active"]), tostring(research_mission_data["cooldown_active"]), tostring(science_research_data["locked"]), tostring(science_research_data["active"]), tostring(science_research_data["cooldown_active"]))
    if any_research_cooldown and last_researched_week ~= 0 then
        DebugMessage("%s -- Research and Funding is on Cooldown", tostring(Script))
        return
    end
    if science_research_data["cooldown_active"] and research_mission_data["cooldown_active"] then
        return
    end
    if research_mission_data["cooldown_active"] and not science_research_data["cooldown_active"] and not research_mission_data["active"] and not science_research_data["active"] then
        Game_Message("Research Funding is now Available, Check a planet with a Research Facility")
        Toggle_Research_Upgrade()
        return
    end
    if not research_mission_data["cooldown_active"] and not research_mission_data["active"] and not science_research_data["active"] and science_research_data["cooldown_active"] then
        Research_Mission_Handler()
        return
    end
    if not science_research_data["cooldown_active"] and not research_mission_data["cooldown_active"] and not research_mission_data["active"] and science_research_data["locked"] then
        if Return_Chance(research_mission_data["chance"], 1.25) then
            Game_Message("A Science Mission is now Available, Check your Mission Logs")
            Research_Mission_Handler()
            return
        else 
            Game_Message("Research Funding is now Available, Check a planet with a Research Facility")
            Toggle_Research_Upgrade()
            return
        end
    end
end

function Check_Mission_Status(mission_flag) -- Seperate Function as it gets checked in an If Statement
    if(_G[mission_flag]()) then
        return true
    else
        return false
    end
end

function Has_Tarkin_Arrived() -- this func is a mess cause Story Scripting was being a pain in the ass
    local tarkin = Find_First_Object("Grand_Moff_Tarkin") -- Trying to find the Team Returned Nil, so if you want the team Object copy below with the Get_Parent_Object
    local tarkin_planet = tarkin.Get_Planet_Location() -- Get his planet location
    if TestValid(tarkin_planet) then -- if he is on a planet
        if tarkin.Get_Planet_Location().Get_Type().Get_Name() == current_mission["goal"] then 
            DebugMessage("%s -- Tarkins Parent Object: %s", tostring(Script), tostring(tarkin.Get_Parent_Object()))
            local tarkin_parent = tarkin.Get_Parent_Object()
            if TestValid(tarkin_parent) then -- If we got Tarkins Parent Object successfully
                local tarkin_planet = tarkin_parent.Get_Parent_Object() -- Get Tarkins Parent Object Parent Object, this is a weird ass workaround to a CTD i was too frustrated to figure out
                if TestValid(tarkin_planet) then
                    DebugMessage("%s -- Tarkin Teams Parent Object: %s", tostring(Script), tostring(tarkin_planet))
                    if tarkin_planet.Get_Type().Get_Name() == current_mission["goal"] then -- This is to make sure he is on the Ground, as the Parent Object of a Land Team returns the Planet, if the team object is in Space it Returns Galactic Fleet
                        DebugMessage("%s -- Tarkin Has Arrived to Goal Planet", tostring(Script))
                        return true
                    end
                end
            end
        end
    end
end

function Remove_Story_Mission(story_event) -- Gets Ran in a Thread so it doesnt interupt any other script function
    DebugMessage("%s -- Starting Remove Event Timer", tostring(Script))
    Sleep(10)
    Remove_Mission(story_event)
    DebugMessage("%s -- Removed Story Mission Dialog", tostring(Script))
end

function Research_Cooldown()
    any_research_cooldown = true
    if any_research_cooldown then
        Sleep(research_cooldown)
        any_research_cooldown = false
    end
end

-- Missio Specific Funs

function Tarkin_Succeed(credits_to_give)
    tarkin_event_text.Clear_Dialog_Text()
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_PLANET_LOCATION", current_mission["goal"])
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_MISSION_STATUS", "Complete")
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_MISSION_CREDITS", tostring(credits_to_give))
end

function Tarkin_Fail()
    tarkin_event_text.Clear_Dialog_Text()
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_PLANET_LOCATION", Return_Name(random_planet))
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_TIME_LIMIT", tostring(current_mission["timetocomplete"]))
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_MISSION_STATUS", "Failed")
end

function Proto_Complete(credits_to_give)
    proto_dialog.Clear_Dialog_Text()
    proto_dialog.Add_Dialog_Text("Prototype Unit to Contruct: " .. tostring(Return_Name(randomUnit)))
    proto_dialog.Add_Dialog_Text("Amount to Construct: " .. build_amount)
    proto_dialog.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_MISSION_STATUS", "Complete")
    proto_dialog.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_MISSION_CREDITS", credits_to_give)
end

function Proto_Fail()
    tarkin_event_text.Clear_Dialog_Text()
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_PLANET_LOCATION", Return_Name(random_planet))
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_TIME_LIMIT", tostring(current_mission["timetocomplete"]))
    tarkin_event_text.Add_Dialog_Text("TEXT_STORY_EMPIRE_SCIENCE_MISSION_STATUS", "Failed")
end