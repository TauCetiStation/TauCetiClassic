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

// /atom signals
#define COMSIG_ATOM_ENTERED "atom_entered"						//from base of atom/Entered(): (atom/movable/entering, /atom)

// /atom/movable signals
#define COMSIG_MOVABLE_CROSSED "movable_crossed"				//from base of atom/movable/Crossed(): (/atom/movable)
#define COMSIG_MOVABLE_MOVED "movable_moved"					//from base of atom/movable/Moved(): (/atom, dir)


#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"				//from slime CtrlClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"				//from slime ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"				//from turf ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"					//from turf AltClickOn(): (/mob)
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"				//from monkey CtrlClickOn(): (/mob)
