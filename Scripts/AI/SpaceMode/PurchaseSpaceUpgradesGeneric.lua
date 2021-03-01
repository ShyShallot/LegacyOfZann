-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/SpaceMode/PurchaseSpaceUpgradesGeneric.lua#5 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, Inc.
--
--
--  *****           **                          *                   *
--  *   **          *                           *                   *
--  *    *          *                           *                   *
--  *    *          *     *                 *   *          *        *
--  *   *     *** ******  * **  ****      ***   * *      * *****    * ***
--  *  **    *  *   *     **   *   **   **  *   *  *    * **   **   **   *
--  ***     *****   *     *   *     *  *    *   *  *   **  *    *   *    *
--  *       *       *     *   *     *  *    *   *   *  *   *    *   *    *
--  *       *       *     *   *     *  *    *   *   * **   *   *    *    *
--  *       **       *    *   **   *   **   *   *    **    *  *     *   *
-- **        ****     **  *    ****     *****   *    **    ***      *   *
--                                          *        *     *
--                                          *        *     *
--                                          *       *      *
--                                      *  *        *      *
--                                      ****       *       *
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
-- C O N F I D E N T I A L   S O U R C E   C O D E -- D O   N O T   D I S T R I B U T E
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/SpaceMode/PurchaseSpaceUpgradesGeneric.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 55010 $
--
--          $DateTime: 2006/09/19 19:14:06 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("pgevents")


function Definitions()
	
	Category = "Purchase_Space_Upgrades_Generic"
	IgnoreTarget = true
	TaskForce = {
	{
		"ReserveForce"
		,"DenySpecialWeaponAttach"
		,"DenyHeroAttach"
		,"RS_Enhanced_Shielding_L1_Upgrade | RS_Enhanced_Shielding_L2_Upgrade | RS_Enhanced_Shielding_L3_Upgrade | RS_Improved_Weapons_L1_Upgrade | RS_Improved_Weapons_L2_Upgrade | RS_Improved_Weapons_L3_Upgrade | RS_Increased_Supplies_L1_Upgrade | RS_Increased_Supplies_L2_Upgrade | RS_Ion_Cannon_Use_Upgrade | RS_Reinforced_Armor_L1_Upgrade | RS_Reinforced_Armor_L2_Upgrade | RS_Improved_Defenses_L1_Upgrade | RS_Improved_Defenses_L2_Upgrade | RS_Improved_Defenses_L3_Upgrade | RS_More_Garrisons_L1_Upgrade = 0,2"
		,"ES_Enhanced_Reactors_L1_Upgrade | ES_Enhanced_Reactors_L2_Upgrade | ES_Enhanced_Reactors_L3_Upgrade | ES_Reinforced_Armor_L1_Upgrade | ES_Reinforced_Armor_L2_Upgrade | ES_Reinforced_Armor_L3_Upgrade | ES_Increased_Supplies_L1_Upgrade | ES_Increased_Supplies_L2_Upgrade | ES_Improved_Weapons_L1_Upgrade | ES_Improved_Weapons_L2_Upgrade | ES_Improved_Weapons_L3_Upgrade | ES_Hypervelocity_Gun_Use_Upgrade | ES_Improved_Defenses_L1_Upgrade | ES_Improved_Defenses_L2_Upgrade | ES_Improved_Defenses_L3_Upgrade | ES_More_Garrisons_L1_Upgrade = 0,2"
		,"UL_Extort_Cash_L1_Upgrade | UL_Extort_Cash_L2_Upgrade | US_Reinforced_Structure_L1_Upgrade | US_Reinforced_Structure_L2_Upgrade | US_Reinforced_Structure_L3_Upgrade | US_BlackMarket_Reactors_L1_Upgrade | US_BlackMarket_Reactors_L2_Upgrade | US_BlackMarket_Reactors_L3_Upgrade | US_Magnetically_Sealed_Armor_L1_Upgrade | US_Magnetically_Sealed_Armor_L2_Upgrade | US_Magnetically_Sealed_Armor_L3_Upgrade | US_Carbonite_Coolant_Systems_L1_Upgrade | US_Carbonite_Coolant_Systems_L2_Upgrade | US_Cloaking_Generator_L1_Upgrade | US_Cloaking_Generator_L2_Upgrade | US_Plasma_Cannon_Use_Upgrade = 0,2"
	}
	}
	 
	RequiredCategories = {"Upgrade"}
	AllowFreeStoreUnits = false

end

function ReserveForce_Thread()
			
	BlockOnCommand(ReserveForce.Produce_Force())
	ReserveForce.Set_Plan_Result(true)
	ReserveForce.Set_As_Goal_System_Removable(false)

	-- Give some time to accumulate money.
	tech_level = PlayerObject.Get_Tech_Level()
	min_credits = 2000
	if tech_level == 2 then
		min_credits = 4000
	elseif tech_level >= 3 then
		min_credits = 6000
	end
	
	max_sleep_seconds = 120
	current_sleep_seconds = 0
	while (PlayerObject.Get_Credits() < min_credits) and (current_sleep_seconds < max_sleep_seconds) do
		current_sleep_seconds = current_sleep_seconds + 1
		Sleep(1)
	end

	ScriptExit()
end

