var/global/obj/effect/overlay/plmaster = null
var/global/obj/effect/overlay/slmaster = null

// nanomanager, the manager for Nano UIs
var/global/datum/nanomanager/nanomanager = new()

// Announcer intercom, because too much stuff creates an intercom for one message then hard del()s it.
var/global/obj/item/device/radio/intercom/global_announcer

var/global/list/paper_tag_whitelist = list("center","p","div","span","h1","h2","h3","h4","h5","h6","hr","pre",	\
	"big","small","font","i","u","b","s","sub","sup","tt","br","hr","ol","ul","li","caption","col",	\
	"table","td","th","tr")
var/global/list/paper_blacklist = list("java","onblur","onchange","onclick","ondblclick","onfocus","onkeydown",	\
	"onkeypress","onkeyup","onload","onmousedown","onmousemove","onmouseout","onmouseover",	\
	"onmouseup","onreset","onselect","onsubmit","onunload")

var/global/gravity_is_on = 1
#define TAB "&nbsp;&nbsp;&nbsp;&nbsp;"
var/global/visual_counter = 1

var/global/list/greek_pronunciation = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

// Icons that appear on the Round End pop-up browser
var/global/list/end_icons = list()
var/global/endgame_scoreboard

// Xenomorphs
var/global/facehuggers_control_type = FACEHUGGERS_PLAYABLE

// Unsorted stuff
var/global/global_message_cooldown = 1
var/global/list/stealth_keys = list()
var/global/list/ignore_vision_inside = list(
	/obj/mecha,
	/obj/machinery/abductor/experiment,
	/obj/machinery/atmospherics/components/unary/cryo_cell,
	/obj/machinery/bodyscanner,
	/obj/machinery/clonepod,
	/obj/machinery/dna_scannernew,
	/obj/machinery/sleeper,
	/obj/effect/dummy,
	/obj/structure/droppod,
	/obj/item/organ/external/head/skeleton,
	)

// Is initiated in setup_religions(). Used to save all info about chaplain's religion.
var/global/datum/religion/chaplain/chaplain_religion
// Cultists religion. You/I can change it?
var/global/datum/religion/cult/cult_religion
var/global/list/datum/religion/all_religions = list()

//Used for global activation of pylons
var/global/list/pylons = list()

var/global/wizard_shades_count = 0
var/global/peacekeeper_shields_count = 0
var/global/timezoneOffset = 0       // The difference betwen midnight (of the host computer) and 0 world.ticks.
var/global/gametime_offset = 12 HOURS //Deciseconds to add to world.time for station time.

var/global/playsound_frequency_admin = 0	// Admin var for shitspawn via Secrets panel
