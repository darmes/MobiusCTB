#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
#  Updates the set_enemy method to display scanned enemies
#==============================================================================
class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # * Set Enemy
  #     enemy : name and status displaying enemy
  #--------------------------------------------------------------------------
  alias mobius_ctb_set_enemy set_enemy
  def set_enemy(enemy)
    # If enemy has been scanned
    if enemy.state?(Mobius::Scan_Skill::SCAN_STATE_ID)
      # treat enemy as actor
      set_actor(enemy)
    else
      # treat as enemy
      mobius_ctb_set_enemy(enemy)
    end
  end
end
