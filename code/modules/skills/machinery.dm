/obj/item/weapon/circuitboard/clonescanner
	name = "Circuit board (XXX Scanner)"
	build_path = /obj/machinery/skill_scanner
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 2)



/obj/machinery/skill_scanner
	name = "XXX modifier"
	desc = "It scans DNA structures."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "scanner"
	density = TRUE
	anchored = TRUE
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 40000
	var/damage_coeff
	var/scan_level
	var/precision_coeff
	var/locked = 0
	var/open = 0

/obj/machinery/dna_scannernew/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/clonescanner(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()



/obj/item/weapon/circuitboard/skills_console
	name = "Circuit board (XXX Console)"
	build_path = /obj/machinery/computer/skills_console
	origin_tech = "programming=2;biotech=2"

/obj/machinery/computer/skills_console
	name = "XXX Modifier Access Console"
	desc = "Used for scanning and modyfing XXX of user."
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
	state_broken_preset = "crewb"
	state_nopower_preset = "crew0"
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


/obj/machinery/computer/scan_consolenew/attackby(obj/item/I, mob/user)
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


/obj/item/weapon/skill_cartridge
	name = "XXX cartridge"
	desc = "Emergency use only."
	icon = 'icons/obj/items.dmi'
	w_class = SIZE_TINY
	item_state = "card-id"
	icon_state = "datadisk0"
	var/points
	var/list/compatible_species = list(HUMAN, TAJARAN, UNATHI)

/obj/item/weapon/skill_cartridge/green
	name = "XXX cartridge"
	item_state = "card-id"
	icon_state = "datadisk0"
	points = 5

/obj/item/weapon/skill_cartridge/red
	name = "XXX cartridge"
	item_state = "card-id"
	icon_state = "datadisk0"
	points = 10

/obj/item/weapon/skill_cartridge/purple
	name = "XXX cartridge"
	item_state = "card-id"
	icon_state = "datadisk0"
	points = 15

/obj/item/weapon/skill_cartridge/ipc
	name = "XXX cartridge"
	item_state = "card-id"
	icon_state = "datadisk0"
	points = 15
	compatible_species= list(IPC)

/obj/item/weapon/implant/skill
	name = "XXX implant"
	desc = "Used to change the XXX of user."
	var/datum/skillset/added_skillset


/obj/item/weapon/implant/skill/implanted(mob/source)
	if(!ishuman(source))
		return
	START_PROCESSING(SSobj, src)
	return 1


/obj/item/weapon/implant/death_alarm/process()
	if (!implanted) return
	var/mob/M = imp_in
	M.help// TODO finish



/obj/item/weapon/implant/death_alarm/emp_act(severity)
	if (malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY

	activate("emp")	//let's shout that this dude is dead
	if(severity == 1)
		if(prob(40))	//small chance of obvious meltdown
			meltdown()
		else if (prob(60))	//but more likely it will just quietly die
			malfunction = MALFUNCTION_PERMANENT
		STOP_PROCESSING(SSobj, src)

	spawn(20)
		malfunction--
