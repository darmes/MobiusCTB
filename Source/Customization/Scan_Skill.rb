#==============================================================================
# ** SCAN SKILL SETTINGS
#------------------------------------------------------------------------------
# The following settings are all optional, and are only used with the expansions
# to the core script.
#==============================================================================
module Mobius
  module Scan_Skill
    #==============================================================================
    # Because this battle system is designed to more tactical than the default system, a
    # scan skill is basically a necessity to allow you to track an enemy's HP/SP.
    # To set this up, first create a skill to perform scan in the database. Second,
    # create a state for scan in the database. The skill and state can be configured however
    # you want just make sure that the scan skill applies the scan state to the enemy when used.
    # Once you've done that, set this option to the ID of the scan state that you created.
    # Then whenever an enemy has the scan state applied, you'll be able to see their HP/SP
    # when targeting them.
    SCAN_STATE_ID = 17
    # OPTIONAL: If you would like a pop-up to be displayed when you use the skill for the
    # first time, then you can do the following additional steps. Create a common event
    # called scan, and add a "script" command to it. Inside the script command, put
    # "Mobius.scan_skill_popup" without quotes. Then simply add the common event to the scan skill
    # you created earlier, and you're done!
    #==============================================================================
  end
end
