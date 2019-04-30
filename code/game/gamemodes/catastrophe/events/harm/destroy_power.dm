/datum/catastrophe_event/power_destroy
	name = "Power destory"

	one_time_event = TRUE

	weight = 100

	event_type = "harmful"
	steps = 3

	event_duration_min = 0.3 // ~10 min event
	event_duration_max = 0.3

/datum/catastrophe_event/power_destroy/on_step()
	switch(step)
		if(1)
			announce(CYRILLIC_EVENT_POWER_DESTROY_1)
		if(2)
			announce(CYRILLIC_EVENT_POWER_DESTROY_2)

			for(var/obj/machinery/sleep_console/M in machines)
				do_destroy(M)
			for(var/obj/machinery/autolathe/M in machines)
				do_destroy(M)
			for(var/obj/machinery/clonepod/M in machines)
				do_destroy(M)
			for(var/obj/machinery/autolathe/M in machines)
				do_destroy(M)
			for(var/obj/machinery/vending/M in machines)
				do_destroy(M, 60)
				CHECK_TICK
			for(var/obj/machinery/atmospherics/components/unary/cryo_cell/M in machines)
				do_destroy(M, 60)
			for(var/obj/machinery/dna_scannernew/M in machines)
				do_destroy(M)
			for(var/obj/machinery/mecha_part_fabricator/M in machines)
				do_destroy(M)
			for(var/obj/machinery/teleport/M in teleporter_list)
				do_destroy(M, 80)
			for(var/obj/machinery/power/smes/M in smes_list)
				do_destroy(M, 20)
				CHECK_TICK
			for(var/obj/machinery/chem_master/M in machines)
				do_destroy(M)
			for(var/obj/machinery/computer/M in computer_list)
				if(M.z != ZLEVEL_STATION)
					continue
				if(prob(50))
					M.set_broken()
				CHECK_TICK
		if(3)
			announce(CYRILLIC_EVENT_POWER_DESTROY_3)

			var/list/skipped_areas = list(/area/turret_protected/ai, /area/tcommsat/computer, /area/tcommsat/chamber)

			for(var/obj/machinery/power/smes/S in smes_list)
				var/area/current_area = get_area(S)
				if(current_area.type in skipped_areas || S.z != ZLEVEL_STATION)
					continue
				S.last_charge = S.charge
				S.last_output = S.output
				S.last_online = S.online
				S.charge = 0
				S.output = 0
				S.online = 0
				S.max_input = 0
				S.max_output = 0
				S.update_icon()
				S.power_change()
				CHECK_TICK

			for(var/obj/machinery/power/apc/C in apc_list)
				if(C.cell && C.z == ZLEVEL_STATION)
					C.cell.charge = 0
				CHECK_TICK

			for(var/obj/item/weapon/stock_parts/cell/C in cell_list)
				if(prob(90))
					C.charge = 0
					C.update_icon()
				CHECK_TICK

			for(var/obj/singularity/C in poi_list)
				qdel(C)

/datum/catastrophe_event/power_destroy/proc/do_destroy(obj/machinery/M, chance = 50)
	if(M.z != ZLEVEL_STATION)
		return
	if(locate(/mob, M.contents))
		return

	if(prob(chance))
		var/turf/T = get_turf(M)
		var/list/components = list()
		for(var/obj/item/I in M.component_parts)
			if(prob(60))
				components += I.type

		qdel(M)

		if(prob(80))
			new /obj/machinery/constructable_frame/machine_frame(T)
		for(var/e in components)
			new e(T)

		if(prob(10))
			var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
			smoke.set_up(5, 0, T)
			smoke.start()