#define FLICK_OVERLAY_JAUNT_DURATION 12

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
	centcomm_cancast = 0 //Prevent people from getting to centcomm

	action_icon_state = "jaunt"

	var/phaseshift = 0
	var/jaunt_duration = 62 //in deciseconds

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/cast(list/targets) //magnets, so mostly hardcoded
	set waitfor = FALSE
	for(var/mob/living/target in targets)
		var/turf/mobloc = get_turf(target.loc)
		var/obj/effect/dummy/spell_jaunt/holder = new(mobloc)
		target.ExtinguishMob()			//This spell can extinguish mob
		target.status_flags ^= GODMODE	//Protection from any kind of damage, caused you in astral world
		holder.master = target
		var/list/companions = handle_teleport_grab(holder, target)
		if(companions)
			for(var/M in companions)
				var/mob/living/L = M
				L.status_flags ^= GODMODE
				L.ExtinguishMob()
		var/image/I = image('icons/mob/blob.dmi', holder, "marker", LIGHTING_LAYER+1)
		if(target.client)
			target.client.images += I
			target.forceMove(holder)
			target.client.eye = holder

		if(phaseshift)
			holder.dir = target.dir
			flick("phase_shift", holder)

			sleep(FLICK_OVERLAY_JAUNT_DURATION)
			holder.canmove = TRUE
			sleep(jaunt_duration)

			mobloc = get_turf(target.loc)
			holder.canmove = FALSE
			flick("phase_shift2", holder)
		else
			flick("liquify", holder)
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, mobloc)
			steam.start()

			sleep(FLICK_OVERLAY_JAUNT_DURATION)
			holder.canmove = TRUE
			sleep(jaunt_duration)

			mobloc = get_turf(target.loc)
			steam.location = mobloc
			steam.start()
			holder.canmove = FALSE
			flick("reappear", holder)

		sleep(FLICK_OVERLAY_JAUNT_DURATION)
		if(target.client)
			target.client.images -= I
			target.client.eye = target
		target.status_flags ^= GODMODE	//Turn off this cheat
		if(companions)
			for(var/M in companions)
				var/mob/living/L = M
				L.status_flags ^= GODMODE
		qdel(holder)

/obj/effect/dummy/spell_jaunt
	name = "water"
	last_move = 0
	density = 0
	anchored = 1
	layer = 5
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank"
	var/mob/master
	var/canmove = FALSE


/obj/effect/dummy/spell_jaunt/relaymove(mob/user, direction)
	if(!canmove || last_move + 2 > world.time)
		return
	if(user != master)
		return
	var/turf/newLoc = get_step(src,direction)
	if(!(newLoc.flags & NOJAUNT))
		loc = newLoc
	else
		to_chat(user, "<span class='warning'>Some strange aura is blocking the way!</span>")
	dir = direction
	last_move = world.time

/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return

/obj/effect/dummy/spell_jaunt/bullet_act(blah)
	return

/obj/effect/dummy/spell_jaunt/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	master = null
	return ..()

#undef FLICK_OVERLAY_JAUNT_DURATION