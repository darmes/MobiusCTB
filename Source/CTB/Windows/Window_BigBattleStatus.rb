#==============================================================================
# ** Window_BigBattleStatus
#------------------------------------------------------------------------------
#  This window displays additional information during battle
#==============================================================================
class Window_BigBattleStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(all_battlers)
    super(0, 0, 640, 320)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.back_opacity = 160
    self.visible = false
    self.z = 100
    @all_battlers = all_battlers
    refresh
  end
  #--------------------------------------------------------------------------
  # * Active Battlers - Returns only the battlers that exist
  #--------------------------------------------------------------------------
  def active_battlers
    return @all_battlers.find_all do | battler |
      battler.exist?
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    # Local variables
    battlers = Mobius::Charge_Turn_Battle::BATTLERS_WORD
    status = Mobius::Charge_Turn_Battle::BATTLERS_WORD
    hp = $data_system.words.hp
    maxhp = Mobius::Charge_Turn_Battle::MAXHP_WORD
    sp = $data_system.words.sp
    maxsp = Mobius::Charge_Turn_Battle::MAXSP_WORD
    w = 152
    h = 32
    # Draw labels
    self.contents.draw_text(1 + (0*w), 0, w, h, battlers)
    self.contents.draw_text(1 + (1*w), 0, w, h, status, 1)
    self.contents.draw_text(1 + (2*w), 0, w, h, "#{hp} / #{maxhp}", 2)
    self.contents.draw_text(1 + (3*w), 0, w, h, "#{sp} / #{maxsp}", 2)
    # Draw battlers
    self.contents.font.color = normal_color
    battler_list = active_battlers()
    for i in 0...battler_list.size
      battler = battler_list[i]
      # TODO: Add status icons support?
      state = make_battler_state_text(battler, w, true)
      self.contents.draw_text(1 + (0*w), 22 + (i*22), w, h, battler.name)
      self.contents.draw_text(1 + (1*w), 22 + (i*22), w, h, state, 1)
      # Check to see if the enemy has been scanned
      # If not, then return question mark values
      if battler.is_a?(Game_Enemy) and not battler.state?(Mobius::Scan_Skill::SCAN_STATE_ID)
          self.contents.draw_text(1 + (2*w), 22 + (i*22), w, 32,"???", 2) # HP
          self.contents.draw_text(1 + (3*w), 22 + (i*22), w, 32,"???", 2) # SP
      else
          draw_battler_hp(battler, 1 + (2*w), 22 + (i*22)) #width = 152
          draw_battler_sp(battler, 1 + (3*w), 22 + (i*22)) #width = 152
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw HP -- Mobius modified from Window_Base
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_battler_hp(actor, x, y)
    # Draw HP
    self.contents.font.color = actor.hp <= actor.maxhp / 10 ? knockout_color :
      actor.hp <= actor.maxhp / 4 ? crisis_color : normal_color
    self.contents.draw_text(x, y, 70, 32, actor.hp.to_s, 2)
    # Draw MaxHP
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 70, y, 12, 32, "/", 1)
    self.contents.draw_text(x + 82, y, 70, 32, actor.maxhp.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw SP -- Mobius modified from Window_Base
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_battler_sp(actor, x, y)
    # Draw SP
    self.contents.font.color = actor.sp <= actor.maxsp / 10 ? knockout_color :
      actor.sp <= actor.maxsp / 4 ? crisis_color : normal_color
    self.contents.draw_text(x, y, 70, 32, actor.sp.to_s, 2)
    # Draw MaxSP
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 70, y, 12, 32, "/", 1)
    self.contents.draw_text(x + 82, y, 70, 32, actor.maxsp.to_s, 2)
  end
end
