#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  Add one new concept to the Game_Enemy class
#    @boss
#      This represents if an enemy should be treated as a boss.
#      This affects certain display elements like prefixing the name with "Boss:"
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
    attr_reader   :boss  # Boss
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     troop_id     : troop ID
  #     member_index : troop member index
  #--------------------------------------------------------------------------
  alias mobius_ctb_game_enemy_initialize initialize
  def initialize(troop_id, member_index)
    mobius_ctb_game_enemy_initialize(troop_id, member_index)
    @boss = Mobius::Charge_Turn_Battle::BOSS_LIST.include?(id)
  end
  #--------------------------------------------------------------------------
  # * Get Name - May return a prefixed base_name
  #--------------------------------------------------------------------------
  alias base_name name
  def name
    if Mobius::Charge_Turn_Battle::USE_ENEMY_PREFIX
      if @boss
        return Mobius::Charge_Turn_Battle::ENEMY_BOSS_PREFIX + base_name
      else
        prefix_array = Mobius::Charge_Turn_Battle::ENEMY_PREFIX.split(",")
        prefix = prefix_array[@member_index].to_s #convert to string in case it's nil
        return prefix + base_name
      end
    else
      return base_name
    end
  end
end
