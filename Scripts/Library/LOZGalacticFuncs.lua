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