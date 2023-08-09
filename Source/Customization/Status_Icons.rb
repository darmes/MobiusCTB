#==============================================================================
# ** STATUS_ICONS SETTINGS
#------------------------------------------------------------------------------
# The following settings are all optional, and are only used with the expansions
# to the core script.
#==============================================================================
module Mobius
  module Status_Icons
    #==============================================================================
    # The STATUS_ICONS expansion will display icons in the status area for users
    # and enemies during battle rather than the default plain text. The icons can
    # be any size, but 24x24 is optimal. Anything taller than 32 pixels will have
    # parts of the top and bottom cutoff as it will center the icon. With a width
    # of 24 pixels, you should be able to fit five icons. Additionally, the states
    # will be displayed with the normal priority set by the database and states with
    # a priority of zero will not be displayed.
    # To enable the "status icons" expansion, set STATUS_ICONS below to "true"
    #==============================================================================
    # Set this option to "true" to enable this expansion
    STATUS_ICONS_ENABLED = false
    # If you've set the above to true, then you need to place an icon for each status in
    # the "Icons" folder by default but this can be changed if desired.
    # The names for each icon should be "StatusNameStatusSuffix"
    # You can set the suffix below. The default is "_Status_Icon". So "Blind" icon
    # would need to be named "Blind_Status_Icon". The icons can be any supported image
    # format (i.e. png, jpg, etc). Keep in mind that only 24x24 (width x height) pixels will be shown.
    STATUS_ICON_SUFFIX = "_Status_Icon"
    # Here you can set the path to the status icons. Note that it is local to the project folder.
    STATUS_ICON_PATH = "Graphics/Icons/"
  end
end
