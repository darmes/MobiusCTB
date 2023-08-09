#==============================================================================
# ** BEASTIARY SETTINGS
#------------------------------------------------------------------------------
# The following settings are all optional, and are only used with the expansions
# to the core script.
#==============================================================================
module Mobius
  module Beastiary
    #==============================================================================
    # The BEASTIARY expansion has two parts - a standalone scene that a player could
    # use to review information on previous foes, and an expanded info window that
    # displays during battle similar to FFXIII. To access the standalone scene,
    # use the script call "$scene = Scene_Beastiary.new". To access the info window,
    # you can set a dedicated button below in the INPUT SETTINGS. Note that a player
    # will have to be selecting an enemy for the button to work.
    # Currently, the beastiary is tightly tied to the scan skill. So if you haven't
    # set one up, please review the instructions above on how to do that.
    # Furthermore, you'll need to add another script call to the scan skill in order
    # for enemies to show up in the standalone beastiary. Inside the script command,
    # put "Mobius.scan_skill" without quotes.
    # For additional setup and configuration, see the below instructions.
    #==============================================================================
    # Set this option to "true" to enable this expansion
    BEASTIARY_ENABLED = true
    # The standalone beastiary has room for 384x384 sprite of the enemy.
    # For most enemies, this is sufficient to display the entire sprite but it
    # may not work for extra large enemies. To work around this, you can create
    # alternate display sprites. The names for each sprite should be "EnemyNameSpriteSuffix".
    # You can set the suffix below. The default is "_Beastiary_Sprite". So "Ghost" sprite
    # would need to be named "Ghost_Beastiary_Sprite". The icons can be any supported image
    # format (i.e. png, jpg, etc). Keep in mind that only 384x384 pixels will be shown.
    # Any enemy without a special sprite will use it's normal one, so you only need
    # to worry about the enemies with really big sprites.
    BEASTIARY_SPRITE_SUFFIX = "_Beastiary_Sprite"
    # By default, the script looks for special sprites in the "Pictures" folder.
    # You can change that by configuring the path below.
    # Note that the path is local to the project directory.
    BEASTIARY_SPRITE_PATH = "Graphics/Pictures/"
    # The beastiary window draws some divider lines which by default are colored
    # white. You can change the color to whatever you want by setting the below
    # numbers to your desired R,G,B values.
    DIVIDER_LINE_COLOR = Color.new(255,255,255)
    # When naming an enemy's stats, the script will use whatever you have set in
    # the database, but there is no place in the database for an "EVA" word, so
    # you can set it below.
    EVASION_WORD = "EVA"
    # Here you can configure the descriptors for the various beastiary pages
    SPRITE_PAGE  = "Image"
    STATS_PAGE   = "Stats"
    ELEMENT_PAGE = "Elements"
    STATUS_PAGE  = "Statuses"
    # Here you can configure the descriptors for the various element efficiencies
    ELEMENT_WORD_200  = "Helpless"  # Rank A
    ELEMENT_WORD_150  = "Weak"      # Rank B
    ELEMENT_WORD_100  = "Normal"    # Rank C
    ELEMENT_WORD_50   = "Resistant" # Rank D
    ELEMENT_WORD_0    = "Immune"    # Rank E
    ELEMENT_WORD_M100 = "Absorbs"   # Rank F
    # Here you can configure the descriptors for the various status efficiencies
    STATUS_WORD_100   = "Helpless"  # Rank A
    STATUS_WORD_80    = "Weak"      # Rank B
    STATUS_WORD_60    = "Normal"    # Rank C
    STATUS_WORD_40    = "Resistant" # Rank D
    STATUS_WORD_20    = "Hardened"  # Rank E
    STATUS_WORD_0     = "Immune"    # Rank F
    # You may want to hide certain elements from displaying in the beastiary.
    # If that's the case, simply list the IDs of the elements below,
    # separating them by commas, e.g. [1,2,3]
    HIDDEN_ELEMENTS = []
    # You may want to hide certain states from displaying in the beastiary.
    # If that's the case, simply list the IDs of the states below,
    # separating them by commas, e.g. [1,2,3]
    HIDDEN_STATES = []
  end
end
