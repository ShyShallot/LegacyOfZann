require("LOZFunctions")
require("PGBase")
function CurrentWeek()
    week = (GetCurrentTime.Galactic_Time() / 60)
    if week < 1 then
        week = 1
    end
    return week 
end

function CurrentWeekRounded()
    local GCTime = GetCurrentTime.Galactic_Time() / 60
    return Dirty_Floor(GCTime)
end
