/**
	Bluespace move element.
	Allows invisible stealth movement while moving on tiles with bluespace_corridor on them.
*/
/datum/element/bluespace_move
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH

	var/prev_invisibility = 0
	var/prev_see_invisible = SEE_INVISIBLE_LEVEL_ONE
	var/prev_alpha = 255

/datum/element/bluespace_move/Attach(datum/target, prev_invisibility, prev_see_invisible, prev_alpha)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/movable/AM = target
	src.prev_invisibility = prev_invisibility
	src.prev_see_invisible = prev_see_invisible
	src.prev_alpha = prev_alpha

	AM.invisibility = SEE_INVISIBLE_LEVEL_TWO
	if(ismob(AM))
		var/mob/M = AM
		M.see_invisible = INVISIBILITY_LEVEL_TWO

	AM.alpha = 204

	RegisterSignal(target, COMSIG_CLIENTMOB_MOVE, .proc/on_move_intent)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_movement)

/datum/element/bluespace_move/Detach(datum/target)
	// What happens if while in the bleuspace corridor subject turns invis? What about modvals, guys?
	var/atom/movable/AM = target
	AM.invisibility = prev_invisibility
	if(ismob(AM))
		var/mob/M = AM
		M.see_invisible = prev_see_invisible

	AM.alpha = prev_alpha

	UnregisterSignal(target, list(COMSIG_CLIENTMOB_MOVE, COMSIG_MOVABLE_MOVED))
	return ..()

/datum/element/bluespace_move/proc/on_move_intent(datum/source, atom/Newloc, dir)
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

	var/obj/structure/bluespace_corridor/BC = locate() in Newloc
	var/obj/machinery/swarm_powered/bluespace_transponder/BT = locate() in M.loc

	if(!BT && !BC)
		to_chat(M, "<span class='warning'>You can't run out of the bluespace corridor! Try switching your movement intention if you want to exit without a portal.</span>")
		return COMPONENT_CLIENTMOB_BLOCK_MOVE

	return NONE

/datum/element/bluespace_move/proc/on_movement(datum/source, atom/OldLoc, dir)
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
		Detach(AM)
		return NONE

	return NONE
