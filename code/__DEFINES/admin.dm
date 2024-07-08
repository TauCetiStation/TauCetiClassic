// ban types
#define BANTYPE_PERMA        "PERMABAN"
#define BANTYPE_TEMP         "TEMPBAN"
#define BANTYPE_JOB_PERMA    "JOB_PERMABAN"
#define BANTYPE_JOB_TEMP     "JOB_TEMPBAN"
#define BANTYPE_CHAT_PERMA   "CHAT_PERMABAN"
#define BANTYPE_CHAT_TEMP    "CHAT_TEMPBAN"

var/global/list/valid_ban_types = list(BANTYPE_PERMA, BANTYPE_TEMP, BANTYPE_JOB_PERMA, BANTYPE_JOB_TEMP, BANTYPE_CHAT_PERMA, BANTYPE_CHAT_TEMP)

// bitflags for client chat bans
#define MUTE_NONE  0
#define MUTE_IC    (1<<0) // say/me
#define MUTE_OOC   (1<<1) // ooc/looc/ghostchat
#define MUTE_PRAY  (1<<2) // pray
#define MUTE_PM    (1<<3) // mentorhelp/adminhelp

// text representation for ban database
var/global/list/mute_ban_bitfield = list(
	"IC" = MUTE_IC,
	"OOC" = MUTE_OOC,
	"PRAY" = MUTE_PRAY,
	"PM" = MUTE_PM,
)

// number of identical messages required to get the spam-prevention automute thing to trigger warnings and automutes
#define SPAM_TRIGGER_WARNING  5
#define SPAM_TRIGGER_AUTOMUTE 10

#define STICKYBAN_TABLENAME "erro_stickyban"
#define STICKYBAN_CKEY_MATCHED_TABLENAME "erro_stickyban_matched_ckey"
#define STICKYBAN_CID_MATCHED_TABLENAME "erro_stickyban_matched_cid"
#define STICKYBAN_IP_MATCHED_TABLENAME "erro_stickyban_matched_ip"

// admin cooldowns
#define ADMIN_CD_IC    "IC"
#define ADMIN_CD_OOC   "OOC"
#define ADMIN_CD_PRAY  "PRAY"
#define ADMIN_CD_PM    "PM"

var/global/list/admin_cooldowns_list = list(
	ADMIN_CD_IC,
	ADMIN_CD_OOC,
	ADMIN_CD_PRAY,
	ADMIN_CD_PM,
)

#define IS_ON_ADMIN_CD(client, type) (LAZYACCESS(client.prefs.admin_cooldowns, type) > world.time)

//Please don't edit these values without speaking to Errorage first	~Carn
//Admin Permissions
#define R_BUILDMODE		1
#define R_ADMIN			2
#define R_BAN			4
#define R_FUN			8
#define R_SERVER		16
#define R_DEBUG			32
#define R_POSSESS		64
#define R_PERMISSIONS	128
#define R_STEALTH		256
#define R_REJUVINATE	512
#define R_VAREDIT		1024
#define R_SOUNDS		2048
#define R_SPAWN			4096
#define R_WHITELIST		8192
#define R_EVENT			16384
#define R_LOG			32768

#define R_MAXPERMISSION 32768 //This holds the maximum value for a permission. It is used in iteration, so keep it updated.

#define R_HOST			65535

#define ADMIN_RANK_ROUND   "Temporary Round Admin"
#define ADMIN_RANK_SANDBOX "Sandbox Admin"
#define ADMIN_RANK_REMOVED "Removed"

#define ADMIN_QUE(user) "(<a href='?_src_=holder;adminmoreinfo=\ref[user]'>?</a>)"
#define ADMIN_FLW(target) "(<a href='?_src_=holder;adminplayerobservefollow=\ref[target]'>FLW</a>)"
#define ADMIN_JMP(target) "(<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>)"
#define ADMIN_VV(target) "(<a href='?_src_=vars;Vars=\ref[target]'>VV</a>)"
#define ADMIN_PP(user)  "(<a href='?_src_=holder;adminplayeropts=\ref[user]'>PP</a>)"
#define ADMIN_SM(user) "(<a href='?_src_=holder;subtlemessage=\ref[user]'>SM</a>)"
#define ADMIN_TP(user) "(<a href='?_src_=holder;traitor=\ref[user]'>TP</a>)"
#define ADMIN_KICK(user) "(<a href='?_src_=holder;boot2=\ref[user]'>KICK</a>)"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_PPJMPFLW(user) "[ADMIN_PP(user)] [ADMIN_FLW(user)] [ADMIN_JMP(user)]"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)]"

#define COORD(A) "[A ? A.Admin_Coordinates_Readable() : "nonexistent location"]"
#define AREACOORD(A) "[A ? A.Admin_Coordinates_Readable(TRUE) : "nonexistent location"]"

/atom/proc/Admin_Coordinates_Readable(area_name, admin_jump_ref)
	var/turf/T = Safe_COORD_Location()
	return T ? "[area_name ? "[get_area_name(T)] " : ""]([T.x],[T.y],[T.z])[admin_jump_ref ? " [ADMIN_JMP(T)]" : ""]" : "nonexistent location"

// +- tg placeholder
/atom/proc/Safe_COORD_Location()
	return get_step(src, 0) //resolve where the thing is.

/turf/Safe_COORD_Location()
	return src

#define AHELP_ACTIVE 1
#define AHELP_CLOSED 2
#define AHELP_RESOLVED 3

#define AHELP_REPLY 1 // actually not used anywhere, remove this comment otherwise.
#define MHELP_REPLY 2

///Max length of a keypress command before it's considered to be a forged packet/bogus command
#define MAX_KEYPRESS_COMMANDLENGTH 16
///Maximum keys that can be bound to one button
#define MAX_COMMANDS_PER_KEY 5
///Maximum keys per keybind
#define MAX_KEYS_PER_KEYBIND 3
///Max amount of keypress messages per second over two seconds before client is autokicked
#define MAX_KEYPRESS_AUTOKICK 50
///Length of held key buffer
#define HELD_KEY_BUFFER_LENGTH 15

#define STICKYBAN_DB_CACHE_TIME    10 SECONDS // DB update cache
#define STICKYBAN_ROGUE_CHECK_TIME 5 // Timeout for rogue check

// Byond ban system list keys
#define BANKEY_TYPE      "type" //The ban's type, if any. It can be "sticky", "session", or "time"
#define BANKEY_CKEY      "ckey" // Ckey of banned user
#define BANKEY_REASON    "reason" // The reason the ban was implemented; Admin only
#define BANKEY_MSG       "message" // A message to display to the user.
#define BANKEY_KEYS      "keys" // Other keys caught in a sticky ban.
#define BANKEY_IP        "IP" // Other IP addresses caught in a sticky ban.
#define BANKEY_CID       "computer_id" // Other computer_id values caught in a sticky ban.
#define BANKEY_TIME      "time" // The number of seconds remaining in the ban.
#define BANKEY_WHITELIST "whitelist"
// Custom ban keys
#define BANKEY_ADMIN     "admin"   // Ckey on author ban
#define BANKEY_FROMDB    "fromdb" // When ban cached in DB
// Only cache keys
#define BANKEY_TIMEOUT   "timeout" // Temporary disable (DB require for restore)
#define BANKEY_REVERT    "reverting"
// Only cache keys. Lists lazy and key may not exists
#define BANKEY_MATCHES_THIS_ROUND       "matches_this_round"
#define BANKEY_ADMIN_MATCHES_THIS_ROUND     "admin_matches_this_round"
#define BANKEY_EXISTING_USER_MATCHES    "existing_user_matches_this_round"
#define BANKEY_PENDING_MATCHES      "pending_matches_this_round"

#define GUARD_CHECK_AGE 60

// Staffwho
#define SW_ADMINS     1
#define SW_MENTORS    2
#define SW_XENOVISORS 3
#define SW_DEVELOPERS 4
#define SW_ALL_GROUPS 4 //update this, if add more staff groups

var/global/list/default_admin_names = list(
	SW_ADMINS     = "Admins",
	SW_MENTORS    = "Mentors",
	SW_XENOVISORS = "Xenovisors",
	SW_DEVELOPERS = "Developers",
)
