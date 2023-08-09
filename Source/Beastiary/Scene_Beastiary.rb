#==============================================================================
# ** Scene_Beastiary
#------------------------------------------------------------------------------
#  This class performs beastiary screen processing.
#==============================================================================
class Scene_Beastiary
  #--------------------------------------------------------------------------
  # * Create Windows
  #--------------------------------------------------------------------------
  def create_windows
    @Window_BeastList = Window_BeastList.new
    @Window_BeastMode = Window_BeastMode.new
    @Window_BeastSprite = Window_BeastSprite.new
    @Window_BeastSprite.visible = true
    @Window_BeastStats = Window_BeastStats.new
    @Window_BeastElements = Window_BeastElements.new
    @Window_BeastStates = Window_BeastStates.new
  end
  #--------------------------------------------------------------------------
  # * Update Windows
  #--------------------------------------------------------------------------
  def update_windows
    @Window_BeastList.update
    @Window_BeastMode.update
    @Window_BeastSprite.update
    @Window_BeastStats.update
    @Window_BeastElements.update
    @Window_BeastStates.update
  end
  #--------------------------------------------------------------------------
  # * Dispose Windows
  #--------------------------------------------------------------------------
  def dispose_windows
    @Window_BeastList.dispose
    @Window_BeastMode.dispose
    @Window_BeastSprite.dispose
    @Window_BeastStats.dispose
    @Window_BeastElements.dispose
    @Window_BeastStates.dispose
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Create windows
    create_windows
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    dispose_windows
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    # Update cursors
    update_windows
    # If the user is selecting a beast
    if @Window_BeastList.active
      update_list
    # If the user is selecting a mode
    else
      update_mode
    end
  end
  #--------------------------------------------------------------------------
  # * Update List
  #--------------------------------------------------------------------------
  def update_list
    enemy = @Window_BeastList.enemy
    # Set enemy in windows if the party has scanned it
    # TODO: Remove the true!
    if true || $game_party.scan_list.include?(enemy.id)
      @Window_BeastSprite.enemy = enemy
      @Window_BeastStats.enemy = enemy
      @Window_BeastElements.enemy = enemy
      @Window_BeastStates.enemy = enemy
    else
      @Window_BeastSprite.enemy = nil
      @Window_BeastStats.enemy = nil
      @Window_BeastElements.enemy = nil
      @Window_BeastStates.enemy = nil
    end
    # When cancel
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # TODO: Make better handling for exit
      $scene = Scene_Menu.new()
    end
    # When enter
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      @Window_BeastMode.active = true
      @Window_BeastList.active = false
    end
  end
  #--------------------------------------------------------------------------
  # * Update Mode
  #--------------------------------------------------------------------------
  def update_mode
    # Hide all mode windows
    @Window_BeastSprite.visible = false
    @Window_BeastStats.visible = false
    @Window_BeastElements.visible = false
    @Window_BeastStates.visible = false
    # Show only selected window
    case @Window_BeastMode.index
    # When Sprite
    when 0
      @Window_BeastSprite.visible = true
    # When Stats
    when 1
      @Window_BeastStats.visible = true
    # When Elements
    when 2
      @Window_BeastElements.visible = true
    # When States
    when 3
      @Window_BeastStates.visible = true
    end
    # When cancel
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      @Window_BeastMode.active = false
      @Window_BeastList.active = true
    end
    # When enter
    if Input.trigger?(Input::C)
      # TODO: Remove if not needed
    end
  end

end
