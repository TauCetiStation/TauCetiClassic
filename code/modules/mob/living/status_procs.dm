#define IS_STUN_IMMUNE(source, ignore_canstun) (!(source.status_flags & CANSTUN || ignore_canstun))
#define IS_PARALYSE_IMMUNE(source, ignore_canstun) (!(source.status_flags & CANPARALYSE || ignore_canstun))
#define IS_WEAKEN_IMMUNE(source, ignore_canstun) (!(source.status_flags & CANWEAKEN || ignore_canstun))


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

/mob/proc/cure_nearsighted(source)
	REMOVE_TRAIT(src, TRAIT_NEARSIGHT, source)

/mob/proc/become_nearsighted(source)
	ADD_TRAIT(src, TRAIT_NEARSIGHT, source)

/* STUN */
// placeholders
/mob/proc/IsStun()

/mob/proc/AmountStun()

/mob/proc/Stun(amount, ignore_canstun = FALSE)

/mob/proc/SetStunned(amount, ignore_canstun = FALSE)

/mob/proc/AdjustStunned(amount, ignore_canstun = FALSE)

/mob/living/IsStun() //If we're stunned
	return has_status_effect(/datum/status_effect/incapacitating/stun)

/mob/living/AmountStun() //How many deciseconds remain in our stun
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	if(S)
		return (S.duration - world.time) / SS_WAIT_DEFAULT
	return 0

/mob/living/Stun(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(HAS_TRAIT(src, TRAIT_STUNIMMUNE))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	amount *= SS_WAIT_DEFAULT // workaround for our Stun amount
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount, TRUE)
	return S

/mob/living/SetStunned(amount, ignore_canstun = FALSE) //Sets remaining duration
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
			S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount, TRUE)
	return S

/mob/living/AdjustStunned(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStun()
	amount *= SS_WAIT_DEFAULT
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/stun, amount, TRUE)
	return S

/* PARALYZED */
// placeholders
/mob/proc/IsParalyzed()

/mob/proc/AmountParalyzed()

/mob/proc/Paralyse(amount, ignore_canstun = FALSE)

/mob/proc/SetParalysis(amount, ignore_canstun = FALSE)

/mob/proc/AdjustParalysis(amount, ignore_canstun = FALSE)

/mob/living/IsParalyzed() //If we're paralyzed
	return has_status_effect(/datum/status_effect/incapacitating/paralyzed)

/mob/living/AmountParalyzed() //How many deciseconds remain in our Paralyzed status effect
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(P)
		return (P.duration - world.time) / SS_WAIT_DEFAULT
	return 0

/mob/living/Paralyse(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(IS_PARALYSE_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	amount *= SS_WAIT_DEFAULT
	if(P)
		P.duration = max(world.time + amount, P.duration)
	else if(amount > 0)
		P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount, TRUE)
	return P

/mob/living/SetParalysis(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(IS_PARALYSE_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(amount <= 0)
		if(P)
			qdel(P)
	else
		amount *= SS_WAIT_DEFAULT
		if(P)
			P.duration = world.time + amount
		else
			P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount, TRUE)
	return P

/mob/living/AdjustParalysis(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_PARALYSE_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	amount *= SS_WAIT_DEFAULT
	if(P)
		P.duration += amount
	else if(amount > 0)
		P = apply_status_effect(/datum/status_effect/incapacitating/paralyzed, amount, TRUE)
	return P

/* WEAKEN */
// placeholders
/mob/proc/IsWeaken()

/mob/proc/AmountWeaken()

/mob/proc/Weaken(amount, ignore_canstun = FALSE)

/mob/proc/SetWeakened(amount, ignore_canstun = FALSE)

/mob/proc/AdjustWeakened(amount, ignore_canstun = FALSE)

/mob/living/IsWeaken() //If we're knocked down
	return has_status_effect(/datum/status_effect/incapacitating/weakened, TRUE)

/mob/living/AmountWeaken() //How many deciseconds remain in our knockdown
	var/datum/status_effect/incapacitating/weakened/K = IsWeaken()
	if(K)
		return (K.duration - world.time) / SS_WAIT_DEFAULT
	return 0

/mob/living/Weaken(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(IS_WEAKEN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/weakened/K = IsWeaken()
	amount *= SS_WAIT_DEFAULT
	if(K)
		K.duration = max(world.time + amount, K.duration)
	else if(amount > 0)
		K = apply_status_effect(/datum/status_effect/incapacitating/weakened, amount, TRUE)
	return K

/mob/living/SetWeakened(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(IS_WEAKEN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/weakened/K = IsWeaken()
	if(amount <= 0)
		if(K)
			qdel(K)
	else
		amount *= SS_WAIT_DEFAULT
		if(K)
			K.duration = world.time + amount
		else
			K = apply_status_effect(/datum/status_effect/incapacitating/weakened, amount, TRUE)
	return K

/mob/living/AdjustWeakened(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_WEAKEN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/weakened/K = IsWeaken()
	amount *= SS_WAIT_DEFAULT
	if(K)
		K.duration += amount
	else if(amount > 0)
		K = apply_status_effect(/datum/status_effect/incapacitating/weakened, amount, TRUE)
	return K

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

/mob/living/carbon/proc/AdjustClumsyStatus(amount)
	var/datum/status_effect/clumsy/C = has_status_effect(STATUS_EFFECT_CLUMSY)
	if(C)
		C.duration += amount SECONDS
	else if(amount > 0)
		C = apply_status_effect(STATUS_EFFECT_CLUMSY, amount SECONDS)
	return C

//////////////

/mob/living/proc/adjust_timed_status_effect(duration, effect, max_duration)
	if(!isnum(duration))
		CRASH("adjust_timed_status_effect: called with an invalid duration. (Got: [duration])")

	if(!ispath(effect, /datum/status_effect))
		CRASH("adjust_timed_status_effect: called with an invalid effect type. (Got: [effect])")

	// If we have a max duration set, we need to check our duration does not exceed it
	if(isnum(max_duration))
		if(max_duration <= 0)
			CRASH("adjust_timed_status_effect: Called with an invalid max_duration. (Got: [max_duration])")

		if(duration >= max_duration)
			duration = max_duration

	var/datum/status_effect/existing = has_status_effect(effect)
	if(existing)
		if(isnum(max_duration) && duration > 0)
			// Check the duration remaining on the existing status effect
			// If it's greater than / equal to our passed max duration, we don't need to do anything
			var/remaining_duration = existing.duration - world.time
			if(remaining_duration >= max_duration)
				return

			// Otherwise, add duration up to the max (max_duration - remaining_duration),
			// or just add duration if it doesn't exceed our max at all
			existing.duration += min(max_duration - remaining_duration, duration)

		else
			existing.duration += duration

		// If the duration was decreased and is now less 0 seconds,
		// qdel it / clean up the status effect immediately
		// (rather than waiting for the process tick to handle it)
		if(existing.duration <= world.time)
			qdel(existing)

	else if(duration > 0)
		apply_status_effect(effect, duration)
	if(!isnum(duration))
		CRASH("adjust_timed_status_effect: called with an invalid duration. (Got: [duration])")

	if(!ispath(effect, /datum/status_effect))
		CRASH("adjust_timed_status_effect: called with an invalid effect type. (Got: [effect])")

	// If we have a max duration set, we need to check our duration does not exceed it
	if(isnum(max_duration))
		if(max_duration <= 0)
			CRASH("adjust_timed_status_effect: Called with an invalid max_duration. (Got: [max_duration])")

		if(duration >= max_duration)
			duration = max_duration
