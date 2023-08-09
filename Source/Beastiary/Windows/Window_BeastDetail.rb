#==============================================================================
# ** Window_BeastDetail
#------------------------------------------------------------------------------
#  This window displays detailed information on scanned beasts
#==============================================================================
class Window_BeastDetail < Window_Base
  #--------------------------------------------------------------------------
  # * Public Attributes
  #--------------------------------------------------------------------------
  attr_accessor  :selected
  #--------------------------------------------------------------------------
  # * Object Initialization
  #   - Enemy is an RPG:Enemy or a Game_Enemy
  #--------------------------------------------------------------------------
  def initialize(enemy = nil, in_battle = false)
    @sub_windows = []
    @enemy = enemy
    @in_battle = in_battle
    @sub_window_index = 0
    make_sub_windows
    if in_battle
      super(0, 0, 640, 320)
      self.z = 98
      self.back_opacity = 240
      self.visible = false
      @selected = true
    else
      super(0, 160, 640, 320)
      self.visible = true
      @selected = false
    end
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Make Sub Windows - Creates the three sub windows
  #--------------------------------------------------------------------------
  def make_sub_windows
    # Create Windows
    for i in 1..3
      @sub_windows.push(Window_BeastSubDetail.new(@enemy, @in_battle, i))
    end
    # If already selected, activate first window
    if @selected
      @sub_windows[@sub_window_index].active = true
    end
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    super
    # Update each sub window
    @sub_windows.each {|window| window.update}
    # Input handling
    if @selected
      # Move focus left
      if Input.trigger?(Input::LEFT)
        @sub_windows[@sub_window_index].active = false
        @sub_window_index = (@sub_window_index - 1) % 3
        @sub_windows[@sub_window_index].active = true
      end
      # Move focus right
      if Input.trigger?(Input::RIGHT)
        @sub_windows[@sub_window_index].active = false
        @sub_window_index = (@sub_window_index + 1) % 3
        @sub_windows[@sub_window_index].active = true
      end
    end
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    # Erase contents
    if self.contents != nil
      self.contents.dispose
    end
    return if @enemy == nil
    # Create empty contents
    self.contents = Bitmap.new(width - 32, height - 32)
    # Get color
    color = Mobius::Beastiary::DIVIDER_LINE_COLOR
    # Draw name
    self.contents.draw_text(0, 0, contents.width, 32, @enemy.name, 1)
    # Draw header line
    self.contents.fill_rect(0, 32, contents.width, 1, color)
    # Draw divider lines
    self.contents.fill_rect(203, 32 + 4, 1, 288, color)
    self.contents.fill_rect(404, 32 + 4, 1, 288, color)
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @sub_windows.each {|window| window.dispose}
  end
  #--------------------------------------------------------------------------
  # * Set Enemy - Calls refresh as needed
  #--------------------------------------------------------------------------
  def enemy=(enemy)
    if @enemy != enemy
      @enemy = enemy
      @sub_windows.each {|window| window.enemy = enemy}
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Set selected - Selects this window, thereby activating/deactivating sub windows
  #--------------------------------------------------------------------------
  def selected=(boolean)
    if @selected == boolean
      @sub_windows[@sub_window_index].active = true
    else
      @sub_windows.each {|window| window.active = false}
    end
  end
  #--------------------------------------------------------------------------
  # * Set visible - Changes visibility for self and sub windows
  #--------------------------------------------------------------------------
  alias old_visible= visible=
  def visible=(boolean)
    self.old_visible = boolean
    @sub_windows.each {|window| window.visible = boolean}
  end
end
