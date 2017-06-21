/obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."

	school = "transmutation"
	charge_max = 300
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	centcomm_cancast = 0 // Prevent people from getting to centcomm

	action_icon_state = "jaunt"

	var phaseshift = 0
	var/jaunt_duration = 50 // in deciseconds

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/cast(list/targets) // magnets, so mostly hardcoded
	for(var/mob/living/target in targets)
		spawn(0)
			var/mobloc = get_turf(target.loc)
			var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "water"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.icon_state = "liquify"
			animation.layer = 5
			animation.master = holder
			target.ExtinguishMob()			// This spell can extinguish mob
			target.status_flags ^= GODMODE	// Protection from any kind of damage, caused you in astral world
			var/image/I = image('icons/mob/blob.dmi', holder, "marker", LIGHTING_LAYER+1)
			target.client.images += I
			if(phaseshift)
				animation.dir = target.dir
				flick("phase_shift",animation)
				target.forceMove(holder)
				target.client.eye = holder
				sleep(jaunt_duration)
				mobloc = get_turf(target.loc)
				animation.loc = mobloc
				target.canmove = 0
				sleep(20)
				animation.dir = target.dir
				flick("phase_shift2",animation)
			else
				flick("liquify",animation)
				target.forceMove(holder)
				target.client.eye = holder
				var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
				steam.set_up(10, 0, mobloc)
				steam.start()
				sleep(jaunt_duration)
				mobloc = get_turf(target.loc)
				animation.loc = mobloc
				steam.location = mobloc
				steam.start()
				target.canmove = 0
				sleep(20)
				flick("reappear",animation)
			sleep(5)
			target.client.images -= I
			target.forceMove(mobloc)
			target.canmove = 1
			target.client.eye = target
			target.status_flags ^= GODMODE	// Turn off this cheat
			qdel(animation)
			qdel(holder)

/obj/effect/dummy/spell_jaunt
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1

/obj/effect/dummy/spell_jaunt/relaymove(mob/user, direction)
	if (!src.canmove) return
	var/turf/newLoc = get_step(src,direction)
	if(!(newLoc.flags & NOJAUNT))
		loc = newLoc
	else
		to_chat(user, "<span class='warning'>Some strange aura is blocking the way!</span>")
	src.canmove = 0
	spawn(2) src.canmove = 1

/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return
/obj/effect/dummy/spell_jaunt/bullet_act(blah)
	return

/obj/effect/dummy/spell_jaunt/Destroy()
	for(var/atom/movable/AM in src)
		AM.loc = get_turf(src)
	return ..()
