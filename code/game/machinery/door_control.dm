#define DOOR_CONTROL_COMPLETE 1
#define DOOR_CONTROL_WITHOUT_WIRES 0

/obj/machinery/door_control
	name = "remote door control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
	anchored = TRUE
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4
	var/id = null
	var/list/obj/machinery/door/airlock/connected_airlocks = list()
	var/list/obj/machinery/door/poddoor/connected_poddoors = list()
	var/normaldoorcontrol = 1
	var/range = 10
	var/specialfunctions = OPEN
	var/wiresexposed = FALSE
	var/locked = TRUE
	var/buildstage = DOOR_CONTROL_COMPLETE
	var/door_control_access = null
	var/accesses_showed = FALSE
	var/modes_showed = FALSE
	var/const/max_connections = 16

/obj/machinery/door_control/atom_init(mapload, dir, building = FALSE)
	. = ..()
	if(building)
		if(loc)
			src.loc = loc
		buildstage = DOOR_CONTROL_WITHOUT_WIRES
		wiresexposed = TRUE
		locked = FALSE
		req_access = list(access_engine)
		pixel_x = (dir & 3) ? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3) ? (dir == 1 ? -24 : 24) : 0
		icon_state = "doorctrl_assembly0"
		return
	else
		req_access = list()
		if(req_access_txt)
			req_access += text2num(req_access_txt)
			req_access_txt = null
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/door_control/atom_init_late()
	for(var/obj/machinery/door/airlock/A in airlock_list)
		if(A.id_tag == src.id)
			connected_airlocks += A
	for(var/obj/machinery/door/poddoor/P in poddoor_list)
		if(P.id == src.id)
			connected_poddoors += P

/obj/machinery/door_control/update_icon()
	overlays.Cut()
	switch(buildstage)
		if(DOOR_CONTROL_COMPLETE)
			if(!wiresexposed)
				if(stat & NOPOWER || (!connected_poddoors.len && !connected_airlocks.len))
					icon_state = "doorctrl-p"
					return
				else
					icon_state = "doorctrl0"
					return
			else
				icon_state = "doorctrl_assembly1"
				if(stat & NOPOWER)
					return
				else if(connected_poddoors.len || connected_airlocks.len)
					overlays += image('icons/obj/stationobjs.dmi', "doorctrl_assembly-is_id")
					return
				else
					overlays += image('icons/obj/stationobjs.dmi', "doorctrl_assembly-no_id")
					return
		if(DOOR_CONTROL_WITHOUT_WIRES)
			icon_state = "doorctrl_assembly0"
			return

/obj/machinery/door_control/allowed_fail(mob/user)
	playsound(src, 'sound/items/buttonswitch.ogg', 20, 1, 1)
	flick("doorctrl-denied",src)

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user)
	switch(buildstage)
		if(DOOR_CONTROL_COMPLETE)
			if(!wiresexposed)
				if(istype(W, /obj/item/device/detective_scanner))
					return
				else if(istype(W, /obj/item/weapon/card/emag))
					req_access.Cut()
					user.SetNextMove(CLICK_CD_INTERACT)
					req_one_access.Cut()
					if(locked)
						locked = FALSE
					playsound(src, "sparks", 100, 1)
					return
				else if(isscrewdriver(W))
					if(locked && !issilicon(user) && !(stat & NOPOWER))
						to_chat(user, "The panel is locked")
						return
					wiresexposed = TRUE
					door_control_access = req_access[1]
					req_access = list(access_engine)
					accesses_showed = FALSE
					modes_showed = FALSE
					update_icon()
					return
				else if(istype(W, /obj/item/weapon/card/id))
					var/obj/item/weapon/card/id/card = W
					if(access_engine in card.access)
						locked = !locked
						to_chat(user, "You [locked ? "lock" : "unlock"] the pannel")
						return
					else
						to_chat(user, "<span class='warning'>Access Denied.</span>")
						return
				else
					return src.attack_hand(user)
			else
				if(isscrewdriver(W))
					wiresexposed = FALSE
					req_access.Cut()
					if(door_control_access)
						req_access += door_control_access
					locked = TRUE
					update_icon()
					return
				else if(ismultitool(W) && !(stat & NOPOWER))
					if(allowed(usr))
						set_up_door_control(user)
						update_icon()
						return
					else
						to_chat(usr, "<span class='warning'>Access Denied.</span>")
						return
				else if(iswirecutter(W))
					to_chat(user, "You remove wires from the door control frame.")
					playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
					new /obj/item/stack/cable_coil/random(loc, 1)
					connected_airlocks.Cut()
					connected_poddoors.Cut()
					specialfunctions = OPEN
					accesses_showed = FALSE
					modes_showed = FALSE
					door_control_access = null
					buildstage = DOOR_CONTROL_WITHOUT_WIRES
					update_icon()
					return
				return
		if(DOOR_CONTROL_WITHOUT_WIRES)
			if(iscoil(W))
				var/obj/item/stack/cable_coil/coil = W
				coil.use(1)
				to_chat(user, "You wire the door control frame.")
				buildstage = DOOR_CONTROL_COMPLETE
				update_icon()
				return
			else if(istype(W, /obj/item/weapon/pen))
				var/t = sanitize_safe(input(user, "Enter the name for the Door Control.", name, name), MAX_LNAME_LEN)
				if(!in_range(src, user))
					return
				name = t
				return
			else if(iswrench(W))
				to_chat(user, "You remove the door control assembly from the wall!")
				var/obj/item/door_control_frame/frame = new
				frame.loc = user.loc
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
				qdel(src)
				return
	return

/obj/machinery/door_control/proc/set_up_door_control(mob/user)
	var/setup_menu = text("<b>Door Control Setup</b><hr>")
	if(!accesses_showed)
		setup_menu += "<b><a href='?src=\ref[src];show_accesses=1'>Show access restrictions setup</a></b><br>"
	else
		setup_menu += "<b><a href='?src=\ref[src];show_accesses=1'>Hide access restrictions setup</a></b><ul>"
		if(!door_control_access)
			setup_menu +="<li><b><a style='color: green' href='?src=\ref[src];none=1'>None</a></b></li>"
		else
			setup_menu +="<li><a href='?src=\ref[src];none=1'>None</a></li>"
		var/list/accesses = get_all_accesses()
		for (var/acc in accesses)
			var/acc_desc = get_access_desc(acc)
			if(acc_desc)
				if(acc == door_control_access)
					setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];access=[acc]'>[acc_desc]</a></b></li>"
				else
					setup_menu += "<li><a href='?src=\ref[src];access=[acc]'>[acc_desc]</a></li>"
		setup_menu += "</ul>"
	if(!modes_showed)
		setup_menu += "<b><a href='?src=\ref[src];show_modes=1'>Show airlock control mode setup</a></b><br>"
	else
		setup_menu += "<b><a href='?src=\ref[src];show_modes=1'>Hide airlock control mode setup</a></b><ul>"
		if(specialfunctions == OPEN)
			setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];mode=[OPEN]'>Open</a></b></li>"
		else
			setup_menu += "<li><a href='?src=\ref[src];mode=[OPEN]'>Open</a></li>"

		if(specialfunctions == BOLTS)
			setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];mode=[BOLTS]'>Toggle bolts</a></b></li>"
		else
			setup_menu += "<li><a href='?src=\ref[src];mode=[BOLTS]'>Toggle bolts</a></li>"

		if(specialfunctions == SHOCK)
			setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];mode=[SHOCK]'>Electrify</a></b></li>"
		else
			setup_menu += "<li><a href='?src=\ref[src];mode=[SHOCK]'>Electrify</a></li>"

		if(specialfunctions == (OPEN | BOLTS))
			setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];mode=[OPEN | BOLTS]'>Open and toggle bolts</a></b></li>"
		else
			setup_menu += "<li><a href='?src=\ref[src];mode=[OPEN | BOLTS]'>Open and toggle bolts</a></li>"

		if(specialfunctions == (BOLTS | SHOCK))
			setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];mode=[BOLTS | SHOCK]'>Toggle bolts and electrify</a></b></li>"
		else
			setup_menu += "<li><a href='?src=\ref[src];mode=[BOLTS | SHOCK]'>Toggle bolts and electrify</a></li>"

		if(specialfunctions == (OPEN | BOLTS | SHOCK))
			setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];mode=[OPEN | BOLTS | SHOCK]'>Open, toggle bolts and electrify</a></b></li>"
		else
			setup_menu += "<li><a href='?src=\ref[src];mode=[OPEN | BOLTS | SHOCK]'>Open, toggle bolts and electrify</a></li>"

		setup_menu += "</ul>"

	setup_menu += "<b><a href='?src=\ref[src];load=1'>Load data from the multitool</a></b><br>"
	setup_menu += "<b><a href='?src=\ref[src];copy=1'>Copy data to the multitool</a></b><br>"
	setup_menu += "<b><a href='?src=\ref[src];clear=1'>Clear data</a></b><br>"
	user << browse("<head><title>[src]</title></head><tt>[entity_ja(setup_menu)]</tt>", "window=door_control")
	onclose(user, "door_control")

/obj/machinery/door_control/Topic(href, href_list)
	..()
	if(!ismultitool(usr.get_active_hand()))
		to_chat(usr, "<span class='warning'>You need a multitool!</span>")
		return
	if(href_list["show_accesses"])
		accesses_showed = !accesses_showed
	if(href_list["show_modes"])
		modes_showed = !modes_showed
	if(href_list["access"])
		door_control_access = text2num(href_list["access"])
		usr << browse(null, "window=door_control")
	if(href_list["none"])
		door_control_access = null
		usr << browse(null, "window=door_control")
	if(href_list["mode"])
		specialfunctions = text2num(href_list["mode"])
	if(href_list["load"])
		var/obj/item/device/multitool/M = usr.get_active_hand()
		if(!M.airlocks_buffer.len && !M.poddoors_buffer.len)
			to_chat(usr, "<span class='warning'>The multitool's buffer is empty</span>")
			return
		var/loaded_airlocks = FALSE
		var/loaded_poddoors = FALSE
		if((M.airlocks_buffer.len > (max_connections - connected_airlocks.len)) && M.airlocks_buffer.len)
			to_chat(usr, "<span class='warning'>This device can't control this number of airlocks!</span>")
		else
			for(var/A in M.airlocks_buffer)
				if(!(A in connected_airlocks))
					connected_airlocks += A
					loaded_airlocks = TRUE
			M.airlocks_buffer.Cut()
		if((M.poddoors_buffer.len > (max_connections - connected_poddoors.len)) && M.poddoors_buffer.len)
			to_chat(usr, "<span class='warning'>This device can't control this number of poddoors!</span>")
		else
			for(var/P in M.poddoors_buffer)
				if(!(P in connected_poddoors))
					connected_poddoors += P
					loaded_poddoors = TRUE
			M.poddoors_buffer.Cut()
		if(loaded_poddoors && loaded_airlocks)
			to_chat(usr, "<span class='notice'>You load the airlocks' and poddors' data.</span>")
		else if(loaded_poddoors)
			to_chat(usr, "<span class='notice'>You load the poddors' data.</span>")
		else if(loaded_airlocks)
			to_chat(usr, "<span class='notice'>You load the airlocks' data.</span>")
	if(href_list["copy"])
		if(!connected_airlocks.len && !connected_poddoors.len)
			to_chat(usr, "<span class='warning'>There's no door data recorded.</span>")
		else
			var/obj/item/device/multitool/M = usr.get_active_hand()
			M.airlocks_buffer = connected_airlocks
			M.poddoors_buffer = connected_poddoors
			to_chat(usr, "<span class='notice'>You copy data.</span>")
	if(href_list["clear"])
		if(!connected_airlocks.len && !connected_poddoors.len)
			to_chat(usr, "<span class='warning'>There's no door data recorded.</span>")
		else
			connected_airlocks.Cut()
			connected_poddoors.Cut()
			specialfunctions = OPEN
			to_chat(usr, "<span class='notice'>You clear data.</span>")
	update_icon()
	set_up_door_control(usr)

/obj/machinery/door_control/attack_hand(mob/user)
	if(buildstage != DOOR_CONTROL_COMPLETE || wiresexposed || (!connected_poddoors.len && !connected_airlocks.len))
		return
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	playsound(src, 'sound/items/buttonswitch.ogg', 20, 1, 1)
	use_power(5)
	icon_state = "doorctrl1"
	if(connected_airlocks.len)
		for(var/obj/machinery/door/airlock/A in connected_airlocks)
			INVOKE_ASYNC(src, .obj/machinery/door_control/proc/toggle_airlock, A)
	if(connected_poddoors.len)
		for(var/obj/machinery/door/poddoor/P in connected_poddoors)
			INVOKE_ASYNC(src, .obj/machinery/door_control/proc/toggle_poddoor, P)
	addtimer(CALLBACK(src, .update_icon), 15)

/obj/machinery/door_control/proc/toggle_airlock(obj/machinery/door/airlock/A)
	if(!A.isAllPowerCut() && A.hasPower())
		if(specialfunctions == OPEN)
			if(A.density)
				A.open()
			else
				A.close()
		else if(specialfunctions == BOLTS)
			if(A.locked)
				A.unbolt()
			else
				A.bolt()
		else if(specialfunctions == SHOCK)
			if(A.secondsElectrified)
				A.secondsElectrified = 0
			else
				A.secondsElectrified = -1
		else if(specialfunctions == (OPEN | BOLTS))
			if(A.density)
				A.unbolt()
				A.open()
				A.bolt()
			else
				A.unbolt()
				A.close()
				A.bolt()
		else if(specialfunctions == (BOLTS | SHOCK))
			if(A.locked)
				A.unbolt()
				A.secondsElectrified = 0
			else
				A.bolt()
				A.secondsElectrified = -1
		else if(specialfunctions == (OPEN | BOLTS | SHOCK))
			if(A.density)
				A.unbolt()
				A.open()
				A.bolt()
				A.secondsElectrified = 0
			else
				A.unbolt()
				A.close()
				A.bolt()
				A.secondsElectrified = -1

/obj/machinery/door_control/proc/toggle_poddoor(obj/machinery/door/poddoor/P)
	if(P.density)
		P.open()
	else
		P.close()


/obj/machinery/door_control/power_change()
	..()
	update_icon()


/obj/item/door_control_frame
	name = "door control frame"
	desc = "Used for building Door Controls."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl_assembly0"

/obj/item/door_control_frame/attackby(obj/item/weapon/W, mob/user)
	..()
	if (iswrench(W))
		new /obj/item/stack/sheet/metal(get_turf(src.loc), 1)
		qdel(src)

/obj/item/door_control_frame/proc/try_build(turf/on_wall) //copied from code/game/machinery/alarm.dm
	if (get_dist(on_wall, usr) > 1)
		return

	var/ndir = get_dir(on_wall, usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf_loc(usr)
	var/area/A = get_area(src)
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, "\red Door Control cannot be placed on this spot.")
		return
	if (A.requires_power == 0 || A.name == "Space")
		to_chat(usr, "\red Door Control cannot be placed in this area.")
		return

	if(gotwallitem(loc, ndir))
		to_chat(usr, "\red There's already an item on this wall!")
		return

	new /obj/machinery/door_control(loc, ndir, TRUE)

	qdel(src)



/obj/machinery/driver_button/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/user)
	if(..() || active)
		return 1

	use_power(5)
	user.SetNextMove(CLICK_CD_INTERACT)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in poddoor_list)
		if (M.id == src.id)
			spawn( 0 )
				M.open()
				return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in mass_driver_list)
		if(M.id == src.id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in poddoor_list)
		if (M.id == src.id)
			spawn( 0 )
				M.close()
				return

	icon_state = "launcherbtt"
	active = 0

#undef DOOR_CONTROL_COMPLETE
#undef DOOR_CONTROL_WITHOUT_WIRES
