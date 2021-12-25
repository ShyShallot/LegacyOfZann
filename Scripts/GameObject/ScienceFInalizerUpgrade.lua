--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZFunctions")
-- Im not entirley sure if this script gets ran cause its on the Tech Upgrade
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    Define_State("State_Init", State_Init);
    ServiceRate = 1.0 -- Wait some time before looping
    DebugMessage("%s -- Defining Plots and Events", tostring(Script))
end

function State_Init(message)
    DebugMessage("%s -- In Inital State, Running Script", tostring(Script))
    if message == OnEnter then -- This is Ran when the script starts
        GlobalValue.Set("Tech_Upgrade_Done", 1)
        ScriptExit()
    end
end