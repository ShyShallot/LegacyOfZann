--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("PGInterventions")


function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    Define_State("State_Init", State_Init);
    ServiceRate = 1.0 -- Wait some time before looping
    politicalControl = 1
    DebugMessage("%s -- politicalControl Value", tostring(politicalControl))
    is_intervention_active = false
	intervention_sleep_time = 120 -- Wait every x seconds to call another intervention

    reward_table_space = { 			
					Find_Object_Type("Broadside_Class_Cruiser"), 
					Find_Object_Type("Interdictor_Cruiser"), 
					Find_Object_Type("Tartan_Patrol_Cruiser"), 
					Find_Object_Type("Victory_Destroyer"), 
					Find_Object_Type("Acclamator_Assault_Ship"), 
					Find_Object_Type("Star_Destroyer"), 
                    Find_Object_Type("TIE_Scout_Squadron"), 
                    Find_Object_Type("Gladiator_Carrier"), }

    reward_table_land = { 
					Find_Object_Type("Imperial_Artillery_Corp"),
					Find_Object_Type("Imperial_Heavy_Scout_Squad"), 
					Find_Object_Type("Imperial_Anti_Aircraft_Company"), 
					Find_Object_Type("Imperial_Armor_Group"), 
					Find_Object_Type("Imperial_Heavy_Assault_Company"), 
					Find_Object_Type("Imperial_Anti_Infantry_Brigade"), 
					Find_Object_Type("Imperial_Stormtrooper_Squad"), 
					Find_Object_Type("Imperial_Light_Scout_Squad"),  }	

 
end

function State_Init(message)
    DebugMessage("%s -- In Inital State, Running Script", tostring(Script))
    if message == OnEnter then -- This is Ran on GC Start, use it to define Vars
            DebugMessage("%s -- In OnEnter, Defining Vars", tostring(Script))
            
            player = Find_Player("Empire")
            DebugMessage("%s -- Found Player", tostring(Script))
            if player == nil then
                player = Find_Player("EMPIRE")
                DebugMessage("%s -- Player not Found doing 2nd Check", tostring(Script))
            end
            GlobalValue.Set("Political_Control", 0)
            DebugMessage("%s -- Setting Global Control", tostring(Script))
            Update_Dialog()
    end
	if message == OnUpdate then -- This is Ran based off of the Service Rate
        if is_intervention_active == false then
            Interventions()
        end
    end
end


function PoliticalScript()
        DebugMessage("%s -- Event Triggered Script, Setting Control", tostring(Script))
        politicalControl = politicalControl + 1
        if politicalControl > 10 then
            politicalControl = 10
        end
        GlobalValue.Set("Political_Control", politicalControl)
        DebugMessage("%s -- politicalControl Value", tostring(politicalControl))
        DebugMessage("%s -- Set Control Values", tostring(Script))
        Update_Dialog()
		DebugMessage("%s -- Running Update_Dialog", tostring(Script))
		sleep(intervention_sleep_time)
end

function Update_Dialog()
    DebugMessage("%s -- Running Update Function", tostring(Script))
    plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_EMPIRE_POLITICAL.XML")
    if plot == nil then
        plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_EMPIRE_POLITICAL.XML")
    end
    event = plot.Get_Event("Empire_Pol_Control_Display")
    event.Clear_Dialog_Text()
    event.Add_Dialog_Text("TEXT_STORY_EMPIRE_POLITICAL_CONTROL", politicalControl)
    Story_Event("POLITICAL_CONTROL_NOTIFICATION")
    DebugMessage("%s -- Update Function Complete", tostring(Script))
end

function Interventions() 

	if player.Get_Credits() >= 9000 then
		Upgrade_Station_Intervention()
	elseif player.Get_Credits() <= 7000 then
		Accumulate_Credits_Intervention() 
	elseif Find_Object_Type("E_Ground_Heavy_Vehicle_Factory") == nil and player.Get_Tech_Level() >= 3 then
		Build_Heavy_Factory_Intervention()
	elseif player.Get_Credits() >= 5000 and player.Get_Tech_Level() >= 2 then
		Build_Light_Factory_Intervention()
	elseif player.Get_Credits() >= 1 then
		Scout_Intervention()
	elseif Find_Object_Type("Darth_Team_Executor") and player.Get_Tech_Level() >= 3 then
		Vader_Favor_Intervention()
	end

end

-- Functions for Empire Interventions
function Upgrade_Station_Intervention()
    
    is_intervention_active = true 

	if player.Get_Faction_Name() == "EMPIRE" then
		dialog = "Dialog_E_Intervention_Upgrade_Space_Station"
	end		
	
	base_type = Target.Get_Next_Starbase_Type()
	
	plot = Get_Story_Plot("StoryMissions\\Intervention_Upgrade_Space_Station.XML")
		
	event = plot.Get_Event("Upgrade_Space_Station_00")
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_STRUCTURE", base_type)
	event.Add_Dialog_Text("TEXT_INTERVENTION_LOCATION", Target)
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", "TEXT_CREDITS", 1000)

	event = plot.Get_Event("Upgrade_Space_Station_01")
	event.Set_Event_Parameter(0, Target)
	event.Set_Event_Parameter(1, base_type.Get_Base_Level())
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", "TEXT_CREDITS", 1000)
	
	event = plot.Get_Event("Upgrade_Space_Station_03")
	event.Set_Reward_Parameter(1, player.Get_Faction_Name())
	event.Set_Reward_Parameter(2, Target)

	plot.Activate()
	
	Wait_On_Flag("UPGRADE_SPACE_STATION_NOTIFICATION_00", Target)

	plot.Suspend()

	plot.Reset()

    PoliticalScript()
    
    is_intervention_active = false
end

function Intervention_Original_Target_Owner_Changed(tf, old_player, new_player)
	--Cancel the mission, then reset the plot and quit
	event = plot.Get_Event("Upgrade_Space_Station_04")
	event.Set_Event_Parameter(0, Target)
	Story_Event("UPGRADE_SPACE_STATION_NOTIFICATION_ABORT", Target)	
	plot.Suspend()
	plot.Reset()
	ScriptExit()
end

function Accumulate_Credits_Intervention()

    is_intervention_active = true

	if player.Get_Faction_Name() == "EMPIRE" then
		dialog = "Dialog_E_Intervention_Accumulate_Credits"
    end
	
	reward_unit, reward_count = Select_Reward_Unit(reward_table_space, player, 500 * (player.Get_Tech_Level() + 1))
	
	plot = Get_Story_Plot("StoryMissions\\Intervention_Accumulate_Credits.XML")
		
	event = plot.Get_Event("Accumulate_Credits_00")
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_CREDIT_TARGET", 10000)
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", reward_unit, reward_count)

	reward_location = FindTarget(Intervention, "One", "Friendly", 1.0)

	event = plot.Get_Event("Accumulate_Credits_01")
	event.Set_Reward_Parameter(0, reward_unit)
	event.Set_Reward_Parameter(1, reward_location)
	event.Set_Reward_Parameter(2, reward_count)
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", reward_unit, reward_count)
	
	event = plot.Get_Event("Accumulate_Credits_03")
	event.Set_Reward_Parameter(1, player.Get_Faction_Name())

	plot.Activate()
	
	while not Check_Story_Flag(player, "ACCUMULATE_CREDITS_NOTIFICATION_00", nil, true) do
		Sleep(1)
	end

	plot.Suspend()

    plot.Reset()
    
    PoliticalScript()

    is_intervention_active = false

end

function Build_Heavy_Factory_Intervention()

    is_intervention_active = true

	if player.Get_Faction_Name() == "EMPIRE" then
		dialog = "Dialog_E_Intervention_Build_Generic_Structure"
		build_object = Find_Object_Type("E_Ground_Heavy_Vehicle_Factory")
	end	

	reward_unit, reward_count = Select_Reward_Unit(reward_table_land, player, 500 * player.Get_Tech_Level())

	
	--determine how many factories should be built
	factory_count = player.Get_Tech_Level()

	--find the xml defined plot for building a generic structure and fill in the skeleton so that
	--it asks the player to build the appropraite number of ion cannons
	plot = Get_Story_Plot("StoryMissions\\Intervention_Build_Generic_Structure.XML")
				
	--Setup the first event to pop up a dialog and give the player some money to spend on the factories				
	event = plot.Get_Event("Build_Generic_Structure_00")
	event.Set_Reward_Parameter(0, factory_count * 1500)
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_QUANTITY", factory_count)
	event.Add_Dialog_Text("TEXT_INTERVENTION_STRUCTURE", build_object)
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", reward_unit, reward_count)
	
	--Set up the second event to fire when we build the correct number of ion cannons
	event = plot.Get_Event("Build_Generic_Structure_01")
	event.Set_Event_Parameter(0, build_object)
	event.Set_Event_Parameter(1, factory_count)
	event.Set_Reward_Parameter(1, player.Get_Faction_Name())
	
	--Start the plot
	plot.Activate()	
	
	--Wait on notification from the story system that the task has been accomplished
	Wait_On_Flag("BUILD_GENERIC_STRUCTURE_NOTIFICATION_00", nil)
	
	--Find a suitable place to station the reward units
	reward_location = FindTarget(Intervention, "Intervention_Helper_Has_Heavy_Vehicle_Factory", "Friendly", 1.0)
	while not reward_location do
		Sleep(1)
		reward_location = FindTarget(Intervention, "Intervention_Helper_Has_Heavy_Vehicle_Factory", "Friendly", 1.0)
	end		
	
	--Set up an event to spawn the reward unit at the selected location and congratulate the player
	event = plot.Get_Event("Build_Generic_Structure_02")
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", reward_unit, reward_count)

	event = plot.Get_Event("Build_Generic_Structure_03")
	event.Set_Reward_Parameter(0, reward_unit)
	event.Set_Reward_Parameter(1, reward_location)
	event.Set_Reward_Parameter(2, reward_count)	

	event = plot.Get_Event("Build_Generic_Structure_04")
	event.Set_Reward_Parameter(1, player.Get_Faction_Name())

	--Fire this story event to allow the plot to continue and run the event we just set up
	Story_Event("BUILD_GENERIC_STRUCTURE_NOTIFICATION_01")
	
	--Wait until the plot informs us that it's done, stop and reset it, then sleep for a while before we exit
	--to prevent interventions from spawning back-to-back
	while not Check_Story_Flag(player, "BUILD_GENERIC_STRUCTURE_NOTIFICATION_02", nil, true) do
		Sleep(1)
	end

	plot.Suspend()

	plot.Reset()

    PoliticalScript()
    
    is_intervention_active = false

end

function Build_Light_Factory_Intervention()
    
    is_intervention_active = true
	
	if player.Get_Faction_Name() == "EMPIRE" then
		dialog = "Dialog_E_Intervention_Build_Generic_Structure"
		build_object = Find_Object_Type("E_Ground_Light_Vehicle_Factory")
	end	

	reward_unit, reward_count = Select_Reward_Unit(reward_table_land, player, 400 * player.Get_Tech_Level())
	
	--determine how many factories should be built
	factory_count = player.Get_Tech_Level()

	--find the xml defined plot for building a generic structure and fill in the skeleton so that
	--it asks the player to build the appropraite number of ion cannons
	plot = Get_Story_Plot("StoryMissions\\Intervention_Build_Generic_Structure.XML")
				
	--Setup the first event to pop up a dialog and give the player some money to spend on the factories				
	event = plot.Get_Event("Build_Generic_Structure_00")
	event.Set_Reward_Parameter(0, factory_count * 50)
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_QUANTITY", factory_count)
	event.Add_Dialog_Text("TEXT_INTERVENTION_STRUCTURE", build_object)
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", reward_unit, reward_count)
	
	--Set up the second event to fire when we build the correct number of ion cannons
	event = plot.Get_Event("Build_Generic_Structure_01")
	event.Set_Event_Parameter(0, build_object)
	event.Set_Event_Parameter(1, factory_count)
	event.Set_Reward_Parameter(1, player.Get_Faction_Name())
	
	--Start the plot
	plot.Activate()	
	
	--Wait on notification from the story system that the task has been accomplished
	Wait_On_Flag("BUILD_GENERIC_STRUCTURE_NOTIFICATION_00", nil)
	
	--Find a suitable place to station the reward units
	reward_location = FindTarget(Intervention, "Intervention_Helper_Has_Light_Vehicle_Factory", "Friendly", 1.0)
	while not reward_location do
		Sleep(1)
		reward_location = FindTarget(Intervention, "Intervention_Helper_Has_Light_Vehicle_Factory", "Friendly", 1.0)
	end		
	
	--Set up an event to spawn the reward unit at the selected location and congratulate the player
	event = plot.Get_Event("Build_Generic_Structure_02")
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", reward_unit, reward_count)

	event = plot.Get_Event("Build_Generic_Structure_03")
	event.Set_Reward_Parameter(0, reward_unit)
	event.Set_Reward_Parameter(1, reward_location)
	event.Set_Reward_Parameter(2, reward_count)	

	event = plot.Get_Event("Build_Generic_Structure_04")
	event.Set_Reward_Parameter(1, player.Get_Faction_Name())

	--Fire this story event to allow the plot to continue and run the event we just set up
	Story_Event("BUILD_GENERIC_STRUCTURE_NOTIFICATION_01")
	
	--Wait until the plot informs us that it's done, stop and reset it, then sleep for a while before we exit
	--to prevent interventions from spawning back-to-back
	while not Check_Story_Flag(player, "BUILD_GENERIC_STRUCTURE_NOTIFICATION_02", nil, true) do
		Sleep(1)
	end

	plot.Suspend()

	plot.Reset()

    PoliticalScript()
    
    is_intervention_active = false


end

function Scout_Intervention()
    
    is_intervention_active = true
		
	if player.Get_Faction_Name() == "EMPIRE" then
		dialog = "Dialog_E_Intervention_Scout"
	end			
		
	plot = Get_Story_Plot("StoryMissions\\Intervention_Scout.XML")
		
	event = plot.Get_Event("Scout_00")
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_LOCATION", Target)
	
	event = plot.Get_Event("Scout_01")
	event.Set_Event_Parameter(0, Target)
	event.Set_Reward_Parameter(1, player.Get_Faction_Name())
	
	plot.Activate()
	
	Wait_On_Flag("SCOUT_NOTIFICATION_00", nil)

	second_target = FindTarget(Intervention, "Intervention_Helper_Good_Scout_Target", "Enemy", 0.5)
	
	if not second_target or second_target == Target then
		event = plot.Get_Event("Scout_06")
		event.Set_Dialog(dialog)
		event.Clear_Dialog_Text()
		event.Add_Dialog_Text("TEXT_INTERVENTION_LOCATION_COMPLETE", Target)	
		event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", "TEXT_CREDITS", 1000)	
		Story_Event("SCOUT_NOTIFICATION_03")
		Wait_On_Flag("SCOUT_NOTIFICATION_02")
		plot.Suspend()
		plot.Reset()
		PoliticalScript()
	end

	event = plot.Get_Event("Scout_02")
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_LOCATION_COMPLETE", Target)	
	event.Add_Dialog_Text("TEXT_INTERVENTION_LOCATION", second_target)	
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", "TEXT_CREDITS", 1000)

	event = plot.Get_Event("Scout_03")
	event.Set_Event_Parameter(0, second_target)
	event.Set_Dialog(dialog)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", "TEXT_CREDITS", 1000)

	event = plot.Get_Event("Scout_05")
	event.Set_Reward_Parameter(1, player.Get_Faction_Name())

	Story_Event("SCOUT_NOTIFICATION_01")

	while not Check_Story_Flag(player, "SCOUT_NOTIFICATION_02", nil, true) do
		Sleep(1)
	end

	plot.Suspend()

	plot.Reset()

	PoliticalScript()

    is_intervention_active = false

end

function Vader_Favor_Intervention()
	
    is_intervention_active = true    
    
	plot = Get_Story_Plot("StoryMissions\\Intervention_Vader_Favor.XML")
	
	empire_player = Find_Player("EMPIRE")
	
	unit, count = Select_Reward_Unit(reward_table_space, empire_player, 2000 * empire_player.Get_Tech_Level())
		
	event = plot.Get_Event("Vader_Favor_00")
	event.Set_Reward_Parameter(0, Target)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_LOCATION", Target)
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", unit, count)
	
	event = plot.Get_Event("Vader_Favor_00_restricted")
	event.Set_Event_Parameter(0, Target)
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_LOCATION", Target)
	
	event = plot.Get_Event("Vader_Favor_01")
	event.Set_Event_Parameter(1, Target)
	event.Set_Reward_Parameter(0, Target)
	
	event = plot.Get_Event("Vader_Favor_02")
	event.Set_Event_Parameter(0, Target)
	
	event = plot.Get_Event("Vader_Favor_03")
	event.Clear_Dialog_Text()
	event.Add_Dialog_Text("TEXT_INTERVENTION_LOCATION", Target)
	event.Add_Dialog_Text("TEXT_INTERVENTION_REWARD", unit, count)
	event.Set_Reward_Parameter(0, unit)
	event.Set_Reward_Parameter(1, Target)
	event.Set_Reward_Parameter(2, count)

	plot.Activate()
	
	while not Check_Story_Flag(player, "VADER_FAVOR_NOTIFICATION_00", nil, true) do
		Sleep(1)
	end
	
	plot.Suspend()

	plot.Reset()
	
	PoliticalScript()

    is_intervention_active = false

end