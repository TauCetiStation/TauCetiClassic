var/const/SAFETY_COOLDOWN = 100

/obj/item/weapon/circuitboard/recycler
	name = "Circuit board (Recycler)"
	board_type = "machine"
	build_path = /obj/machinery/recycler
	origin_tech = "engineering = 3"
	req_components = list(/obj/item/weapon/stock_parts/manipulator = 1)


/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine which is used to grind lumps of trash down; there are lights on the side of it."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/safety_mode = 0 // Temporality stops the machine if it detects a mob
	var/grinding = 0
	var/icon_name = "grinder-o"
	var/blood = 0
	var/eat_dir = WEST
	var/chance_to_recycle = 1

/obj/machinery/recycler/atom_init()
	// On us
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/recycler(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()
	update_icon()

/obj/machinery/recycler/RefreshParts()
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		chance_to_recycle = 25 * M.rating //% of materials salvaged
	chance_to_recycle = min(100, chance_to_recycle)

/obj/machinery/recycler/examine(mob/user)
	..()
	to_chat(user, "The power light is [(stat & NOPOWER) ? "off" : "on"].")
	to_chat(user, "The safety-mode light is [safety_mode ? "on" : "off"].")
	to_chat(user, "The safety-sensors status light is [emagged ? "off" : "on"].")

/obj/machinery/recycler/power_change()
	..()
	update_icon()


/obj/machinery/recycler/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		return

	if(exchange_parts(user, I))
		return

	if(default_pry_open(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	default_deconstruction_crowbar(I)
	..()
	return

/obj/machinery/recycler/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = 1
	if(safety_mode)
		safety_mode = 0
		update_icon()
	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='notice'>You use the cryptographic sequencer on the [src.name].</span>")
	return TRUE

/obj/machinery/recycler/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = 0
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end

// This is purely for admin possession !FUN!.
/obj/machinery/recycler/Bump(atom/movable/AM)
	..()
	if(AM)
		Bumped(AM)


/obj/machinery/recycler/Bumped(atom/movable/AM)

	if(stat & (BROKEN|NOPOWER))
		return
	if(!anchored)
		return
	if(safety_mode)
		return

	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		if(isliving(AM))
			if(emagged)
				eat(AM)
			else
				stop(AM)
		else if(istype(AM, /obj/item))
			recycle(AM)
		else // Can't recycle
			playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			AM.forceMove(src.loc)

/obj/machinery/recycler/proc/recycle(obj/item/I, sound = 1)
	I.forceMove(src.loc)
	if(!istype(I))
		return

	if(sound)
		playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
	var/chance_mod = 1
	if(!istype(I, /obj/item/weapon/scrap_lump))
		chance_mod = 5
	if(prob(chance_to_recycle / chance_mod))
		new /obj/item/stack/sheet/refined_scrap(loc)
	qdel(I)


/obj/machinery/recycler/proc/stop(mob/living/L)
	set waitfor = 0
	playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	safety_mode = 1
	update_icon()
	L.forceMove(src.loc)

	sleep(SAFETY_COOLDOWN)
	playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	safety_mode = 0
	update_icon()

/obj/machinery/recycler/proc/eat(mob/living/L)

	L.forceMove(src.loc)

	if(issilicon(L))
		playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
	else
		L.emote("scream")

	var/gib = 1
	// By default, the emagged recycler will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = 0
		if(L.stat == CONSCIOUS)
			L.emote("scream")
		add_blood(L)

	if(!blood && !issilicon(L))
		blood = 1
		update_icon()

	// Remove and recycle the equipped items.
	for(var/obj/item/I in L.get_equipped_items())
		if(L.unEquip(I))
			recycle(I, 0)

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)
	L.anchored = 1
	// For admin fun, var edit emagged to 2.
	if(gib || emagged == 2)
		L.gib()
		playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
	else if(emagged == 1)
		for(var/i = 1 to 3)
			sleep(10)
			L.adjustBruteLoss(80)
	L.anchored = 0
