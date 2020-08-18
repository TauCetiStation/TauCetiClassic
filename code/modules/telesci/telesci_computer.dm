/obj/machinery/computer/telescience
	name = "Telepad Control Console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	circuit = /obj/item/weapon/circuitboard/telesci_console
	light_color = "#315ab4"
	idle_power_usage = 250
	active_power_usage = 75000
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Telescience control console initialized.<BR>Welcome."

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/datum/projectile_data/last_tele_data = null
	var/z_co = 1
	var/power_off
	var/rotation_off
	var/angle_off
	var/last_target

	var/rotation = 0
	var/angle = 45
	var/power = 5

	// Based on the power used
	var/teleport_cooldown = 0 // every index requires a bluespace crystal
	var/list/power_options = list(5, 10, 20, 25, 30, 40, 50, 80, 100)
	var/teleporting = 0
	var/starting_crystals = 0
	var/max_crystals = 4
	var/list/crystals = list()
	var/obj/item/device/gps/inserted_gps
	var/obj/effect/portal/tsci_wormhole/active_wormhole = null

/obj/machinery/computer/telescience/atom_init()
	. = ..()
	recalibrate()

/obj/machinery/computer/telescience/atom_init()
	. = ..()
	for(var/i = 1; i <= starting_crystals; i++)
		crystals += new /obj/item/bluespace_crystal/artificial(null) // starting crystals

/obj/machinery/computer/telescience/Destroy()
	eject()
	if(inserted_gps)
		inserted_gps.loc = loc
		inserted_gps = null
	if(telepad)
		telepad.computer = null
		telepad = null
	close_wormhole()
	return ..()

/obj/machinery/computer/telescience/examine(mob/user)
	..()
	to_chat(user, "There are [crystals.len] bluespace crystals in the crystal ports.")

/obj/machinery/computer/telescience/attack_paw(mob/user)
	to_chat(user, "<span class='warning'>You are too primitive to use this computer!</span>")
	return

/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
		set_light(0)
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
			set_light(0)
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
			set_light(light_range_on, light_power_on)

/obj/machinery/computer/telescience/power_change()
	..()
	if(stat & NOPOWER)
		close_wormhole()

/obj/machinery/computer/telescience/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/bluespace_crystal))
		if(crystals.len >= max_crystals)
			to_chat(user, "<span class='warning'>There are not enough crystal ports.</span>")
			return
		user.drop_item()
		crystals += W
		W.loc = null
		user.visible_message("<span class='notice'>[user] inserts a [W] into the [src]'s crystal port.</span>")
		updateDialog()
		return
	else if(istype(W, /obj/item/device/gps))
		if(!inserted_gps)
			inserted_gps = W
			user.drop_from_inventory(W)
			W.loc = src
			user.visible_message("<span class='notice'>[user] inserts [W] into \the [src]'s GPS device slot.</span>")
		return
	else if(ismultitool(W))
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/telepad))
			if(telepad)
				telepad.computer = null
				close_wormhole()
			telepad = M.buffer
			telepad.computer = src
			M.buffer = null
			to_chat(user, "<span class='notice'>You upload the data from the [W.name]'s buffer.</span>")
		return
	else
		return ..()

/obj/machinery/computer/telescience/ui_interact(mob/user)
	var/t
	if(!telepad)
		in_use = 0     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No telepad located. <BR>Please add telepad data.</div><BR>"
	else
		if(inserted_gps)
			t += "<A href='?src=\ref[src];ejectGPS=1'>Eject GPS</A>"
			t += "<A href='?src=\ref[src];setMemory=1'>Set GPS memory</A>"
		else
			t += "<span class='linkOff'>Eject GPS</span>"
			t += "<span class='linkOff'>Set GPS memory</span>"
		t += "<div class='statusDisplay'>[temp_msg]</div><BR>"
		t += "<A href='?src=\ref[src];setrotation=1'>Set Bearing</A>"
		t += "<div class='statusDisplay'>[rotation]°</div>"
		t += "<A href='?src=\ref[src];setangle=1'>Set Elevation</A>"
		t += "<div class='statusDisplay'>[angle]°</div>"
		t += "<span class='linkOn'>Set Power</span>"
		t += "<div class='statusDisplay'>"

		for(var/i = 1; i <= power_options.len; i++)
			if(power == power_options[i])
				t += "<span class='linkOn'>[power_options[i]]</span>"
				continue
			t += "<A href='?src=\ref[src];setpower=[i]'>[power_options[i]]</A>"
		t += "</div>"

		t += "<A href='?src=\ref[src];setz=1'>Set Sector</A>"
		t += "<div class='statusDisplay'>[z_co ? z_co : "NULL"]</div>"

		if(active_wormhole)
			t += "<BR><span class='linkOff'>Open Wormhole</span><A href='?src=\ref[src];close_teleport=1'>Close Wormhole</A>"
		else
			t += "<BR><A href='?src=\ref[src];open_teleport=1'>Open Wormhole</A><span class='linkOff'>Close Wormhole</span>"
		t += "<BR><A href='?src=\ref[src];recal=1'>Recalibrate Crystals</A> <A href='?src=\ref[src];eject=1'>Eject Crystals</A>"

		// Information about the last teleport
		t += "<BR><div class='statusDisplay'>"
		if(!last_tele_data)
			t += "No teleport data found."
		else
			t += "Source Location: ([last_tele_data.src_x], [last_tele_data.src_y])<BR>"
			//t += "Distance: [round(last_tele_data.distance, 0.1)]m<BR>"
			t += "Time: [round(last_tele_data.time, 0.1)] secs<BR>"
		t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 550)
	popup.set_content(t)
	popup.open()

/obj/machinery/computer/telescience/proc/create_wormhole(turf/exit)
	if(exit.density)
		return FALSE
	if(istype(exit, /turf/space))
		if(exit.x <= TRANSITIONEDGE || exit.x >= (world.maxx - TRANSITIONEDGE - 1) || exit.y <= TRANSITIONEDGE || exit.y >= (world.maxy - TRANSITIONEDGE - 1))
			return FALSE
	for(var/X in exit.contents)
		var/atom/A = X
		if(A.density)
			return FALSE
	active_wormhole = new (telepad.loc, exit)
	active_wormhole.linked_console = src
	return active_wormhole

/obj/machinery/computer/telescience/proc/sparks()
	if(telepad)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, get_turf(telepad))
		s.start()
	else
		return

/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")
	return

/obj/machinery/computer/telescience/proc/close_wormhole()
	if(active_wormhole)
		set_power_use(IDLE_POWER_USE)
		qdel(active_wormhole)
		active_wormhole = null

/obj/machinery/computer/telescience/proc/open_wormhole(mob/user)
	if(active_wormhole)
		return

	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power.<BR>Please wait [round((teleport_cooldown - world.time) / 10)] seconds."
		return

	if(teleporting)
		temp_msg = "Telepad is in use.<BR>Please wait."
		return

	if(telepad)
		var/truePower = clamp(power + power_off, 1, 1000)
		var/trueRotation = rotation + rotation_off
		var/trueAngle = clamp(angle + angle_off, 1, 90)

		var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
		last_tele_data = proj_data

		var/trueX = clamp(round(proj_data.dest_x, 1), 1, world.maxx)
		var/trueY = clamp(round(proj_data.dest_y, 1), 1, world.maxy)
		var/spawn_time = round(proj_data.time) * 10

		var/turf/target = locate(trueX, trueY, z_co)
		last_target = target
		var/area/A = get_area(target)
		flick("pad-beam", telepad)

		if(spawn_time > 15) // 1.5 seconds
			playsound(telepad, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER, 25)
			// Wait depending on the time the projectile took to get there
			teleporting = 1
			temp_msg = "Powering up bluespace crystals.<BR>Please wait."


		spawn(round(proj_data.time) * 10) // in seconds
			teleporting = 0
			if(!telepad)
				return
			if(telepad.stat & NOPOWER)
				return
			if(create_wormhole(target))
				teleport_cooldown = world.time + (power * 2)
				teles_left -= 1

				// use a lot of power
				use_power(power * 1500)
				set_power_use(ACTIVE_POWER_USE)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, get_turf(telepad))
				s.start()

				temp_msg = "Teleport successful."
				if(teles_left < 10)
					temp_msg += "<BR>Calibration required soon."
				else
					temp_msg += "<BR>Data printed below."
				log_investigate("[key_name(usr)]/[user] has teleported with Telescience at [trueX],[trueY],[z_co], in [A ? A.name : "null area"].",INVESTIGATE_TELESCI)

				var/datum/effect/effect/system/spark_spread/SS = new /datum/effect/effect/system/spark_spread
				SS.set_up(5, 1, target)
				SS.start()

				flick("pad-beam", telepad)
				playsound(telepad, 'sound/weapons/guns/gunpulse_emitter2.ogg', VOL_EFFECTS_MASTER, 25)

			else
				use_power(power * 1500)
				var/datum/effect/effect/system/spark_spread/SS = new /datum/effect/effect/system/spark_spread
				SS.set_up(5, 1, get_turf(telepad))
				SS.start()

				flick("pad-beam", telepad)
				playsound(telepad, 'sound/weapons/guns/gunpulse_emitter2.ogg', VOL_EFFECTS_MASTER, 25)
				temp_msg = "Error!<BR>Something wrong with the navigation data."
			updateDialog()

/obj/machinery/computer/telescience/proc/prepare_wormhole(mob/user)
	if(rotation == null || angle == null || z_co == null)
		temp_msg = "ERROR!<BR>Set a angle, rotation and sector."
		return
	if(power <= 0)
		telefail()
		temp_msg = "ERROR!<BR>No power selected!"
		return
	if(angle < 1 || angle > 90)
		telefail()
		temp_msg = "ERROR!<BR>Elevation is less than 1 or greater than 90."
		return
	if(!SSmapping.has_level(z_co) || is_centcom_level(z_co) || is_junkyard_level(z_co)) // Change this to notele trait or something
		telefail()
		temp_msg = "ERROR! This sector is unreachable."
		return
	if(teles_left > 0)
		open_wormhole(user)
	else
		telefail()
		temp_msg = "ERROR!<BR>Calibration required."
		return
	return

/obj/machinery/computer/telescience/proc/eject()
	for(var/obj/item/I in crystals)
		I.loc = src.loc
		crystals -= I
	power = 0

/obj/machinery/computer/telescience/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!telepad)
		updateDialog()
		return FALSE

	if(telepad.panel_open)
		temp_msg = "Telepad undergoing physical maintenance operations."

	if(href_list["setrotation"])
		var/new_rot = input("Please input desired bearing in degrees.", name, rotation) as num
		if(!..()) // Check after we input a value, as they could've moved after they entered something
			return
		rotation = clamp(new_rot, -900, 900)
		rotation = round(rotation, 0.01)

	if(href_list["setangle"])
		var/new_angle = input("Please input desired elevation in degrees.", name, angle) as num
		if(!..())
			return
		angle = clamp(round(new_angle, 0.1), 1, 9999)

	if(href_list["setpower"])
		var/index = href_list["setpower"]
		index = text2num(index)
		if(index != null && power_options[index])
			power = power_options[index]

	if(href_list["setz"])
		var/new_z = input("Please input desired sector.", name, z_co) as num
		if(!..())
			return
		z_co = clamp(round(new_z), 1, 10)

	if(href_list["ejectGPS"])
		inserted_gps.loc = loc
		inserted_gps = null

	if(href_list["setMemory"])
		if(last_target)
			inserted_gps.locked_location = last_target
			temp_msg = "Location saved."
		else
			temp_msg = "ERROR!<BR>No data stored."

	if(href_list["open_teleport"])
		prepare_wormhole(usr)

	if(href_list["close_teleport"])
		close_wormhole(usr)

	if(href_list["recal"])
		recalibrate()
		sparks()
		temp_msg = "NOTICE:<BR>Calibration successful."

	if(href_list["eject"])
		eject()
		temp_msg = "NOTICE:<BR>Bluespace crystals ejected."

	updateDialog()

/obj/machinery/computer/telescience/proc/recalibrate()
	if(telepad)
		teles_left = clamp(crystals.len * telepad.efficiency * 4 + rand(-5, 0), 0, 65)
	else
		teles_left = 0
	angle_off = rand(-25, 25)
	power_off = rand(-4, 0)
	rotation_off = rand(-10, 10)
