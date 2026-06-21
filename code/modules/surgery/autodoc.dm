#define AUTODOC_COOLDOWN 30

ADD_TO_GLOBAL_LIST(/obj/machinery/autodoc, autodoc_machines)
/obj/machinery/autodoc
	name = "Autodoc"
	cases = list("автодок", "автодока", "автодоку", "автодок", "автодоком", "автодоке")
	desc = "Используется для оперирования пациентов."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "autodoc_0"
	anchored = TRUE
	light_color = "#00ff00"
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_NOVICE)

	var/list/datum/auto_surgery/surgeries_queue = list()
	var/list/datum/surgery_step/steps_queue = list()

	var/prev_step_time = 0

	var/datum/wires/autodoc/wires = null
	var/medical_access = FALSE
	var/seller_account_number = MAP_VENDOR_ACCOUNT_NUMBER_PLACEHOLDER

	var/obj/item/weapon/reagent_containers/blood/blood_pack = null
	var/obj/item/weapon/reagent_containers/glass/beaker/beaker_antibiotic = null
	var/obj/item/weapon/tank/anesthetic = null

	var/surgery_in_process = FALSE
	var/chosen_zone

/obj/machinery/autodoc/atom_init(mapload)
	. = ..()

	wires = new(src)

	if(mapload)
		if(is_station_level(z))
			seller_account_number = MAP_MEDBAY_ACCOUNT_NUMBER_PLACEHOLDER

		blood_pack = new /obj/item/weapon/reagent_containers/blood/APlus

		beaker_antibiotic = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		beaker_antibiotic.reagents.add_reagent("spaceacillin", rand(0, 150))
		beaker_antibiotic.update_icon()

		anesthetic = new /obj/item/weapon/tank/anesthetic/small(src)

/obj/machinery/autodoc/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)
		stop_operation()

/obj/machinery/autodoc/relaymove(mob/user)
	if(!user.incapacitated())
		open_machine()

/obj/machinery/autodoc/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Autodoc"

	if (usr.incapacitated())
		return
	if(!do_skill_checks(usr))
		return
	open_machine()
	add_fingerprint(usr)
	return

/obj/machinery/autodoc/proc/connect_anesthetic()
	if(!occupant)
		return

	if(!anesthetic)
		return

	if(occupant.internal)
		return

	ADD_TRAIT(occupant, TRAIT_EXTERNAL_VENTILATION, src)
	occupant.internal = anesthetic


/obj/machinery/autodoc/proc/disconnect_anesthetic()
	if(!occupant)
		return

	if(!anesthetic)
		return

	if(occupant.internal != anesthetic)
		return

	REMOVE_TRAIT(occupant, TRAIT_EXTERNAL_VENTILATION, src)
	occupant.internal = null

/obj/machinery/autodoc/proc/start_operation()
	if(steps_queue.len)
		return

	if(!surgeries_queue.len)
		return

	connect_anesthetic()

	surgery_in_process = TRUE

/obj/machinery/autodoc/proc/stop_operation()
	surgeries_queue = list()
	steps_queue = list()
	disconnect_anesthetic()
	surgery_in_process = FALSE

/obj/machinery/autodoc/open_machine()
	stop_operation()
	return ..()

/obj/machinery/autodoc/dropContents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		if(AM == blood_pack)
			continue
		if(AM == anesthetic)
			continue
		if(AM == beaker_antibiotic)
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

/obj/machinery/autodoc/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Autodoc"

	if (usr.incapacitated())
		return
	if(!move_inside_checks(usr, usr))
		return
	close_machine(usr, usr)

/obj/machinery/autodoc/close_machine(mob/living/target = null)
	surgeries_queue = list()
	steps_queue = list()
	return ..()

/obj/machinery/autodoc/proc/move_inside_checks(mob/target, mob/user)
	if(occupant)
		to_chat(user, "<span class='userdanger'>[C_CASE(src, NOMINATIVE_CASE)] уже занят кем-то!</span>")
		return FALSE
	if(!ishuman(target))
		to_chat(user, "<span class='userdanger'>Это устройство может оперировать только гуманоидные формы жизни.</span>")
		return FALSE
	var/mob/living/carbon/human/H = target
	if(H.species.flags[NO_MED_HEALTH_SCAN])
		to_chat(user, "<span class='userdanger'>Это существо нельзя оперировать</span>")
		return FALSE
	if(!check_insurance(get_insurance_type(H), INSURANCE_STANDARD))
		to_chat(user, "<span class='userdanger'>У пациента отсутствует страховка.</span>")
		return FALSE
	if(target.abiotic())
		to_chat(user, "<span class='userdanger'>У пациента не должно быть чего-либо в руках.</span>")
		return FALSE
	if(!do_skill_checks(user))
		return
	return TRUE

/obj/machinery/autodoc/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		if(!move_inside_checks(G.affecting, user))
			return

		add_fingerprint(user)
		close_machine(G.affecting)
		playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return

	if(isscrewing(W) && anchored)
		src.panel_open = !src.panel_open
		to_chat(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
		updateUsrDialog()
		return
	if(is_wire_tool(W) && panel_open && wires.interact(user))
		return

	if(panel_open)
		if(!seller_account_number && (istype(W, /obj/item/device/pda) && W.GetID()))
			var/obj/item/weapon/card/Card = W.GetID()
			seller_account_number = Card.associated_account_number
			to_chat(user, "<span class='notice'>You connect your account to the [src]</span>")
			return

		if(!seller_account_number && istype(W, /obj/item/weapon/card))
			var/obj/item/weapon/card/Card = W
			seller_account_number = Card.associated_account_number
			to_chat(user, "<span class='notice'>You connect your account to the [src]</span>")
			return

	return ..()

/obj/machinery/autodoc/update_icon()
	icon_state = "autodoc_[occupant ? "1" : "0"]"

/obj/machinery/autodoc/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated())
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, что с этим делать.</span>")
		return
	if(!move_inside_checks(target, user))
		return
	add_fingerprint(user)
	close_machine(target)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/autodoc/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, что с этим делать.</span>")
		return
	if(occupant)
		eject()
		return
	var/mob/living/carbon/target = locate() in loc
	if(!target)
		return
	if(!move_inside_checks(target, user))
		return
	add_fingerprint(user)
	close_machine(target)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/autodoc/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
	for(var/atom/movable/A in src)
		A.forceMove(get_turf(src))
		A.ex_act(severity)
	qdel(src)

/obj/machinery/autodoc/deconstruct(disassembled)
	disconnect_anesthetic()
	for(var/atom/movable/A in src)
		A.forceMove(get_turf(src))
	..()

/obj/machinery/autodoc/process()
	if(!surgery_in_process)
		return

	if(prev_step_time + AUTODOC_COOLDOWN > world.time)
		return

	if(steps_queue.len)
		process_step()
		return

	if(surgeries_queue.len)
		process_surgery()
		return

/obj/machinery/autodoc/proc/process_surgery()
	var/list/surgery_list = popleft(surgeries_queue)
	var/surgery_path = surgery_list["surgery_type"]
	var/datum/auto_surgery/surgery = new surgery_path()
	if(!surgery)
		return

	if(!check_insurance(get_insurance_type(occupant), surgery.insurance_needed))
		qdel(surgery)
		return

	for(var/surgery_step in surgery.steps)
		var/list/step_list = list("target_zone" = surgery_list["target_zone"], "step" = surgery_step, "cost" = surgery.step_cost)
		steps_queue += list(step_list)

	if(occupant && beaker_antibiotic && beaker_antibiotic.reagents)
		beaker_antibiotic.reagents.trans_to(occupant, 5)

	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
	qdel(surgery)

/obj/machinery/autodoc/proc/process_step()
	var/list/step_list = popleft(steps_queue)
	var/step_path = step_list["step"]
	var/datum/surgery_step/step = new step_path()
	if(!step.is_valid_mutantrace(occupant))
		qdel(step)
		if(!steps_queue.len && !surgeries_queue.len)
			open_machine()
		return

	if(!blood_pack || !blood_pack.reagents)
		abort_operation("<span class='danger'>Недостаточно крови, операция отменена!</span>")
		return

	if(!blood_pack.reagents.remove_reagent("blood", 1))
		abort_operation("<span class='danger'>Недостаточно крови, операция отменена!</span>")
		return

	var/target_zone = step_list["target_zone"]
	if(!try_take_money(step_list["cost"]))
		abort_operation("<span class='danger'>Недостаточно средств, операция отменена!</span>")
		return

	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		if(!HAS_TRAIT(H, TRAIT_NO_PAIN) && !HAS_TRAIT(H, TRAIT_IMMOBILIZED))
			H.adjustHalLoss(25)
		if(prob(H.traumatic_shock) && !H.incapacitated(NONE))
			abort_operation("<span class='danger'>Пациент вырвался на свободу!</span>")
			return

	step.end_step_action(occupant, target_zone)

	playsound(src, 'sound/machines/ding.ogg', VOL_EFFECTS_MASTER)
	qdel(step)

	prev_step_time = world.time

	if(!steps_queue.len && !surgeries_queue.len)
		open_machine()

/obj/machinery/autodoc/proc/abort_operation(message)
	playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)
	visible_message(message)
	open_machine()

/obj/machinery/autodoc/proc/try_take_money(amount_needed = 0)
	if(!seller_account_number) //No account connection, everything is free!
		return TRUE

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
		charge_to_account(MA.account_number, global.department_accounts["Medical"].account_number, "Оплата за операцию в АвтоДоке", name, -amount_needed)
		charge_to_account(global.department_accounts["Medical"].account_number, MA.account_number, "Оплата за операцию в АвтоДоке", name, amount_needed)

	return TRUE

/obj/machinery/autodoc/proc/check_insurance(insurance_to_check, minimal_insurance)
	if(!seller_account_number) //No account connection, everything is free!
		return TRUE

	if(seller_account_number != global.department_accounts["Medical"].account_number) //We are not connected to medbay, no need for insurance check!
		return TRUE

	return is_insurance_sufficient(insurance_to_check, minimal_insurance)

/obj/machinery/autodoc/proc/try_access_beakers(mob/user)
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

/obj/machinery/autodoc/proc/eject_thing(obj/item/weapon/beaker, mob/user)
	if(!ishuman(user))
		beaker.forceMove(get_turf(src))
		return

	var/mob/living/carbon/human/H = user
	beaker.forceMove(get_turf(H))
	H.put_in_hands(beaker)

/obj/machinery/autodoc/proc/try_put_thing(mob/user, type_to_check)
	if(!ishuman(usr))
		return null

	var/mob/living/carbon/human/H = user

	var/obj/item/I = H.get_active_hand()
	if(!I)
		return null

	if(!istype(I, type_to_check))
		return null

	if(!H.drop_from_inventory(I, src))
		return null

	return I

/obj/machinery/autodoc/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/autodoc/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Autodoc", C_CASE(src, NOMINATIVE_CASE), 900, 540)
		ui.open()

/obj/machinery/autodoc/tgui_static_data(mob/user)
	var/list/static_data = list()

	var/list/operations = list()
	for(var/target_zone in global.auto_surgeries)
		var/list/surgeries_list = global.auto_surgeries[target_zone]
		if(!surgeries_list.len)
			continue

		for(var/datum/auto_surgery/surgery in surgeries_list)
			operations += list(list("target_zone" = target_zone, "name" = surgery.name, "type" = surgery.type))

	static_data["operations"] = operations
	return static_data

/obj/machinery/autodoc/tgui_data(mob/user)
	var/list/data = list()

	data["medical_access"] = medical_access

	data["operating"] = surgery_in_process

	data["blood_beaker"] = blood_pack ? list("name" = blood_pack.blood_type, "amount" = round(blood_pack.reagents.total_volume / blood_pack.volume * 100)) : null

	data["antibiotic_beaker"] = beaker_antibiotic ? list("name" = beaker_antibiotic.label_text ? beaker_antibiotic.label_text : beaker_antibiotic.reagents.get_master_reagent_name(), "amount" = round(beaker_antibiotic.reagents.total_volume / beaker_antibiotic.volume * 100)) : null

	data["anesthetic_tank"] = anesthetic ? CASE(anesthetic, NOMINATIVE_CASE) : null

	data["chosen_surgeries"] = surgeries_queue
	data["chosen_zone"] = chosen_zone

	return data

/obj/machinery/autodoc/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("open")
			open_machine()
			return TRUE

		if("operate")
			start_operation()
			return TRUE

		if("choose_zone")
			var/chosen = params["zone"]
			if(!(chosen in TARGET_ZONE_ALL))
				return

			chosen_zone = chosen

		if("add_operation")
			if(surgery_in_process)
				return

			if(!occupant)
				return

			var/surgery_zone = params["surgery_zone"]

			if(!(surgery_zone in TARGET_ZONE_ALL))
				return

			var/surgery_type = text2path(params["surgery_type"])

			if(!ispath(surgery_type))
				return

			var/datum/auto_surgery/surg = surgery_type
			if(!check_insurance(get_insurance_type(occupant), surg::insurance_needed))
				playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)
				visible_message("<span class='danger'>Страховка пациента недостаточна для этой операции!</span>")
				return

			for(var/list/surgery in surgeries_queue)
				if(surgery["target_zone"] != surgery_zone)
					continue

				if(surgery["surgery_type"] != surgery_type)
					continue

				surgeries_queue -= list(surgery)
				return TRUE

			surgeries_queue += list(list("target_zone" = surgery_zone, "surgery_type" = surgery_type))
			return TRUE

		if("access")
			if(medical_access)
				medical_access = FALSE
				return TRUE

			try_access_beakers(usr)
			return TRUE

		if("eject_blood_beaker")
			if(!medical_access)
				return

			if(!blood_pack)
				return

			eject_thing(blood_pack, usr)
			blood_pack = null
			return TRUE

		if("put_blood_beaker")
			if(!medical_access)
				return

			if(blood_pack)
				return

			blood_pack = try_put_thing(usr, /obj/item/weapon/reagent_containers/blood)
			return TRUE

		if("eject_antibiotic_beaker")
			if(!medical_access)
				return

			if(!beaker_antibiotic)
				return

			eject_thing(beaker_antibiotic, usr)
			beaker_antibiotic = null
			return TRUE

		if("put_antibiotic_beaker")
			if(!medical_access)
				return

			if(beaker_antibiotic)
				return

			beaker_antibiotic = try_put_thing(usr, /obj/item/weapon/reagent_containers/glass/beaker)
			return TRUE

		if("eject_tank")
			if(!medical_access)
				return

			if(!anesthetic)
				return

			disconnect_anesthetic()
			eject_thing(anesthetic, usr)
			anesthetic = null
			return TRUE

		if("put_tank")
			if(!medical_access)
				return

			if(anesthetic)
				return

			anesthetic = try_put_thing(usr, /obj/item/weapon/tank)
			return TRUE

	return TRUE
