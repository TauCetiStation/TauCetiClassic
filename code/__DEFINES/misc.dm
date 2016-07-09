//gets all subtypes of type
#define subtypesof(typepath) ( typesof(typepath) - typepath )

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

//zlevel defines, can be overriden for different maps in the appropriate _maps file.
#define ZLEVEL_STATION  	1
#define ZLEVEL_CENTCOMM 	2 //EI NATH!!
#define ZLEVEL_CENTCOM  	2
#define ZLEVEL_TELECOMMS	3
#define ZLEVEL_DERELICT		4
#define ZLEVEL_ASTEROID 	5
#define ZLEVEL_EMPTY	 	6

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

//ticker.current_state values
#define GAME_STATE_STARTUP		0
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4

//Object specific defines
#define CANDLE_LUM 3 //For how bright candles are

//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

// Doors!
#define DOOR_CRUSH_DAMAGE 10

//Germs and infection
#define GERM_LEVEL_AMBIENT		110		//maximum germ level you can reach by standing still
#define GERM_LEVEL_MOVE_CAP		200		//maximum germ level you can reach by running around

#define INFECTION_LEVEL_ONE		100
#define INFECTION_LEVEL_TWO		500
#define INFECTION_LEVEL_THREE	1000

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

//some colors
#define COLOR_RED 		"#FF0000"
#define COLOR_GREEN 	"#00FF00"
#define COLOR_BLUE 		"#0000FF"
#define COLOR_CYAN 		"#00FFFF"
#define COLOR_PINK 		"#FF00FF"
#define COLOR_YELLOW 	"#FFFF00"
#define COLOR_ORANGE 	"#FF9900"
#define COLOR_WHITE 	"#FFFFFF"

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

#define shuttle_time_in_station 1800 // 3 minutes in the station
#define shuttle_time_to_arrive 6000 // 10 minutes to arrive

//Flags for zone sleeping
#define ZONE_ACTIVE 	1
#define ZONE_SLEEPING 	0

#define LIGHTING_LAYER 10

#define FOR_DVIEW(type, range, center, invis_flags) \
	dview_mob.loc = center; \
	dview_mob.see_invisible = invis_flags; \
	for(type in view(range, dview_mob))
#define END_FOR_DVIEW dview_mob.loc = null

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
#define MAT_BANANIUM	"$bananium"

#define MINERAL_MATERIAL_AMOUNT 2000
//The amount of materials you get from a sheet of mineral like iron/diamond/glass etc

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

//from /tg/, must be rewriten
//#define TURF_LAYER 2 //For easy recordkeeping; this is a byond define
#define ABOVE_OPEN_TURF_LAYER 2.01
#define CLOSED_TURF_LAYER 2.05
#define ABOVE_NORMAL_TURF_LAYER 2.08
#define LATTICE_LAYER 2.2
#define DISPOSAL_PIPE_LAYER 2.3
#define GAS_PIPE_LAYER 2.35
#define WIRE_LAYER 2.4
#define WIRE_TERMINAL_LAYER 2.45
#define LOW_OBJ_LAYER 2.5

#define BELOW_OPEN_DOOR_LAYER 2.6
#define OPEN_DOOR_LAYER 2.7
#define PROJECTILE_HIT_THRESHHOLD_LAYER 2.75 //projectiles won't hit objects at or below this layer if possible
#define TABLE_LAYER 2.8
#define BELOW_OBJ_LAYER 2.9
#define LOW_ITEM_LAYER 2.95
//#define OBJ_LAYER 3 //For easy recordkeeping; this is a byond define
#define CLOSED_DOOR_LAYER 3.1
#define CLOSED_FIREDOOR_LAYER 3.11
#define ABOVE_OBJ_LAYER 3.2
#define ABOVE_WINDOW_LAYER 3.3
#define SIGN_LAYER 3.4
#define HIGH_OBJ_LAYER 3.5

#define BELOW_MOB_LAYER 3.7
#define LYING_MOB_LAYER 3.8