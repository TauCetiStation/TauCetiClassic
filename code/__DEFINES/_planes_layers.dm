/*This file is a list of all preclaimed planes & layers

All planes & layers should be given a value here instead of using a magic/arbitrary number.

After fiddling with planes and layers for some time, I figured I may as well provide some documentation:

What are planes?
	Think of Planes as a sort of layer for a layer - if plane X is a larger number than plane Y, the highest number for a layer in X will be below the lowest
	number for a layer in Y.
	Planes also have the added bonus of having planesmasters.

What are Planesmasters?
	Planesmasters, when in the sight of a player, will have its appearance properties (for example, colour matrices, alpha, transform, etc)
	applied to all the other objects in the plane. This is all client sided.
	Usually you would want to add the planesmaster as an invisible image in the client's screen.

What can I do with Planesmasters?
	You can: Make certain players not see an entire plane,
	Make an entire plane have a certain colour matrices,
	Make an entire plane transform in a certain way,
	Make players see a plane which is hidden to normal players - I intend to implement this with the antag HUDs for example.
	Planesmasters can be used as a neater way to deal with client images or potentially to do some neat things

How do planes work?
	A plane can be any integer from -100 to 100. (If you want more, bug lummox.)
	All planes above 0, the 'base plane', are visible even when your character cannot 'see' them, for example, the HUD.
	All planes below 0, the 'base plane', are only visible when a character can see them.

How do I add a plane?
	Think of where you want the plane to appear, look through the pre-existing planes and find where it is above and where it is below
	Slot it in in that place, and change the pre-existing planes, making sure no plane shares a number.
	Add a description with a comment as to what the plane does.

How do I make something a planesmaster?
	Add the PLANE_MASTER appearance flag to the appearance_flags variable.

What is the naming convention for planes or layers?
	Make sure to use the name of your object before the _LAYER or _PLANE, eg: [NAME_OF_YOUR_OBJECT HERE]_LAYER or [NAME_OF_YOUR_OBJECT HERE]_PLANE
	Also, as it's a define, it is standard practice to use capital letters for the variable so people know this.

*/

/*
	from stddef.dm, planes & layers built into byond.

	FLOAT_LAYER = -1
	AREA_LAYER = 1
	TURF_LAYER = 2
	OBJ_LAYER = 3
	MOB_LAYER = 4
	FLY_LAYER = 5
	EFFECTS_LAYER = 5000
	TOPDOWN_LAYER = 10000
	BACKGROUND_LAYER = 20000
	EFFECTS_LAYER = 5000
	TOPDOWN_LAYER = 10000
	BACKGROUND_LAYER = 20000
	------

	FLOAT_PLANE = -32767
*/

//NEVER HAVE ANYTHING BELOW THIS PLANE ADJUST IF YOU NEED MORE SPACE
#define LOWEST_EVER_PLANE -200

#define CLICKCATCHER_PLANE   -99

#define PLANE_SPACE            -95
#define PLANE_SPACE_PARALLAX   -90
  #define SPACE_PARALLAX_1_LAYER 1
  #define SPACE_PARALLAX_2_LAYER 2
  #define SPACE_PARALLAX_3_LAYER 3
  #define SPACE_PARALLAX_PLANET_LAYER 10

//SINGULARITY EFFECT
#define SINGULARITY_EFFECT_PLANE_0 -25
#define SINGULARITY_EFFECT_PLANE_1 -24
#define SINGULARITY_EFFECT_PLANE_2 -23
#define SINGULARITY_EFFECT_PLANE_3 -22
#define SINGULO_RENDER_TARGET_0 "*SINGULOEFFECT_RENDER_TARGET_0"
#define SINGULO_RENDER_TARGET_1 "*SINGULOEFFECT_RENDER_TARGET_1"
#define SINGULO_RENDER_TARGET_2 "*SINGULOEFFECT_RENDER_TARGET_2"
#define SINGULO_RENDER_TARGET_3 "*SINGULOEFFECT_RENDER_TARGET_3"

//ANOMALIES EFFECT
#define ANOMALY_PLANE -21
#define ANOMALY_RENDER_TARGET "*ANOM_RENDER_TARGET"

// underfloor, floor and game planes have common layout order
// in some cases object can be switched between these planes
// FLOOR plane disables ambitn occlusion, UNDERFLOOR exists for undertile component
#define UNDERFLOOR_PLANE -8
#define FLOOR_PLANE -7
#define GAME_PLANE -4
  #define BELOW_TURF_LAYER                1.9
  //efine TURF_LAYER                      2     // For easy recordkeeping; this is a byond define
  #define ABOVE_NORMAL_TURF_LAYER         2.08
  #define BULLET_HOLE_LAYER               2.1
  #define GAS_PIPE_HIDDEN_SUPPLY_LAYER    2.33
  #define GAS_PIPE_HIDDEN_SCRUBBER_LAYER  2.34
  #define GAS_PIPE_HIDDEN_LAYER           2.35
  #define POWER_CABLES_HEAVY              2.39
  #define TURF_CAP_LAYER                  2.4   // cap on grid_floor and possible other future floors who can do UNDERFLOOR_VISIBLE, should be above hidden pipes
  #define POWER_CABLES                    2.44
  #define GAS_SCRUBBER_LAYER              2.46
  #define GAS_PIPE_VISIBLE_LAYER          2.47
  #define GAS_FILTER_LAYER                2.48
  #define GAS_PUMP_LAYER                  2.49
  #define LOW_OBJ_LAYER                   2.491 // Currently used only by unused machinery
  #define SAFEDOOR_LAYER                  2.5   // firedoors, poddoors, and someone used this for safe for some reason
  #define ABOVE_SAFEDOOR_LAYER            2.51  // poddoors default, they should be around SAFEDOOR_LAYER (see SAFEDOOR_CLOSED_MOD_*) but little above firedoors
  #define POWER_TERMINAL                  2.6
  #define BELOW_CONTAINERS_LAYER          2.7   // Below closets, crates...
  #define CONTAINER_STRUCTURE_LAYER       2.8   // Layer for closets, crates, bags, racks, tables
  #define DOOR_LAYER                      2.82
  #define BELOW_MACHINERY_LAYER           2.83  // Currently for grilles only, because they should be below machinery
  #define DEFAULT_MACHINERY_LAYER         2.85  // Every /obj/machinery by default have this layer
  #define BELOW_OBJ_LAYER                 2.9
  //efine OBJ_LAYER                       3     // For easy recordkeeping; this is a byond define
  #define ABOVE_OBJ_LATER                 3.01
  #define TRANSIT_TUBE_LAYER              3.1
  #define WINDOWS_LAYER                   3.2
  #define ABOVE_WINDOW_LAYER              3.3
  #define SIGN_LAYER                      3.4   // Default value for /obj/structure/sign
  #define BELOW_MOB_LAYER                 3.7   // Currently used only by fluff struct in bluespace shelter
  //efine MOB_LAYER                       4     // For easy recordkeeping; this is a byond define
  #define BELL_LAYER                      4.20
  #define INFRONT_MOB_LAYER               4.25
  //efine FLY_LAYER                       5     // For easy recordkeeping; this is a byond define
  #define LAMPS_LAYER                     5
  #define MOB_ELECTROCUTION_LAYER         5.01
  #define INDICATOR_LAYER                 5.01  // Emotes should be above this as they are shown only temporary.
  #define EMOTE_LAYER                     5.02
  #define ABOVE_FLY_LAYER                 5.1
  #define HIGHEST_GAME_LAYER              50

#define ABOVE_GAME_PLANE  -1
#define SEETHROUGH_PLANE -3

#define BLACKNESS_PLANE   0

#define SINGULARITY_PLANE 10
  #define SINGULARITY_LAYER 1
  #define ABOVE_SINGULARITY_LAYER 2

#define AREA_PLANE 60

#define GHOST_ILLUSION_PLANE 79
  #define GHOST_ILLUSION_RENDER_TARGET "*GHOST_ILLUSION_RENDER_TARGET"

#define GHOST_PLANE 80
#define POINT_PLANE 90

//---------- -----LIGHTING -------------
#define LIGHTING_PLANE 100
#define LIGHTING_EXPOSURE_PLANE 101 // Light sources "cones"
#define LIGHTING_LAMPS_SELFGLOW 102 // Light sources glow (lamps, doors overlay, etc.)
#define LIGHTING_LAMPS_PLANE 103 // Light sources themselves (lamps, screens, etc.)
#define LIGHTING_LAMPS_GLARE 104 // Light glare (optional setting)
#define LIGHTING_LAMPS_RENDER_TARGET "*LIGHTING_LAMPS_RENDER_TARGET"

#define ENVIRONMENT_LIGHTING_PLANE 110
#define ENVIRONMENT_LIGHTING_COLOR_PLANE 111
#define ENVIRONMENT_LIGHTING_LOCAL_PLANE 112

#define ABOVE_LIGHTING_PLANE 120
  #define ABOVE_LIGHTING_LAYER 1
  #define RUNECHAT_LAYER 2
  #define RUNECHAT_LAYER_MAX 3

///--------------MISC--------------
#define CAMERA_STATIC_PLANE 200

//--------------- FULLSCREEN IMAGES ------------
#define FULLSCREEN_PLANE 500
  #define FLASH_LAYER 1
  #define FULLSCREEN_LAYER 2

//-------------------- Rendering ---------------------
#define RENDER_PLANE_GAME 990
#define RENDER_PLANE_ABOVE_GAME 991
#define RENDER_PLANE_NON_GAME 995
#define RENDER_PLANE_MASTER 999

//-------------------- HUD ---------------------
//HUD layer defines
#define HUD_PLANE 1000
  #define HUD_LAYER 1
#define ABOVE_HUD_PLANE 1100
  #define ABOVE_HUD_LAYER 1
  #define HUD_TOOLTIP_LAYER 2

///Plane of the "splash" icon used that shows on the lobby screen. Nothing should ever be above this.
#define SPLASHSCREEN_PLANE 9999

///Plane master controller keys
#define PLANE_MASTERS_GAME "plane_masters_game"

//--------------------MISC-----------------------
//modifiers for /obj/machinery/door (and subtypes) layers
#define DOOR_CLOSED_MOD     0.3          // how much the layer is increased when the door is closed
#define SAFEDOOR_CLOSED_MOD_ABOVE_WINDOW (ABOVE_WINDOW_LAYER - SAFEDOOR_LAYER)
#define SAFEDOOR_CLOSED_MOD_BEFORE_DOOR  (DOOR_LAYER - SAFEDOOR_LAYER - 0.01)
