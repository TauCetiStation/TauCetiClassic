/**
	Bluespace move element.
	Allows invisible stealth movement while moving on tiles with bluespace_corridor on them.
*/
/datum/element/bluespace_move
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH

	var/prev_invisibility = 0
	var/prev_see_invisible = 0
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
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_movement)

/datum/element/bluespace_move/Detach(datum/target)
	// What happens if while in the bleuspace corridor subject turns invis? What about modvals, guys?
	var/atom/movable/AM = target
	AM.invisibility = prev_invisibility
	if(ismob(AM))
		var/mob/M = AM
		M.see_invisible = prev_see_invisible
	AM.alpha = prev_alpha

	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/element/bluespace_move/proc/on_movement(datum/source, atom/OldLoc, dir)
	var/atom/movable/AM = source

	var/obj/structure/bluespace_corridor/BC = locate() in AM.loc
	var/obj/machinery/bluespace_transponder/BT = locate() in OldLoc

	var/has_punishment = !BT

	if(!BC)
		if(has_punishment)
			to_chat(source, "<span class='warning'>Such sudden jumps out of the bluespace web might damage you!</span>")
		Detach(source)
		return
