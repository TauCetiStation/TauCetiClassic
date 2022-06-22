#define IS_STUN_IMMUNE(source, ignore_canstun) (!(source.status_flags & CANSTUN || ignore_canstun))


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


/* STUN */
/mob/living/proc/IsStun() //If we're stunned
	return has_status_effect(/datum/status_effect/incapacitating/stun)

/mob/living/proc/AmountStun() //How many deciseconds remain in our stun
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	if(S)
		return S.duration - world.time
	return 0

/mob/living/proc/Stun(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	amount *= SS_WAIT_DEFAULT // workaround for our Stun amount
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount)
	return S

/mob/living/proc/SetStun(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	if(amount <= 0)
		if(S)
			qdel(S)
	else
		amount *= SS_WAIT_DEFAULT
		if(S)
			S.duration = world.time + amount
		else
			S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount)
	return S

/mob/living/proc/AdjustStun(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	amount *= SS_WAIT_DEFAULT
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount)
	return S

/* PARALYZED */
/mob/living/proc/IsParalyzed() //If we're paralyzed
	return has_status_effect(/datum/status_effect/incapacitating/paralyzed)

/mob/living/proc/AmountParalyzed() //How many deciseconds remain in our Paralyzed status effect
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(P)
		return P.duration - world.time
	return 0

/mob/living/proc/Paralyze(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	amount *= SS_WAIT_DEFAULT
	if(P)
		P.duration = max(world.time + amount, P.duration)
	else if(amount > 0)
		P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount)
	return P

/mob/living/proc/SetParalyzed(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(amount <= 0)
		if(P)
			qdel(P)
	else
		amount *= SS_WAIT_DEFAULT
		if(absorb_stun(amount, ignore_canstun))
			return
		if(P)
			P.duration = world.time + amount
		else
			P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount)
	return P

/mob/living/proc/AdjustParalyzed(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	amount *= SS_WAIT_DEFAULT
	if(P)
		P.duration += amount
	else if(amount > 0)
		P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount)
	return P

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
