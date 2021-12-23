require("PGStateMachine")

function Definitions()
    ServiceRate = 1
    Define_State("State_Init", State_Init)
    idle_anim = "idle"
end

function State_Init(message)
    if(message == OnEnter) then
        if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end
        Object.Play_Animation(idle_anim, true, 0)
        ScriptExit()
    end
end