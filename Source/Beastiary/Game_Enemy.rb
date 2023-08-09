#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  Add one new concept to the Game_Enemy class
#    element_ranks
#      This lets us easily look up an enemy's element affinities
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Get Element Effectiveness
  #--------------------------------------------------------------------------
  def element_ranks
    return $data_enemies[@enemy_id].element_ranks
  end
end
