#==============================================================================
# ** Window_BeastStats
#------------------------------------------------------------------------------
#  This window displays the stats of the selected beast
#==============================================================================
class Window_BeastStats < Window_BeastInformation
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Clear contents
    self.contents.clear
    # Draw all stats
    column_max = 2
    padding = 8
    height = 32
    width = self.contents.width / column_max
    for i in 0..9
      x = i % column_max * (width + padding)
      y = i / column_max * height
      draw_enemy_parameter(x, y, width - padding, height, i)
    end
    # Draw separating line
    color = Mobius::Beastiary::DIVIDER_LINE_COLOR
    self.contents.fill_rect(0, 168, contents.width, 1, color)
    # Draw bio
    if @enemy
      draw_bio
    else
      draw_empty_bio
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Bio
  #--------------------------------------------------------------------------
  def draw_bio
    bio = Mobius::Beastiary::BIOGRAPHIES[@enemy.id]
    bio.each_with_index  do |line, index|
      y = index * 32 + 176
      self.contents.draw_text(4, y, contents.width, 32, line)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Empty Bio
  #--------------------------------------------------------------------------
  def draw_empty_bio
    self.contents.draw_text(0, 176, contents.width, 224, "???", 1)
  end
end
