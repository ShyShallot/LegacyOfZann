require("PGStoryMode")
require("PGStateMachine")
require("Random_Planet_Starter_No_Underworld")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    StoryModeEvents =
    {
        Universal_Story_Start = Global_Story
    }

end

-- Yes this code is similar to AOTR, i used it as a base for the most part and how things are done are based off of aotr, 
--i thank them for the original idea

function Story_Mode_Service()

end

function Global_Story(message)
    if  message == OnEnter then 
        DebugMessage("%s -- We Started Calling Func", tostring(Script))
        Spawn_Random_Units()
        while (isSpawningDone() ~= true) do
            Sleep(1)
        end
        Story_Event("Spawning_Done")
        DebugMessage("%s -- All Done", tostring(Script))
    end
end