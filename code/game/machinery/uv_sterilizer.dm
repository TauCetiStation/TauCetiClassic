

/obj/machinery/uv_sterilizer
	name = "UV sterilizer"
	desc = "Uses some fancy Wey-Med supplied trickery to make dirty things clean, very-very clean."
	icon = 'icons/obj/medical.dmi'
	icon_state = "uv_sterilizer_idle"
	density = TRUE
	anchored = TRUE
	use_power = TRUE
	idle_power_usage = 40

	var/processing = FALSE
	var/efficency = 0 // How fast do we do the cleaning.
	var/shelves_available = 0 // How many shelves can we handle.

	var/obj/item/weapon/storage/internal/updating/shelves

/obj/machinery/uv_sterilizer/atom_init(mapload)
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/uv_sterilizer(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)

	RefreshParts()

	update_icon()

/obj/machinery/uv_sterilizer/Destroy()
	QDEL_NULL(shelves)
	return ..()

/obj/machinery/uv_sterilizer/RefreshParts()
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		efficency += M.rating

	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		shelves_available += M.rating

	shelves = new(src)
	shelves.set_slots(slots = (6 * shelves_available), slot_size = ITEM_SIZE_NORMAL)

/obj/machinery/uv_sterilizer/proc/clean()
	var/cleaned_amount = 0
	sleep(100 / efficency)

	for(var/obj/item/I in get_contents())
		I.clean_blood()
		I.cleanse_germ_level()
		cleaned_amount++

	use_power(500 * cleaned_amount / efficency)

/obj/machinery/uv_sterilizer/verb/start_cleaning()
	set name = "Start Cleaning Procedure"
	set desc = "Starts the cleaning procedure."
	set category = "Object"
	set src in oview(1)

	var/mob/living/user = usr
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	if(!user.IsAdvancedToolUser())
		return

	if(processing)
		return

	processing = TRUE
	visible_message("<span class='notice'>[src] boops, as it starts up.</span>")

	icon_state = "uv_sterilizer_processing"
	clean()
	sleep(15)
	icon_state = "uv_sterilizer_idle"

	visible_message("<span class='notice'>[src] beeps, as it stops.</span>")
	processing = FALSE

/obj/machinery/uv_sterilizer/attack_hand(mob/living/user)
	if(!processing && !user.incapacitated())
		user.SetNextMove(CLICK_CD_MELEE)
		shelves.open(user)
		..()

/obj/machinery/uv_sterilizer/MouseDrop_T(mob/living/target, mob/user)
	if(!processing && !user.incapacitated() && target == user)
		shelves.open(user)

/obj/machinery/uv_sterilizer/attackby(obj/item/O, mob/user)
	if(processing)
		return

	if(user.a_intent != I_HELP)
		if(exchange_parts(user, O))
			return

		if(default_deconstruction_crowbar(O))
			return

		if(default_unfasten_wrench(O))
			return

	if(shelves.can_be_inserted(O))
		shelves.handle_item_insertion(O)
		return

	..()
