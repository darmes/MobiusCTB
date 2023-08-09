#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  Overwrites the draw_actor_state method
#==============================================================================
class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Draw State
  #     battler : battler
  #     x       : draw spot x-coordinate
  #     y       : draw spot y-coordinate
  #     width   : draw spot width
  # This version will draw icons for the statuses rather than text
  #--------------------------------------------------------------------------
  def draw_actor_state(battler, x, y, width = 125)
    # create temp array for storing bitmaps
    icon_bitmaps = get_status_icon_bitmaps(battler)
    # draw all bitmaps that fit
    width_sum = 0
    icon_bitmaps.each do |bitmap|
      # draw icon centered in height but as wide as it is
      w = bitmap.width
      ch = bitmap.height / 2
      src_rect = Rect.new(0, ch - 16, w, 32)
      # only draw next icon if it'll fit
      if (width_sum + w) <= width
        self.contents.blt(x + width_sum, y, bitmap, src_rect)
        # add padding of 1 pixel to separate icons
        width_sum += (w + 1)
      else
        break
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Status Icon Bitmaps - Takes a Game_Battler and returns an array of
  #   bitmaps for drawing their current statuses
  #--------------------------------------------------------------------------
  def get_status_icon_bitmaps(battler)
    icon_bitmaps = []
    # for every state ID in battler's states array (which is sorted by priority)
    for id in battler.states
      # if it should be displayed
      if $data_states[id].rating >= 1
        # load icon bitmap
        bitmap = get_status_icon_bitmap(id)
        # store in temp array
        icon_bitmaps.push(bitmap)
      end
    end
    return icon_bitmaps
  end
  #--------------------------------------------------------------------------
  # * Get Status Icon Bitmap - Takes a Game_Battler and returns an array of bitmaps
  #   for drawing their current statuses
  #--------------------------------------------------------------------------
  def get_status_icon_bitmap(id)
    # get associated icon name
    icon_base_name = $data_states[id].name
    # get suffix
    suffix = Mobius::Status_Icons::STATUS_ICON_SUFFIX
    # create filename
    icon_name = icon_base_name + suffix
    # load icon bitmap
    return RPG::Cache.status_icon(icon_name)
    rescue Errno::ENOENT
      rect = Rect.new(0,0,24,24)
      color = Mobius::Charge_Turn_Battle::MISSING_GRAPHIC_COLOR
      bitmap = Bitmap.new(24,24)
      bitmap.fill_rect(rect, color)
      return bitmap
  end

end
