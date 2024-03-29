/obj/machinery/power/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "coil"
	anchored = FALSE
	density = TRUE
	var/power_loss = 2
	var/input_power_multiplier = 1

/obj/machinery/power/tesla_coil/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/tesla_coil(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/power/tesla_coil/RefreshParts()
	..()

	var/power_multiplier = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		power_multiplier += C.rating
	input_power_multiplier = power_multiplier

/obj/machinery/power/tesla_coil/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "coil", "coil", W))
		return

	if(exchange_parts(user, W))
		return

	if(default_pry_open(W))
		return

	if(default_unfasten_wrench(user, W))
		if(!anchored)
			disconnect_from_network()
		else
			connect_to_network()
		return

	default_deconstruction_crowbar(W)

/obj/machinery/power/tesla_coil/tesla_act(power)
	being_shocked = 1
	var/power_produced = power / power_loss
	add_avail(power_produced*input_power_multiplier)
	flick("coilhit", src)
	playsound(src, 'sound/magic/LightningShock.ogg', VOL_EFFECTS_MISC, null, FALSE, null, 5)
	tesla_zap(src, 5, power_produced)
	VARSET_IN(src, being_shocked, FALSE, 10)

/obj/machinery/power/grounding_rod
	name = "Grounding Rod"
	desc = "Keep an area from being fried from Edison's Bane."
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "grounding_rod"
	anchored = FALSE
	density = TRUE

/obj/machinery/power/grounding_rod/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/grounding_rod(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/power/grounding_rod/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grounding_rod", "grounding_rod", W))
		return

	if(exchange_parts(user, W))
		return

	if(default_pry_open(W))
		return

	if(default_unfasten_wrench(user, W))
		return

	default_deconstruction_crowbar(W)

/obj/machinery/power/grounding_rod/tesla_act(power)
	flick("coil_shock_1", src)
