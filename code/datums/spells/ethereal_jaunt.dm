#define FLICK_OVERLAY_JAUNT_DURATION 12

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	name = "Выход из Тела"
	desc = "Делает вас прозрачным и невидимым, позволяя летать и проходить сквозь стены."
	charge_max = 30 SECONDS
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	action_icon_state = "jaunt"
	var/icon/dissapear_animation //what animation is gonna get played on spell cast
	var/icon/appear_animation //what animation is gonna get played on spell end
	var/movement_cooldown = 2 //movement speed, less is faster
	var/jaunt_duration = 6 SECONDS //how long jaunt will last

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/cast(list/targets) //magnets, so mostly hardcoded
	set waitfor = FALSE

	for(var/mob/living/target in targets)
		if(!target.canmove)
			continue

		var/turf/mobloc = get_turf(target.loc)
		var/obj/effect/dummy/spell_jaunt/holder = new(mobloc)
		holder.modifier_delay = movement_cooldown
		target.ExtinguishMob()			//This spell can extinguish mob
		target.add_status_flags(GODMODE) //Protection from any kind of damage, caused you in astral world

		var/remove_xray = FALSE
		if(!(XRAY in target.mutations))
			target.mutations += XRAY
			target.update_sight()
			remove_xray = TRUE

		holder.master = target
		var/list/companions = handle_teleport_grab(holder, target)
		if(companions)
			for(var/M in companions)
				var/mob/living/L = M
				L.add_status_flags(GODMODE)
				L.ExtinguishMob()
		var/image/I = image('icons/mob/blob.dmi', holder, "marker")
		I.plane = HUD_PLANE
		holder.indicator = I
		if(target.client)
			target.client.images += I
			target.forceMove(holder)
			target.client.eye = holder
		holder.set_dir(target.dir)
		holder.canmove = TRUE
		if(dissapear_animation)
			holder.canmove = FALSE
			flick(dissapear_animation, holder)
			sleep(FLICK_OVERLAY_JAUNT_DURATION)
			holder.canmove = TRUE
		sleep(jaunt_duration)
		if(appear_animation)
			holder.canmove = FALSE
			flick(appear_animation, holder)
			sleep(FLICK_OVERLAY_JAUNT_DURATION)
			holder.canmove = TRUE
		mobloc = get_turf(target.loc)
		if(target.client)
			target.client.images -= I
			target.client.eye = target
		target.remove_status_flags(GODMODE)	//Turn off this cheat
		if(remove_xray)
			target.mutations -= XRAY
			target.update_sight()
		if(companions)
			for(var/M in companions)
				var/mob/living/L = M
				L.remove_status_flags(GODMODE)
		target.eject_from_wall(gib = TRUE, companions = companions)
		qdel(holder)

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/phaseshift
	charge_max = 40 SECONDS
	clothes_req = 0
	jaunt_duration = 4 SECONDS
	action_icon_state = "phaseshift"
	action_background_icon_state = "bg_cult"
	dissapear_animation = icon(icon = 'icons/mob/mob.dmi', icon_state = "phase_shift")
	appear_animation = icon(icon = 'icons/mob/mob.dmi', icon_state = "phase_shift2")

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shadow_walk
	name = "Shadow Walk"
	desc = "Phases you into the space between worlds for a short time, allowing movement through walls and invisbility."
	panel = "Shadowling Abilities"
	charge_max = 60 SECONDS
	clothes_req = 0
	action_icon_state = "jaunt"
	jaunt_duration = 6 SECONDS
	movement_cooldown = -1
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shadow_walk/cast(list/targets)
	..()
	usr.visible_message("<span class='warning'>[usr] vanishes in a puff of black mist!</span>", "<span class='shadowling'>You enter the space between worlds as a passageway.</span>")
	sleep(jaunt_duration)
	usr.visible_message("<span class='warning'>[usr] suddenly manifests!</span>", "<span class='shadowling'>The pressure becomes too much and you vacate the interdimensional darkness.</span>")

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/wizard
	school = "transmutation"
	centcomm_cancast = 0 //Prevent people from getting to centcomm
	dissapear_animation = icon(icon = 'icons/mob/mob.dmi', icon_state = "liquify")
	appear_animation = icon(icon = 'icons/mob/mob.dmi', icon_state = "reappear")

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/wizard/cast(list/targets)
	..()
	var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
	steam.set_up(10, 0, get_turf(usr.loc))
	steam.start()
	sleep(jaunt_duration + FLICK_OVERLAY_JAUNT_DURATION)
	steam.location = get_turf(usr.loc)
	steam.start()

/obj/effect/dummy/spell_jaunt
	name = "water"
	last_move = 0
	density = FALSE
	anchored = TRUE
	layer = FLY_LAYER
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank"
	var/mob/master
	var/canmove = FALSE
	var/image/indicator
	var/modifier_delay = 2

/obj/effect/dummy/spell_jaunt/relaymove(mob/user, direction)

	if(last_move + modifier_delay > world.time)
		return
	if(user != master)
		return

	last_move = world.time
	
	var/turf/newLoc = get_step(src,direction)

	if(SEND_SIGNAL(newLoc, COMSIG_ATOM_INTERCEPT_TELEPORT))
		to_chat(user, "<span class='warning'>Some strange aura is blocking the way!</span>")
		return FALSE

	if(canmove)
		loc = newLoc // breaks entered/exit callbacks, but forcemove can trigger unnecessary things like traps

	dir = direction
	if(indicator)
		var/turf/T = get_turf(loc)
		indicator.icon_state = "marker[T.is_mob_placeable() ? "" : "_danger"]"

/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return

/obj/effect/dummy/spell_jaunt/bullet_act(obj/item/projectile/P, def_zone)
	return PROJECTILE_ACTED // I think bullet_act should not be called

/obj/effect/dummy/spell_jaunt/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	master = null
	QDEL_NULL(indicator)
	return ..()

#undef FLICK_OVERLAY_JAUNT_DURATION

/mob/proc/eject_from_wall(gib = FALSE, prioritize_ground = TRUE, list/companions = null)
	var/turf/mobloc = get_turf(loc)
	if(mobloc.is_mob_placeable(src))
		return
	var/found_ground = !prioritize_ground // this is to give priority to non-space tiles
	var/to_gib = gib // this is a small feature i considered funny.
	                  // chances of this occuring are very small
	                  // as it requires 9x9 grid of impassable tiles ~getup1
	for(var/turf/newloc in orange(1, mobloc))
		if(newloc.is_mob_placeable(src) && !isenvironmentturf(newloc) && !SEND_SIGNAL(newloc, COMSIG_ATOM_INTERCEPT_TELEPORT))
			found_ground = TRUE
			to_gib = FALSE
			forceMove(newloc)
			if(companions)
				for(var/mob/M in companions)
					M.forceMove(newloc)
			return
	if(!found_ground)
		for(var/turf/newloc in orange(1, mobloc))
			if(newloc.is_mob_placeable(src))
				to_gib = FALSE
				forceMove(newloc)
				if(companions)
					for(var/mob/M in companions)
						M.forceMove(newloc)
				return
	if(to_gib)
		gib()
		if(companions)
			for(var/mob/M in companions)
				M.gib()
