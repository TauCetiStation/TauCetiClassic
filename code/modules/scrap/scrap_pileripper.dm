/obj/item/weapon/circuitboard/pile_ripper
	name = "Circuit board (Pile Ripper)"
	board_type = "machine"
	build_path = /obj/machinery/pile_ripper
	origin_tech = "engineering = 3"
	req_components = list(/obj/item/weapon/stock_parts/manipulator = 1)

/obj/machinery/pile_ripper
	name = "pile ripper"
	desc = "This machine rips everything in front of it apart."
	icon = 'icons/obj/structures/scrap/recycling.dmi'
	icon_state = "grinder-b0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 300

	var/safety_mode = 0 // Temporality stops the machine if it detects a mob
	var/icon_name = "grinder-b"
	var/blood = 0
	var/rating = 1
	var/last_ripped = 0

/obj/machinery/pile_ripper/atom_init()
	// On us
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/pile_ripper(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()
	update_icon()

/obj/machinery/pile_ripper/process()
	if(last_ripped >= world.time)
		return
	last_ripped = world.time
	if(safety_mode)
		playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		safety_mode = 0
		update_icon()
	var/turf/ripped_turf = get_turf(get_step(src, 8))
	for(var/mob/living/poor_soul in ripped_turf)
		if(emagged || prob(25))
			eat(poor_soul)
		else
			stop(poor_soul)
	var/count = 0
	for(var/obj/ripped_item in ripped_turf)
		if(count >= rating)
			break
		if(istype(ripped_item, /obj/structure/scrap))
			var/obj/structure/scrap/pile = ripped_item
			while(pile.dig_out_lump(loc, 1))
				if(prob(20))
					break
			count++
		else if(istype(ripped_item, /obj/item))
			ripped_item.forceMove(src.loc)
			if(prob(20))
				qdel(ripped_item)
		else if(istype(ripped_item, /obj/structure/scrap_cube))
			var/obj/structure/scrap_cube/cube = ripped_item
			cube.make_pile()

/obj/machinery/pile_ripper/RefreshParts()
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		rating = M.rating

/obj/machinery/pile_ripper/examine(mob/user)
	..()
	to_chat(user, "The power light is [(stat & NOPOWER) ? "off" : "on"].")
	to_chat(user, "The safety-mode light is [safety_mode ? "on" : "off"].")
	to_chat(user, "The safety-sensors status light is [emagged ? "off" : "on"].")

/obj/machinery/pile_ripper/power_change()
	..()
	update_icon()

/obj/machinery/pile_ripper/proc/stop(mob/living/L)
	playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	safety_mode = 1
	update_icon()
	L.forceMove(src.loc)

	last_ripped += SAFETY_COOLDOWN
	update_icon()

/obj/machinery/pile_ripper/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)

	if(default_deconstruction_screwdriver(user, "grinder-bOpen", "grinder-b0", I))
		return

	if(exchange_parts(user, I))
		return

	if(default_pry_open(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	else
		default_deconstruction_crowbar(I)

/obj/machinery/pile_ripper/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = 1
	if(safety_mode)
		safety_mode = 0
		update_icon()
	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='notice'>You use the cryptographic sequencer on the [src.name].</span>")
	return TRUE

/obj/machinery/pile_ripper/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = 0
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end


/obj/machinery/pile_ripper/proc/eat(mob/living/L)
	if(issilicon(L))
		playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
	else
		playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)

	var/gib = 1
	// By default, the emagged pile_ripper will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = 0
		if(L.stat == CONSCIOUS)
			L.emote("scream")
		add_blood(L)
	if(!blood && !issilicon(L))
		blood = 1
		update_icon()
	if(gib)
		L.gib()

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)
	// Strip some clothing

	for(var/obj/item/I in L.get_equipped_items())
		if(L.unEquip(I))
			I.forceMove(loc)
			if(prob(15)) //saved by ripped cloth
				return

	// Start shredding meat

	var/slab_name = L.name
	var/slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat

	if(istype(L,/mob/living/carbon/human))
		slab_name = L.real_name
		slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	else if(istype(L, /mob/living/carbon/monkey))
		slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	var/obj/item/weapon/reagent_containers/food/snacks/meat/new_meat = new slab_type(get_turf(get_step(src, 4)))
	new_meat.name = "[slab_name] [new_meat.name]"

	new_meat.reagents.add_reagent("nutriment", 10)
	L.nutrition -= 100
	if(L.nutrition > 0)
		L.adjustBruteLoss(45)
	else
		L.gib()

