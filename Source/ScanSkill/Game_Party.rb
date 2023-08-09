#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Add one new concept to the Game_Party class
#    @scan_list
#      This is a list of enemy IDs that have been scanned by the party.
#      This list is used by the beastiary to show only scanned enemies.
#==============================================================================
class Game_Party
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor  :scan_list  # ID array of scanned enemies
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias mobius_ctb_initialize initialize
  def initialize
    mobius_ctb_initialize
    @scan_list = [1,2,3]
  end

end
