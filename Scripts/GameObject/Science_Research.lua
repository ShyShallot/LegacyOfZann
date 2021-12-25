--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZFunctions")
-- This is just a simple script to increase the Science_Level by 1 and then despawn the "unit" so that the player cant use it
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    Define_State("State_Init", State_Init);
    ServiceRate = 1.0 -- Wait some time before looping
    DebugMessage("%s -- Defining Plots and Events", tostring(Script))
end

function State_Init(message)
    DebugMessage("%s -- In Inital State, Running Script", tostring(Script))
    if message == OnEnter then -- This is Ran when the script starts
        DebugMessage("%s -- In OnEnter, Defining", tostring(Script))
        level = GlobalValue.Get("Science_Level")
        new_level = level + 1
        GlobalValue.Set("Science_Level", new_level)
        GlobalValue.Set("Science_Increased", 1)
        Sleep(1)
        Object.Despawn()
    end
end