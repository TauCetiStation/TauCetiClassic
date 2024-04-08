#define path2text(path) "[path]"

//gets all subtypes of type
#define subtypesof(typepath) ( typesof(typepath) - typepath )

// gets final path from /obj/random, ignores item spawn nothing chance
#define PATH_OR_RANDOM_PATH(path) (ispath(path, /obj/random) ? random2path(path) : path)

//number of deciseconds in a day
#define MIDNIGHT_ROLLOVER 864000

// Define for coders.
// If you want switch conditions to be fully specified in the switch body
// and at the same time the empty condition do nothing.
#define SWITCH_PASS ;


#define TRANSITIONEDGE		7 //Distance from edge to move to another z-level

#define ENGINE_EJECT_Z		3 //Unused now

//HUD styles. Please ensure HUD_VERSIONS is the same as the maximum index. Index order defines how they are cycled in F12.
#define HUD_STYLE_STANDARD 1
#define HUD_STYLE_REDUCED 2
#define HUD_STYLE_NOHUD 3

#define HUD_VERSIONS 3	//used in show_hud()
//1 = standard hud
//2 = reduced hud (just hands and intent switcher)
//3 = no hud (for screenshots)

//SSticker.current_state values
#define GAME_STATE_STARTUP		0
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4

//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

// Doors!
#define DOOR_CRUSH_DAMAGE 20

#define FIREDOOR_MAX_PRESSURE_DIFF 25 // kPa

#define FIREDOOR_MAX_TEMP 50 // °C
#define FIREDOOR_MIN_TEMP 0

#define FIREDOOR_ALERT_HOT  1
#define FIREDOOR_ALERT_COLD 2


//Germs and infection
#define GERM_LEVEL_AMBIENT		110		//maximum germ level you can reach by standing still
#define GERM_LEVEL_MOVE_CAP		200		//maximum germ level you can reach by running around

#define INFECTION_LEVEL_ONE		100
#define INFECTION_LEVEL_TWO		500
#define INFECTION_LEVEL_THREE	1000

#define INFECTION_LEVEL_ONE_PLUS	INFECTION_LEVEL_ONE + ( (INFECTION_LEVEL_TWO - INFECTION_LEVEL_ONE) * 1/3 )
#define INFECTION_LEVEL_ONE_PLUS_PLUS	INFECTION_LEVEL_ONE + ( (INFECTION_LEVEL_TWO - INFECTION_LEVEL_ONE) * 2/3 )
#define INFECTION_LEVEL_TWO_PLUS	INFECTION_LEVEL_TWO + ( (INFECTION_LEVEL_THREE - INFECTION_LEVEL_TWO) * 1/3 )
#define INFECTION_LEVEL_TWO_PLUS_PLUS	INFECTION_LEVEL_TWO + ( (INFECTION_LEVEL_THREE - INFECTION_LEVEL_TWO) * 2/3 )

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

#define shuttle_time_in_station 1800 // 3 minutes in the station
#define shuttle_time_to_arrive 6000 // 10 minutes to arrive

#define EVENT_LEVEL_FEATURE 1
#define EVENT_LEVEL_MUNDANE 2
#define EVENT_LEVEL_MODERATE 3
#define EVENT_LEVEL_MAJOR 4

// shows STORAGE levels deep:
// 1 lvl: item in backpack in src
// 2 lvl: item in box in backpack in src
// 3 lvl: item in matchbox in box in backpack in src
// and so on
#define MAX_STORAGE_DEEP_LEVEL 2

//defines
#define RESIZE_DEFAULT_SIZE 1

//Just space
#define SPACE_ICON_STATE	"[((x + y) ^ ~(x * y) + z) % 25]"

//Material defines
#define MAT_METAL		"metal"
#define MAT_GLASS		"glass"
#define MAT_SILVER		"silver"
#define MAT_GOLD		"gold"
#define MAT_DIAMOND		"diamond"
#define MAT_URANIUM		"uranium"
#define MAT_PHORON		"phoron"
#define MAT_PLASTIC		"plastic"
#define MAT_BANANIUM	"bananium"

#define COIN_GOLD "Gold coin"
#define COIN_SILVER "Silver coin"
#define COIN_DIAMOND "Diamond coin"
#define COIN_IRON "Iron coin"
#define COIN_PHORON "Solid phoron coin"
#define COIN_URANIUM "Uranium coin"
#define COIN_BANANIUM "Bananium coin"
#define COIN_PLATINUM "Platunum coin"
#define COIN_MYTHRIL "Mythril coin"

#define MINERAL_MATERIAL_AMOUNT 2000
//The amount of materials you get from a sheet of mineral like iron/diamond/glass etc

#define APC_MIN_TO_MALF_DECLARE 5
//if malf apcs < than this, malf can't begin the takeover attempt

#define MALF_SMALL_MODULE_PRICE 10
#define MALF_LARGE_MODULE_PRICE 50
//Malf modules prices

// Maploader bounds indices
#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

//Movement dir masks
#define NORTH_SOUTH 3 // NORTH | SOUTH
#define EAST_WEST 12 // EAST | WEST

// Diagonal movement
#define FIRST_DIAG_STEP 1
#define SECOND_DIAG_STEP 2

// Bluespace shelter deploy checks
#define SHELTER_DEPLOY_ALLOWED "allowed"
#define SHELTER_DEPLOY_BAD_TURFS "bad turfs"
#define SHELTER_DEPLOY_BAD_AREA "bad area"
#define SHELTER_DEPLOY_ANCHORED_OBJECTS "anchored objects"

// Cargo-related stuff.
#define MANIFEST_ERROR_CHANCE		5
#define MANIFEST_ERROR_NAME			1
#define MANIFEST_ERROR_CONTENTS		2
#define MANIFEST_ERROR_ITEM			4

//Dummy mob reserve slots
#define DUMMY_HUMAN_SLOT_PREFERENCES "dummy_preference_preview"
#define DUMMY_HUMAN_SLOT_BARBER "dummy_barbet_preview"
#define DUMMY_HUMAN_SLOT_MANIFEST "dummy_manifest_generation"

//teleport checks
#define TELE_CHECK_NONE 0
#define TELE_CHECK_TURFS 1
#define TELE_CHECK_ALL 2

/**
 * Get the turf that `A` resides in, regardless of any containers.
 *
 * Use in favor of `A.loc` or `src.loc` so that things work correctly when
 * stored inside an inventory, locker, or other container.
 */
#define get_turf(A) (get_step(A, 0))

/**
 * Get the ultimate area of `A`, similarly to [get_turf].
 *
 * Use instead of `A.loc.loc`.
 */
#define get_area(A) (isarea(A) ? A : get_step(A, 0)?.loc)

// Door assembly states
#define ASSEMBLY_SECURED       0
#define ASSEMBLY_WIRED         1
#define ASSEMBLY_NEAR_FINISHED 2

//Wet floor type bitflags. Stronger ones should be higher in number.
#define DRY_FLOOR 0
#define WATER_FLOOR 1
#define LUBE_FLOOR  2

#define WORLD_ICON_SIZE 32
#define PIXEL_MULTIPLIER WORLD_ICON_SIZE/32

// (Bay12 = -2), but we don't have that projectile code, so...
#define PROJECTILE_FORCE_MISS -1
#define PROJECTILE_ACTED 0
#define PROJECTILE_ABSORBED 2
#define PROJECTILE_ALL_OK 3

#define RUNE_WORDS list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")

//Error handler defines
#define ERROR_USEFUL_LEN 2

//Filters
#define AMBIENT_OCCLUSION filter(type = "drop_shadow", x = 0, y = -2, size = 4, color = "#04080FAA")

#define CLIENT_FROM_VAR(I) (ismob(I) ? I:client : (istype(I, /client) ? I : (istype(I, /datum/mind) ? I:current?:client : null)))

#define ENTITY_TAB "&nbsp;&nbsp;&nbsp;&nbsp;"

//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

//https://secure.byond.com/docs/ref/info.html#/atom/var/mouse_opacity
#define MOUSE_OPACITY_TRANSPARENT   0
#define MOUSE_OPACITY_ICON          1
#define MOUSE_OPACITY_OPAQUE        2

// Used in browser.dm for common.css style.
#define CSS_THEME_LIGHT     "theme_light"
#define CSS_THEME_DARK      "theme_dark"
#define CSS_THEME_SYNDICATE "theme_syndicate"
#define CSS_THEME_ABDUCTOR  "theme_abductor"

#define BYOND_JOIN_LINK "byond://[BYOND_SERVER_ADDRESS]"
#define BYOND_SERVER_ADDRESS config.server ? "[config.server]" : "[world.address]:[world.port]"

#define DELAY2GLIDESIZE(delay) (world.icon_size / max(CEIL(delay / world.tick_lag), 1))

#define PLASMAGUN_OVERCHARGE 30100

#define VAR_SWAP(A, B)\
	var/temp = A;\
	A = B;\
	B = temp;\

#define LOC_SWAP(A, B)\
	var/atom/temp = A.loc;\
	A.forceMove(B.loc);\
	B.forceMove(temp);\

//! ## Overlays subsystem

///Compile all the overlays for an atom from the cache lists
#define COMPILE_OVERLAYS(A)\
	var/list/ad = A.add_overlays;\
	var/list/rm = A.remove_overlays;\
	if(length(rm)){\
		A.overlays -= rm;\
		rm.Cut();\
	}\
	if(length(ad)){\
		A.overlays |= ad;\
		ad.Cut();\
	}\
	for(var/I in A.alternate_appearances){\
		var/datum/atom_hud/alternate_appearance/AA = A.alternate_appearances[I];\
		if(AA.transfer_overlays){\
			AA.copy_overlays(A, TRUE);\
		}\
	}\
	A.flags_2 &= ~OVERLAY_QUEUED_2;\
	if(isturf(A)){SSdemo.mark_turf(A);}\
	if(isobj(A) || ismob(A)){SSdemo.mark_dirty(A);}\

///Access Region Codes///
#define REGION_ALL			0
#define REGION_GENERAL		1
#define REGION_SECURITY		2
#define REGION_MEDBAY		3
#define REGION_RESEARCH		4
#define REGION_ENGINEERING	5
#define REGION_SUPPLY		6
#define REGION_COMMAND		7
#define REGION_CENTCOMM		8

#define ADD_TO_GLOBAL_LIST(type, list) ##type/atom_init(){\
	. = ..();\
	global.##list += src;}\
##type/Destroy(){\
	global.##list -= src;\
	return ..()}

// Fullscreen overlay resolution in tiles.
#define FULLSCREEN_OVERLAY_RESOLUTION_X 15
#define FULLSCREEN_OVERLAY_RESOLUTION_Y 15

// can_heal proc return values
#define HEAL_EFFECTIVENESS_NONE 0
#define HEAL_EFFECTIVENESS_HALF 0.5
#define HEAL_EFFECTIVENESS_MAX 1

// Calculates the offset n in the dir d.
// For example, if you pass a non-horizontal dir to X_OFFSET, it will always be 0.
// If dir is EAST, then a positive number will be returned, if WEST, then a negative one.
#define X_OFFSET(n_steps, dir) (n_steps * (!!(dir & EAST) + !!(dir & WEST) * -1))
#define Y_OFFSET(n_steps, dir) (n_steps * (!!(dir & NORTH) + !!(dir & SOUTH) * -1))

// strips all newlines from a string, replacing them with null
#define STRIP_NEWLINE(S) replacetextEx(S, "\n", null)

/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

//For crawl_can_use() in /mob/living
#define IS_ABOVE(A, B) (A.layer > B.layer || A.plane > B.plane)

#define CARGOSHOPNAME "ГрузТорг"

// Notification action types for ghosts
#define NOTIFY_JUMP "jump"
#define NOTIFY_ATTACK "attack"
#define NOTIFY_ORBIT "orbit"

#define TEST_MERGE_DEFAULT_TEXT "Loading..."

#define TURF_DECALS_LIMIT 4 // max of /obj/effect/decal/turf_decal in one turf

#define WALLS_COLORS list("blue", "yellow", "red", "purple", "green", "beige")

// todo: do something with this monster
//       port smooth groups from tg/other sane server
#define CAN_SMOOTH_WITH_WALLS list( \
		/turf/unsimulated/wall, \
		/turf/simulated/wall, \
		/turf/simulated/wall/yellow, \
		/turf/simulated/wall/red, \
		/turf/simulated/wall/purple, \
		/turf/simulated/wall/green, \
		/turf/simulated/wall/beige, \
		/turf/simulated/wall/r_wall, \
		/turf/simulated/wall/r_wall/yellow, \
		/turf/simulated/wall/r_wall/red, \
		/turf/simulated/wall/r_wall/purple, \
		/turf/simulated/wall/r_wall/green, \
		/turf/simulated/wall/r_wall/beige, \
		/obj/structure/falsewall, \
		/obj/structure/falsewall/yellow, \
		/obj/structure/falsewall/red, \
		/obj/structure/falsewall/purple, \
		/obj/structure/falsewall/green, \
		/obj/structure/falsewall/beige, \
		/obj/structure/falsewall/reinforced, \
		/obj/structure/falsewall/reinforced/yellow, \
		/obj/structure/falsewall/reinforced/red, \
		/obj/structure/falsewall/reinforced/purple, \
		/obj/structure/falsewall/reinforced/green, \
		/obj/structure/falsewall/reinforced/beige, \
		/obj/structure/girder, \
		/obj/structure/girder/reinforced, \
		/obj/structure/windowsill, \
		/obj/structure/window/fulltile, \
		/obj/structure/window/fulltile/phoron, \
		/obj/structure/window/fulltile/tinted, \
		/obj/structure/window/fulltile/polarized, \
		/obj/structure/window/fulltile/reinforced, \
		/obj/structure/window/fulltile/reinforced/phoron, \
		/obj/structure/window/fulltile/reinforced/tinted, \
		/obj/structure/window/fulltile/reinforced/polarized, \
		/obj/structure/window/fulltile/reinforced/indestructible, \
		/obj/machinery/door/airlock, \
		/obj/machinery/door/airlock/centcom, \
		/obj/machinery/door/airlock/command, \
		/obj/machinery/door/airlock/security, \
		/obj/machinery/door/airlock/engineering, \
		/obj/machinery/door/airlock/medical, \
		/obj/machinery/door/airlock/virology, \
		/obj/machinery/door/airlock/maintenance, \
		/obj/machinery/door/airlock/freezer, \
		/obj/machinery/door/airlock/mining, \
		/obj/machinery/door/airlock/atmos, \
		/obj/machinery/door/airlock/research, \
		/obj/machinery/door/airlock/science, \
		/obj/machinery/door/airlock/neutral, \
		/obj/machinery/door/airlock/highsecurity, \
		/obj/machinery/door/airlock/vault, \
		/obj/machinery/door/airlock/external, \
		/obj/machinery/door/airlock/glass, \
		/obj/machinery/door/airlock/command/glass, \
		/obj/machinery/door/airlock/engineering/glass, \
		/obj/machinery/door/airlock/security/glass, \
		/obj/machinery/door/airlock/medical/glass, \
		/obj/machinery/door/airlock/virology/glass, \
		/obj/machinery/door/airlock/research/glass, \
		/obj/machinery/door/airlock/mining/glass, \
		/obj/machinery/door/airlock/atmos/glass, \
		/obj/machinery/door/airlock/science/glass, \
		/obj/machinery/door/airlock/science/neutral, \
		/obj/machinery/door/airlock/maintenance_hatch, \
)

#define SMOOTH_ADAPTERS_WALLS list( \
		/turf/simulated/wall = "wall", \
		/obj/structure/falsewall = "wall", \
		/obj/machinery/door/airlock = "wall", \
)

// wall don't need adapter with another wall
#define SMOOTH_ADAPTERS_WALLS_FOR_WALLS list( \
		/obj/machinery/door/airlock = "wall", \
)
