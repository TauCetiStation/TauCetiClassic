var/global/obj/effect/overlay/plmaster = null
var/global/obj/effect/overlay/slmaster = null

// nanomanager, the manager for Nano UIs
var/datum/nanomanager/nanomanager = new()

// Announcer intercom, because too much stuff creates an intercom for one message then hard del()s it.
var/global/obj/item/device/radio/intercom/global_announcer

var/list/paper_tag_whitelist = list("center","p","div","span","h1","h2","h3","h4","h5","h6","hr","pre",	\
	"big","small","font","i","u","b","s","sub","sup","tt","br","hr","ol","ul","li","caption","col",	\
	"table","td","th","tr")
var/list/paper_blacklist = list("java","onblur","onchange","onclick","ondblclick","onfocus","onkeydown",	\
	"onkeypress","onkeyup","onload","onmousedown","onmousemove","onmouseout","onmouseover",	\
	"onmouseup","onreset","onselect","onsubmit","onunload")

var/gravity_is_on = 1
var/TAB = "&nbsp;&nbsp;&nbsp;&nbsp;"
var/visual_counter = 1

//Goonstyle scoreboard
// NOW AN ASSOCIATIVE LIST
// NO FUCKING EXCUSE FOR THE ATROCITY THAT WAS
var/list/score=list(
	"crewscore"      = 0, // this is the overall var/score for the whole round
	"stuffshipped"   = 0, // how many useful items have cargo shipped out?
	"stuffharvested" = 0, // how many harvests have hydroponics done?
	"oremined"       = 0, // obvious
	"researchdone"   = 0,
	"eventsendured"  = 0, // how many random events did the station survive?
	"powerloss"      = 0, // how many APCs have poor charge?
	"escapees"       = 0, // how many people got out alive?
	"deadcrew"       = 0, // dead bodies on the station, oh no
	"mess"           = 0, // how much poo, puke, gibs, etc went uncleaned
	"meals"          = 0,
	"disease"        = 0, // how many rampant, uncured diseases are on board the station
	"deadcommand"    = 0, // used during rev, how many command staff perished
	"arrested"       = 0, // how many traitors/revs/whatever are alive in the brig
	"traitorswon"    = 0, // how many traitors were successful?
	"roleswon"        = 0, // how many roles were successful?
	"allarrested"    = 0, // did the crew catch all the enemies alive?
	"opkilled"       = 0, // used during nuke mode, how many operatives died?
	"disc"           = 0, // is the disc safe and secure?
	"nuked"          = 0, // was the station blown into little bits?

	// these ones are mainly for the stat panel
	"powerbonus"    = 0, // if all APCs on the station are running optimally, big bonus
	"messbonus"     = 0, // if there are no messes on the station anywhere, huge bonus
	"deadaipenalty" = 0, // is the AI dead? if so, big penalty
	"foodeaten"     = 0, // nom nom nom
	"clownabuse"    = 0, // how many times a clown was punched, struck or otherwise maligned
	"richestname"   = null, // this is all stuff to show who was the richest alive on the shuttle
	"richestjob"    = null,  // kinda pointless if you dont have a money system i guess
	"richestcash"   = 0,
	"richestkey"    = null,
	"dmgestname"    = null, // who had the most damage on the shuttle (but was still alive)
	"dmgestjob"     = null,
	"dmgestdamage"  = 0,
	"dmgestkey"     = null
)

var/global/list/achievements = list()


// Icons that appear on the Round End pop-up browser
var/global/list/end_icons = list()
var/endgame_info_logged = 0

// Unsorted stuff
var/global_message_cooldown = 1
var/list/stealth_keys = list()
var/list/ignore_vision_inside = list(
	/obj/mecha,
	/obj/machinery/abductor/experiment,
	/obj/machinery/atmospherics/unary/cryo_cell,
	/obj/machinery/bodyscanner,
	/obj/machinery/clonepod,
	/obj/machinery/dna_scannernew,
	/obj/machinery/sleeper,
	/obj/effect/dummy
	)
