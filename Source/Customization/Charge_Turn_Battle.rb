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
    BOSS_LIST = []

    # The following options all allow you to set display words similar to how you can set
    # custom words in the database for HP, SP, etc.
    ESCAPE_WORD = "Escape"
    BATTLERS_WORD = "Battlers"
    STATUS_WORD = "Status"
    MAXHP_WORD = "MAXHP"
    MAXSP_WORD = "MAXSP"

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
  end
end
