/obj/machinery/labor_counter_machine
	name = "labor counting machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = TRUE
	anchored = TRUE
	speed_process = TRUE
	max_integrity = 300
	damage_deflection = 20
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
			count_product(I)
			I.Move(output_turf)
			i++
			if (i >= 10)
				return

/obj/machinery/labor_counter_machine/proc/count_product(obj/item/product)
	var/amount = 1
	var/datum/labor/rate

	var/datum/labor/L
	for(var/tag in global.labor_rates)
		L = global.labor_rates[tag]
		if(istype(product, L.product))
			rate = L
			break
	if(!rate)
		return

	if(istype(product, /obj/item/stack))
		var/obj/item/stack/S = product
		amount = S.amount

	console.add_product(rate.nametag, amount)

/**********************Labor products counter console**************************/
/obj/machinery/labor_counter_console
	name = "payout console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	damage_deflection = 20
	var/obj/item/weapon/card/id/labor/inserted_id
	var/obj/machinery/labor_counter_machine/machine
	var/credits = 0

/obj/machinery/labor_counter_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/labor_counter_console/atom_init_late()
	machine = locate(/obj/machinery/labor_counter_machine) in range(5, src)
	if (machine)
		machine.console = src
	else
		log_debug("Payout console at [x], [y], [z] could not find its machine!")
		qdel(src)

/obj/machinery/labor_counter_console/proc/add_product(nametag, amount)
	var/datum/labor/L = global.labor_rates[nametag]
	if(!L || amount <= 0)
		return

	credits += L.price * amount
	SStgui.update_uis(src)

/obj/machinery/labor_counter_console/attack_hand(mob/user)
	add_fingerprint(user)
	tgui_interact(user)

/obj/machinery/labor_counter_console/attackby(obj/item/I, mob/user)
	if(!inserted_id && istype(I, /obj/item/weapon/card/id/labor))
		if(!powered())
			return
		if(user.drop_from_inventory(I, src))
			inserted_id = I
			SStgui.update_uis(src)
		return
	..()

/obj/machinery/labor_counter_console/emag_act(mob/user)
	if(!inserted_id)
		to_chat(usr, "<span class='warning'>There is no ID to initiate release protocol!</span>")
		return FALSE

	to_chat(user, "You hack \the [src] to initiate release protocol.")
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	visible_message("<span class='warning'>BZZzZZzZZzZT</span>")
	release_prisoner()
	. = TRUE

/obj/machinery/labor_counter_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LaborPayout", name)
		ui.open()

/obj/machinery/labor_counter_console/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = ..()
	data["unclaimedPayout"] = credits

	if(inserted_id)
		data["has_id"] = TRUE
		data["id"] = list(
			"name" = inserted_id.registered_name,
			"credits" = inserted_id.labor_credits,
			"sentence" = inserted_id.labor_sentence
		)
	else
		data["has_id"] = FALSE

	return data

/obj/machinery/labor_counter_console/tgui_act(action, list/params)
	if(..())
		return TRUE

	. = TRUE
	add_fingerprint(usr)
	switch(action)
		if("logoff")
			if(!inserted_id)
				return
			usr.put_in_hands(inserted_id)
			inserted_id = null
		if("claim")
			if(istype(inserted_id))
				var/cr = input("How many credits you want to claim?", "Payout", credits) as num | null
				if(!cr || cr <= 0 || credits - cr < 0)
					to_chat(usr, "<span class='warning'>Invalid amount of credits.</span>")
					return
				inserted_id.labor_credits += cr
				credits -= cr
		if("insert")
			var/obj/item/weapon/card/id/labor/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_from_inventory(I, src)
				inserted_id = I
			else
				to_chat(usr, "<span class='warning'>No valid ID.</span>")
		if("release")
			if(inserted_id.labor_credits < inserted_id.labor_sentence)
				return
			release_prisoner()
			inserted_id.labor_credits -= inserted_id.labor_sentence
			inserted_id.labor_sentence = 0

/obj/machinery/labor_counter_console/proc/release_prisoner()
	broadcast_security_hud_message("<b>[src.name]</b> Заключенный <b>[inserted_id.registered_name]</b> отработал вынесенный приговор. \
									<b>[inserted_id.responsible_officer]</b> запрашивается к месту проведения принудительных работ для процедуры освобождения.", src)

	if(inserted_id.security_data)
		inserted_id.security_data.fields["criminal"] = "Released"
		for(var/mob/living/carbon/human/H in global.human_list)
			if(H.real_name == inserted_id.registered_name)
				H.sec_hud_set_security_status()
		add_record(null, inserted_id.security_data, "Отбыл наказание за преступления по статьям: [inserted_id.broken_laws]. Уголовный статус статус был изменен на <b>Released</b>", "NT Security System")

	var/obj/item/weapon/paper/P = new(src.loc)
	P.name = "Labor completion certificate"
	P.info = {"
        <center><font size=\"4\"><b>Автоматическая система безопасности НаноТрейзен</b><br>
        Свидетельство о завершении принудительных работ</font></center><br>
        <hr>Полное имя заключённого: [inserted_id.registered_name]<br>
		Сумма отработки в кредитах: [inserted_id.labor_sentence]<br>
		Ответственный сотрудник СБ: [inserted_id.responsible_officer]<br>
		Время завершения принудительных работ: [worldtime2text()]<br>
        <hr>Место для штампов.<br>
	"}
	var/obj/item/weapon/stamp/hos/S = new
	S.stamp_paper(P, "NT Security System")
	P.update_icon()
	P.updateinfolinks()
