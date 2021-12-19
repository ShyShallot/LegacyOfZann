--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZFunctions")
require("Random_Planet_Starter_No_Underworld") -- We use this function as a base
-- Please Note this script is a total fucking mess, it works and i dont want to spend 2 more days re-writing it
-- This script File is the main Function File for the Rebel Slice Mechanic

function Spawn_Random_Units()
    DebugMessage("%s -- Function called spawning starting units", tostring(Script))
    --Planet_List() This is only used for Debugging, do not renable unless needed
    Spawn_Player_Empire()
    Sleep(1)
    Spawn_Player_Rebel()
    Sleep(1)
    Spawn_Player_Underworld()
    Sleep(2)
    Spawn_Player_Pirates() -- Always spawn pirates last, as they fill in the gaps
    DebugMessage("%s -- All Done", tostring(Script))
end

--function Planet_List()
--    local planets = FindPlanet.Get_All_Planets()
--    for k, v in pairs(planets) do
--        DebugMessage("%s -- Planet List Key", tostring(k))
--        DebugMessage("%s -- Planet List Value", tostring(v))
--    end
--end

function Spawn_Player_Underworld() 
    local player = Find_Player("UNDERWORLD")
    Despawn_Starting_Structure(player)
    DebugMessage("%s -- Despawning Underworld Structure", tostring(Script))
    Sleep(1)
    planet_start = Random_Planet_Select()
    DebugMessage("%s -- Start Planet", tostring(planet_start))
    if TestValid(planet_start) then
        DebugMessage("%s -- Planet is alive", tostring(Script))
        if Return_Faction(planet_start) == "NEUTRAL" then   
            DebugMessage("%s -- Planet Valid for spawn", tostring(Script))
            planet_start.Change_Owner(player)
        end
    else
        DebugMessage("%s -- Planet not found", tostring(Script))
        return
    end
    underworld_start_table = {
        {
            [Find_Object_Type("Kedalbe_Battleship")] = 1,
            [Find_Object_Type("Vengeance_Frigate")] = GameRandom(1,3),
            [Find_Object_Type("StarViper_Squadron")] = GameRandom(2,3),
            [Find_Object_Type("Skipray_Squadron")] = GameRandom(3,6),
        },
        {
            [Find_Object_Type("U_Ground_Droid_Works")] = 1,
            [Find_Object_Type("U_Ground_Palace")] = 1,
            [Find_Object_Type("U_Ground_Vehicle_Factory")] = 1,
            [Find_Object_Type("REBEL_GROUND_MINING_FACILITY")] = 1,
            [Find_Object_Type("Underworld_Merc_Squad")] = GameRandom(2,5),
            [Find_Object_Type("MZ8_Pulse_Cannon_Tank_Company")] = 2
        }
    }
    space_units = underworld_start_table[1]
    ground_units = underworld_start_table[2]
    DebugMessage("%s -- Spawning Underworld Units", tostring(Script))
    Spawn_Space_Station(player, 5, planet_start)
    Spawn_Space_Units(space_units, planet_start, player)
    Spawn_Ground_Units(ground_units, planet_start, player)
    DebugMessage("%s -- All Done", tostring(Script))
end