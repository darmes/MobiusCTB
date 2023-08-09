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
    Mobius::Beastiary::HIDDEN_ELEMENTS.each do |id|
      @element_ids.delete(id)
    end
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
    super
    unless @enemy == nil
      padding = 0
      height = 32
      width = self.contents.width - padding
      # draw all elements
      for i in 0...@element_ids.size
        draw_element(padding, i * height, width, height, @element_ids[i])
      end
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
end
