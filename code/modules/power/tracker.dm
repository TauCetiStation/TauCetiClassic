//Solar tracker

//Machine that tracks the sun and reports it's direction to the solar controllers
//As long as this is working, solar panels on same powernet will track automatically

/obj/machinery/power/tracker
	name = "solar tracker"
	desc = "A solar directional tracker."
	icon = 'icons/obj/power.dmi'
	icon_state = "tracker"
	anchored = 1
	density = 1
	use_power = NO_POWER_USE

	var/sun_angle = 0		// sun angle as set by sun datum

/obj/machinery/power/tracker/atom_init(mapload, obj/item/solar_assembly/S)
	. = ..()
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/sheet/glass
		S.tracker = 1
		S.anchored = 1
	S.loc = src
	connect_to_network()

/obj/machinery/power/tracker/disconnect_from_network()
	..()
	SSsun.solars.Remove(src)

/obj/machinery/power/tracker/connect_to_network()
	var/to_return = ..()
	SSsun.solars.Add(src)
	return to_return

// called by datum/sun/calc_position() as sun's angle changes
/obj/machinery/power/tracker/proc/set_angle(angle)
	sun_angle = angle

	//set icon dir to show sun illumination
	dir = turn(NORTH, -angle - 22.5)	// 22.5 deg bias ensures, e.g. 67.5-112.5 is EAST

	// check we can draw power
	if(stat & NOPOWER)
		return

	// find all solar controls and update them
	// currently, just update all controllers in world
	// ***TODO: better communication system using network
	if(powernet)
		for(var/obj/machinery/power/solar_control/C in get_solars_powernet())
			if(powernet.nodes[C])
				if(get_dist(C, src) < SOLAR_MAX_DIST)
					C.tracker_update(angle)


/obj/machinery/power/tracker/attackby(obj/item/weapon/W, mob/user)

	if(iscrowbar(W))
		if(user.is_busy()) return
		if(W.use_tool(src, user, 50, volume = 50))
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.loc = src.loc
				S.give_glass()
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			user.visible_message("<span class='notice'>[user] takes the glass off the tracker.</span>")
			qdel(src)
		return
	..()

// timed process
// make sure we can draw power from the powernet
/obj/machinery/power/tracker/process()

	var/avail = surplus()

	if(avail > 500)
		add_load(500)
		stat &= ~NOPOWER
	else
		stat |= NOPOWER


// Tracker Electronic

/obj/item/weapon/tracker_electronics

	name = "tracker electronics"
	icon = 'icons/obj/doors/door_electronics.dmi'
	icon_state = "door_electronics"
	w_class = ITEM_SIZE_SMALL
