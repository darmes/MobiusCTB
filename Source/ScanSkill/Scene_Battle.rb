#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  Add a public getter for the active battler
#==============================================================================
class Scene_Battle
  # Use $scene.active_battler to get current actor during batttle
  attr_reader :active_battler
end
