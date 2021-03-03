--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZFunctions")
-- Please Note this script is a total fucking mess, it works and i dont want to spend 2 more days re-writing it
-- This script File is the main Function File for the Rebel Slice Mechanic

function Spawn_Random_Units()
    DebugMessage("%s -- Function called spawning starting units", tostring(Script))
    pirate_control_threshold = 0.7 -- a percentage, from 0 to 1, 1 being pirates control 100% of all neutral planets
    --Planet_List() This is only used for Debugging, do not renable unless needed
    Spawn_Player_Empire()
    Sleep(1)
    Spawn_Player_Rebel()
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

function Despawn_Starting_Structure(player)
    playerFac = player.Get_Faction_Name()
    if playerFac == "EMPIRE" then
        DebugMessage("%s -- Player is Empire", tostring(Script))
        starting_struct = Find_First_Object("E_Ground_Barracks", player)
    elseif playerFac == "REBEL" then
        DebugMessage("%s -- Player is Rebel", tostring(Script))
        starting_struct = Find_First_Object("R_Ground_Barracks", player)
    elseif playerFac == "PIRATES" then
        DebugMessage("%s -- Player is Pirates", tostring(Script))
        starting_struct = Find_First_Object("Pirate_Command_Center", player)
    end

    if TestValid(starting_struct) then
        DebugMessage("%s -- Found Struct, Getting Planet location", tostring(Script))
        starting_struct_planet = starting_struct.Get_Planet_Location()
        DebugMessage("%s -- Despawning Struct", tostring(Script))
        starting_struct.Despawn()
        DebugMessage("%s -- Resetting that planet", tostring(Script))
        starting_struct_planet.Change_Owner(Find_Player("NEUTRAL"))
        DebugMessage("%s -- All done", tostring(Script))
    else
        DebugMessage("%s -- Could not find Struct", tostring(Script))
        return
    end
end

function Spawn_Player_Pirates()
    player = Find_Player("PIRATES")
    Despawn_Starting_Structure(player)
    DebugMessage("%s -- Despawning pirate structure", tostring(Script))
    Sleep(1)
    
    pirate_start_table = {
        {
            [Find_Object_Type("PIRATE_ASTEROID_BASE")] = 1,
            [Find_Object_Type("PIRATE_FRIGATE")] = 1,
            [Find_Object_Type("PIRATE_CORONA_FRIGATE")] = GameRandom(1,2),
            [Find_Object_Type("Z95_HEADHUNTER_SQUADRON")] = GameRandom(2,8),
        },
        {
            [Find_Object_Type("PIRATE_COMMAND_CENTER")] = 1,
            [Find_Object_Type("PIRATE_SKIFF_TEAM")] = GameRandom(1,4),
            [Find_Object_Type("PIRATE_SOLDIER_SQUAD")] = GameRandom(2,5),
        }
    }
    space_units = pirate_start_table[1]
    ground_units = pirate_start_table[2]
    local planets = FindPlanet.Get_All_Planets()
    local planetcount = table.getn(planets) * pirate_control_threshold
    for x=planetcount, 0, -1 do
        for k, planet in pairs(planets) do
            if TestValid(planet) and Return_Faction(planet) == "NEUTRAL" then
                DebugMessage("%s -- Planet Valid for spawning", tostring(Script))
                if Return_Faction(planet) == "NEUTRAL" and (Return_Faction(planet) ~= "REBEL" or Return_Faction(planet) ~= "EMPIRE") then   
                    DebugMessage("%s -- Planet Valid for spawn", tostring(Script))
                    planet.Change_Owner(player)
                    Spawn_Space_Units(space_units, planet)
                    Spawn_Ground_Units(ground_units, planet)
                else
                    return
                end
            end
        end
    end
    DebugMessage("%s -- All Done spawning Pirates", tostring(Script))
end

function Spawn_Player_Empire()
    player = Find_Player("EMPIRE")
    Despawn_Starting_Structure(player)
    DebugMessage("%s -- Despawning Empire Structure", tostring(Script))
    Sleep(1)
    planet_start = Random_Planet_Select()
    if TestValid(planet_start) then
        if Return_Faction(planet_start) == "NEUTRAL" then   
            DebugMessage("%s -- Planet Valid for spawn", tostring(Script))
            planet_start.Change_Owner(player)
        end
    else
        return
    end
    empire_start_table = {
        {
            [Find_Object_Type("Empire_Star_Base_5")] = 1,
            [Find_Object_Type("STAR_DESTROYER")] = 1,
            [Find_Object_Type("ACCLAMATOR_ASSAULT_SHIP")] = 1,
            [Find_Object_Type("TIE_BOMBER_SQUADRON")] = 1,
            [Find_Object_Type("TIE_FIGHTER_SQUADRON")] = 2,
        },
        {
            [Find_Object_Type("E_GROUND_BARRACKS")] = 1,
            [Find_Object_Type("E_GROUND_LIGHT_VEHICLE_FACTORY")] = 1,
            [Find_Object_Type("EMPIRE_GROUND_MINING_FACILITY")] = 1,
            [Find_Object_Type("IMPERIAL_STORMTROOPER_SQUAD")] = 2,
            [Find_Object_Type("IMPERIAL_HEAVY_SCOUT_SQUAD")] = 2
        }
    }

    space_units = empire_start_table[1]
    ground_units = empire_start_table[2]
    DebugMessage("%s -- Spawning Units", tostring(Script))
    Spawn_Space_Units(space_units, planet_start)
    Spawn_Ground_Units(ground_units, planet_start)
    DebugMessage("%s -- All Done", tostring(Script))
end

function Spawn_Player_Rebel()
    player = Find_Player("REBEL")
    Despawn_Starting_Structure(player)
    DebugMessage("%s -- Despawning Rebel Structure", tostring(Script))
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
    rebel_start_table = {
        {
            [Find_Object_Type("Rebel_Star_Base_5")] = 1,
            [Find_Object_Type("CALAMARI_CRUISER")] = 1,
            [Find_Object_Type("NEBULON_B_FRIGATE")] = GameRandom(1,3),
            [Find_Object_Type("Y-WING_SQUADRON")] = GameRandom(2,3),
            [Find_Object_Type("REBEL_X-WING_SQUADRON")] = GameRandom(3,6),
        },
        {
            [Find_Object_Type("R_GROUND_BARRACKS")] = 1,
            [Find_Object_Type("R_GROUND_LIGHT_VEHICLE_FACTORY")] = 1,
            [Find_Object_Type("REBEL_GROUND_MINING_FACILITY")] = 1,
            [Find_Object_Type("REBEL_INFANTRY_SQUAD")] = GameRandom(2,5),
            [Find_Object_Type("REBEL_LIGHT_TANK_BRIGADE")] = 2
        }
    }
    space_units = rebel_start_table[1]
    ground_units = rebel_start_table[2]
    DebugMessage("%s -- Spawning Rebel Units", tostring(Script))
    Spawn_Space_Units(space_units, planet_start)
    Spawn_Ground_Units(ground_units, planet_start)
    DebugMessage("%s -- All Done", tostring(Script))
end

function Random_Planet_Select()
    DebugMessage("%s -- Selecting Random Planet", tostring(Script))
    local planets = FindPlanet.Get_All_Planets()
    local totalplanets = table.getn(planets)
    local selectRandom = GameRandom(1, totalplanets) -- Lua starts index at 1 cause why not
    DebugMessage("%s -- Random Selected Index", tostring(selectRandom))
    randomPlanet = planets[selectRandom]
    DebugMessage("%s -- Random Planet", tostring(randomPlanet))
    return randomPlanet
    
end

function Spawn_Space_Units(space_list, planet)
    local x = 0
    for unit, amount in pairs(space_list) do
        DebugMessage("%s -- Unit to Spawn", tostring(unit.Get_Name()))
        DebugMessage("%s -- Amount to spawn", tostring(amount))
        DebugMessage("%s -- Spawning Space Units", tostring(Script))
        if amount == 1 then
            Spawn_Unit(unit, planet, player)
        else
            for x=amount, 0, -1 do
                Spawn_Unit(unit, planet, player)
                DebugMessage("%s -- Amount left", tostring(x))
            end
        end
    end
end

function Spawn_Ground_Units(ground_list, planet)
    for unit, amount in pairs(ground_list) do
        DebugMessage("%s -- Unit to Spawn", tostring(unit.Get_Name()))
        DebugMessage("%s -- Amount to spawn", tostring(amount))
        DebugMessage("%s -- Spawning Ground Units", tostring(Script))
        if amount == 1 then
            Spawn_Unit(unit, planet, player)
        else
            for x=amount, 0, -1 do
                Spawn_Unit(unit, planet, player)
                DebugMessage("%s -- Amount left", tostring(x))
            end
        end
    end
end
