/obj/machinery/door/poddoor
	name = "Podlock"
	desc = "Why it no open!!!"
	icon = 'icons/obj/doors/blast_door.dmi'
	icon_state = "pdoor1"
	var/id = 1.0
	explosion_resistance = 25
	block_air_zones = 0

/obj/machinery/door/poddoor/New()
	. = ..()
	if(density)
		layer = 3.3
	else
		layer = initial(layer)
	return

/obj/machinery/door/poddoor/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return 0

/obj/machinery/door/poddoor/attackby(obj/item/weapon/C, mob/user)
	src.add_fingerprint(user)
	if (!( istype(C, /obj/item/weapon/crowbar) || (istype(C, /obj/item/weapon/twohanded/fireaxe) && C:wielded == 1) ))
		return
	if ((src.density && (stat & NOPOWER) && !( src.operating )))
		spawn( 0 )
			src.operating = 1
			flick("pdoorc0", src)
			src.icon_state = "pdoor0"
			src.set_opacity(0)
			sleep(15)
			src.density = 0
			src.operating = 0
			return
	return

/obj/machinery/door/poddoor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("pdoorc0", src)
	src.icon_state = "pdoor0"
	src.set_opacity(0)
	sleep(10)
	layer = initial(layer)
	src.density = 0
	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0
	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/poddoor/close()
	if (src.operating)
		return
	src.operating = 1
	layer = 4.1		//Above everything except firedoors
	flick("pdoorc1", src)
	src.icon_state = "pdoor1"
	src.density = 1
	src.set_opacity(initial(opacity))
	update_nearby_tiles()

	sleep(10)
	src.operating = 0
	return

/obj/machinery/door/poddoor/filler_object
	name = ""
	icon_state = ""
