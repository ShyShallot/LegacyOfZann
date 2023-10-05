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
        last_planet_diff = GlobalValue.Get("Death_Planet_Diff")
        if player == nil then -- If the wrong player string is found run this 
            --DebugMessage("%s -- Wrong Player Found, Setting it to proper player", tostring(Script))
            player = Find_Player("REBEL") -- Set Player String as correct if needed, This is a Back up to prevent errors DO NOT DELETE
        end

        --DebugMessage("%s -- Setting Respawn Time Per Tech", tostring(Script))
        -- Because the way Rebel Tech works: 0 is Tech Level 1 and so on
        respawnTimePerTechLevel = 
        {
            25, -- Tech 1
            35,
            50,
            60 -- tech 4
        }

        respawnMultiplier = 
        {
            0.75, -- Planet diff 0
            0.85,
            1,
            1.15,
            1.25,
            1.4 -- Planet diff 5
        }

        if are_droids_Dead == 1 then
            --DebugMessage("%s -- Droid Team is dead, sleeping per Tech Level for Respawn", tostring(Script))
            Game_Message("Tech Slice Failed, C3PO and R2D2 will return in " .. respawnTimePerTechLevel[player.Get_Tech_Level()+1] * respawnMultiplier[last_planet_diff+1] .. " Seconds.")
            Sleep(respawnTimePerTechLevel[player.Get_Tech_Level()+1] * respawnMultiplier[last_planet_diff+1])
           -- DebugMessage("%s -- Respawned the Droids", tostring(Script))
            Story_Event("REBEL_SLICE_RESPAWN")
            Game_Message("LOZ_REBEL_SLICE_RESPAWN")
            
        end

        if are_droids_Dead == 2 then
            Game_Message("RD2D and C3PO can't steal tech from a pirate planet, and have traveled to the nearest Rebel System")
           -- DebugMessage("%s -- Special Respawn, From Pirate Planet", tostring(Script))
            --DebugMessage("%s -- Respawned the Droids", tostring(Script))
            Story_Event("REBEL_SLICE_RESPAWN")
            Game_Message("LOZ_REBEL_SLICE_RESPAWN")
        end
    end
end
