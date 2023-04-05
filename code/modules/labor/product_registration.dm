/obj/machinery/labor_counter_machine
	name = "Labor counter machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = TRUE
	anchored = TRUE
	//speed_process = TRUE
	var/obj/machinery/labor_counter_console/console
	var/list/acceptable_products = list(/obj/item/stack, /obj/item/weapon/reagent_containers/food/snacks/grown)

/obj/machinery/labor_counter_machine/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/labor_counter_machine/process()
	var/turf/input_turf = get_step(src, dir)
	var/turf/output_turf = get_step(src, turn(dir, 180))
	var/i = 0

	for (var/obj/item/I in input_turf.contents)
		if(is_type_in_list(I, acceptable_products))
			I.Move(output_turf)
			i++
			if (i >= 10)
				return

/**********************Labor products counter console**************************/
/obj/machinery/labor_counter_console
	name = "Labor counter console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/labor_counter_machine/machine = null

/obj/machinery/labor_counter_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/labor_counter_console/atom_init_late()
	machine = locate(/obj/machinery/labor_counter_machine) in range(5, src)
	if (machine)
		machine.console = src
	else
		qdel(src)

/obj/machinery/labor_counter_console/attack_hand(mob/user)
	add_fingerprint(user)
	tgui_interact(user)
