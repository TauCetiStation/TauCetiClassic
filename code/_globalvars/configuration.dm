var/global/datum/configuration/config = null

var/global/host = null
var/global/join_motd = null
var/global/host_announcements
var/global/list/test_merges
var/global/station_name = "NSS Exodus"
var/global/station_name_ru = "КСН Исход"
var/global/system_name = "Tau Ceti"
var/global/system_name_ru = "Tay Кита"
var/global/game_version = "TauCetiStation"
var/global/game_year = (text2num(time2text(world.realtime, "YYYY")) + 200)
var/global/gamestory_start_year = 2213
var/global/changelog_hash = ""

var/global/list/donators = list()

var/global/aliens_allowed = 1
var/global/ooc_allowed = 1
var/global/looc_allowed = 1
var/global/dsay_allowed = 1
var/global/dooc_allowed = 1
var/global/traitor_scaling = 1
//var/goonsay_allowed = 0
var/global/dna_ident = 1
var/global/abandon_allowed = 1
var/global/guests_allowed = 1
var/global/shuttle_frozen = 0
var/global/shuttle_left = 0
var/global/tinted_weldhelh = 1
var/global/mouse_respawn_time = 5 //Amount of time that must pass between a player dying as a mouse and repawning as a mouse. In minutes.

// Debug is used exactly once (in living.dm) but is commented out in a lot of places.  It is not set anywhere and only checked.
// Debug2 is used in conjunction with a lot of admin verbs and therefore is actually legit.
var/global/Debug = 0	// global debug switch
var/global/Debug2 = 1   // enables detailed job debug file in secrets

var/global/eventchance = 10 //% per 5 mins
var/global/event = 0
var/global/hadevent = 0
var/global/blobevent = 0

//Admin call for slack
var/global/list/ac_nameholder = list()
