function Remove_Mission(tag)
    DebugMessage("%s -- Removing Mission: %s", tostring(Script), tostring(tag))
    local plot = Get_Story_Plot("StoryMissions\\Custom\\STORY_SANDBOX_EMPIRE_SCIENCE_LIB.XML") -- Please note that the .XML HAS TO BE CAPITILIZED if not it wont find the file
    event = plot.Get_Event("REMOVE_MISSION")
    event.Set_Reward_Parameter(0, tag)
    Story_Event("REMOVE_MISSION")
    return true
end