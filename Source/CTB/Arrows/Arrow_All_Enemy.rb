#==============================================================================
# ** Arrow_All_Enemy
#------------------------------------------------------------------------------
#  This class creates and manages arrow cursors to choose all enemies.
#==============================================================================
class Arrow_All_Enemy < Arrow_All_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    make_enemy_list
    make_helper_arrows
  end
  #--------------------------------------------------------------------------
  # * Make Enemy List
  #--------------------------------------------------------------------------
  def make_enemy_list
    for enemy in $game_troop.enemies
      @battlers.push(enemy) if enemy.exist?
    end
  end
end
