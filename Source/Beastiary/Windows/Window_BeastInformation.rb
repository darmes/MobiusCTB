#==============================================================================
# ** Window_BeastInformation
#------------------------------------------------------------------------------
#  This window serves as a base class for all the beast information windows
#==============================================================================
class Window_BeastInformation < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(222, 0, 416, 416)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.visible = false
    @enemy = nil
    @max_oy = 0
    @wait_count = 0
  end
  #--------------------------------------------------------------------------
  # * Update - Scroll the page
  #--------------------------------------------------------------------------
  def update
    super
    if (@wait_count > 0)
      @wait_count -= 1
      return
    end
    if (self.oy < (@max_oy - 1))
      self.oy += 1
    elsif (self.oy < @max_oy)
      @wait_count = 80
      self.oy += 1
    else
      @wait_count = 80
      self.oy = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Set Enemy - Calls refresh as needed
  #--------------------------------------------------------------------------
  def enemy=(new_enemy)
    if @enemy != new_enemy
      @enemy = new_enemy
      refresh
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
      parameter_value = @enemy ? @enemy.maxhp : "???"
    when 1
      parameter_name = $data_system.words.sp
      parameter_value = @enemy ? @enemy.maxsp : "???"
    when 2
      parameter_name = $data_system.words.pdef
      parameter_value = @enemy ? @enemy.pdef : "???"
    when 3
      parameter_name = $data_system.words.mdef
      parameter_value = @enemy ? @enemy.mdef : "???"
    when 4
      parameter_name = $data_system.words.atk
      parameter_value = @enemy ? @enemy.atk : "???"
    when 5
      parameter_name = $data_system.words.str
      parameter_value = @enemy ? @enemy.str : "???"
    when 6
      parameter_name = $data_system.words.dex
      parameter_value = @enemy ? @enemy.dex : "???"
    when 7
      parameter_name = $data_system.words.agi
      parameter_value = @enemy ? @enemy.agi : "???"
    when 8
      parameter_name = $data_system.words.int
      parameter_value = @enemy ? @enemy.int : "???"
    when 9
      parameter_name = Mobius::Beastiary::EVASION_WORD
      parameter_value = @enemy ? @enemy.eva : "???"
    end
    # draw stat name
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, w, h, parameter_name)
    # draw stat value
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, w, h, parameter_value.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Element
  #     x           : draw spot x-coordinate
  #     y           : draw spot y-coordinate
  #     w           : draw spot width
  #     h           : draw spot height
  #     element_id  : element_id corresponds to database value
  #--------------------------------------------------------------------------
  def draw_element(x, y, w, h, element_id)
    # draw name
    name = $data_system.elements[element_id]
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, w, h, name, 0)
    # draw element rank
    self.contents.font.color = normal_color
    if @enemy
      element_efficiency = @enemy.element_efficiency(element_id)
      self.contents.draw_text(x, y, w, h, element_efficiency, 2)
    else
      self.contents.draw_text(x, y, w, h, "???", 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw State
  #     x           : draw spot x-coordinate
  #     y           : draw spot y-coordinate
  #     w           : draw spot width
  #     h           : draw spot height
  #     state_id    : state_id corresponds to database value
  #--------------------------------------------------------------------------
  def draw_state(x, y, w, h, state_id)
    # get name
    name = $data_states[state_id].name
    # draw name
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, w, h, name, 0)
    # draw state rank
    self.contents.font.color = normal_color
    if @enemy
      state_efficiency = @enemy.state_efficiency(state_id)
      self.contents.draw_text(x, y, w, h, state_efficiency, 2)
    else
      self.contents.draw_text(x, y, w, h, "???", 2)
    end
  end
end
