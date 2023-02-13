/obj/machinery/optable/skill_scanner
	name = "CMF manipulation table"
	desc = "Used to scan and change the cognitive and motor functions of living beings. Also a very comfortable table to lie on."
	icon = 'icons/obj/skills/skills_machinery.dmi'
	icon_state = "table_skill_idle"
	icon_state_active = "table_skill_active"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 10000
	var/obj/machinery/computer/skills_console/console = null
	var/obj/item/weapon/skill_cartridge/cartridge = null


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
	if(istype(W, /obj/item/weapon/skill_cartridge))
		if(!console)
			to_chat(user, "<span class='notice'>You need to link [src] to the CMF Modifier Access Console first.</span>")
			return FALSE
		if(!cartridge)
			user.drop_from_inventory(W, src)
			cartridge = W
			to_chat(user, "<span class='notice'>You insert [W].</span>")
		else
			to_chat(user, "<span class='notice'>There is already [cartridge] inserted.</span>")

		return FALSE
	if(victim)
		return
	if(default_deconstruction_screwdriver(user, "table_skill_open", initial(icon_state), W))
		update_icon()
		return
	if(exchange_parts(user, W))
		return
	if(panel_open)
		if(ispulsing(W))
			var/obj/item/device/multitool/M = W
			M.buffer = src
			to_chat(user, "<span class='notice'>You save the data in the [W.name]'s buffer.</span>")
	default_deconstruction_crowbar(W)

/obj/machinery/optable/skill_scanner/proc/eject_cartridge()
	if(cartridge && !cartridge.unpacked)
		cartridge.forceMove(loc)
		cartridge = null
		return TRUE
	return FALSE

/obj/machinery/optable/skill_scanner/proc/inject_victim()
	var/mob/living/carbon/human/H = victim
	for(var/obj/item/weapon/implant/skill/S in H)
		if(S.implanted)
			S.meltdown()
	var/obj/item/weapon/implant/skill/implant = new(H)
	implant.set_skills(cartridge.selected_buffs, cartridge.compatible_species)
	implant.inject(H, BP_HEAD)
	QDEL_NULL(cartridge)

/obj/machinery/optable/skill_scanner/proc/abort_injection()
	if(cartridge && cartridge.unpacked)
		qdel(cartridge)
		cartridge = null

/obj/machinery/optable/skill_scanner/take_victim(mob/living/carbon/C, mob/living/carbon/user)
	. = ..()
	if(!victim || !console)
		return
	console.updateDialog()

/obj/machinery/optable/skill_scanner/process()
	. = ..()
	if(!victim && panel_open)
		icon_state = "table_skill_open"

/obj/machinery/optable/skill_scanner/deconstruction()
	. = ..()
	if(cartridge && !cartridge.unpacked)
		cartridge.forceMove(loc)
		cartridge = null
	if(console)
		console.scanner = null
