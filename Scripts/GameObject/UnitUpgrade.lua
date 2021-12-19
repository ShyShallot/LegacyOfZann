-- This script handels the upgrade system by despawning the original unit and spawning an upgraded version
-- To add a new upgradable unit just add the Un Upgraded units XML name and the Upgraded XML name to the table
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZPlanetTechTable") 
require("LOZFunctions")
require("LOZUnitUpgrades")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    Define_State("State_Init", State_Init);
    ServiceRate = 1.0 -- Wait some time before looping c
end
 
 
function State_Init(message)
 
    if message == OnEnter then
        if Get_Game_Mode() == "Land" or Get_Game_Mode() == "Space" then
            DebugMessage("%s -- Gamemode is not Galactic, Exiting", tostring(Script))
            ScriptExit()
        end
        DebugMessage("%s -- Getting Upgrade Name to upgrade", tostring(Script))
        Get_Unit_Upgrade()
        Sleep(1)
        DebugMessage("%s -- Despawning Upgrade Object", tostring(Script))
        Object.Despawn()
    end
    ScriptExit()
end

function Get_Unit_Upgrade()
    unit_upgrades = Define_Upgrade_Table()
    player = Object.Get_Owner()
    planet = Object.Get_Planet_Location()
    for upgade, unitTable in pairs() do 
        if(Return_Name(Object) == upgade) then
            unitstoFilter = Find_All_Objects_Of_Type(unitTable[1]);
            for _, unit in pairs() do
                if(unit.Get_Planet_Location() == planet) then
                    Upgrade_Unit(player, planet, unit, unitTable[2]);
                end
            end
        end
    end
end

-- Actual Function to handle upgrading
-- param1: player, used for spawning unit under that player
-- param2: planet, the upgrade's current planet location, used to check if the units we found are on this planet and to spawn units on the correct planet
-- param3: unupgraded_unit, the XML name of the unit that is to be upgraded
-- param4: upgraded_unit, the XML name of the unit to be upgraded to
function Upgrade_Unit(player, planet, unupgraded_unit, upgraded_unit) 
    local unit_type = Find_Object_Type(unupgraded_unit)
    local unupgraded_units = Find_All_Objects_Of_Type(unit_type)
    local upgraded_unit_type = Find_Object_Type(upgraded_unit)
    for k, unit in pairs(unupgraded_units) do 
        if Test_Valid(unit) then
            DebugMessage("%s -- Unit is Valid", tostring(Script))
            if unit.Get_Planet_Location() == planet then
                DebugMessage("%s -- Despawning Unit of Type", tostring(Script))
                unit.Despawn();
                DebugMessage("%s -- Spawning new unit", tostring(Script))
                Spawn_Unit(upgraded_unit_type, planet, player);
                DebugMessage("%s -- All Done", tostring(Script))
            end
        end
    end
end
