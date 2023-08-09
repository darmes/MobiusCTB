#==============================================================================
# ** Window_BeastStates
#------------------------------------------------------------------------------
#  This window displays the status affinities of the selected beast
#==============================================================================
class Window_BeastStates < Window_BeastInformation
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super()
    # The $data_states starts at index 1 and has an empty entry in the 0 position
    # What we're doing here is creating an array of state IDs from the base system
    # and then removing IDs that we want to hide in the beastiary
    num_of_states = $data_states.size - 1
    @state_ids = (1..num_of_states).to_a
    Mobius::Beastiary::HIDDEN_STATES.each do |id|
      @state_ids.delete(id)
    end
    @state_ids.delete_if do |id|
      $data_states[id].rating < 1
    end
    # Create a bitmap big enough to hold all the elements
    self.contents = Bitmap.new(width - 32, @state_ids.size * 32)
    # If the bitmap is bigger than the window's display height (h-32),
    # Than enable automatic scrolling by setting @max_oy > 0
    @max_oy = self.contents.height - (self.height - 32)
    @wait_count = 80
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Clear contents
    self.contents.clear
    padding = 0
    height = 32
    width = self.contents.width - padding
    # draw all elements
    for i in 0...@state_ids.size
      draw_state(padding, i * height, width, height, @state_ids[i])
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
      state_rank = state_rank_decode(@enemy.state_ranks[state_id])
      self.contents.draw_text(x, y, w, h, state_rank, 2)
    else
      self.contents.draw_text(x, y, w, h, "???", 2)
    end
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
