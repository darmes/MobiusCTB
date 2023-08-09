#==============================================================================
# ** Window_BeastList
#------------------------------------------------------------------------------
#  This window displays a selectable list of beasts
#==============================================================================
class Window_BeastList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    # called in super @item_max = 1
    # called in super @column_max = 1
    # called in super @index = -1
    #super(0, 0, 256, 480)
    super(0, 0, 222, 416)
    # The $data_enemies starts at index 1 and has an empty entry in the 0 position
    num_of_enemies = $data_enemies.size - 1
    @data = $data_enemies.slice(1, num_of_enemies)
    @data.delete_if do |enemy|
      Mobius::Beastiary::HIDDEN_BEASTS.include?(enemy.id)
    end
    @item_max = @data.size
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
  #     color : text color
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = Rect.new(4, 32 * index, self.contents.width - 8, 32)
    enemy = @data[index]
    if Mobius::Beastiary::DISPLAY_ID
      if Mobius::Beastiary::DISPLAY_DATABASE_ID
        enemy_id = enemy.id
      else
        enemy_id = index + 1
      end
      enemy_id_text = ("%03d" % enemy_id) + ": "
    else
      enemy_id_text = ""
    end
    enemy_name = $game_party.scan_list.include?(enemy_id) ? enemy.name : "???"
    text = enemy_id_text + enemy_name
    self.contents.draw_text(rect, text)
  end
  #--------------------------------------------------------------------------
  # * Get Enemy
  #--------------------------------------------------------------------------
  def enemy
    return @data[self.index]
  end

end
