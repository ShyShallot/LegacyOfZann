-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/GameObject/UM01_BlackBoxPowerUp.lua#4 $
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
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/GameObject/UM01_BlackBoxPowerUp.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Jeff_Stewart $
--
--            $Change: 47424 $
--
--          $DateTime: 2006/06/28 17:56:17 $
--
--          $Revision: #4 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")


function Definitions()

   -- Object isn't valid at this point so don't do any operations that
   -- would require it.  State_Init is the first chance you have to do
   -- operations on Object
   
	DebugMessage("%s -- In Definitions", tostring(Script))
	Define_State("State_Init", State_Init);
	player=nil
end


function State_Init(message)

	if message == OnEnter then
		-- Register a prox event that looks for any nearby units
		Register_Prox(Object, Unit_Prox, 200, nil)
	elseif message == OnUpdate then
		-- Do nothing
	elseif message == OnExit then
		-- Do nothing
	end

end

function Unit_Prox(self_obj, trigger_obj)
	player = Find_Player("Underworld")
	if trigger_obj.Get_Owner() == player then
		if not trigger_obj then
			DebugMessage("Warning: prox received a nil trigger_obj .")
			return
		end
		self_obj.Take_Damage(10000) 
	end
	rebel_player = Find_Player("Rebel")
	if trigger_obj.Get_Owner() == rebel_player then
	end
end