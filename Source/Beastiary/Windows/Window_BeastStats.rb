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
    super
    unless @enemy == nil
      column_max = 2
      padding = 8
      height = 32
      width = self.contents.width / column_max
      # Draw all stats
      for i in 0..9
        x = i % column_max * (width + padding)
        y = i / column_max * height
        draw_enemy_parameter(x, y, width - padding, height, i)
      end
      # Get color
      color = Mobius::Beastiary::DIVIDER_LINE_COLOR
      # Draw separating line
      self.contents.fill_rect(0, 168, contents.width, 1, color)
      # Draw bio
      draw_bio
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Parameter
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     w     : draw spot width
  #     h     : draw spot height
  #     type  : parameter type (0-9)
  #--------------------------------------------------------------------------
  def draw_enemy_parameter(x, y, w, h, type)
    case type
    when 0
      parameter_name = $data_system.words.hp
      parameter_value = @enemy.maxhp
    when 1
      parameter_name = $data_system.words.sp
      parameter_value = @enemy.maxsp
    when 2
      parameter_name = $data_system.words.pdef
      parameter_value = @enemy.pdef
    when 3
      parameter_name = $data_system.words.mdef
      parameter_value = @enemy.mdef
    when 4
      parameter_name = $data_system.words.atk
      parameter_value = @enemy.atk
    when 5
      parameter_name = $data_system.words.str
      parameter_value = @enemy.str
    when 6
      parameter_name = $data_system.words.dex
      parameter_value = @enemy.dex
    when 7
      parameter_name = $data_system.words.agi
      parameter_value = @enemy.agi
    when 8
      parameter_name = $data_system.words.int
      parameter_value = @enemy.int
    when 9
      parameter_name = Mobius::Beastiary::EVASION_WORD
      parameter_value = @enemy.eva
    end
    # draw stat name
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, w, h, parameter_name)
    # draw stat value
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, w, h, parameter_value.to_s, 2)
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
end
