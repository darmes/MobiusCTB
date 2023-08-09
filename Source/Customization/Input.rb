#==============================================================================
# ** INPUT SETTINGS
#------------------------------------------------------------------------------
# This section lets you customize input control settings.
#==============================================================================
module Input
  # The battle system has a few additional windows that can be opened/closed/controlled
  # during battle, and therefore need their own buttons. You can customize what
  # those buttons are here. Remember these are not keys on the keyboard but the
  # built-in "buttons". If you press F1 while playing, you can change what keyboard
  # key is linked to what "button". Valid options are A, R, L, X, Y, or Z.
  # The options should be entered with formatting (like they are below).
  BATTLE_STATUS_ACCESS_BUTTON = A
  BEASTIARY_BATTLE_ACCESS_BUTTON = A
  TURN_WINDOW_DRAW_DOWN_BUTTON = R
  TURN_WINDOW_DRAW_UP_BUTTON = L
end
