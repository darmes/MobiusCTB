#==============================================================================
# ** Window_BeastSprite
#------------------------------------------------------------------------------
#  This window displays the sprite of the selected beast
#==============================================================================
class Window_BeastSprite < Window_BeastInformation
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    super
    unless @enemy == nil
      # Get sprite bitmap
      enemy_bitmap = RPG::Cache.beastiary_sprite(self.get_filename)
      rect = Rect.new(0, 0, contents.width, contents.height)
      # Draw sprite
      draw_bitmap_centered(enemy_bitmap, rect)
    end
    return
  # If filename can't be found, use default battler sprite
  rescue Errno::ENOENT
    enemy_bitmap = RPG::Cache.battler(@enemy.battler_name, @enemy.battler_hue)
    rect = Rect.new(0, 0, contents.width, contents.height)
    draw_bitmap_centered(enemy_bitmap, rect)
  end
  #--------------------------------------------------------------------------
  # * Get Filename - Returns filename for sprite
  #--------------------------------------------------------------------------
  def get_filename
    return @enemy.base_name + Mobius::Beastiary::BEASTIARY_SPRITE_SUFFIX
  end
end
