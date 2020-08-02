#define DOOR_CONTROL_COMPLETE      1
#define DOOR_CONTROL_WITHOUT_WIRES 0

#define OPEN_BOLTS        (OPEN | BOLTS)
#define BOLTS_SHOCK       (BOLTS | SHOCK)
#define OPEN_BOLTS_SHOCK  (OPEN | BOLTS | SHOCK)

#define ON_WALL  0
#define ON_TABLE 1

/obj/machinery/door_control
	name = "Remote Door Control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = STATIC_ENVIRON
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	allowed_checks = ALLOWED_CHECK_A_HAND
	var/id = null
	var/list/obj/machinery/door/airlock/connected_airlocks = list()
	var/list/obj/machinery/door/poddoor/connected_poddoors = list()
	var/normaldoorcontrol = 1
	var/range = 20
	var/specialfunctions = OPEN
	var/wiresexposed = FALSE
	var/panel_locked = TRUE
	var/controls_locked = TRUE
	var/buildstage = DOOR_CONTROL_COMPLETE
	var/accesses_showed = FALSE
	var/modes_showed = FALSE
	var/const/max_connections = 16

/obj/machinery/door_control/atom_init(mapload, dir, build_on)
	. = ..()
	if(!mapload)
		buildstage = DOOR_CONTROL_WITHOUT_WIRES
		wiresexposed = TRUE
		panel_locked = FALSE
		req_one_access = list()
		if(build_on == ON_WALL)
			pixel_x = (dir & 3) ? 0 : (dir == 4 ? -24 : 24)
			pixel_y = (dir & 3) ? (dir == 1 ? -24 : 24) : 0
		else if(build_on == ON_TABLE)
			pixel_x = (dir & 3) ? 0 : (dir == 4 ? 7 : -7)
			pixel_y = (dir & 3) ? (dir == 1 ? 9 : -3) : (dir == 4 ? 3 : 3)
		icon_state = "doorctrl_assembly0"
		return
	else
		if(req_access.len)
			req_one_access = req_access.Copy()
			req_access.Cut()
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/door_control/atom_init_late()
	for(var/obj/machinery/door/airlock/A in airlock_list)
		if(A.id_tag == src.id)
			connected_airlocks += A
	for(var/obj/machinery/door/poddoor/P in poddoor_list)
		if(P.id == src.id)
			connected_poddoors += P
	update_icon()

/obj/machinery/door_control/Destroy()
	connected_airlocks.Cut()
	connected_poddoors.Cut()
	return ..()

/obj/machinery/door_control/update_icon()
	cut_overlays()
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
				else if(emagged)
					add_overlay(image('icons/obj/stationobjs.dmi', "doorctrl_assembly-emagged"))
				else if(connected_poddoors.len || connected_airlocks.len)
					add_overlay(image('icons/obj/stationobjs.dmi', "doorctrl_assembly-is_id"))
					return
				else
					add_overlay(image('icons/obj/stationobjs.dmi', "doorctrl_assembly-no_id"))
					return
		if(DOOR_CONTROL_WITHOUT_WIRES)
			icon_state = "doorctrl_assembly0"
			return

/obj/machinery/door_control/allowed_fail(mob/user)
	playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER, 20)
	flick("doorctrl-denied",src)

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user)
	switch(buildstage)
		if(DOOR_CONTROL_COMPLETE)
			if(!wiresexposed)
				if(istype(W, /obj/item/device/detective_scanner))
					return
				else if(isscrewdriver(W))
					if(panel_locked && !issilicon(user) && !(stat & NOPOWER) && !emagged)
						to_chat(user, "<span class='warning'>The panel is locked</span>")
						return
					wiresexposed = TRUE
					accesses_showed = FALSE
					modes_showed = FALSE
					update_icon()
					return
				else if(istype(W, /obj/item/weapon/card/id) && !(stat & NOPOWER) && !emagged)
					var/obj/item/weapon/card/id/card = W
					if(access_engine in card.access)
						panel_locked = !panel_locked
						to_chat(user, "<span class='notice'>You [panel_locked ? "lock" : "unlock"] the pannel</span>")
						return
					else
						to_chat(user, "<span class='warning'>Access Denied.</span>")
						return
				else
					return src.attack_hand(user)
			else
				if(isscrewdriver(W))
					wiresexposed = FALSE
					panel_locked = TRUE
					controls_locked = TRUE
					update_icon()
					return
				else if(istype(W, /obj/item/weapon/card/id) && !(stat & NOPOWER) && !emagged)
					var/obj/item/weapon/card/id/card = W
					if(access_engine in card.access)
						controls_locked = !controls_locked
						to_chat(user, "<span class='notice'>You [controls_locked ? "lock" : "unlock"] controls</span>")
						return
					else
						to_chat(user, "<span class='warning'>Access Denied.</span>")
						return
				else if(ismultitool(W) && !(stat & NOPOWER))
					if(!controls_locked || emagged || issilicon(user))
						set_up_door_control(user)
						update_icon()
						return
					else
						to_chat(usr, "<span class='warning'>Controls are locked!</span>")
						return
				else if(iswirecutter(W))
					to_chat(user, "You remove wires from the door control frame.")
					playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
					new /obj/item/stack/cable_coil/random(loc, 1)
					connected_airlocks.Cut()
					connected_poddoors.Cut()
					req_one_access.Cut()
					specialfunctions = OPEN
					accesses_showed = FALSE
					modes_showed = FALSE
					emagged = FALSE
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
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
				qdel(src)
				return

/obj/machinery/door_control/emag_act(mob/user)
	if((buildstage == DOOR_CONTROL_COMPLETE) && !emagged)
		emagged = TRUE
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		update_icon()
		return TRUE
	return FALSE

/obj/machinery/door_control/proc/set_up_door_control(mob/user)
	var/setup_menu = text("<b>Door Control Setup</b><hr>")
	if(!accesses_showed)
		setup_menu += "<b><a href='?src=\ref[src];show_accesses=1'>Show access restrictions setup</a></b><br>"
	else
		setup_menu += "<b><a href='?src=\ref[src];show_accesses=1'>Hide access restrictions setup</a></b><ul>"
		if(!req_one_access.len)
			setup_menu +="<li><b><a style='color: green' href='?src=\ref[src];none=1'>None</a></b></li>"
		else
			setup_menu +="<li><a href='?src=\ref[src];none=1'>None</a></li>"
		var/list/accesses = get_all_accesses()
		for (var/acc in accesses)
			var/acc_desc = get_access_desc(acc)
			if(acc_desc)
				if(acc in req_one_access)
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

		if(specialfunctions == OPEN_BOLTS)
			setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];mode=[OPEN_BOLTS]'>Open and toggle bolts</a></b></li>"
		else
			setup_menu += "<li><a href='?src=\ref[src];mode=[OPEN_BOLTS]'>Open and toggle bolts</a></li>"

		if(specialfunctions == BOLTS_SHOCK)
			setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];mode=[BOLTS_SHOCK]'>Toggle bolts and electrify</a></b></li>"
		else
			setup_menu += "<li><a href='?src=\ref[src];mode=[BOLTS_SHOCK]'>Toggle bolts and electrify</a></li>"

		if(specialfunctions == OPEN_BOLTS_SHOCK)
			setup_menu += "<li><b><a style='color: green' href='?src=\ref[src];mode=[OPEN_BOLTS_SHOCK]'>Open, toggle bolts and electrify</a></b></li>"
		else
			setup_menu += "<li><a href='?src=\ref[src];mode=[OPEN_BOLTS_SHOCK]'>Open, toggle bolts and electrify</a></li>"

		setup_menu += "</ul>"

	setup_menu += "<b><a href='?src=\ref[src];load=1'>Load data from the multitool</a></b><br>"
	setup_menu += "<b><a href='?src=\ref[src];copy=1'>Copy data to the multitool</a></b><br>"
	setup_menu += "<b><a href='?src=\ref[src];clear=1'>Clear data</a></b><br>"

	var/datum/browser/popup = new(user, "window=door_control", src.name)
	popup.set_content(setup_menu)
	popup.open()

/obj/machinery/door_control/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(!ismultitool(usr.get_active_hand()))
		to_chat(usr, "<span class='warning'>You need a multitool!</span>")
		return
	if(href_list["show_accesses"])
		accesses_showed = !accesses_showed
	if(href_list["show_modes"])
		modes_showed = !modes_showed
	if(href_list["access"])
		var/acc = text2num(href_list["access"])
		if(acc in req_one_access)
			req_one_access -= acc
		else
			req_one_access += acc
	if(href_list["none"])
		req_one_access.Cut()
	if(href_list["mode"])
		specialfunctions = text2num(href_list["mode"])
	if(href_list["load"])
		var/obj/item/device/multitool/M = usr.get_active_hand()
		if(!M.airlocks_buffer.len && !M.poddoors_buffer.len)
			to_chat(usr, "<span class='warning'>The multitool's buffer is empty</span>")
			return
		var/loaded_airlocks = FALSE
		var/loaded_poddoors = FALSE
		var/airlocks_out_of_range = FALSE
		var/poddoors_out_of_range = FALSE
		if((M.airlocks_buffer.len > (max_connections - connected_airlocks.len)) && M.airlocks_buffer.len)
			to_chat(usr, "<span class='warning'>This device can't control this number of airlocks!</span>")
		else
			for(var/A in M.airlocks_buffer)
				if(!(A in connected_airlocks))
					if(get_dist(src, A) > range)
						airlocks_out_of_range = TRUE
					else
						connected_airlocks += A
						loaded_airlocks = TRUE
			M.airlocks_buffer.Cut()
		if((M.poddoors_buffer.len > (max_connections - connected_poddoors.len)) && M.poddoors_buffer.len)
			to_chat(usr, "<span class='warning'>This device can't control this number of poddoors!</span>")
		else
			for(var/P in M.poddoors_buffer)
				if(!(P in connected_poddoors))
					if(get_dist(src, P) > range)
						poddoors_out_of_range = TRUE
					else
						connected_poddoors += P
						loaded_poddoors = TRUE
			M.poddoors_buffer.Cut()
		if(loaded_poddoors && loaded_airlocks)
			to_chat(usr, "<span class='notice'>You load the airlocks' and poddors' data.</span>")
		else if(loaded_poddoors)
			to_chat(usr, "<span class='notice'>You load the poddors' data.</span>")
		else if(loaded_airlocks)
			to_chat(usr, "<span class='notice'>You load the airlocks' data.</span>")
		if(airlocks_out_of_range)
			to_chat(usr, "<span class='warning'>Some airlocks are out of range!</span>")
		if(poddoors_out_of_range)
			to_chat(usr, "<span class='warning'>Some poddoors are out of range!</span>")
	if(href_list["copy"])
		if(!connected_airlocks.len && !connected_poddoors.len)
			to_chat(usr, "<span class='warning'>There's no door data recorded.</span>")
		else
			var/obj/item/device/multitool/M = usr.get_active_hand()
			M.airlocks_buffer = connected_airlocks.Copy()
			M.poddoors_buffer = connected_poddoors.Copy()
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
	playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER, 20)
	use_power(5)
	icon_state = "doorctrl1"
	for(var/obj/machinery/door/airlock/A in connected_airlocks)
		INVOKE_ASYNC(src, .proc/toggle_airlock, A)
	for(var/obj/machinery/door/poddoor/P in connected_poddoors)
		INVOKE_ASYNC(src, .proc/toggle_poddoor, P)
	addtimer(CALLBACK(src, /obj.proc/update_icon), 15)

/obj/machinery/door_control/proc/toggle_airlock(obj/machinery/door/airlock/A)
	if(!A.isAllPowerCut() && A.hasPower())
		if(specialfunctions == OPEN)
			if(A.density)
				A.open()
			else
				A.close_unsafe()
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
		else if(specialfunctions == (OPEN_BOLTS))
			if(A.density)
				A.unbolt()
				A.open()
				A.bolt()
			else
				A.unbolt()
				A.close_unsafe()
				A.bolt()
		else if(specialfunctions == (BOLTS_SHOCK))
			if(A.locked)
				A.unbolt()
				A.secondsElectrified = 0
			else
				A.bolt()
				A.secondsElectrified = -1
		else if(specialfunctions == (OPEN_BOLTS_SHOCK))
			if(A.density)
				A.unbolt()
				A.open()
				A.bolt()
				A.secondsElectrified = 0
			else
				A.unbolt()
				A.close_unsafe()
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

/obj/item/door_control_frame/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		new /obj/item/stack/sheet/metal(get_turf(src.loc), 1)
		qdel(src)
		return
	return ..()

/obj/item/door_control_frame/proc/try_build(target)
	if (get_dist(target, usr) > 1)
		return

	var/ndir = get_dir(target, usr)
	if (!(ndir in cardinal))
		return

	var/area/A = get_area(src)
	if(A.requires_power == 0 || istype(A, /area/space))
		to_chat(usr, "<span class='warning'>Door Control cannot be placed in this area.</span>")
		return

	if(istype(target, /turf/simulated/wall))
		var/turf/loc = get_turf_loc(usr)

		if(!istype(loc, /turf/simulated/floor))
			to_chat(usr, "<span class='warning'>Door Control cannot be placed on this spot.</span>")
			return

		if(gotwallitem(loc, ndir))
			to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
			return

		new /obj/machinery/door_control(loc, ndir, ON_WALL)

	else if(istype(target, /obj/structure/table/reinforced))
		var/turf/loc = get_turf_loc(target)

		if (!istype(loc, /turf/simulated/floor))
			to_chat(usr, "<span class='warning'>Door Control cannot be placed on this spot.</span>")
			return

		for(var/obj/machinery/machine in loc)
			if(!istype(machine, /obj/machinery/door_control) && !istype(machine, /obj/machinery/door/window) && !istype(machine, /obj/machinery/atmospherics))
				to_chat(usr, "<span class='warning'>There's already an object on this table!</span>")
				return
			else if(istype(machine, /obj/machinery/door_control))
				if((ndir == NORTH && machine.pixel_y > 3) || (ndir == SOUTH && machine.pixel_y < 3) || (ndir == EAST && machine.pixel_x > 0) || (ndir == WEST && machine.pixel_x < 0))
					to_chat(usr, "<span class='warning'>There's already a button on this side of table!</span>")
					return

		new /obj/machinery/door_control(loc, ndir, ON_TABLE)

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

#undef OPEN_BOLTS
#undef OPEN_BOLTS_SHOCK

#undef ON_WALL
#undef ON_TABLE
