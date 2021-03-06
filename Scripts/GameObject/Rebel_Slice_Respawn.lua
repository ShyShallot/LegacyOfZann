--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")

function Definitions()
    --DebugMessage("%s -- In Definitions", tostring(Script))
    Define_State("State_Init", State_Init);
    ServiceRate = 2.0 -- Wait some time before looping
end

function State_Init(message)
    --DebugMessage("%s -- In Inital State, Running Script", tostring(Script))
    if message == OnEnter then -- This is Ran on GC Start, use it to define Vars
        --DebugMessage("%s -- In OnEnter, Running rest of Script", tostring(Script))
        GlobalValue.Set("Total_Slice_Amount", 0)
        GlobalValue.Set("IS_REBEL_ISD_LOCKED", 0)


    elseif message == OnUpdate then -- This is Ran based off of the Service Rate
        --DebugMessage("%s -- Defining Plots and Events", tostring(Script))
        plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_REBEL_SLICE.XML") -- Get Plot file for Text Event
        --DebugMessage("%s -- Finding Player", tostring(Script))
        player = Find_Player("Rebel") -- Find Rebel Player, will 99% of the time not be AI
        are_droids_Dead = GlobalValue.Get("Droid_Dead") -- Global Value to check if C3PO and R2D2 are dead
        if player == nil then -- If the wrong player string is found run this 
            --DebugMessage("%s -- Wrong Player Found, Setting it to proper player", tostring(Script))
            player = Find_Player("REBEL") -- Set Player String as correct if needed, This is a Back up to prevent errors DO NOT DELETE
        end

        --DebugMessage("%s -- Setting Respawn Time Per Tech", tostring(Script))
        if player.Get_Tech_Level() == 0 then -- Get Respawn Time Per each Tech Level
            respawnPerTech = 45 -- Was 85
        elseif player.Get_Tech_Level() == 1 then
            respawnPerTech = 90 -- Was 125
        elseif player.Get_Tech_Level() == 2 then
            respawnPerTech = 135 -- Was 195
        elseif player.Get_Tech_Level() == 3 then
            respawnPerTech = 180 -- Was 245
        end

        if are_droids_Dead == 1 then
            --DebugMessage("%s -- Droid Team is dead, sleeping per Tech Level for Respawn", tostring(Script))
            Sleep(respawnPerTech)
           -- DebugMessage("%s -- Respawned the Droids", tostring(Script))
            Story_Event("REBEL_SLICE_RESPAWN")
            Game_Message("LOZ_REBEL_SLICE_RESPAWN")
            
        end

        if are_droids_Dead == 2 then
           -- DebugMessage("%s -- Special Respawn, From Pirate Planet", tostring(Script))
            --DebugMessage("%s -- Respawned the Droids", tostring(Script))
            Story_Event("REBEL_SLICE_RESPAWN")
            Game_Message("LOZ_REBEL_SLICE_RESPAWN")
        end
    end
end
