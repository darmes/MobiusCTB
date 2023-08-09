#==============================================================================
# ** Arrow_All_Actor
#------------------------------------------------------------------------------
#  This class creates and manages arrow cursors to choose all actors.
#==============================================================================
class Arrow_All_Actor < Arrow_All_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    make_actor_list
    make_helper_arrows
  end
  #--------------------------------------------------------------------------
  # * Make Actor List
  #--------------------------------------------------------------------------
  def make_actor_list
    for actor in $game_party.actors
      @battlers.push(actor) if actor.exist?
    end
  end
end
