--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZFunctions")
-- Please Note this script is a total fucking mess, it works and i dont want to spend 2 more days re-writing it
-- This script File is the main Function File for the Rebel Slice Mechanic

--function Planet_List()
--    local planets = FindPlanet.Get_All_Planets()
--    for k, v in pairs(planets) do
--        DebugMessage("%s -- Planet List Key", tostring(k))
--        DebugMessage("%s -- Planet List Value", tostring(v))
--    end
--end

function Despawn_Starting_Structure(player)
    local playerFac = player.Get_Faction_Name()
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

empire_structures = {"E_GROUND_BARRACKS","E_GROUND_LIGHT_VEHICLE_FACTORY","EMPIRE_GROUND_MINING_FACILITY"}
empire_starbase = "Empire_Star_Base_5"
empire_units = {
    ["STAR_DESTROYER"] = 1, 
    ["ACCLAMATOR_ASSAULT_SHIP"] = 2, 
    ["TIE_BOMBER_SQUADRON"] = 2, 
    ["TIE_FIGHTER_SQUADRON"] = 4,
    ["IMPERIAL_STORMTROOPER_SQUAD"] = 2,
    ["IMPERIAL_HEAVY_SCOUT_SQUAD"] = 2
}
rebel_structures = {"R_GROUND_BARRACKS","R_GROUND_LIGHT_VEHICLE_FACTORY","REBEL_GROUND_MINING_FACILITY"}
rebel_starbase = "Rebel_Star_Base_5"
rebel_units = {
    ["CALAMARI_CRUISER"] = 1,
    ["NEBULON_B_FRIGATE"] = 2,
    ["Y-WING_SQUADRON"] = 2,
    ["REBEL_X-WING_SQUADRON"] = 3,
    ["REBEL_INFANTRY_SQUAD"] = 3,
    ["REBEL_LIGHT_TANK_BRIGADE"] = 2
}

function Spawn_Random_Units()
    DebugMessage("%s -- Function called spawning starting units", tostring(Script))
    --Planet_List() This is only used for Debugging, do not renable unless needed
    empire = Find_Player("EMPIRE")
    rebel = Find_Player("REBEL")
    Spawn_Faction_Starting(empire, empire_structures, empire_starbase, empire_units)
    Sleep(1)
    Spawn_Faction_Starting(rebel, rebel_structures, rebel_starbase, rebel_units)
    Sleep(2)
    Spawn_Player_Pirates() -- Always spawn pirates last, as they fill in the gaps
    DebugMessage("%s -- All Done", tostring(Script))
end

function Spawn_Player_Pirates()
    local player = Find_Player("PIRATES")
    local Hplayer = Find_Human_Player()
    Despawn_Starting_Structure(player)
    DebugMessage("%s -- Despawning pirate structure", tostring(Script))
    Sleep(1)
    
    pirate_start_table = {
        {
            [Find_Object_Type("PIRATE_ASTEROID_BASE")] = 1,
            [Find_Object_Type("PIRATE_FRIGATE")] = 1,
            [Find_Object_Type("PIRATE_CORONA_FRIGATE")] = 2,
            [Find_Object_Type("Z95_HEADHUNTER_SQUADRON")] = 2,
        },
        {
            [Find_Object_Type("PIRATE_COMMAND_CENTER")] = 1,
            [Find_Object_Type("PIRATE_SKIFF_TEAM")] = 2,
            [Find_Object_Type("PIRATE_SOLDIER_SQUAD")] = 3,
        }
    }
    space_units = pirate_start_table[1]
    ground_units = pirate_start_table[2]
    local planets = FindPlanet.Get_All_Planets()
    local planetcount = table.getn(planets)
    local piratecontrol = Pirate_Control_Threshold(Hplayer)
    local finalplanetfill = planetcount * piratecontrol
    DebugMessage("%s -- Total Planets to fill", tostring(finalplanetfill))
    local planets_left = finalplanetfill
    Sleep(1)
    for k, planet in pairs(planets) do
        if TestValid(planet) and Return_Faction(planet) == "NEUTRAL" and planets_left >= 1 then
            DebugMessage("%s -- Planet Valid for spawning", tostring(Script))
            if Return_Faction(planet) == "NEUTRAL" and (Return_Faction(planet) ~= "REBEL" or Return_Faction(planet) ~= "EMPIRE") then   
                DebugMessage("%s -- Planet Valid for spawn", tostring(Script))
                planet.Change_Owner(player)
                Spawn_Space_Units(space_units, planet, player)
                Spawn_Ground_Units(ground_units, planet, player)
                planets_left = planets_left - 1
                DebugMessage("%s -- Planets left to take over", tostring(planets_left))
            else
                return
            end
        end
    end
    DebugMessage("%s -- All Done spawning Pirates", tostring(Script))
end

function Spawn_Faction_Starting(faction, structures, starbase, units)
    Despawn_Starting_Structure(faction)
    DebugMessage("%s -- Despawning %s Structure", tostring(Script), tostring(faction.Get_Faction_Name()))
    Sleep(1)
    planet_start = Random_Planet_Select()
    if TestValid(planet_start) then
        if Return_Faction(planet_start) == "NEUTRAL" then   
            DebugMessage("%s -- Planet Valid for spawn", tostring(Script))
            planet_start.Change_Owner(faction)
        end
    else
        return
    end
    Sleep(1)
    Spawn_Unit(starbase, planet_start, faction)
    Spawn_Unit_List(structures, planet_start, faction)
    Spawn_Unit_List(units, planet_start, faction)
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

function Spawn_Unit_List(unit_list, planet, player)
    local x = 0
    for unit, amount in pairs(unit_list) do
        unitO = Find_Object_Type(unit)
        DebugMessage("%s -- Unit to Spawn", tostring(unit.Get_Name()))
        DebugMessage("%s -- Amount to spawn", tostring(amount))
        DebugMessage("%s -- Spawning Space Units", tostring(Script))
        if amount == 1 then
            Spawn_Unit(unitO, planet, player)
        else
            for x=amount, 0, -1 do
                Spawn_Unit(unitO, planet, player)
                DebugMessage("%s -- Amount left", tostring(x))
            end
        end
    end
end

function Pirate_Control_Threshold(player)
    
    if player.Get_Difficulty() == "Easy" then
        pirate_control_threshold = 0.4 -- Pirates control x% of the Map on start
        DebugMessage("%s -- Difficulty is Easy, Pirate Control Treshold", tostring(pirate_control_threshold))
    elseif player.Get_Difficulty() == "Hard" then
        pirate_control_threshold = 0.75
        DebugMessage("%s -- Difficulty is Hard, Pirate Control Treshold", tostring(pirate_control_threshold))
    else
        pirate_control_threshold = 0.55
        DebugMessage("%s -- Difficulty is Normal, Pirate Control Treshold", tostring(pirate_control_threshold))
    end
    if pirate_control_threshold ~= nil then
        DebugMessage("%s -- Final Pirate Control Treshold", tostring(pirate_control_threshold))
        return pirate_control_threshold
    end
end

function Find_Human_Player()
    empire = Find_Player("EMPIRE")
    rebels = Find_Player("REBEL")

    if empire.Is_Human() and (not rebels.Is_Human()) then
        DebugMessage("%s -- Human player is Empire", tostring(Script))
        return empire
    elseif rebels.Is_Human() and (not empire.Is_Human()) then
        DebugMessage("%s -- Human player is Rebel", tostring(Script))
        return rebels
    end
end
