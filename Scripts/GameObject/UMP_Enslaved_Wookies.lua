-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/GameObject/UMP_Enslaved_Wookies.lua#4 $
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
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/GameObject/UMP_Enslaved_Wookies.lua $
--
--    Original Author: James Yarrow
--
--            $Author: Mike_Lytle $
--
--            $Change: 50481 $
--
--          $DateTime: 2006/08/04 16:32:19 $
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
	underworld_player = Find_Player("Underworld")

end


function State_Init(message)

	if message == OnEnter then
		-- Register a prox event that looks for any nearby units
		Register_Prox(Object, Unit_Prox, 100, underworld_player)
	elseif message == OnUpdate then
		-- Do nothing
	elseif message == OnExit then
		-- Do nothing
	end

end

function Unit_Prox(self_obj, trigger_obj)
    if self_obj.Is_Selectable() then
        self_obj.Cancel_Event_Object_In_Range(Unit_Prox)
        return
    end
        
    self_obj.Change_Owner(underworld_player) 
    parent = self_obj.Get_Parent_Object()
    self_obj.Get_Parent_Object().Change_Owner(underworld_player) 
    self_obj.Get_Parent_Object().Set_Selectable(true)
    self_obj.Set_Selectable(true)
    underworld_player.Select_Object(Object)
    
    --self_obj.Play_SFX_Event("Unit_Select_Chewie")
    self_obj.Cancel_Event_Object_In_Range(Unit_Prox)
end