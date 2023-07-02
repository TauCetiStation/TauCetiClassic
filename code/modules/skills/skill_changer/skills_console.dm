/obj/machinery/computer/skills_console
	name = "CMF Modifier Access Console"
	desc = "Used for scanning and modyfing cognitive and motor functions of connected patient."
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
	idle_power_usage = 100
	active_power_usage = 85000
	var/obj/machinery/optable/skill_scanner/scanner = null
	required_skills = list(/datum/skill/command = SKILL_LEVEL_NOVICE, /datum/skill/medical = SKILL_LEVEL_NOVICE)

/obj/machinery/computer/skills_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/skills_console/atom_init_late()
	for(var/obj/machinery/optable/skill_scanner/skill_scanner in orange(5, src))
		scanner = skill_scanner
		scanner.console = src
		break

/obj/machinery/computer/skills_console/proc/inserted_cartridge()
	return scanner && scanner.cartridge != null

/obj/machinery/computer/skills_console/attackby(obj/item/I, mob/user)
	if(ispulsing(I))
		var/obj/item/device/multitool/M = I
		if(M.buffer && istype(M.buffer, /obj/machinery/optable/skill_scanner))
			scanner = M.buffer
			scanner.console = src
			M.buffer = null
			to_chat(user, "<span class='notice'>You upload the data from the [I.name]'s buffer.</span>")
			tgui_interact(user)
		return FALSE
	return ..()

/obj/machinery/computer/skills_console/attack_hand(mob/user)
	user.set_machine(src)
	tgui_interact(user)

/obj/machinery/computer/skills_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillsConsole", name)
		ui.open()

/obj/machinery/computer/skills_console/tgui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/area/A = get_area(src)
	data["power_usage"] = current_power_usage
	data["power_max"] = "No data"
	data["power_current"] = "No data"
	if(A)
		var/obj/machinery/power/apc/apc = A.get_apc()
		if(apc)
			data["power_current"] = apc.cell.charge
			data["power_max"] = apc.cell.maxcharge

	data["connected_table"] = scanner
	data["connected_patient"] = scanner && scanner.victim

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
	data["skill_max_value"] = SKILL_LEVEL_HUMAN_MAX
	data["inserted_cartridge"] = inserted_cartridge()
	if(inserted_cartridge())
		var/obj/item/weapon/skill_cartridge/cartridge = scanner.cartridge
		data["skill_list"] = cartridge.get_buff_list()
		data["compatible_species"] = cartridge.compatible_species
		data["cartridge_name"] = cartridge.name
		data["cartridge_unpacked"] = cartridge.unpacked
		data["cartridge_points"] = cartridge.points
		data["free_points"] = cartridge.points - cartridge.get_used_points()
	data["can_inject"] = can_inject(user)

	return data

/obj/machinery/computer/skills_console/proc/can_inject(mob/user)
	if(scanner && scanner.cartridge && scanner.victim && scanner.victim.mind)
		if(ishuman(scanner.victim))
			var/mob/living/carbon/human/H = scanner.victim
			var/same_user = H == user
			var/compatible = (H.species.name in scanner.cartridge.compatible_species)
			if(compatible && !same_user && !(HAS_TRAIT(H, TRAIT_VISUAL_MINDSHIELD) || HAS_TRAIT(H, TRAIT_VISUAL_LOYAL)))
				return TRUE
	return FALSE

/obj/machinery/computer/skills_console/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			if(scanner && scanner.eject_cartridge())
				set_power_use(IDLE_POWER_USE)
			. = TRUE
		if("inject")
			if(can_inject(usr))
				scanner.inject_victim()
				set_power_use(IDLE_POWER_USE)
			. = TRUE
		if("change_skill")
			if(scanner && scanner.cartridge && scanner.cartridge.unpacked)
				scanner.cartridge.set_skills_buff(params)

		if("abort")
			if(scanner)
				scanner.abort_injection()
				set_power_use(IDLE_POWER_USE)
			. = TRUE
		if("unpack")
			if(scanner && scanner.cartridge && !scanner.cartridge.unpacked)
				scanner.cartridge.unpacked = TRUE
				set_power_use(ACTIVE_POWER_USE)
			. = TRUE
	update_icon()

/obj/machinery/computer/skills_console/deconstruction()
	. = ..()
	if(scanner)
		scanner.console = null
