--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
--require("LOZPlanetTechTable.lua") a Unfinished script for a future function

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    Define_State("State_Init", State_Init);
    ServiceRate = 1.0 -- Wait some time before looping
    Total_Slice_Amount_S = GlobalValue.Get("Total_Slice_Amount")

    DebugMessage("%s -- Defining Plots and Events", tostring(Script))
    plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_REBEL_SLICE.XML") -- Get Plot file for Text Event

    

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
        
        planet = Object.Get_Planet_Location() -- Get Planet Location, Keep in Update so we can update the Planet Location
        Droid_Team_Fleet = Droid_Team.Get_Parent_Object()
        Droid_Team_Fleet_Count = Droid_Team_Fleet.Get_Contained_Object_Count()
        DebugMessage("%s -- In OnUpdate Checking", tostring(Script))
        if planet == nil then -- Check if the planet is nil, used to check if the unit is Hyperspace
            DebugMessage("%s -- No Planet Found, Sleeping", tostring(Script))
            Sleep(5) -- Give Time to Travel to planet
        else
            planetOwner = planet.Get_Owner().Get_Faction_Name() -- Use Faction name as this doesnt error the script when checking for planet owner
        end

        --if contains(planet_tech_table, planet) then , UNUSED If statement that uses the Planet Table, which doesnt work.
            
        --end

        DebugMessage("%s -- Setting Chance Per Tech", tostring(Script))
        if player.Get_Tech_Level() == 1 then -- Get Slice Chance based of the Players Current Tech Level after Adjustment(?)
            sliceChanceTech = GameRandom(1.0, 0.75)
            sliceTechTime = GameRandom(5, 15)
        elseif player.Get_Tech_Level() == 2 then
            sliceChanceTech = GameRandom(0.75, 0.50)
            sliceTechTime = GameRandom(15, 25)
        elseif player.Get_Tech_Level() == 3 then
            sliceChanceTech = GameRandom(0.50, 0.45)
            sliceTechTime = GameRandom(25, 35)
        elseif player.Get_Tech_Level() == 4 then
            sliceChanceTech = GameRandom(0.45, 0.35)
            sliceTechTime = GameRandom(35, 45)
        end

       DebugMessage("%s -- Setting Chance Per Difficulty", tostring(Script))
        if player.Get_Difficulty() == "Easy" then -- Get Slice Chance off of Difficulty as a second param
            sliceChanceDiff = 1.5
            successchance = GameRandom(0.5, 0.5) -- Compare success chance, do not delete
        elseif player.Get_Difficulty() == "Normal" then
            sliceChanceDiff = 1.0
            successchance = GameRandom(0.3, 0.45) -- Compare success chance, do not delete
        elseif player.Get_Difficulty() == "Hard" then
            sliceChanceDiff = 0.5 
            successchance = GameRandom(0.25, 0.35) -- Compare success chance, do not delete
        end
    

        DebugMessage("%s -- Running Main Part, Checking Object Runner", tostring(Script))
        if Object == Object.Get_Parent_Object() or Object.Get_Type("Droid_R2D2") then -- A Just In Case to make sure that the Object calling the script is the Droid Team or R2D2
           DebugMessage("%s -- Getting Total Slice Chance", tostring(Script)) 
            total_slice_chance = sliceChanceDiff * sliceChanceTech -- Caculate our Total Chance from our Tech and Diff values
            
           DebugMessage("%s -- Checking if we own the planet", tostring(Script)) 
           DebugMessage("%s -- Planet Owner", tostring(planetOwner))

            if planetOwner ~= "REBEL" then -- Make sure we dont own the planet and check if the planet was recently sliced from

                if planetOwner ~= "PIRATES" then -- Prevent Slicing from Pirate Planets
                    if Droid_Team_Fleet_Count == 1  then
                        if player.Get_Credits() >= 2000 then
                            IS_ISD_LOCKED = GlobalValue.Get("IS_REBEL_ISD_LOCKED")
                        
                            DebugMessage("%s -- Determining if Slice Failed or Not", tostring(Script)) 
                            Droid_Team.Play_SFX_Event("Unit_Move_C3PO") -- Play Sound Effect on Slicing Start

                            Game_Message("LOZ_REBEL_SLICE_PROG") -- Show Text telling the player to wait

                            Sleep(sliceTechTime) -- Pause the Script based off of our Tech Level for Slicing 

                            if total_slice_chance <= successchance then -- Total_Slice_Chance is from our Tech and Diff Values, check if its less than our Success Chance
                                    Droid_Team.Play_SFX_Event("Unit_Defeat_C3PO")
                                    Sleep(3) -- Give time for Audio to Finish
                                    Game_Message("LOZ_REBEL_SLICE_FAIL") -- Run the Story Event telling the player that it failed and to Despawn
                                    DebugMessage("%s -- Slice Failed, Despawning Droids", tostring(Script))
                                    GlobalValue.Set("Droid_Dead", 1) -- Set Droid_Dead to 1 for Respawn Script
                                    Droid_Team.Despawn() -- Despawn R2D2 and C3PO 
                                    Object.Despawn() -- Despawn R2D2 just in case
                            elseif total_slice_chance >= successchance then
                                    if planetOwner == "EMPIRE" then -- Make sure Planet is owned by Empire
                                        DebugMessage("%s -- Starting ISD Unlock", tostring(Script)) 
                                        kuat = FindPlanet("Kuat") -- Find the planet Kuat
                                        DebugMessage("%s -- Found Kuat Planet", tostring(Script)) 
                                        isdUnlockChance = GameRandom(0.2, 0.3) -- First Chance
                                        successchanceISD = GameRandom(0.25, 0.29) -- Second Chance
                                        DebugMessage("%s -- Getting Unlock Chances", tostring(Script)) 
                                        if planet == kuat then -- If Planet is owned by the Empire and the planet is Kuat
                                            DebugMessage("%s -- found planet Kuat successfully", tostring(Script)) 
                                            if player.Get_Tech_Level() >= 3 then -- If player is above Tech 3 as an ISD on tech below is broken
                                                DebugMessage("%s -- Is Tech 3", tostring(Script)) 
                                                if IS_ISD_LOCKED == 0 then -- Make sure player has never unlocked the Rebel ISD
                                                    DebugMessage("%s -- ISD is Locked", tostring(Script)) 
                                                    if isdUnlockChance >= successchanceISD then
                                                        DebugMessage("%s -- Unlock Chance Successfull", tostring(Script)) 
                                                        Story_Event("REBEL_SLICE_ISD_UNLOCK")
                                                        Game_Message("LOZ_REBEL_SLICE_ISD_UNLOCK")
                                                        GlobalValue.Set("IS_REBEL_ISD_LOCKED", 1) -- Let game know the player Unlocked the Rebel ISD
                                                    end
                                                end
                                            end
                                        end
                                    end -- Run Rest of successful slice stuff
                                    DebugMessage("%s -- Slice Sucseesful, Despawning Droids", tostring(Script))
                                    credits_take = GameRandom(-1000, -650) -- Remove a random amount of credits to compensate for a lack of player control
                                    player.Give_Money(credits_take) -- It says Give Money but we are adding a Negtive Value so its just subtracting
                                    Droid_Team.Play_SFX_Event("Unit_Hack_Turret_C3PO")
                                    Sleep(3) -- Give time for Audio to Finish
                                    Game_Message("LOZ_REBEL_SLICE_WIN") -- Tell the player the slice succeeded and to Despawn
                                    GlobalValue.Set("Droid_Dead", 1) -- Set Droid_Dead to 1 for Respawn Script
                                    Droid_Team.Despawn() -- Despawn R2D2 and C3PO 
                                    Object.Despawn() -- Despawn R2D2 just in case
                                    GlobalValue.Set("Total_Slice_Amount", Total_Slice_Amount_S + 1)
                                    DisplaySliceLeft()
                            end
                        elseif player.Get_Credits() <= 2000 then  -- Check if player has less than 2k Credits
                            Game_Message("LOZ_REBEL_SLICE_NCREDITS")
                            Sleep(1)
                            GlobalValue.Set("Droid_Dead", 2)
                            Droid_Team.Despawn() -- Despawn R2D2 and C3PO 
                            Object.Despawn() -- Despawn R2D2 just in case
                        end

                    end
                elseif planetOwner == "PIRATES" then
                    Game_Message("LOZ_REBEL_SLICE_UNAVAIL")
                    Droid_Team.Play_SFX_Event("GUI_Bad_Sound")
                    Sleep(1)
                    GlobalValue.Set("Droid_Dead", 2)
                    Droid_Team.Despawn() -- Despawn R2D2 and C3PO 
                    Object.Despawn() -- Despawn R2D2 just in case
                end
               DebugMessage("%s -- Exiting Slice Functions", tostring(Script))

               
            end
            DebugMessage("%s -- Exiting Slice Chances", tostring(Script))
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
                    Story_Event("REBEL_SLICE_CREDIT_WARNING_1")
                    if player_credits >= 8000 then
                        DebugMessage("%s -- Player has specified amount of credits", tostring(Script))
                        player.Give_Money(-4500)
                        player.Set_Tech_Level(1)
                        Sleep(5)
                        Story_Event("REBEL_SLICE_CREDIT_WARNING_REMOVE")
                        if Total_Slice_Amount_S >= slices_Required then
                            Total_Slice_Amount_S = GlobalValue.Set("Total_Slice_Amount", 0)
                        end
                    end
                end
                if tech_Level == 1 then
                    DebugMessage("%s -- Player on Tech 2", tostring(Script))
                    Story_Event("REBEL_SLICE_CREDIT_WARNING_2")
                    if player_credits >= 16000 then
                        DebugMessage("%s -- Player has specified amount of credits", tostring(Script))
                        player.Give_Money(-8500)
                        player.Set_Tech_Level(2)
                        Sleep(5)
                        Story_Event("REBEL_SLICE_CREDIT_WARNING_REMOVE")
                        if Total_Slice_Amount_S >= slices_Required then
                            Total_Slice_Amount_S = GlobalValue.Set("Total_Slice_Amount", 0)
                        end
                    end
                end
                if tech_Level == 2 then
                    DebugMessage("%s -- Player on Tech 3", tostring(Script))
                    Story_Event("REBEL_SLICE_CREDIT_WARNING_3")
                    if player_credits >= 25000 then
                        DebugMessage("%s -- Player has specified amount of credits", tostring(Script))
                        player.Give_Money(-16500)
                        player.Set_Tech_Level(3)
                        Sleep(5)
                        Story_Event("REBEL_SLICE_CREDIT_WARNING_REMOVE")
                        if Total_Slice_Amount_S >= slices_Required then
                            Total_Slice_Amount_S = GlobalValue.Set("Total_Slice_Amount", 0)
                        end
                    end
                end
                if tech_Level == 3 then
                    DebugMessage("%s -- Player on Tech 3", tostring(Script))
                    Story_Event("REBEL_SLICE_CREDIT_WARNING_4")
                    if player_credits >= 35000 then
                        DebugMessage("%s -- Player has specified amount of credits", tostring(Script))
                        player.Give_Money(-25000)
                        player.Set_Tech_Level(4)
                        Sleep(5)
                        Story_Event("REBEL_SLICE_CREDIT_WARNING_REMOVE")
                        if Total_Slice_Amount_S >= slices_Required then
                            Total_Slice_Amount_S = GlobalValue.Set("Total_Slice_Amount", 0)
                        end
                    end
                end
            end


        end
        DebugMessage("%s -- Exiting Script main Functions", tostring(Script))
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
