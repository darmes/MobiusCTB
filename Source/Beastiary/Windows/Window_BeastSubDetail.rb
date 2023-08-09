#==============================================================================
# ** Window_BeastSubDetail
#------------------------------------------------------------------------------
#  This window allows for separate scrolling of beast details
#==============================================================================
class Window_BeastSubDetail < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #  type - 1, 2, 3 --> 1=stats, 2=elements, 3=states
  #--------------------------------------------------------------------------
  def initialize(enemy, in_battle, type)
    # Configuration values - change these two to configure the three windows
    padding = 4
    overlap = 29
    # Calculated values - derived from above two
    w = (640 + (2 * overlap) - (2 * padding)) / 3    # Window Width
    h = 320 - 32                                     # Window Height
    x1 = padding                                     # Stat Window x-coordinate
    x2 = padding + w - overlap                       # Element Window x-coordinate
    x3 = padding + (2 * w) - (2 * overlap)           # State Window x-coordinate
    if in_battle
      y = 4 + 32                                   # All Window y-coordinate
    else
      y = 4 + 160 + 32                             # All Window y-coordinate
    end
    case type
    when 1 ; x = x1
    when 2 ; x = x2
    when 3 ; x = x3
    end
    # Use calculated values to create window
    super(x, y, w, h)
    # Initialize variables
    @enemy = enemy
    @in_battle = in_battle
    @type = type
    @index = 0
    @item_max = 0
    self.active = false
    self.opacity = 0
    self.back_opacity = 0
    self.contents = Bitmap.new(w - 32, h - 32)
    refresh
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    # dispose contents
    if self.contents != nil
      self.contents.dispose
    end
    # reset index
    self.index = 0
    # reset number of items
    @item_max = 0
    unless @enemy == nil
      case @type
      when 1 ; draw_stats
      when 2 ; draw_elements
      when 3 ; draw_states
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Set Enemy - Calls refresh as needed
  #--------------------------------------------------------------------------
  def enemy=(enemy)
    if @enemy != enemy
      @enemy = enemy
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Stats - draws an enemy's stats
  #--------------------------------------------------------------------------
  def draw_stats
    # configuration
    padding = 2
    @item_max = 10
    # create bitmap
    self.contents = Bitmap.new(width - 32, @item_max * 32)
    w = self.contents.width - (2 * padding)
    # draw all stats
    for i in 0..9
      draw_enemy_parameter(@enemy, padding, i * 32, w, 32, i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Parameter
  #     enemy : enemy
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     w     : draw spot width
  #     h     : draw spot height
  #     type  : parameter type (0-9)
  #--------------------------------------------------------------------------
  def draw_enemy_parameter(enemy, x, y, w, h, type)
    case type
    when 0
      parameter_name = $data_system.words.hp
      parameter_value = enemy.maxhp
    when 1
      parameter_name = $data_system.words.sp
      parameter_value = enemy.maxsp
    when 2
      parameter_name = $data_system.words.atk
      parameter_value = enemy.atk
    when 3
      parameter_name = $data_system.words.pdef
      parameter_value = enemy.pdef
    when 4
      parameter_name = $data_system.words.mdef
      parameter_value = enemy.mdef
    when 5
      parameter_name = $data_system.words.str
      parameter_value = enemy.str
    when 6
      parameter_name = $data_system.words.dex
      parameter_value = enemy.dex
    when 7
      parameter_name = $data_system.words.agi
      parameter_value = enemy.agi
    when 8
      parameter_name = $data_system.words.int
      parameter_value = enemy.int
    when 9
      parameter_name = Mobius::Beastiary::EVASION_WORD
      parameter_value = enemy.eva
    end
    # draw stat name
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, w, h, parameter_name)
    # draw stat value
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, w, h, parameter_value.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Elements - draws an enemy's elemental strengths/weaknesses
  #--------------------------------------------------------------------------
  def draw_elements
    # configuration
    padding = 2
    @item_max = $data_system.elements.size - 1
    # create bitmap
    self.contents = Bitmap.new(width - 32, @item_max * 32)
    # draw all elements
    for i in 1...$data_system.elements.size
      draw_element(padding, (i - 1) * 32, width - 32 - (2 * padding), 32, i)
    end
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
    # get element name
    name = $data_system.elements[element_id]
    # draw name
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, w, h, name, 0)
    # get element rank
    element_rank = element_rank_decode(@enemy.element_ranks[element_id])
    # draw element rank
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, w, h, element_rank, 2)
  end
  #--------------------------------------------------------------------------
  # * Element Rank Decode - converts integer to string based on customization
  #--------------------------------------------------------------------------
  def element_rank_decode(element_rank)
    case element_rank
    when 1 # Very Weak = 200%
      return Mobius::Beastiary::ELEMENT_WORD_200
    when 2 # Weak = 150%
      return Mobius::Beastiary::ELEMENT_WORD_150
    when 3 # Normal = 100%
      return Mobius::Beastiary::ELEMENT_WORD_100
    when 4 # Resistant = 50%
      return Mobius::Beastiary::ELEMENT_WORD_50
    when 5 # Immune = 0%
      return Mobius::Beastiary::ELEMENT_WORD_0
    when 6 # Absorb = -100%
      return Mobius::Beastiary::ELEMENT_WORD_M100
    end
  end
  #--------------------------------------------------------------------------
  # * Draw States - draws an enemy's status strengths/weaknesses
  #--------------------------------------------------------------------------
  def draw_states
    # configuration
    padding = 2
    @item_max = $data_states.size - 1
    # create bitmap
    self.contents = Bitmap.new(width - 32, @item_max * 32)
    # draw all states
    for i in 1...$data_states.size
      draw_state(padding, (i - 1) * 32, width - 32 - (2 * padding), 32, i)
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
    # get state rank
    state_rank = state_rank_decode(@enemy.state_ranks[state_id])
    # draw state name
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, w, h, state_rank, 2)
  end
  #--------------------------------------------------------------------------
  # * State Rank Decode - converts integer to string based on customization
  #--------------------------------------------------------------------------
  def state_rank_decode(state_rank)
    case state_rank
    when 1 # Very Weak = 100%
      return Mobius::Beastiary::STATUS_WORD_100
    when 2 # Weak = 80%
      return Mobius::Beastiary::STATUS_WORD_80
    when 3 # Normal = 60%
      return Mobius::Beastiary::STATUS_WORD_60
    when 4 # Resistant = 40%
      return Mobius::Beastiary::STATUS_WORD_40
    when 5 # Very Resistant = 20%
      return Mobius::Beastiary::STATUS_WORD_20
    when 6 # Immune = 0%
      return Mobius::Beastiary::STATUS_WORD_0
    end
  end
end
