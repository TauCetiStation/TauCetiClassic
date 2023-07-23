//TRAIN STATION 13

//This module is all about doors.

//Like a dog without a bone, an actor out on loan, riders on the storm! - The DOORS

/obj/structure/mineral_door/wood/single
	name = "wooden door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "wood"

/obj/structure/mineral_door/wood/double
	name = "wooden double door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "wooddouble"

/obj/structure/mineral_door/wood/doubledirty
	name = "dirty wooden double door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "wooddoubledirty"

/obj/structure/mineral_door/transparent/wood
	name = "wooden door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "woodglass"
	sheetType = /obj/item/stack/sheet/wood
	operating_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/mineral_door/transparent/wooddouble
	name = "wooden double door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "wooddoubleglass"
	sheetType = /obj/item/stack/sheet/wood
	operating_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/mineral_door/transparent/metal
	name = "metal double door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "metaldoubleglass"
	max_integrity = 300
	sheetType = /obj/item/stack/sheet/metal

/obj/structure/mineral_door/transparent/automatic
	name = "semi-automatic door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "locomotiveglass"
	max_integrity = 300
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/effects/turret/open.ogg'

/obj/structure/mineral_door/transparent/traindouble
	name = "metal sliding door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "traindouble"
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/machines/shutter_open.ogg'

/obj/structure/mineral_door/transparent/trainglass
	name = "metal door with doorlight"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "trainglass"
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/mineral_door/metal/automatic
	name = "semi-automatic door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "locomotive"
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/effects/turret/open.ogg'

/obj/structure/mineral_door/metal/reinforced
	name = "blast door"
	desc = "This door is as strong, as it looks."
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "blastdoor"
	max_integrity = 1000
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/machines/firedoor_open.ogg'

/obj/structure/mineral_door/metal/coupe
	name = "metal sliding door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "coupe"
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/machines/firedoor_open.ogg'

/obj/structure/mineral_door/metal/train
	name = "metal door"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "train"
	sheetType = /obj/item/stack/sheet/metal
	operating_sound = 'sound/effects/doorcreaky.ogg'

//GATES

/obj/machinery/door/poddoor/gateleft
	name = "gate"
	icon = 'trainstation13/icons/gateleft.dmi'

/obj/machinery/door/poddoor/gateright
	name = "gate"
	icon = 'trainstation13/icons/gateright.dmi'

//AUTOMATIC

ADD_TO_GLOBAL_LIST(/obj/machinery/door/traindoor, traindoor_list)

var/global/list/traindoor_list = list()

/obj/machinery/door/traindoor
	name = "automatic doors"
	desc = "Why it no open!!!"
	icon = 'trainstation13/icons/traindoors.dmi'
	icon_state = "automatic"
	icon_state_open  = "automatic_open"
	icon_state_close = "automatic"
	opacity = FALSE
	layer = ABOVE_SAFEDOOR_LAYER
	base_layer = ABOVE_SAFEDOOR_LAYER
	var/id = 1.0
	explosion_resistance = 25
	block_air_zones = 0
	door_open_sound  = 'trainstation13/sound/machines/autodoor_open.ogg'
	door_close_sound = 'trainstation13/sound/machines/autodoor_close.ogg'

	resistance_flags = FULL_INDESTRUCTIBLE

/obj/machinery/door/traindoor/atom_init()
	. = ..()
	traindoor_list += src
	if(density)
		layer = base_layer + SAFEDOOR_CLOSED_MOD_ABOVE_WINDOW

/obj/machinery/door/traindoor/Destroy()
	traindoor_list -= src
	return ..()

/obj/machinery/door/traindoor/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return 0

/obj/machinery/door/traindoor/try_open(mob/living/user, obj/item/tool = null)
	if(!tool)
		add_fingerprint(user)
		return
	..()

/obj/machinery/door/traindoor/attackby(obj/item/weapon/C, mob/user)
	add_fingerprint(user)

	if(!hasPower())
		var/can_wedge = FALSE
		if(isprying(C))
			can_wedge = TRUE
		else if(istype(C, /obj/item/weapon/fireaxe))
			var/obj/item/weapon/fireaxe/F = C
			can_wedge = HAS_TRAIT(F, TRAIT_DOUBLE_WIELDED)

		if(can_wedge)
			open(TRUE)

	else if(ispulsing(C) && !density)
		var/obj/item/device/multitool/M = C
		var/turf/turf = get_turf(src)
		if(!is_station_level(turf.z) && !is_mining_level(turf.z))
			to_chat(user, "<span class='warning'>This automatic door cannot be connected!</span>")
		else if(src in M.doors_buffer)
			to_chat(user, "<span class='warning'>This automatic door is already in the buffer!</span>")
		else if(M.doors_buffer.len >= M.buffer_limit)
			to_chat(user, "<span class='warning'>The multitool's buffer is full!</span>")
		else
			M.doors_buffer += src
			to_chat(user, "<span class='notice'>You add this automatic door to the buffer of your multitool.</span>")


/obj/machinery/door/traindoor/normal_open_checks()
	if(hasPower())
		return TRUE
	return FALSE

/obj/machinery/door/traindoor/normal_close_checks()
	if(hasPower())
		return TRUE
	return FALSE

/obj/machinery/door/traindoor/do_open()
	if(hasPower())
		use_power(20)
	playsound(src, door_open_sound, VOL_EFFECTS_MASTER)
	do_animate("opening")
	icon_state = icon_state_open
	SSdemo.mark_dirty(src)
	sleep(3)
	explosion_resistance = 0
	layer = 3.3
	density = FALSE
	set_opacity(FALSE)
	update_nearby_tiles()
	SSdemo.mark_dirty(src)

/obj/machinery/door/traindoor/do_close()
	if(hasPower())
		use_power(20)
	playsound(src, door_close_sound, VOL_EFFECTS_MASTER)
	do_animate("closing")
	icon_state = icon_state_close
	SSdemo.mark_dirty(src)
	sleep(3)
	explosion_resistance = initial(explosion_resistance)
	layer = 3.3 + SAFEDOOR_CLOSED_MOD_ABOVE_WINDOW
	density = TRUE
	set_opacity(FALSE)
	do_afterclose()
	update_nearby_tiles()
	SSdemo.mark_dirty(src)

/obj/machinery/door/traindoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("automatic_opening", src)
		if("closing")
			flick("automatic_closing", src)
	return

/obj/machinery/door/traindoor/display
	name = "automatic doors display"
	desc = "A display device that accurately shows status of automatic doors."
	icon = 'trainstation13/icons/trainmachines.dmi'
	layer = 3.3
	door_open_sound  = 'sound/effects/triple_beep.ogg'
	door_close_sound = 'sound/effects/triple_beep.ogg'