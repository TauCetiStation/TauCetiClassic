/obj/machinery/drone_fabricator
	name = "drone fabricator"
	desc = "A large automated factory for producing maintenance drones."

	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000

	var/drone_progress = 0
	var/produce_drones = 1
	var/time_last_drone = 500

	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"

/obj/machinery/drone_fabricator/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		icon_state = "drone_fab_nopower"
		stat |= NOPOWER
	update_power_use()

/obj/machinery/drone_fabricator/process()

	if(SSticker.current_state < GAME_STATE_PLAYING)
		return

	if(stat & NOPOWER || !produce_drones)
		if(icon_state != "drone_fab_nopower") icon_state = "drone_fab_nopower"
		return

	if(drone_progress >= 100)
		icon_state = "drone_fab_idle"
		return

	icon_state = "drone_fab_active"
	var/elapsed = world.time - time_last_drone
	drone_progress = round((elapsed/config.drone_build_time)*100)

	if(drone_progress >= 100)
		visible_message("\The [src] voices a strident beep, indicating a drone chassis is prepared.")

/obj/machinery/drone_fabricator/examine(mob/user)
	..()
	if(produce_drones && drone_progress >= 100 && istype(user,/mob/dead) && config.allow_drone_spawn && count_drones() < config.max_maint_drones)
		to_chat(user, "<BR><B>A drone is prepared. Select 'Spawners Menu' from the Ghost tab, and choose the Drone role to spawn as a maintenance drone.</B>")

/obj/machinery/drone_fabricator/proc/count_drones()
	var/drones = 0
	for(var/mob/living/silicon/robot/drone/D as anything in drone_list)
		if(D.key && D.client)
			drones++
	return drones

/obj/machinery/drone_fabricator/proc/create_drone(client/player)

	if(stat & NOPOWER)
		return

	if(!produce_drones || !config.allow_drone_spawn || count_drones() >= config.max_maint_drones)
		return

	if(!player) //|| !istype(player.mob,/mob/dead))
		return

	visible_message("\The [src] churns and grinds as it lurches into motion, disgorging a shiny new drone after a few moments.")
	flick("h_lathe_leave",src)

	time_last_drone = world.time
	var/mob/living/silicon/robot/drone/maintenance/new_drone = new(get_turf(src))
	new_drone.transfer_personality(player)
	new_drone.mind.skills.add_available_skillset(/datum/skillset/cyborg)
	new_drone.mind.skills.maximize_active_skills()
	drone_progress = 0

/obj/machinery/drone_fabricator/atom_break(damage_flag)
	. = ..()
	if(!.)
		return
	audible_message("<span class='warning'>[src] lets out a tinny alarm before falling dark.</span>")
	playsound(loc, 'sound/machines/warning-buzzer.ogg', VOL_EFFECTS_MASTER, 50, TRUE)

/obj/machinery/drone_fabricator/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/metal(loc, 5)
	..()

/mob/proc/dronize()

	for(var/obj/machinery/drone_fabricator/DF in machines)
		if(DF.stat & NOPOWER || !DF.produce_drones)
			continue

		if(DF.count_drones() >= config.max_maint_drones)
			to_chat(src, "<span class='warning'>There are too many active drones in the world for you to spawn.</span>")
			return

		if(DF.drone_progress >= 100)
			DF.create_drone(src.client)
			return

	to_chat(src, "<span class='warning'>There are no available drone spawns, sorry. Drone fabricators is out of service, or no drones produced yet.</span>")
