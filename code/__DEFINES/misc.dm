//gets all subtypes of type
#define subtypesof(typepath) ( typesof(typepath) - typepath )

//number of deciseconds in a day
#define MIDNIGHT_ROLLOVER 864000

//singularity defines
#define STAGE_ONE	1
#define STAGE_TWO	3
#define STAGE_THREE	5
#define STAGE_FOUR	7
#define STAGE_FIVE	9
#define STAGE_SIX	11 //From supermatter shard

//Ghost orbit types:
#define GHOST_ORBIT_CIRCLE		"circle"
#define GHOST_ORBIT_TRIANGLE	"triangle"
#define GHOST_ORBIT_HEXAGON		"hexagon"
#define GHOST_ORBIT_SQUARE		"square"
#define GHOST_ORBIT_PENTAGON	"pentagon"

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

#define EVENT_LEVEL_MUNDANE 1
#define EVENT_LEVEL_MODERATE 2
#define EVENT_LEVEL_MAJOR 3

//defines
#define RESIZE_DEFAULT_SIZE 1

//Just space
#define SPACE_ICON_STATE	"[((x + y) ^ ~(x * y) + z) % 25]"

//Material defines
#define MAT_METAL		"$metal"
#define MAT_GLASS		"$glass"
#define MAT_SILVER		"$silver"
#define MAT_GOLD		"$gold"
#define MAT_DIAMOND		"$diamond"
#define MAT_URANIUM		"$uranium"
#define MAT_PHORON		"$phoron"
#define MAT_PLASTIC		"$plastic"
#define MAT_BANANIUM	"$bananium"

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

#define APC_BONUS_WITH_INTERCEPT 4
//If AI intercepts message, he can hack additional APC_BONUS_WITH_INTERCEPT APCs without attracting attention

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


//teleport checks
#define TELE_CHECK_NONE 0
#define TELE_CHECK_TURFS 1
#define TELE_CHECK_ALL 2

//get_turf(): Returns the turf that contains the atom.
//Example: A fork inside a box inside a locker will return the turf the locker is standing on.
#define get_turf(A) (get_step(A, 0))

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
#define PROJECTILE_ACTED 0 // it means that something else has took control of bullet_act() proc and it didn't run till the end.
#define PROJECTILE_ABSORBED 2
#define PROJECTILE_ALL_OK 3

#define COORD(A) "([A.x],[A.y],[A.z])"

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
#define CSS_THEME_LIGHT "theme_light"
#define CSS_THEME_DARK "theme_dark"

#define BYOND_JOIN_LINK "byond://[BYOND_SERVER_ADDRESS]"
#define BYOND_SERVER_ADDRESS config.server ? "[config.server]" : "[world.address]:[world.port]"

//Facehugger's control type
#define FACEHUGGERS_STATIC_AI     0   // don't move by themselves
#define FACEHUGGERS_DYNAMIC_AI    1   // controlled by simple AI
#define FACEHUGGERS_PLAYABLE      2   // controlled by players

//Time it takes to impregnate someone with facehugger
#define MIN_IMPREGNATION_TIME 200
#define MAX_IMPREGNATION_TIME 250

#define DELAY2GLIDESIZE(delay) (world.icon_size / max(CEIL(delay / world.tick_lag), 1))

#define PLASMAGUN_OVERCHARGE 30100

//! ## Overlays subsystem

///Compile all the overlays for an atom from the cache lists
#define COMPILE_OVERLAYS(A)\
	if (TRUE) {\
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
		A.flags_2 &= ~OVERLAY_QUEUED_2;\
		if(isturf(A)){SSdemo.mark_turf(A);}\
		if(isobj(A) || ismob(A)){SSdemo.mark_dirty(A);}\
	}