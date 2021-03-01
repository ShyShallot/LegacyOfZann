-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/GameObject/UM11_ForceAdeptFour.lua#3 $
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
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/GameObject/UM11_ForceAdeptFour.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Jeff_Stewart $
--
--            $Change: 49291 $
--
--          $DateTime: 2006/07/20 17:09:55 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")


function Definitions()

   -- Object isn't valid at this point so don't do any operations that
   -- would require it.  State_Init is the first chance you have to do
   -- operations on Object
   
	DebugMessage("%s -- In Definitions", tostring(Script))
	Define_State("State_Init", State_Init);
end


function State_Init(message)

	if message == OnEnter then
		warp1 = Find_Hint("STORY_TRIGGER_ZONE", "a4-w1")
		warp2 = Find_Hint("STORY_TRIGGER_ZONE", "a4-w2")
		warp3 = Find_Hint("STORY_TRIGGER_ZONE", "a4-w3")
		warp4 = Find_Hint("STORY_TRIGGER_ZONE", "a4-w4")
		warp5 = Find_Hint("STORY_TRIGGER_ZONE", "a4-w5")
		warp6 = Find_Hint("STORY_TRIGGER_ZONE", "a4-w6")
	
		-- Register a prox event that looks for any nearby units
		Register_Prox(Object, Unit_Prox, 100, Find_Player("Underworld"))
		
		closerange = false
		
		Create_Thread("AdeptFour_AI")
	elseif message == OnUpdate then
		-- Do nothing
		
	elseif message == OnExit then
		-- Do nothing
	end

end

function Unit_Prox(self_obj, trigger_obj)
	DebugMessage("-- %s -- %s",tostring(Object.Get_Type()),tostring(Object.Get_Owner()))
	if not trigger_obj then
		DebugMessage("Warning: prox received a nil trigger_obj .")
		return
	end
	closerange = true
end

function AdeptFour_AI()
	warptimer = 0
	while TestValid(Object) do
		noteleports = false
		cage = Find_Nearest(Object,"Underworld_Ysalamiri_Cage")
		if TestValid(cage) then
			dist = Object.Get_Distance(cage)
			if dist < 200 then
				noteleports = true
				Object.Override_Max_Speed(.1)
				Object.Attach_Particle_Effect("STUNNED_OBJECT")
				Object.Set_Cannot_Be_Killed(false)
				--MessageBox("Stunned")
			end
		else
			Object.Set_Cannot_Be_Killed(true)
			Object.Override_Max_Speed(false)
			noteleports = false
		end
		warptimer = warptimer + 1
		if not noteleports then 
			if warptimer/5 > Object.Get_Hull() then
				rand_index = GameRandom(1,6)
				Object.Suspend_Locomotor(true)
				Object.Play_Animation("Idle",true,0)
				Object.Attach_Particle_Effect("BOTHAN_STUN_GAS")
				Sleep(1)
				if rand_index == 1 then
					Object.Teleport_And_Face(warp1)
				end
				if rand_index == 2 then
					Object.Teleport_And_Face(warp2)
				end
				if rand_index == 3 then
					Object.Teleport_And_Face(warp3)
				end
				if rand_index == 4 then
					Object.Teleport_And_Face(warp4)
				end
				if rand_index == 5 then
					Object.Teleport_And_Face(warp5)
				end
				if rand_index == 6 then
					Object.Teleport_And_Face(warp6)
				end
				Object.Suspend_Locomotor(false)
				warptimer = 0
			end
		end
		target = Find_Nearest(Object, underworld_player)
		if TestValid(target) then
			Object.Attack_Move(target)
		end
		Sleep(1)
		closerange = false
	end
end


