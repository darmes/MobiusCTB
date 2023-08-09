#==============================================================================
# ** Arrow_All_Base
#------------------------------------------------------------------------------
#  This class creates and manages arrow cursors to choose multiple battlers
#==============================================================================
class Arrow_All_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :help_window              # help window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #--------------------------------------------------------------------------
  def initialize(viewport)
    @viewport = viewport
    @help_window = nil
    @battlers = []
    @arrows = []
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Set sprite coordinates
    unless @battlers == [] or @battlers == nil
      for arrow in @arrows
        arrow.update
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Make Helper Arrows
  #--------------------------------------------------------------------------
  def make_helper_arrows
    for i in 0...@battlers.size
      @arrows.push(Arrow_Base.new(@viewport))
      arrow = @arrows[i]
      battler = @battlers[i]
      arrow.x = battler.screen_x
      arrow.y = battler.screen_y
    end
  end
  #--------------------------------------------------------------------------
  # * Set Help Window
  #     help_window : new help window
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    if @help_window != nil
      update_help
    end
  end
  #--------------------------------------------------------------------------
  # * Help Text Update
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text("All", 1)
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    for arrow in @arrows
      arrow.dispose
    end
  end
end
