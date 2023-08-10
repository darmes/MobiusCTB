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
  
end
