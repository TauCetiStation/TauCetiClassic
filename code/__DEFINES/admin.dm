//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC			1
#define MUTE_OOC		2
#define MUTE_PRAY		4
#define MUTE_ADMINHELP	8
#define MUTE_DEADCHAT	16
#define MUTE_MENTORHELP	32
#define MUTE_ALL		63

//Number of identical messages required to get the spam-prevention automute thing to trigger warnings and automutes
#define SPAM_TRIGGER_WARNING  5
#define SPAM_TRIGGER_AUTOMUTE 10

//Some constants for DB_Ban
#define BANTYPE_PERMA		1
#define BANTYPE_TEMP		2
#define BANTYPE_JOB_PERMA	3
#define BANTYPE_JOB_TEMP	4
#define BANTYPE_ANY_FULLBAN	5 //used to locate stuff to unban.
#define BANTYPE_ANY_JOB		9 //used to remove jobbans

#define BANTYPE_PERMA_STR		"PERMABAN"
#define BANTYPE_TEMP_STR		"TEMPBAN"
#define BANTYPE_JOB_PERMA_STR	"JOB_PERMABAN"
#define BANTYPE_JOB_TEMP_STR	"JOB_TEMPBAN"
#define BANTYPE_ANY_FULLBAN_STR	"ANY"
#define BANTYPE_ANY_JOB_STR		"ANYJOB"

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

#define ADMIN_QUE(user) "(<a href='?_src_=holder;adminmoreinfo=\ref[user]'>?</a>)"
#define ADMIN_FLW(target) "(<a href='?_src_=holder;adminplayerobservefollow=\ref[target]'>FLW</a>)"
#define ADMIN_JMP(target) "(<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>)"
#define ADMIN_VV(target) "(<a href='?_src_=vars;Vars=\ref[target]'>VV</a>)"
#define ADMIN_PP(user)  "(<a href='?_src_=holder;adminplayeropts=\ref[user]'>PP</a>)"
#define ADMIN_SM(user) "(<a href='?_src_=holder;subtlemessage=\ref[user]'>SM</a>)"
#define ADMIN_TP(user) "(<a href='?_src_=holder;traitor=\ref[user]'>TP</a>)"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_PPJMPFLW(user) "[ADMIN_PP(user)] [ADMIN_FLW(user)] [ADMIN_JMP(user)]"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)]"

#define AHELP_ACTIVE 1
#define AHELP_CLOSED 2
#define AHELP_RESOLVED 3

#define AHELP_REPLY 1 // actually not used anywhere, remove this comment otherwise.
#define MHELP_REPLY 2

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