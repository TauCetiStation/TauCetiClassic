/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	cases = list("консоль капсулы диализа", "консоли капсулы диализа", "консоли капсулы диализа", "консоль капсулы диализа", "консолью капсулы диализа", "консоли капсулы диализа")
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "sleeperconsole"
	anchored = TRUE //About time someone fixed this.
	density = FALSE
	light_color = "#7bf9ff"

/obj/machinery/sleeper
	name = "Sleeper"
	cases = list("капсула диализа", "капсулы диализа", "капсуле диализа", "капсулу диализа", "капсулой диализа", "капсуле диализа")
	desc = "Используется для быстрого вывода или ввода различных веществ путём диализа."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "sleeper-open"
	layer = BELOW_CONTAINERS_LAYER
	density = FALSE
	anchored = TRUE
	state_open = 1
	light_color = "#7bf9ff"
	allowed_checks = ALLOWED_CHECK_TOPIC
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/filtering = 0
	var/efficiency = 1
	var/min_health = -25
	var/list/available_chems
	var/list/possible_chems = list(
		list("tricordrazine", "paracetamol", "stoxin", "dexalin", "bicaridine", "kelotane"),
		list("imidazoline"),
		list("anti_toxin", "ryetalyn" ,"dermaline", "arithrazine"),
		list("dexalinp", "alkysine")
	)
	var/upgraded = FALSE
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_TRAINED)

/obj/machinery/sleeper/upgraded
	upgraded = TRUE

/obj/machinery/sleeper/atom_init(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleeper(null)
	if(upgraded)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace(null)
		component_parts += new /obj/item/weapon/stock_parts/manipulator/nano/pico/femto(null)
	else
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
		component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()
	if(mapload)
		beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)

/obj/machinery/sleeper/RefreshParts()
	..()

	var/E
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	var/I
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		I += M.rating

	efficiency = initial(efficiency)* E
	min_health = initial(min_health) * E
	available_chems = list()
	for(var/i in 1 to min(I, possible_chems.len))
		available_chems |= possible_chems[i]

/obj/machinery/sleeper/allow_drop()
	return 0

/obj/machinery/sleeper/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated() || !iscarbon(target) || target.buckled)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, как работает это устройство.</span>")
		return
	close_machine(target)

/obj/machinery/sleeper/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, как работает это устройство.</span>")
		return
	if(occupant && is_operational())
		open_machine()
		return
	var/mob/living/carbon/target = locate() in loc
	if(!target)
		return
	close_machine(target)

/obj/machinery/sleeper/process()
	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		if(filtering > 0)
			if(beaker)
				if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
					H.blood_trans_to(beaker, 1)
					for(var/datum/reagent/x in src.occupant.reagents.reagent_list)
						H.reagents.trans_to(beaker, 3)
						H.blood_trans_to(beaker, 1)
	return

/obj/machinery/sleeper/deconstruct(disassembled)
	for(var/atom/movable/A as anything in src)
		A.forceMove(loc)
	..()

/obj/machinery/sleeper/attack_animal(mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	..()
	if(M.environment_smash)
		visible_message("<span class='danger'>[M.name] ломает [CASE(src, NOMINATIVE_CASE)] на части!</span>")
		qdel(src)
	return

/obj/machinery/sleeper/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(!beaker)
			beaker = I
			user.drop_from_inventory(I, src)
			user.visible_message("[user] вставил [I] в [CASE(src, ACCUSATIVE_CASE)]!", "Вы вставили [I] в [CASE(src, ACCUSATIVE_CASE)]!")
			updateUsrDialog()
			return
		else
			to_chat(user, "<span class='warning'>Внутри капсулы уже находится сосуд.</span>")
			return

	if(!state_open && !occupant)
		if(default_deconstruction_screwdriver(user, "sleeper-o", "sleeper", I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(exchange_parts(user, I))
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return

/obj/machinery/sleeper/ex_act(severity)
	if(filtering)
		toggle_filter()
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
	for(var/atom/movable/A as anything in src)
		A.loc = src.loc
		ex_act(severity)
	qdel(src)

/obj/machinery/sleeper/emp_act(severity)
	if(filtering)
		toggle_filter()
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

/obj/machinery/sleeper/proc/toggle_filter()
	if(filtering)
		filtering = 0
	else
		filtering = 1

/obj/machinery/sleeper/proc/go_out()
	if(filtering)
		toggle_filter()
	if(!occupant)
		return
	for(var/atom/movable/O in src)
		if(O == beaker)
			continue
		O.loc = loc
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant = null
	icon_state = "sleeper-open"

/obj/machinery/sleeper/container_resist()
	open_machine()

/obj/machinery/sleeper/relaymove(mob/user)
	..()
	open_machine()

/obj/machinery/sleeper/Destroy()
	var/turf/T = loc
	T.contents += contents
	return ..()

/obj/machinery/sleeper/verb/remove_beaker()
	set name = "Remove Beaker"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return
	if(beaker)
		filtering = 0
		beaker.loc = usr.loc
		beaker = null
	add_fingerprint(usr)
	return

/obj/machinery/sleeper/ui_interact(mob/user)
	var/dat = "<div class='Section__title'>Статус капсулы диализа</div>"

	dat += "<div class='Section'>"
	if(!occupant)
		dat += "Капсула не занята"
	else
		dat += "[occupant.name] => "
		switch(occupant.stat)	//obvious, see what their status is
			if(0)
				dat += "<span class='good'>В сознании</span>"
			if(1)
				dat += "<span class='average'>Не в сознании</span>"
			else
				dat += "<span class='bad'>МЁРТВ</span>"

		dat += "<br />"

		dat +=  "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [occupant.health]%;' class='progressFill bggood'></div></div><div class='statusValue'>[occupant.health]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Механические повреждения:</div><div class='progressBar'><div style='width: [occupant.getBruteLoss()]%;' class='progressFill bgbad'></div></div><div class='statusValue'>[occupant.getBruteLoss()]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Статус асфиксии:</div><div class='progressBar'><div style='width: [occupant.getOxyLoss()]%;' class='progressFill bgbad'></div></div><div class='statusValue'>[occupant.getOxyLoss()]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Статус интоксикации:</div><div class='progressBar'><div style='width: [occupant.getToxLoss()]%;' class='progressFill bgbad'></div></div><div class='statusValue'>[occupant.getToxLoss()]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Термические повреждения:</div><div class='progressBar'><div style='width: [occupant.getFireLoss()]%;' class='progressFill bgbad'></div></div><div class='statusValue'>[occupant.getFireLoss()]%</div></div>"

		var/occupant_paralysis = occupant.AmountParalyzed()
		dat += "<HR><div class='line'><div class='statusLabel'>Paralysis Summary:</div><div class='statusValue'>[round(occupant_paralysis)]% [occupant_paralysis ? "([round(occupant_paralysis / 4)] seconds left)" : ""]</div></div>"
		if(occupant.reagents.reagent_list.len)
			for(var/datum/reagent/R in occupant.reagents.reagent_list)
				dat += text("<div class='line'><div class='statusLabel'>[R.name]:</div><div class='statusValue'>[] units</div></div>", round(R.volume, 0.1))

	dat += "</div>"

	dat += "<A href='?src=\ref[src];refresh=1'>Начать сканирование</A>"

	dat += "<A href='?src=\ref[src];[state_open ? "close=1'>Закрыть</A>" : "open=1'>Открыть</A>"]"

	dat += "<h3>Сосуд</h3>"

	if(src.beaker)
		dat += "<A href='?src=\ref[src];removebeaker=1'>Убрать сосуд</A>"
		if(filtering)
			dat += "<A href='?src=\ref[src];togglefilter=1'>Остановить диализ</A>"
			dat += text("<BR>В выходном сосуде осталось [] юнитов свободного места<BR><HR>", src.beaker.reagents.maximum_volume - src.beaker.reagents.total_volume)
		else
			dat += "<A href='?src=\ref[src];togglefilter=1'>Начать диализ</A>"
			dat += text("<BR>В выходном сосуде осталось [] юнитов свободного места", src.beaker.reagents.maximum_volume - src.beaker.reagents.total_volume)
	else
		dat += "<BR>Сосуд для проведения диализа не вставлен"

	dat += "<h3>Введение препаратов</h3>"

	if(src.occupant)
		dat += "<A href='?src=\ref[src];inject=inaprovaline'>Ввести Инапровалин</A>"
	else
		dat += "<span class='disabled'>Ввести Инапровалин</span>"
	if(occupant && occupant.health > min_health)
		for(var/re in available_chems)
			var/datum/reagent/C = chemical_reagents_list[re]
			if(C)
				dat += "<BR><A href='?src=\ref[src];inject=[C.id]'>Ввести [C.name]</A>"
	else
		for(var/re in available_chems)
			var/datum/reagent/C = chemical_reagents_list[re]
			if(C)
				dat += "<BR><span class='disabled'>Ввести [C.name]</span>"

	var/datum/browser/popup = new(user, "капсула диализа", "консоль капсулы диализа", 520, 605)	//Set up the popup browser window
	popup.set_content(dat)
	popup.open()

/obj/machinery/sleeper/Topic(href, href_list)
	. = ..()
	if(!. || usr == occupant)
		return FALSE

	if(href_list["refresh"])
		updateUsrDialog()
	else if(href_list["open"])
		open_machine()
	else if(href_list["close"])
		close_machine()
	else if(href_list["removebeaker"])
		remove_beaker()
	else if(href_list["togglefilter"])
		toggle_filter()
	else if(occupant && occupant.stat != DEAD)
		if(href_list["inject"] == "inaprovaline" || (occupant.health > min_health && (href_list["inject"] in available_chems)))
			inject_chem(usr, href_list["inject"])
		else
			to_chat(usr, "<span class='notice'>ОШИБКА: ПАЦИЕНТ НЕ НАХОДИТСЯ В СТАБИЛЬНОМ СОСТОЯНИИ ДЛЯ ВВЕДЕНИЯ ПРЕПАРАТОВ.</span>")
	else
		to_chat(usr, "<span class='notice'>ОШИБКА: У ПАЦИЕНТА ОБНАРУЖЕНО СЕРЬЕЗНОЕ НАРУШЕНИЕ МЕТАБОЛИЗМА.</span>")
	updateUsrDialog()

/obj/machinery/sleeper/open_machine()
	if(!state_open && !panel_open)
		..()
		if(beaker)
			beaker.loc = src

/obj/machinery/sleeper/close_machine(mob/target)
	if(state_open && !panel_open)
		to_chat(target, "<span class='notice'><b>Вы чувствуете охлаждение воздуха в капсуле, а затем медленную остановку жизненных процессов.</b></span>")
		..(target)

/obj/machinery/sleeper/proc/inject_chem(mob/user, chem)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount(chem) + 10 <= 20 * efficiency)
			occupant.reagents.add_reagent(chem, 10)
		var/units = round(occupant.reagents.get_reagent_amount(chem))
		to_chat(user, "<span class='notice'>Пациенту было введено [units] юнит(ов) [chem] в организм.</span>")

/obj/machinery/sleeper/update_icon()
	if(state_open)
		icon_state = "sleeper-open"
	else
		icon_state = "sleeper"
