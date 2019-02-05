/obj/machinery/door/poddoor
	name = "Podlock"
	desc = "Why it no open!!!"
	icon = 'icons/obj/doors/blast_door.dmi'
	icon_state = "pdoor1"
	icon_state_open  = "pdoor0"
	icon_state_close = "pdoor1"
	var/id = 1.0
	explosion_resistance = 25
	block_air_zones = 0
	door_open_sound  = 'sound/machines/blast_door.ogg'
	door_close_sound = 'sound/machines/blast_door.ogg'

/obj/machinery/door/poddoor/cargo
	icon = 'code/modules/locations/shuttles/cargo.dmi'

/obj/machinery/door/poddoor/atom_init()
	. = ..()
	poddoor_list += src
	if(density)
		layer = base_layer + PODDOOR_CLOSED_MOD

/obj/machinery/door/poddoor/Destroy()
	poddoor_list -= src
	return ..()

/obj/machinery/door/poddoor/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return 0

/obj/machinery/door/poddoor/attackby(obj/item/weapon/C, mob/user)
	add_fingerprint(user)
	if(istype(C, /obj/item/weapon/crowbar) || (istype(C, /obj/item/weapon/twohanded/fireaxe) && C:wielded))
		if(!hasPower())
			open(TRUE)

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
	playsound(src, door_open_sound, 100, 1)
	do_animate("opening")
	icon_state = icon_state_open
	sleep(3)
	explosion_resistance = 0
	layer = base_layer
	density = FALSE
	set_opacity(FALSE)
	update_nearby_tiles()

/obj/machinery/door/poddoor/do_close()
	if(hasPower())
		use_power(20)
	playsound(src, door_close_sound, 100, 1)
	do_animate("closing")
	icon_state = icon_state_close
	sleep(3)
	explosion_resistance = initial(explosion_resistance)
	layer = base_layer + PODDOOR_CLOSED_MOD
	density = TRUE
	set_opacity(TRUE)
	do_afterclose()
	update_nearby_tiles()

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("pdoorc0", src)
		if("closing")
			flick("pdoorc1", src)
	return
