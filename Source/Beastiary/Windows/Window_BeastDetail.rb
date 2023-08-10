#==============================================================================
# ** Window_BeastDetail
#------------------------------------------------------------------------------
#  This window displays detailed information on scanned beasts
#==============================================================================
class Window_BeastDetail < Window_BeastInformation
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    super(0, 0, 640, 320)
    self.z = 98
    self.back_opacity = 240
    refresh
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    # Clear contents
    self.contents.clear
    return if @enemy == nil
    # Set up drawing variables
    color = Mobius::Beastiary::DIVIDER_LINE_COLOR
    w3 = contents.width / 3
    # Draw name
    self.contents.draw_text(0, 0, w3, 32, @enemy.name)
    # Draw header line
    self.contents.fill_rect(0, 32, w3, 1, color)
    # Draw divider lines
    self.contents.fill_rect(w3 + 1, 4, 1, 320 - 32, color)
    self.contents.fill_rect(w3 + 1, 5*32, 2*w3, 1, color)
    # Draw stats
    draw_stats
    # Draw Elements
    draw_elements
    # Draw States
    draw_states
  end
  #--------------------------------------------------------------------------
  # * Draw all stats
  #--------------------------------------------------------------------------
  def draw_stats
    column_max = 2
    offset = 204
    padding = 8
    height = 32
    width = contents.width / 3
    for i in 0..9
      x = i % column_max * (width + padding) + offset
      y = i / column_max * height
      draw_enemy_parameter(x, y, width - padding, height, i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw top/bottom elements
  #--------------------------------------------------------------------------
  def draw_elements
    w3 = contents.width / 3
    self.contents.draw_text(0, 32, w3, 32, "Strong Elements")
    draw_element(0, 2*32, w3, 32, 1)
    draw_element(0, 3*32, w3, 32, 2)
    draw_element(0, 4*32, w3, 32, 3)
    self.contents.draw_text(0, 5*32, w3, 32, "Weak Elements")
    draw_element(0, 6*32, w3, 32, 4)
    draw_element(0, 7*32, w3, 32, 5)
    draw_element(0, 8*32, w3, 32, 6)
  end
  #--------------------------------------------------------------------------
  # * Draw top/bottom states
  #--------------------------------------------------------------------------
  def draw_states
    w3 = contents.width / 3
    x = w3 + 1
    x2 = 2*w3
    self.contents.draw_text(x, 5*32, w3, 32, "Strong States")
    draw_state(x, 6*32, w3, 32, 1)
    draw_state(x, 7*32, w3, 32, 2)
    draw_state(x, 8*32, w3, 32, 3)
    self.contents.draw_text(x2, 5*32, w3, 32, "Weak States")
    draw_state(x2, 6*32, w3, 32, 4)
    draw_state(x2, 7*32, w3, 32, 5)
    draw_state(x2, 8*32, w3, 32, 6)
  end
end
