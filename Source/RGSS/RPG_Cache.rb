#==============================================================================
# ** RPG::Cache changes
#==============================================================================
module RPG::Cache
  #--------------------------------------------------------------------------
  # * Status icon loading from cache
  #--------------------------------------------------------------------------
  def self.status_icon(filename)
    path = Mobius::Status_Icons::STATUS_ICON_PATH
    self.load_bitmap(path, filename)
  end
  #--------------------------------------------------------------------------
  # * Beastiary sprite loading from cache
  #--------------------------------------------------------------------------

  def self.beastiary_sprite(filename)
    path = Mobius::Beastiary::BEASTIARY_SPRITE_PATH
    self.load_bitmap(path, filename)
  end
end
#=============================RGSS CHANGES END=================================
