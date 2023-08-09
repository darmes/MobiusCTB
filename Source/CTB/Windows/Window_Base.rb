#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  Adds three utility functions to Window_Base
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Draws a bitmap centered in a rect
  #     bitmap : bitmap to draw
  #     rect   : rectangle to center bitmap in
  #--------------------------------------------------------------------------
  def draw_bitmap_centered(bitmap, rect)
    draw_x = ( (rect.width - bitmap.width) / 2 ) + rect.x
    draw_y = ( (rect.height - bitmap.height) / 2 ) + rect.y
    self.contents.blt(draw_x, draw_y, bitmap, bitmap.rect)
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Name - Adds width parameter
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : text width for the name (defaults to 120)
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y, width = 120)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width, 32, actor.name)
  end
  #--------------------------------------------------------------------------
  # * Draw Icon
  #     icon_name : filename of the icon ("String")
  #     x         : draw spot x-coordinate
  #     y         : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_icon(icon_name, x, y)
    bitmap = RPG::Cache.icon(icon_name)
    src_rect = Rect.new(0, 0, 24, 24)
    self.contents.blt(x, y, bitmap, src_rect)
  end

end
