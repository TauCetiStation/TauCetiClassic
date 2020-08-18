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

#define CLICKCATCHER_PLANE   -99

#define PLANE_SPACE            -95
#define PLANE_SPACE_PARALLAX   -90

#define FLOOR_PLANE      -2
#define GAME_PLANE       -1
#define BLACKNESS_PLANE   0

#define LIGHTING_PLANE         15
#define LIGHTING_LAYER         15
#define ABOVE_LIGHTING_LAYER   16

//HUD layer defines

#define FULLSCREEN_PLANE 18
#define FLASH_LAYER      18
#define FULLSCREEN_LAYER 18.1

#define HUD_PLANE         19
#define HUD_LAYER         19
#define ABOVE_HUD_PLANE   20
#define ABOVE_HUD_LAYER   20

//efine TURF_LAYER                      2     // For easy recordkeeping; this is a byond define
#define ABOVE_NORMAL_TURF_LAYER         2.08  // Currently used only by /obj/structure/fans/tiny
#define GAS_PIPE_HIDDEN_SUPPLY_LAYER    2.33
#define GAS_PIPE_HIDDEN_SCRUBBER_LAYER  2.34
#define GAS_PIPE_HIDDEN_LAYER           2.35
#define GAS_SCRUBBER_LAYER              2.46
#define GAS_PIPE_VISIBLE_LAYER          2.47
#define GAS_FILTER_LAYER                2.48
#define GAS_PUMP_LAYER                  2.49
#define LOW_OBJ_LAYER                   2.491 // Currently used only by unused machinery
#define FIREDOOR_LAYER                  2.5
#define BELOW_CONTAINERS_LAYER          2.7   // Below closets, crates...
#define CONTAINER_STRUCTURE_LAYER       2.8   // Layer for closets, crates, bags, racks, tables
#define DOOR_LAYER                      2.82
#define BELOW_MACHINERY_LAYER           2.83  // Currently for grilles only, because they should be below machinery
#define DEFAULT_MACHINERY_LAYER         2.85  // Every /obj/machinery by default have this layer
//efine OBJ_LAYER                       3     // For easy recordkeeping; this is a byond define
#define SHUTTERS_LAYER                  3.1
#define ABOVE_WINDOW_LAYER              3.3
#define SIGN_LAYER                      3.4   // Default value for /obj/structure/sign
#define BELOW_MOB_LAYER                 3.7   // Currently used only by fluff struct in bluespace shelter
//efine MOB_LAYER                       4     // For easy recordkeeping; this is a byond define
#define INFRONT_MOB_LAYER               4.25
//efine FLY_LAYER                       5     // For easy recordkeeping; this is a byond define
#define INDICATOR_LAYER                 5.01  // Emotes should be above this as they are shown only temporary.
#define EMOTE_LAYER                     5.02
#define SINGULARITY_LAYER				6
#define SINGULARITY_EFFECT_LAYER		6.1

//modifiers for /obj/machinery/door (and subtypes) layers
#define DOOR_CLOSED_MOD     0.3          // how much the layer is increased when the door is closed
#define PODDOOR_CLOSED_MOD  0.31
#define FIREDOOR_CLOSED_MOD 0.31
