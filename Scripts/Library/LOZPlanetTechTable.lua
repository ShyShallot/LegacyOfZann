
-- This is the Planet Table for Legacy of Zann, This Table is used for Setting and Getting the Tech Availablity and Difficulty of a Planet.
-- Made by ShyShallot for Legacy of Zann
require("LOZFunctions")
function Define_Planet_Table()
        planets_tech_diff_table = {
            ["ABREGADO_RAE"] = 2,
            ["AETENII"] = 3,
            ["ALDERAAN"] = 2,
            ["ALZOCIII"] = 1,
            ["ANAXES"] = 5,
            ["ATZERRI"] = 3,
            ["BESPIN"] = 3,
            ["BESTINE"] = 4,
            ["BONADAN"] = 4,
            ["BOTHAWUI"] = 5,
            ["BYSS"] = 1,
            ["CARIDA"] = 4,
            ["CORELLIA"] = 3,
            ["CORULAG"] = 3,
            ["CORUSCANT"] = 5,
            ["DATHOMIR"] = 4,
            ["DAGOBAH"] = 1,
            ["DANTOOINE"] = 2,
            ["ENDOR"] = 0,
            ["ERIADU"] = 3,
            ["FELUCIA"] = 1,
            ["FONDOR"] = 3,
            ["FRESIA"] = 2,
            ["GEONOSIS"] = 2,
            ["HONOGHR"] = 1,
            ["HOTH"] = 2,
            ["HYPORI"] = 1,
            ["ILUM"] = 0,
            ["JABIIM"] = 1,
            ["KAMINO"] = 5,
            ["KASHYYYK"] = 1,
            ["KESSEL"] = 3,
            ["KORRIBAN"] = 2,
            ["KUAT"] = 5,
            ["MANAAN"] = 3,
            ["MANDALORE"] = 5,
            ["MONCALIMARI"] = 3,
            ["MUSTAFAR"] = 2,
            ["MUUNILINST"] = 5,
            ["MYRKR"] = 1,
            ["NABOO"] = 2,
            ["NALHUTTA"] = 5,
            ["POLUS"] = 5,
            ["RYLOTH"] = 3,
            ["SALEUCAMI"] = 2,
            ["SHOLA"] = 0,
            ["SULLUST"] = 4,
            ["TARIS"] = 2,
            ["TATOOINE"] = 1,
            ["THE_MAW"] = 5,
            ["THYFERRA"] = 3,
            ["UTAPAU"] = 2,
            ["VERGESSOASTEROIDS"] = 4,
            ["WAYLAND"] = 5,
            ["YAVIN"] = 2
        }

        planets_tech_avail_table = {
            ["ABREGADO_RAE"] = 3,
            ["AETENII"] = 0,
            ["ALDERAAN"] = 2,
            ["ALZOCIII"] = 1,
            ["ANAXES"] = 4,
            ["ATZERRI"] = 4,
            ["BESPIN"] = 2,
            ["BESTINE"] = 4,
            ["BONADAN"] = 5,
            ["BOTHAWUI"] = 4,
            ["BYSS"] = 2,
            ["CARIDA"] = 3,
            ["CORELLIA"] = 4,
            ["CORULAG"] = 4,
            ["CORUSCANT"] = 5,
            ["DATHOMIR"] = 2,
            ["DAGOBAH"] = 0,
            ["DANTOOINE"] = 1,
            ["ENDOR"] = 0,
            ["ERIADU"] = 4,
            ["FELUCIA"] = 2,
            ["FONDOR"] = 4,
            ["FRESIA"] = 4,
            ["GEONOSIS"] = 2,
            ["HONOGHR"] = 2,
            ["HOTH"] = 1,
            ["HYPORI"] = 1,
            ["ILUM"] = 0,
            ["JABIIM"] = 2,
            ["KAMINO"] = 3,
            ["KASHYYYK"] = 2,
            ["KESSEL"] = 2,
            ["KORRIBAN"] = 1,
            ["KUAT"] = 5,
            ["MANAAN"] = 2,
            ["MANDALORE"] = 5,
            ["MONCALIMARI"] = 4,
            ["MUSTAFAR"] = 2,
            ["MUUNILINST"] = 5,
            ["MYRKR"] = 1,
            ["NABOO"] = 4,
            ["NALHUTTA"] = 5,
            ["POLUS"] = 0,
            ["RYLOTH"] = 4,
            ["SALEUCAMI"] = 2,
            ["SHOLA"] = 0,
            ["SULLUST"] = 5,
            ["TARIS"] = 4,
            ["TATOOINE"] = 2,
            ["THE_MAW"] = 5,
            ["THYFERRA"] = 3,
            ["UTAPAU"] = 3,
            ["VERGESSOASTEROIDS"] = 1,
            ["WAYLAND"] = 0,
            ["YAVIN"] = 0
        }
        return planets_tech_diff_table, planets_tech_avail_table

end

function Calculate_Planet_Slice_Values(planetC)
    tech_diff, tech_avail = Define_Planet_Table()
    for planet, diff in pairs(tech_diff) do
        if planetC.Get_Type().Get_Name() == planet then
            planet_diff = diff
        end
    end
    for planet, avail in pairs(tech_avail) do
        if planetC.Get_Type().Get_Name() == planet then
            planet_avail = avail
        end
    end
    if planet_diff ~= nil and planet_avail ~= nil then
        return planet_diff, planet_avail
    end
end

function Calculate_Slice_Chances(diff, avail)
    if diff == 0 then
        diff_chance = 1.0
    elseif diff == 1 then
        diff_chance = 0.8
    elseif diff == 2 then
        diff_chance = 0.6
    elseif diff == 3 then
        diff_chance = 0.5
    elseif diff == 4 then
        diff_chance = 0.35
    elseif diff == 5 then
        diff_chance = 0.2
    end

    if avail == 0 then
        avail_chance = 0.1
    elseif avail == 1 then
        avail_chance = 0.25
    elseif avail == 2 then
        avail_chance = 0.4
    elseif avail == 3 then
        avail_chance = 0.5
    elseif avail == 4 then
        avail_chance = 0.8
    elseif avail == 5 then
        avail_chance = 1.0
    end
    
    final_slice_chance  = diff_chance * avail_chance
    if Return_Chance(final_slice_chance) == true then
        return true
    end
end

function Calculate_Sleep_Time(diff, avail)
    if diff == 0 then
        sleepTime = 20
    elseif diff == 1 then
        sleepTime = 30
    elseif diff == 2 then
        sleepTime = 35
    elseif diff == 3 then
        sleepTime = 40
    elseif diff == 4 then
        sleepTime = 50
    elseif diff == 5 then
        sleepTime = 60
    end

    if avail == 0 then
        mutliplier = 2.0
    elseif avail == 1 then
        mutliplier = 1.5
    elseif avail == 2 then
        mutliplier = 1.25
    elseif avail == 3 then
        mutliplier = 1
    elseif avail == 4 then
        mutliplier = 0.8
    elseif avail == 5 then
        mutliplier = 0.65
    end
    
    final_sleep_time = sleepTime * mutliplier
    return final_sleep_time
end
