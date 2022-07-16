/obj/item/weapon/circuitboard/skill_scanner
	name = "Circuit board (CMF table)"
	build_path = /obj/machinery/optable/skill_scanner
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 4,
							/obj/item/weapon/stock_parts/manipulator = 4,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/capacitor= 1)

/obj/item/weapon/circuitboard/skills_console
	name = "Circuit board (CMF Console)"
	build_path = /obj/machinery/computer/skills_console
	origin_tech = "programming=2;biotech=2"

/obj/machinery/optable/skill_scanner
	name = "CMF Table"
	desc = "Used to scan and change the cognitive and motor functions of living beings. Also a very comfortable table to lie on."
	icon = 'icons/obj/skills/skills_machinery.dmi'
	icon_state = "table_idle"
	icon_state_active = "table_active"
	icon_state_idle = "table_idle"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 10000

/obj/machinery/optable/skill_scanner/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/skill_scanner(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()

/obj/machinery/optable/skill_scanner/attackby(obj/item/W, mob/user)
	if(victim)
		return
	if(default_deconstruction_screwdriver(user, "table_open", "table_idle", W))
		return
	if(exchange_parts(user, W))
		return

	default_deconstruction_crowbar(W)

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
		break

/obj/machinery/computer/skills_console/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/skill_cartridge))
		if (!cartridge)
			if(!do_skill_checks(user))
				return
			user.drop_from_inventory(I, src)
			cartridge = I
			to_chat(user, "<span class='notice'>You insert [I].</span>")
			nanomanager.update_uis(src) // update all UIs attached to src
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

	if(scanner.victim)
		var/iq = 100
		var/mdi = 0
		var/list/iq_skills = list(/datum/skill/chemistry, /datum/skill/research, /datum/skill/medical, /datum/skill/engineering)
		var/list/mdi_skills = list(/datum/skill/firearms, /datum/skill/civ_mech, /datum/skill/combat_mech, /datum/skill/construction, /datum/skill/surgery)
		var/mob/living/carbon/human/H = scanner.victim
		for(var/skill in H.mind.skills.active.skills)
			for(var/skill_type as anything in iq_skills)
				if(istype(skill, skill_type))
					iq += H.mind.skills.active.get_value(skill)
			for(var/skill_type as anything in mdi_skills)
				if(istype(skill, skill_type))
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

/obj/machinery/computer/skills_console/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return
	if(action == "change_color")
		var/new_color = params["color"]
		. = TRUE
	update_icon()

/obj/item/weapon/skill_cartridge
	name = "USP cartridge"
	desc = "Used in conjunction with the CMF apparatus to rapidly alter skills."
	icon = 'icons/obj/skills/cartridges.dmi'
	w_class = SIZE_TINY
	icon_state = "green"
	var/points
	var/list/compatible_species = list(HUMAN, TAJARAN, UNATHI)
	var/unpacked = FALSE

/obj/item/weapon/skill_cartridge/green
	name = "USP-5 cartridge"
	icon_state = "green"
	points = 5

/obj/item/weapon/skill_cartridge/blue
	name = "USP-7 cartridge"
	icon_state = "blue"
	points = 7

/obj/item/weapon/skill_cartridge/red
	name = "USP-10 cartridge"
	icon_state = "red"
	points = 10

/obj/item/weapon/skill_cartridge/purple
	name = "USP-15 cartridge"
	item_state = "card-id"
	icon_state = "purple"
	points = 15

/obj/item/weapon/skill_cartridge/ipc
	name = "CSP-15 cartridge"
	desc = "Used together with the CMF apparatus to rapidly alter skills. Specifically, this one can be used with the IPC."
	icon_state = "ipc"
	points = 15
	compatible_species= list(IPC)

/obj/item/weapon/implant/skill
	name = "CMF implant"
	var/datum/skillset/added_skillset


/obj/item/weapon/implant/skill/implanted(mob/source)
	if(!ishuman(source))
		return
	var/mob/living/carbon/human/H = source
	if(H.ismindprotect())
		H.adjustBrainLoss(25)
		return
	H.add_skills_buff(added_skillset)
	return 1

/obj/item/weapon/implant/skill/emp_act(severity)
	if (malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY

	if(severity == 1)
		if(prob(40))	//small chance of obvious meltdown
			meltdown()
	spawn(20)
		malfunction--

/obj/item/weapon/implant/skill/meltdown()
	..()
	if(!imp_in || !ishuman(imp_in))
		return
	var/mob/living/M = imp_in
	M.remove_skills_buff(added_skillset)
	M.adjustBrainLoss(100)

/obj/item/weapon/implant/skill/proc/removed()
	meltdown()
