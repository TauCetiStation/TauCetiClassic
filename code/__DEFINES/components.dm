#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup || !target.comp_lookup[sigtype] ? NONE : target._SendSignal(sigtype, list(target, ##arguments)) )

//shorthand
#define GET_COMPONENT_FROM(varname, path, target) var##path/##varname = ##target.GetComponent(##path)
#define GET_COMPONENT(varname, path) GET_COMPONENT_FROM(varname, path, src)

#define COMPONENT_INCOMPATIBLE 1

// How multiple components of the exact same type are handled in the same datum

#define COMPONENT_DUPE_HIGHLANDER      0	//old component is deleted (default)
#define COMPONENT_DUPE_ALLOWED         1	//duplicates allowed
#define COMPONENT_DUPE_UNIQUE          2	//new component is deleted
#define COMPONENT_DUPE_UNIQUE_PASSARGS 4	//old component is given the initialization args of the new

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
#define COMSIG_COMPONENT_ADDED "component_added"				//when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"			//before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"			//before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_QDELETED "parent_qdeleted"				//after a datum's Destroy() is called: (force, qdel_hint), at this point none of the other components chose to interrupt qdel and Destroy has been called

// /client signals
#define COMSIG_CLIENTMOB_MOVE "client_move"		//from base of client/Move(): (atom/NewLoc, direction)
	#define COMPONENT_CLIENTMOB_BLOCK_MOVE 1
#define COMSIG_CLIENTMOB_POSTMOVE "client_postmove" //from base of client/Move, after all movement is finished(): (atom/NewLoc, direction)
// /atom signals
#define COMSIG_ATOM_ENTERED "atom_entered"						//from base of atom/Entered(): (atom/movable/entering, /atom)

#define COMSIG_ATOM_CANPASS "movable_canpass"	//from base of atom/movable/CanPass() & mob/CanPass(): (atom/movable/mover, atom/target, height, air_group)
	#define COMPONENT_CANPASS  "canpass"
	#define COMPONENT_CANTPASS "cantpass"

#define COMSIG_PARENT_ATTACKBY "atom_attackby"			        ///from base of atom/attackby(): (/obj/item, /mob/living, params)
	#define COMPONENT_NO_AFTERATTACK 1								//Return this in response if you don't want afterattack to be called

// /atom/movable signals
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"					///from base of atom/movable/Move(): (/atom/newLoc)
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE 1
#define COMSIG_MOVABLE_CROSSED "movable_crossed"				//from base of atom/movable/Crossed(): (/atom/movable)
#define COMSIG_MOVABLE_MOVED "movable_moved"					//from base of atom/movable/Moved(): (/atom/oldLoc, dir)
#define COMSIG_MOVABLE_LOC_MOVED "movable_loc_moved"					//from base of atom/movable/locMoved(): (/atom/oldLoc, dir)

#define COMSIG_ATOM_START_PULL "atom_start_pull"				//from base of /mob/start_pulling(): (/mob/puller)
	#define COMPONENT_PREVENT_PULL 1
#define COMSIG_ATOM_STOP_PULL  "atom_stop_pull"					//from base of /mob/stop_pulling(): (/mob/puller)

#define COMSIG_MOVABLE_WADDLE "movable_waddle"		//from atom/movable/proc/waddle(): (waddle_angle, waddle_height)

#define COMSIG_MOVABLE_GRABBED "movable_grabbed"	//from mob/Grab(): (mob/grabber, force_state, show_warnings)
	#define COMPONENT_PREVENT_GRAB 1

#define COMSIG_MOVABLE_PIXELMOVE "movable_pixelmove" // hopefully called from all places where pixel_x and pixel_y is set. used by multi_carry, and waddle. (): ()

// living signals
#define COMSIG_LIVING_START_PULL "living_start_pull"			//from base of /mob/start_pulling(): (/atom/movable/target)
#define COMSIG_LIVING_STOP_PULL "living_stop_pull"				//from base of /mob/stop_pulling(): (/atom/movable/target)

#define COMSIG_MOVABLE_BUCKLE "buckle"							///from base of atom/movable/buckle_mob(): (mob/buckled)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"						///from base of atom/movable/unbuckle_mob(): (mob/buckled)

#define COMSIG_LIVING_MOVE_PULLED "living_move_pulled"			//from base of /mob/Move_Pulled(): (atom/target)
	#define COMPONENT_PREVENT_MOVE_PULLED 1

#define COMSIG_LIVING_CLICK_CTRL "living_click_ctrl"				//from base of mob/CtrlClickOn(): (atom/target)
#define COMSIG_LIVING_CLICK_CTRL_SHIFT "living_click_ctrl_shift"	//from base of mob/CtrlShiftClickOn(): (atom/target)
	#define COMPONENT_CANCEL_CLICK 1

#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"				//from slime CtrlClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"				//from slime ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"				//from turf ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"					//from turf AltClickOn(): (/mob)
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"				//from monkey CtrlClickOn(): (/mob)
