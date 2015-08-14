#===============================================================================
# Mobius' Charge Turn Battle System
# Author: Mobius XVI
# Version: 1.2
# Date: 10 AUG 2015
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
#	 select along with their own customization options.
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
module Mobius
	module Charge_Turn_Battle
		# CHARGE_RATE lets you set a formula for how a charge bar will fill.
		# Keep in mind that this will all happen behind the scenes, so it won't
		# effect how "quickly" it will fill in real time. 
		# Your formula must be contained between two quotation
		# marks, i.e. "your formula". Formulas are valid provided they make 
		# mathematical sense. You can use any integer numbers, mathematical symbols
		# like +, -, *, /, or ** for exponentiation. You can also use the following
		# list of keywords to get a battler's stat:
		# hp = current HP ; sp = current SP ; maxhp = Max HP ; maxsp = Max SP
		# str = strength ; dex = dexterity ; agi = agility ; int = intelligence 
		# atk = attack ; pdef = physical defence ; mdef = magical defence ; eva = evasion
		# here are some example formulas
		# "(10 * str) / (agi + 7)"
		# "(maxhp - hp) * 100 / (5 + eva**2)"
		CHARGE_RATE = "(5 + agi/5)"
		
		# CHARGE_BAR_TOTAL is the numerical amount that the charge bar must reach
		# before a battler gets a turn. Between this and the CHARGE_RATE, you can affect
		# how often a battler gets an "extra" turn. As an example, say you have two battlers
		# A and B with agilities of 5 and 10 respectively. Further, let's say the CHARGE_RATE 
		# is just "agi" and the CHARGE_BAR_TOTAL is 100. Both battlers will start with a charge 
		# bar of 0, and then fill them up behind the scenes until A has 50 and B has 100.
		# B then gets a turn, and his charge bar resets to 0. The bars fill up until A has 100 
		# and B has 100. A gets a turn, then B gets a turn, and both bars reset to 0. So you can
		# see how B will essentially get two turns for every turn that A gets.
		CHARGE_BAR_TOTAL = 100
		
		# SPEED_FACTORS allow you to set bonuses/penalites for certain actions. Normally,
		# after a battler gets a turn their charge bar gets reset to 0. However, based on what
		# action they just performed, you can adjust it positively or negatively. So if you set
		# a speed factor of 10 for "defend", whenever a battler defended on their turn, their
		# charge bar would get reset to 0 then immediately get 10 points added back to it.
		# This of course would mean they'll get their next turn sooner. You could also apply
		# speed penalties for "slow" attacks. Say you have a skill that deals massive damage,
		# but would fatigue the battler. You could set a speed factor of -10 and then after
		# they executed the attack, their charge bar would get reset to 0 and then immediately
		# have 10 points removed.
		
		# DEFEND_SPEED_FACTOR sets the bonus/penalty for defending.
		DEFEND_SPEED_FACTOR = 0
		# ESCAPE_SPEED_FACTOR sets the bonus/penalty for attempting to escape and failing.
		ESCAPE_SPEED_FACTOR = 0
		# NOTHING_SPEED_FACTOR sets the bonus/penalty for doing nothing (only used by enemies).
		NOTHING_SPEED_FACTOR = 0
		# WEAPON_SPEED_FACTORS allow you to give individual weapons a bonus/penalty.
		# Note that the speed factor will only be applied when a battler performs a basic attack.
		# To set this up, place the weapon ID followed by an arrow "=>" and then the speed factor
		# inside of the curly brackets. Separate entries by a comma. The entries can span multiple
		# lines so long as all entries are surrounded by the start and end curly brackets.
		# Example: { 1 => 10, 2 => 5 } 
		# You don't need to set a speed factor for every weapon if you don't want to. Any weapon
		# not explicitly given a speed factor here will use the "default" value on the next line.
		WEAPON_SPEED_FACTORS = {}
		# The default line sets the speed factor for any weapon not included above.
		WEAPON_SPEED_FACTORS.default = 0
		# SKILL_SPEED_FACTORS is identical in set up to WEAPON_SPEED_FACTORS but for skills.
		SKILL_SPEED_FACTORS = {} 
		SKILL_SPEED_FACTORS.default = 0
		# ITEM_SPEED_FACTORS is identical in set up to WEAPON_SPEED_FACTORS but for items.
		ITEM_SPEED_FACTORS = {} 
		ITEM_SPEED_FACTORS.default = 0
		
		# You can designate certain enemies as "bosses". This will change how their names are
		# displayed as well as the icon shown for them in the turn order window.
		# To set this up, all you need to do is list all of the enemies' IDs, separated by commas,
		# inside of the square brackets.
		BOSS_LIST = [23]	
				
		# This option allows you to set the display word for escape similar to how you can set
		# custom words in the database for HP, SP, etc.
		ESCAPE_WORD = "Escape"
		
		# The battle system comes with a collection of turn icons to use. However, you don't 
		# have to use those if you don't want. As long as you leave the names unchanged, you 
		# can modify them however you want. But keep in mind that only 32x48 (width x height)
		# pixels will be shown. But let's say you'd rather have unique icons for each actor
		# and/or each enemy. Then these options are for you.
		
		# Set this option to "true" to enable unique icons for each actor. 
		USE_ACTOR_PICTURES = false
		# If you've set the above to true, then you need to place an icon for each actor in
		# the "Pictures" folder. The names for each picture should be "ActorNameActorSuffix"
		# You can set the suffix below. The default is "_Turn_Order_Icon". So "Aluxes" icon
		# would need to be named "Aluxes_Turn_Order_Icon". The icons can be any supported image
		# format (i.e. png, jpg, etc). Keep in mind that only 32x48 (width x height) pixels will be shown.
		ACTOR_PICTURES_SUFFIX = "_Turn_Order_Icon"
		# Set this option to "true" to enable unique icons for each enemy.
		USE_ENEMY_PICTURES = false
		# If you've set the above to true, then you need to place an icon for each enemy in
		# the "Pictures" folder. The names for each picture should be "EnemyNameEnemySuffix"
		# You can set the suffix below. The default is "_Turn_Order_Icon". So "Ghost" icon
		# would need to be named "Ghost_Turn_Order_Icon". The icons can be any supported image
		# format (i.e. png, jpg, etc). Keep in mind that only 32x48 (width x height) pixels will be shown.
		ENEMY_PICTURES_SUFFIX = "_Turn_Order_Icon"
		# If any image can't be found, a 32x32 box of the below color will be drawn instead.
		# You can change the numbers to change the color. The numbers are RGB values.
		# I recommend you just leave this black, but I realize that might be hard to see 
		# for some people so you can change it if need be.
		MISSING_GRAPHIC_COLOR = Color.new(0, 0, 0)
		
		# When showing the enemy's name during battle, the battle system can be set to
		# automatically add a prefix based on the enemy's index. This way the player can 
		# distinguish between Ghost A and Ghost B for example.
		# Set this to "true" to enable the prefixes; set this to "false" to disable it.
		USE_ENEMY_PREFIX = true
		# If you are using prefixes, you can customize how they are displayed.
		# Simply place your prefixes, separated by commas, in between the quotes.
		# Keep in mind that this is very literal, so spaces count.
		# Also, if you don't have eight different prefixes, then some enemies just
		# won't get a prefix. 
		# Lastly, you don't need to worry about this if you've set the above option to false.
		ENEMY_PREFIX = "A: ,B: ,C: ,D: ,E: ,F: ,G: ,H: "
		# If you are using prefixes, you can customize how they are displayed.
		# Any enemy tagged as a "boss" in the "BOSS_LIST" above will get this prefix
		# instead of a normal prefix. 
		# Keep in mind that this is very literal, so spaces count.
		# Lastly, you don't need to worry about this if you've set the above option to false.
		ENEMY_BOSS_PREFIX = "Boss: "		
		
		# Because this battle system is designed to more tactical than the default system, a 
		# scan skill is basically a necessity to allow you to track an enemy's HP/SP. 
		# To set this up, first create a skill to perform scan in the database. Second,
		# create a state for scan in the database. The skill and state can be configured however
		# you want just make sure that the scan skill applies the scan state to the enemy when used.
		# Once you've done that, set this option to the ID of the scan state that you created. 
		# Then whenever an enemy has the scan state applied, you'll be able to see their HP/SP
		# when targeting them.
		SCAN_STATE_ID = 17
		# OPTIONAL: If you would like a pop-up to be displayed when you use the skill for the 
		# first time, then you can do the following additional steps. Create a common event
		# called scan, and add a "script" command to it. Inside the script command, put
		# "Mobius.scan_skill_popup" without quotes. Then simply add the common event to the scan skill
		# you created earlier, and you're done!
		#==============================================================================
		
		#==============================================================================
		# ** EXPANSION SETTINGS
		#------------------------------------------------------------------------------
		# The following settings are all optional, and are only used with the expansions 
		# to the core script.
		#==============================================================================
		
		#==============================================================================
		# ** STATUS_ICONS SETTINGS
		#------------------------------------------------------------------------------
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
		STATUS_ICONS = true 		
		# If you've set the above to true, then you need to place an icon for each status in
		# the "Icons" folder by default but this can be changed if desired.
		# The names for each icon should be "StatusNameStatusSuffix"
		# You can set the suffix below. The default is "_Status_Icon". So "Blind" icon
		# would need to be named "Blind_Status_Icon". The icons can be any supported image
		# format (i.e. png, jpg, etc). Keep in mind that only 24x24 (width x height) pixels will be shown.
		STATUS_ICON_SUFFIX = ""
		# Here you can set the path to the status icons. Note that it is local to the project folder.
		STATUS_ICON_PATH = "Graphics/Icons/"
		
		#==============================================================================
		# ** BEASTIARY SETTINGS
		#------------------------------------------------------------------------------
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
		BEASTIARY = true 
		# The standalone beastiary will show a 200x200 sprite of the enemy.
		# For most small enemies, this is sufficient to display the entire sprite
		# but not for large enemies. So you can create alternate display sprites.
		# The names for each sprite should be "EnemyNameSpriteSuffix".
		# You can set the suffix below. The default is "_Beastiary_Sprite". So "Ghost" sprite
		# would need to be named "Ghost_Beastiary_Sprite". The icons can be any supported image
		# format (i.e. png, jpg, etc). Keep in mind that only 200x200 (width x height) pixels will be shown.
		# Any enemy without a special sprite will use it's normal one, so you only need
		# to worry about the enemies with big sprites.
		BEASTIARY_SPRITE_SUFFIX = "_Beastiary_Sprite"
		# By default, the script looks for special sprites in the "Pictures" folder.
		# You can change that by configuring the path below.
		# Note that the path is local to the project directory.
		BEASTIARY_SPRITE_PATH = "Graphics/Pictures/"
		# The beastiary window draws some divider lines which by default are colored 
		# white. You can change the color to whatever you want by setting the below
		# numbers to your desired R,G,B values.
		BEASTIARY_DIVIDER_LINE_COLOR = Color.new(255,255,255)
		# When naming an enemy's stats, the script will use whatever you have set in
		# the database, but there is no place in the database for an "EVA" word, so 
		# you can set it below.
		BEASTIARY_EVASION_WORD = "EVA"
		# Here you can configure the descriptors for the various element efficiencies
		BEASTIARY_ELEMENT_WORD_200  = "Helpless"  # Rank A
		BEASTIARY_ELEMENT_WORD_150  = "Weak"      # Rank B
		BEASTIARY_ELEMENT_WORD_100  = "Normal"    # Rank C 
		BEASTIARY_ELEMENT_WORD_50   = "Resistant" # Rank D 
		BEASTIARY_ELEMENT_WORD_0    = "Immune"    # Rank E 
		BEASTIARY_ELEMENT_WORD_M100 = "Absorbs"   # Rank F 
		# Here you can configure the descriptors for the various status efficiencies
		BEASTIARY_STATUS_WORD_100   = "Helpless"  # Rank A
		BEASTIARY_STATUS_WORD_80    = "Weak"      # Rank B
		BEASTIARY_STATUS_WORD_60    = "Normal"    # Rank C 
		BEASTIARY_STATUS_WORD_40    = "Resistant" # Rank D 
		BEASTIARY_STATUS_WORD_20    = "Hardened"  # Rank E 
		BEASTIARY_STATUS_WORD_0     = "Immune"    # Rank F 
		
	end
end
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
#==============================================================================
# ** CUSTOMIZATION END	
#------------------------------------------------------------------------------
# ** EDIT BELOW THIS LINE AT OWN RISK!!!
#==============================================================================
#==============================================================================
# ** Data Check
#------------------------------------------------------------------------------
#  This section runs a check on all customization options to ensure that
#  they are valid.
#==============================================================================

#==============================================================================
# ** Game_Battler (part 1)
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass for the Game_Actor
#  and Game_Enemy classes.
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :charge_gauge             # charge gauge 
  attr_accessor :charge_gauge_dummy       # charge gauge dummy 
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias mobius_game_battler_initialize initialize
  def initialize
    mobius_game_battler_initialize
    @charge_gauge = 0 
    @charge_gauge_dummy = 0 
  end
  #--------------------------------------------------------------------------
  # * Charge -- Increases a battler's actual charge gauge
  #--------------------------------------------------------------------------
  def charge
    @charge_gauge += eval(Mobius::Charge_Turn_Battle::CHARGE_RATE)  
  end
  #--------------------------------------------------------------------------
  # * Dummy Charge -- Increases a battler's dummy charge gauge for use
  #		in calculating turn order
  #--------------------------------------------------------------------------
  def dummy_charge
    @charge_gauge_dummy += eval(Mobius::Charge_Turn_Battle::CHARGE_RATE)    
  end
  #--------------------------------------------------------------------------
  # * Dummy Charge Copy -- Sets a battler's dummy gauge equal to normal gauge
  #--------------------------------------------------------------------------
  def dummy_charge_copy
    @charge_gauge_dummy = @charge_gauge
  end
  #--------------------------------------------------------------------------
  # * Charge Reset -- Resets a battler's charge gauge to zero +/- speed_factor
  #--------------------------------------------------------------------------
  def charge_reset
    @charge_gauge -= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
    @charge_gauge += speed_factor
  end
  #--------------------------------------------------------------------------
  # * Dummy Charge Reset -- Resets a battler's dummy charge gauge to zero 
  #--------------------------------------------------------------------------
  def dummy_charge_reset
    @charge_gauge_dummy -= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
  end
  #--------------------------------------------------------------------------
  # * Charge Clear -- Clears out a battler's charge/dummy charge at battle end
  #--------------------------------------------------------------------------
  def charge_clear
	@charge_gauge = 0
	@charge_gauge_dummy = 0
  end
  #--------------------------------------------------------------------------
  # * Speed Factor -- Returns a battler's speed_factor
  #--------------------------------------------------------------------------
  def speed_factor
    case @current_action.kind
    #when basic ( attack / defend / escape / nothing )
    when 0
		case @current_action.basic
		# when attack
		when 0
			#get speed factor from hash: WEAPON_SPEED_FACTORS
			spd = Mobius::Charge_Turn_Battle::WEAPON_SPEED_FACTORS[@weapon_id]
			return spd
		# when defend
		when 1
			return Mobius::Charge_Turn_Battle::DEFEND_SPEED_FACTOR
		# when escape
		when 2
			return Mobius::Charge_Turn_Battle::ESCAPE_SPEED_FACTOR
		# when nothing
		when 3
			return Mobius::Charge_Turn_Battle::NOTHING_SPEED_FACTOR
		end
    #when skill
    when 1
      #get skill_id
      skill_id = @current_action.skill_id
      #get speed factor from hash: SKILL_SPEED_FACTORS
      spd = Mobius::Charge_Turn_Battle::SKILL_SPEED_FACTORS[skill_id]
      return spd
    #when item
    when 2
      #get item_id
      item_id = @current_action.item_id
      #get speed factor from hash: ITEM_SPEED_FACTORS
      spd = Mobius::Charge_Turn_Battle::ITEM_SPEED_FACTORS[item_id]
      return spd
    end
  end  
end

#==============================================================================
# ** Game_BattleAction
#------------------------------------------------------------------------------
#  This class handles actions in battle. It's used within the Game_Battler 
#  class.
#==============================================================================

class Game_BattleAction
  #--------------------------------------------------------------------------
  # * Action Name -- Mobius Added
  #       Returns string corresponding to action kind
  #--------------------------------------------------------------------------
  def action_name
    case @kind
    #when basic
    when 0
      #determine type of basic
      case @basic
      #when attack
      when 0
        return "Attack"
      #when defend
      when 1
        return "Defend"
      #when escape
      when 2
        return "Escape"
      #when nothing
      when 3
        return "Nothing"
      end
    #when skill
    when 1
      return $data_skills[@skill_id].name unless $data_skills[@skill_id] == nil
    #when item
    when 2
      return $data_items[@item_id].name unless $data_items[@item_id] == nil
    end
    return "???"
  end
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemies. It's used within the Game_Troop class
#  ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
    attr_reader   :boss            # Boss
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     troop_id     : troop ID
  #     member_index : troop member index
  #--------------------------------------------------------------------------
  alias mobius_initialize initialize
  def initialize(troop_id, member_index)
	mobius_initialize(troop_id, member_index)
    @boss = Mobius::Charge_Turn_Battle::BOSS_LIST.include?(id)
  end
  #--------------------------------------------------------------------------
  # * Get Name - Changed by Mobius
  #--------------------------------------------------------------------------
  alias base_name name
  def name
    #base_name = $data_enemies[@enemy_id].name - removed
	if Mobius::Charge_Turn_Battle::USE_ENEMY_PREFIX
		if @boss
		  full_name = Mobius::Charge_Turn_Battle::ENEMY_BOSS_PREFIX + base_name
		else
		  #temp_str = Mobius::Charge_Turn_Battle::ENEMY_PREFIX - OLD
		  #letter = temp_str[@member_index, 1]
		  #full_name = letter + ": " + base_name
		  prefix_array = Mobius::Charge_Turn_Battle::ENEMY_PREFIX.split(",")
		  prefix = prefix_array[@member_index].to_s #convert to string in case it's nil
		  full_name = prefix + base_name
		end
	else
		full_name = base_name
	end
    return full_name
  end
  #--------------------------------------------------------------------------
  # * Get Element Effectiveness
  #--------------------------------------------------------------------------
  def element_ranks
    return $data_enemies[@enemy_id].element_ranks
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles the party. It includes information on amount of gold 
#  and items. Refer to "$game_party" for the instance of this class.
#==============================================================================

class Game_Party
	
	attr_accessor  :scan_list                # ID array of scanned enemies - Mobius
	
	alias mobius_party_initialize initialize
	alias mobius_clear_actions clear_actions
	
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		mobius_party_initialize
		@scan_list = [1,2,3,4,5,6]
	end
	#--------------------------------------------------------------------------
	# * Clear All Member Actions and Charge Gauges
	#--------------------------------------------------------------------------
	def clear_actions
		mobius_clear_actions
		# Clear All Member Charge Gauges
		for actor in @actors
		  actor.charge_clear
		end
	end

end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This class is for all in-game windows.
#==============================================================================

class Window_Base < Window
	#--------------------------------------------------------------------------
	# * Draw Name
	#     bitmap : bitmap to draw
	#     rect   : rectangle to center bitmap in
	#--------------------------------------------------------------------------
	def draw_bitmap_centered(bitmap, rect)
		draw_x = ( (rect.width - bitmap.width) / 2 ) + rect.x
		draw_y = ( (rect.height - bitmap.height) / 2 ) + rect.y
		self.contents.blt(draw_x, draw_y, bitmap, bitmap.rect)		
	end
  #--------------------------------------------------------------------------
  # * Draw Name
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
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
  #     MOBIUS ADDED
  #--------------------------------------------------------------------------
  def draw_icon(icon_name, x, y)
    bitmap = RPG::Cache.icon(icon_name)
    src_rect = Rect.new(0, 0, 24, 24)
    self.contents.blt(x, y, bitmap, src_rect)
  end
  
  # If STATUS_ICONS expansion has been selected, run this code
  if Mobius::Charge_Turn_Battle::STATUS_ICONS
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
		suffix = Mobius::Charge_Turn_Battle::STATUS_ICON_SUFFIX
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
	  
end

#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
#  This window shows skill and item explanations along with actor status.
#==============================================================================

class Window_Help < Window_Base
	# If STATUS_ICONS expansion has been selected, run this code
	if Mobius::Charge_Turn_Battle::STATUS_ICONS
		#--------------------------------------------------------------------------
		# * Set Enemy
		#     enemy : name and status displaying enemy
		#--------------------------------------------------------------------------
		def set_enemy(enemy)
			self.contents.clear
			@actor = nil
			@text = nil
			self.visible = true
			# If enemy has been scanned 
			if enemy.state?(Mobius::Charge_Turn_Battle::SCAN_STATE_ID)
				# treat enemy as actor
				draw_actor_name(enemy, 4, 0)
				draw_actor_state(enemy, 140, 0)
				draw_actor_hp(enemy, 284, 0)
				draw_actor_sp(enemy, 460, 0)
			elsif enemy.states.any? { |id| $data_states[id].rating >= 1 }
				# treat enemy as mostly actor
				self.contents.clear
				draw_actor_name(enemy, 140, 0, 120)
				draw_actor_state(enemy, 344, 0, 120)					
			else
				# draw only name
				text = enemy.name 
				set_text(text, 1)			
			end
		end
	# else run this code
	else
		#--------------------------------------------------------------------------
		# * Set Enemy
		#     enemy : name and status displaying enemy
		#--------------------------------------------------------------------------
		def set_enemy(enemy)
			# If enemy has been scanned -- Mobius added
			if enemy.state?(Mobius::Charge_Turn_Battle::SCAN_STATE_ID)
			  # treat enemy as actor
			  self.contents.clear
			  draw_actor_name(enemy, 4, 0)
			  draw_actor_state(enemy, 140, 0)
			  draw_actor_hp(enemy, 284, 0)
			  draw_actor_sp(enemy, 460, 0)
			  @actor = nil
			  @text = nil
			  self.visible = true
			else
			  # treat as enemy
			  text = enemy.name 
			  state_text = make_battler_state_text(enemy, 112, false)
			  if state_text != ""
				text += "  " + state_text
			  end
			  set_text(text, 1)
			end
		end  
	end
end

#==============================================================================
# ** Window_BigBattleStatus
#------------------------------------------------------------------------------
#  This window displays additional information during battle
#==============================================================================

class Window_BigBattleStatus < Window_Base
  
  attr_accessor   :action_battlers
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    super(0, 0, 640, 320)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.back_opacity = 160
    @action_battlers = nil
    self.visible = false
    self.z = 100
    update
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(1, 0, 152, 32, "Battlers")
    self.contents.draw_text(1 + 152, 0, 152, 32, "Status", 1)
    self.contents.draw_text(1 + 304, 0, 152, 32, "HP / MAXHP", 2)
    self.contents.draw_text(1 + 456, 0, 152, 32, "SP / MAXSP", 2)
    self.contents.font.color = normal_color
    if @action_battlers != nil
      for i in 0...@action_battlers.size
        # @action_battlers will contain all the battlers in a battle including
        # dead enemies, and KO'd actors
        battler = @action_battlers[i]
        break if battler == nil 
        # So the line below checks to see if the battler still "exists"
        # If he doesn't exist, he gets removed from the @action_battlers array
        # The for loop is then called again using the same value for "i"
        # This ensures the numbers and lines print correctly
        # However, the for loop will still run to the original size of
        # @action_battlers. So, the line above cancels the loop as soon as
        # a nil value is reached
        if not battler.exist?
          @action_battlers.delete_at(i)
          redo
        end
        # This if checks to see if the enemy has been scanned
        # If he hasn't then it returns question mark values
        if battler.is_a?(Game_Enemy) and not battler.state?(43)
          state = make_battler_state_text(battler, 152, true)
          self.contents.draw_text(1 + 304, i * 22 + 22, 152, 32,"???", 2) # HP
          self.contents.draw_text(1 + 456, i * 22 + 22, 152, 32,"???", 2) # SP
        else
          state = make_battler_state_text(battler, 152, true)
          draw_battler_hp(battler, 1 + 304, i * 22 + 22) #width = 152
          draw_battler_sp(battler, 1 + 456, i * 22 + 22) #width = 152
        end
        self.contents.draw_text(1, i * 22 + 22, 152, 32, battler.name)
        self.contents.draw_text(1 + 152, i * 22 + 22, 152, 32, state, 1)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw HP -- Mobius modified from Window_Base
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_battler_hp(actor, x, y)
    # Draw HP
    self.contents.font.color = actor.hp <= actor.maxhp / 10 ? knockout_color :
      actor.hp <= actor.maxhp / 4 ? crisis_color : normal_color
    self.contents.draw_text(x, y, 70, 32, actor.hp.to_s, 2)
    # Draw MaxHP
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 70, y, 12, 32, "/", 1)
    self.contents.draw_text(x + 82, y, 70, 32, actor.maxhp.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw SP -- Mobius modified from Window_Base
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_battler_sp(actor, x, y)
    # Draw SP
    self.contents.font.color = actor.sp <= actor.maxsp / 10 ? knockout_color :
      actor.sp <= actor.maxsp / 4 ? crisis_color : normal_color
    self.contents.draw_text(x, y, 70, 32, actor.sp.to_s, 2)
    # Draw MaxSP
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 70, y, 12, 32, "/", 1)
    self.contents.draw_text(x + 82, y, 70, 32, actor.maxsp.to_s, 2)
  end
end

#==============================================================================
# ** Window_TurnOrder
#------------------------------------------------------------------------------
#  This window displays the current turn order during battle  
#  The window can be scrolled during the command phase
#==============================================================================

class Window_TurnOrder < Window_Base

  attr_accessor :turn_order  # Turn Order
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    super(640 - 64, 0, 64, 320) # right justified
    self.contents = Bitmap.new(width - 32, 768)# 16 battlers tall
    self.back_opacity = 160
    @current_battlers = []
    @turn_order = []
    @first_draw_index = 0
    @drawing_down = false
    @drawing_up = false
    @wait_count = 0
    @actor_index = -1
    @enemy_index = -1
    self.visible = true
    self.z = 100
    update
    refresh
  end
  #--------------------------------------------------------------------------
  # * Update -- Mobius
  #--------------------------------------------------------------------------
  def update(current_battlers = @current_battlers, index = @actor_index)
    @wait_count -= 1 if @wait_count > 0
    if @current_battlers != current_battlers
      @current_battlers = current_battlers
      refresh
    end
    if @actor_index != index
      @actor_index = index
      if index == 3 # If current battler is Actor 4
        self.x = 0
      else
        self.x = 640 - 64
      end
    end
    make_turn_order
    if @drawing_down #oy +
      if self.oy == (@first_draw_index * 48)
        @drawing_down = false
      else
        self.oy += 12
      end
      return      
    end
    if @drawing_up
      if self.oy == (@first_draw_index * 48)
        @drawing_up = false
      else
        self.oy -= 12
      end
      return 
    end
    if Input.repeat?(Input::TURN_WINDOW_DRAW_DOWN_BUTTON)
      shift_draw_down
    end
    if Input.repeat?(Input::TURN_WINDOW_DRAW_UP_BUTTON)
      shift_draw_up
    end
    
    #refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh -- Mobius
  #--------------------------------------------------------------------------
  def refresh(current_battlers = @current_battlers, index = @actor_index)
    self.contents.clear
    draw_turn_order    
  end
  #--------------------------------------------------------------------------
  # * Make Turn Order -- Mobius
  #--------------------------------------------------------------------------
  def make_turn_order(current_battlers = @current_battlers)
    if current_battlers != [] and current_battlers != nil
      #initialize dummy gauges
      for battler in current_battlers
        battler.dummy_charge_copy
      end 
      #initialize turn order
      turn_order_temp = []
      until turn_order_temp.size >= 16
        #charge dummy gauges
        until dummy_battler_charged?
          for battler in current_battlers
          battler.dummy_charge
          end
        end
        #get the fastest one
        fastest = current_battlers.max \
        {|a,b| a.charge_gauge_dummy <=> b.charge_gauge_dummy }
        #add the fastest to the turn order
        turn_order_temp.push(fastest)
        #reset the fastest
        fastest.dummy_charge_reset
      end
      #compare with set turn order
      unless @turn_order == turn_order_temp
        @turn_order = turn_order_temp
        refresh
      end
    end
  end    
  #--------------------------------------------------------------------------
  # * Dummy Battler Charged -- Mobius
  #--------------------------------------------------------------------------
  def dummy_battler_charged?
    for battler in @current_battlers
      return true if battler.charge_gauge_dummy >= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
    end
    return false
  end 
  #--------------------------------------------------------------------------
  # * Draw Turn Order -- Mobius, Draws all icons
  #-------------------------------------------------------------------------- 
  def draw_turn_order
    if @turn_order != []
      for i in 0...@turn_order.size
        battler = @turn_order[i]
        if battler.is_a?(Game_Enemy)
          draw_enemy_graphic(battler, 0, i * 48)
        elsif battler.is_a?(Game_Actor)
          draw_actor_graphic(battler, 0, i * 48) 
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Shift Draw Up -- Mobius
  #-------------------------------------------------------------------------- 
  def shift_draw_up
    if @first_draw_index == 0
      if @wait_count <= 0
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        @wait_count = 12
      end
      return #do nothing
    else
      @first_draw_index -= 1
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      #refresh
      @drawing_up = true
    end
  end    
  #--------------------------------------------------------------------------
  # * Shift Draw Down -- Mobius
  #-------------------------------------------------------------------------- 
  def shift_draw_down
    if @first_draw_index == 10
      if @wait_count <= 0
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        @wait_count = 12
      end
      return #do nothing
    else
      @first_draw_index += 1
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      #refresh
      @drawing_down = true
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Graphic
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
	if Mobius::Charge_Turn_Battle::USE_ACTOR_PICTURES
		actor_picture_name = actor.name + Mobius::Charge_Turn_Battle::ACTOR_PICTURES_SUFFIX
		bitmap = RPG::Cache.picture(actor_picture_name)
		cw = bitmap.width / 2
		ch = bitmap.height / 2
		src_rect = Rect.new(cw - 16, ch - 24, 32, 48)
	else
		bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
		cw = bitmap.width / 4 / 2
		ch = bitmap.height / 4 / 2
		src_rect = Rect.new(cw - 16, ch - 24, 32, 48)
		#self.contents.blt(x, y, bitmap, src_rect)
	end
	self.contents.blt(x, y, bitmap, src_rect)
	return
	# If filename can't be found
	rescue Errno::ENOENT
		rect = Rect.new(x, y, 32, 32)
		self.contents.fill_rect(rect, Mobius::Charge_Turn_Battle::MISSING_GRAPHIC_COLOR)
  end  
  #--------------------------------------------------------------------------
  # * Draw Enemy Graphic
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_enemy_graphic(enemy, x, y)
	if Mobius::Charge_Turn_Battle::USE_ENEMY_PICTURES
		enemy_picture_name = enemy.base_name + Mobius::Charge_Turn_Battle::ENEMY_PICTURES_SUFFIX
		bitmap = RPG::Cache.picture(enemy_picture_name)
		cw = bitmap.width / 2
		ch = bitmap.height / 2
		src_rect = Rect.new(cw - 16, ch - 24, 32, 48)
	else
		if enemy.boss
			bitmap = RPG::Cache.picture("EnemyBoss")
		else
			bitmap = RPG::Cache.picture(sprintf("Enemy%01d", enemy.index + 1))
		end
		cw = bitmap.width / 2
		ch = bitmap.height / 2
		src_rect = Rect.new(cw - 16, ch - 24, 32, 48)
		#self.contents.blt(x, y, bitmap, src_rect)
	end
	self.contents.blt(x, y, bitmap, src_rect)
	return
	# If filename can't be found
	rescue Errno::ENOENT
		rect = Rect.new(x, y, 32, 32)
		self.contents.fill_rect(rect, Mobius::Charge_Turn_Battle::MISSING_GRAPHIC_COLOR)
  end
end
  
#==============================================================================
# ** Arrow_All_Enemy
#------------------------------------------------------------------------------
#  This class creates and manages arrow cursors to choose all enemies. 
#==============================================================================

class Arrow_All_Enemy 
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :help_window              # help window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #--------------------------------------------------------------------------
  def initialize(viewport)
    @viewport = viewport
	@help_window = nil
    @enemies = []
    @arrows = []
    make_enemy_list
    make_helper_arrows
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Set sprite coordinates
    unless @enemies == [] or @enemies == nil
      for arrow in @arrows
        arrow.update
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Make Enemy List
  #--------------------------------------------------------------------------
  def make_enemy_list
    for enemy in $game_troop.enemies
      @enemies.push(enemy) if enemy.exist?
    end
  end
  #--------------------------------------------------------------------------
  # * Make Helper Arrows
  #--------------------------------------------------------------------------
  def make_helper_arrows
    for i in 0...@enemies.size
	  @arrows.push(Arrow_Base.new(@viewport))
      arrow = @arrows[i]
      enemy = @enemies[i]
      arrow.x = enemy.screen_x
      arrow.y = enemy.screen_y
    end  
  end
  #--------------------------------------------------------------------------
  # * Set Help Window
  #     help_window : new help window
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    # Update help text (update_help is defined by the subclasses)
    if @help_window != nil
      update_help
    end
  end
  #--------------------------------------------------------------------------
  # * Help Text Update
  #--------------------------------------------------------------------------
  def update_help
    # Display enemy name and state in the help window
    @help_window.set_text("All", 1)
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    for arrow in @arrows
      arrow.dispose
    end
  end
end

#==============================================================================
# ** Arrow_All_Actor
#------------------------------------------------------------------------------
#  This class creates and manages arrow cursors to choose all actors.
#==============================================================================

class Arrow_All_Actor 
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :help_window              # help window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #--------------------------------------------------------------------------
  def initialize(viewport)
	@viewport = viewport
	@help_window = nil
    @actors = []
    @arrows = []
    make_actor_list
    make_helper_arrows
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Set sprite coordinates
    unless @actors == [] or @actors == nil
      for arrow in @arrows
        arrow.update
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Make Actor List
  #--------------------------------------------------------------------------
  def make_actor_list
    for actor in $game_party.actors
      @actors.push(actor) if actor.exist?
    end
  end
  #--------------------------------------------------------------------------
  # * Make Helper Arrows
  #--------------------------------------------------------------------------
  def make_helper_arrows
    for i in 0...@actors.size
	  @arrows.push(Arrow_Base.new(@viewport))
      arrow = @arrows[i]
      actor = @actors[i]
      arrow.x = actor.screen_x
      arrow.y = actor.screen_y
    end  
  end
  #--------------------------------------------------------------------------
  # * Set Help Window
  #     help_window : new help window
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    # Update help text (update_help is defined by the subclasses)
    if @help_window != nil
      update_help
    end
  end
  #--------------------------------------------------------------------------
  # * Help Text Update
  #--------------------------------------------------------------------------
  def update_help
    # Display enemy name and state in the help window
    @help_window.set_text("All", 1)
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    for arrow in @arrows
      arrow.dispose
    end
  end
end

#==============================================================================
# ** Scene_Battle (part 1)
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle
  attr_reader :active_battler #Mobius added. Use $scene.active_battler to get
                              #current actor during batttle
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  alias mobius_main main
  def main
    # Initialize each kind of temporary battle data
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # Initialize battle event interpreter
    $game_system.battle_interpreter.setup(nil, 0)
    # Prepare troop
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    # Make actor command window
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    s5 = Mobius::Charge_Turn_Battle::ESCAPE_WORD # Mobius Added
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4, s5])
    @actor_command_window.y = 128
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Make other windows
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    #@help_window.back_opacity = 160
	@help_window.back_opacity = 230
	@help_window.z = 200
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    @turn_order_window = Window_TurnOrder.new #Mobius Added
    @big_status_window = Window_BigBattleStatus.new #Mobius Added
	if Mobius::Charge_Turn_Battle::BEASTIARY
		@enemy_detail_window = Window_BeastDetail.new(nil, true) #Mobius Added
	end
    # Make sprite set
    @spriteset = Spriteset_Battle.new
    # Initialize wait count
    @wait_count = 0
    # Execute transition
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # Start pre-battle phase
    start_phase1
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Refresh map
    $game_map.refresh
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    @turn_order_window.dispose # Mobius Added
    @big_status_window.dispose # Mobius
	if Mobius::Charge_Turn_Battle::BEASTIARY
		@enemy_detail_window.dispose # Mobius
	end
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # Dispose of sprite set
    @spriteset.dispose
    # If switching to title screen
    if $scene.is_a?(Scene_Title)
      # Fade out screen
      Graphics.transition
      Graphics.freeze
    end
    # If switching from battle test to any screen other than game over screen
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end

  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias mobius_update update
  def update
    if @turn_order_window.visible
      @turn_order_window.update(@current_battlers, @actor_index) # Mobius
    end
    mobius_update
  end
end

#==============================================================================
# ** Scene_Battle (part 2)
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # * Start Party Command Phase
  #--------------------------------------------------------------------------
  def start_phase2
    # Shift to phase 2
    @phase = 2
    # Increase Turn Count
    $game_temp.battle_turn += 1
    # Set actor to non-selecting
    @actor_index = -1
    @active_battler = nil
    @action_battlers = []
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Clear main phase flag
    $game_temp.battle_main_phase = false
    # Make new array of current battlers
    @current_battlers = []
    for enemy in $game_troop.enemies
      @current_battlers.push(enemy) if enemy.exist?
    end
    for actor in $game_party.actors
      @current_battlers.push(actor) if actor.exist?
    end
  end
  #--------------------------------------------------------------------------
  # * Battler Charged -- Mobius
  #--------------------------------------------------------------------------
  def battler_charged?
    for battler in @current_battlers
      return true if battler.charge_gauge >= Mobius::Charge_Turn_Battle::CHARGE_BAR_TOTAL
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Frame Update (party command phase)
  #--------------------------------------------------------------------------
  def update_phase2
    #charge all the battlers until someone gets an active turn
    until battler_charged?
      for battler in @current_battlers
        battler.charge
      end
    end
    #set the active battler to the fastest
    @active_battler = 
    @current_battlers.max {|a,b| a.charge_gauge <=> b.charge_gauge}
    # Remove appropiate states automatically
    @active_battler.remove_states_auto_start
    # Refresh Battle Status window
    @status_window.refresh
    # branch according to whether it's an enemy or actor
    if @active_battler.is_a?(Game_Enemy)
      @active_battler.make_action
      start_phase4
    else #if it's an actor
      start_phase3      
    end
    return
  end
  #--------------------------------------------------------------------------
  # * Frame Update (party command phase: escape)
  #--------------------------------------------------------------------------
  def update_phase2_escape
    # Calculate enemy agility average
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # Calculate actor agility average
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # Determine if escape is successful
    success = rand(100) < 50 * actors_agi / enemies_agi
    # If escape is successful
    if success
      # Play escape SE
      $game_system.se_play($data_system.escape_se)
      # Return to BGM before battle started
      $game_system.bgm_play($game_temp.map_bgm)
      # Battle ends
      battle_end(1)
    # If escape is failure
    else
      # Start main phase
      start_phase4
    end
  end

end

#==============================================================================
# ** Scene_Battle (part 3)
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # * Start Actor Command Phase
  #--------------------------------------------------------------------------
  def start_phase3
    # Shift to phase 3
    @phase = 3
    @actor_index = $game_party.actors.index(@active_battler)
    @active_battler.blink = true
    if @active_battler.inputable?
      phase3_setup_command_window
    else
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase)
  #--------------------------------------------------------------------------
  def update_phase3
    # If enemy detail is enabled      -- Mobius
    if @enemy_detail_window != nil and @enemy_detail_window.visible
      update_enemy_detail_window
    # If enemy arrow is enabled
    elsif @enemy_arrow != nil
      update_phase3_enemy_select
    # If all enemy arrow is enabled   -- Mobius
    elsif @all_enemy_arrow != nil
      update_phase3_all_enemy_select
    # If actor arrow is enabled
    elsif @actor_arrow != nil
      update_phase3_actor_select
    # If all actor arrow is enabled   -- Mobius
    elsif @all_actor_arrow != nil
      update_phase3_all_actor_select
    # If skill window is enabled
    elsif @skill_window != nil
      update_phase3_skill_select
    # If item window is enabled
    elsif @item_window != nil
      update_phase3_item_select
    # If turn order window is up       -- Mobius
    elsif @big_status_window.visible
      update_big_status_window
    # If actor command window is enabled
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : basic command)
  #--------------------------------------------------------------------------
  def update_phase3_basic_command
    # If shift is pressed
    if Input.trigger?(Input::A)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Start turn order window
      start_big_status_window
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Branch by actor command window cursor position
      case @actor_command_window.index
      when 0  # attack
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        # Start enemy selection
        start_enemy_select
      when 1  # skill
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 1
        # Start skill selection
        start_skill_select
      when 2  # guard
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 1
        # Go to command input for next actor
        start_phase4
      when 3  # item
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 2
        # Start item selection
        start_item_select
      when 4  # escape
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # If it's not possible to escape
        if $game_temp.battle_can_escape == false
          # Play buzzer SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        #Clear current action
        @active_battler.current_action.clear
        # Escape processing
        update_phase2_escape
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : skill selection)
  #--------------------------------------------------------------------------
  def update_phase3_skill_select
    # Make skill window visible
    @skill_window.visible = true
    # Update skill window
    @skill_window.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End skill selection
      end_skill_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Get currently selected data on the skill window
      @skill = @skill_window.skill
      # If it can't be used
      if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.skill_id = @skill.id
      # Make skill window invisible
      @skill_window.visible = false
      # If effect scope is single enemy
      if @skill.scope == 1
        # Start enemy selection
        start_enemy_select
      # If effect scope is all enemy - Mobius
      elsif @skill.scope == 2
        # Start all enemy selection
        start_all_enemy_select
      # If effect scope is single ally
      elsif @skill.scope == 3 or @skill.scope == 5
        # Start actor selection
        start_actor_select
      # If effect scope is all ally - Mobius
      elsif @skill.scope == 4 or @skill.scope == 6
        # Start all actor selection
        start_all_actor_select
      # If effect scope is not single
      else
        # End skill selection
        end_skill_select
        # Go to command input for next actor
        start_phase4
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : item selection)
  #--------------------------------------------------------------------------
  def update_phase3_item_select
    # Make item window visible
    @item_window.visible = true
    # Update item window
    @item_window.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End item selection
      end_item_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Get currently selected data on the item window
      @item = @item_window.item
      # If it can't be used
      unless $game_party.item_can_use?(@item.id)
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.item_id = @item.id
      # Make item window invisible
      @item_window.visible = false
      # If effect scope is single enemy
      if @item.scope == 1
        # Start enemy selection
        start_enemy_select
      # If effect scope is all enemy - Mobius
      elsif @item.scope == 2
        # Start all enemy selection
        start_all_enemy_select
      # If effect scope is single ally
      elsif @item.scope == 3 or @item.scope == 5
        # Start actor selection
        start_actor_select
      # If effect scope is all ally - Mobius
      elsif @item.scope == 4 or @item.scope == 6
        # Start all actor selection
        start_all_actor_select
      # If effect scope is not single
      else
        # End item selection
        end_item_select
        # Go to command input for next actor
        start_phase4
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : enemy selection)
  #--------------------------------------------------------------------------
  def update_phase3_enemy_select
    # Update enemy arrow
    @enemy_arrow.update
	# If Beastiary is added
	if Mobius::Charge_Turn_Battle::BEASTIARY
		# If Beastiary access button is pressed
		if Input.trigger?(Input::BEASTIARY_BATTLE_ACCESS_BUTTON)
		  # Set enemy
		  enemy = @enemy_arrow.enemy
		  # If enemy has been scanned -- Mobius added
		  if enemy.state?(Mobius::Charge_Turn_Battle::SCAN_STATE_ID)
			# Play decision SE
			$game_system.se_play($data_system.decision_se)
			# Start turn order window
			start_enemy_detail_window(enemy)
			return
		  else
			# Play buzzer SE
			$game_system.se_play($data_system.buzzer_se)
		  end
		end
	end
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End enemy selection
      end_enemy_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.target_index = @enemy_arrow.index
      # End enemy selection
      end_enemy_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Go to command input for next actor
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : all enemy selection) - MOBIUS
  #--------------------------------------------------------------------------
  def update_phase3_all_enemy_select
    # Update enemy arrow
    @all_enemy_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End enemy selection
      end_all_enemy_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # End enemy selection
      end_all_enemy_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Go to command input for next actor
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : actor selection)
  #--------------------------------------------------------------------------
  def update_phase3_actor_select
    # Update actor arrow
    @actor_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End actor selection
      end_actor_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.target_index = @actor_arrow.index
      # End actor selection
      end_actor_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Go to command input for next actor
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : all actor selection) - MOBIUS
  #--------------------------------------------------------------------------
  def update_phase3_all_actor_select
    # Update enemy arrow
    @all_actor_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End enemy selection
      end_all_actor_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # End enemy selection
      end_all_actor_select
      # If skill window is showing
      if @skill_window != nil
        # End skill selection
        end_skill_select
      end
      # If item window is showing
      if @item_window != nil
        # End item selection
        end_item_select
      end
      # Go to command input for next actor
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Start Enemy Selection
  #--------------------------------------------------------------------------
  def start_enemy_select
    # Make enemy arrow
    @enemy_arrow = Arrow_Enemy.new(@spriteset.viewport1)
    # Associate help window
    @enemy_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * End Enemy Selection
  #--------------------------------------------------------------------------
  def end_enemy_select
    # Dispose of enemy arrow
    @enemy_arrow.dispose
    @enemy_arrow = nil
    # If command is [fight]
    if @actor_command_window.index == 0
      # Enable actor command window
      @actor_command_window.active = true
      @actor_command_window.visible = true
      @turn_order_window.visible = true
      # Hide help window
      @help_window.visible = false
    end
    # If skill window is showing
    if @skill_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
    # If item window is showing
    if @item_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end 
  end
  #--------------------------------------------------------------------------
  # * Start All Enemy Selection - MOBIUS
  #--------------------------------------------------------------------------
  def start_all_enemy_select
    # Make enemy arrow
    @all_enemy_arrow = Arrow_All_Enemy.new(@spriteset.viewport1)
    # Associate help window
    @all_enemy_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * End All Enemy Selection - MOBIUS
  #--------------------------------------------------------------------------
  def end_all_enemy_select
    # Dispose of enemy arrow
    @all_enemy_arrow.dispose
    @all_enemy_arrow = nil
    # If command is [fight]
    if @actor_command_window.index == 0
      # Enable actor command window
      @actor_command_window.active = true
      @actor_command_window.visible = true
      @turn_order_window.visible = true
      # Hide help window
      @help_window.visible = false
    end
    # If skill window is showing
    if @skill_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
    # If item window is showing
    if @item_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end 
  end
  #--------------------------------------------------------------------------
  # * Start Actor Selection
  #--------------------------------------------------------------------------
  def start_actor_select
    # Make actor arrow
    @actor_arrow = Arrow_Actor.new(@spriteset.viewport2)
    @actor_arrow.index = @actor_index
    # Associate help window
    @actor_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * End Actor Selection
  #--------------------------------------------------------------------------
  def end_actor_select
    # Dispose of actor arrow
    @actor_arrow.dispose
    @actor_arrow = nil
    # If skill window is showing
    if @skill_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
    # If item window is showing
    if @item_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end 
  end
  #--------------------------------------------------------------------------
  # * Start All Actor Selection - MOBIUS
  #--------------------------------------------------------------------------
  def start_all_actor_select
    # Make actor arrow
    @all_actor_arrow = Arrow_All_Actor.new(@spriteset.viewport2)
    # Associate help window
    @all_actor_arrow.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * End All Actor Selection - MOBIUS
  #--------------------------------------------------------------------------
  def end_all_actor_select
    # Dispose of enemy arrow
    @all_actor_arrow.dispose
    @all_actor_arrow = nil
    # If command is [fight]
    if @actor_command_window.index == 0
      # Enable actor command window
      @actor_command_window.active = true
      @actor_command_window.visible = true
      @turn_order_window.visible = true
      # Hide help window
      @help_window.visible = false
    end
    # If skill window is showing
    if @skill_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end
    # If item window is showing
    if @item_window != nil
      # Hide turn order window
      @turn_order_window.visible = false
    end 
  end
  #--------------------------------------------------------------------------
  # * Start Skill Selection
  #--------------------------------------------------------------------------
  def start_skill_select
    # Make skill window
    @skill_window = Window_Skill.new(@active_battler)
    # Associate help window
    @skill_window.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * End Skill Selection
  #--------------------------------------------------------------------------
  def end_skill_select
    # Dispose of skill window
    @skill_window.dispose
    @skill_window = nil
    # Hide help window
    @help_window.visible = false
    # Enable actor command window
    @actor_command_window.active = true
    @actor_command_window.visible = true
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * Start Item Selection
  #--------------------------------------------------------------------------
  def start_item_select
    # Make item window
    @item_window = Window_Item.new
    # Associate help window
    @item_window.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * End Item Selection
  #--------------------------------------------------------------------------
  def end_item_select
    # Dispose of item window
    @item_window.dispose
    @item_window = nil
    # Hide help window
    @help_window.visible = false
    # Enable actor command window
    @actor_command_window.active = true
    @actor_command_window.visible = true
    @turn_order_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * Start Big Status Window -- Mobius
  #--------------------------------------------------------------------------
  def start_big_status_window
    @big_status_window.action_battlers = @current_battlers
    @big_status_window.update
    @big_status_window.visible = true
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @turn_order_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * Update Big Status Window -- Mobius
  #--------------------------------------------------------------------------
  def update_big_status_window
     @big_status_window.update
     if Input.trigger?(Input::A) or Input.trigger?(Input::B)
       # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End Turn Order Window
      end_big_status_window
      end
  end
  #--------------------------------------------------------------------------
  # * End Big Status Window -- Mobius
  #--------------------------------------------------------------------------
  def end_big_status_window
    @big_status_window.visible = false
    @turn_order_window.visible = true
    # Enable actor command window
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
  #--------------------------------------------------------------------------
  # * Start Enemy Detail Window -- Mobius
  #--------------------------------------------------------------------------
  def start_enemy_detail_window(enemy)
    # Set enemy detail window's enemy
    @enemy_detail_window.enemy = enemy
    @enemy_detail_window.update
    # Show enemy detail window
    @enemy_detail_window.visible = true
    # Hide turn order window
    @turn_order_window.visible = false
    # Hide help window
    @help_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * Update Enemy Detail Window -- Mobius
  #--------------------------------------------------------------------------
  def update_enemy_detail_window
     @enemy_detail_window.update
     if Input.trigger?(Input::A) or Input.trigger?(Input::B)
       # Play cancel SE
       $game_system.se_play($data_system.cancel_se)
       # End Turn Order Window
       end_enemy_detail_window
     end
  end
  #--------------------------------------------------------------------------
  # * End Enemy Detail Window -- Mobius
  #--------------------------------------------------------------------------
  def end_enemy_detail_window
    # Hide enemy detail window
    @enemy_detail_window.visible = false
    # Show turn order window
    @turn_order_window.visible = true
    # Show help window
    @help_window.visible = true
  end
end

#==============================================================================
# ** Scene_Battle (part 4) 
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # * Start Main Phase
  #--------------------------------------------------------------------------
  def start_phase4
    # Shift to phase 4
    @phase = 4
    @active_battler.blink = false
    @active_battler.charge_reset
    @action_battlers.push(@active_battler)
    # Turn count #MOBIUS: enemies won't attack on "turn 0"
    # Moved to start_phase2 so that enemies can take their first turn
    # $game_temp.battle_turn += 1 

    # Search all battle event pages
    for index in 0...$data_troops[@troop_id].pages.size
      # Get event page
      page = $data_troops[@troop_id].pages[index]
      # If this page span is [turn]
      if page.span == 1
        # Clear action completed flags
        $game_temp.battle_event_flags[index] = false
      end
    end
    # Set actor as unselectable
    @actor_index = -1
    @active_battler = nil
    # Enable party command window
    @party_command_window.active = false
    @party_command_window.visible = false
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Set main phase flag
    $game_temp.battle_main_phase = true
	
    # Make enemy action -- Mobius: Moved to start_phase2, and only runs one 
	# enemy at a time
    #  for enemy in $game_troop.enemies
    #    enemy.make_action
    #  end
    # Make action orders -- Mobius: No longer used
    # make_action_orders
	
    # Shift to step 1
    @phase4_step = 1
  end
  #--------------------------------------------------------------------------
  # * Make Basic Action Results
  #--------------------------------------------------------------------------
  alias mobius_make_basic_action_result make_basic_action_result
  def make_basic_action_result    
    # If guard -- MOBIUS VERSION
    if @active_battler.current_action.basic == 1
      # Display "Guard" in help window
      @help_window.set_text($data_system.words.guard, 1)
      # Return
      return
    end
    # If escape
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      # Display "Escape" in help window
      @help_window.set_text(Mobius::Charge_Turn_Battle::ESCAPE_WORD, 1)
      # Escape
      @active_battler.escape
      return
    end
	mobius_make_basic_action_result
  end

end

#===========================BEASTIARY EXPANSION================================
#==============================================================================
# ** Window_BeastList
#------------------------------------------------------------------------------
#  This window displays a selectable list of beasts
#==============================================================================
class Window_BeastList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize()
    super(200, 0, 440, 160)
    self.back_opacity = 160
    self.z = 100
    @column_max = 2
    @data = $game_party.scan_list.clone.sort
    refresh
    self.visible = true
    self.active = true
    self.index = 0
    # called in super @item_max = 1
    # called in super @column_max = 1
    # called in super @index = -1
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    super
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    # Erase contents
    if self.contents != nil
      self.contents.dispose
    end
    @item_max = @data.size
    # Draw bitmap
    self.contents = Bitmap.new(width - 32, row_max * 32)
    for i in 0...@item_max
      id = @data[i]
      enemy = $data_enemies[id]
      name = enemy ? enemy.name : "???"
      x = 4 + i % @column_max * ( width / @column_max)
      y = i / @column_max * 32
      self.contents.draw_text(x, y, ( width / @column_max), 32, name)
    end      
  end
  #--------------------------------------------------------------------------
  # * Get Enemy
  #--------------------------------------------------------------------------
  def enemy
    return $data_enemies[@data[self.index]]
  end
  
end

#==============================================================================
# ** Window_BeastSprite
#------------------------------------------------------------------------------
#  This window displays the sprite of the selected beast
#==============================================================================
class Window_BeastSprite < Window_Base
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		super(0, 0, 200, 200)
		@enemy = nil
		self.contents = Bitmap.new(width - 32, height - 32)
		self.opacity = 240
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		unless @enemy == nil
			# Clear contents
			self.contents.clear
			# Get sprite bitmap
			enemy_bitmap = RPG::Cache.beastiary_sprite(self.get_filename)
			rect = Rect.new(x, y, contents.width, contents.height)
			# Draw sprite
			draw_bitmap_centered(enemy_bitmap, rect)
		end
		return
		# If filename can't be found, use default battler sprite
		rescue Errno::ENOENT
			enemy_bitmap = RPG::Cache.battler(@enemy.battler_name, 
											   @enemy.battler_hue)
			rect = Rect.new(x, y, contents.width, contents.height)
			draw_bitmap_centered(enemy_bitmap, rect)
	end
	#--------------------------------------------------------------------------
	# * Set Enemy - Calls refresh as needed
	#--------------------------------------------------------------------------
	def enemy=(new_enemy)
		if @enemy == new_enemy
		  return
		else
		  @enemy = new_enemy
		  refresh
		end
	end
	#--------------------------------------------------------------------------
	# * Get Filename - Returns filename for sprite
	#--------------------------------------------------------------------------
	def get_filename
		return @enemy.base_name + Mobius::Charge_Turn_Battle::BEASTIARY_SPRITE_SUFFIX		 
	end
end

#==============================================================================
# ** Window_BeastDetail
#------------------------------------------------------------------------------
#  This window displays detailed information on scanned beasts
#==============================================================================
class Window_BeastDetail < Window_Base
	#--------------------------------------------------------------------------
	# * Public Attributes
	#--------------------------------------------------------------------------
	attr_accessor	:selected
	#--------------------------------------------------------------------------
	# * Object Initialization
	#   - Enemy is an RPG:Enemy or a Game_Enemy
	#--------------------------------------------------------------------------
	def initialize(enemy = nil, in_battle = false)
		@sub_windows = []
		@enemy = enemy
		@in_battle = in_battle
		@sub_window_index = 0
		make_sub_windows
		if in_battle
		  super(0, 0, 640, 320)
		  self.z = 98
		  self.back_opacity = 240
		  self.visible = false
		  @selected = true
		else
		  super(0, 160, 640, 320)
		  self.visible = true
		  @selected = false
		end
		self.contents = Bitmap.new(width - 32, height - 32)				
		refresh		
	end
	#--------------------------------------------------------------------------
	# * Make Sub Windows - Creates the three sub windows
	#--------------------------------------------------------------------------
	def make_sub_windows
		# Create Windows
		for i in 1..3
			@sub_windows.push(Window_BeastSubDetail.new(@enemy, @in_battle, i))
		end
		# If already selected, activate first window
		if @selected
			@sub_windows[@sub_window_index].active = true
		end
	end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    super
	# Update each sub window
	@sub_windows.each {|window| window.update}
	# Input handling
	if @selected
		# Move focus left
		if Input.trigger?(Input::LEFT)
			@sub_windows[@sub_window_index].active = false
			@sub_window_index = (@sub_window_index - 1) % 3
			@sub_windows[@sub_window_index].active = true
		end
		# Move focus right
		if Input.trigger?(Input::RIGHT)
			@sub_windows[@sub_window_index].active = false
			@sub_window_index = (@sub_window_index + 1) % 3
			@sub_windows[@sub_window_index].active = true
		end
	end
  end
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    # Erase contents
    if self.contents != nil
      self.contents.dispose
    end
    return if @enemy == nil
    # Create empty contents
    self.contents = Bitmap.new(width - 32, height - 32)
	# Get color
	color = Mobius::Charge_Turn_Battle::BEASTIARY_DIVIDER_LINE_COLOR
    # Draw name
    self.contents.draw_text(0, 0, contents.width, 32, @enemy.name, 1)
	# Draw header line
    self.contents.fill_rect(0, 32, contents.width, 1, color)
	# Draw divider lines
	self.contents.fill_rect(203, 32 + 4, 1, 288, color)
	self.contents.fill_rect(404, 32 + 4, 1, 288, color)  
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
	super
	@sub_windows.each {|window| window.dispose}
  end
  #--------------------------------------------------------------------------
  # * Set Enemy - Calls refresh as needed
  #--------------------------------------------------------------------------
  def enemy=(enemy)
    if @enemy == enemy
      return
    else
      @enemy = enemy
	  @sub_windows.each {|window| window.enemy = enemy}
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # * Set selected - Selects this window, thereby activating/deactivating sub windows
  #--------------------------------------------------------------------------
  def selected=(boolean)
	if @selected = boolean
		@sub_windows[@sub_window_index].active = true
	else
		@sub_windows.each {|window| window.active = false}
	end
  end
  #--------------------------------------------------------------------------
  # * Set visible - Changes visibility for self and sub windows
  #--------------------------------------------------------------------------
  alias old_visible= visible=
  def visible=(boolean)
	self.old_visible = boolean
	if self.visible
		@sub_windows.each {|window| window.visible = true}
	else
		@sub_windows.each {|window| window.visible = false}
	end
  end  
end

#==============================================================================
# ** Window_BeastSubDetail
#------------------------------------------------------------------------------
#  This window allows for separate scrolling of beast details
#==============================================================================
class Window_BeastSubDetail < Window_Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#	type - 1, 2, 3 --> 1=stats, 2=elements, 3=states
	#--------------------------------------------------------------------------
	def initialize(enemy, in_battle, type)
		# Configuration values - change these two to configure the three windows
		padding = 4
		overlap = 29
		# Calculated values - derived from above two
		w = (640 + (2 * overlap) - (2 * padding)) / 3    # Window Width
		h = 320 - 32                                     # Window Height
		x1 = padding                                     # Stat Window x-coordinate
		x2 = padding + w - overlap                       # Element Window x-coordinate
		x3 = padding + (2 * w) - (2 * overlap)           # State Window x-coordinate
		if in_battle
			y = 4 + 32                                   # All Window y-coordinate
		else
			y = 4 + 160 + 32                             # All Window y-coordinate
		end
		case type
		when 1 ; x = x1
		when 2 ; x = x2
		when 3 ; x = x3
		end
		# Use calculated values to create window
		super(x, y, w, h)
		# Initialize variables
		@enemy = enemy
		@in_battle = in_battle
		@type = type
		@index = 0
		@item_max = 0
		self.active = false
		self.opacity = 0
		self.back_opacity = 0
		self.contents = Bitmap.new(w - 32, h - 32)
		refresh
	end
	#--------------------------------------------------------------------------
	# * refresh
	#--------------------------------------------------------------------------
	def refresh
		# dispose contents
		if self.contents != nil
		  self.contents.dispose
		end
		# reset index
		self.index = 0
		# reset number of items
		@item_max = 0
		unless @enemy == nil
			case @type
			when 1 ; draw_stats
			when 2 ; draw_elements
			when 3 ; draw_states
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Set Enemy - Calls refresh as needed
	#--------------------------------------------------------------------------
	def enemy=(enemy)
		if @enemy == enemy
		  return
		else
		  @enemy = enemy
		  refresh
		end
	end
	#--------------------------------------------------------------------------
	# * Draw Stats - draws an enemy's stats
	#--------------------------------------------------------------------------
	def draw_stats
		# configuration
		padding = 2
		@item_max = 10
		# create bitmap
		self.contents = Bitmap.new(width - 32, @item_max * 32)
		w = self.contents.width - (2 * padding)
		# draw all stats
		for i in 0..9 
			draw_enemy_parameter(@enemy, padding, i * 32, w, 32, i)
		end
	end
	#--------------------------------------------------------------------------
	# * Draw Enemy Parameter
	#     enemy : enemy
	#     x     : draw spot x-coordinate
	#     y     : draw spot y-coordinate
	#     w     : draw spot width
	#     h     : draw spot height
	#     type  : parameter type (0-9)
	#--------------------------------------------------------------------------
	def draw_enemy_parameter(enemy, x, y, w, h, type)
		case type
		when 0
		  parameter_name = $data_system.words.hp
		  parameter_value = enemy.maxhp
		when 1 
		  parameter_name = $data_system.words.sp
		  parameter_value = enemy.maxsp
		when 2 
		  parameter_name = $data_system.words.atk
		  parameter_value = enemy.atk
		when 3 
		  parameter_name = $data_system.words.pdef
		  parameter_value = enemy.pdef
		when 4 
		  parameter_name = $data_system.words.mdef
		  parameter_value = enemy.mdef
		when 5 
		  parameter_name = $data_system.words.str
		  parameter_value = enemy.str
		when 6 
		  parameter_name = $data_system.words.dex
		  parameter_value = enemy.dex
		when 7 
		  parameter_name = $data_system.words.agi
		  parameter_value = enemy.agi
		when 8 
		  parameter_name = $data_system.words.int
		  parameter_value = enemy.int
		when 9 
		  parameter_name = Mobius::Charge_Turn_Battle::BEASTIARY_EVASION_WORD
		  parameter_value = enemy.eva
		end
		# draw stat name
		self.contents.font.color = system_color
		self.contents.draw_text(x, y, w, h, parameter_name)
		# draw stat value
		self.contents.font.color = normal_color
		self.contents.draw_text(x, y, w, h, parameter_value.to_s, 2)
	end
	#--------------------------------------------------------------------------
	# * Draw Elements - draws an enemy's elemental strengths/weaknesses
	#--------------------------------------------------------------------------
	def draw_elements
		# configuration
		padding = 2
		@item_max = $data_system.elements.size - 1
		# create bitmap
		self.contents = Bitmap.new(width - 32, @item_max * 32)
		# draw all elements
		for i in 1...$data_system.elements.size
			draw_element(padding, (i - 1) * 32, width - 32 - (2 * padding), 32, i)
		end
	end
	#--------------------------------------------------------------------------
	# * Draw Element
	#     x           : draw spot x-coordinate
	#     y           : draw spot y-coordinate
	#     w           : draw spot width
	#     h           : draw spot height
	#     element_id  : element_id corresponds to database value
	#--------------------------------------------------------------------------
	def draw_element(x, y, w, h, element_id)
		# get element name
		name = $data_system.elements[element_id]
		# draw name
		self.contents.font.color = system_color
		self.contents.draw_text(x, y, w, h, name, 0)
		# get element rank
		element_rank = element_rank_decode(@enemy.element_ranks[element_id])
		# draw element rank
		self.contents.font.color = normal_color
		self.contents.draw_text(x, y, w, h, element_rank, 2)
	end
	#--------------------------------------------------------------------------
	# * Element Rank Decode - converts integer to string based on customization
	#--------------------------------------------------------------------------
	def element_rank_decode(element_rank)
		case element_rank
		when 1 # Very Weak = 200%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_ELEMENT_WORD_200
		when 2 # Weak = 150%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_ELEMENT_WORD_150
		when 3 # Normal = 100%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_ELEMENT_WORD_100
		when 4 # Resistant = 50%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_ELEMENT_WORD_50
		when 5 # Immune = 0%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_ELEMENT_WORD_0
		when 6 # Absorb = -100%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_ELEMENT_WORD_M100
		end
	end
	#--------------------------------------------------------------------------
	# * Draw States - draws an enemy's status strengths/weaknesses
	#--------------------------------------------------------------------------
	def draw_states
		# configuration
		padding = 2
		@item_max = $data_states.size - 1
		# create bitmap
		self.contents = Bitmap.new(width - 32, @item_max * 32)
		# draw all states
		for i in 1...$data_states.size
			draw_state(padding, (i - 1) * 32, width - 32 - (2 * padding), 32, i)
		end
	end
	#--------------------------------------------------------------------------
	# * Draw State
	#     x           : draw spot x-coordinate
	#     y           : draw spot y-coordinate
	#     w           : draw spot width
	#     h           : draw spot height
	#     state_id    : state_id corresponds to database value
	#--------------------------------------------------------------------------
	def draw_state(x, y, w, h, state_id)
		# get name
		name = $data_states[state_id].name
		# draw name
		self.contents.font.color = system_color
		self.contents.draw_text(x, y, w, h, name, 0)
		# get state rank
		state_rank = state_rank_decode(@enemy.state_ranks[state_id])
		# draw state name
		self.contents.font.color = normal_color
		self.contents.draw_text(x, y, w, h, state_rank, 2)
	end
	#--------------------------------------------------------------------------
	# * State Rank Decode - converts integer to string based on customization
	#--------------------------------------------------------------------------
	def state_rank_decode(state_rank)
		case state_rank
		when 1 # Very Weak = 100%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_STATUS_WORD_100
		when 2 # Weak = 80%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_STATUS_WORD_80
		when 3 # Normal = 60%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_STATUS_WORD_60
		when 4 # Resistant = 40%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_STATUS_WORD_40
		when 5 # Very Resistant = 20%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_STATUS_WORD_20
		when 6 # Immune = 0%
		  return Mobius::Charge_Turn_Battle::BEASTIARY_STATUS_WORD_0
		end
	end
end

#==============================================================================
# ** Scene_Beastiary
#------------------------------------------------------------------------------
#  This class performs beastiary screen processing.
#==============================================================================
class Scene_Beastiary
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Make windows
    @Window_BeastList = Window_BeastList.new
    @Window_BeastDetail = Window_BeastDetail.new
	@Window_BeastSprite = Window_BeastSprite.new
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @Window_BeastList.dispose
    @Window_BeastDetail.dispose
	@Window_BeastSprite.dispose
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
	# Set enemy in windows
    @Window_BeastDetail.enemy = @Window_BeastList.enemy
	@Window_BeastSprite.enemy = @Window_BeastList.enemy
	# Call update
    @Window_BeastList.update
    @Window_BeastDetail.update
	@Window_BeastSprite.update
	# Input handling
	if @Window_BeastDetail.selected
		# When cancel
		if Input.trigger?(Input::B)
			@Window_BeastDetail.selected = false
			@Window_BeastList.active = true
		end
	else
		# When cancel
		if Input.trigger?(Input::B)
		  # Play cancel SE
		  $game_system.se_play($data_system.cancel_se)
		  $scene = Scene_Menu.new()
		end
		# When enter
		if Input.trigger?(Input::C)
			@Window_BeastDetail.selected = true
			@Window_BeastList.active = false
		end
	end
  end
  
end

#=========================BEASTIARY EXPANSION END==============================

#===============================RGSS CHANGES===================================
#==============================================================================
# ** RPG::Enemy changes
#==============================================================================
module RPG
	class Enemy
		alias base_name name
	end		
end
#==============================================================================
# ** RPG::Cache changes
#==============================================================================
module RPG::Cache
	#--------------------------------------------------------------------------
	# * Status icon loading from cache
	#--------------------------------------------------------------------------
	def self.status_icon(filename)
		path = Mobius::Charge_Turn_Battle::STATUS_ICON_PATH
		self.load_bitmap(path, filename)
	end
	#--------------------------------------------------------------------------
	# * Beastiary sprite loading from cache
	#--------------------------------------------------------------------------

	def self.beastiary_sprite(filename)
		path = Mobius::Charge_Turn_Battle::BEASTIARY_SPRITE_PATH
		self.load_bitmap(path, filename)
	end
end
#=============================RGSS CHANGES END=================================
#==============================================================================
# ** Mobius
#------------------------------------------------------------------------------
#  This module is a collection of various, random methods that don't fit 
#  anywhere else, and need to be able to be called from anywhere.
#
#  Author:
#   Mobius XVI
#
#  Usage:
#   All methods are module methods and can be called globally by prefacing the
#   method name with "Mobius", ex. "Mobius.example"
#==============================================================================
module Mobius
	#------------------------------------------------------------------------
	# * Scan Skill - scans an enemy and adds their stats to the beastiary
	#------------------------------------------------------------------------
	def self.scan_skill
		ab = $scene.active_battler
		ti = ab.current_action.target_index
		en = $game_troop.enemies[ti]
		$game_party.scan_list.push(en.id).uniq!
	end
	#------------------------------------------------------------------------
	# * Scan Skill Popup - scans an enemy creates a pop-up window
	#------------------------------------------------------------------------
	def self.scan_skill_popup
		ab = $scene.active_battler
		ti = ab.current_action.target_index
		en = $game_troop.enemies[ti]
		name = en.name
		hp = en.hp ; maxhp = en.maxhp
		sp = en.sp ; maxsp = en.maxsp
		atk = en.atk
		pdef = en.pdef ; mdef = en.mdef
		txt = "#{name} \nHP: #{hp}/#{maxhp}\n"+
		"SP: #{sp}/#{maxsp} \nATK: #{atk} \nPDEF: #{pdef}\n"+
		"MDEF: #{mdef}"
		$game_temp.message_text = txt
		Window_Message.new
	end

end # Module End

# Code by Mobius XVI
# DBS fixes as requested by TheRiotInside
# Changes methods for removing states
# Explanation:
# DBS reduces turn count and removes states at end of turn
# This fixes causes turn count to decrement at end of turn while 
# state removal happens at beginning of turn

# TO BE COMPATIBLE WITH MY CTB SYSTEM
# "Remove states auto" is still called in phase 4 since the only active battler
# in phase 4 is whoever's turn it is, thus they will have there turn count
# decrement by one.
# "Remove states auto start" is called in phase two after determining whose turn
# it is next. That way only the current battler will have their states removed.
class Game_Battler
  #--------------------------------------------------------------------------
  # * Natural Removal of States (called up each end turn)
  #--------------------------------------------------------------------------
  def remove_states_auto
    for i in @states_turn.keys.clone
      if @states_turn[i] > 0
        @states_turn[i] -= 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Natural Removal of States (called up each start turn)
  #--------------------------------------------------------------------------
  def remove_states_auto_start
    for i in @states_turn.keys.clone
      if @states_turn[i] <= 0 and rand(100) < $data_states[i].auto_release_prob
        remove_state(i)
      end
    end
  end
end # Class end