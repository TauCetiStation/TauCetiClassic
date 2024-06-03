// this can be little confusing, but call it as you would call
// /datum/preferences/proc/get_pref(type)
// ex. client.prefs.get_pref()
#define get_pref(type) player_settings[type].value

// pref types
#define PREF_TYPE_BOOLEAN "boolean"
#define PREF_TYPE_TEXT    "text"
//#define PREF_TYPE_INTEGER "integer"
#define PREF_TYPE_RANGE   "range"
#define PREF_TYPE_SELECT  "select"
#define PREF_TYPE_HEX     "hex"

// pref domains (categories)
#define PREF_DOMAIN_PLAYER     "player"
#define PREF_DOMAIN_KEYBINDS   "keybinds"
#define PREF_DOMAIN_META       "meta"
#define PREF_DOMAIN_CHARACTER  "character" // todo

// player pref domain subcategories
#define PREF_PLAYER_UI "ui"
#define PREF_PLAYER_GRAPHICS "graphics"
#define PREF_PLAYER_AUDIO "audio"
#define PREF_PLAYER_CHAT "chat"
#define PREF_PLAYER_GAME "game"
#define PREF_PLAYER_KEYBINDS "keybinds"

///datum/pref/player/graphics/glowlevel
#define GLOW_HIGH    "high"
#define GLOW_MED     "med"
#define GLOW_LOW     "low"
#define GLOW_DISABLE "disable"

///datum/pref/player/graphics/parallax
#define PARALLAX_INSANE  "insane"  //for show offs
#define PARALLAX_HIGH    "high"    //default.
#define PARALLAX_MED     "med"
#define PARALLAX_LOW     "low"
#define PARALLAX_DISABLE "disable"

#define PARALLAX_DELAY_DEFAULT world.tick_lag
#define PARALLAX_DELAY_MED     1
#define PARALLAX_DELAY_LOW     2

///datum/pref/player/chat/attack_log
#define ATTACK_LOG_DISABLED "disabled"
#define ATTACK_LOG_BY_CLIENT "by_client"
//#define ATTACK_LOG_BOTH_CLIENT "both_client" // todo
#define ATTACK_LOG_ALL "all"

//used for alternate_option
#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2

// Job preference levels.
#define JP_LOW 1
#define JP_MEDIUM 2
#define JP_HIGH 3
// Order is of the essence apperantly. From highest order to lowest.
#define JP_LEVELS list(JP_HIGH, JP_MEDIUM, JP_LOW)

#define TOOLTIP_NORTH "TOP+0.1, CENTER-3"

//recommened client FPS
#define RECOMMENDED_FPS 100 // consider updating preferences if you change this value, or else it will be used only for new players

// ui themes
#define UI_STYLE_WHITE "White"
#define UI_STYLE_MIDNIGHT "Midnight"
#define UI_STYLE_OLD "Old"
#define UI_STYLE_ORANGE "Orange"
