#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================
class Scene_Battle
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  alias mobius_main main
  def main
    # Initialize each kind of temporary battle data
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # Initialize battle event interpreter
    $game_system.battle_interpreter.setup(nil, 0)
    # Prepare troop
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    # Make actor command window
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    s5 = Mobius::Charge_Turn_Battle::ESCAPE_WORD # Mobius Added
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4, s5])
    @actor_command_window.y = 128
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Make other windows
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    #@help_window.back_opacity = 160
    @help_window.back_opacity = 230
    @help_window.z = 200
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    @turn_order_window = Window_TurnOrder.new #Mobius Added
    all_battlers = [].concat($game_party.actors).concat($game_troop.enemies)
    @big_status_window = Window_BigBattleStatus.new(all_battlers)
    if Mobius::Beastiary::BEASTIARY_ENABLED
      @enemy_detail_window = Window_BeastDetail.new(nil, true) #Mobius Added
    end
    # Make sprite set
    @spriteset = Spriteset_Battle.new
    # Initialize wait count
    @wait_count = 0
    # Execute transition
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # Start pre-battle phase
    start_phase1
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
    # Refresh map
    $game_map.refresh
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    @turn_order_window.dispose # Mobius Added
    @big_status_window.dispose # Mobius
    if Mobius::Beastiary::BEASTIARY_ENABLED
      @enemy_detail_window.dispose # Mobius
    end
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # Dispose of sprite set
    @spriteset.dispose
    # If switching to title screen
    if $scene.is_a?(Scene_Title)
      # Fade out screen
      Graphics.transition
      Graphics.freeze
    end
    # If switching from battle test to any screen other than game over screen
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias mobius_update update
  def update
    if @turn_order_window.visible
      @turn_order_window.update(@current_battlers, @actor_index) # Mobius
    end
    mobius_update
  end
  #--------------------------------------------------------------------------
  # * Start Party Command Phase
  #--------------------------------------------------------------------------
  def start_phase2
    # Shift to phase 2
    @phase = 2
    # Set actor to non-selecting
    @actor_index = -1
    @active_battler = nil
    @action_battlers = []
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Clear main phase flag
    $game_temp.battle_main_phase = false
    # Increase Turn Count
    $game_temp.battle_turn += 1
    # Make new array of current battlers
    @current_battlers = []
    for enemy in $game_troop.enemies
      @current_battlers.push(enemy) if enemy.exist?
    end
    for actor in $game_party.actors
      @current_battlers.push(actor) if actor.exist?
    end
  end
  #--------------------------------------------------------------------------
  # * Battler Charged
  #--------------------------------------------------------------------------
  def battler_charged?
    for battler in @current_battlers
      return true if battler.charge_gauge >= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Frame Update (party command phase)
  #--------------------------------------------------------------------------
  def update_phase2
    # Charge all the battlers until someone gets an active turn
    until battler_charged?
      for battler in @current_battlers
        battler.charge
      end
    end
    # Set the active battler to the fastest
    @active_battler = @current_battlers.max {|a,b| a.charge_gauge <=> b.charge_gauge}
    # Remove appropiate states automatically
    @active_battler.remove_states_auto_start
    # Refresh Battle Status window
    @status_window.refresh
    # branch according to whether it's an enemy or actor
    if @active_battler.is_a?(Game_Enemy)
      @active_battler.make_action
      start_phase4
    else #if it's an actor
      start_phase3
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (party command phase: escape)
  #--------------------------------------------------------------------------
  def update_phase2_escape
    # Calculate enemy agility average
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # Calculate actor agility average
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # Determine if escape is successful
    success = rand(100) < 50 * actors_agi / enemies_agi
    # If escape is successful
    if success
      # Play escape SE
      $game_system.se_play($data_system.escape_se)
      # Return to BGM before battle started
      $game_system.bgm_play($game_temp.map_bgm)
      # Battle ends
      battle_end(1)
    # If escape is failure
    else
      # Start main phase
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Start Actor Command Phase
  #--------------------------------------------------------------------------
  def start_phase3
    # Shift to phase 3
    @phase = 3
    @actor_index = $game_party.actors.index(@active_battler)
    @active_battler.blink = true
    if @active_battler.inputable?
      phase3_setup_command_window
    else
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase)
  #--------------------------------------------------------------------------
  def update_phase3
    # If enemy detail is enabled
    if @enemy_detail_window != nil and @enemy_detail_window.visible
      update_enemy_detail_window
    # If enemy arrow is enabled
    elsif @enemy_arrow != nil
      update_phase3_enemy_select
    # If all enemy arrow is enabled
    elsif @all_enemy_arrow != nil
      update_phase3_all_enemy_select
    # If actor arrow is enabled
    elsif @actor_arrow != nil
      update_phase3_actor_select
    # If all actor arrow is enabled
    elsif @all_actor_arrow != nil
      update_phase3_all_actor_select
    # If skill window is enabled
    elsif @skill_window != nil
      update_phase3_skill_select
    # If item window is enabled
    elsif @item_window != nil
      update_phase3_item_select
    # If turn order window is up
    elsif @big_status_window.visible
      update_big_status_window
    # If actor command window is enabled
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : basic command)
  #--------------------------------------------------------------------------
  def update_phase3_basic_command
    # If shift is pressed
    if Input.trigger?(Input::BATTLE_STATUS_ACCESS_BUTTON)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Start turn order window
      start_big_status_window
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Branch by actor command window cursor position
      case @actor_command_window.index
      when 0  # attack
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        # Start enemy selection
        start_enemy_select
      when 1  # skill
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 1
        # Start skill selection
        start_skill_select
      when 2  # guard
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 1
        # Go to command input for next actor
        start_phase4
      when 3  # item
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 2
        # Start item selection
        start_item_select
      when 4  # escape
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # If it's not possible to escape
        if $game_temp.battle_can_escape == false
          # Play buzzer SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        #Clear current action
        @active_battler.current_action.clear
        # Escape processing
        update_phase2_escape
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : skill selection)
  #--------------------------------------------------------------------------
  def update_phase3_skill_select
    # Make skill window visible
    @skill_window.visible = true
    # Update skill window
    @skill_window.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End skill selection
      end_skill_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Get currently selected data on the skill window
      @skill = @skill_window.skill
      # If it can't be used
      if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.skill_id = @skill.id
      # Make skill window invisible
      @skill_window.visible = false
      # If effect scope is single enemy
      if @skill.scope == 1
        # Start enemy selection
        start_enemy_select
      # If effect scope is all enemy - Mobius
      elsif @skill.scope == 2
        # Start all enemy selection
        start_all_enemy_select
      # If effect scope is single ally
      elsif @skill.scope == 3 or @skill.scope == 5
        # Start actor selection
        start_actor_select
      # If effect scope is all ally - Mobius
      elsif @skill.scope == 4 or @skill.scope == 6
        # Start all actor selection
        start_all_actor_select
      # If effect scope is not single
      else
        # End skill selection
        end_skill_select
        # Go to command input for next actor
        start_phase4
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : item selection)
  #--------------------------------------------------------------------------
  def update_phase3_item_select
    # Make item window visible
    @item_window.visible = true
    # Update item window
    @item_window.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End item selection
      end_item_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Get currently selected data on the item window
      @item = @item_window.item
      # If it can't be used
      unless $game_party.item_can_use?(@item.id)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.item_id = @item.id
      # Make item window invisible
      @item_window.visible = false
      # If effect scope is single enemy
      if @item.scope == 1
        # Start enemy selection
        start_enemy_select
      # If effect scope is all enemy - Mobius
      elsif @item.scope == 2
        # Start all enemy selection
        start_all_enemy_select
      # If effect scope is single ally
      elsif @item.scope == 3 or @item.scope == 5
        # Start actor selection
        start_actor_select
      # If effect scope is all ally - Mobius
      elsif @item.scope == 4 or @item.scope == 6
        # Start all actor selection
        start_all_actor_select
      # If effect scope is not single
      else
        # End item selection
        end_item_select
        # Go to command input for next actor
        start_phase4
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : enemy selection)
  #--------------------------------------------------------------------------
  def update_phase3_enemy_select
    # Update enemy arrow
    @enemy_arrow.update
    # If Beastiary is added
    if Mobius::Beastiary::BEASTIARY_ENABLED
      # If Beastiary access button is pressed
      if Input.trigger?(Input::BEASTIARY_BATTLE_ACCESS_BUTTON)
        # Set enemy
        enemy = @enemy_arrow.enemy
        # If enemy has been scanned
        if enemy.state?(Mobius::Scan_Skill::SCAN_STATE_ID)
          # Play decision SE
          $game_system.se_play($data_system.decision_se)
          # Start enemy detail window
          start_enemy_detail_window(enemy)
          return
        else
          # Play buzzer SE
          $game_system.se_play($data_system.buzzer_se)
        end
      end
    end
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End enemy selection
      end_enemy_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.target_index = @enemy_arrow.index
      # End enemy selection
      end_enemy_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Execute action
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : all enemy selection)
  #--------------------------------------------------------------------------
  def update_phase3_all_enemy_select
    # Update enemy arrow
    @all_enemy_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End enemy selection
      end_all_enemy_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # End enemy selection
      end_all_enemy_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Execute action
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : actor selection)
  #--------------------------------------------------------------------------
  def update_phase3_actor_select
    # Update actor arrow
    @actor_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End actor selection
      end_actor_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.target_index = @actor_arrow.index
      # End actor selection
      end_actor_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Execute action
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : all actor selection)
  #--------------------------------------------------------------------------
  def update_phase3_all_actor_select
    # Update enemy arrow
    @all_actor_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End enemy selection
      end_all_actor_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # End enemy selection
      end_all_actor_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Execute action
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Start Enemy Selection
  #--------------------------------------------------------------------------
  def start_enemy_select
    # Make enemy arrow
    @enemy_arrow = Arrow_Enemy.new(@spriteset.viewport1)
    # Associate help window
    @enemy_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * End Enemy Selection
  #--------------------------------------------------------------------------
  def end_enemy_select
    # Dispose of enemy arrow
    @enemy_arrow.dispose
    @enemy_arrow = nil
    # If command is [fight]
    if @actor_command_window.index == 0
      # Enable actor command window
      @actor_command_window.active = true
      @actor_command_window.visible = true
      @turn_order_window.visible = true
      # Hide help window
      @help_window.visible = false
    end
    # If skill window is showing
    if @skill_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
    # If item window is showing
    if @item_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # * Start All Enemy Selection
  #--------------------------------------------------------------------------
  def start_all_enemy_select
    # Make enemy arrow
    @all_enemy_arrow = Arrow_All_Enemy.new(@spriteset.viewport1)
    # Associate help window
    @all_enemy_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * End All Enemy Selection
  #--------------------------------------------------------------------------
  def end_all_enemy_select
    # Dispose of enemy arrow
    @all_enemy_arrow.dispose
    @all_enemy_arrow = nil
    # If command is [fight]
    if @actor_command_window.index == 0
      # Enable actor command window
      @actor_command_window.active = true
      @actor_command_window.visible = true
      @turn_order_window.visible = true
      # Hide help window
      @help_window.visible = false
    end
    # If skill window is showing
    if @skill_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
    # If item window is showing
    if @item_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # * Start Actor Selection
  #--------------------------------------------------------------------------
  def start_actor_select
    # Make actor arrow
    @actor_arrow = Arrow_Actor.new(@spriteset.viewport2)
    @actor_arrow.index = @actor_index
    # Associate help window
    @actor_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * End Actor Selection
  #--------------------------------------------------------------------------
  def end_actor_select
    # Dispose of actor arrow
    @actor_arrow.dispose
    @actor_arrow = nil
    # If skill window is showing
    if @skill_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
    # If item window is showing
    if @item_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # * Start All Actor Selection
  #--------------------------------------------------------------------------
  def start_all_actor_select
    # Make actor arrow
    @all_actor_arrow = Arrow_All_Actor.new(@spriteset.viewport2)
    # Associate help window
    @all_actor_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * End All Actor Selection
  #--------------------------------------------------------------------------
  def end_all_actor_select
    # Dispose of enemy arrow
    @all_actor_arrow.dispose
    @all_actor_arrow = nil
    # If command is [fight]
    if @actor_command_window.index == 0
      # Enable actor command window
      @actor_command_window.active = true
      @actor_command_window.visible = true
      @turn_order_window.visible = true
      # Hide help window
      @help_window.visible = false
    end
    # If skill window is showing
    if @skill_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
    # If item window is showing
    if @item_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # * Start Skill Selection
  #--------------------------------------------------------------------------
  alias mobius_ctb_start_skill_select start_skill_select
  def start_skill_select
    mobius_ctb_start_skill_select
    @turn_order_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * End Skill Selection
  #--------------------------------------------------------------------------
  alias mobius_ctb_end_skill_select end_skill_select
  def end_skill_select
    mobius_ctb_end_skill_select
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * Start Item Selection
  #--------------------------------------------------------------------------
  alias mobius_ctb_start_item_select start_item_select
  def start_item_select
    mobius_ctb_start_item_select
    @turn_order_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * End Item Selection
  #--------------------------------------------------------------------------
  alias mobius_ctb_end_item_select end_item_select
  def end_item_select
    mobius_ctb_end_item_select
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * Start Big Status Window
  #--------------------------------------------------------------------------
  def start_big_status_window
    @big_status_window.refresh
    @big_status_window.visible = true
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * Update Big Status Window
  #--------------------------------------------------------------------------
  def update_big_status_window
    @big_status_window.update
    if Input.trigger?(Input::A) or Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End Turn Order Window
      end_big_status_window
    end
  end
  #--------------------------------------------------------------------------
  # * End Big Status Window
  #--------------------------------------------------------------------------
  def end_big_status_window
    @big_status_window.visible = false
    @turn_order_window.visible = true
    # Enable actor command window
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * Start Enemy Detail Window
  #--------------------------------------------------------------------------
  def start_enemy_detail_window(enemy)
    # Set enemy detail window's enemy
    @enemy_detail_window.enemy = enemy
    @enemy_detail_window.update
    # Show enemy detail window
    @enemy_detail_window.visible = true
    # Hide turn order window
    @turn_order_window.visible = false
    # Hide help window
    @help_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * Update Enemy Detail Window
  #--------------------------------------------------------------------------
  def update_enemy_detail_window
     @enemy_detail_window.update
     if Input.trigger?(Input::A) or Input.trigger?(Input::B)
       # Play cancel SE
       $game_system.se_play($data_system.cancel_se)
       # End Turn Order Window
       end_enemy_detail_window
     end
  end
  #--------------------------------------------------------------------------
  # * End Enemy Detail Window
  #--------------------------------------------------------------------------
  def end_enemy_detail_window
    # Hide enemy detail window
    @enemy_detail_window.visible = false
    # Show turn order window
    @turn_order_window.visible = true
    # Show help window
    @help_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * Start Main Phase
  #--------------------------------------------------------------------------
  def start_phase4
    # Shift to phase 4
    @phase = 4
    @active_battler.blink = false
    @active_battler.charge_reset
    @action_battlers.push(@active_battler)
    # Enemies won't attack on "turn 0" so I moved the turn count increment
    # to start_phase2 so that enemies can take their first turn
    # $game_temp.battle_turn += 1

    # Search all battle event pages
    for index in 0...$data_troops[@troop_id].pages.size
      # Get event page
      page = $data_troops[@troop_id].pages[index]
      # If this page span is [turn]
      if page.span == 1
        # Clear action completed flags
        $game_temp.battle_event_flags[index] = false
      end
    end
    # Set actor as unselectable
    @actor_index = -1
    @active_battler = nil
    # Disable party command window
    @party_command_window.active = false
    @party_command_window.visible = false
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Set main phase flag
    $game_temp.battle_main_phase = true

    # Make enemy action -- Moved to start_phase2, and only runs one
    # enemy at a time
    #  for enemy in $game_troop.enemies
    #    enemy.make_action
    #  end
    # Make action orders -- Mobius: No longer used
    # make_action_orders

    # Shift to step 1
    @phase4_step = 1
  end
  #--------------------------------------------------------------------------
  # * Make Basic Action Results
  #--------------------------------------------------------------------------
  alias mobius_make_basic_action_result make_basic_action_result
  def make_basic_action_result
    # If guard
    if @active_battler.current_action.basic == 1
      # Display "Guard" in help window
      @help_window.set_text($data_system.words.guard, 1)
      # Return
      return
    end
    # If escape
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      # Display "Escape" in help window
      @help_window.set_text(Mobius::Charge_Turn_Battle::ESCAPE_WORD, 1)
      # Escape
      @active_battler.escape
      return
    end
    mobius_make_basic_action_result
  end

end
