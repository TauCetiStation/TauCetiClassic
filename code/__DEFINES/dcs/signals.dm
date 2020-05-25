// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice

//leaved for example (as part with "!" important to know)
//#define COMSIG_GLOB_MOB_CREATED "!mob_created"					//mob was created somewhere : (mob)

//////////////////////////////////////////////////////////////////

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"
/// after a datum's Destroy() is called: (force, qdel_hint), at this point none of the other components chose to interrupt qdel and Destroy has been called
#define COMSIG_PARENT_QDELETED "parent_qdeleted"

// light related signals
/// from base of /atom/movable/lighting_object/update(): (turf/my_turf)
#define COMSIG_LIGHT_UPDATE_OBJECT "light_update_object"

// /datum/reagent signals
/// from base of reagent/reaction_turf(): (turf/T, volume)
#define COMSIG_REAGENT_REACTION_TURF "reagent_reaction_turf"

// /client signals
/// from base of client/Move(): (atom/NewLoc, direction)
#define COMSIG_CLIENTMOB_MOVE "client_move"
	#define COMPONENT_CLIENTMOB_BLOCK_MOVE 1
/// from base of client/Move, after all movement is finished(): (atom/NewLoc, direction)
#define COMSIG_CLIENTMOB_POSTMOVE "client_postmove"

// /atom signals
/// from base of atom/Entered(): (atom/movable/entering, /atom)
#define COMSIG_ATOM_ENTERED "atom_entered"
/// from base of atom/Exited(): (atom/movable/exiting, /atom/newLoc)
#define COMSIG_ATOM_EXITED "atom_exited"
/// from base of atom/movable/CanPass() & mob/CanPass(): (atom/movable/mover, atom/target, height, air_group)
#define COMSIG_ATOM_CANPASS "movable_canpass"
	#define COMPONENT_CANPASS  "canpass"
	#define COMPONENT_CANTPASS "cantpass"
/// from base of atom/attackby(): (/obj/item, /mob/living, params)
#define COMSIG_PARENT_ATTACKBY "atom_attackby"
	// Return this in response if you don't want afterattack to be called
	#define COMPONENT_NO_AFTERATTACK 1
/// from base of atom/examine(): (/mob)
#define COMSIG_PARENT_EXAMINE "atom_examine"
/// from base of mob/examinate(): (/mob)
#define COMSIG_PARENT_POST_EXAMINE "atom_post_examine"
/// from base of atom/MouseDrop(): (/atom/over, /mob/user)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"
	#define COMPONENT_NO_MOUSEDROP 1
/// from base of atom/MouseDrop_T: (/atom/from, /mob/user)
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"

// /atom/movable signals
/// from base of atom/movable/Move(): (/atom/newLoc)
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE 1
/// from base of atom/movable/Crossed(): (/atom/movable)
#define COMSIG_MOVABLE_CROSSED "movable_crossed"
/// from base of atom/movable/Moved(): (/atom/oldLoc, dir)
#define COMSIG_MOVABLE_MOVED "movable_moved"
/// from base of atom/movable/locMoved(): (/atom/oldLoc, dir)
#define COMSIG_MOVABLE_LOC_MOVED "movable_loc_moved"
/// from base of /mob/start_pulling(): (/mob/puller)
#define COMSIG_ATOM_START_PULL "atom_start_pull"
	#define COMPONENT_PREVENT_PULL 1
/// from base of /mob/stop_pulling(): (/mob/puller)
#define COMSIG_ATOM_STOP_PULL  "atom_stop_pull"
/// from atom/movable/proc/waddle(): (waddle_angle, waddle_height)
#define COMSIG_MOVABLE_WADDLE "movable_waddle"
/// from mob/tryGrab(): (mob/grabber, force_state, show_warnings)
#define COMSIG_MOVABLE_TRY_GRAB "movable_try_grab"
	#define COMPONENT_PREVENT_GRAB 1
/// hopefully called from all places where pixel_x and pixel_y is set. used by multi_carry, and waddle. (): ()
#define COMSIG_MOVABLE_PIXELMOVE "movable_pixelmove"

// /obj/item signals
/// from base of obj/item/attack(): (/mob/living/target, /mob/living/user, def_zone)
#define COMSIG_ITEM_ATTACK "item_attack"
	#define COMPONENT_ITEM_NO_ATTACK 1
/// from base of obj/item/attack_self(): (/mob/user)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
	#define COMPONENT_NO_INTERACT 1
/// from base of mob/ShiftClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_SHIFTCLICKWITH "item_shiftclickwith"
/// from base of mob/CtrlClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_CTRLCLICKWITH "item_ctrlclickwith"
/// from base of mob/AltClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_ALTCLICKWITH "item_altclickwith"
/// from base of mob/CtrlShiftClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_CTRLSHIFTCLICKWITH "item_ctrlshiftclickwith"
/// from base of mob/MiddleClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_MIDDLECLICKWITH "item_middleclickwith"
	#define COMSIG_ITEM_CANCEL_CLICKWITH 1
/// from base of atom/MouseDrop(): (/atom/over, /atom/dropping, /mob/user)
#define COMSIG_ITEM_MOUSEDROP_ONTO "item_mousedrop_onto"
	// #define COMPONENT_NO_MOUSEDROP 1

// mob signals
/// from mob/proc/slip(): (weaken_duration, obj/slipped_on, lube)
#define COMSIG_MOB_SLIP "movable_slip"

// living signals
/// from base of /mob/start_pulling(): (/atom/movable/target)
#define COMSIG_LIVING_START_PULL "living_start_pull"
/// from base of /mob/stop_pulling(): (/atom/movable/target)
#define COMSIG_LIVING_STOP_PULL "living_stop_pull"
/// from base of atom/movable/buckle_mob(): (mob/buckled)
#define COMSIG_MOVABLE_BUCKLE "buckle"
/// from base of atom/movable/unbuckle_mob(): (mob/buckled)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"
/// from base of /mob/Move_Pulled(): (atom/target)
#define COMSIG_LIVING_MOVE_PULLED "living_move_pulled"
	#define COMPONENT_PREVENT_MOVE_PULLED 1
/// from base of mob/CtrlClickOn(): (atom/target)
#define COMSIG_LIVING_CLICK_CTRL "living_click_ctrl"
/// from base of mob/CtrlShiftClickOn(): (atom/target)
#define COMSIG_LIVING_CLICK_CTRL_SHIFT "living_click_ctrl_shift"
	#define COMPONENT_CANCEL_CLICK 1
/// from slime CtrlClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"
/// from slime ShiftClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"
/// from turf ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"
/// from turf AltClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"
/// from monkey CtrlClickOn(): (/mob)
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"

// Component specific signals.
/// send this signal to remove a list of tip ids(use tip_names as tip ids): (/list/tip_ids_to_remove)
#define COMSIG_TIPS_REMOVE "comsig_tip_remove"
