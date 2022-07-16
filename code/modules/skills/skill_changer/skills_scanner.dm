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