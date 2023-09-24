/obj/machinery/swarm_powered
	var/mob/living/simple_animal/hostile/replicator/drone_supply

	var/prioritized = FALSE

/obj/machinery/swarm_powered/atom_init()
	. = ..()
	if(prioritized)
		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		FR.prioritized_load += idle_power_usage

	update_icon()

/obj/machinery/swarm_powered/Destroy()
	if(prioritized)
		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		FR.prioritized_load -= idle_power_usage
	drone_supply = null
	return ..()

/obj/machinery/swarm_powered/powered()
	. = ..()
	if(.)
		return

	if(drone_supply && !drone_supply.incapacitated())
		return

	return can_draw_swarm_energy()

/obj/machinery/swarm_powered/power_change()
	..()
	update_icon()

/obj/machinery/swarm_powered/proc/draw_energy()
	var/area/A = get_area(src)
	var/area_powered = A && A.powered(power_channel)

	if(area_powered)
		return

	if(draw_energy_from_drone())
		if(stat & NOPOWER)
			stat &= ~NOPOWER
			update_icon()

	else if(can_draw_swarm_energy())
		if(stat & NOPOWER)
			stat &= ~NOPOWER
			update_icon()
		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		FR.adjust_energy(-idle_power_usage)

	else if(!(stat & NOPOWER))
		stat |= NOPOWER
		update_icon()

/obj/machinery/swarm_powered/proc/can_draw_swarm_energy()
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/energy_available = FR.energy
	if(!prioritized)
		energy_available -= FR.prioritized_load

	return energy_available >= idle_power_usage

/obj/machinery/swarm_powered/proc/start_drone_energy_supply(mob/living/simple_animal/hostile/replicator/R)
	if(drone_supply)
		return

	// to-do: (replicators) add a sound here. the sound should sound somewhat scary but awe-inspiring, a noble sacrifice is being made
	to_chat(R, "<span class='notice'>You power [src] via your own energy, breaking yourself apart.</span>")
	R.visible_message("<span class='notice'>[R] is crumbling apart, holding the portal open.</span>")

	drone_supply = R
	RegisterSignal(drone_supply, list(COMSIG_PARENT_QDELETING), PROC_REF(stop_drone_energy_supply))
	RegisterSignal(drone_supply, list(COMSIG_MOVABLE_MOVED), PROC_REF(check_drone_proximity))

	drone_supply.sacrifice_powering = TRUE

/obj/machinery/swarm_powered/proc/check_drone_proximity()
	SIGNAL_HANDLER

	if(drone_supply.loc != loc)
		stop_drone_energy_supply()

/obj/machinery/swarm_powered/proc/stop_drone_energy_supply()
	SIGNAL_HANDLER

	// to-do: (replicators) add a sound here. something noble, the drone has either fallen helping out his comrades, or the deed has been accomplished
	drone_supply.sacrifice_powering = FALSE

	UnregisterSignal(drone_supply, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
	drone_supply = null

	if(!powered() && !(stat & NOPOWER))
		stat |= NOPOWER
		update_icon()

/obj/machinery/swarm_powered/proc/draw_energy_from_drone()
	if(!drone_supply)
		return FALSE

	if(drone_supply.incapacitated())
		stop_drone_energy_supply()
		return FALSE

	drone_supply.take_bodypart_damage(0, 5)
	return TRUE


var/global/list/obj/machinery/swarm_powered/bluespace_transponder/transponders = list()
var/global/list/obj/machinery/swarm_powered/bluespace_transponder/active_transponders = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/swarm_powered/bluespace_transponder, transponders)

/obj/machinery/swarm_powered/bluespace_transponder
	name = "bluespace transponder"
	desc = "An exit from the web of bluespace corridors - or is it the entrance to them?"

	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_exit"

	anchored = TRUE
	density = FALSE

	use_power = IDLE_POWER_USE
	idle_power_usage = REPLICATOR_TRANSPONDER_POWER_USAGE

	max_integrity = 600
	resistance_flags = CAN_BE_HIT

	var/destroy_unpowered_after = 0
	var/destroy_unpowered_time = 2 MINUTES

	var/next_sound = 0

	var/obj/item/device/assembly/signaler/anomaly/deactivation_signal = null

/obj/machinery/swarm_powered/bluespace_transponder/atom_init(mapload)
	. = ..()

	var/freq = rand(1200, 1599)
	if(IS_MULTIPLE(freq, 2))//signaller frequencies are always uneven!
		freq++

	deactivation_signal = new(src, freq)
	deactivation_signal.frequency = freq
	deactivation_signal.name = "[name] core"
	deactivation_signal.code = rand(1, 100)

	AddComponent(/datum/component/replicator_regeneration)

	for(var/mob/living/simple_animal/hostile/replicator/R in get_turf(src))
		try_enter_corridor(R)

/obj/machinery/swarm_powered/bluespace_transponder/Destroy()
	QDEL_NULL(deactivation_signal)
	global.active_transponders -= src

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.destroyed_transponders += 1

	return ..()

/obj/machinery/swarm_powered/bluespace_transponder/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return

	to_chat(user, "<span class='notice'>And only you could possibly know. That they are indeed both. The beggining and the end.</span>")

/obj/machinery/swarm_powered/bluespace_transponder/proc/try_enter_corridor(atom/movable/AM)
	if(stat & NOPOWER)
		if(isreplicator(AM))
			start_drone_energy_supply(AM)
			return FALSE
		return FALSE

	var/obj/structure/bluespace_corridor/BC = locate() in loc
	if(!BC)
		return FALSE

	if(AM.invisibility > 0)
		return FALSE

	var/see_invisible_level = 0
	if(ismob(AM))
		var/mob/M = AM
		see_invisible_level = M.see_invisible

	playsound(src, 'sound/magic/MAGIC_MISSILE.ogg', VOL_EFFECTS_MASTER, 60)
	AM.AddComponent(/datum/component/bluespace_move, src, AM.invisibility, see_invisible_level, AM.alpha)
	return TRUE

/obj/machinery/swarm_powered/bluespace_transponder/Crossed(atom/movable/AM)
	if(try_enter_corridor(AM))
		return

	return ..()

/obj/machinery/swarm_powered/bluespace_transponder/start_drone_energy_supply(mob/living/simple_animal/hostile/replicator/R)
	. = ..()
	playsound(R, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	playsound(R, 'sound/mecha/Mech_Step.ogg', VOL_EFFECTS_MASTER, 80)

/obj/machinery/swarm_powered/bluespace_transponder/stop_drone_energy_supply(mob/living/simple_animal/hostile/replicator/R)
	playsound(R, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	return ..()

/obj/machinery/swarm_powered/bluespace_transponder/update_icon()
	if(stat & NOPOWER)
		global.active_transponders -= src
		icon_state = "bhole3"
		destroy_unpowered_after = world.time + destroy_unpowered_time
	else
		global.active_transponders |= src
		icon_state = "bluespace_wormhole_exit"
		destroy_unpowered_after = 0

/obj/machinery/swarm_powered/bluespace_transponder/process()
	draw_energy()

	if(next_sound < world.time && prob(5))
		next_sound = next_sound + 20 SECONDS
		playsound(src, 'sound/machines/signal.ogg', VOL_EFFECTS_MASTER)

	if(destroy_unpowered_after && destroy_unpowered_after < world.time)
		var/area/A = get_area(src)
		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		FR.object_communicate(src, "", "Has closed in [A.name], due to lack of energy.")
		FR.adjust_materials(REPLICATOR_COST_TRANSPONDER)

		// I'm not destroyed I did it on my own.
		FR.destroyed_transponders -= 1

		QDEL_NULL(deactivation_signal)
		neutralize()

	if(stat & NOPOWER)
		return

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()

	if(FR.gas > REPLICATOR_GAS_MOLES_TRANSPONDER_DISSIPATE_PER_TICK)
		var/total_waste = min(FR.gas, length(global.active_transponders) * REPLICATOR_GAS_MOLES_TRANSPONDER_DISSIPATE_PER_TICK)
		var/waste_per_portal = total_waste / length(global.active_transponders)

		if(FR.dissipate_fractol(src, waste_per_portal))
			FR.adjust_fractol(-waste_per_portal)
	else if(FR.gas > 0)
		if(FR.dissipate_fractol(src, FR.gas))
			FR.adjust_fractol(-FR.gas)

	if(length(global.alive_replicators) < FR.bandwidth * 0.5)
		return

	if(FR.collect_taxes(REPLICATOR_TRANSPONDER_CONSUMPTION_RATE))
		FR.materials_consumed += REPLICATOR_TRANSPONDER_CONSUMPTION_RATE

/obj/machinery/swarm_powered/bluespace_transponder/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/replicator))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	return ..()

/obj/machinery/swarm_powered/bluespace_transponder/proc/neutralize()
	playsound(src, 'sound/effects/basscannon.ogg', VOL_EFFECTS_MASTER, 50)
	visible_message("<span class='notice'>[src] beeps for the last time, and collapses.</span>")
	if(deactivation_signal)
		deactivation_signal.forceMove(loc)
		deactivation_signal = null
	qdel(src)

/obj/machinery/swarm_powered/bluespace_transponder/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/analyzer))
		to_chat(user, "<span class='notice'>Analyzing... [src]'s unstable field is fluctuating along frequency [deactivation_signal.code]:[format_frequency(deactivation_signal.frequency)].</span>")
		return
	return ..()

/obj/machinery/swarm_powered/bluespace_transponder/emp_act(severity)
	. = ..()
	take_damage(100.0 / severity, damage_type = BURN)
	if(get_integrity() <= 0)
		QDEL_NULL(deactivation_signal)

var/global/list/obj/machinery/power/replicator_generator/replicator_generators = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/power/replicator_generator, replicator_generators)

/obj/machinery/power/replicator_generator
	name = "bluespace generator"
	desc = "A device to harness the power of the bluespace flow. You wonder what might need so much energy."
	icon = 'icons/obj/machines/field_generator.dmi'
	icon_state = "Field_Gen"

	density = TRUE
	anchored = TRUE

	use_power = IDLE_POWER_USE
	idle_power_usage = 0

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

	var/next_sound = 0

	var/next_teleportation = 0
	var/teleportation_cooldown = 1 MINUTE

	var/has_crystal = TRUE

/obj/machinery/power/replicator_generator/atom_init()
	. = ..()
	if(!(locate(/obj/structure/cable/power_rune) in loc))
		new /obj/structure/cable/power_rune(loc)

	var/obj/structure/forcefield_node/FN = locate() in loc
	if(FN)
		FN.layer = LOW_OBJ_LAYER
		FN.remove_area_node(FN)

	AddComponent(/datum/component/replicator_regeneration)

	update_icon()

/obj/machinery/power/replicator_generator/Destroy()
	playsound(loc, pick('sound/machines/arcade/gethit1.ogg', 'sound/machines/arcade/gethit2.ogg', 'sound/machines/arcade/-mana1.ogg', 'sound/machines/arcade/-mana2.ogg'), VOL_EFFECTS_MASTER)

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.destroyed_generators += 1

	if(has_crystal)
		new /obj/item/bluespace_crystal/artificial(loc)

	var/obj/structure/forcefield_node/FN = locate() in loc
	if(FN)
		FN.layer = ABOVE_OBJ_LATER
		FN.add_area_node(FN)

	return ..()

/obj/machinery/power/replicator_generator/emp_act(severity)
	. = ..()
	next_teleportation = world.time + teleportation_cooldown / severity
	update_icon()

/obj/machinery/power/replicator_generator/update_icon()
	cut_overlays()
	if(next_teleportation <= world.time)
		add_overlay("+on")

/obj/machinery/power/replicator_generator/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return

	to_chat(user, "<span class='notice'>It's obivous! The power is needed for Bluespace Transponders. Powers approximately [round(REPLICATOR_GENERATOR_POWER_GENERATION / REPLICATOR_TRANSPONDER_POWER_USAGE)] of them.</span>")
	var/teleport_string = "."
	if(next_teleportation > world.time)
		teleport_string = ", this one however can not for the next [CEIL((next_teleportation - world.time) * 0.1)] seconds."
	to_chat(user, "<span class='notice'>You also know it can be used to teleport to other generators[teleport_string]</span>")

/obj/machinery/power/replicator_generator/Moved(atom/OldLoc, moveddir)
	. = ..()

	var/obj/structure/forcefield_node/FN_oldLoc = locate() in OldLoc
	if(FN_oldLoc)
		FN_oldLoc.add_area_node(FN_oldLoc)

	var/obj/structure/forcefield_node/FN = locate() in loc
	if(FN)
		FN.remove_area_node(FN)

/obj/machinery/power/replicator_generator/process()
	if(next_teleportation > world.time)
		return

	if(next_sound < world.time && prob(5))
		next_sound = next_sound + 20 SECONDS
		playsound(src, 'sound/machines/signal.ogg', VOL_EFFECTS_MASTER)

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.adjust_energy(REPLICATOR_GENERATOR_POWER_GENERATION)

/obj/machinery/power/replicator_generator/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/replicator))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	return ..()

/obj/machinery/power/replicator_generator/Crossed(atom/movable/AM)
	if(!isreplicator(AM))
		return ..()

	var/obj/structure/bluespace_corridor/BC = locate() in loc
	if(!BC)
		return ..()

	if(AM.invisibility <= 0)
		return ..()

	INVOKE_ASYNC(src, PROC_REF(try_teleport), AM)

/obj/machinery/power/replicator_generator/proc/teleportation_checks(mob/living/simple_animal/hostile/replicator/R, obj/machinery/power/replicator_generator/target)
	if(!R.is_controlled())
		return FALSE
	if(target.next_teleportation > world.time)
		return FALSE
	if(target.stat & BROKEN)
		return FALSE
	if(!(locate(/obj/structure/bluespace_corridor) in target.loc))
		return FALSE
	if(R.invisibility <= 0)
		return FALSE
	return TRUE

/obj/machinery/power/replicator_generator/proc/try_teleport(mob/living/simple_animal/hostile/replicator/R)
	if(R.incapacitated())
		return
	if(!R.is_controlled())
		return
	if(next_teleportation > world.time)
		to_chat(R, "<span class='notice'>Can not teleport at this moment, please wait for [CEIL((next_teleportation - world.time) * 0.1)] seconds.</span>")
		return

	if(length(global.replicator_generators) <= 1)
		to_chat(R, "<span class='notice'>No other generators to teleport to.</span>")
		return

	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	visible_message("<span class='notice'>[src] appears to be charging up.</span>")
	if(!do_after(R, 3 SECONDS, target=src, extra_checks=CALLBACK(src, PROC_REF(teleportation_checks))))
		return

	var/list/pos_areas = list()

	for(var/obj/machinery/power/replicator_generator/RG as anything in global.replicator_generators)
		if(RG == src)
			continue
		if(RG.stat & BROKEN)
			continue
		if(!(locate(/obj/structure/bluespace_corridor) in RG.loc))
			continue
		if(RG.next_teleportation > world.time)
			continue

		var/area/A = get_area(RG)
		pos_areas[A.name] = A

	var/area_name = tgui_input_list(R, "Choose an area with a generator in it.", "Generator Transfer", pos_areas)
	if(!area_name)
		return
	if(R.loc != loc)
		return
	if(!R.is_controlled())
		return
	if(R.incapacitated())
		to_chat(R, "<span class='notice'>Unit too weak to support teleportation efforts.</span>")
		return
	if(R.invisibility <= 0)
		return
	var/obj/structure/bluespace_corridor/BC = locate() in loc
	if(!BC)
		return

	var/area/thearea = pos_areas[area_name]

	for(var/obj/machinery/power/replicator_generator/RG in thearea)
		if(RG == src)
			continue
		if(RG.stat & BROKEN)
			continue
		if(!(locate(/obj/structure/bluespace_corridor) in RG.loc))
			continue
		if(RG.next_teleportation > world.time)
			continue

		next_teleportation = world.time + teleportation_cooldown
		RG.next_teleportation = world.time + teleportation_cooldown

		update_icon()
		RG.update_icon()

		var/teleported_anyone = FALSE
		for(var/mob/living/simple_animal/hostile/replicator/R_teleporting in loc)
			if(R_teleporting.invisibility <= 0)
				continue

			flash_color(src, flash_color=BC.color, flash_time=5)

			R_teleporting.forceMove(RG.loc)
			teleported_anyone = TRUE

		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), teleportation_cooldown)
		addtimer(CALLBACK(RG, TYPE_PROC_REF(/atom, update_icon)), teleportation_cooldown)

		if(teleported_anyone)
			playsound(src, 'sound/magic/MAGIC_MISSILE.ogg', VOL_EFFECTS_MASTER, 60)
			playsound(RG, 'sound/magic/blink.ogg', VOL_EFFECTS_MASTER, 60)
		return

	to_chat(R, "<span class='notice'>Teleportation failed, due to a cooldown, lack of generators in the area, or destruction of the Web.</span>")

/turf/proc/get_untaken_replicator_color()
	var/list/possibilities = REPLICATOR_RUNE_COLORS
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
	desc = "A cypher, beholdeth to no one."
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

/obj/structure/cable/power_rune/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return

	to_chat(user, "<span class='notice'>Not even you could possibly know what use this has.</span>")

/obj/structure/cable/power_rune/update_icon()
	return

/obj/structure/cable/power_rune/emp_act(severity)
	. = ..()
	if(prob(20 / severity))
		qdel(src)


/obj/structure/bluespace_corridor
	name = "rune"
	desc = "A cypher, to the web of lies."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "transit_rune"

	density = FALSE
	anchored = TRUE

	var/next_obstacle_animation = 0

	var/neighbor_count = 0

	var/rune_color
	var/internal_rune_color

	// Images don't have invisibility.
	var/obj/effect/overlay/internal_overlay

	var/creator_ckey

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

/obj/structure/bluespace_corridor/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return

	to_chat(user, "<span class='notice'>Ah, the subtle intricacies of how this rune interacts with the Web, with how it interacts with the Nodes. You are certain you can enter it through a Bluespace Transponder.</span>")

/obj/structure/bluespace_corridor/proc/animate_obstacle()
	if(next_obstacle_animation > world.time)
		return
	next_obstacle_animation = world.time + 6

	var/matrix/old_transform = matrix(transform)
	var/old_color = color

	color = pick(REPLICATOR_RUNE_COLORS)

	var/matrix/M = matrix(transform)
	M.Scale(1.2, 1.2)

	animate(src, transform=M, time=4)
	animate(transform=old_transform,time=2)

	sleep(6)

	transform = old_transform
	color = old_color

/obj/structure/bluespace_corridor/Crossed(atom/movable/AM)
	if(AM && AM.invisibility > 0 && prob(30))
		playsound(AM, 'sound/mecha/UI_SCI-FI_Tone_Deep_Wet_22_complite.ogg', VOL_EFFECTS_MASTER)

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[creator_ckey]
	if(RAI)
		RAI.corridor_crossed_times += 1

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

/obj/structure/bluespace_corridor/attackby(obj/item/I, mob/user)
	var/erase_time = length(global.alive_replicators) > 0 ? SKILL_TASK_DIFFICULT : SKILL_TASK_TRIVIAL
	if(ispulsing(I) && !user.is_busy())
		user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", "<span class='notice'>You start disarm [src].</span>")
		if(do_skilled(user, src, erase_time, list(/datum/skill/research = SKILL_LEVEL_TRAINED), -0.2))
		// to-do: (replicators) add a sound here. the sound should be somewhat melancholic and mechanical. even though this web is made by enemies, it still is a magnificent thing
			visible_message("<span class='notice'>[src] beeps loudly, before dissappearing.</span>")
			qdel(src)
			return

	return ..()

/obj/structure/bluespace_corridor/emp_act(severity)
	. = ..()
	if(prob(20 / severity))
		qdel(src)


var/global/list/obj/machinery/swarm_powered/bluespace_catapult/bluespace_catapults = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/swarm_powered/bluespace_catapult, bluespace_catapults)

/obj/machinery/swarm_powered/bluespace_catapult
	name = "bluespace catapult"
	desc = "The immensity of this structure leaves you in pure awe. This thing, a quiet madness made. Oh no."

	icon = 'icons/mob/replicator.dmi'
	icon_state = "catapult"

	use_power = IDLE_POWER_USE
	idle_power_usage = REPLICATOR_CATAPULT_POWER_USAGE

	resize = 1.5

	density = TRUE
	anchored = TRUE

	max_integrity = 900
	resistance_flags = CAN_BE_HIT

	prioritized = TRUE

	var/max_required_power = 9000000
	var/max_required_materials = 1200

	var/required_power = 0
	var/required_materials = 0

	var/last_perc_announcement = 0

	var/victory = FALSE

	var/perc_finished = 0

	var/next_construction = 0

	var/next_lemming_reminder = 0
	var/lemming_reminder_cooldown = 2 MINUTES

/obj/machinery/swarm_powered/bluespace_catapult/atom_init()
	. = ..()
	var/datum/announcement/centcomm/replicator/construction_began/CB = new
	CB.play(get_area(src))

	required_power = max_required_power
	required_materials = max_required_materials

	update_transform()

	global.poi_list += src

	AddComponent(/datum/component/replicator_regeneration)

/obj/machinery/swarm_powered/bluespace_catapult/Destroy()
	global.poi_list -= src

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.swarm_chat_message("The Swarm", "The Bluespace Catapult has been destroyed! A setback, you must construct another one.", 5)

	FR.destroyed_catapults += 1

	return ..()

/obj/machinery/swarm_powered/bluespace_catapult/process()
	if(next_construction > world.time)
		return

	var/materials_satisfied = 1 - required_materials / max_required_materials
	var/power_satisfied = 1 - required_power / max_required_power

	perc_finished = FLOOR(materials_satisfied * power_satisfied * 100, 1)
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()

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

		density = FALSE

		for(var/mob/M in player_list)
			if(!isnewplayer(M))
				M.playsound_local(null, 'sound/hallucinations/demons_3.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)

		var/area/A = get_area(src)
		FR.swarm_chat_message("The Swarm", "Bluespace Catapult construction finished in [A.name]. Escape through the dimensional rift before it closes!", 5)

		next_lemming_reminder = world.time + lemming_reminder_cooldown

	if(perc_finished >= 100 && next_lemming_reminder < world.time && FR.replicators_launched < REPLICATORS_CATAPULTED_TO_WIN)
		var/area/A = get_area(src)
		FR.swarm_chat_message("The Swarm", "[REPLICATORS_CATAPULTED_TO_WIN - FR.replicators_launched] more replicators are required to launch from the catapult at [A.name]. You must go there, now!", 5)
		next_lemming_reminder = world.time + lemming_reminder_cooldown

	if(announcement)
		last_perc_announcement = perc_finished
		announcement.play(get_area(src))

	draw_energy()

	if(stat & NOPOWER)
		return

	if(required_power >= 0)
		required_power = max(0, required_power - idle_power_usage)

	if(required_materials <= 0)
		return

	if(FR.collect_taxes(5))
		required_materials = max(0, required_materials - 5)

/obj/machinery/swarm_powered/bluespace_catapult/Crossed(atom/movable/AM)
	if(!isreplicator(AM))
		return ..()

	var/mob/living/simple_animal/hostile/replicator/R = AM
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()

	if(length(global.alive_replicators) <= 1 && FR.replicators_launched < REPLICATORS_CATAPULTED_TO_WIN)
		to_chat(AM, "<span class='notice'>One must stay behind. Replicate more, and send others.</span>")
		return

	FR.replicators_launched += 1

	var/datum/replicator_array_info/RAI = FR.ckey2info[R.last_controller_ckey]
	if(RAI)
		RAI.replicators_launched += 1

	playsound(src, 'sound/magic/MAGIC_MISSILE.ogg', VOL_EFFECTS_MASTER, 75)

	R.death()
	qdel(R)

	if(FR.replicators_launched >= REPLICATORS_CATAPULTED_TO_WIN && !victory)
		FR.swarm_chat_message("The Swarm", "Mission accomplished.", 5)
		victory = TRUE
		INVOKE_ASYNC(FR, TYPE_PROC_REF(/datum/faction/replicators, victory_animation), get_turf(src))

/obj/machinery/swarm_powered/bluespace_catapult/examine(mob/user)
	. = ..()
	if(!isreplicator(user) && !isobserver(user))
		return

	if(isreplicator(user))
		to_chat(user, "<span class='warning'>This is your way out, onwards. Protect it at <b>ALL</b> costs.</span>")
	if(isobserver(user) && perc_finished < 100)
		to_chat(user, "<span class='warning'>It is [perc_finished]% finished.</span>")

	if(perc_finished >= 100)
		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		to_chat(user, "<span class='notice'>Launched [FR.replicators_launched]/[REPLICATORS_CATAPULTED_TO_WIN] replicators.</span>")
	else
		if(required_materials > 0)
			to_chat(user, "<span class='notice'>It requires [required_materials] more materials.</span>")
		if(required_power > 0)
			to_chat(user, "<span class='notice'>It required [required_power] more power.</span>")

		if(next_construction > 0)
			to_chat(user, "<span class='warning'>It's construction is disabled for the next [(world.time - next_construction) * 0.1] seconds.</span>")
		else if(stat & NOPOWER)
			to_chat(user, "<span class='warning'>It is not powered. It must be powered to consume.</span>")


/obj/machinery/swarm_powered/bluespace_catapult/emp_act(severity)
	. = ..()
	next_construction = world.time + (10 SECONDS / severity)
