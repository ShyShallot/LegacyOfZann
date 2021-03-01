
-- This is the Planet Table for Legacy of Zann, This Table is used for Setting and Getting the Tech Availablity and Difficulty of a Planet.
-- Made by ShyShallot for Legacy of Zann
function Base_Definitions()
	-- DebugMessage("%s -- In Base_Definitions", tostring(Script))
    planet_tech_table = {
        planets = {
            "Abregado_Rae",
            "AetenII",
            "Alderaan",
            "AlzocIII",
            "Anaxes",
            "Atzerri",
            "Bespin",
            "Bestine"
            "Bonadan",
            "Bothawui",
            "Byss",
            "Carida",
            "Corellia",
            "Corulag",
            "Coruscant",
            "Dathomir",
            "Dagobah",
            "Dantooine",
            "Endor",
            "Eriadu",
            "Felucia",
            "Fondor",
            "Fresia",
            "Geonosis",
            "Honoghr",
            "Hoth",
            "Hypori",
            "Ilum",
            "Jabiim",
            "Kamino",
            "Kashyyyk",
            "Kessel",
            "Korriban",
            "Kuat",
            "Manaan",
            "Mandalore",
            "MonCalimari",
            "Mustafar",
            "Muunilinst",
            "Myrkr",
            "Naboo",
            "NalHutta",
            "Polus",
            "Ryloth",
            "Saleucami",
            "Shola",
            "Sullust",
            "Taris",
            "Tatooine",
            "The_Maw",
            "Thyferra",
            "Utapau",
            "VergessoAsteroids",
            "Wayland",
            "Yavin"
        };
    }

end
function table_contains(table, val)
    for i=1,#table do
       if table[i] == val then 
          return true
       end
    end
    return false
end
