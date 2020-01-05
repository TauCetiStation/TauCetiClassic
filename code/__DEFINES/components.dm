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

#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"					//from base of atom/MouseDrop(): (/atom/over, /mob/user)
	#define COMPONENT_NO_MOUSEDROP 1
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"			//from base of atom/MouseDrop_T: (/atom/from, /mob/user)

// /atom/movable signals
#define COMSIG_MOVABLE_CROSSED "movable_crossed"				//from base of atom/movable/Crossed(): (/atom/movable)
#define COMSIG_MOVABLE_MOVED "movable_moved"					//from base of atom/movable/Moved(): (/atom, dir)

// /obj/item signals
#define COMSIG_ITEM_ATTACK "item_attack"						//from base of obj/item/attack(): (/mob/living/target, /mob/living/user, def_zone)
	#define COMPONENT_ITEM_NO_ATTACK 1

#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"					//from base of obj/item/attack_self(): (/mob/user)
	#define COMPONENT_NO_INTERACT 1

#define COMSIG_ITEM_SHIFTCLICKWITH "item_shiftclickwith"			//from base of mob/ShiftClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_CTRLCLICKWITH "item_ctrlclickwith"				//from base of mob/CtrlClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_ALTCLICKWITH "item_altclickwith"				//from base of mob/AltClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_CTRLSHIFTCLICKWITH "item_ctrlshiftclickwith"	//from base of mob/CtrlShiftClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_MIDDLECLICKWITH "item_middleclickwith"			//from base of mob/MiddleClickOn(): (atom/target, mob/user)
	#define COMSIG_ITEM_CANCEL_CLICKWITH 1

#define COMSIG_ITEM_MOUSEDROP_ONTO "item_mousedrop_onto"			//from base of atom/MouseDrop(): (/atom/over, /atom/dropping, /mob/user)
	//#define COMPONENT_NO_MOUSEDROP 1
