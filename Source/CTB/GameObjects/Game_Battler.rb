#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  Add two new concepts to the Game_Battler class
#    @charge_gauge
#      This represents how close a battler is to their next turn.
#      Ranges from 0-100.
#      When this value reaches 100, the battler gets a turn.
#    @charge_gauge_dummy
#      This is used to calculate future turns, and isn't "real".
#      We can freely manipulate this value to forecast out turn order.
#  Adjusts how states are removed to be compatible with new turn structure
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :charge_gauge             # charge gauge
  attr_accessor :charge_gauge_dummy       # charge gauge dummy
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias mobius_ctb_game_battler_initialize initialize
  def initialize
    mobius_ctb_game_battler_initialize
    @charge_gauge = 0
    @charge_gauge_dummy = 0
  end
  #--------------------------------------------------------------------------
  # * Charge -- Increases a battler's actual charge gauge
  #--------------------------------------------------------------------------
  def charge
    @charge_gauge += eval(Mobius::Charge_Turn_Battle::CHARGE_RATE)
  end
  #--------------------------------------------------------------------------
  # * Dummy Charge -- Increases a battler's dummy charge gauge for use
  #   in calculating turn order
  #--------------------------------------------------------------------------
  def dummy_charge
    @charge_gauge_dummy += eval(Mobius::Charge_Turn_Battle::CHARGE_RATE)
  end
  #--------------------------------------------------------------------------
  # * Dummy Charge Copy -- Sets a battler's dummy gauge equal to normal gauge
  #--------------------------------------------------------------------------
  def dummy_charge_copy
    @charge_gauge_dummy = @charge_gauge
  end
  #--------------------------------------------------------------------------
  # * Charge Reset -- Resets a battler's charge gauge to zero +/- speed_factor
  #--------------------------------------------------------------------------
  def charge_reset
    @charge_gauge -= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
    @charge_gauge += speed_factor
  end
  #--------------------------------------------------------------------------
  # * Dummy Charge Reset -- Resets a battler's dummy charge gauge to zero
  #--------------------------------------------------------------------------
  def dummy_charge_reset
    @charge_gauge_dummy -= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
  end
  #--------------------------------------------------------------------------
  # * Charge Clear -- Clears out a battler's charge/dummy charge at battle end
  #--------------------------------------------------------------------------
  def charge_clear
    @charge_gauge = 0
    @charge_gauge_dummy = 0
  end
  #--------------------------------------------------------------------------
  # * Speed Factor -- Returns a battler's speed_factor
  #--------------------------------------------------------------------------
  def speed_factor
    case @current_action.kind
    # When basic ( attack / defend / escape / nothing )
    when 0
      case @current_action.basic
      # When attack
      when 0
        # Get speed factor from hash: WEAPON_SPEED_FACTORS
        return Mobius::Charge_Turn_Battle::WEAPON_SPEED_FACTORS[@weapon_id]
      # When defend
      when 1
        return Mobius::Charge_Turn_Battle::DEFEND_SPEED_FACTOR
      # When escape
      when 2
        return Mobius::Charge_Turn_Battle::ESCAPE_SPEED_FACTOR
      # When nothing
      when 3
        return Mobius::Charge_Turn_Battle::NOTHING_SPEED_FACTOR
      end
    # When skill
    when 1
      skill_id = @current_action.skill_id
      # Get speed factor from hash: SKILL_SPEED_FACTORS
      return Mobius::Charge_Turn_Battle::SKILL_SPEED_FACTORS[skill_id]
    # When item
    when 2
      item_id = @current_action.item_id
      # Get speed factor from hash: ITEM_SPEED_FACTORS
      return Mobius::Charge_Turn_Battle::ITEM_SPEED_FACTORS[item_id]
    end
  end
  #--------------------------------------------------------------------------
  # Explanation:
  #  DBS reduces turn count and removes states at end of turn
  #  This fix causes turn count to decrement at end of turn while
  #  state removal happens at beginning of turn
  # TO BE COMPATIBLE WITH MY CTB SYSTEM
  #  "Remove states auto" is still called in phase 4 since the only active battler
  #  in phase 4 is whoever's turn it is, thus they will have there turn count
  #  decrement by one.
  #  "Remove states auto start" is called in phase two after determining whose turn
  #  it is next. That way only the current battler will have their states removed.
  #--------------------------------------------------------------------------
  # * Natural Removal of States (called up each end turn)
  #--------------------------------------------------------------------------
  def remove_states_auto
    for i in @states_turn.keys.clone
      if @states_turn[i] > 0
        @states_turn[i] -= 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Natural Removal of States (called up each start turn)
  #--------------------------------------------------------------------------
  def remove_states_auto_start
    for i in @states_turn.keys.clone
      if @states_turn[i] <= 0 and rand(100) < $data_states[i].auto_release_prob
        remove_state(i)
      end
    end
  end
end
