// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/locked
	name = "Body Scanner"
	desc = "Used for a more detailed analysis of the patient."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scanner_0"
	density = TRUE
	anchored = TRUE
	light_color = "#00ff00"
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_NOVICE)

/obj/machinery/bodyscanner/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/bodyscanner/relaymove(mob/user)
	if(!user.incapacitated())
		open_machine()

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if (usr.incapacitated())
		return
	open_machine()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if (usr.incapacitated())
		return
	if(!move_inside_checks(usr, usr))
		return
	close_machine(usr, usr)
	SStgui.update_uis(src)

/obj/machinery/bodyscanner/proc/move_inside_checks(mob/target, mob/user)
	if(occupant)
		to_chat(user, "<span class='userdanger'>The scanner is already occupied!</span>")
		return FALSE
	if(!iscarbon(target))
		return FALSE
	if(target.abiotic())
		to_chat(user, "<span class='userdanger'>Subject cannot have abiotic items on.</span>")
		return FALSE
	if(!do_skill_checks(user))
		return
	return TRUE

/obj/machinery/bodyscanner/attackby(obj/item/weapon/grab/G, mob/user)
	if(!istype(G))
		return
	if(!move_inside_checks(G.affecting, user))
		return
	add_fingerprint(user)
	close_machine(G.affecting)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	qdel(G)

/obj/machinery/bodyscanner/update_icon()
	icon_state = "body_scanner_[occupant ? "1" : "0"]"

/obj/machinery/bodyscanner/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated())
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	if(!move_inside_checks(target, user))
		return
	add_fingerprint(user)
	close_machine(target)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/bodyscanner/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	if(occupant)
		open_machine()
		add_fingerprint(user)
		return
	var/mob/living/carbon/target = locate() in loc
	if(!target)
		return
	if(!move_inside_checks(target, user))
		return
	add_fingerprint(user)
	close_machine(target)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
	for(var/atom/movable/A in src)
		A.forceMove(loc)
		ex_act(severity)
	qdel(src)

/obj/machinery/bodyscanner/deconstruct(disassembled)
	for(var/atom/movable/A in src)
		A.forceMove(loc)
	..()

/obj/machinery/body_scanconsole/power_change()
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

/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/mind_protect/mindshield, /obj/item/weapon/implant/tracking, /obj/item/weapon/implant/mind_protect/loyalty, /obj/item/weapon/implant/obedience, /obj/item/weapon/implant/skill, /obj/item/weapon/implant/blueshield, /obj/item/weapon/implant/fake_loyal)
	var/delete
	name = "Body Scanner Console"
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scannerconsole"
	anchored = TRUE
	var/next_print = 0
	var/storedinfo = null
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_TRAINED)

/obj/machinery/body_scanconsole/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/body_scanconsole/atom_init_late()
	connected = locate(/obj/machinery/bodyscanner) in orange(1, src)

/obj/machinery/body_scanconsole/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/body_scanconsole/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BodyScanner", name, 690, 600)
		ui.open()

/obj/machinery/body_scanconsole/tgui_data(mob/user)
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
		occupantData["drunkenness"] = (occupant.drunkenness / 10)
		occupantData["bodyTempC"] = occupant.bodytemperature-T0C
		occupantData["bodyTempF"] = (((occupant.bodytemperature-T0C) * 1.8) + 32)

		occupantData["hasBorer"] = occupant.has_brain_worms()

		var/list/bloodData = list()
		bloodData["hasBlood"] = FALSE
		if(!occupant.species.flags[NO_BLOOD])
			bloodData["hasBlood"] = TRUE
			bloodData["percent"] = round(((occupant.blood_amount() / BLOOD_VOLUME_NORMAL)*100))
			bloodData["pulse"] = occupant.get_pulse(GETPULSE_TOOL)
			bloodData["bloodLevel"] = occupant.blood_amount()
			bloodData["bloodMax"] = BLOOD_VOLUME_MAXIMUM
			bloodData["bloodNormal"] = BLOOD_VOLUME_NORMAL
		occupantData["blood"] = bloodData

		var/list/extOrganData = list()
		for(var/obj/item/organ/external/E in occupant.bodyparts)
			var/list/organData = list()
			organData["name"] = capitalize(E.name)
			organData["open"] = E.open
			organData["germ_level"] = E.germ_level
			organData["bruteLoss"] = E.brute_dam
			organData["fireLoss"] = E.burn_dam
			organData["totalLoss"] = E.brute_dam + E.burn_dam
			organData["maxHealth"] = E.max_damage
			organData["broken"] = E.min_broken_damage

			var/list/implantData = list()
			for(var/obj/I in E.implants)
				var/list/implantSubData = list()
				if(is_type_in_list(I, known_implants))
					implantSubData["name"] = capitalize(sanitize(I.name))
					implantData.Add(list(implantSubData))
				else
					implantSubData["name"] = null
					implantData.Add(list(implantSubData))
			organData["implant"] = implantData
			organData["implant_len"] = implantData.len

			var/list/organStatus = list()
			if(E.status & ORGAN_BROKEN)
				organStatus["broken"] = capitalize(E.broken_description)
			if(E.is_robotic())
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

		occupantData["extOrgan"] = extOrganData

		var/list/intOrganData = list()
		for(var/obj/item/organ/internal/I in occupant.organs)
			var/list/organData = list()
			organData["name"] = capitalize(I.name)
			organData["desc"] = I.desc
			organData["germ_level"] = I.germ_level
			organData["damage"] = I.damage
			organData["maxHealth"] = I.min_broken_damage
			organData["bruised"] = I.min_bruised_damage
			organData["broken"] = I.min_broken_damage
			organData["robotic"] = I.robotic == 2
			organData["dead"] = (I.status & ORGAN_DEAD)

			intOrganData.Add(list(organData))

		occupantData["intOrgan"] = intOrganData

		occupantData["blind"] = occupant.sdisabilities & BLIND
		occupantData["colourblind"] = occupant.daltonism
		occupantData["nearsighted"] = HAS_TRAIT(occupant, TRAIT_NEARSIGHT)

	data["occupant"] = occupantData

	return data

/obj/machinery/body_scanconsole/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("ejectify")
			connected.eject()
		if("print_p")
			print_scan()

	return TRUE

/obj/machinery/body_scanconsole/proc/print_scan(additional_info)
	var/obj/item/weapon/paper/P = new(loc)
	if(!connected || !connected.occupant) // If while we were printing the occupant got out or our thingy did a boom.
		return
	var/mob/living/carbon/human/occupant = connected.occupant
	var/t1 = "<B>[occupant ? occupant.name : "Unknown"]'s</B> advanced scanner report.<BR>"
	t1 += "Station Time: <B>[worldtime2text()]</B><BR>"
	switch(occupant.stat) // obvious, see what their status is
		if(CONSCIOUS)
			t1 += "Status: <B>Conscious</B>"
		if(UNCONSCIOUS)
			t1 += "Status: <B>Unconscious</B>"
		else
			t1 += "Status: <B><span class='warning'>*dead*</span></B>"
	t1 += additional_info
	P.info = t1
	P.name = "[occupant.name]'s scanner report"
	P.update_icon()
