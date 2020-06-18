/obj/machinery/mining
	icon = 'icons/obj/mining_drill.dmi'
	anchored = 0
	use_power = NO_POWER_USE         //The drill takes power directly from a cell.
	density = 1
	layer = MOB_LAYER+0.1 //So it draws over mobs in the tile north of it.

/obj/machinery/mining/drill
	name = "mining drill head"
	desc = "An enormous drill."
	icon_state = "mining_drill"

	var/braces_needed = 2
	var/list/supports = list()
	var/supported = 0
	var/active = 0
	var/list/resource_field = list()

	var/ore_types = list(
		"iron" = /obj/item/weapon/ore/iron,
		"uranium" = /obj/item/weapon/ore/uranium,
		"gold" = /obj/item/weapon/ore/gold,
		"silver" = /obj/item/weapon/ore/silver,
		"diamond" = /obj/item/weapon/ore/diamond,
		"phoron" = /obj/item/weapon/ore/phoron,
		"osmium" = /obj/item/weapon/ore/osmium,
		"hydrogen" = /obj/item/weapon/ore/hydrogen,
		"silicates" = /obj/item/weapon/ore/glass,
		"carbonaceous rock" = /obj/item/weapon/ore/coal
		)

	//Upgrades
	var/damage_to_user
	var/harvest_speed
	var/capacity
	var/charge_use
	var/radius
	var/obj/item/weapon/stock_parts/cell/cell = null

	//Flags
	var/need_update_field = 0
	var/need_player_check = 0

	//hacks
	var/datum/wires/mining_drill/wires = null

	var/wires_shocked = 0
	var/wires_overload = 0
	var/wires_radio_disable = 0
	var/wires_power_disable = 0
	var/wires_protector_disable = 0




/obj/machinery/mining/drill/atom_init()

	. = ..()

	wires = new(src)

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/miningdrill(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)

	RefreshParts()

/obj/machinery/mining/drill/Destroy()
	QDEL_NULL(wires)

	for(var/obj/machinery/mining/brace/b in supports)
		b.disconnect()

	return ..()

/obj/machinery/mining/drill/process()

	if(!can_work())
		return

	if(!use_cell_power())
		system_error("system charge error")
		return

	if(need_update_field)
		get_resource_field()

		//Drill through the flooring, if any.
		if(istype(get_turf(src), /turf/simulated/floor/plating/airless/asteroid))
			var/turf/simulated/floor/plating/airless/asteroid/T = get_turf(src)
			if(!T.dug)
				T.gets_dug()
		else if(istype(get_turf(src), /turf/simulated/floor))
			var/turf/simulated/floor/T = get_turf(src)
			T.ex_act(2.0)

	dig_ore()


/obj/machinery/mining/drill/proc/can_work()
	if(!active)
		return 0
	if(need_player_check)
		return 0
	if(!check_supports())
		system_error("system configuration error")
		return 0
	return 1

/obj/machinery/mining/drill/proc/use_cell_power()
	if(wires_power_disable)
		return 0
	if(!cell)
		return 0
	if(cell.use(charge_use))
		return 1
	return 0

/obj/machinery/mining/drill/proc/check_supports()
	if(!supports || supports.len < braces_needed)
		return 0

	if(supports && supports.len >= braces_needed)
		return 1


/obj/machinery/mining/drill/proc/system_error(error)

	if(error)
		src.visible_message("<span class='notice'>\The [src] flashes a '[error]' warning.</span>")
	need_player_check = 1
	active = 0
	update_icon()


/obj/machinery/mining/drill/proc/get_resource_field()

	resource_field = list()
	need_update_field = 0

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	for(var/turf/mine_truf in range(T, radius))
		if(mine_truf.has_resources)
			resource_field += mine_truf

	if(!resource_field.len)
		system_error("resources depleted")


/obj/machinery/mining/drill/proc/dig_ore()
	//Dig out the tasty ores.
	if(!resource_field.len)
		system_error("resources depleted")
		return

	var/turf/simulated/harvesting = pick(resource_field)

	//remove emty trufs
	while(resource_field.len && !harvesting.resources)
		harvesting.has_resources = 0
		harvesting.resources = null
		resource_field -= harvesting
		harvesting = pick(resource_field)

	if(!harvesting)
		system_error("resources depleted")
		return

	var/total_harvest = harvest_speed //Ore harvest-per-tick.
	var/found_resource = 0 //If this doesn't get set, the area is depleted and the drill errors out.

	for(var/metal in ore_types)

		if(contents.len >= capacity)
			system_error("insufficient storage space")
			return

		if(contents.len + total_harvest >= capacity)
			total_harvest = capacity - contents.len

		if(total_harvest <= 0)
			break

		if(harvesting.resources[metal])

			found_resource  = 1

			var/create_ore = 0
			if(harvesting.resources[metal] >= total_harvest)
				harvesting.resources[metal] -= total_harvest
				create_ore = total_harvest
				total_harvest = 0
			else
				total_harvest -= harvesting.resources[metal]
				create_ore = harvesting.resources[metal]
				harvesting.resources[metal] = 0

			for(var/i=1, i <= create_ore, i++)
				var/oretype = ore_types[metal]
				new oretype(src)

	if(!found_resource)
		harvesting.has_resources = 0
		harvesting.resources = null
		resource_field -= harvesting

/obj/machinery/mining/drill/proc/connect_brace(obj/machinery/mining/brace/brace)
	if(!supports)
		supports = list()

	supports += brace
	anchored = 1

	if(supports && supports.len >= braces_needed)
		supported = 1

	update_icon()

/obj/machinery/mining/drill/proc/disconnect_brace(obj/machinery/mining/brace/brace)
	if(active && wires_protector_disable)
		active = 0
		critical_brace_lost()
	if(!supports)
		supports = list()

	supports -= brace

	if((!supports || !supports.len))
		anchored = 0
	else
		anchored = 1

	if(supports && supports.len >= braces_needed)
		supported = 1
	else
		supported = 0

	update_icon()

/obj/machinery/mining/drill/proc/critical_brace_lost()
	if(wires_overload)
		system_error("WARNING: The brace have lost. The drill may be destroy")
		explosion(src.loc, 1, 2, 4)

	else
		system_error("WARNING: The brace have lost. Start emergency stop")

/obj/machinery/mining/drill/RefreshParts()
	..()
	damage_to_user = 30
	harvest_speed = 0
	capacity = 0
	charge_use = 50
	radius = 0

	for(var/obj/item/weapon/stock_parts/P in component_parts)
		if(istype(P, /obj/item/weapon/stock_parts/micro_laser))
			harvest_speed = P.rating
		if(istype(P, /obj/item/weapon/stock_parts/matter_bin))
			capacity = 200 * P.rating
		if(istype(P, /obj/item/weapon/stock_parts/capacitor))
			charge_use -= 10 * P.rating
		if(istype(P, /obj/item/weapon/stock_parts/scanning_module))
			radius = 1 + P.rating
	cell = locate(/obj/item/weapon/stock_parts/cell) in component_parts

	if(wires_overload && wires_protector_disable)
		harvest_speed = min(harvest_speed + 2, 4)
		radius = min (radius + 1, 4)
		charge_use = charge_use * 2

	damage_to_user = damage_to_user * harvest_speed


/obj/machinery/mining/drill/attackby(obj/item/O, mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(wires_shocked)
		shock(user)
	if(active && wires_protector_disable)
		cut_hand(user)
	if(!active)
		if(default_deconstruction_screwdriver(user, "mining_drill", "mining_drill", O))
			return
		if(default_deconstruction_crowbar(O, 1))
			return
		if(exchange_parts(user, O))
			return


	if(!panel_open || active)
		return ..()

	if(istype(O, /obj/item/weapon/stock_parts/cell))
		if(cell)
			to_chat(user, "The drill already has a cell installed.")
		else
			user.drop_item()
			O.loc = src
			cell = O
			component_parts += O
			to_chat(user, "You install \the [O].")
		return

	if(is_wire_tool(O) && wires.interact(user))
		return
	..()

/obj/machinery/mining/drill/is_interactable()
	return TRUE

/obj/machinery/mining/drill/attack_hand(mob/user)
	if(..())
		return
	if(issilicon(user))
		to_chat(user, "This drill didn`t support your iterface")
		return
	if(wires_shocked && !isobserver(user))
		shock(user)
	if (panel_open && cell)
		to_chat(user, "You take out \the [cell].")
		cell.updateicon()
		cell.loc = get_turf(user)
		component_parts -= cell
		cell = null
		return
	else if(need_player_check)
		to_chat(user, "You hit the manual override and reset the drill's error checking.")
		need_player_check = 0
		if(anchored)
			need_update_field = 1
		update_icon()
		return
	else if(supported && !panel_open)
		if(use_cell_power())
			active = !active
			if(active)
				visible_message("<span class='notice'>\The [src] lurches downwards, grinding noisily.</span>")
				need_update_field = 1
			else
				visible_message("<span class='notice'>\The [src] shudders to a grinding halt.</span>")
		else
			to_chat(user, "<span class='notice'>The drill is unpowered.</span>")
	else
		to_chat(user, "<span class='notice'>Turning on a piece of industrial machinery without sufficient bracing or wires exposed is a bad idea.</span>")

	update_icon()

/obj/machinery/mining/drill/proc/shock(mob/user)
	if(!cell || wires_power_disable )
		return 0
	if(!istype(user, /mob/living/carbon))
		return 0

	var/mob/living/carbon/C = user

	if(!cell.use(cell.maxcharge / 10))
		return 0

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()

	if(C.electrocute_act(cell.maxcharge / 400))
		return 1
	else
		return 0

/obj/machinery/mining/drill/proc/cut_hand(mob/user)
	if(!ishuman(user)) // no hand no cut
		to_chat(user, "<span class='danger'>You feel, that [src] want to cut your arm</span>")
		return 0

	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]

	if(!BP || !BP.is_usable())
		return

	H.apply_damage(damage_to_user, BRUTE, BP, H.run_armor_check(BP, "melee")/2, 1)
	to_chat(H, "<span class='danger'>You feel, that [src] try to cut your [BP]!</span>")

	if(BP.is_stump)
		return

	BP = BP.parent

	H.apply_damage(damage_to_user, BRUTE, BP, H.run_armor_check(BP, "melee")/2, 1)
	to_chat(H, "<span class='danger'>You feel, that [src] try to cut your [BP]!</span>")

/obj/machinery/mining/drill/update_icon()
	if(need_player_check)
		icon_state = "mining_drill_error"
	else if(active)
		icon_state = "mining_drill_active"
	else if(supported)
		icon_state = "mining_drill_braced"
	else
		icon_state = "mining_drill"
	return

/obj/machinery/mining/drill/verb/unload()
	set name = "Unload Drill"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return

	var/obj/structure/ore_box/B = locate() in orange(1)
	if(B)
		for(var/obj/item/weapon/ore/O in contents)
			O.loc = B
		to_chat(usr, "<span class='notice'>You unload the drill's storage cache into the ore box.</span>")
	else
		to_chat(usr, "<span class='notice'>You must move an ore box up to the drill before you can unload it.</span>")



