#define TRAIT_HOOKED "hooked"
#define IMMOBILIZATION_TIMER (0.25 SECONDS) //! How long we immobilize the firer after firing - we do cancel the immobilization early if nothing is hit.

/// Meat Hook
/obj/item/weapon/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	ammo_type = /obj/item/ammo_casing/magic/hook
	icon_state = "hook"
	item_state = "hook"
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	force = 18
	global_access = TRUE

/obj/item/weapon/gun/magic/hook/suicide_act(mob/living/user)
	if(!ishuman(user))
		user.visible_message("[user] is using the [src] on their head! It looks like theyre trying to commit suicide!")
		return BRUTELOSS
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/head/removable = H.bodyparts_by_name[BP_HEAD]
	if(isnull(removable))
		user.visible_message("[user] stuffs the chain of the [src] down the hole where their head should be! It looks like theyre trying to commit suicide!")
		return OXYLOSS

	playsound(get_turf(src), fire_sound, VOL_EFFECTS_MASTER)
	user.visible_message("[user] is using the [src] on their head! It looks like theyre trying to commit suicide!")
	playsound(get_turf(src), 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)
	removable.droplimb(TRUE, TRUE, FALSE)
	return BRUTELOSS

/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/item/projectile/hook
	var/obj/item/projectile/hook/H

/obj/item/ammo_casing/magic/hook/ready_proj(atom/target, mob/living/user, quiet)
	. = ..()
	if(!BB)
		return
	H = BB

/obj/item/ammo_casing/magic/hook/throw_proj(obj/item/weapon/gun/weapon, atom/target, turf/targloc, mob/living/user, params, boolet_number)
	. = ..()
	H.set_chain()

/obj/item/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/projectiles.dmi'
	pass_flags = PASSTABLE
	damage = 20
	agony = 20
	damage_type = BRUTE
	hitsound = list('sound/effects/splat.ogg')
	/// The chain we send out while we are in motion, referred to as "initial" to not get confused with the chain we use to reel the victim in.
	var/datum/beam/initial_chain

/obj/item/projectile/hook/Fire(atom/A, mob/living/user, params)
	. = ..()
	set_chain()

/obj/item/projectile/hook/proc/set_chain()
	if(!firer)
		return
	initial_chain = Beam(firer, icon_state = "chain")
	initial_chain.visuals.color = color
	ADD_TRAIT(firer, TRAIT_IMMOBILIZED, REF(src))
	ADD_TRAIT(firer, TRAIT_INCAPACITATED, REF(src))
	addtimer(CALLBACK(src, PROC_REF(remove_immobilization)), IMMOBILIZATION_TIMER, TIMER_STOPPABLE) // safety if we miss, if we get a hit we stay immobilized

/obj/item/projectile/hook/proc/remove_immobilization()
	REMOVE_TRAIT(firer, TRAIT_IMMOBILIZED, REF(src))
	REMOVE_TRAIT(firer, TRAIT_INCAPACITATED, REF(src))

/obj/item/projectile/hook/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!ismovable(target))
		return

	var/atom/movable/victim = target
	if(victim.anchored || HAS_TRAIT_FROM(victim, TRAIT_HOOKED, REF(firer)))
		return

	victim.visible_message("<span class='danger'>[victim] is snagged by [firer]'s hook!</span>")

	var/datum/hook_and_move/puller = new ()
	puller.begin_pulling(firer, victim, get_turf(firer), src)
	REMOVE_TRAIT(firer, TRAIT_IMMOBILIZED, REF(src))

/obj/item/projectile/hook/Destroy(force)
	if(firer)
		REMOVE_TRAIT(firer, TRAIT_IMMOBILIZED, REF(src))
		REMOVE_TRAIT(firer, TRAIT_INCAPACITATED, REF(src))
	QDEL_NULL(initial_chain)
	return ..()

/// Lightweight datum that just handles moving a target for the hook.
/// Do not use this outside this file. Or atleast make sure that you understand what you do.
/datum/hook_and_move
	/// Weakref to the victim we are dragging
	var/datum/weakref/victim_ref = null
	/// Weakref of the destination that the victim is heading towards.
	var/datum/weakref/destination_ref = null
	/// Weakref to the firer of the hook
	var/datum/weakref/firer_ref = null
	/// String to the REF() of the dude that fired us so we can ensure we always cleanup our traits
	var/firer_ref_string = null

	/// The last time our movement fired.
	var/last_movement = 0
	/// The chain beam we currently own.
	var/datum/beam/return_chain = null

	/// How many steps we force the victim to take per tick
	var/steps_per_tick = 5
	/// How long we knockdown the victim for.
	var/knockdown_time = (0.5 SECONDS)

/datum/hook_and_move/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	QDEL_NULL(return_chain)
	return ..()

/// Uses fastprocessing to move our victim to the destination at a rather fast speed.
/datum/hook_and_move/proc/begin_pulling(atom/movable/firer, atom/movable/victim, atom/destination, obj/item/projectile/P)
	return_chain = firer.Beam(victim, icon_state = "chain")
	return_chain.visuals.color = P.color

	firer_ref_string = REF(firer)
	ADD_TRAIT(victim, TRAIT_HOOKED, firer_ref_string)
	ADD_TRAIT(firer, TRAIT_IMMOBILIZED, REF(src))
	ADD_TRAIT(firer, TRAIT_INCAPACITATED, REF(src))

	if(isliving(victim))
		var/mob/living/fresh_meat = victim
		fresh_meat.Weaken(knockdown_time)

	destination_ref = WEAKREF(destination)
	victim_ref = WEAKREF(victim)
	firer_ref = WEAKREF(firer)

	START_PROCESSING(SSfastprocess, src)

/// Cancels processing and removes the trait from the victim.
/datum/hook_and_move/proc/end_movement()
	var/atom/movable/firer = firer_ref?.resolve()
	if(!QDELETED(firer))
		REMOVE_TRAIT(firer, TRAIT_IMMOBILIZED, REF(src))
		REMOVE_TRAIT(firer, TRAIT_INCAPACITATED, REF(src))

	var/atom/movable/victim = victim_ref?.resolve()
	if(!QDELETED(victim))
		REMOVE_TRAIT(victim, TRAIT_HOOKED, firer_ref_string)

	qdel(src)

/datum/hook_and_move/process(seconds_per_tick)
	var/atom/movable/victim = victim_ref?.resolve()
	var/atom/destination = destination_ref?.resolve()
	if(QDELETED(victim) || QDELETED(destination))
		end_movement()
		return

	var/steps_to_take = round(steps_per_tick * (world.time - last_movement))
	if(steps_to_take <= 0)
		return

	var/movement_result = attempt_movement(victim, destination)
	if(!movement_result || (victim.loc == destination.loc)) // either we failed our movement or our mission is complete
		end_movement()

/// Attempts to move the victim towards the destination. Returns TRUE if we do a successful movement, FALSE otherwise.
/// second_attempt is a boolean to prevent infinite recursion.
/// If this whole series of events wasn't reliant on SSfastprocess firing as fast as it does, it would have been more useful to make this a move loop datum. But, we need the speed.
/datum/hook_and_move/proc/attempt_movement(atom/movable/subject, atom/target, second_attempt = FALSE)
	var/actually_moved = FALSE
	if(!second_attempt)
		actually_moved = step_towards(subject, target)

	if(actually_moved)
		return TRUE

	// alright now the code fucking sucks
	var/subject_x = subject.x
	var/subject_y = subject.y
	var/target_x = target.x
	var/target_y = target.y

	//If we're going x, step x
	if((target_x > subject_x) && step(subject, EAST))
		actually_moved = TRUE
	else if((target_x < subject_x) && step(subject, WEST))
		actually_moved = TRUE

	if(actually_moved)
		return TRUE

	//If the x step failed, go y
	if((target_y > subject_y) && step(subject, NORTH))
		actually_moved = TRUE
	else if((target_y < subject_y) && step(subject, SOUTH))
		actually_moved = TRUE

	if(actually_moved)
		return TRUE

	// if we fail twice, abort. otherwise queue up the second attempt.
	if(second_attempt)
		return FALSE

	return attempt_movement(subject, target, second_attempt = TRUE)


/// Debug hook for fun (AKA admin abuse). doesn't do any more damage or anything just lets you wildfire it.
/obj/item/weapon/gun/magic/hook/debug
	name = "super meat hook"
	max_charges = 100
	recharge_rate = 1
	color = COLOR_PALE_RED_GRAY

/obj/item/projectile/hook/dark
	color = COLOR_BLACK
