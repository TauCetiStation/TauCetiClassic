/**
	Bluespace move component.
	Allows invisible stealth movement while moving on tiles with bluespace_corridor on them.
*/
/datum/component/bluespace_move
	var/prev_invisibility = 0
	var/prev_see_invisible = SEE_INVISIBLE_LEVEL_ONE
	var/prev_alpha = 255

	var/atom/entry

/datum/component/bluespace_move/Initialize(atom/entry, prev_invisibility, prev_see_invisible, prev_alpha)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.entry = entry
	RegisterSignal(entry, list(COMSIG_PARENT_QDELETING), PROC_REF(clear_entry))

	var/atom/movable/AM = parent
	src.prev_invisibility = prev_invisibility
	src.prev_see_invisible = prev_see_invisible
	src.prev_alpha = prev_alpha

	AM.invisibility = SEE_INVISIBLE_LEVEL_TWO
	if(ismob(AM))
		var/mob/M = AM
		M.see_invisible = INVISIBILITY_LEVEL_TWO
		RegisterSignal(M, list(COMSIG_MOB_CLICK), PROC_REF(on_click))

	AM.alpha = 204

	ADD_TRAIT(AM, TRAIT_BLUESPACE_MOVING, BLUESPACE_MOVE_COMPONENT_TRAIT)

	RegisterSignal(AM, COMSIG_CLIENTMOB_MOVE, PROC_REF(on_move_intent))
	RegisterSignal(AM, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))

/datum/component/bluespace_move/Destroy()
	// What happens if while in the bleuspace corridor subject turns invis? What about modvals, guys?
	var/atom/movable/AM = parent
	AM.invisibility = prev_invisibility
	if(ismob(AM))
		var/mob/M = AM
		M.see_invisible = prev_see_invisible
		UnregisterSignal(M, list(COMSIG_MOB_CLICK))

	AM.alpha = prev_alpha

	REMOVE_TRAIT(AM, TRAIT_BLUESPACE_MOVING, BLUESPACE_MOVE_COMPONENT_TRAIT)

	UnregisterSignal(AM, list(COMSIG_CLIENTMOB_MOVE, COMSIG_MOVABLE_MOVED))

	clear_entry()
	return ..()

/datum/component/bluespace_move/proc/clear_entry()
	SIGNAL_HANDLER

	if(!entry)
		return

	UnregisterSignal(entry, list(COMSIG_PARENT_QDELETING))
	entry = null

/datum/component/bluespace_move/proc/on_move_intent(datum/source, atom/Newloc, dir)
	SIGNAL_HANDLER

	var/mob/M = source
	// Lulwhat clientmob move on a non-mob?
	if(!ismob(M))
		return NONE

	if(M.m_intent == MOVE_INTENT_RUN)
		return NONE

	// FUCK YOU DIAGONAL MOVEMENT
	// YOU ARE NOT ELEGANT
	// YOU DO NOT WORK
	// YOU ARE THE SOURCE OF ALL MOVEMENT INCONSISTENCIES IN THIS GAME
	// AND YOU ARE THE REASON WHY THIS COOL FEATURE WORKS BADLY
	// SO I AM FUCKING YOU OUT OF EXISTENCE
	// BEGONE!
	var/is_diagonal = ISDIAGONALDIR(dir)
	if(is_diagonal)
		return COMPONENT_CLIENTMOB_BLOCK_MOVE

	if((locate(/obj/structure/replicator_forcefield) in Newloc))
		return NONE

	var/obj/structure/bluespace_corridor/BC = locate() in Newloc
	var/obj/machinery/swarm_powered/bluespace_transponder/BT = locate() in M.loc

	if(!BT && !BC)
		to_chat(M, "<span class='warning'>You can't run out of the bluespace corridor! Try switching your movement intention if you want to exit without a portal.</span>")
		return COMPONENT_CLIENTMOB_BLOCK_MOVE

	return NONE

/datum/component/bluespace_move/proc/on_movement(datum/source, atom/OldLoc, dir)
	SIGNAL_HANDLER

	var/atom/movable/AM = source

	var/obj/structure/bluespace_corridor/BC = locate() in AM.loc
	var/obj/machinery/swarm_powered/bluespace_transponder/BT = locate() in OldLoc

	var/has_punishment = !BT || (BT.stat & NOPOWER)

	if(!BC)
		if(has_punishment)
			// to-do: punish for not walking out of a portal? currently the only punishment is that it's louder.
			playsound(AM, 'sound/magic/Blind.ogg', VOL_EFFECTS_MASTER, 80)
		else
			playsound(AM, 'sound/magic/blink.ogg', VOL_EFFECTS_MASTER, 60)
		qdel(src)
		return NONE

	return NONE

/datum/component/bluespace_move/proc/on_click(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isturf(target.loc))
		return
	var/mob/clicker = source
	if(!isturf(clicker.loc))
		return
	var/obj/structure/bluespace_corridor/BC = locate() in clicker.loc
	if(!BC)
		return
	INVOKE_ASYNC(BC, TYPE_PROC_REF(/obj/structure/bluespace_corridor, animate_obstacle))
