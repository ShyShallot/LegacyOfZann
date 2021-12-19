--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZPlanetTechTable") 
require("LOZFunctions")
-- Please Note this script is a total fucking mess, it works and i dont want to spend 2 more days re-writing it
-- This script File is the main Function File for the Rebel Slice Mechanic
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    Define_State("State_Init", State_Init);
    ServiceRate = 1.0 -- Wait some time before looping
    Total_Slice_Amount_S = GlobalValue.Get("Total_Slice_Amount")

    DebugMessage("%s -- Defining Plots and Events", tostring(Script))
    plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_REBEL_SLICE.XML") -- Get Plot file for Text Event
    sliced_planet = nil
end

function State_Init(message)
    DebugMessage("%s -- In Inital State, Running Script", tostring(Script))
    if message == OnEnter then -- This is Ran when the script starts
        DebugMessage("%s -- In OnEnter, Defining", tostring(Script))
        GlobalValue.Set("Droid_Dead", 0) -- Droid_Dead value for custom Tech Based Respawn
        player = Object.Get_Owner() -- Get the Droids Owner
        Droid_Team = Object.Get_Parent_Object() -- Find Hero Company of R2D2 for sound and despawn purposes 
        
    end
    if message == OnUpdate then -- This is Ran based off of the Service Rate
        Droid_Team_Fleet = Droid_Team.Get_Parent_Object()
        planet = Object.Get_Planet_Location() -- Get Planet Location, Keep in Update so we can update the Planet Location
        DebugMessage("%s -- In OnUpdate Checking", tostring(Script))
        if planet == nil then -- Check if the planet is nil, used to check if the unit is Hyperspace
            DebugMessage("%s -- No Planet Found, Sleeping", tostring(Script))
            Sleep(5) -- Give Time to Travel to planet      
        end
        DebugMessage("%s -- Running Main Part, Checking Object Runner", tostring(Script))
        DebugMessage("%s -- Object Name", tostring(Return_Name(Object)))
        DebugMessage("%s -- Object Parent Name", tostring(Return_Name(Droid_Team)))
        if Return_Name(Droid_Team) == "DROIDS_TEAM_CUSTOM" and TestValid(planet) then -- A Just In Case to make sure that the Object calling the script is the Droid Team or R2D2
            DebugMessage("%s -- Running Slice", tostring(Script))
            DebugMessage("%s -- Current Planet", tostring(planet))
            planet_diff, planet_avail = Calculate_Planet_Slice_Values(planet)
            Slice_Mechanic(planet, player)
        end
    end

end

function DisplaySliceLeft()
    Total_Slice_Amount_S = GlobalValue.Get("Total_Slice_Amount")
    if Total_Slice_Amount_S == 1 then
        Story_Event("REBEL_SLICE_LEFT_4")
    elseif Total_Slice_Amount_S == 2 then
        Story_Event("REBEL_SLICE_LEFT_3")
    elseif Total_Slice_Amount_S == 3 then
        Story_Event("REBEL_SLICE_LEFT_2")
    elseif Total_Slice_Amount_S == 4 then
        Story_Event("REBELS_SLICE_LEFT_1")
    elseif Total_Slice_Amount_S == 5 then
        Story_Event("REBEL_SLICE_LEFT_HIDE")
    end
end

function Slice_Mechanic(planet, player)
    Droid_Team_Fleet_Count = Droid_Team_Fleet.Get_Contained_Object_Count()
    Total_Slice_Amount_S = GlobalValue.Get("Total_Slice_Amount")
    DebugMessage("%s -- Slice called validating", tostring(Script))
    if Is_Planet_Valid_For_Slice(lastplanet, planet, player) then
        DebugMessage("%s -- Planet Validated", tostring(Script))
        DebugMessage("%s -- Droid Fleet", tostring(Return_Name(Droid_Team_Fleet)))
        if Droid_Team_Fleet_Count == 1  then
            DebugMessage("%s -- Droids are alone", tostring(Script))
            if player.Get_Credits() >= 2000 then
                DebugMessage("%s -- Player has enough credits", tostring(Script))
                IS_ISD_LOCKED = GlobalValue.Get("IS_REBEL_ISD_LOCKED")
                DebugMessage("%s -- Determining if Slice Failed or Not", tostring(Script)) 
                Droid_Team.Play_SFX_Event("Unit_Move_C3PO") -- Play Sound Effect on Slicing Start
                sliceTechTime = Calculate_Sleep_Time(planet_diff, planet_avail)
                DebugMessage("Current Time to Sleep: %s", tostring(sliceTechTime))
                Game_Message("Tech Slicing In Progress, Please Wait " .. sliceTechTime .. " Seconds") -- Show Text telling the player to wait
                Sleep(sliceTechTime) -- Pause the Script based off of our Tech Level for Slicing 
                if not Calculate_Slice_Chances(planet_diff, planet_avail) then -- Total_Slice_Chance is from our Tech and Diff Values, check if its less than our Success Chance
                    sliced_planet = Object.Get_Planet_Location()
                    Droid_Team.Play_SFX_Event("Unit_Defeat_C3PO")
                    Sleep(3) -- Give time for Audio to Finish
                    DebugMessage("%s -- Slice Failed, Despawning Droids", tostring(Script))
                    GlobalValue.Set("Droid_Dead", 1) -- Set Droid_Dead to 1 for Respawn Script
                    Droid_Team.Despawn() -- Despawn R2D2 and C3PO 
                    Object.Despawn() -- Despawn R2D2 just in case
                else
                    sliced_planet = Object.Get_Planet_Location()
                    Unlock_Rebel_Star_Destroyer(planet, player)
                    DebugMessage("%s -- Slice Sucseesful, Despawning Droids", tostring(Script))
                    GlobalValue.Set("Total_Slice_Amount", Total_Slice_Amount_S + 1)
                    DisplaySliceLeft()
                    credits_take = GameRandom(-1000, -650) -- Remove a random amount of credits to compensate for a lack of player control
                    player.Give_Money(credits_take) -- It says Give Money but we are adding a Negtive Value so its just subtracting
                    Droid_Team.Play_SFX_Event("Unit_Hack_Turret_C3PO")
                    Sleep(3) -- Give time for Audio to Finish
                    Game_Message("LOZ_REBEL_SLICE_WIN") -- Tell the player the slice succeeded and to Despawn
                    GlobalValue.Set("Droid_Dead", 1) -- Set Droid_Dead to 1 for Respawn Script
                    Droid_Team.Despawn() -- Despawn R2D2 and C3PO 
                    lastplanet = Object.Get_Planet_Location()
                    Object.Despawn() -- Despawn R2D2 just in case
                end
            elseif player.Get_Credits() <= 2000 then  -- Check if player has less than 2k Credits
                Game_Message("LOZ_REBEL_SLICE_NCREDITS")
                Sleep(1)
                GlobalValue.Set("Droid_Dead", 2)
                Droid_Team.Despawn() -- Despawn R2D2 and C3PO 
                Object.Despawn() -- Despawn R2D2 just in case
            end
            Slices_Left_Till_Tech(player)
        end
    elseif Return_Faction(planet) == "PIRATES" then
        Game_Message("LOZ_REBEL_SLICE_UNAVAIL")
        Droid_Team.Play_SFX_Event("GUI_Bad_Sound")
        Sleep(1)
        GlobalValue.Set("Droid_Dead", 2)
        Droid_Team.Despawn() -- Despawn R2D2 and C3PO 
        Object.Despawn() -- Despawn R2D2 just in case
    end
end

function Is_Planet_Valid_For_Slice(lastplanet, planet, player)
    planetOwner = Return_Faction(planet)
    if planetOwner ~= "REBEL" then -- Make sure we dont own the planet and check if the planet was recently sliced from
        DebugMessage("%s -- Planet not owned by rebels", tostring(Script))
        if planetOwner ~= "PIRATES" then -- Prevent Slicing from Pirate Planets
            DebugMessage("%s -- Planet Not Owned by Pirates", tostring(Script))
            if TestValid(lastplanet) then
                DebugMessage("%s -- Last Planet Found", tostring(Script))
                if Return_Name(lastplanet) ~= Return_Name(planet) then
                    DebugMessage("%s -- Last Planet is not the same as the current one", tostring(Script))
                    return true
                else
                    DebugMessage("%s -- Last Planet is the same, returning", tostring(Script))
                    return false
                end
            else
                DebugMessage("%s -- Last planet not found returning true", tostring(Script))
                return true
            end
        elseif planetOwner == "PIRATES" then
            DebugMessage("%s -- Planet is equal to pirate, respawning", tostring(Script))
            return false
        end
    end
end

function Unlock_Rebel_Star_Destroyer(planet, player)
    planetOwner = Return_Faction(planet)
    if planetOwner == "EMPIRE" then -- Make sure Planet is owned by Empire
        DebugMessage("%s -- Starting ISD Unlock", tostring(Script)) 
        kuat = FindPlanet("Kuat") -- Find the planet Kuat
        DebugMessage("%s -- Found Kuat Planet", tostring(Script)) 
        DebugMessage("%s -- Getting Unlock Chances", tostring(Script)) 
        if planet == kuat then -- If Planet is owned by the Empire and the planet is Kuat
            DebugMessage("%s -- found planet Kuat successfully", tostring(Script)) 
            if player.Get_Tech_Level() >= 3 then -- If player is above Tech 3 as an ISD on tech below is broken
                DebugMessage("%s -- Is Tech 3", tostring(Script)) 
                if IS_ISD_LOCKED == 0 then -- Make sure player has never unlocked the Rebel ISD
                    DebugMessage("%s -- ISD is Locked", tostring(Script)) 
                    if Return_Chance(GameRandom(0.2, 0.6)) then
                        DebugMessage("%s -- Unlock Chance Successfull", tostring(Script)) 
                        Story_Event("REBEL_SLICE_ISD_UNLOCK")
                        Game_Message("LOZ_REBEL_SLICE_ISD_UNLOCK")
                        GlobalValue.Set("IS_REBEL_ISD_LOCKED", 1) -- Let game know the player Unlocked the Rebel ISD
                    end
                end
            end
        end
    end
end

function Slices_Left_Till_Tech(player)
    player_credits = player.Get_Credits()
    tech_Level = player.Get_Tech_Level()
    slices_Required = 5
    DebugMessage("%s -- Checking Slice Amount", tostring(Script))
    DebugMessage("%s -- Slice Amount", tostring(Total_Slice_Amount_S))
    if Total_Slice_Amount_S == slices_Required then -- Player Has to slice this many times to tech-up
        DebugMessage("%s -- Slice Amount", tostring(Total_Slice_Amount_S))
        DebugMessage("%s -- Slice Amount meet", tostring(Script))
        if tech_Level == 0 then
            DebugMessage("%s -- Player on Tech 1", tostring(Script))
            Unlock_Tech_Upgrade(player)
            if Total_Slice_Amount_S >= slices_Required then
                Total_Slice_Amount_S = GlobalValue.Set("Total_Slice_Amount", 0)
            end
        end
        if tech_Level == 1 then
            DebugMessage("%s -- Player on Tech 2", tostring(Script))
            Unlock_Tech_Upgrade(player)
            if Total_Slice_Amount_S >= slices_Required then
                Total_Slice_Amount_S = GlobalValue.Set("Total_Slice_Amount", 0)
            end
        end
        if tech_Level == 2 then
            DebugMessage("%s -- Player on Tech 3", tostring(Script))
            Unlock_Tech_Upgrade(player)
            if Total_Slice_Amount_S >= slices_Required then
                Total_Slice_Amount_S = GlobalValue.Set("Total_Slice_Amount", 0)
            end
        end
        if tech_Level == 3 then
            DebugMessage("%s -- Player on Tech 4", tostring(Script))
            Unlock_Tech_Upgrade(player)
            if Total_Slice_Amount_S >= slices_Required then
                Total_Slice_Amount_S = GlobalValue.Set("Total_Slice_Amount", 0)
            end
        end
    end
end

function Unlock_Tech_Upgrade(player)
    DebugMessage("%s -- Unlocking Tech Upgrade", tostring(Script))
    tech_level = player.Get_Tech_Level()
    if tech_level == 0 then
        DebugMessage("%s -- Player is on Tech 1", tostring(Script))
        Story_Event("UNLOCK_TECH_UPGRADE_1")
    elseif tech_level == 1 then
        DebugMessage("%s -- Player is on Tech 2", tostring(Script))
        Story_Event("UNLOCK_TECH_UPGRADE_2")
    elseif tech_level == 2 then
        DebugMessage("%s -- Player is on Tech 3", tostring(Script))
        Story_Event("UNLOCK_TECH_UPGRADE_3")
    elseif tech_level == 3 then
        DebugMessage("%s -- Player is on Tech 4", tostring(Script))
        Story_Event("UNLOCK_TECH_UPGRADE_4")
    end
end



