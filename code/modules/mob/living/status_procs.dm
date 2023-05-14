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
	if(!HAS_TRAIT(src, TRAIT_NEARSIGHT))
		clear_fullscreen("nearsighted")

/mob/proc/become_nearsighted(source)
	if(!HAS_TRAIT(src, TRAIT_NEARSIGHT))
		overlay_fullscreen("nearsighted", /atom/movable/screen/fullscreen/impaired, 1)
	ADD_TRAIT(src, TRAIT_NEARSIGHT, source)

/mob/living/carbon/human/become_nearsighted(source)
	if(glasses)
		var/obj/item/clothing/glasses/G = glasses
		if(G.prescription)
			ADD_TRAIT(src, TRAIT_NEARSIGHT, source)
			return
	if(!HAS_TRAIT(src, TRAIT_NEARSIGHT))
		overlay_fullscreen("nearsighted", /atom/movable/screen/fullscreen/impaired, 1)
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
