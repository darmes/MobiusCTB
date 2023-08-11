#==============================================================================
# ** Window_BeastElements
#------------------------------------------------------------------------------
#  This window displays the elemental affinities of the selected beast
#==============================================================================
class Window_BeastElements < Window_BeastInformation
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super()
    # The $data_system.elements starts at index 1 and has an empty entry in the 0 position
    # What we're doing here is creating an array of element IDs from the base system
    # and then removing IDs that we want to hide in the beastiary
    num_of_elements = $data_system.elements.size - 1
    @element_ids = (1..num_of_elements).to_a
    filter_elements(@element_ids)
    # Create a bitmap big enough to hold all the elements
    self.contents = Bitmap.new(width - 32, @element_ids.size * 32)
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
    # draw all elements
    padding = 0
    height = 32
    width = self.contents.width - padding
    for i in 0...@element_ids.size
      draw_element(padding, i * height, width, height, @element_ids[i])
    end
  end
end
