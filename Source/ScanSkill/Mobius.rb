#==============================================================================
# ** Mobius
#------------------------------------------------------------------------------
#  This module is a collection of various, random methods that don't fit
#  anywhere else, and need to be able to be called from anywhere.
#
#  Usage:
#   All methods are module methods and can be called globally by prefacing the
#   method name with "Mobius", ex. "Mobius.example"
#==============================================================================
module Mobius
  #------------------------------------------------------------------------
  # * Scan Skill - scans an enemy and adds their stats to the beastiary
  #------------------------------------------------------------------------
  def self.scan_skill
    ab = $scene.active_battler
    ti = ab.current_action.target_index
    en = $game_troop.enemies[ti]
    $game_party.scan_list.push(en.id).uniq!
  end
  #------------------------------------------------------------------------
  # * Scan Skill Popup - scans an enemy creates a pop-up window
  #------------------------------------------------------------------------
  def self.scan_skill_popup
    ab = $scene.active_battler
    ti = ab.current_action.target_index
    en = $game_troop.enemies[ti]
    name = en.name
    hp = en.hp ; maxhp = en.maxhp
    sp = en.sp ; maxsp = en.maxsp
    atk = en.atk
    pdef = en.pdef ; mdef = en.mdef
    txt = "#{name} \nHP: #{hp}/#{maxhp}\n"+
    "SP: #{sp}/#{maxsp} \nATK: #{atk} \nPDEF: #{pdef}\n"+
    "MDEF: #{mdef}"
    $game_temp.message_text = txt
    Window_Message.new
  end

end
