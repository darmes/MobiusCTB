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
    self.contents.draw_text(4, 0, w3, 32, @enemy.name)
    # Draw header line
    self.contents.fill_rect(0, 32, w3, 1, color)
    # Draw divider lines
    self.contents.fill_rect(w3, 0, 1, 320 - 32, color)
    self.contents.fill_rect(w3, (5 * 32), (2 * w3), 1, color)
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
    padding = 4
    height = 32
    width = contents.width / 3
    offset = width + 4
    for i in 0..9
      x = i % column_max * (width + padding) + offset
      y = i / column_max * height
      draw_enemy_parameter(x, y, width - (2 * padding), height, i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw top/bottom elements
  #--------------------------------------------------------------------------
  def draw_elements
    padding = 4
    w3 = contents.width / 3
    width = w3 - padding
    height = 32
    self.contents.font.color = system_color
    self.contents.draw_text(0, 32, width, height, "Strong Elements", 1)
    strong = strong_elements()
    draw_element(0, 2*32, width, height, strong[0]) if strong[0]
    draw_element(0, 3*32, width, height, strong[1]) if strong[1]
    draw_element(0, 4*32, width, height, strong[2]) if strong[2]
    self.contents.font.color = system_color
    self.contents.draw_text(0, 5*32, width, height, "Weak Elements", 1)
    weak = weak_elements()
    draw_element(0, 6*32, width, height, weak[0]) if weak[0]
    draw_element(0, 7*32, width, height, weak[1]) if weak[1]
    draw_element(0, 8*32, width, height, weak[2]) if weak[2]
  end
  #--------------------------------------------------------------------------
  # * Draw top/bottom states
  #--------------------------------------------------------------------------
  def draw_states
    padding = 4
    w3 = contents.width / 3
    width = w3 - padding
    height = 32
    x = w3 + padding
    x2 = (2 * w3) + padding
    self.contents.font.color = system_color
    self.contents.draw_text(x, 5*32, width, height, "Strong States", 1)
    strong = strong_states()
    draw_state(x, 6*32, width, height, strong[0]) if strong[0]
    draw_state(x, 7*32, width, height, strong[1]) if strong[1]
    draw_state(x, 8*32, width, height, strong[2]) if strong[2]
    self.contents.font.color = system_color
    self.contents.draw_text(x2, 5*32, w3, height, "Weak States", 1)
    weak = weak_states()
    draw_state(x2, 6*32, width, height, weak[0]) if weak[0]
    draw_state(x2, 7*32, width, height, weak[1]) if weak[1]
    draw_state(x2, 8*32, width, height, weak[2]) if weak[2]
  end
  #--------------------------------------------------------------------------
  # * Get a set of IDs while applying a filter
  #--------------------------------------------------------------------------
  def filter(original)
    copy = original.dup
    yield(copy)
    return copy
  end
  #--------------------------------------------------------------------------
  # * Get the enemies strong elements filtering out hidden elements
  #--------------------------------------------------------------------------
  def strong_elements
    return filter(@enemy.strong_elements) {|arr| filter_elements(arr)}
  end
  #--------------------------------------------------------------------------
  # * Get the enemies weak elements filtering out hidden elements
  #--------------------------------------------------------------------------
  def weak_elements
    return filter(@enemy.weak_elements) {|arr| filter_elements(arr)}
  end
  #--------------------------------------------------------------------------
  # * Get the enemies strong states filtering out hidden elements
  #--------------------------------------------------------------------------
  def strong_states
    return filter(@enemy.strong_states) {|arr| filter_states(arr)}
  end
  #--------------------------------------------------------------------------
  # * Get the enemies weak states filtering out hidden elements
  #--------------------------------------------------------------------------
  def weak_states
    return filter(@enemy.weak_states) {|arr| filter_states(arr)}
  end
  
end
