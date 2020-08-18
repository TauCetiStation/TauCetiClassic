//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA

#define SIGH 0
#define ANNOYED 1
#define DELIGHT 2

/obj/machinery/bot/mulebot
	name = "Mulebot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	layer = MOB_LAYER
	density = 1
	anchored = 1
	animate_movement=1
	health = 150 //yeah, it's tougher than ed209 because it is a big metal box with wheels --rastaf0
	maxhealth = 150
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5

	can_buckle = 1
	buckle_lying = 0

	suffix = ""
	req_access = list(access_cargo) // added robotics access so assembly line drop-off works properly -veyveyr //I don't think so, Tim. You need to add it to the MULE's hidden robot ID card. -NEO

	var/atom/movable/load = null		// the loaded crate (usually)
	var/beacon_freq = 1400
	var/control_freq = 1447
	var/turf/target				// this is turf to navigate to (location of beacon)
	var/loaddir = 0				// this the direction to unload onto/load from
	var/new_destination = ""	// pending new destination (waiting for beacon response)
	var/destination = ""		// destination description
	var/home_destination = "" 	// tag of home beacon

	var/path[] = new()

	var/mode = 0		//0 = idle/ready
						//1 = loading/unloading
						//2 = moving to deliver
						//3 = returning to home
						//4 = blocked
						//5 = computing navigation
						//6 = waiting for nav computation
						//7 = no destination beacon found (or no route)

	var/blockcount	= 0		//number of times retried a blocked path
	var/reached_target = 1 	//true if already reached the target

	var/refresh = 1		// true to refresh dialogue
	var/auto_return = 1	// true if auto return to home beacon after unload
	var/auto_pickup = 1 // true if auto-pickup at beacon

	var/obj/item/weapon/stock_parts/cell/cell
						// the installed power cell
	var/datum/wires/mulebot/wires = null
	var/bloodiness = 0		// count of bloodiness

/obj/machinery/bot/mulebot/atom_init()
	..()
	wires = new(src)
	botcard = new(src)
	var/datum/job/cargo_tech/J = new/datum/job/cargo_tech
	botcard.access = J.get_access()
//	botcard.access += access_robotics //Why --Ikki
	cell = new(src)
	cell.charge = 2000
	cell.maxcharge = 2000

	if(radio_controller)
		radio_controller.add_object(src, control_freq, filter = RADIO_MULEBOT)
		radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/bot/mulebot/atom_init_late()
	var/count = 0
	for(var/obj/machinery/bot/mulebot/other in bots_list)
		count++
	if(!suffix)
		suffix = "#[count]"
	name = "Mulebot ([suffix])"

/obj/machinery/bot/mulebot/Destroy()
	QDEL_NULL(wires)
	if(radio_controller)
		radio_controller.remove_object(src,beacon_freq)
		radio_controller.remove_object(src,control_freq)
	unload(0)
	return ..()

// attack by item
// emag : lock/unlock,
// screwdriver: open/close hatch
// cell: insert it
// other: chance to knock rider off bot
/obj/machinery/bot/mulebot/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/weapon/stock_parts/cell) && open && !cell)
		var/obj/item/weapon/stock_parts/cell/C = I
		user.drop_item()
		C.loc = src
		cell = C
		updateDialog()
	else if(isscrewdriver(I))
		if(locked)
			to_chat(user, "<span class='notice'>The maintenance hatch cannot be opened or closed while the controls are locked.</span>")
			return

		open = !open
		if(open)
			src.visible_message("[user] opens the maintenance hatch of [src]", "<span class='notice'>You open [src]'s maintenance hatch.</span>")
			on = 0
			icon_state="mulebot-hatch"
		else
			src.visible_message("[user] closes the maintenance hatch of [src]", "<span class='notice'>You close [src]'s maintenance hatch.</span>")
			icon_state = "mulebot0"

		updateDialog()
	else if(is_wire_tool(I))
		wires.interact(user)
	else if (iswrench(I))
		if (src.health < maxhealth)
			src.health = min(maxhealth, src.health+25)
			user.visible_message(
				"<span class='warning'>[user] repairs [src]!</span>",
				"<span class='notice'>You repair [src]!</span>"
			)
		else
			to_chat(user, "<span class='notice'>[src] does not need a repair!</span>")
	else if(load && ismob(load))  // chance to knock off rider
		if(prob(1+I.force * 2))
			unload(0)
			user.visible_message("<span class='warning'>[user] knocks [load] off [src] with \the [I]!</span>", "<span class='warning'>You knock [load] off [src] with \the [I]!</span>")
		else
			to_chat(user, "You hit [src] with \the [I] but to no effect.")
	else
		return ..()

/obj/machinery/bot/mulebot/emag_act(mob/user)
	locked = !locked
	to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the mulebot's controls!</span>")
	flick("mulebot-emagged", src)
	playsound(src, 'sound/effects/sparks1.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	return TRUE

/obj/machinery/bot/mulebot/ex_act(severity)
	unload(0)
	switch(severity)
		if(2)
			wires.random_cut()
			wires.random_cut()
			wires.random_cut()
		if(3)
			wires.random_cut()
	..()
	return

/obj/machinery/bot/mulebot/bullet_act()
	if(prob(50) && !isnull(load))
		unload(0)
	if(prob(25))
		visible_message("<span class='red'>Something shorts out inside [src]!</span>")
		wires.random_cut()
	..()

/obj/machinery/bot/mulebot/ui_interact(mob/user)
	var/ai = isAI(user) || isobserver(user)
	var/dat

	dat += "<TT><B>Multiple Utility Load Effector Mk. III</B></TT><BR><BR>"
	dat += "ID: [suffix]<BR>"
	dat += "Power: [on ? "On" : "Off"]<BR>"

	if(!open)
		dat += "Status: "
		switch(mode)
			if(0)
				dat += "Ready"
			if(1)
				dat += "Loading/Unloading"
			if(2)
				dat += "Navigating to Delivery Location"
			if(3)
				dat += "Navigating to Home"
			if(4)
				dat += "Waiting for clear path"
			if(5,6)
				dat += "Calculating navigation path"
			if(7)
				dat += "Unable to locate destination"


		dat += "<BR>Current Load: [load ? load.name : "<i>none</i>"]<BR>"
		dat += "Destination: [!destination ? "<i>none</i>" : destination]<BR>"
		dat += "Power level: [cell ? cell.percent() : 0]%<BR>"

		if(locked && !ai)
			dat += "<HR>Controls are locked <A href='byond://?src=\ref[src];op=unlock'><I>(unlock)</I></A>"
		else
			dat += "<HR>Controls are unlocked <A href='byond://?src=\ref[src];op=lock'><I>(lock)</I></A><BR><BR>"

			dat += "<A href='byond://?src=\ref[src];op=power'>Toggle Power</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=stop'>Stop</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=go'>Proceed</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=home'>Return to Home</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=destination'>Set Destination</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=setid'>Set Bot ID</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=sethome'>Set Home</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=autoret'>Toggle Auto Return Home</A> ([auto_return ? "On":"Off"])<BR>"
			dat += "<A href='byond://?src=\ref[src];op=autopick'>Toggle Auto Pickup Crate</A> ([auto_pickup ? "On":"Off"])<BR>"

			if(load)
				dat += "<A href='byond://?src=\ref[src];op=unload'>Unload Now</A><BR>"
			dat += "<HR>The maintenance hatch is closed.<BR>"

	else
		if(!ai)
			dat += "The maintenance hatch is open.<BR><BR>"
			dat += "Power cell: "
			if(cell)
				dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
			else
				dat += "<A href='byond://?src=\ref[src];op=cellinsert'>Removed</A><BR>"
		else
			dat += "The bot is in maintenance mode and cannot be controlled.<BR>"

	var/datum/browser/popup = new(user, "window=mulebot", src.name, 350, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/bot/mulebot/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	switch(href_list["op"])
		if("lock", "unlock")
			if(src.allowed(usr))
				locked = !locked
			else
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return FALSE
		if("power")
			if (src.on)
				turn_off()
			else if (cell && !open)
				if (!turn_on())
					to_chat(usr, "<span class='warning'>You can't switch on [src].</span>")
					return FALSE
			else
				return FALSE
			visible_message("[usr] switches [on ? "on" : "off"] [src].")


		if("cellremove")
			if(open && cell && !usr.get_active_hand())
				cell.updateicon()
				usr.put_in_active_hand(cell)
				cell.add_fingerprint(usr)
				cell = null

				usr.visible_message("<span class='notice'>[usr] removes the power cell from [src].</span>", "<span class='notice'>You remove the power cell from [src].</span>")

		if("cellinsert")
			if(open && !cell)
				var/obj/item/weapon/stock_parts/cell/C = usr.get_active_hand()
				if(istype(C))
					usr.drop_item()
					cell = C
					C.loc = src
					C.add_fingerprint(usr)

					usr.visible_message("<span class='notice'>[usr] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")


		if("stop")
			if(mode >=2)
				mode = 0

		if("go")
			if(mode == 0)
				start()

		if("home")
			if(mode == 0 || mode == 2)
				start_home()

		if("destination")
			refresh=0
			var/new_dest = sanitize_safe(input("Enter new destination tag", "Mulebot [suffix ? "([suffix])" : ""]", input_default(destination)) as text|null, MAX_LNAME_LEN)
			refresh=1
			if(new_dest)
				set_destination(new_dest)


		if("setid")
			refresh=0
			var/new_id = sanitize_safe(input("Enter new bot ID", "Mulebot [suffix ? "([suffix])" : ""]", input_default(suffix)) as text|null, MAX_LNAME_LEN)
			refresh=1
			if(new_id)
				suffix = new_id
				name = "Mulebot ([suffix])"

		if("sethome")
			refresh=0
			var/new_home = sanitize_safe(input("Enter new home tag", "Mulebot [suffix ? "([suffix])" : ""]", input_default(home_destination)) as text|null, MAX_LNAME_LEN)
			refresh=1
			if(new_home)
				home_destination = new_home

		if("unload")
			if(load && mode !=1)
				if(loc == target)
					unload(loaddir)
				else
					unload(0)

		if("autoret")
			auto_return = !auto_return

		if("autopick")
			auto_pickup = !auto_pickup

		if("close")
			usr.unset_machine()
			usr << browse(null,"window=mulebot")

	updateDialog()

// returns true if the bot has power
/obj/machinery/bot/mulebot/proc/has_power()
	return !open && cell && cell.charge>0 && wires.has_power()

/obj/machinery/bot/mulebot/proc/buzz(type)
	switch(type)
		if(SIGH)
			visible_message("[src] makes a sighing buzz.", "<span class='italics'>You hear an electronic buzzing sound.</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		if(ANNOYED)
			visible_message("[src] makes an annoyed buzzing sound.", "<span class='italics'>You hear an electronic buzzing sound.</span>")
			playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		if(DELIGHT)
			visible_message("[src] makes a delighted ping!", "<span class='italics'>You hear a ping.</span>")
			playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/bot/mulebot/MouseDrop_T(atom/movable/AM, mob/user)
	if(user.incapacitated() || user.lying)
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	if (!istype(AM))
		return

	load(AM)

// mousedrop a crate to load the bot
// can load anything if emagged
/obj/machinery/bot/mulebot/MouseDrop_T(atom/movable/AM, mob/user)
	if(user.incapacitated() || user.lying)
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	if (!istype(AM))
		return

	load(AM)

// called to load a crate
/obj/machinery/bot/mulebot/proc/load(atom/movable/AM)
	if(load ||  AM.anchored)
		return
	if(!isturf(AM.loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
		return

	var/obj/structure/closet/crate/CRATE
	if(istype(AM,/obj/structure/closet/crate))
		CRATE = AM
	else
		if(wires.load_check())
			buzz(SIGH)
			return		// if not emagged, only allow crates to be loaded

	if(CRATE) // if it's a crate, close before loading
		CRATE.close()

	if(isobj(AM))
		var/obj/O = AM
		if(O.buckled_mob || (locate(/mob) in AM)) //can't load non crates objects with mobs buckled to it or inside it.
			buzz(SIGH)
			return

	if(isliving(AM))
		if(!buckle_mob(AM))
			return
	else
		AM.loc = src
		AM.pixel_y += 9
		if(AM.layer < layer)
			AM.layer = layer + 0.1
		add_overlay(AM)

	load= AM
	mode = 0
	send_status()

/obj/machinery/bot/mulebot/buckle_mob(mob/living/M)
	if(M.buckled)
		return 0
	var/turf/T = get_turf(src)
	if(M.loc != T)
		density = 0
		var/can_step = step_towards(M, T)
		density = 1
		if(!can_step)
			return 0
	return ..()


/obj/machinery/bot/mulebot/post_buckle_mob(mob/living/M)
	if(M == buckled_mob) //post buckling
		M.pixel_y = initial(M.pixel_y) + 9
		if(M.layer < layer)
			M.layer = layer + 0.1

	else //post unbuckling
		load = null
		M.layer = initial(M.layer)
		M.plane = initial(M.plane)
		M.pixel_y = initial(M.pixel_y)

// called to unload the bot
// argument is optional direction to unload
// if zero, unload at bot's location
/obj/machinery/bot/mulebot/proc/unload(dirn)
	if(!load)
		return

	mode = 0

	cut_overlays()

	if(buckled_mob)
		unbuckle_mob()
		return

	load.loc = loc
	load.pixel_y = initial(load.pixel_y)
	load.layer = initial(load.layer)
	load.plane = initial(load.plane)
	if(dirn)
		var/turf/T = loc
		var/turf/newT = get_step(T,dirn)
		if(load.CanPass(load,newT)) //Can't get off onto anything that wouldn't let you pass normally
			step(load, dirn)

	load = null


/obj/machinery/bot/mulebot/process()
	if(!has_power())
		on = 0
		return
	if(on)
		var/speed = (wires.motor1() ? 1 : 0) + (wires.motor2() ? 2 : 0)
		//world << "speed: [speed]"
		switch(speed)
			if(0)
				// do nothing
			if(1)
				process_bot()
				spawn(2)
					process_bot()
					sleep(2)
					process_bot()
					sleep(2)
					process_bot()
					sleep(2)
					process_bot()
			if(2)
				process_bot()
				spawn(4)
					process_bot()
			if(3)
				process_bot()

	if(refresh) updateDialog()

/obj/machinery/bot/mulebot/proc/process_bot()
	if(!on)
		return

	switch(mode)
		if(0)		// idle
			icon_state = "mulebot0"
			return
		if(1)		// loading/unloading
			return
		if(2,3,4)		// navigating to deliver,home, or blocked

			if(loc == target)		// reached target
				at_target()
				return

			else if(path.len > 0 && target)		// valid path

				var/turf/next = path[1]
				reached_target = 0
				if(next == loc)
					path -= next
					return


				if(istype( next, /turf/simulated))
					if(bloodiness)
						var/obj/effect/decal/cleanable/blood/tracks/B = new(loc)
						var/newdir = get_dir(next, loc)
						if(newdir == dir)
							B.dir = newdir
						else
							newdir = newdir | dir
							if(newdir == 3)
								newdir = 1
							else if(newdir == 12)
								newdir = 4
							B.dir = newdir
						bloodiness--

					var/moved = step_towards(src, next)	// attempt to move
					if(cell) cell.use(1)
					if(moved)	// successful move
						blockcount = 0
						path -= loc


						if(mode==4)
							spawn(1)
								send_status()

						if(destination == home_destination)
							mode = 3
						else
							mode = 2

					else		// failed to move

						blockcount++
						mode = 4
						if(blockcount == 3)
							buzz(ANNOYED)

						if(blockcount > 5)	// attempt 5 times before recomputing
							// find new path excluding blocked turf
							buzz(SIGH)

							spawn(2)
								calc_path(next)
								if(path.len > 0)
									buzz(DELIGHT)
								mode = 4
							mode =6
							return
						return
				else
					buzz(ANNOYED)
					mode = 5
					return
			else
				mode = 5
				return

		if(5)		// calculate new path
			mode = 6
			spawn(0)

				calc_path()

				if(path.len > 0)
					blockcount = 0
					mode = 4
					buzz(DELIGHT)

				else
					buzz(SIGH)

					mode = 7
	return


// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/mulebot/proc/calc_path(turf/avoid = null)
	src.path = get_path_to(src.loc, src.target, /turf/proc/Distance_cardinal, 0, 250, id=botcard, exclude=avoid)


// sets the current destination
// signals all beacons matching the delivery code
// beacons will return a signal giving their locations
/obj/machinery/bot/mulebot/proc/set_destination(new_dest)
	spawn(0)
		new_destination = new_dest
		post_signal(beacon_freq, "findbeacon", "delivery")
		updateDialog()

// starts bot moving to current destination
/obj/machinery/bot/mulebot/proc/start()
	if(!on)
		return
	if(destination == home_destination)
		mode = 3
	else
		mode = 2
	icon_state = "mulebot[wires.mob_avoid()]"

// starts bot moving to home
// sends a beacon query to find
/obj/machinery/bot/mulebot/proc/start_home()
	if(!on)
		return
	spawn(0)
		set_destination(home_destination)
		mode = 4
	icon_state = "mulebot[wires.mob_avoid()]"

// called when bot reaches current target
/obj/machinery/bot/mulebot/proc/at_target()
	if(!reached_target)
		src.visible_message("[src] makes a chiming sound!", "You hear a chime.")
		playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		reached_target = 1

		if(load)		// if loaded, unload at target
			unload(loaddir)
		else
			// not loaded
			if(auto_pickup)		// find a crate
				var/atom/movable/AM
				if(!wires.load_check())		// if emagged, load first unanchored thing we find
					for(var/atom/movable/A in get_step(loc, loaddir))
						if(!A.anchored)
							AM = A
							break
				else			// otherwise, look for crates only
					AM = locate(/obj/structure/closet/crate) in get_step(loc,loaddir)
				if(AM && AM.Adjacent(src))
					load(AM)
		// whatever happened, check to see if we return home

		if(auto_return && destination != home_destination)
			// auto return set and not at home already
			start_home()
			mode = 4
		else
			mode = 0	// otherwise go idle

	send_status()	// report status to anyone listening

	return

// called when bot bumps into anything
/obj/machinery/bot/mulebot/Bump(atom/obs)
	if(!wires.mob_avoid())		//usually just bumps, but if avoidance disabled knock over mobs
		var/mob/M = obs
		if(ismob(M))
			if(istype(M,/mob/living/silicon/robot))
				src.visible_message("<span class='warning'>[src] bumps into [M]!</span>")
			else
				src.visible_message("<span class='warning'>[src] knocks over [M]!</span>")
				M.stop_pulling()
				M.Stun(8)
				M.Weaken(5)
				M.lying = 1
	..()

/obj/machinery/bot/mulebot/alter_health()
	return get_turf(src)


// called from mob/living/carbon/human/Crossed()
// when mulebot is in the same loc
/obj/machinery/bot/mulebot/proc/RunOver(mob/living/carbon/human/H)
	src.visible_message("<span class='warning'>[src] drives over [H]!</span>")
	playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)

	var/damage = rand(5,15)
	H.apply_damage(2*damage, BRUTE, BP_HEAD)
	H.apply_damage(2*damage, BRUTE, BP_CHEST)
	H.apply_damage(0.5*damage, BRUTE, BP_L_LEG)
	H.apply_damage(0.5*damage, BRUTE, BP_R_LEG)
	H.apply_damage(0.5*damage, BRUTE, BP_L_ARM)
	H.apply_damage(0.5*damage, BRUTE, BP_R_ARM)

	var/obj/effect/decal/cleanable/blood/B = new(src.loc)
	B.blood_DNA = list()
	B.blood_DNA[H.dna.unique_enzymes] = H.dna.b_type

	bloodiness += 4

// player on mulebot attempted to move
/obj/machinery/bot/mulebot/relaymove(mob/user)
	if(user.incapacitated())
		return
	if(load == user)
		unload(0)

// receive a radio signal
// used for control and beacon reception

/obj/machinery/bot/mulebot/receive_signal(datum/signal/signal)

	if(!on)
		return

	/*
	to_chat(world, "rec signal: [signal.source]")
	for(var/x in signal.data)
		to_chat(world, "* [x] = [signal.data[x]]")
	*/
	var/recv = signal.data["command"]
	// process all-bot input
	if(recv=="bot_status" && wires.remote_rx())
		send_status()


	recv = signal.data["command [suffix]"]
	if(wires.remote_rx())
		// process control input
		switch(recv)
			if("stop")
				mode = 0
				return

			if("go")
				start()
				return

			if("target")
				set_destination(signal.data["destination"] )
				return

			if("unload")
				if(loc == target)
					unload(loaddir)
				else
					unload(0)
				return

			if("home")
				start_home()
				return

			if("bot_status")
				send_status()
				return

			if("autoret")
				auto_return = text2num(signal.data["value"])
				return

			if("autopick")
				auto_pickup = text2num(signal.data["value"])
				return

	// receive response from beacon
	recv = signal.data["beacon"]
	if(wires.beacon_rx())
		if(recv == new_destination)	// if the recvd beacon location matches the set destination
									// the we will navigate there
			destination = new_destination
			target = signal.source.loc
			var/direction = signal.data["dir"]	// this will be the load/unload dir
			if(direction)
				loaddir = text2num(direction)
			else
				loaddir = 0
			icon_state = "mulebot[wires.mob_avoid()]"
			calc_path()
			updateDialog()

// send a radio signal with a single data key/value pair
/obj/machinery/bot/mulebot/proc/post_signal(freq, key, value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/mulebot/proc/post_signal_multiple(freq, list/keyval)

	if(freq == beacon_freq && !wires.beacon_rx())
		return
	if(freq == control_freq && !wires.remote_tx())
		return

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency) return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	//for(var/key in keyval)
	//	signal.data[key] = keyval[key]
	signal.data = keyval
		//world << "sent [key],[keyval[key]] on [freq]"
	if (signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if (signal.data["type"] == "mulebot")
		frequency.post_signal(src, signal, filter = RADIO_MULEBOT)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/mulebot/proc/send_status()
	var/list/kv = list(
		"type" = "mulebot",
		"name" = suffix,
		"loca" = (loc ? loc.loc : "Unknown"),	// somehow loc can be null and cause a runtime - Quarxink
		"mode" = mode,
		"powr" = (cell ? cell.percent() : 0),
		"dest" = destination,
		"home" = home_destination,
		"load" = load,
		"retn" = auto_return,
		"pick" = auto_pickup,
	)
	post_signal_multiple(control_freq, kv)

/obj/machinery/bot/mulebot/emp_act(severity)
	if (cell)
		cell.emplode(severity)
	if(load)
		load.emplode(severity)
	..()


/obj/machinery/bot/mulebot/explode()
	src.visible_message("<span class='danger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut/red(Tsec)
	if (cell)
		cell.loc = Tsec
		cell.update_icon()
		cell = null

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	qdel(src)

#undef SIGH
#undef ANNOYED
#undef DELIGHT
