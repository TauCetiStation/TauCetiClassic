/datum/element/awkward
	element_flags = ELEMENT_DETACH

/datum/element/awkward/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_LIVING_BUMPED, PROC_REF(atom_bumped))

/datum/element/awkward/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_BUMPED)

/datum/element/awkward/proc/do_awkward_effect(mob/living/affected, atom/A)
	playsound(get_turf(affected), pick(SOUNDIN_PUNCH_MEDIUM), VOL_EFFECTS_MASTER)
	affected.visible_message("<span class='warning'>[affected] [pick("ran", "slammed")] into \the [A]!</span>")
	affected.apply_damage(3, BRUTE, pick(BP_HEAD , BP_CHEST , BP_L_LEG , BP_R_LEG))
	affected.Stun(1)
	affected.Weaken(2)

/datum/element/awkward/proc/atom_bumped(datum/source, atom/A)
	SIGNAL_HANDLER
	if(!isliving(source))
		return
	var/mob/living/affected = source
	if(affected.stat != CONSCIOUS)
		return
	//make a way to avoid debuf
	if(affected.m_intent == MOVE_INTENT_WALK)
		return
	if(is_blocked_turf(A))
		//its not a brainloss debuff, dont lay down by trying to open the door
		if(istype(A, /obj/machinery/door))
			return
		if(istype(A, /obj/structure/mineral_door))
			return
		if(isobj(A))
			var/obj/O = A
			//prevents stun by crates and lockers, which can be pulled by running on them
			if(!O.anchored)
				return
		if(ismob(A))
			return
	do_awkward_effect(affected, A)
