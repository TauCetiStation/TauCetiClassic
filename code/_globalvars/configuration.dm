var/datum/configuration/config = null

var/host = null
var/join_motd = null
var/host_announcements
var/join_test_merge = null
var/test_merges
var/station_name = "NSS Exodus"
var/system_name = "Tau Ceti"
var/game_version = "TauCetiStation"
var/game_year = (text2num(time2text(world.realtime, "YYYY")) + 200)
var/gamestory_start_year = 2213
var/changelog_hash = ""

var/list/donators = list()

var/aliens_allowed = FALSE
var/ooc_allowed = TRUE
var/looc_allowed = TRUE
var/dsay_allowed = TRUE
var/dooc_allowed = TRUE
var/traitor_scaling = TRUE
//var/goonsay_allowed = FALSE
var/dna_ident = TRUE
var/abandon_allowed = TRUE
var/enter_allowed = TRUE
var/guests_allowed = TRUE
var/shuttle_frozen = FALSE
var/shuttle_left = FALSE
var/tinted_weldhelh = TRUE
var/mouse_respawn_time = 5 //Amount of time that must pass between a player dying as a mouse and repawning as a mouse. In minutes.

// Debug is used exactly once (in living.dm) but is commented out in a lot of places.  It is not set anywhere and only checked.
// Debug2 is used in conjunction with a lot of admin verbs and therefore is actually legit.
var/Debug = 0	// global debug switch
var/Debug2 = 1   // enables detailed job debug file in secrets

//This was a define, but I changed it to a variable so it can be changed in-game.(kept the all-caps definition because... code...) -Errorage
var/MAX_EXPLOSION_RANGE = 14

var/eventchance = 10 //% per 5 mins
var/event = FALSE
var/hadevent = FALSE
var/blobevent = FALSE

//Admin call for slack
var/list/ac_nameholder = list()
