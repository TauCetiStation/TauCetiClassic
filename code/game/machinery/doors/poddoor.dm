#define BLASTDOOR_LIGHT_POWER 2
#define BLASTDOOR_LIGHT_RANGE 1.5


/obj/machinery/door/poddoor
	name = "Podlock"
	var/base_name = "bdoor"
	desc = "Why it no open!!!"
	icon = 'icons/obj/doors/blast_door.dmi'
	icon_state = "bdoor_closed"
	icon_state_open  = "bdoor_opend"
	icon_state_close = "bdoor_closed"
	layer = ABOVE_SAFEDOOR_LAYER
	base_layer = ABOVE_SAFEDOOR_LAYER
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
		layer = base_layer + SAFEDOOR_CLOSED_MOD_ABOVE_WINDOW

	setStatusOverlay()

/obj/machinery/door/poddoor/update_icon()
	..()
	if(density)
		layer = base_layer + SAFEDOOR_CLOSED_MOD_ABOVE_WINDOW
	else
		layer = base_layer

/obj/machinery/door/poddoor/Destroy()
	poddoor_list -= src
	return ..()

/obj/machinery/door/poddoor/power_change()
	..()
	if(!hasPower())
		cut_overlays()
		set_light(0)

/obj/machinery/door/poddoor/proc/setStatusOverlay()
	cut_overlays()
	if(!density)
		if(hasPower() && ("lights_opend" in icon_states(icon)))
			var/image/status_overlay = image(icon_state = "lights_opend")
			set_light(BLASTDOOR_LIGHT_RANGE, BLASTDOOR_LIGHT_POWER, COLOR_GREEN)
			status_overlay.plane = LIGHTING_LAMPS_PLANE
			add_overlay(status_overlay)
		else
			set_light(0)
	else
		if("lights_closed" in icon_states(icon))
			var/image/status_overlay = image(icon_state = "lights_closed")
			set_light(BLASTDOOR_LIGHT_RANGE, BLASTDOOR_LIGHT_POWER, COLOR_RED)
			status_overlay.plane = LIGHTING_LAMPS_PLANE
			add_overlay(status_overlay)
		else
			set_light(0)


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

/obj/machinery/door/poddoor/attackby(obj/item/weapon/C, mob/user)
	add_fingerprint(user)

	if(!hasPower())
		if(isprying(C))
			open(TRUE)

	else if(ispulsing(C) && !density)
		var/obj/item/device/multitool/M = C
		var/turf/turf = get_turf(src)
		if(!is_station_level(turf.z) && !is_mining_level(turf.z))
			to_chat(user, "<span class='warning'>This poddoor cannot be connected!</span>")
		else if(src in M.doors_buffer)
			to_chat(user, "<span class='warning'>This poddoor is already in the buffer!</span>")
		else if(M.doors_buffer.len >= M.buffer_limit)
			to_chat(user, "<span class='warning'>The multitool's buffer is full!</span>")
		else
			M.doors_buffer += src
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
	density = FALSE
	setStatusOverlay()
	updateStatus()

/obj/machinery/door/poddoor/do_close()
	if(hasPower())
		use_power(20)
	playsound(src, door_close_sound, VOL_EFFECTS_MASTER)
	do_animate("closing")
	density = TRUE
	setStatusOverlay()
	updateStatus()
	do_afterclose()

/obj/machinery/door/poddoor/proc/updateStatus()
	sleep(5)
	if(!density)
		explosive_resistance = 0
		set_opacity(FALSE)
	else
		explosive_resistance = initial(explosive_resistance)
		set_opacity(TRUE)
	update_nearby_tiles()
	SSdemo.mark_dirty(src)
	update_icon()

/obj/machinery/door/poddoor/do_animate(animation)
	var/image/animate = image(icon_state = "[base_name]_[animation]")
	if("lights_[animation]" in icon_states(icon))
		var/image/I = image(icon_state = "lights_[animation]")
		I.plane = LIGHTING_LAMPS_PLANE
		set_light(BLASTDOOR_LIGHT_RANGE, BLASTDOOR_LIGHT_POWER, COLOR_RED)
		add_overlay(I)
	flick(animate, src)
	return

/obj/machinery/door/poddoor/mafia
	name = "Station Night Shutters"
	desc = "When it's time to sleep, the lights will go out. Remember - no one in space can hear you scream."
	id = "mafia"
	icon_state = "bdoor_opened"
	layer = BELOW_TURF_LAYER
	base_layer = BELOW_TURF_LAYER
	opacity = FALSE
	density = FALSE
