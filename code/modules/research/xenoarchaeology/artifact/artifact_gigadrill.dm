/obj/machinery/giga_drill
	name = "alien drill"
	desc = "A giant alien drill mounted on long treads."
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "gigadrill"
	use_power = NO_POWER_USE
	density = TRUE
	layer = 3.1 // to go over ores
	var/active = FALSE
	var/drill_time = 5
	var/turf/drilling_turf
	var/cooldown = null

/obj/machinery/giga_drill/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(user.is_busy())
		return
	if(active)
		flick("gigadrill_off", src)
	else
		flick("gigadrill_on", src)
	if(do_after(user, 5, target = src))
		to_chat(user, "<span class='notice'>You pull the lever on \the [src].</span>")
		if(active)
			active = FALSE
			icon_state = "gigadrill"
			src.visible_message("<span class='notice'>[src] slowly spins down.</span>")
			playsound(src, 'sound/mecha/powerup.ogg', VOL_EFFECTS_MASTER)
		else
			active = TRUE
			icon_state = "gigadrill_active"
			src.visible_message("<span class='warning'>[src]  shudders to life!</span>")
			playsound(src, 'sound/mecha/mechmove03.ogg', VOL_EFFECTS_MASTER)

/obj/machinery/giga_drill/Bump(atom/A) // It drills the mineral if it bumps to it.
	if(active && !drilling_turf)
		if(istype(A, /turf/simulated/mineral))
			var/turf/simulated/mineral/M = A
			drilling_turf = get_turf(src)
			src.visible_message("<span class='warning'><b>[src] begins to drill into \the [M].</b></span>")
			playsound(src, 'sound/mecha/mechdrill.ogg', VOL_EFFECTS_MASTER)
			anchored = TRUE
			addtimer(CALLBACK(src, .proc/drill_mineral, M), drill_time)
		else if(world.time >= cooldown && istype(A, /turf/simulated))
			cooldown = world.time + 10
			src.visible_message("<span class='warning'>[src] can't drill through \the [A].</span>")

/obj/machinery/giga_drill/proc/drill_mineral(turf/simulated/mineral/M)
	if(get_turf(src) == drilling_turf && active)
		M.GetDrilled()
		src.loc = M
		var/list/viewing = list()
		for(var/mob/H in viewers(src))
			if(H.client)
				viewing += H.client
		flick_overlay(image(icon, src, "gigadrill_move"), viewing, 4)
	drilling_turf = null
	anchored = FALSE
