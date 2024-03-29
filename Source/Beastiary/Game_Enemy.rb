#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  Add one new concept to the Game_Enemy class
#    element_ranks
#      This lets us easily look up an enemy's element affinities
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Get Element Efficiency - Human readable string
  #     element_id : Element ID
  #--------------------------------------------------------------------------
  def element_efficiency(element_id)
    return $data_enemies[@enemy_id].element_efficiency(element_id)
  end
  #--------------------------------------------------------------------------
  # * Get All Elements Effectiveness
  #--------------------------------------------------------------------------
  def element_ranks
    return $data_enemies[@enemy_id].element_ranks
  end
  #--------------------------------------------------------------------------
  # * Get Elements that the enemy is strong versus
  #--------------------------------------------------------------------------
  def strong_elements
    return $data_enemies[@enemy_id].strong_elements
  end
  #--------------------------------------------------------------------------
  # * Get Elements that the enemy is strong versus
  #--------------------------------------------------------------------------
  def weak_elements
    return $data_enemies[@enemy_id].weak_elements
  end
  #-------------------------------------------------------------------------- 
  # * Get State Efficiency - Human readable string
  #     state_id : State ID
  #--------------------------------------------------------------------------
  def state_efficiency(state_id)
    $data_enemies[@enemy_id].state_efficiency(state_id)
  end
  #--------------------------------------------------------------------------
  # * Get States that the enemy is strong versus
  #--------------------------------------------------------------------------
  def strong_states
    return $data_enemies[@enemy_id].strong_states
  end
  #--------------------------------------------------------------------------
  # * Get States that the enemy is strong versus
  #--------------------------------------------------------------------------
  def weak_states
    return $data_enemies[@enemy_id].weak_states
  end
end
