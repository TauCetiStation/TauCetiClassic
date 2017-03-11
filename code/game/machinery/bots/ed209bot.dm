/obj/machinery/bot/ed209
	name = "ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed2090"
	layer = 5.0
	density = 0
	anchored = 0
//	weight = 1.0E7
	req_one_access = list(access_security, access_forensics_lockers)
	health = 100
	maxhealth = 100
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5

	var/lastfired = 0
	var/shot_delay = 3 //.3 seconds between shots
	var/lasercolor = ""
	var/disabled = 0//A holder for if it needs to be disabled, if true it will not seach for targets, shoot at targets, or move, currently only used for lasertag

	//var/lasers = 0

	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/frustration = 0
//var/emagged = 0 //Emagged Secbots view everyone as a criminal
	var/idcheck = 1 //If false, all station IDs are authorized for weapons.
	var/check_records = 1 //Does it check security records? Checks arrest status and existence of record
	var/arrest_type = 0 //If true, don't handcuff
	var/declare_arrests = 1 //When making an arrest, should it notify everyone wearing sechuds?
	var/projectile = null//Holder for projectile type, to avoid so many else if chains

	var/mode = 0
#define SECBOT_IDLE 		0		// idle
#define SECBOT_HUNT 		1		// found target, hunting
#define SECBOT_PREP_ARREST 	2		// at target, preparing to arrest
#define SECBOT_ARREST		3		// arresting target
#define SECBOT_START_PATROL	4		// start patrol
#define SECBOT_PATROL		5		// patrolling
#define SECBOT_SUMMON		6		// summoned by PDA

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


/obj/item/weapon/ed209_assembly
	name = "ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = ""


/obj/machinery/bot/ed209/New(loc,created_name,created_lasercolor)
	..()
	if(created_name)
		name = created_name
	if(created_lasercolor)
		lasercolor = created_lasercolor
	update_icon()
	if(lasercolor)
		shot_delay = 6		//Longer shot delay because JESUS CHRIST
		check_records = 0	//Don't actively target people set to arrest
		arrest_type = 1		//Don't even try to cuff
		req_access = list(access_maint_tunnels)
		arrest_type = 1
		if((lasercolor == "b") && (name == "ED-209 Security Robot"))//Picks a name if there isn't already a custome one
			name = pick("BLUE BALLER","SANIC","BLUE KILLDEATH MURDERBOT")
		if((lasercolor == "r") && (name == "ED-209 Security Robot"))
			name = pick("RED RAMPAGE","RED ROVER","RED KILLDEATH MURDERBOT")
	addtimer(CALLBACK(src, .proc/post_creation), 3)


/obj/machinery/bot/ed209/proc/post_creation()
	botcard = new /obj/item/weapon/card/id(src)
	var/datum/job/detective/J = new/datum/job/detective
	botcard.access = J.get_access()

	if(radio_controller)
		radio_controller.add_object(src, control_freq, filter = RADIO_SECBOT)
		radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)

/obj/machinery/bot/ed209/turn_on()
	. = ..()
	mode = SECBOT_IDLE
	update_icon()
	updateUsrDialog()

/obj/machinery/bot/ed209/update_icon()
	icon_state = "[lasercolor]ed209[on]"

/obj/machinery/bot/ed209/turn_off()
	..()
	target = null
	oldtarget_name = null
	anchored = 0
	mode = SECBOT_IDLE
	walk_to(src,0)
	update_icon()
	updateUsrDialog()

/obj/machinery/bot/ed209/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/dat

	dat += text({"
<TT><B>Automatic Security Unit v2.5</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},

"<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user))
		if(!lasercolor)
			dat += text({"<BR>
Check for Weapon Authorization: []<BR>
Check Security Records: []<BR>
Operating Mode: []<BR>
Report Arrests: []"},

"<A href='?src=\ref[src];operation=idcheck'>[idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=declarearrests'>[declare_arrests ? "Yes" : "No"]</A>" )

		dat += text({"<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )


	user << browse("<HEAD><TITLE>Securitron v2.5 controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/bot/ed209/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(lasercolor && ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if((lasercolor == "b") && istype(H.wear_suit, /obj/item/clothing/suit/redtag))//Opposing team cannot operate it
			return FALSE
		else if((lasercolor == "r") && istype(H.wear_suit, /obj/item/clothing/suit/bluetag))
			return FALSE
	if(href_list["power"] && allowed(usr))
		if(on)
			turn_off()
		else
			turn_on()

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

/obj/machinery/bot/ed209/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>ERROR</span>")
		else if(open)
			to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
		else if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
		else
			to_chat(user, "<span class='notice'>Access denied.</span>")
	else
		..()
		if(!istype(W, /obj/item/weapon/screwdriver) && W.force && !target)
			target = user
			if(lasercolor)//To make up for the fact that lasertag bots don't hunt
				shootAt(user)
			mode = SECBOT_HUNT

/obj/machinery/bot/ed209/Emag(mob/user)
	..()
	if(open && !locked)
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s target assessment circuits.</span>")
		audible_message("<span class='userdanger'><B>[src] buzzes oddly!</span>")
		target = null
		if(user)
			oldtarget_name = user.name
		last_found = world.time
		anchored = 0
		emagged = 2
		on = 1
		projectile = null
		mode = SECBOT_IDLE
		update_icon()

/obj/machinery/bot/ed209/process()
	//set background = 1

	if(!on)
		return

	var/list/mob/living/carbon/targets = list()
	for (var/mob/living/carbon/C in view(12, src)) //Let's find us a target
		var/threatlevel = 0
		if(C.stat || C.lying && !C.crawling)
			continue
		threatlevel = assess_perp(C)
		//speak(C.real_name + text(": threat: []", threatlevel))
		if(threatlevel < 4)
			continue

		var/dst = get_dist(src, C)
		if(dst <= 1 || dst > 12)
			continue
		targets += C

	if(targets.len)
		var/mob/living/carbon/t = pick(targets)
		if((t.stat != DEAD) && (!t.lying || t.crawling))
			//speak("selected target: " + t.real_name)
			shootAt(t)

	switch(mode)
		if(SECBOT_IDLE)		// idle
			walk_to(src, 0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = SECBOT_START_PATROL	// switch to patrol mode

		if(SECBOT_HUNT)		// hunting for perp
			if(lasercolor)//Lasertag bots do not tase or arrest anyone, just patrol and shoot and whatnot
				mode = SECBOT_IDLE
				return
			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
		//		for(var/mob/O in hearers(src, null))
		//			O << "<span class='game say'><span class='name'>[src]</span> beeps, \"Backup requested! Suspect has evaded arrest.\""
				target = null
				last_found = world.time
				frustration = 0
				mode = 0
				walk_to(src,0)

			if(target)		// make sure target exists
				if(Adjacent(target))		// if right next to perp
					playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
					icon_state = "[lasercolor]ed209-c"
					addtimer(CALLBACK(src, .proc/update_icon), 2)
					var/mob/living/carbon/M = target
					var/maxstuns = 4
					if(M.stuttering < 10 && !(HULK in M.mutations))
						M.stuttering = 10
					M.Stun(10)
					M.Weaken(10)
					maxstuns--
					if(maxstuns <= 0)
						target = null

					if(declare_arrests)
						var/area/location = get_area(src)
						broadcast_security_hud_message("[name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] suspect <b>[target]</b> in <b>[location]</b>", src)
					visible_message("\red <B>[target] has been stunned by [src]!</B>")

					mode = SECBOT_PREP_ARREST
					anchored = 1
					target_lastloc = M.loc
					return

				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					walk_to(src, target, 1, 4)
					if(get_dist(src, target) >= olddist)
						frustration++
					else
						frustration = 0

		if(SECBOT_PREP_ARREST)		// preparing to arrest target
			if(lasercolor)
				mode = SECBOT_IDLE
				return
			if(!target)
				mode = SECBOT_IDLE
				anchored = 0
				return
			// see if he got away
			if((get_dist(src, target) > 1) || (target.loc != target_lastloc) && (target.weakened < 2))
				anchored = 0
				mode = SECBOT_HUNT
				return

			if(iscarbon(target))
				if(!target.handcuffed && !arrest_type)
					playsound(loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
					mode = SECBOT_ARREST
					visible_message("\red <B>[src] is trying to put handcuffs on [target]!</B>")
					addtimer(CALLBACK(src, .proc/subprocess, mode), 60)


		//					playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
		//					var/arrest_message = pick("Have a secure day!","I AM THE LAW.", "God made tomorrow for the crooks we don't catch today.","You can't outrun a radio.")
		//					speak(arrest_message)
			else
				mode = SECBOT_IDLE
				target = null
				anchored = 0
				last_found = world.time
				frustration = 0

		if(SECBOT_ARREST)		// arresting
			if(lasercolor)
				mode = SECBOT_IDLE
				return
			if(!target || target.handcuffed)
				anchored = 0
				mode = SECBOT_IDLE
				return


		if(SECBOT_START_PATROL)	// start a patrol
			if(path.len > 0 && patrol_target)	// have a valid path, so just resume
				mode = SECBOT_PATROL
				return

			else if(patrol_target)		// has patrol target already
				INVOKE_ASYNC(src, .proc/subprocess, mode)

			else					// no patrol target, so need a new one
				find_patrol_target()
				speak("Engaging patrol mode.")


		if(SECBOT_PATROL)		// patrol mode
			patrol_step()
			addtimer(CALLBACK(src, .proc/subprocess, mode), 5)

		if(SECBOT_SUMMON)		// summoned to PDA
			patrol_step()
			addtimer(CALLBACK(src, .proc/subprocess, mode), 4)
			addtimer(CALLBACK(src, .proc/subprocess, mode), 8)

/obj/machinery/bot/ed209/proc/subprocess(oldmode)
	switch(oldmode)
		if(SECBOT_PREP_ARREST)
			if(get_dist(src, target) <= 1)
				if(target.handcuffed)
					return

				if(iscarbon(target))
					target.handcuffed = new /obj/item/weapon/handcuffs(target)
					target.update_inv_handcuffed()	//update handcuff overlays

				mode = SECBOT_IDLE
				target = null
				anchored = 0
				last_found = world.time
				frustration = 0

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

// perform a single patrol step

/obj/machinery/bot/ed209/proc/patrol_step()

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
				if(lasercolor)
					sleep(20)
			else		// failed to move
				blockcount++
				if(blockcount > 5)	// attempt 5 times before recomputing
					// find new path excluding blocked turf
					addtimer(CALLBACK(src, .proc/patrol_substep, next), 2)

		else	// not a valid turf
			mode = SECBOT_IDLE

	else	// no path, so calculate new one
		mode = SECBOT_START_PATROL

/obj/machinery/bot/ed209/proc/patrol_substep(turf/next)
	calc_path(next)
	if(path.len == 0)
		find_patrol_target()
	else
		blockcount = 0


// finds a new patrol target
/obj/machinery/bot/ed209/proc/find_patrol_target()
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
/obj/machinery/bot/ed209/proc/find_nearest_beacon()
	nearest_beacon = null
	new_destination = "__nearest__"
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1
	addtimer(CALLBACK(src, .proc/find_nearest_beacon_substep), 10)

/obj/machinery/bot/ed209/proc/find_nearest_beacon_substep()
	awaiting_beacon = 0
	if(nearest_beacon)
		set_destination(nearest_beacon)
	else
		auto_patrol = 0
		mode = SECBOT_IDLE
		speak("Disengaging patrol mode.")
		send_status()


/obj/machinery/bot/ed209/proc/at_patrol_target()
	find_patrol_target()


// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/ed209/proc/set_destination(new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1


// receive a radio signal
// used for beacon reception

/obj/machinery/bot/ed209/receive_signal(datum/signal/signal)
	if(!on)
		return

	/*
	to_chat(world, "rec signal: [signal.source]")
	for(var/x in signal.data)
		to_chat(world, "* [x] = [signal.data[x]]")
	*/

	var/recv = signal.data["command"]
	// process all-bot input
	if(recv=="bot_status")
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
/obj/machinery/bot/ed209/proc/post_signal(freq, key, value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/ed209/proc/post_signal_multiple(freq, list/keyval)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency)
		return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	//for(var/key in keyval)
	//	signal.data[key] = keyval[key]
		//world << "sent [key],[keyval[key]] on [freq]"
	signal.data = keyval
	if(signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if(signal.data["type"] == "secbot")
		frequency.post_signal(src, signal, filter = RADIO_SECBOT)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/ed209/proc/send_status()
	var/list/kv = list(
		"type" = "secbot",
		"name" = name,
		"loca" = loc.loc,	// area
		"mode" = mode,
	)
	post_signal_multiple(control_freq, kv)



// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/ed209/proc/calc_path(turf/avoid = null)
	path = AStar(loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=avoid)
	if(!path)
		path = list()


// look for a criminal in view of the bot

/obj/machinery/bot/ed209/proc/look_for_perp()
	if(disabled)
		return
	anchored = 0
	threatlevel = 0
	for(var/mob/living/carbon/C in view(12, src)) //Let's find us a criminal
		if(C.stat || C.handcuffed)
			continue

		if(lasercolor && C.lying)
			continue//Does not shoot at people lyind down when in lasertag mode, because it's just annoying, and they can fire once they get up.

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = assess_perp(C)

		if(threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("Level [threatlevel] infraction alert!")
			if(!lasercolor)
				playsound(loc, pick('sound/voice/ed209_20sec.ogg', 'sound/voice/EDPlaceholder.ogg'), 50, 0)
			visible_message("<b>[src]</b> points at [C.name]!")
			mode = SECBOT_HUNT
			process() // ensure bot quickly responds to a perp
			break
		else
			continue


//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
/obj/machinery/bot/ed209/proc/assess_perp(mob/living/carbon/perp)
	var/threatcount = 0

	if(!istype(perp))
		return 0

	if(emagged == 2)
		return 10 //Everyone is a criminal!

	threatcount = perp.assess_perp(src, FALSE, idcheck, FALSE, check_records)

	if(lasercolor && ishuman(perp))
		var/mob/living/carbon/human/hperp = perp
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			threatcount = 0//They will not, however shoot at people who have guns, because it gets really fucking annoying
			if(istype(hperp.wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if(istype(hperp.r_hand, /obj/item/weapon/gun/energy/laser/redtag) || istype(hperp.l_hand, /obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 4
			if(istype(hperp.belt, /obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 2

		else if(lasercolor == "r")
			threatcount = 0
			if(istype(hperp.wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if(istype(hperp.r_hand,/obj/item/weapon/gun/energy/laser/bluetag) || istype(hperp.l_hand,/obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 4
			if(istype(hperp.belt, /obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 2

	if(idcheck && allowed(perp) && !lasercolor)
		threatcount = 0//Corrupt cops cannot exist beep boop

	return threatcount

/obj/machinery/bot/ed209/Bump(atom/M) //Leave no door unopened!
	if(istype(M, /obj/machinery/door) && !isnull(botcard))
		var/obj/machinery/door/D = M
		if(!istype(D, /obj/machinery/door/firedoor) && D.check_access(botcard) && !istype(D,/obj/machinery/door/poddoor))
			D.open()
			frustration = 0
	else if(!anchored && isliving(M))
		loc = M.loc
		frustration = 0

/obj/machinery/bot/ed209/proc/speak(message)
	audible_message("<span class='name'>[src]</span> beeps, \"[message]\"")

/obj/machinery/bot/ed209/explode()
	walk_to(src, 0)
	visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/ed209_assembly/Sa = new /obj/item/weapon/ed209_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = name
	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(!lasercolor)
		var/obj/item/weapon/gun/energy/taser/G = new /obj/item/weapon/gun/energy/taser(Tsec)
		G.power_supply.charge = 0
	else if(lasercolor == "b")
		var/obj/item/weapon/gun/energy/laser/bluetag/G = new /obj/item/weapon/gun/energy/laser/bluetag(Tsec)
		G.power_supply.charge = 0
	else if(lasercolor == "r")
		var/obj/item/weapon/gun/energy/laser/redtag/G = new /obj/item/weapon/gun/energy/laser/redtag(Tsec)
		G.power_supply.charge = 0

	if(prob(50))
		new /obj/item/robot_parts/l_leg(Tsec)
		if(prob(25))
			new /obj/item/robot_parts/r_leg(Tsec)
	if(prob(25))//50% chance for a helmet OR vest
		if(prob(50))
			new /obj/item/clothing/head/helmet(Tsec)
		else
			if(!lasercolor)
				new /obj/item/clothing/suit/storage/flak(Tsec)
			if(lasercolor == "b")
				new /obj/item/clothing/suit/bluetag(Tsec)
			if(lasercolor == "r")
				new /obj/item/clothing/suit/redtag(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(loc)
	qdel(src)


/obj/machinery/bot/ed209/proc/shootAt(mob/target)
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	var/turf/T = get_turf(src)
	var/atom/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return

	//if(lastfired && world.time - lastfired < 100)
	//	playsound(loc, 'ed209_shoot.ogg', 50, 0)

	if(!projectile)
		if(!lasercolor)
			if(emagged == 2)
				projectile = /obj/item/projectile/beam
			else
				projectile = /obj/item/projectile/energy/electrode
		else if(lasercolor == "b")
			if(emagged == 2)
				projectile = /obj/item/projectile/beam/lastertag/omni
			else
				projectile = /obj/item/projectile/beam/lastertag/blue
		else if(lasercolor == "r")
			if(emagged == 2)
				projectile = /obj/item/projectile/beam/lastertag/omni
			else
				projectile = /obj/item/projectile/beam/lastertag/red

	var/obj/item/projectile/A = new projectile(loc)
	A.original = target
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.process()

/obj/machinery/bot/ed209/attack_alien(mob/living/carbon/alien/user)
	..()
	if(!isalien(target))
		target = user
		mode = SECBOT_HUNT


/obj/machinery/bot/ed209/emp_act(severity)
	if(severity == 2 && prob(70))
		..(severity - 1)
	else
		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay(loc)
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)
		QDEL_IN(pulse2, 10)
		var/list/mob/living/carbon/targets = new
		for(var/mob/living/carbon/C in view(12, src))
			if(C.stat == DEAD)
				continue
			targets += C
		if(targets.len)
			if(prob(50))
				var/mob/toshoot = pick(targets)
				if(toshoot)
					targets -= toshoot
					if(prob(50) && emagged < 2)
						emagged = 2
						shootAt(toshoot)
						emagged = 0
					else
						shootAt(toshoot)
			else if(prob(50))
				if(targets.len)
					var/mob/toarrest = pick(targets)
					if(toarrest)
						target = toarrest
						mode = SECBOT_HUNT



/obj/item/weapon/ed209_assembly/attackby(obj/item/weapon/W, mob/user)
	..()

	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", name, created_name), 1, MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
		return

	switch(build_step)
		if(0, 1)
			if(istype(W, /obj/item/robot_parts/l_leg) || istype(W, /obj/item/robot_parts/r_leg))
				user.drop_item()
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the robot leg to [src].</span>")
				name = "legs/frame assembly"
				if(build_step == 1)
					item_state = "ed209_leg"
					icon_state = "ed209_leg"
				else
					item_state = "ed209_legs"
					icon_state = "ed209_legs"

		if(2)
			if(istype(W, /obj/item/clothing/suit/redtag))
				lasercolor = "r"
			else if(istype(W, /obj/item/clothing/suit/bluetag))
				lasercolor = "b"
			if(lasercolor || istype(W, /obj/item/clothing/suit/storage/flak))
				user.drop_item()
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the armor to [src].</span>")
				name = "vest/legs/frame assembly"
				item_state = "[lasercolor]ed209_shell"
				icon_state = "[lasercolor]ed209_shell"

		if(3)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					build_step++
					name = "shielded frame assembly"
					to_chat(user, "<span class='notice'>You welded the vest to [src].</span>")
		if(4)
			if(istype(W, /obj/item/clothing/head/helmet))
				user.drop_item()
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the helmet to [src].</span>")
				name = "covered and shielded frame assembly"
				item_state = "[lasercolor]ed209_hat"
				icon_state = "[lasercolor]ed209_hat"

		if(5)
			if(isprox(W))
				user.drop_item()
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the prox sensor to [src].</span>")
				name = "covered, shielded and sensored frame assembly"
				item_state = "[lasercolor]ed209_prox"
				icon_state = "[lasercolor]ed209_prox"

		if(6)
			if(istype(W, /obj/item/weapon/cable_coil))
				var/obj/item/weapon/cable_coil/coil = W
				to_chat(user, "<span class='notice'>You start to wire [src]...</span>")
				if(do_after(user, 40, target = src))
					if(build_step == 6 && coil.use(1))
						build_step++
						to_chat(user, "<span class='notice'>You wire the ED-209 assembly.</span>")
						name = "wired ED-209 assembly"

		if(7)
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/weapon/gun/energy/laser/bluetag))
						return
					name = "bluetag ED-209 assembly"
				if("r")
					if(!istype(W, /obj/item/weapon/gun/energy/laser/redtag))
						return
					name = "redtag ED-209 assembly"
				if("")
					if(!istype(W, /obj/item/weapon/gun/energy/taser))
						return
					name = "taser ED-209 assembly"
				else
					return
			build_step++
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			item_state = "[lasercolor]ed209_taser"
			icon_state = "[lasercolor]ed209_taser"
			user.drop_item()
			qdel(W)

		if(8)
			if(istype(W, /obj/item/weapon/screwdriver))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				to_chat(user, "<span class='notice'>Now attaching the gun to the frame...</span>")
				if(do_after(user, 40, target = src))
					if(build_step == 8)
						build_step++
						name = "armed [name]"
						to_chat(user, "<span class='notice'>Taser gun attached.</span>")

		if(9)
			if(istype(W, /obj/item/weapon/stock_parts/cell))
				build_step++
				to_chat(user, "<span class='notice'>You complete the ED-209.</span>")
				var/turf/T = get_turf(src)
				new /obj/machinery/bot/ed209(T, created_name, lasercolor)
				user.drop_item()
				qdel(W)
				user.drop_from_inventory(src)
				qdel(src)


/obj/machinery/bot/ed209/bullet_act(obj/item/projectile/Proj)
	if(!disabled && ((lasercolor == "b") && istype(Proj, /obj/item/projectile/beam/lastertag/red) \
				|| (lasercolor == "r") && istype(Proj, /obj/item/projectile/beam/lastertag/blue)))
		disabled = 1
		qdel(Proj)
		addtimer(CALLBACK(src, .proc/enable), 100)
	..()

/obj/machinery/bot/ed209/proc/enable()
	disabled = 0

/obj/machinery/bot/ed209/bluetag/New()//If desired, you spawn red and bluetag bots easily
	new /obj/machinery/bot/ed209(get_turf(src), null, "b")
	qdel(src)

/obj/machinery/bot/ed209/redtag/New()
	new /obj/machinery/bot/ed209(get_turf(src), null, "r")
	qdel(src)
