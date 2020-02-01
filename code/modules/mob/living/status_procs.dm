/mob/living/proc/add_quirk(quirk, spawn_effects)
	if(HAS_TRAIT(src, quirk))
		return
	if(!SSquirks || !SSquirks.quirks[quirk])
		return
	var/datum/quirk/T = SSquirks.quirks[quirk]
	new T (src, spawn_effects)
	return TRUE

/mob/living/proc/remove_quirk(quirk)
	var/datum/quirk/T = roundstart_quirks[quirk]
	if(T)
		qdel(T)
		return TRUE

/mob/living/proc/has_quirk(quirktype)
	return roundstart_quirks[quirktype]

/////////////////////////////////// SLEEPING ////////////////////////////////////

/mob/proc/IsSleeping() //non-living mobs shouldn't be sleeping either
	return FALSE

/mob/living/IsSleeping() //If we're asleep
	return has_status_effect(STATUS_EFFECT_SLEEPING)

/mob/living/proc/AmountSleeping() //How many deciseconds remain in our sleep
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		return S.duration - world.time
	return 0

/mob/living/proc/Sleeping(amount, updating = TRUE, ignore_sleepimmune = FALSE) //Can't go below remaining duration
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount, updating)
	return S

/mob/living/proc/SetSleeping(amount, updating = TRUE, ignore_sleepimmune = FALSE) //Sets remaining duration
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(amount <= 0)
		if(S)
			qdel(S)
	else if(S)
		S.duration = world.time + amount
	else
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount, updating)
	return S

/mob/living/proc/AdjustSleeping(amount, updating = TRUE, ignore_sleepimmune = FALSE) //Adds to remaining duration
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount, updating)
	return S
