/obj/mecha/combat/gygax
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "Gygax"
	icon_state = "gygax"
	initial_icon = "gygax"
	step_in = 3
	dir_in = 1 //Facing North.
	health = 300
	deflect_chance = 15
	damage_absorption = list(BRUTE=0.75,BURN=1,BULLET=0.8,LASER=0.7,ENERGY=0.85,BOMB=1)
	max_temperature = 25000
	infra_luminosity = 6
	var/overload_coeff = 2
	wreckage = /obj/effect/decal/mecha_wreckage/gygax
	internal_damage_threshold = 35
	max_equip = 3
	var/overload = FALSE

	var/datum/action/innate/mecha/mech_overload_mode/overload_action = new

/obj/mecha/combat/gygax/Destroy()
	QDEL_NULL(overload_action)
	return ..()

/obj/mecha/combat/gygax/atom_init()
	. = ..()
	AddComponent(/datum/component/examine_research, DEFAULT_SCIENCE_CONSOLE_ID, 3000, list(DIAGNOSTIC_EXTRA_CHECK, VIEW_EXTRA_CHECK))

/obj/mecha/combat/gygax/GrantActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Grant(user, src)

/obj/mecha/combat/gygax/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Remove(user)

/obj/mecha/combat/gygax/security/atom_init() //for aspect
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/repair_droid(src)
	ME.attach(src)

/obj/mecha/combat/gygax/ultra
	desc = "A highly improved version of Gygax exosuit."
	name = "Gygax Ultra"
	icon_state = "ultra"
	initial_icon = "ultra"
	health = 350
	deflect_chance = 20
	damage_absorption = list(BRUTE=0.65,BURN=0.9,BULLET=0.7,LASER=0.6,ENERGY=0.75,BOMB=0.9)
	max_temperature = 30000
	wreckage = /obj/effect/decal/mecha_wreckage/gygax/ultra
	animated = 1

/obj/mecha/combat/gygax/ultra/atom_init()
	. = ..()
	AddComponent(/datum/component/examine_research, DEFAULT_SCIENCE_CONSOLE_ID, 4600, list(DIAGNOSTIC_EXTRA_CHECK, VIEW_EXTRA_CHECK))

/obj/mecha/combat/gygax/ultra/security/atom_init() //for aspect
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/repair_droid(src)
	ME.attach(src)

/obj/mecha/combat/gygax/dark
	desc = "A lightweight exosuit used by Nanotrasen Death Squads. A significantly upgraded Gygax security mech."
	name = "Dark Gygax"
	icon_state = "darkgygax"
	initial_icon = "darkgygax"
	health = 400
	deflect_chance = 25
	damage_absorption = list(BRUTE=0.6,BURN=0.8,BULLET=0.6,LASER=0.5,ENERGY=0.65,BOMB=0.8)
	max_temperature = 45000
	overload_coeff = 1
	wreckage = /obj/effect/decal/mecha_wreckage/gygax/dark
	max_equip = 4
	step_energy_drain = 5

/obj/mecha/combat/gygax/dark/atom_init()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	AddComponent(/datum/component/examine_research, DEFAULT_SCIENCE_CONSOLE_ID, 4000, list(DIAGNOSTIC_EXTRA_CHECK, VIEW_EXTRA_CHECK))

/obj/mecha/combat/gygax/dark/add_cell(obj/item/weapon/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 30000
	cell.maxcharge = 30000


/obj/mecha/combat/gygax/proc/overload()
	if(usr != src.occupant)
		return
	if(!check_fumbling("<span class='notice'>You fumble around, figuring out how to [overload? "en" : "dis"]able leg actuators overload.</span>"))
		return
	if(overload)
		overload = 0
		step_in = initial(step_in)
		step_energy_drain = initial(step_energy_drain)
		occupant_message("<font color='blue'>You disable leg actuators overload.</font>")
		if(animated)
			flick("ultra-gofasta-off",src)
			reset_icon()
	else
		overload = 1
		step_in = min(1, round(step_in/2))
		step_energy_drain = step_energy_drain*overload_coeff
		occupant_message("<font color='red'>You enable leg actuators overload.</font>")
		if(animated)
			flick("ultra-gofasta-on",src)
			icon_state = "ultra-gofasta"
	log_message("Toggled leg actuators overload.")
	return

/obj/mecha/combat/gygax/dyndomove(direction)
	if(!..()) return
	if(overload)
		health--
		if(health < initial(health) - initial(health)/3)
			overload = 0
			step_in = initial(step_in)
			step_energy_drain = initial(step_energy_drain)
			occupant_message("<font color='red'>Leg actuators damage threshold exceded. Disabling overload.</font>")
			if(animated)
				flick("ultra-gofasta-off",src)
				reset_icon()
	return


/obj/mecha/combat/gygax/get_stats_part()
	var/output = ..()
	output += "<b>Leg actuators overload: [overload?"on":"off"]</b>"
	return output

/obj/mecha/combat/gygax/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_leg_overload=1'>Toggle leg actuators overload</a>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/combat/gygax/Topic(href, href_list)
	..()
	if (href_list["toggle_leg_overload"])
		overload()
	return
