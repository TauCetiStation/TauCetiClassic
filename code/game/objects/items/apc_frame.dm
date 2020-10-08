// APC HULL

/obj/item/apc_frame
	name = "APC frame"
	desc = "Used for repairing or building APCs."
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	flags = CONDUCT

/obj/item/apc_frame/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		qdel(src)
	else
		return ..()

/obj/item/apc_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, "<span class='warning'>APC cannot be placed on this spot.</span>")
		return
	if (A.requires_power == 0 || istype(A,/area/space))
		to_chat(usr, "<span class='warning'>APC cannot be placed in this area.</span>")
		return
	if (A.get_apc())
		to_chat(usr, "<span class='warning'>This area already has APC.</span>")
		return //only one APC per area
	for(var/obj/machinery/power/terminal/T in loc)
		if (T.master)
			to_chat(usr, "<span class='warning'>There is another network terminal here.</span>")
			return
		else
			new /obj/item/stack/cable_coil/random(loc, 10)
			to_chat(usr, "You cut the cables and disassemble the unused power terminal.")
			qdel(T)
	new /obj/machinery/power/apc(loc, ndir, 1)
	qdel(src)
