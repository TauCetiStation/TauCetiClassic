/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "sleeperconsole"
	anchored = TRUE //About time someone fixed this.
	density = FALSE
	light_color = "#7bf9ff"

/obj/machinery/sleeper
	name = "Sleeper"
	cases = list("медкапсула", "медкапсулы", "медкапсуле", "медкапсулу", "медкапсулой", "медкапсуле")
	desc = "Медицинская капсула для обеспечения пациента реагентами и фильтрации крови."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "sleeper-open"
	layer = BELOW_CONTAINERS_LAYER
	density = FALSE
	anchored = TRUE
	state_open = 1
	light_color = "#7bf9ff"
	allowed_checks = ALLOWED_CHECK_TOPIC
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_TRAINED)


	var/obj/item/weapon/reagent_containers/glass/beaker/dialysis = null
	var/dialyzing = FALSE
	var/list/dialysis_report
	var/dialysis_cost = 1


	var/obj/item/weapon/reagent_containers/glass/beaker/cryo = null
	var/freezing = FALSE
	COOLDOWN_DECLARE(clonexadon_consumption)
	var/freeze_cost = 5
	var/freezing_start_time = 0


	var/list/regular_beakers = list()
	var/regular_injection_cost = 1

	var/list/premium_beakers = list()
	var/premium_injection_cost = 3

	var/medical_access = FALSE

	var/upgraded = FALSE

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
		populate_beakers()

/obj/machinery/sleeper/proc/populate_beakers()
	dialysis = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	if(prob(25))//random blood from previous shift
		dialysis.reagents.add_reagent("blood", rand(1, 150))
		dialysis.update_icon()

	cryo = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	if(prob(25))//random cryoxadone from previous shift
		cryo.reagents.add_reagent("cryoxadone", rand(1, 50))
		cryo.update_icon()

	var/obj/item/weapon/reagent_containers/glass/beaker/large/Beaker = new(src)
	Beaker.reagents.add_reagent("dexalinp", 150)
	Beaker.update_icon()
	premium_beakers[Beaker] = 0

	Beaker = new(src)
	Beaker.reagents.add_reagent("tricordrazine", 150)
	Beaker.update_icon()
	premium_beakers[Beaker] = 0

	Beaker = new(src)
	Beaker.reagents.add_reagent("hyronalin", 150)
	Beaker.update_icon()
	premium_beakers[Beaker] = 0

	Beaker = new(src)
	Beaker.reagents.add_reagent("specialwhiskey", 150)
	Beaker.update_icon()
	premium_beakers[Beaker] = 0

/obj/machinery/sleeper/RefreshParts()
	..()

	var/E
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	var/I
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		I += M.rating

/obj/machinery/sleeper/allow_drop()
	return 0

/obj/machinery/sleeper/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated() || !iscarbon(target) || target.buckled)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, что с этим делать.</span>")
		return
	close_machine(target)

/obj/machinery/sleeper/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, что с этим делать.</span>")
		return
	if(occupant && is_operational())
		open_machine()
		return
	var/mob/living/carbon/target = locate() in loc
	if(!target)
		return
	close_machine(target)

/obj/machinery/sleeper/deconstruct(disassembled)
	for(var/atom/movable/A as anything in contents)
		A.forceMove(get_turf(src))
	..()

/obj/machinery/sleeper/attack_animal(mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	..()
	if(M.environment_smash)
		visible_message("<span class='danger'>[M.name] рвёт [CASE(src, ACCUSATIVE_CASE)] на части!</span>")
		qdel(src)
	return

/obj/machinery/sleeper/attackby(obj/item/I, mob/user)
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
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
	for(var/atom/movable/A as anything in contents)
		A.forceMove(get_turf(src))
		A.ex_act(severity)
	qdel(src)

/obj/machinery/sleeper/emp_act(severity)
	if(dialyzing)
		stop_dialyzing()
	else
		dialyzing = TRUE

	if(freezing)
		stop_freezing()
	else
		freezing = TRUE

	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

/obj/machinery/sleeper/proc/go_out()
	if(!occupant)
		return

	if(freezing)
		stop_freezing()

	if(dialyzing)
		stop_dialyzing()

	stop_injections()


	icon_state = "sleeper-open"

/obj/machinery/sleeper/dropContents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		if(AM in regular_beakers)
			continue
		if(AM in premium_beakers)
			continue
		if(AM == cryo)
			continue
		if(AM == dialysis)
			continue

		AM.forceMove(T)
		if(!isliving(AM))
			continue

		var/mob/living/L = AM
		if(!L.client)
			continue

		L.client.eye = L
		L.client.perspective = MOB_PERSPECTIVE

	occupant = null

/obj/machinery/sleeper/container_resist()
	open_machine()

/obj/machinery/sleeper/relaymove(mob/user)
	..()
	open_machine()

/obj/machinery/sleeper/Destroy()
	for(var/atom/movable/A as anything in contents)
		A.forceMove(get_turf(src))
	return ..()

/obj/machinery/sleeper/open_machine()
	if(!state_open && !panel_open)
		..()
		playsound(src, 'sound/machines/sleeper_open.ogg', VOL_EFFECTS_MASTER, vary = FALSE)

/obj/machinery/sleeper/close_machine(mob/target)
	if(state_open && !panel_open)
		to_chat(target, "<span class='notice'><b>Вы чувствуете лёгкий холод и погружаетесь в себя.</b></span>")
		playsound(src, 'sound/machines/sleeper_close.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
		..(target)

/obj/machinery/sleeper/update_icon()
	if(state_open)
		icon_state = "sleeper-open"
	else
		icon_state = "sleeper"

/obj/machinery/sleeper/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/sleeper/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Sleeper", C_CASE(src, NOMINATIVE_CASE), 900, 600)
		ui.open()

/obj/machinery/sleeper/tgui_data(mob/user)
	var/list/data = list()

	data["medical_access"] = medical_access

	data["dialyzing"] = dialyzing

	var/list/report = list()
	if(dialyzing)
		for(var/R in dialysis_report)
			report += "[R] ([round(text2num(dialysis_report[R]))] ю.)"

	data["dialysis_report"] = report.len ? report : null

	data["freezing"] = freezing

	if(freezing)
		data["freezing_time"] = freezing_start_time ? time2text(world.time - freezing_start_time, "mm:ss") : "00:00"

	data["dialysis_beaker"] = dialysis ? list("name" = dialysis.reagents.get_master_reagent_name(), "amount" = round(dialysis.reagents.total_volume / dialysis.volume * 100)) : null

	data["cryo_beaker"] = cryo ? list("name" = cryo.reagents.get_master_reagent_name(), "amount" = round(cryo.reagents.total_volume / cryo.volume * 100)) : null

	var/list/regular = list()
	for(var/i in 1 to 5)
		if(i <= regular_beakers.len)
			var/obj/item/weapon/reagent_containers/glass/beaker/B = regular_beakers[i]
			regular += list(list("id" = i, "name" = B.reagents.get_master_reagent_name(), "amount" = round(B.reagents.total_volume / B.volume * 100), "injecting_amount" = regular_beakers[B]))
			continue

		regular += null

	data["regular_beakers"] = regular

	var/list/premium = list()
	for(var/i in 1 to 5)
		if(i <= premium_beakers.len)
			var/obj/item/weapon/reagent_containers/glass/beaker/B = premium_beakers[i]
			premium += list(list("id" = i, "name" = B.reagents.get_master_reagent_name(), "amount" = round(B.reagents.total_volume / B.volume * 100), "injecting_amount" = premium_beakers[B]))
			continue

		premium += null

	data["premium_beakers"] = premium

	return data

/obj/machinery/sleeper/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("open")
			open_machine()
			return TRUE

		if("dialyze")
			dialyzing = !dialyzing
			return TRUE

		if("freeze")
			freezing = !freezing
			return TRUE

		if("access")
			if(medical_access)
				medical_access = FALSE
				return TRUE

			try_access_beakers(usr)
			return TRUE

		if("eject_dialyzing_beaker")
			if(!medical_access)
				return

			if(!dialysis)
				return

			stop_dialyzing()
			eject_beaker(dialysis, usr)
			dialysis = null
			return TRUE

		if("put_dialyzing_beaker")
			if(!medical_access)
				return

			if(dialysis)
				return

			dialysis = try_put_beaker(usr)
			return TRUE

		if("eject_cryo_beaker")
			if(!medical_access)
				return

			if(!cryo)
				return

			stop_freezing()
			eject_beaker(cryo, usr)
			cryo = null
			return TRUE

		if("put_cryo_beaker")
			if(!medical_access)
				return

			if(cryo)
				return

			cryo = try_put_beaker(usr)
			return TRUE

		if("eject_beaker")
			if(!medical_access)
				return

			var/beaker_type = params["beaker_type"]
			if(!beaker_type)
				return

			var/beaker_id = text2num(params["beaker_id"])
			if(!beaker_id)
				return

			switch(beaker_type)
				if("regular")
					var/beaker = regular_beakers[beaker_id]
					if(!beaker)
						return

					eject_beaker(beaker, usr)
					regular_beakers -= beaker
					return TRUE

				if("premium")
					var/beaker = premium_beakers[beaker_id]
					if(!beaker)
						return

					eject_beaker(beaker, usr)
					premium_beakers -= beaker
					return TRUE

		if("put_beaker")
			if(!medical_access)
				return

			var/beaker_type = params["beaker_type"]
			if(!beaker_type)
				return

			switch(beaker_type)
				if("regular")
					if(regular_beakers.len >= 5)
						return

					var/beaker = try_put_beaker(usr)
					if(!beaker)
						return

					regular_beakers[beaker] = 0
					return TRUE

				if("premium")
					if(premium_beakers.len >= 5)
						return

					var/beaker = try_put_beaker(usr)
					if(!beaker)
						return

					premium_beakers[beaker] = 0
					return TRUE

		if("change_injection_amount")
			var/beaker_type = params["beaker_type"]
			if(!beaker_type)
				return

			var/beaker_id = text2num(params["beaker_id"])
			if(!beaker_id)
				return

			var/injection_amount = text2num(params["new_injection_amount"])

			injection_amount = clamp(injection_amount, 0, 5)

			switch(beaker_type)
				if("regular")
					var/beaker = regular_beakers[beaker_id]
					if(!beaker)
						return

					regular_beakers[beaker] = injection_amount
					return TRUE

				if("premium")
					var/beaker = premium_beakers[beaker_id]
					if(!beaker)
						return

					premium_beakers[beaker] = injection_amount
					return TRUE

	return TRUE

/obj/machinery/sleeper/proc/try_access_beakers(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/obj/item/I = H.get_active_hand()
	if(!I)
		return

	if(!istype(I, /obj/item/weapon/card/id))
		return

	var/obj/item/weapon/card/id/card = I
	if(access_medical in card.access)
		medical_access = TRUE

/obj/machinery/sleeper/proc/eject_beaker(obj/item/weapon/beaker, mob/user)
	if(!ishuman(user))
		beaker.forceMove(get_turf(src))
		return

	var/mob/living/carbon/human/H = user
	beaker.forceMove(get_turf(H))
	H.put_in_hands(beaker)


/obj/machinery/sleeper/proc/try_put_beaker(mob/user)
	if(!ishuman(usr))
		return null

	var/mob/living/carbon/human/H = user

	var/obj/item/I = H.get_active_hand()
	if(!I)
		return null

	if(!istype(I, /obj/item/weapon/reagent_containers/glass/beaker))
		return null

	if(!H.drop_from_inventory(I, src))
		return null

	return I


/obj/machinery/sleeper/process()
	if(!occupant)
		stop_freezing()
		stop_dialyzing()
		return

	if(!ishuman(occupant))
		stop_freezing()
		stop_dialyzing()
		return

	if(freezing)
		freeze_occupant()
		return

	if(dialyzing)
		filter_blood()

	inject_from_beakers()
	return



/obj/machinery/sleeper/proc/freeze_occupant()
	if(!cryo)
		stop_freezing()
		return

	if(!COOLDOWN_FINISHED(src, clonexadon_consumption))
		return

	var/mob/living/carbon/human/H = occupant
	if(get_insurance_type(H) != INSURANCE_PREMIUM)
		stop_freezing()
		return

	if(!try_take_money(freeze_cost))
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)
		stop_freezing()
		return

	COOLDOWN_START(src, clonexadon_consumption, 5 SECONDS)
	if(!freezing_start_time)
		freezing_start_time = world.time

	if(!cryo.reagents.remove_reagent("cryoxadone", 1))
		stop_freezing()
		return

	if(!H.has_status_effect(STATUS_EFFECT_STASIS_BAG))
		H.apply_status_effect(STATUS_EFFECT_STASIS_BAG, null, TRUE)

/obj/machinery/sleeper/proc/stop_freezing()
	freezing = FALSE
	COOLDOWN_RESET(src, clonexadon_consumption)

	freezing_start_time = 0

	var/mob/living/carbon/human/H = occupant
	if(!H)
		return

	if(H.has_status_effect(STATUS_EFFECT_STASIS_BAG))
		H.remove_status_effect(STATUS_EFFECT_STASIS_BAG)



/obj/machinery/sleeper/proc/filter_blood()
	if(!dialysis)
		stop_dialyzing()
		return

	var/mob/living/carbon/human/H = occupant
	if(get_insurance_type(H) == INSURANCE_NONE)
		stop_dialyzing()
		return

	if(!try_take_money(dialysis_cost))
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)
		stop_dialyzing()
		return

	if(!dialysis.reagents.get_free_space())
		stop_dialyzing()
		return

	dialysis.reagents.del_reagent("blood")
	H.take_blood(dialysis, 1)
	dialysis_report = params2list(dialysis.reagents.get_data("blood")["trace_chem"])

	if(!dialysis_report || !dialysis_report.len)
		stop_dialyzing()
		return

	playsound(src, 'sound/machines/dialysis.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
	for(var/datum/reagent/x in H.reagents.reagent_list)
		H.reagents.trans_to(dialysis, 3)

/obj/machinery/sleeper/proc/stop_dialyzing()
	dialyzing = FALSE



/obj/machinery/sleeper/proc/inject_from_beakers()
	var/mob/living/carbon/human/H = occupant
	if(get_insurance_type(H) == INSURANCE_NONE)
		return

	for(var/obj/item/weapon/reagent_containers/glass/beaker/B in regular_beakers)
		var/inject_amount = regular_beakers[B]
		if(!inject_amount)
			continue

		if(!try_take_money(inject_amount * regular_injection_cost))
			playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)
			stop_injections()
			return

		if(!B.reagents.trans_to(H, inject_amount))
			regular_beakers[B] = 0
			continue

		playsound(src, 'sound/machines/sleeper_inject.ogg', VOL_EFFECTS_MASTER, vary = FALSE)

	if(get_insurance_type(H) != INSURANCE_PREMIUM)
		return

	for(var/obj/item/weapon/reagent_containers/glass/beaker/B in premium_beakers)
		var/inject_amount = premium_beakers[B]
		if(!inject_amount)
			continue

		if(!try_take_money(inject_amount * premium_injection_cost))
			playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)
			stop_injections()
			return

		if(!B.reagents.trans_to(H, inject_amount))
			premium_beakers[B] = 0
			continue

		playsound(src, 'sound/machines/sleeper_inject.ogg', VOL_EFFECTS_MASTER, vary = FALSE)

/obj/machinery/sleeper/proc/stop_injections()
	for(var/obj/item/weapon/reagent_containers/glass/beaker/B in regular_beakers)
		regular_beakers[B] = 0

	for(var/obj/item/weapon/reagent_containers/glass/beaker/B in premium_beakers)
		premium_beakers[B] = 0


/obj/machinery/sleeper/proc/try_take_money(amount_needed = 0)
	if(!occupant || !ishuman(occupant))
		return FALSE

	var/mob/living/carbon/human/H = occupant
	var/datum/data/record/R = find_record("fingerprint", md5(H.dna.uni_identity), data_core.general)
	if(!R)
		return FALSE

	var/datum/money_account/MA = get_account(R.fields["acc_number"])
	if(!MA)
		return FALSE

	if(MA.money < amount_needed)
		return FALSE

	if(amount_needed > 0)
		charge_to_account(MA.account_number, global.department_accounts["Medical"].account_number, "Оплата за операцию в [CASE(src, PREPOSITIONAL_CASE)]", name, -amount_needed)
		charge_to_account(global.department_accounts["Medical"].account_number, MA.account_number, "Оплата за операцию в [CASE(src, PREPOSITIONAL_CASE)]", name, amount_needed)

	return TRUE
