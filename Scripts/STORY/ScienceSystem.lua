require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZFunctions")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
	ServiceRate = 1
	Define_State("State_Init", State_Init);
end

function State_Init(message)
	if message == OnEnter then
        DebugMessage("%s -- Setting Init Values", tostring(Script))
        GlobalValue.Set("Science_Level", 0)
        GlobalValue.Set("Next_Tech_Up_At", 0)
        player = Find_Player("Empire")
        tech_level = player.Get_Tech_Level()
        plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_EMPIRE_SCIENCE_LIB.XML")
        Setup_Inital_Level()
	end
end

function Setup_Inital_Level()
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
    elseif tech_level == 5 then
        GlobalValue.Set("Science_Level", 20)
    end
    DebugMessage("%s -- Science Vals: %s, %s", tostring(Script), GlobalValue.Get("Science_Level"), GlobalValue.Get("Next_Tech_Up_At"))
    Set_Display_Level(tech_Level, GlobalValue.Get("Next_Tech_Up_At"))
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

    Story_Event("ACTIVATE_SCIENCE_DISPLAY")
end