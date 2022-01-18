require("LOZFunctions")
require("PGBase")
weekTime = 45 -- this should match <Fiscal_Cycle_Time_In_Secs> Found in the GameConstants.xml
function CurrentWeek()
    week = (GetCurrentTime.Galactic_Time() / weekTime)
    if week < 1 then
        week = 1
    end
    return week 
end

function CurrentWeekRounded()
    local GCTime = (GetCurrentTime.Galactic_Time() / weekTime) + 0.4
    return tonumber(Dirty_Floor(GCTime))
end

function WeekTime() 
    return weekTime
end

function Remove_Mission(tag)
    DebugMessage("%s -- Removing Mission: %s", tostring(Script), tostring(tag))
    local plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_EMPIRE_SCIENCE_LIB.XML") -- Please note that the .XML HAS TO BE CAPITILIZED if not it wont find the file
    event = plot.Get_Event("REMOVE_MISSION")
    event.Set_Reward_Parameter(0, tag)
    Story_Event("REMOVE_MISSION")
    return true
end