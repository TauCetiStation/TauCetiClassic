/obj/item/weapon/circuitboard/skill_scanner
	name = "Circuit board (CMF modifier)"
	build_path = /obj/machinery/skill_scanner
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/skills_console
	name = "Circuit board (CMF Console)"
	build_path = /obj/machinery/computer/skills_console
	origin_tech = "programming=2;biotech=2"

/obj/machinery/skill_scanner
	name = "CMF modifier"
	desc = "Used to scan and change the cognitive and motor functions of living beings."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "scanner"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 10000
	var/damage_coeff
	var/scan_level
	var/precision_coeff
	var/locked = 0
	var/open = 0

/obj/machinery/dna_scannernew/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/skills_console(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()



/obj/machinery/computer/skills_console
	name = "CMF Modifier Access Console"
	desc = "Used for scanning and modyfing XXX of connected patient."
	icon = 'icons/obj/computer.dmi'
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
	required_skills = list(/datum/skill/command = SKILL_LEVEL_NOVICE, /datum/skill/medical = SKILL_LEVEL_NOVICE, /datum/skill/research = SKILL_LEVEL_NOVICE)


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
	data["cartridge"] = cartridge.name

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
	icon = 'icons/obj/items.dmi'
	w_class = SIZE_TINY
	item_state = "card-id"
	icon_state = "datadisk0"
	var/points
	var/list/compatible_species = list(HUMAN, TAJARAN, UNATHI)

/obj/item/weapon/skill_cartridge/green
	name = "USP-5 cartridge"
	item_state = "card-id"
	icon_state = "datadisk0"
	points = 5

/obj/item/weapon/skill_cartridge/blue
	name = "USP-7 cartridge"
	item_state = "card-id"
	icon_state = "datadisk0"
	points = 7

/obj/item/weapon/skill_cartridge/red
	name = "USP-10 cartridge"
	item_state = "card-id"
	icon_state = "datadisk0"
	points = 10

/obj/item/weapon/skill_cartridge/purple
	name = "USP-15 cartridge"
	item_state = "card-id"
	icon_state = "datadisk0"
	points = 15

/obj/item/weapon/skill_cartridge/ipc
	name = "CSP-15 cartridge"
	desc = "Used together with the CMF apparatus to rapidly alter skills. Specifically, this one can be used with the IPC."
	item_state = "card-id"
	icon_state = "datadisk0"
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
