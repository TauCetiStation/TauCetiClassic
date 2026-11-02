/obj/machinery/door/poddoor
	name = "Podlock"
	desc = "Why it no open!!!"
	icon = 'icons/obj/doors/blast_door.dmi'
	icon_state = "pdoor1"
	icon_state_open  = "pdoor0"
	icon_state_close = "pdoor1"
	layer = ABOVE_SAFEDOOR_LAYER
	base_layer = ABOVE_SAFEDOOR_LAYER
	layer_delta = SAFEDOOR_CLOSED_MOD_ABOVE_WINDOW
	var/id = 1.0
	explosive_resistance = 3
	block_air_zones = 0
	door_open_sound  = 'sound/machines/blast_door.ogg'
	door_close_sound = 'sound/machines/blast_door.ogg'

	resistance_flags = FULL_INDESTRUCTIBLE

/obj/machinery/door/poddoor/cargo
	icon = 'icons/locations/shuttles/cargo.dmi'

/obj/machinery/door/poddoor/atom_init()
	. = ..()
	poddoor_list += src
	if(density)
		layer = base_layer + layer_delta

/obj/machinery/door/poddoor/Destroy()
	poddoor_list -= src
	return ..()

/obj/machinery/door/poddoor/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return 0

/obj/machinery/door/poddoor/try_open(mob/living/user, obj/item/tool = null)
	if(!tool)
		add_fingerprint(user)
		return
	..()

/obj/machinery/door/poddoor/attackby(obj/item/I, mob/user)
	add_fingerprint(user)

	if(!hasPower())
		var/can_wedge = FALSE
		if(I.get_quality(QUALITY_PRYING))
			can_wedge = TRUE
		else if(istype(I, /obj/item/weapon/fireaxe))
			var/obj/item/weapon/fireaxe/Fire_Axe = I
			can_wedge = HAS_TRAIT(Fire_Axe, TRAIT_DOUBLE_WIELDED)

		if(can_wedge)
			open(TRUE)

	else if(I.get_quality(QUALITY_PULSING) && !density)
		var/obj/item/device/multitool/MT = I
		var/turf/turf = get_turf(src)
		if(!is_station_level(turf.z) && !is_mining_level(turf.z))
			to_chat(user, "<span class='warning'>This poddoor cannot be connected!</span>")
		else if(src in MT.doors_buffer)
			to_chat(user, "<span class='warning'>This poddoor is already in the buffer!</span>")
		else if(MT.doors_buffer.len >= MT.buffer_limit)
			to_chat(user, "<span class='warning'>The multitool's buffer is full!</span>")
		else
			MT.doors_buffer += src
			to_chat(user, "<span class='notice'>You add this poddoor to the buffer of your multitool.</span>")


/obj/machinery/door/poddoor/normal_open_checks()
	if(hasPower())
		return TRUE
	return FALSE

/obj/machinery/door/poddoor/normal_close_checks()
	if(hasPower())
		return TRUE
	return FALSE

/obj/machinery/door/poddoor/do_open()
	if(hasPower())
		use_power(20)
	playsound(src, door_open_sound, VOL_EFFECTS_MASTER)
	do_animate("opening")
	icon_state = icon_state_open
	SSdemo.mark_dirty(src)
	sleep(7)
	explosive_resistance = 0
	layer = base_layer
	density = FALSE
	set_opacity(FALSE)
	update_nearby_tiles()
	SSdemo.mark_dirty(src)

/obj/machinery/door/poddoor/do_close()
	if(hasPower())
		use_power(20)
	layer = base_layer + layer_delta
	playsound(src, door_close_sound, VOL_EFFECTS_MASTER)
	do_animate("closing")
	icon_state = icon_state_close
	SSdemo.mark_dirty(src)
	sleep(3)
	explosive_resistance = initial(explosive_resistance)
	density = TRUE
	set_opacity(TRUE)
	do_afterclose()
	update_nearby_tiles()
	SSdemo.mark_dirty(src)

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("pdoorc0", src)
		if("closing")
			flick("pdoorc1", src)
	return

/obj/machinery/door/poddoor/emag_act(mob/user)
	return FALSE

/obj/machinery/door/poddoor/mafia
	name = "Station Night Shutters"
	desc = "When it's time to sleep, the lights will go out. Remember - no one in space can hear you scream."
	id = "mafia"
	icon_state = "pdoor0"
	layer = BELOW_TURF_LAYER
	base_layer = BELOW_TURF_LAYER
	opacity = FALSE
	density = FALSE
