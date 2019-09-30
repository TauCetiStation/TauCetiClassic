/obj/machinery/computer/teleporter
	name = "Teleporter Control Console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/teleporter"
	var/obj/item/device/gps/locked = null
	var/regime_set = "Teleporter"
	var/id = null
	var/obj/machinery/teleport/station/power_station
	var/calibrating
	var/turf/target //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.

/obj/machinery/computer/teleporter/atom_init()
	id = "[rand(1000, 9999)]"
	. = ..()
	teleporter_list += src
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/teleporter/atom_init_late()
	link_power_station()

/obj/machinery/computer/teleporter/Destroy()
	teleporter_list -= src
	if (power_station)
		power_station.teleporter_console = null
		power_station = null
	return ..()

/obj/machinery/computer/teleporter/proc/link_power_station()
	if(power_station)
		return
	for(var/newdir in cardinal)
		power_station = locate(/obj/machinery/teleport/station, get_step(src, newdir))
		if(power_station)
			break
	return power_station

/obj/machinery/computer/teleporter/attackby(I, mob/living/user)
	if(istype(I, /obj/item/device/gps))
		var/obj/item/device/gps/L = I
		if(L.locked_location && !(stat & (NOPOWER|BROKEN)))
			user.drop_from_inventory(L)
			L.loc = src
			locked = L
			to_chat(user, "<span class='notice'>You insert the GPS device into the [name]'s slot.</span>")
	else
		..()
	return

/obj/machinery/computer/teleporter/ui_interact(mob/user)
	var/data = "<h3>Teleporter Status</h3>"
	if(!power_station)
		data += "<div class='statusDisplay'>No power station linked.</div>"
	else if(!power_station.teleporter_hub)
		data += "<div class='statusDisplay'>No hub linked.</div>"
	else
		data += "<div class='statusDisplay'>Current regime: [regime_set]<BR>"
		data += "Current target: [(!target) ? "None" : "[get_area(target)] [(regime_set != "Gate") ? "" : "Teleporter"]"]<BR>"
		if(calibrating)
			data += "Calibration: <font color='yellow'>In Progress</font>"
		else if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
			data += "Calibration: <font color='green'>Optimal</font>"
		else
			data += "Calibration: <font color='red'>Sub-Optimal</font>"
		data += "</div><BR>"

		data += "<A href='?src=\ref[src];regimeset=1'>Change regime</A><BR>"
		data += "<A href='?src=\ref[src];settarget=1'>Set target</A><BR>"
		if(locked)
			data += "<BR><A href='?src=\ref[src];locked=1'>Get target from memory</A><BR>"
			data += "<A href='?src=\ref[src];eject=1'>Eject GPS device</A><BR>"
		else
			data += "<BR><span class='linkOff'>Get target from memory</span><BR>"
			data += "<span class='linkOff'>Eject GPS device</span><BR>"
		data += "<BR><A href='?src=\ref[src];calibrate=1'>Calibrate Hub</A>"

	var/datum/browser/popup = new(user, "teleporter", name, 400, 400)
	popup.set_content(data)
	popup.open()

/obj/machinery/computer/teleporter/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["eject"])
		eject()
		updateDialog()
		return

	if(!check_hub_connection())
		to_chat(usr, "<span class='warning'>Error: Unable to detect hub.</span>")
		return FALSE
	if(calibrating)
		to_chat(usr, "<span class='warning'>Error: Calibration in progress. Stand by.</span>")
		return FALSE

	if(href_list["regimeset"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		reset_regime()
	if(href_list["settarget"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		set_target(usr)
	if(href_list["locked"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		target = get_turf(locked.locked_location)
	if(href_list["calibrate"])
		if(!target)
			to_chat(usr, "<span class='danger'>Error: No target set to calibrate to.</span>")
			return FALSE
		if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
			to_chat(usr, "<span class='warning'>Hub is already calibrated!</span>")
			return FALSE
		to_chat(usr, "<span class='notice'>Processing hub calibration to target...</span>")

		calibrating = 1
		spawn(50 * (3 - power_station.teleporter_hub.accurate)) //Better parts mean faster calibration
			calibrating = 0
			if(check_hub_connection())
				power_station.teleporter_hub.calibrated = 1
				to_chat(usr, "<span class='notice'>Calibration complete.</span>")
			else
				to_chat(usr, "<span class='danger'>Error: Unable to detect hub.</span>")

	updateDialog()

/obj/machinery/computer/teleporter/proc/check_hub_connection()
	if(!power_station)
		return
	if(!power_station.teleporter_hub)
		return
	return 1

/obj/machinery/computer/teleporter/proc/reset_regime()
	target = null
	if(regime_set == "Teleporter")
		regime_set = "Gate"
	else
		regime_set = "Teleporter"

/obj/machinery/computer/teleporter/proc/eject()
	if(locked)
		locked.loc = loc
		locked = null

/obj/machinery/computer/teleporter/proc/set_target(mob/user)
	if(regime_set == "Teleporter")
		var/list/L = list()
		var/list/areaindex = list()

		for(var/obj/item/device/radio/beacon/R in radio_beacon_list)
			var/turf/T = get_turf(R)
			if (!T)
				continue
			if(is_centcom_level(T.z) || !SSmapping.has_level(T.z))
				continue
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R

		for (var/obj/item/weapon/implant/tracking/I in implant_list)
			if (!I.implanted || !ismob(I.loc))
				continue
			else
				var/mob/M = I.loc
				if (M.stat == 2)
					if (M.timeofdeath + 6000 < world.time)
						continue
				var/turf/T = get_turf(M)
				if(!T)	continue
				if(is_centcom_level(T.z))
					continue
				var/tmpname = M.real_name
				if(areaindex[tmpname])
					tmpname = "[tmpname] ([++areaindex[tmpname]])"
				else
					areaindex[tmpname] = 1
				L[tmpname] = I

		var/desc = input("Please select a location to lock in.", "Locking Computer") in L
		target = L[desc]

	else
		var/list/L = list()
		var/list/areaindex = list()
		var/list/S = power_station.linked_stations
		if(!S.len)
			to_chat(user, "<span class='alert'>No connected stations located.</span>")
			return
		for(var/obj/machinery/teleport/station/R in S)
			var/turf/T = get_turf(R)
			if (!T || !R.teleporter_hub || !R.teleporter_console)
				continue
			if(is_centcom_level(T.z))
				continue
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R
		var/desc = input("Please select a station to lock in.", "Locking Computer") in L
		target = L[desc]
		if(target)
			var/obj/machinery/teleport/station/trg = target
			trg.linked_stations |= power_station
			trg.stat &= ~NOPOWER
			if(trg.teleporter_hub)
				trg.teleporter_hub.stat &= ~NOPOWER
				trg.teleporter_hub.update_icon()
			if(trg.teleporter_console)
				trg.teleporter_console.stat &= ~NOPOWER
				trg.teleporter_console.update_icon()
	return

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	anchored = 1

/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/teleport/station/power_station
	var/calibrated //Calibration prevents mutation

/obj/machinery/teleport/hub/atom_init()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teleporter_hub(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/teleport/hub/atom_init_late()
	link_power_station()

/obj/machinery/teleport/hub/Destroy()
	if (power_station)
		power_station.teleporter_hub = null
		power_station = null
	return ..()

/obj/machinery/teleport/hub/RefreshParts()
	var/A = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		A += M.rating
	accurate = A

/obj/machinery/teleport/hub/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			break
	return power_station

/obj/machinery/teleport/hub/Bumped(M)
	if(is_centcom_level(z))
		to_chat(M, "You can't use this here.")
	if(is_ready())
		teleport(M)
		use_power(5000)
	return

/obj/machinery/teleport/hub/attackby(obj/item/W, mob/user)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", W))
		return

	if(exchange_parts(user, W))
		return

	default_deconstruction_crowbar(W)

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M, turf/T)
	var/obj/machinery/computer/teleporter/com = power_station.teleporter_console
	if (!com)
		return
	if (!com.target)
		visible_message("<span class='notice'>Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if(is_centcom_level(com.target.z))
		visible_message("<span class='notice'>Unknown coordinates. Please reinstate coordinate matrix.</span>")
		return
	if (istype(M, /atom/movable))
		if(do_teleport(M, com.target))
			if(!calibrated && prob(30 - ((accurate) * 10))) //oh dear a problem
				if(ishuman(M))//don't remove people from the round randomly you jerks
					var/mob/living/carbon/human/human = M
					// Effects similar to mutagen.
					if(!human.species.flags[IS_SYNTHETIC])
						randmuti(human)
						randmutb(human)
						domutcheck(human)
						human.UpdateAppearance()
				//		if(human.dna && human.dna.species.id == "human")
				//			M  << "<span class='italics'>You hear a buzzing in your ears.</span>"
				//			human.set_species(/datum/species/fly)

						human.apply_effect((rand(120 - accurate * 40, 180 - accurate * 60)), IRRADIATE, 0)
			calibrated = 0
	return

/obj/machinery/teleport/hub/update_icon()
	if(panel_open)
		icon_state = "tele-o"
	else if(power_station && power_station.engaged)
		icon_state = "tele1"
	else
		icon_state = "tele0"

/obj/machinery/teleport/hub/power_change()
	..()
	update_icon()

/obj/machinery/teleport/hub/proc/is_ready()
	. = !panel_open && !(stat & (BROKEN|NOPOWER)) && power_station && power_station.engaged && !(power_station.stat & (BROKEN|NOPOWER))

//obj/machinery/teleport/hub/syndicate/atom_init()
//	. = ..()
//	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
//	RefreshParts()

/obj/machinery/teleport/station
	name = "station"
	desc = "It's the station thingy of a teleport thingy." //seriously, wtf.
	icon_state = "controller"
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	var/engaged = 0
	var/obj/machinery/computer/teleporter/teleporter_console
	var/obj/machinery/teleport/hub/teleporter_hub
	var/list/linked_stations = list()
	var/efficiency = 0

/obj/machinery/teleport/station/atom_init()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teleporter_station(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/teleport/station/atom_init_late()
	link_console_and_hub()

/obj/machinery/teleport/station/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E - 1

/obj/machinery/teleport/station/proc/link_console_and_hub()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_hub = locate(/obj/machinery/teleport/hub, get_step(src, dir))
		if(teleporter_hub)
			teleporter_hub.link_power_station()
			break
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_console = locate(/obj/machinery/computer/teleporter, get_step(src, dir))
		if(teleporter_console)
			teleporter_console.link_power_station()
			break
	return teleporter_hub && teleporter_console

/obj/machinery/teleport/station/Destroy()
	if(teleporter_hub)
		teleporter_hub.power_station = null
		teleporter_hub.update_icon()
		teleporter_hub = null
	if (teleporter_console)
		teleporter_console.power_station = null
		teleporter_console = null
	return ..()

/obj/machinery/teleport/station/attackby(obj/item/weapon/W, mob/user)
	if(ismultitool(W) && !panel_open)
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/teleport/station) && M.buffer != src)
			if(linked_stations.len < efficiency)
				linked_stations.Add(M.buffer)
				M.buffer = null
				to_chat(user, "<span class='notice'>You upload the data from the [W.name]'s buffer.</span>")
			else
				to_chat(user, "<span class='alert'>This station cant hold more information, try to use better parts.</span>")
	if(default_deconstruction_screwdriver(user, "controller-o", "controller", W))
		update_icon()
		return

	if(exchange_parts(user, W))
		return

	default_deconstruction_crowbar(W)

	if(panel_open)
		if(ismultitool(W))
			var/obj/item/device/multitool/M = W
			M.buffer = src
			to_chat(user, "<span class='notice'>You download the data to the [W.name]'s buffer.</span>")
			return
		if(iswirecutter(W))
			link_console_and_hub()
			to_chat(user, "<span class='notice'>You reconnect the station to nearby machinery.</span>")
			return

/obj/machinery/teleport/station/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(!panel_open)
		toggle(user)

/obj/machinery/teleport/station/proc/toggle(mob/user)
	if(!teleporter_hub || !teleporter_console)
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	if (teleporter_console.target)
		src.engaged = !src.engaged
		use_power(5000)
		visible_message("<span class='notice'>Teleporter [engaged ? "" : "dis"]engaged!</span>")
	else
		visible_message("<span class='alert'>No target detected.</span>")
		src.engaged = 0
	teleporter_hub.update_icon()
	src.add_fingerprint(user)
	return

/obj/machinery/teleport/station/power_change()
	..()
	if(stat & NOPOWER)
		update_icon()
		if(teleporter_hub)
			teleporter_hub.update_icon()

/obj/machinery/teleport/station/update_icon()
	if(panel_open)
		icon_state = "controller-o"
	else if(stat & NOPOWER)
		icon_state = "controller-p"
	else
		icon_state = "controller"
