#==============================================================================
# ** Window_TurnOrder
#------------------------------------------------------------------------------
#  This window displays the current turn order during battle
#  The window can be scrolled during the command phase
#==============================================================================
class Window_TurnOrder < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    super(640 - 64, 0, 64, 320) # right justified
    self.contents = Bitmap.new(width - 32, (16 * 48)) # 16 battlers tall
    self.back_opacity = 160
    @current_battlers = []
    @turn_order = []
    @first_draw_index = 0
    @drawing_down = false
    @drawing_up = false
    @wait_count = 0
    @actor_index = -1
    @enemy_index = -1
    self.visible = true
    self.z = 100
    update
    refresh
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update(current_battlers = @current_battlers, index = @actor_index)
    @wait_count -= 1 if @wait_count > 0
    if @current_battlers != current_battlers
      @current_battlers = current_battlers
      refresh
    end
    if @actor_index != index
      @actor_index = index
      if index == 3 # If current battler is Actor 4
        self.x = 0
      else
        self.x = 640 - 64
      end
    end
    make_turn_order
    if @drawing_down
      if self.oy == (@first_draw_index * 48)
        @drawing_down = false
      else
        self.oy += 12
      end
      return
    end
    if @drawing_up
      if self.oy == (@first_draw_index * 48)
        @drawing_up = false
      else
        self.oy -= 12
      end
      return
    end
    if Input.repeat?(Input::TURN_WINDOW_DRAW_DOWN_BUTTON)
      shift_draw_down
    end
    if Input.repeat?(Input::TURN_WINDOW_DRAW_UP_BUTTON)
      shift_draw_up
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(current_battlers = @current_battlers, index = @actor_index)
    self.contents.clear
    draw_turn_order
  end
  #--------------------------------------------------------------------------
  # * Make Turn Order
  #--------------------------------------------------------------------------
  def make_turn_order(current_battlers = @current_battlers)
    if current_battlers != [] and current_battlers != nil
      #initialize dummy gauges
      for battler in current_battlers
        battler.dummy_charge_copy
      end
      #initialize turn order
      turn_order_temp = []
      until turn_order_temp.size >= 16
        #charge dummy gauges
        until dummy_battler_charged?
          for battler in current_battlers
          battler.dummy_charge
          end
        end
        #get the fastest one
        fastest = current_battlers.max \
        {|a,b| a.charge_gauge_dummy <=> b.charge_gauge_dummy }
        #add the fastest to the turn order
        turn_order_temp.push(fastest)
        #reset the fastest
        fastest.dummy_charge_reset
      end
      #compare with set turn order
      unless @turn_order == turn_order_temp
        @turn_order = turn_order_temp
        refresh
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Dummy Battler Charged
  #--------------------------------------------------------------------------
  def dummy_battler_charged?
    for battler in @current_battlers
      return true if battler.charge_gauge_dummy >= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Draw Turn Order -- Draws all icons
  #--------------------------------------------------------------------------
  def draw_turn_order
    if @turn_order != []
      for i in 0...@turn_order.size
        battler = @turn_order[i]
        if battler.is_a?(Game_Enemy)
          draw_enemy_graphic(battler, 0, i * 48)
        elsif battler.is_a?(Game_Actor)
          draw_actor_graphic(battler, 0, i * 48)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Shift Draw Up
  #--------------------------------------------------------------------------
  def shift_draw_up
    if @first_draw_index == 0
      if @wait_count <= 0
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        @wait_count = 12
      end
      return #do nothing
    else
      @first_draw_index -= 1
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      #refresh
      @drawing_up = true
    end
  end
  #--------------------------------------------------------------------------
  # * Shift Draw Down
  #--------------------------------------------------------------------------
  def shift_draw_down
    if @first_draw_index == 10
      if @wait_count <= 0
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        @wait_count = 12
      end
      return #do nothing
    else
      @first_draw_index += 1
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      #refresh
      @drawing_down = true
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Graphic
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    if Mobius::Charge_Turn_Battle::USE_ACTOR_PICTURES
      actor_picture_name = actor.name + Mobius::Charge_Turn_Battle::ACTOR_PICTURES_SUFFIX
      bitmap = RPG::Cache.picture(actor_picture_name)
      cw = bitmap.width / 2
      ch = bitmap.height / 2
    else
      bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
      cw = bitmap.width / 4 / 2
      ch = bitmap.height / 4 / 2
    end
    src_rect = Rect.new(cw - 16, ch - 24, 32, 48)
    self.contents.blt(x, y, bitmap, src_rect)
    return
    # If filename can't be found
  rescue Errno::ENOENT
    rect = Rect.new(x, y, 32, 48)
    self.contents.fill_rect(rect, Mobius::Charge_Turn_Battle::MISSING_GRAPHIC_COLOR)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Graphic
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_enemy_graphic(enemy, x, y)
    if Mobius::Charge_Turn_Battle::USE_ENEMY_PICTURES
      enemy_picture_name = enemy.base_name + Mobius::Charge_Turn_Battle::ENEMY_PICTURES_SUFFIX
      bitmap = RPG::Cache.picture(enemy_picture_name)
      cw = bitmap.width / 2
      ch = bitmap.height / 2
    else
      if enemy.boss
        bitmap = RPG::Cache.picture("EnemyBoss")
      else
        bitmap = RPG::Cache.picture(sprintf("Enemy%01d", enemy.index + 1))
      end
      cw = bitmap.width / 2
      ch = bitmap.height / 2
    end
    src_rect = Rect.new(cw - 16, ch - 24, 32, 48)
    self.contents.blt(x, y, bitmap, src_rect)
    return
  # If filename can't be found
  rescue Errno::ENOENT
    rect = Rect.new(x, y, 32, 48)
    self.contents.fill_rect(rect, Mobius::Charge_Turn_Battle::MISSING_GRAPHIC_COLOR)
  end
end
