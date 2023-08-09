#===============================================================================
# Mobius' Charge Turn Battle System
# Author: Mobius XVI
# Version: 1.4
# Date: 25 JUN 2023
#===============================================================================
#
# Introduction:
#
#   This script overhauls the default battle system and replaces it with a
#   "CTB" system similar to Final Fantasy Tactics and Final Fantasy X.
#   Battlers now use their speed to charge up a hidden turn gauge, and
#   when it's full, they get a turn immediately. This causes turns to alternate
#   in a semi-predictable order, making for a more strategic battle system.
#
# Instructions:
#
#  - Place this script below all the default scripts but above main.
#
#  - Import the enemy icon pictures into your project, and place them in
#    the "pictures" folder.
#
#  - The customization section below has additional instructions on
#    how you can set certain preferences up to your liking.
#
#  - Below the customization section are additional expansions that you can
#   select along with their own customization options.
#
# Issues/Bugs/Possible Bugs:
#
#   - As this script basically replaces the default battle system, it
#     will likely be incompatible with other battle system scripts.
#
#  Credits/Thanks:
#    - Mobius XVI, author
#    - TheRiotInside, for testing/feedback/suggestions
#    - Mudkicker, for suggesting customizable turn icons
#
#  License
#    This script is licensed under the MIT license, so you can use it for both commercial and non-commercial games!
#    Check the included license file for the full text.
#    Further, if you do decide to use this script in a commercial product, I'd ask that you
#    let me know via a forum post or a PM. Thanks.
#
#==============================================================================
# ** CUSTOMIZATION START
#==============================================================================
