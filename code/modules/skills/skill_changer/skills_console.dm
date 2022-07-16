/obj/machinery/computer/skills_console
	name = "CMF Modifier Access Console"
	desc = "Used for scanning and modyfing XXX of connected patient."
	icon = 'icons/obj/skills/skills_machinery.dmi'
	icon_state = "laptop_skills"
	state_broken_preset = "laptopb"
	state_nopower_preset = "laptop0"
	light_color = "#315ab4"
	density = TRUE
	circuit = /obj/item/weapon/circuitboard/skills_console
	var/selected_menu_key = null
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 400
	var/obj/item/weapon/skill_cartridge/cartridge = null
	var/obj/machinery/optable/skill_scanner/scanner = null
	required_skills = list(/datum/skill/command = SKILL_LEVEL_NOVICE, /datum/skill/medical = SKILL_LEVEL_NOVICE, /datum/skill/research = SKILL_LEVEL_NOVICE)

/obj/machinery/computer/skills_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/skills_console/atom_init_late()
	for(var/obj/machinery/optable/skill_scanner in orange(5, src))
		scanner = skill_scanner
		scanner.console = src
		break

/obj/machinery/computer/skills_console/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/skill_cartridge))
		if (!cartridge)
			if(!do_skill_checks(user))
				return
			user.drop_from_inventory(I, src)
			cartridge = I
			to_chat(user, "<span class='notice'>You insert [I].</span>")
			updateDialog()
		return FALSE
	else if(ismultitool(I))
		var/obj/item/device/multitool/M = I
		if(M.buffer && istype(M.buffer, /obj/machinery/optable/skill_scanner))
			scanner = M.buffer
			scanner.console = src
			M.buffer = null
			to_chat(user, "<span class='notice'>You upload the data from the [I.name]'s buffer.</span>")
			updateDialog()
		return FALSE
	return ..()

/obj/machinery/computer/skills_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillsConsole")
		ui.open()

/obj/machinery/computer/skills_console/tgui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["connected_table"] = scanner
	data["connected_patient"] = scanner && scanner.victim

	var/skill_list = list()
	for(var/skill_type in all_skills)
		skill_list += all_skills[skill_type]
	data["skill_list"] = skill_list

	if(scanner && scanner.victim && scanner.victim.mind)
		var/iq = 100
		var/mdi = 0
		var/list/iq_skills = list(/datum/skill/chemistry, /datum/skill/research, /datum/skill/medical, /datum/skill/engineering)
		var/list/mdi_skills = list(/datum/skill/firearms, /datum/skill/civ_mech, /datum/skill/combat_mech, /datum/skill/construction, /datum/skill/surgery)
		var/mob/living/carbon/human/H = scanner.victim
		for(var/skill in H.mind.skills.active.skills)
			if(skill in iq_skills)
				iq += H.mind.skills.active.get_value(skill) * 6
			if(skill in mdi_skills)
				mdi +=  H.mind.skills.active.get_value(skill)
		data["IQ"] = iq
		data["MDI"] = mdi
	data["skill_min_value"] = SKILL_LEVEL_MIN
	data["skill_max_value"] = SKILL_LEVEL_MAX
	data["inserted_cartridge"] = cartridge != null
	if(cartridge)
		data["compatible_species"] = cartridge.compatible_species
		data["cartridge_name"] = cartridge.name
		data["cartridge_unpacked"] = cartridge.unpacked
		data["cartridge_points"] = cartridge.points

	return data
/obj/machinery/computer/skills_console/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/computer/skills_console/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return
	if(action == "eject")
		if(cartridge && !cartridge.unpacked)
			cartridge.forceMove(loc)
			cartridge = null
			. = TRUE
	if(action == "inject")
		var/new_color = params["color"]
		. = TRUE
	if(action == "abort")
		if(cartridge && cartridge.unpacked)
			qdel(cartridge)
			cartridge = null
	if(action == "unpack")
		if(cartridge && !cartridge.unpacked)
			cartridge.unpacked = TRUE
			. = TRUE
	update_icon()
