//Preference toggles (it had more bits, but updating player saves without wiping method is a bit more complex).
#define SHOW_ANIMATIONS	16
#define SHOW_PROGBAR	32

#define TOGGLES_DEFAULT (SHOW_ANIMATIONS|SHOW_PROGBAR)

//Chat toggles
#define CHAT_OOC		1
#define CHAT_DEAD		2
#define CHAT_GHOSTEARS	4
#define CHAT_NOCLIENT_ATTACK 8
#define CHAT_PRAYER		16
#define CHAT_RADIO		32
#define CHAT_ATTACKLOGS	64
#define CHAT_DEBUGLOGS	128
#define CHAT_LOOC		256
#define CHAT_GHOSTRADIO 512
#define CHAT_GHOSTNPC	1024
#define CHAT_CKEY		2048

#define TOGGLES_DEFAULT_CHAT (CHAT_OOC|CHAT_DEAD|CHAT_NOCLIENT_ATTACK|CHAT_GHOSTEARS|CHAT_PRAYER|CHAT_RADIO|CHAT_GHOSTRADIO|CHAT_GHOSTNPC|CHAT_ATTACKLOGS|CHAT_LOOC|CHAT_CKEY)


#define PARALLAX_INSANE -1 //for show offs
#define PARALLAX_HIGH    0 //default.
#define PARALLAX_MED     1
#define PARALLAX_LOW     2
#define PARALLAX_DISABLE 3 //this option must be the highest number

#define PARALLAX_THEME_CLASSIC "classic"
#define PARALLAX_THEME_TG      "tgstation"

#define PARALLAX_DELAY_DEFAULT world.tick_lag
#define PARALLAX_DELAY_MED     1
#define PARALLAX_DELAY_LOW     2

#define CHAT_GHOSTSIGHT_ALL        1
#define CHAT_GHOSTSIGHT_ALLMANUAL  2
#define CHAT_GHOSTSIGHT_NEARBYMOBS 3

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
