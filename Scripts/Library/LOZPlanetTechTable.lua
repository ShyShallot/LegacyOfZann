
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
    if tech_diff[planetC.Get_Type().Get_Name()] ~= nil then
        planet_diff = tech_diff[planetC.Get_Type().Get_Name()]
    end
    if tech_avail[planetC.Get_Type().Get_Name()] ~= nil then
        planet_avail = tech_avail[planetC.Get_Type().Get_Name()]
    end
    if planet_diff ~= nil and planet_avail ~= nil then
        return planet_diff, planet_avail
    end
end

function Calculate_Slice_Chances(diff, avail, flags)

    diff_chance = {1.0, 0.8, 0.6, 0.5, 0.35, 0.2}

    avail_chance = {0.2, 0.35, 0.5, 0.65, 0.8, 1.0}
    
    addtional_modifier = 1

    if flags.IS_PIRATE then
        addtional_modifier = addtional_modifier - 0.05
    end

    final_slice_chance  = (diff_chance[diff+1] * avail_chance[avail+1]) * addtional_modifier
    if Return_Chance(final_slice_chance) then
        return true
    end
    return false
end

function Calculate_Sleep_Time(diff, avail, flags)

    diff_sleep_time = { 20, 30, 35, 40, 50, 60}

    avil_multiplier = {2.0 ,1.5 ,1.25 ,1 ,0.8 ,0.65}

    addtional_modifier = 0

    if flags.IS_PIRATE then
        addtional_modifier = addtional_modifier + 25
    end
    
    final_sleep_time = (diff_sleep_time[diff+1] * avil_multiplier[avail+1]) + addtional_modifier;

    return final_sleep_time
end
