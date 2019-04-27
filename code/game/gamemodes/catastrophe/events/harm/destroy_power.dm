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
			announce("Исход, наши сканеры регистрируют аномальную активность на звезде Тау Кита. Интенсивные вспышки создают проблемы с некоторым нашим оборудованием. Будьте осторожны, мы следим за ситуацией")
		if(2)
			announce("Внимание, станци[JA_PLACEHOLDER]. Только что на звезде Тау Кита произошла одна из самых мощных вспышек за последнее врем[JA_PLACEHOLDER]. Часть нашего оборудовани[JA_PLACEHOLDER] полностью вышла из стро[JA_PLACEHOLDER]. Проверьте электрические приборы на наличие поломок и произведите ремонт. Ситуаци[JA_PLACEHOLDER] может ухудшитьс[JA_PLACEHOLDER], будьте готовы")

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
			for(var/obj/machinery/atmospherics/components/unary/cryo_cell/M in machines)
				do_destroy(M, 60)
			for(var/obj/machinery/dna_scannernew/M in machines)
				do_destroy(M)
			for(var/obj/machinery/mecha_part_fabricator/M in machines)
				do_destroy(M)
			for(var/obj/machinery/teleport/M in machines)
				do_destroy(M, 80)
			for(var/obj/machinery/power/smes/M in machines)
				do_destroy(M, 20)
			for(var/obj/machinery/chem_master/M in machines)
				do_destroy(M)
			for(var/obj/machinery/computer/M in computer_list)
				if(M.z != ZLEVEL_STATION)
					continue
				if(prob(50))
					M.set_broken()
		if(3)
			announce("Исход, внимание! Нова[JA_PLACEHOLDER] вспышка повлекла за собой мощный ЭМ импульс. Наши системы энергоснабжени[JA_PLACEHOLDER] частично вышли из стро[JA_PLACEHOLDER]. Так как ваша станци[JA_PLACEHOLDER] находитс[JA_PLACEHOLDER] гораздо ближе к звезде, то последстви[JA_PLACEHOLDER] могли быть гораздо более разрушительными. Попытайтесь восстановить энергию и затем отправьте отчёт о полученных повреждени[JA_PLACEHOLDER]х")

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

			for(var/obj/machinery/power/apc/C in apc_list)
				if(C.cell && C.z == ZLEVEL_STATION)
					C.cell.charge = 0

			for(var/obj/item/weapon/stock_parts/cell/C in world)
				if(prob(90))
					C.charge = 0
					C.update_icon()

			for(var/obj/singularity/C in world)
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