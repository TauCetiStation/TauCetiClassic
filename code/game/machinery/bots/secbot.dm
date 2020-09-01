/obj/machinery/bot/secbot
	name = "Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot0"
	var/icon_state_arrest = "secbot-c"
	layer = 5.0
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5

	req_one_access = list(access_security, access_forensics_lockers)
	var/mob/living/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/frustration = 0
	var/lasercolor = "" //Used by ED209
//	var/emagged = 0 //Emagged Secbots view everyone as a criminal
	var/idcheck = 0 //If false, all station IDs are authorized for weapons.
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	var/declare_arrests = 1 //When making an arrest, should it notify everyone wearing sechuds?
	var/next_harm_time = 0

	var/mode = 0

	var/auto_patrol = 0		// set to make bot automatically patrol

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = 1447		// bot control frequency


	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route
	var/list/path = new				// list of path turfs

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/nearest_beacon			// the nearest beacon's tag
	var/turf/nearest_beacon_loc	// the nearest beacon's location


/obj/machinery/bot/secbot/beepsky
	name = "Officer Beep O'sky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey."
	idcheck = 0
	auto_patrol = 1
	layer = MOB_LAYER

/obj/item/weapon/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess


/obj/machinery/bot/secbot/atom_init()
	. = ..()
	botcard = new /obj/item/weapon/card/id(src)
	var/datum/job/cadet/C = new/datum/job/cadet
	botcard.access = C.get_access()
	if(radio_controller)
		radio_controller.add_object(src, control_freq, filter = RADIO_SECBOT)
		radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)
	update_icon()

/obj/machinery/bot/secbot/turn_on()
	..()
	same_pos_count = 0
	update_icon()
	updateUsrDialog()

/obj/machinery/bot/secbot/turn_off()
	..()
	target = null
	oldtarget_name = null
	anchored = 0
	mode = SECBOT_IDLE
	walk_to(src, 0)
	update_icon()
	updateUsrDialog()

/obj/machinery/bot/secbot/ui_interact(mob/user)
	var/dat

	dat += text({"
		<TT><B>Automatic Security Unit v1.3</B></TT><BR><BR>
		Status: []<BR>
		Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
		Maintenance panel panel is [open ? "opened" : "closed"]"},

		"<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user) || isobserver(user))
		dat += text({"<BR>
			Check for Weapon Authorization: []<BR>
			Check Security Records: []<BR>
			Operating Mode: []<BR>
			Report Arrests: []<BR>
			Auto Patrol: []"},

			"<A href='?src=\ref[src];operation=idcheck'>[idcheck ? "Yes" : "No"]</A>",
			"<A href='?src=\ref[src];operation=ignorerec'>[check_records ? "Yes" : "No"]</A>",
			"<A href='?src=\ref[src];operation=switchmode'>[arrest_type ? "Detain" : "Arrest"]</A>",
			"<A href='?src=\ref[src];operation=declarearrests'>[declare_arrests ? "Yes" : "No"]</A>",
			"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )

	var/datum/browser/popup = new(user, "window=autosec", src.name)
	popup.set_content(dat)
	popup.open()

/obj/machinery/bot/secbot/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["power"] && allowed(usr))
		if(on)
			turn_off()
		else
			turn_on()
		return

	switch(href_list["operation"])
		if("idcheck")
			idcheck = !idcheck
		if("ignorerec")
			check_records = !check_records
		if("switchmode")
			arrest_type = !arrest_type
		if("patrol")
			auto_patrol = !auto_patrol
			mode = SECBOT_IDLE
		if("declarearrests")
			declare_arrests = !declare_arrests

	updateUsrDialog()

/obj/machinery/bot/secbot/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>ERROR</span>")
		else if(open)
			to_chat(user, "<span class='red'>Please close the access panel before locking it.</span>")
		else if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
		else
			to_chat(user, "<span class='notice'>Access denied.</span>")
	else
		. = ..()
		beingAttacked(W, user)


/obj/machinery/bot/secbot/proc/beingAttacked(obj/item/weapon/W, mob/user)
	if(!isscrewdriver(W) && W.force && !target)
		target = user
		mode = SECBOT_HUNT

/obj/machinery/bot/secbot/proc/forgetCurrentTarget()
	target = null
	last_found = world.time
	mode = SECBOT_IDLE
	walk_to(src, 0)
	frustration = 0
	anchored = FALSE

/obj/machinery/bot/secbot/emag_act(mob/user)
	..()
	if(open && !locked)
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s target assessment circuits.</span>")
		audible_message("<span class='userdanger'>[src] buzzes oddly!</span>")
		target = null
		if(user)
			oldtarget_name = user.name
		last_found = world.time
		anchored = 0
		emagged = 2
		on = 1
		update_icon()
		mode = SECBOT_IDLE

/obj/machinery/bot/secbot/is_on_patrol()
	return mode == SECBOT_START_PATROL

/obj/machinery/bot/secbot/process()
	if(!on)
		return
	if(!inaction_check())
		return

	switch(mode)
		if(SECBOT_IDLE)		// idle
			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = SECBOT_START_PATROL	// switch to patrol mode

		if(SECBOT_HUNT)		// hunting for perp
			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				forgetCurrentTarget()

			if(target)		// make sure target exists
				if(Adjacent(target) && istype(target.loc, /turf))
					if(iscarbon(target))
						playsound(src, 'sound/weapons/Egloves.ogg', VOL_EFFECTS_MASTER)
						icon_state = "[lasercolor][icon_state_arrest]"
						addtimer(CALLBACK(src, .proc/update_icon), 2)
						var/mob/living/carbon/M = target
						do_attack_animation(M)
						M.apply_effect(60, AGONY, 0) // As much as a normal stunbaton

						if(declare_arrests)
							var/area/location = get_area(src)
							broadcast_security_hud_message("[name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] suspect <b>[target]</b> in <b>[location]</b>", src)
						visible_message("<span class='danger'>[target] has been stunned by [src]!</span>")

						mode = SECBOT_PREP_ARREST
						anchored = TRUE
						target_lastloc = M.loc
						return

					else
						//just harmbaton them until dead
						if(world.time > next_harm_time)
							next_harm_time = world.time + 15
							playsound(src, 'sound/weapons/Egloves.ogg', VOL_EFFECTS_MASTER)
							visible_message("<span class='danger'>[src] beats [target] with the stun baton!</span>")
							icon_state = "[lasercolor][icon_state_arrest]"
							addtimer(CALLBACK(src, .proc/update_icon), 2)
							do_attack_animation(target)
							target.adjustBruteLoss(15)
							if(target.stat)
								forgetCurrentTarget()
								playsound(src, pick(SOUNDIN_BEEPSKY), VOL_EFFECTS_MASTER, null, FALSE)

				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					walk_to(src, target, 1, 4)
					if(get_dist(src, target) >= olddist)
						frustration++
					else
						frustration = 0
			else
				frustration = 8

		if(SECBOT_PREP_ARREST)		// preparing to arrest target
			// see if he got away
			if(!Adjacent(target) || ((target.loc != target_lastloc) && (target.weakened < 2)))
				anchored = 0
				mode = SECBOT_HUNT
				return

			if(iscarbon(target))
				var/mob/living/carbon/C = target
				if(!C.handcuffed && !arrest_type)
					playsound(src, 'sound/weapons/handcuffs.ogg', VOL_EFFECTS_MASTER, 30, null, -2)
					mode = SECBOT_ARREST
					visible_message("<span class='warning bold'>[src] is trying to put handcuffs on [target]!</span>")
					addtimer(CALLBACK(src, .proc/subprocess, SECBOT_PREP_ARREST), 60)

			else
				forgetCurrentTarget()

		if(SECBOT_ARREST)		// arresting
			if(!target || !iscarbon(target))
				forgetCurrentTarget()
			else
				var/mob/living/carbon/C = target
				if(C.handcuffed)
					forgetCurrentTarget()

		if(SECBOT_START_PATROL)	// start a patrol
			if(path.len > 0 && patrol_target)	// have a valid path, so just resume
				mode = SECBOT_PATROL
				return

			else if(patrol_target)		// has patrol target already
				INVOKE_ASYNC(src, .proc/subprocess, SECBOT_START_PATROL)

			else					// no patrol target, so need a new one
				find_patrol_target()
				speak("Engaging patrol mode.")


		if(SECBOT_PATROL)		// patrol mode
			patrol_step()
			addtimer(CALLBACK(src, .proc/subprocess, SECBOT_PATROL), 5)

		if(SECBOT_SUMMON)		// summoned to PDA
			patrol_step()
			addtimer(CALLBACK(src, .proc/subprocess, SECBOT_SUMMON), 4)
			addtimer(CALLBACK(src, .proc/subprocess, SECBOT_SUMMON), 8)

/obj/machinery/bot/secbot/proc/subprocess(oldmode)
	switch(oldmode)
		if(SECBOT_PREP_ARREST)
			if(!target) //All will be cleared in /process()
				return
			if(Adjacent(target))
				if(iscarbon(target))
					var/mob/living/carbon/mob_carbon = target
					mob_carbon.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(mob_carbon), SLOT_HANDCUFFED)
				forgetCurrentTarget()
				playsound(src, pick(SOUNDIN_BEEPSKY), VOL_EFFECTS_MASTER, null, FALSE)
			else if(mode == SECBOT_ARREST)
				anchored = FALSE
				mode = SECBOT_HUNT

		if(SECBOT_START_PATROL)
			calc_path()		// so just find a route to it
			if(path.len == 0)
				patrol_target = 0
				return
			mode = SECBOT_PATROL

		if(SECBOT_PATROL)
			if(mode == SECBOT_PATROL)
				patrol_step()

		if(SECBOT_SUMMON)
			if(mode == SECBOT_SUMMON)
				patrol_step()


/obj/machinery/bot/secbot/update_icon()
	icon_state = "secbot[on]"

// perform a single patrol step

/obj/machinery/bot/secbot/proc/patrol_step()
	if(loc == patrol_target)		// reached target
		at_patrol_target()
		return

	else if(path.len > 0 && patrol_target)		// valid path
		var/turf/next = path[1]
		if(next == loc)
			path -= next
			return

		if(istype(next, /turf/simulated))
			var/moved = step_towards(src, next)	// attempt to move
			if(moved)	// successful move
				blockcount = 0
				path -= loc
				look_for_perp()
			else		// failed to move
				blockcount++
				if(blockcount > 5)	// attempt 5 times before recomputing
					// find new path excluding blocked turf
					addtimer(CALLBACK(src, .proc/patrol_substep, next), 2)

		else	// not a valid turf
			mode = SECBOT_IDLE

	else	// no path, so calculate new one
		mode = SECBOT_START_PATROL

/obj/machinery/bot/secbot/proc/patrol_substep(turf/next)
	calc_path(next)
	if(path.len == 0)
		find_patrol_target()
	else
		blockcount = 0

// finds a new patrol target
/obj/machinery/bot/secbot/proc/find_patrol_target()
	send_status()
	if(awaiting_beacon)			// awaiting beacon response
		awaiting_beacon++
		if(awaiting_beacon > 5)	// wait 5 secs for beacon response
			find_nearest_beacon()	// then go to nearest instead
		return

	if(next_destination)
		set_destination(next_destination)
	else
		find_nearest_beacon()


// finds the nearest beacon to self
// signals all beacons matching the patrol code
/obj/machinery/bot/secbot/proc/find_nearest_beacon()
	nearest_beacon = null
	new_destination = "__nearest__"
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1
	addtimer(CALLBACK(src, .proc/find_nearest_beacon_substep), 10)

/obj/machinery/bot/secbot/proc/find_nearest_beacon_substep()
	awaiting_beacon = 0
	if(nearest_beacon)
		set_destination(nearest_beacon)
	else
		auto_patrol = 0
		mode = SECBOT_IDLE
		speak("Disengaging patrol mode.")
		send_status()

/obj/machinery/bot/secbot/proc/at_patrol_target()
	find_patrol_target()


// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/secbot/proc/set_destination(new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1


// receive a radio signal
// used for beacon reception

/obj/machinery/bot/secbot/receive_signal(datum/signal/signal)
	//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/bot/secbot/receive_signal([signal.debug_print()])")
	if(!on)
		return

	/*
	to_chat(world, "rec signal: [signal.source]")
	for(var/x in signal.data)
		to_chat(world, "* [x] = [signal.data[x]]")
	*/

	var/recv = signal.data["command"]
	// process all-bot input
	if(recv == "bot_status")
		send_status()

	// check to see if we are the commanded bot
	if(signal.data["active"] == src)
	// process control input
		switch(recv)
			if("stop")
				mode = SECBOT_IDLE
				auto_patrol = 0
				return

			if("go")
				mode = SECBOT_IDLE
				auto_patrol = 1
				return

			if("summon")
				patrol_target = signal.data["target"]
				next_destination = destination
				destination = null
				awaiting_beacon = 0
				mode = SECBOT_SUMMON
				calc_path()
				speak("Responding.")
				return


	// receive response from beacon
	recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	if(recv == new_destination)	// if the recvd beacon location matches the set destination
								// the we will navigate there
		destination = new_destination
		patrol_target = signal.source.loc
		next_destination = signal.data["next_patrol"]
		awaiting_beacon = 0

	// if looking for nearest beacon
	else if(new_destination == "__nearest__")
		var/dist = get_dist(src,signal.source.loc)
		if(nearest_beacon)

			// note we ignore the beacon we are located at
			if(dist > 1 && dist < get_dist(src, nearest_beacon_loc))
				nearest_beacon = recv
				nearest_beacon_loc = signal.source.loc
				return
			else
				return
		else if(dist > 1)
			nearest_beacon = recv
			nearest_beacon_loc = signal.source.loc


// send a radio signal with a single data key/value pair
/obj/machinery/bot/secbot/proc/post_signal(freq, key, value)
	post_signal_multiple(freq, list("[key]" = value))

// send a radio signal with multiple data key/values
/obj/machinery/bot/secbot/proc/post_signal_multiple(freq, list/keyval)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)
	if(!frequency)
		return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	//for(var/key in keyval)
	//	signal.data[key] = keyval[key]
	signal.data = keyval
		//world << "sent [key],[keyval[key]] on [freq]"
	if(signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if(signal.data["type"] == "secbot")
		frequency.post_signal(src, signal, filter = RADIO_SECBOT)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/secbot/proc/send_status()
	if(!(src && loc && loc.loc))
		return
	var/list/kv = list(
	"type" = "secbot",
	"name" = name,
	"loca" = loc.loc,	// area
	"mode" = mode
	)
	post_signal_multiple(control_freq, kv)



// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/secbot/proc/calc_path(turf/avoid = null)
	path = get_path_to(src, patrol_target, /turf/proc/Distance, 0, 120, id=botcard, exclude=avoid)

// look for a criminal in view of the bot

/obj/machinery/bot/secbot/proc/look_for_perp()
	anchored = 0
	for(var/mob/living/L in view(7, src)) //Let's find us a criminal
		if(L.stat)
			continue

		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if(C.handcuffed)
				continue

		if((L.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = assess_perp(L)

		if(threatlevel >= 4)
			target = L
			oldtarget_name = L.name
			speak("Level [threatlevel] infraction alert!")
			playsound(src, pick('sound/voice/beepsky/criminal.ogg', 'sound/voice/beepsky/justice.ogg', 'sound/voice/beepsky/freeze.ogg'), VOL_EFFECTS_MASTER, null, FALSE)
			visible_message("<b>[src]</b> points at [L.name]!")
			mode = SECBOT_HUNT
			process() // ensure bot quickly responds to a perp
			break
		else
			continue


//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
/obj/machinery/bot/secbot/proc/assess_perp(mob/living/perp)
	var/threatcount = 0

	if(!istype(perp))
		return 0

	if(emagged == 2)
		return 10 //Everyone is a criminal!

	threatcount = perp.assess_perp(src, FALSE, idcheck, FALSE, check_records)
	return threatcount

/obj/machinery/bot/secbot/Bump(atom/M) //Leave no door unopened!
	if(istype(M, /obj/machinery/door) && !isnull(botcard))
		var/obj/machinery/door/D = M
		if(!istype(D, /obj/machinery/door/firedoor) && D.check_access(botcard) && !istype(D,/obj/machinery/door/poddoor))
			D.open()
			frustration = 0
	else if(isliving(M) && !anchored)
		loc = M.loc
		frustration = 0

/obj/machinery/bot/secbot/proc/speak(message)
	audible_message("<span class='name'>[src]</span> beeps, \"[message]\"")


/obj/machinery/bot/secbot/explode()
	walk_to(src,0)
	visible_message("<span class='warning'><B>[src] blows apart!</B></span>")
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/secbot_assembly/Sa = new /obj/item/weapon/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.add_overlay(image('icons/obj/aibots.dmi', "hs_hole"))
	Sa.created_name = name
	new /obj/item/device/assembly/prox_sensor(Tsec)

	var/obj/item/weapon/melee/baton/B = new /obj/item/weapon/melee/baton(Tsec)
	B.charges = 0

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(loc)
	qdel(src)

/obj/machinery/bot/secbot/attack_alien(mob/living/carbon/xenomorph/user)
	..()
	if(!isxeno(target))
		target = user
		mode = SECBOT_HUNT

//Secbot Construction

/obj/item/clothing/head/helmet/attackby(obj/item/I, mob/user, params)
	if(!issignaler(I)) //Eh, but we don't want people making secbots out of space helmets.
		return ..()

	var/obj/item/device/assembly/signaler/S = I
	if(!S.secured)
		return ..()

	var/obj/item/weapon/secbot_assembly/A = new /obj/item/weapon/secbot_assembly
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>You add \the [S] to the helmet.</span>")
	qdel(S)
	qdel(src)

/obj/item/weapon/secbot_assembly/attackby(obj/item/I, mob/user, params)
	if(iswelder(I) && !build_step)
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.use(0, user))
			build_step++
			add_overlay(image('icons/obj/aibots.dmi', "hs_hole"))
			to_chat(user, "You weld a hole in [src]!")

	else if(isprox(I) && build_step == 1)
		build_step++
		to_chat(user, "You add the prox sensor to [src]!")
		add_overlay(image('icons/obj/aibots.dmi', "hs_eye"))
		name = "helmet/signaler/prox sensor assembly"
		qdel(I)

	else if((istype(I, /obj/item/robot_parts/l_arm) || istype(I, /obj/item/robot_parts/r_arm)) && (build_step == 2))
		build_step++
		to_chat(user, "You add the robot arm to [src]!")
		name = "helmet/signaler/prox sensor/robot arm assembly"
		add_overlay(image('icons/obj/aibots.dmi', "hs_arm"))
		qdel(I)

	else if(istype(I, /obj/item/weapon/melee/baton) && (build_step >= 3))
		build_step++
		to_chat(user, "You complete the Securitron! Beep boop.")
		var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot
		S.loc = get_turf(src)
		S.name = created_name
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter new robot name", name, input_default(created_name)), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t

	else
		return ..()
