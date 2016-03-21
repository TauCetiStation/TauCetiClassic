/obj/item/weapon/circuitboard/pile_ripper
	name = "Circuit board (Pile Ripper)"
	board_type = "machine"
	build_path = "/obj/machinery/recycler"
	origin_tech = "engineering = 3"
	frame_desc = "Requires 1 Manipulator"
	req_components = list("/obj/item/weapon/stock_parts/manipulator" = 1)

/obj/machinery/pile_ripper
	name = "pile ripper"
	desc = "This machine rips everything in front of it apart."
	icon = 'icons/obj/structures/scrap/recycling.dmi'
	icon_state = "grinder-b0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 100
	active_power_usage = 600

	var/safety_mode = 0 // Temporality stops the machine if it detects a mob
	var/active = 0
	var/icon_name = "grinder-b"
	var/blood = 0
	var/cooldown = 30
	var/last_ripped = 0
	var/turf/ripped_turf

/obj/machinery/pile_ripper/New()
	// On us
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/pile_ripper(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()
	update_icon()

/obj/machinery/pile_ripper/process()
	if(!active || !ripped_turf)
		update_use_power(1)
		return

	if((last_ripped + cooldown) >= world.time)
		return
	last_ripped = world.time + cooldown
	for(var/obj/ripped_item in ripped_turf)
		if(istype(ripped_item, /obj/structure/scrap))
			var/obj/structure/scrap/pile = ripped_item
			pile.dig_out_lump(loc)
		else if(istype(ripped_item, /obj/item))
			ripped_item.loc = loc
			ripped_item.throw_at(get_edge_target_turf(src,4),rand(1,5),15)
	for(var/mob/living/poor_soul in ripped_turf)
		if(emagged)
			spawn()
				eat(poor_soul)
		else
			stop(poor_soul)

/obj/machinery/pile_ripper/attack_hand(mob/user as mob)
	if(..())
		return
	if(active)
		active = 0
	else
		active = 1
		update_use_power(2)
		ripped_turf = get_turf(get_step(src,8))
	update_icon()

/obj/machinery/pile_ripper/RefreshParts()
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		cooldown = 30 / M.rating

/obj/machinery/pile_ripper/examine(mob/user)
	..()
	user << "The power light is [(stat & NOPOWER) ? "off" : "on"]."
	user << "The safety-mode light is [safety_mode ? "on" : "off"]."
	user << "The safety-sensors status light is [emagged ? "off" : "on"]."

/obj/machinery/pile_ripper/power_change()
	..()
	update_icon()

/obj/machinery/pile_ripper/proc/stop(mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = 1
	active = 0
	update_use_power(1)
	update_icon()
	L.loc = src.loc

	spawn(SAFETY_COOLDOWN)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		safety_mode = 0
		update_icon()

/obj/machinery/pile_ripper/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/weapon/card/emag))
		emag_act(user)
	if(default_deconstruction_screwdriver(user, "grinder-bOpen", "grinder-b0", I))
		active = 0
		update_use_power(0)
		return

	if(exchange_parts(user, I))
		return

	if(default_pry_open(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	default_deconstruction_crowbar(I)
	..()
	add_fingerprint(user)
	return

/obj/machinery/pile_ripper/proc/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(safety_mode)
			safety_mode = 0
			update_icon()
		playsound(src.loc, "sparks", 75, 1, -1)
		user << "<span class='notice'>You use the cryptographic sequencer on the [src.name].</span>"

/obj/machinery/pile_ripper/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = 0
	if(!is_powered)
		active = 0
	icon_state = icon_name + "[active]" + "[(blood ? "bld" : "")]" // add the blood tag at the end


/obj/machinery/pile_ripper/proc/eat(mob/living/L)
	L.loc = src.loc
	if(issilicon(L))
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)

	var/gib = 1
	// By default, the emagged pile_ripper will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = 0
		if(L.stat == CONSCIOUS)
			L.say("응응응응읽촹!")
		add_blood(L)

	if(!blood && !issilicon(L))
		blood = 1
		update_icon()


	if(gib)
		L.gib()

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)
	L.anchored = 1
	var/rip_times = 3
	var/slab_name = L.name
	var/slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat

	if(istype(L,/mob/living/carbon/human))
		slab_name = L.real_name
		slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	else if(istype(L, /mob/living/carbon/monkey))
		slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	for(var/i = 1 to rip_times)
		sleep(10)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/new_meat = new slab_type(get_turf(get_step(src, 4)))
		new_meat.name = "[slab_name] [new_meat.name]"
		new_meat.reagents.add_reagent("nutriment", L.nutrition / 15)
		L.adjustBruteLoss(45)
	for(var/obj/item/I in L.get_equipped_items())
		if(L.unEquip(I))
			if(prob(30))
				qdel(I)
			else
				I.loc = loc // Drop it onto the turf for throwing.
				I.throw_at(get_edge_target_turf(src,4),rand(1,5),15)
	L.gib()

/obj/item/weapon/paper/pile_ripper
	name = "paper - 'garbage duty instructions'"
	info = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect the said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then deliver these minerals to cargo or engineering. You are our last hope for a clean station, do not screw this up!"
