var/global/list/obj/machinery/swarm_powered/bluespace_transponder/transponders = list()
var/global/list/obj/machinery/swarm_powered/bluespace_transponder/active_transponders = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/swarm_powered/bluespace_transponder, transponders)

/obj/machinery/swarm_powered

/obj/machinery/swarm_powered/powered()
	return ..() || global.replicators_faction.energy > idle_power_usage

/obj/machinery/swarm_powered/power_change()
	..()
	update_icon()

/obj/machinery/swarm_powered/proc/draw_energy()
	var/area/A = get_area(src)
	var/area_powered = A && A.powered(power_channel)

	var/has_reserve_power = global.replicators_faction.energy > idle_power_usage

	if(area_powered)
		return

	var/power_status_changed = FALSE

	if(has_reserve_power)
		if(stat & NOPOWER)
			power_status_changed = TRUE
			stat &= ~NOPOWER
		global.replicators_faction.energy -= idle_power_usage

	else if(!(stat & NOPOWER))
		power_status_changed = TRUE
		stat |= NOPOWER

	if(power_status_changed)
		update_icon()


/obj/machinery/swarm_powered/bluespace_transponder
	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_exit"
	name = "bluespace transponder"
	desc = "Huh."

	anchored = TRUE
	density = FALSE

	use_power = IDLE_POWER_USE
	idle_power_usage = 15000

	var/next_sound = 0

/obj/machinery/swarm_powered/bluespace_transponder/Crossed(atom/movable/AM)
	if(stat & NOPOWER)
		return ..()

	var/obj/structure/bluespace_corridor/BC = locate() in loc
	if(!BC)
		return ..()

	if(AM.invisibility > 0)
		return ..()

	var/see_invisible_level = 0
	if(ismob(AM))
		var/mob/M = AM
		see_invisible_level = M.see_invisible

	playsound(src, 'sound/magic/MAGIC_MISSILE.ogg', VOL_EFFECTS_MASTER, 60)
	AM.AddElement(/datum/element/bluespace_move, AM.invisibility, see_invisible_level, AM.alpha)

/obj/machinery/swarm_powered/bluespace_transponder/update_icon()
	if(stat & NOPOWER)
		global.active_transponders -= src
		icon_state = "bhole3"
	else
		global.active_transponders |= src
		icon_state = "bluespace_wormhole_exit"

/obj/machinery/swarm_powered/bluespace_transponder/Destroy()
	global.active_transponders -= src
	return ..()

/obj/machinery/swarm_powered/bluespace_transponder/process()
	draw_energy()

	if(next_sound < world.time && prob(5))
		next_sound = next_sound + 20 SECONDS
		playsound(src, 'sound/machines/signal.ogg', VOL_EFFECTS_MASTER)

/obj/machinery/swarm_powered/bluespace_transponder/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/replicator))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	return ..()


/obj/machinery/power/replicator_generator
	name = "bluespace generator"
	desc = "Huh."
	icon = 'icons/obj/objects.dmi'
	icon_state = "coolanttank"

	density = TRUE
	anchored = TRUE

	use_power = IDLE_POWER_USE
	idle_power_usage = 0

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

	var/next_sound = 0

/obj/machinery/power/replicator_generator/atom_init()
	. = ..()
	new /obj/structure/cable/power_rune(loc)

/obj/machinery/power/replicator_generator/process()
	if(next_sound < world.time && prob(5))
		next_sound = next_sound + 20 SECONDS
		playsound(src, 'sound/machines/signal.ogg', VOL_EFFECTS_MASTER)

	global.replicators_faction.energy += 15000

/obj/machinery/power/replicator_generator/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/replicator))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	return ..()


/turf/proc/get_untaken_replicator_color()
	var/list/possibilities = REPLICATOR_COLORS
	var/obj/structure/cable/power_rune/PR = locate() in src
	if(PR)
		possibilities -= PR.rune_color
	var/obj/structure/bluespace_corridor/BC = locate() in src
	if(BC)
		possibilities -= BC.rune_color
		possibilities -= BC.internal_rune_color
	return possibilities


/obj/structure/cable/power_rune
	name = "rune"
	desc = "Huh."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "power_rune"

	var/rune_color

/obj/structure/cable/power_rune/atom_init()
	. = ..()
	icon_state = "power_rune_[rand(1, 3)]"

	var/turf/my_turf = get_turf(src)

	rune_color = pick(my_turf.get_untaken_replicator_color())
	color = rune_color

	d1 = 0
	for(var/obj/structure/cable/C in get_turf(src))
		d2 = turn(C.d2, 180)
		break

	var/datum/powernet/PN = new
	PN.add_cable(src)

	mergeConnectedNetworks(d2) //merge the powernet with adjacents powernets
	mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

/obj/structure/cable/power_rune/update_icon()
	return


/obj/structure/bluespace_corridor
	name = "rune"
	desc = "Huh."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "transit_rune"

	var/neighbor_count = 0

	var/rune_color
	var/internal_rune_color

	// Images don't have invisibility.
	var/obj/effect/overlay/internal_overlay

/obj/structure/bluespace_corridor/atom_init()
	. = ..()

	icon_state = "transit_rune_[rand(1, 3)]"

	var/turf/my_turf = get_turf(src)

	rune_color = pick(my_turf.get_untaken_replicator_color())
	color = rune_color

	internal_rune_color = pick(my_turf.get_untaken_replicator_color())

	internal_overlay = new
	internal_overlay.icon = icon
	internal_overlay.icon_state = "corridor_internal"
	internal_overlay.color = internal_rune_color
	internal_overlay.invisibility = INVISIBILITY_LEVEL_TWO
	internal_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	// Invisibility doesn't work with overlays
	vis_contents += internal_overlay

	neighbor_adjust_count(my_turf, 1)

/obj/structure/bluespace_corridor/Destroy()
	vis_contents -= internal_overlay
	QDEL_NULL(internal_overlay)

	var/turf/my_turf = get_turf(src)
	if(my_turf)
		neighbor_adjust_count(my_turf, -1)

	return ..()

/obj/structure/bluespace_corridor/Crossed(atom/movable/AM)
	if(AM && AM.invisibility > 0 && prob(30))
		playsound(AM, 'sound/mecha/UI_SCI-FI_Tone_Deep_Wet_22_complite.ogg', VOL_EFFECTS_MASTER)
	return ..()

/obj/structure/bluespace_corridor/Moved(atom/OldLoc, move_dir)
	var/turf/old_turf = get_turf(OldLoc)
	var/turf/my_turf = get_turf(src)

	if(old_turf)
		neighbor_adjust_count(old_turf, -1)
	if(my_turf)
		neighbor_adjust_count(my_turf, 1)

/obj/structure/bluespace_corridor/proc/neighbor_adjust_count(turf/T, value)
	for(var/card_dir in global.cardinal)
		var/turf/other = get_step(T, card_dir)
		var/obj/structure/bluespace_corridor/BC = locate(/obj/structure/bluespace_corridor) in other
		if(!BC)
			continue
		BC.neighbor_count += value
		neighbor_count += value

var/global/list/obj/machinery/swarm_powered/bluespace_catapult/bluespace_catapults = list()
// Requires 10 drones in teh swarm.
ADD_TO_GLOBAL_LIST(/obj/machinery/swarm_powered/bluespace_catapult, bluespace_catapults)

/obj/machinery/swarm_powered/bluespace_catapult
	name = "bluespace catapult"
	desc = "Oh no."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "catapult"

	use_power = IDLE_POWER_USE
	idle_power_usage = 20000

	resize = 1.5

	density = TRUE
	anchored = TRUE

	var/max_required_power = 24000000
	var/max_required_materials = 2000

	var/required_power = 0
	var/required_materials = 0

	var/last_perc_announcement = 0

	var/victory = FALSE

/obj/machinery/swarm_powered/bluespace_catapult/atom_init()
	. = ..()
	var/datum/announcement/centcomm/replicator/construction_began/CB = new
	CB.play(get_area(src))

	required_power = max_required_power
	required_materials = max_required_materials

	update_transform()

/obj/machinery/swarm_powered/bluespace_catapult/process()
	var/materials_satisfied = required_materials / max_required_materials
	var/power_satisfied = required_power / max_required_power
	var/perc_finished = round((1 - materials_satisfied * power_satisfied) * 100)

	var/datum/announcement/centcomm/replicator/announcement
	if(perc_finished >= 25 && last_perc_announcement < 25)
		announcement = new /datum/announcement/centcomm/replicator/construction_quarter
		icon_state = "catapult_25"
	else if(perc_finished >= 50 && last_perc_announcement < 50)
		announcement = new /datum/announcement/centcomm/replicator/construction_half
		icon_state = "catapult_50"
	else if(perc_finished >= 75 && last_perc_announcement < 75)
		announcement = new /datum/announcement/centcomm/replicator/construction_three_quarters
		icon_state = "catapult_75"
	else if(perc_finished >= 100 && last_perc_announcement < 100)
		announcement = new /datum/announcement/centcomm/replicator/doom
		icon_state = "catapult_100"

		global.replicators_faction.announce_swarm("The Swarm", "The Swarm", "Mission accomplished.")
		density = FALSE

		for(var/mob/M in player_list)
			if(!isnewplayer(M))
				M.playsound_local(null, 'sound/effects/dimensional_rend.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)

	if(announcement)
		last_perc_announcement = perc_finished
		announcement.play(get_area(src))

	draw_energy()

	if(stat & NOPOWER)
		return

	if(required_power >= 0)
		required_power = max(0, required_power - idle_power_usage)

	if(global.replicators_faction.materials < REPLICATOR_COST_REPLICATE + 5 || required_materials <= 0)
		return

	global.replicators_faction.adjust_materials(-5)
	required_materials = max(0, required_materials - 5)

/obj/machinery/swarm_powered/bluespace_catapult/Crossed(atom/movable/AM)
	if(isreplicator(AM))
		var/mob/living/simple_animal/replicator/R = AM
		global.replicators_faction.replicators_launched += 1

		R.death()
		qdel(R)

		if(global.replicators_faction.replicators_launched >= 10 && !victory)
			victory = TRUE
			INVOKE_ASYNC(global.replicators_faction, /datum/faction/replicators.proc/victory_animation, get_turf(src))

		return

	return ..()

/obj/machinery/swarm_powered/bluespace_catapult/examine(mob/user)
	. = ..()
	if(!isreplicator(user))
		return
	if(required_materials > 0)
		to_chat(user, "<span class='notice'>It requires [required_materials] more materials.</span>")
	if(required_power > 0)
		to_chat(user, "<span class='notice'>It required [required_power] more power.</span>")
