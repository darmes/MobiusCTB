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
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Clear contents
    self.contents.clear
    if @enemy == nil
      w = self.contents.width
      h = self.contents.height
      self.contents.draw_text(0, 0, w, h, "???", 1)
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
end
