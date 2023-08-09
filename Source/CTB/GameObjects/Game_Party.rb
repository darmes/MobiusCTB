#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Add charge gauge clearing
#==============================================================================
class Game_Party
  #--------------------------------------------------------------------------
  # * Clear All Member Actions and Charge Gauges
  #--------------------------------------------------------------------------
  alias mobius_clear_actions clear_actions
  def clear_actions
    mobius_clear_actions
    # Clear All Member Charge Gauges
    for actor in @actors
      actor.charge_clear
    end
  end

end
