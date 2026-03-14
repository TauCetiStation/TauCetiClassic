// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/autodoc
	var/locked
	name = "Autodoc"
	cases = list("автодок", "автодока", "автодоку", "автодок", "автодоком", "автодоке")
	desc = "Используется для оперирования пациентов."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scanner_0"
	anchored = TRUE
	light_color = "#00ff00"
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_NOVICE)

/obj/machinery/autodoc/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

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

/obj/machinery/autodoc/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Autodoc"

	if (usr.incapacitated())
		return
	if(!move_inside_checks(usr, usr))
		return
	close_machine(usr, usr)

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
	if(target.abiotic())
		to_chat(user, "<span class='userdanger'>У пациента не должно быть чего-либо в руках.</span>")
		return FALSE
	if(!do_skill_checks(user))
		return
	return TRUE

/obj/machinery/autodoc/attackby(obj/item/weapon/grab/G, mob/user)
	if(!istype(G))
		return
	if(!move_inside_checks(G.affecting, user))
		return
	add_fingerprint(user)
	close_machine(G.affecting)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/autodoc/update_icon()
	icon_state = "body_scanner_[occupant ? "1" : "0"]"

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
	for(var/atom/movable/A in src)
		A.forceMove(get_turf(src))
	..()

/obj/machinery/autodoc_console/power_change()
	if(stat & BROKEN)
		icon_state = "body_scannerconsole-p"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "body_scannerconsole-p"
			stat |= NOPOWER
			update_power_use()
	update_power_use()

/obj/machinery/autodoc_console
	var/obj/machinery/autodoc/connected
	name = "Autodoc Console"
	cases = list("консоль автодока", "консоли автодока", "консоли автодока", "консоль автодока", "консолью автодока", "консоли автодока")
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scannerconsole"
	anchored = TRUE
	COOLDOWN_DECLARE(next_print)
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_TRAINED)

/obj/machinery/autodoc_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/autodoc_console/atom_init_late()
	connected = locate(/obj/machinery/autodoc) in orange(1, src)

/obj/machinery/autodoc_console/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/autodoc_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AutoDoc", C_CASE(src, NOMINATIVE_CASE), 690, 600)
		ui.open()

/obj/machinery/autodoc_console/tgui_data(mob/user)
	var/list/data = list()
	var/list/occupantData = list()
	var/mob/living/carbon/human/occupant = connected.occupant

	data["occupied"] = occupant
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth

		occupantData["hasVirus"] = occupant.virus2.len

		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()

		occupantData["radLoss"] = occupant.radiation
		occupantData["cloneLoss"] = occupant.getCloneLoss()
		occupantData["brainLoss"] = occupant.getBrainLoss()
		occupantData["drunkenness"] = (occupant.drunkenness / 6) // 600 - maximum stage
		occupantData["bodyTempC"] = occupant.bodytemperature-T0C
		occupantData["bodyTempF"] = (((occupant.bodytemperature-T0C) * 1.8) + 32)

		occupantData["hasBorer"] = !!occupant.has_brain_worms()

		var/list/bloodData = list()
		bloodData["hasBlood"] = FALSE
		if(!HAS_TRAIT(occupant, TRAIT_NO_BLOOD))
			bloodData["hasBlood"] = TRUE
			bloodData["percent"] = round(((occupant.blood_amount() / BLOOD_VOLUME_NORMAL)*100))
			bloodData["pulse"] = occupant.get_pulse_number(GETPULSE_TOOL)
			bloodData["bloodLevel"] = occupant.blood_amount()
			bloodData["bloodNormal"] = BLOOD_VOLUME_NORMAL
		occupantData["blood"] = bloodData

		var/list/extOrganData = list()
		for(var/obj/item/organ/external/E in occupant.bodyparts)
			var/list/organData = list()

			organData["name"] = C_CASE(E, NOMINATIVE_CASE)
			if(E.is_stump)
				organData["name"] = capitalize(parse_zone_ru(E.body_zone))

			organData["open"] = E.open
			organData["germ_level"] = get_germ_level_name(E.germ_level)
			organData["bruteLoss"] = E.brute_dam
			organData["fireLoss"] = E.burn_dam
			organData["totalLoss"] = E.brute_dam + E.burn_dam
			organData["maxHealth"] = E.max_damage
			organData["broken"] = E.min_broken_damage
			organData["stump"] = E.is_stump

			var/list/implantData = list()
			var/has_unknown_implant = FALSE
			for(var/obj/item/weapon/implant/I in E.embedded_objects)
				var/list/implantSubData = list()
				implantSubData["name"] = C_CASE(I, NOMINATIVE_CASE)

				if(!is_known_implant(I))
					has_unknown_implant = TRUE
					implantSubData["name"] = null

				implantData.Add(list(implantSubData))

			organData["implant"] = implantData
			organData["unknown_implant"] = has_unknown_implant

			var/list/organStatus = list()
			if(E.status & ORGAN_BROKEN)
				organStatus["broken"] = capitalize(E.broken_description)
			if(E.is_robotic_part())
				organStatus["robotic"] = TRUE
			if(E.status & ORGAN_SPLINTED)
				organStatus["splinted"] = TRUE
			if(E.status & ORGAN_DEAD)
				organStatus["dead"] = TRUE

			organData["status"] = organStatus

			if(istype(E, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
				organData["lungRuptured"] = TRUE

			if(E.status & ORGAN_ARTERY_CUT)
				organData["internalBleeding"] = TRUE

			extOrganData.Add(list(organData))

		for(var/bp_type in occupant.get_missing_bodyparts())
			var/list/organData = list()
			var/list/organStatus = list()

			organData["name"] = capitalize(parse_zone_ru(bp_type))
			organData["missing"] = TRUE
			organData["totalLoss"] = 0

			organData["status"] = organStatus

			extOrganData.Add(list(organData))

		occupantData["extOrgan"] = extOrganData

		var/list/intOrganData = list()
		for(var/obj/item/organ/internal/I in occupant.organs)
			var/list/organData = list()
			organData["name"] = C_CASE(I, NOMINATIVE_CASE)
			organData["germ_level"] = get_germ_level_name(I.germ_level)
			organData["damage"] = I.damage
			organData["maxHealth"] = I.min_broken_damage
			organData["bruised"] = I.is_bruised()
			organData["broken"] = I.is_broken()
			organData["robotic"] = I.is_robotic()
			organData["dead"] = (I.status & ORGAN_DEAD)

			intOrganData.Add(list(organData))

		occupantData["intOrgan"] = intOrganData

		occupantData["blind"] = occupant.sdisabilities & BLIND
		occupantData["nearsighted"] = HAS_TRAIT(occupant, TRAIT_NEARSIGHT)

	data["occupant"] = occupantData

	return data

/obj/machinery/autodoc_console/proc/is_known_implant(obj/item/weapon/implant/I)
	return I.legal

/obj/machinery/autodoc_console/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("ejectify")
			connected.eject()
		if("print_p")
			print_scan()

	return TRUE
