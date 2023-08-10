#==============================================================================
# ** Window_BeastMode
#------------------------------------------------------------------------------
#  This window allows changing what's displayed in the beastiary
#  like the beast's sprite, stats, elements, or status affinities
#==============================================================================
class Window_BeastMode < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    # called in super @item_max = 1
    # called in super @column_max = 1
    # called in super @index = -1
    super(0, 480 - 64, 640, 64)
    @data = [
      Mobius::Beastiary::SPRITE_PAGE,
      Mobius::Beastiary::STATS_PAGE,
      Mobius::Beastiary::ELEMENT_PAGE,
      Mobius::Beastiary::STATUS_PAGE,
    ]
    @item_max = @data.size
    @column_max = 4
    self.contents = Bitmap.new(width - 32, row_max * 32)
    refresh
    self.visible = true
    self.active = true
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    text = @data[index]
    x = 4 + index % @column_max * ( width / @column_max)
    y = index / @column_max * 32
    self.contents.draw_text(x, y, ( width / @column_max), 32, text)
  end
  
end
