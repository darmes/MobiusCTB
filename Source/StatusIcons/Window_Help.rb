#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
#  Adds status icons to unscanned enemies
#==============================================================================
class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # * Set Enemy
  #     enemy : name and status displaying enemy
  #--------------------------------------------------------------------------
  alias mobius_status_icons_set_enemy mobius_ctb_set_enemy # unused alias
  def mobius_ctb_set_enemy(enemy)
    if enemy.states.any? { |id| $data_states[id].rating >= 1 }
      # treat enemy as mostly actor
      self.contents.clear
      draw_actor_name(enemy, 140, 0, 120)
      draw_actor_state(enemy, 344, 0, 120)
      @actor = enemy
      @text = nil
      self.visible = true
    else
      # draw only name
      text = enemy.name
      set_text(text, 1)
    end
  end

end
