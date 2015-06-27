/obj/effect/effect/jet_trails
	name = "jet trails"
	icon = 'tauceti/modules/_spacecraft/spacecraft.dmi'
	icon_state = "jet_trails"
	anchored = 1.0

/datum/effect/effect/system/jet_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

	set_up(atom/atom)
		attach(atom)
		oldposition = get_turf(atom)

	start()
		if(!src.on)
			src.on = 1
			src.processing = 1
		if(src.processing)
			src.processing = 0
			spawn(0)
				var/turf/T = get_turf(src.holder)
				if(T != src.oldposition)
					if(istype(T, /turf/space))
						var/obj/effect/effect/jet_trails/I = new /obj/effect/effect/jet_trails(src.oldposition)
						src.oldposition = T
						I.dir = src.holder.dir
						flick("jet_fade", I)
						I.icon_state = "blank"
						spawn( 20 )
							I.delete()
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()
				else
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()

	proc/stop()
		src.processing = 0
		src.on = 0

/obj/effect/decal/cleanable/spacecraft_debris
	name = "spacecraft debris"
	desc = "It's a useless heap of junk... <i>or is it?</i>"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'tauceti/modules/_spacecraft/wreckage.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")

/obj/effect/decal/cleanable/spacecraft_debris/proc/streak(var/list/directions)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				if (prob(40))
					var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad
					smoke.set_up(5,0,src)
					smoke.start()
				else if (prob(10))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(3, 1, src)
					s.start()
			if (step_to(src, get_step(src, direction), 0))
				break

proc/spacecraft_boom(atom/location)
	new /obj/effect/debrisspawner(get_turf(location))

/obj/effect/debrisspawner
	var/sparks = 0 //whether sparks spread on Gib()
	var/list/gibtypes = list(/obj/effect/decal/cleanable/spacecraft_debris,/obj/effect/decal/cleanable/spacecraft_debris,/obj/effect/decal/cleanable/spacecraft_debris, /obj/effect/decal/cleanable/spacecraft_debris,/obj/effect/decal/cleanable/spacecraft_debris,/obj/effect/decal/cleanable/spacecraft_debris)
	var/list/gibamounts = list(1,1,1,2,1,2)
	var/list/gibdirections = list()
	var/obj/effect/decal/cleanable/spacecraft_debris/debris = new /obj/effect/decal/cleanable/spacecraft_debris

	New(location)
		..()
		gibdirections = list(alldirs,alldirs,alldirs,alldirs,alldirs,alldirs)

		if(istype(loc,/turf)) //basically if a badmin spawns it
			boom(loc)

	proc/boom(atom/location)
		if(gibtypes.len != gibamounts.len || gibamounts.len != gibdirections.len)
			world << "\red Gib list length mismatch!"
			return

		for(var/i = 1, i<= gibtypes.len, i++)
			if(gibamounts[i])
				for(var/j = 1, j<= gibamounts[i], j++)
					var/gibType = gibtypes[i]
					debris = new gibType(location)

					var/list/directions = gibdirections[i]
					if(directions.len)
						debris.streak(directions)

		qdel(src)
/*
/obj/effect/debrisspawner
	gibtypes = list(/obj/effect/decal/cleanable/robot_debris/up,/obj/effect/decal/cleanable/robot_debris/down,/obj/effect/decal/cleanable/robot_debris,/obj/effect/decal/cleanable/robot_debris,/obj/effect/decal/cleanable/robot_debris,/obj/effect/decal/cleanable/robot_debris/limb)
	gibamounts = list(1,1,1,1,1,1)

	New()
		gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs)
		gibamounts[6] = pick(0,1,2)
		..() 		*/

/obj/machinery/spacecraft_beacon
	name = "Hyperspace beacon"
	desc = "It used for navigation through space"
	icon = 'tauceti/modules/_spacecraft/spacecraft_parts.dmi'
	icon_state = "hyper_beacon"
	density = 0
	anchored = 1
	use_power = 2
	idle_power_usage = 20
	active_power_usage = 80


/obj/effect/marker/sc_marker
	icon_state = "X"
	icon = 'icons/misc/mark.dmi'
	name = "X"
	invisibility = 101
	anchored = 1
	opacity = 0

/obj/item/weapon/circuitboard/sccomp
	name = "Circuit board (Trading operations console)"
	build_path = "/obj/machinery/computer/tradecomp"
	origin_tech = "programming=3"

/obj/machinery/computer/sccomp
	name = "Trading operations console"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	req_access = list(access_qm)
	circuit = "/obj/item/weapon/circuitboard/supplycomp"
	var/temp = null
	var/ordered_sc = 0
	var/balance = 0
	var/moving = 0
	var/movetime = 1200
	var/at_station = 0
	var/eta_timeofday
	var/eta
//	var/hacked = 0
//	var/can_order_contraband = 0
	var/last_viewed_group = "categories"

/obj/machinery/computer/sccomp/attackby()
	return

/obj/machinery/computer/sccomp/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		user << "\red Access Denied."
		return

	if(..())
		return
	user.set_machine(src)
//	var/datum/money_account/station_account
	if(station_account)
		balance = station_account.money
//	post_signal("supply")
	var/dat
	if (temp)
		dat = temp
	else
		dat += {"<BR><B>Spacecraft ordering console</B><HR>
		\n Station balance: [balance]<BR><HR>
		[moving ? "\n*Must be away to order items*<BR>\n<BR>":at_station ? "\n*Must be away to order items*<BR>\n<BR>":"\n<A href='?src=\ref[src];order_sc=1'>Order spacecraft</A><BR>\n<BR>"]
		[moving ? "\n*Shuttle already called*<BR>\n<BR>":at_station ? "\n<A href='?src=\ref[src];send=1'>Send away</A><BR>\n<BR>":"\n<A href='?src=\ref[src];send=1'>Send to station</A><BR>\n<BR>"]
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/sccomp/Topic(href, href_list)
	if(..())
		return

	if( isturf(loc) && (in_range(src, usr) || istype(usr, /mob/living/silicon)) )
		usr.set_machine(src)

	if(href_list["send"])
		if(!can_move())
			temp = "For safety reasons the automated supply shuttle cannot transport back to supply station live organisms, classified nuclear weaponry, homing beacons or spacecraft.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

		else if(at_station)
			moving = 1
			send()
			temp = "The supply shuttle has departed.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		else
			moving = 1
			spawn(1200)
				send()
			temp = "The supply shuttle has been called.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["order_sc"]) //Пока что всё вручную, со временем, автоматизирую
		temp = "Current avaible spacecrafts: <BR><BR>"
		temp += "<BR><A href='?src=\ref[src];order_civilian=1'>S-17 Zenith - Civilian scout/cargo spacecraft(20000 credits)</A><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"


	else if (href_list["order_civilian"])
		if(ordered_sc == 1)
			temp = "Spacecraft already ordered.<BR>"
			temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
			return
		if(supply_shuttle.points >= 30)
			supply_shuttle.points -= 30
			ordered_sc += 1
			for(var/obj/effect/marker/sc_marker/A in world)
				if(A.name == "X")
					new /obj/spacecraft/civilian/civ1(get_turf(A))
			temp = "Thanks for your order.<BR>"
			temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
		else
			temp = "Not enough money.<BR>"
			temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["mainmenu"])
		temp = null


	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/sccomp/proc/send()
	var/area/from
	var/area/dest
	var/area/the_shuttles_way
	switch(at_station)
		if(1)
			from = locate(/area/spacecraft_shuttle/station)
			dest = locate(/area/spacecraft_shuttle/dock)
			the_shuttles_way = from
			at_station = 0
		if(0)
			from = locate(/area/spacecraft_shuttle/dock)
			dest = locate(/area/spacecraft_shuttle/station)
			the_shuttles_way = dest
			at_station = 1
	moving = 0

	for(var/mob/living/unlucky_person in the_shuttles_way)
		unlucky_person.gib()

	from.move_contents_to(dest)

/obj/machinery/computer/sccomp/proc/can_move()
	if(moving) return 0

	var/area/shuttle = locate(/area/spacecraft_shuttle/station)
	if(!shuttle) return 0

	if(forbidden_atoms_check(shuttle))
		return 0

	return 1

	//To stop things being sent to centcomm which should not be sent to centcomm. Recursively checks for these types.
/obj/machinery/computer/sccomp/proc/forbidden_atoms_check(atom/A)
	if(istype(A,/mob/living))
		return 1
	if(istype(A,/obj/item/weapon/disk/nuclear))
		return 1
	if(istype(A,/obj/machinery/nuclearbomb))
		return 1
	if(istype(A,/obj/item/device/radio/beacon))
		return 1
	if(istype(A,/obj/spacecraft) && at_station)
		return 1

	for(var/i=1, i<=A.contents.len, i++)
		var/atom/B = A.contents[i]
		if(.(B))
			return 1