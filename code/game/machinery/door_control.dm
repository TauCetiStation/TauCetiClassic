#define COMPLETE 1
#define WITHOUT_WIRES 0

/obj/machinery/door_control
	name = "Remote Door Control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
	anchored = TRUE
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4
	var/id = "none" //most of doors have this variable empty, so if this variable is empty here, the default button will be able to open all of these doors.
	var/range = 10
	var/normaldoorcontrol = FALSE
	var/desiredstate = 0 // Zero is closed, 1 is open.
	var/specialfunctions = 1
	var/wiresexposed = FALSE
	var/locked = TRUE
	var/buildstage = COMPLETE
	var/door_control_access = null

/obj/machinery/door_control/atom_init(mapload, dir, building = FALSE)
	. = ..()
	if(building)
		if(loc)
			src.loc = loc
		buildstage = WITHOUT_WIRES
		wiresexposed = TRUE
		locked = FALSE
		id = "none"
		req_access_txt = num2text(access_engine)
		pixel_x = (dir & 3) ? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3) ? (dir == 1 ? -24 : 24) : 0
		icon_state = "doorctrl_assembly0"
		return

/obj/machinery/door_control/update_icon()
	switch(buildstage)
		if(COMPLETE)
			if(!wiresexposed)
				if(overlays)
					overlays.Cut()
				if(stat & NOPOWER || id == "none")
					icon_state = "doorctrl-p"
					return
				else
					icon_state = "doorctrl0"
					return
			else
				icon_state = "doorctrl_assembly1"
				if(overlays)
					overlays.Cut()
				if(stat & NOPOWER)
					return
				else if(id != "none")
					overlays += image('icons/obj/stationobjs.dmi', "doorctrl_assembly-is_id")
					return
				else
					overlays += image('icons/obj/stationobjs.dmi', "doorctrl_assembly-no_id")
					return
		if(WITHOUT_WIRES)
			if(overlays)
				overlays.Cut()
			icon_state = "doorctrl_assembly0"
			return

/obj/machinery/door_control/allowed_fail(mob/user)
	playsound(src, 'sound/items/buttonswitch.ogg', 20, 1, 1)
	flick("doorctrl-denied",src)

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user)
	switch(buildstage)
		if(COMPLETE)
			if(!wiresexposed)
				if(istype(W, /obj/item/device/detective_scanner))
					return
				else if(istype(W, /obj/item/weapon/card/emag))
					req_access = list()
					user.SetNextMove(CLICK_CD_INTERACT)
					req_one_access = list()
					if(locked)
						locked = FALSE
					playsound(src.loc, "sparks", 100, 1)
					return
				else if(isscrewdriver(W))
					if(locked && !issilicon(user) && !(stat & NOPOWER))
						to_chat(user, "The panel is locked")
						return
					wiresexposed = TRUE
					door_control_access = req_access_txt
					req_access_txt = num2text(access_engine)
					req_access = null
					update_icon()
					return
				else if(istype(W, /obj/item/weapon/card/id))
					var/obj/item/weapon/card/id/card = W
					if(access_engine in card.access)
						locked = !locked
						to_chat(user, "You [locked ? "lock" : "unlock"] the pannel")
						return
					else
						to_chat(usr, "<span class='warning'>Access Denied.</span>")
						return
				else
					return src.attack_hand(user)
			else
				if(isscrewdriver(W))
					wiresexposed = FALSE
					req_access_txt = null
					req_access = null
					if(door_control_access)
						req_access_txt = door_control_access
					locked = TRUE
					update_icon()
					return
				else if(ismultitool(W))
					if(allowed(usr))
						var/t = sanitize_safe(input(user, "Enter the identification code for the Door Control.", name, id), 20)
						if(!t)
							return
						if(!in_range(src, usr))
							return
						id = t
						set_door_control_access(user)
						update_icon()
						return
					else
						to_chat(usr, "<span class='warning'>Access Denied.</span>")
						return
				else if(iswirecutter(W))
					to_chat(user, "You remove wires from the door control frame.")
					playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
					new /obj/item/stack/cable_coil/random(loc, 1)
					id = "none"
					door_control_access = null
					buildstage = WITHOUT_WIRES
					update_icon()
					return
				return
		if(WITHOUT_WIRES)
			if(iscoil(W))
				var/obj/item/stack/cable_coil/coil = W
				coil.use(1)
				to_chat(user, "You wire the door control frame.")
				buildstage = COMPLETE
				update_icon()
				return
			else if(istype(W, /obj/item/weapon/pen))
				var/t = sanitize_safe(input(user, "Enter the name for the Door Control.", name, name), MAX_LNAME_LEN)
				if(!t)
					return
				if(!in_range(src, usr))
					return
				name = t
				return
			else if(iswrench(W))
				to_chat(user, "You remove the door control assembly from the wall!")
				var/obj/item/door_control_frame/frame = new /obj/item/door_control_frame()
				frame.loc = user.loc
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				qdel(src)
				return
	return

/obj/machinery/door_control/proc/set_door_control_access(mob/user)
	var/accesses_setup = text("<B>Access control</B><BR>\n")
	accesses_setup +="<A HREF='?src=\ref[src];none=1'>None</A><BR>"
	var/list/accesses = get_all_accesses()
	for (var/acc in accesses)
		var/acc_desc = get_access_desc(acc)
		if(acc_desc)
			accesses_setup += "<A HREF='?src=\ref[src];access=[acc]'>[acc_desc]</A><BR>"
	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[entity_ja(accesses_setup)]</TT>", "window=door_control")
	onclose(user, "door_control")

/obj/machinery/door_control/Topic(href, href_list)
	..()
	if(href_list["access"])
		door_control_access = (href_list["access"])
		usr << browse(null, "window=door_control")
	if(href_list["none"])
		door_control_access = null
		usr << browse(null, "window=door_control")

/obj/machinery/door_control/attack_hand(mob/user)
	if(buildstage != COMPLETE || wiresexposed || id == "none")
		return
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	playsound(src, 'sound/items/buttonswitch.ogg', 20, 1, 1)
	use_power(5)
	icon_state = "doorctrl1"

	for(var/obj/machinery/door/airlock/D in range(range))
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				if (D.density)
					spawn(0)
						D.open()
						return
				else
					spawn(0)
						D.close()
						return
			if(desiredstate == 1)
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = 1
				if(specialfunctions & BOLTS)
					D.bolt()
				if(specialfunctions & SHOCK)
					D.secondsElectrified = -1
				if(specialfunctions & SAFE)
					D.safe = 0
			else
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = 0
				if(specialfunctions & BOLTS)
					if(!D.isAllPowerCut() && D.hasPower())
						D.unbolt()
				if(specialfunctions & SHOCK)
					D.secondsElectrified = 0
				if(specialfunctions & SAFE)
					D.safe = 1

	for(var/obj/machinery/door/poddoor/M in poddoor_list)
		if (M.id == src.id)
			if (M.density)
				spawn( 0 )
					M.open()
					return
			else
				spawn( 0 )
					M.close()
					return

	desiredstate = !desiredstate
	spawn(15)
		update_icon()

/obj/machinery/door_control/power_change()
	..()
	update_icon()


/obj/item/door_control_frame
	name = "Door Control frame"
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
