//Cleanbot assembly
/obj/item/weapon/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/created_name = "Cleanbot"


//Cleanbot
/obj/machinery/bot/cleanbot
	name = "Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot0"
	layer = MOB_LAYER
	density = 0
	anchored = 0
	//weight = 1.0E7
	health = 25
	maxhealth = 25
	var/cleaning = 0
	var/screwloose = 0
	var/oddbutton = 0
	var/blood = 1
	var/list/target_types = list()
	var/obj/effect/decal/cleanable/target
	var/obj/effect/decal/cleanable/oldtarget
	var/oldloc = null
	req_access = list(access_janitor)
	var/path[] = new()
	var/patrol_path[] = null
	var/beacon_freq = 1445		// navigation beacon frequency
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/should_patrol
	var/next_dest
	var/next_dest_loc

/obj/machinery/bot/cleanbot/atom_init()
	. = ..()
	get_targets()
	icon_state = "cleanbot[on]"

	should_patrol = 1

	botcard = new /obj/item/weapon/card/id(src)
	var/datum/job/janitor/J = new/datum/job/janitor
	botcard.access = J.get_access()

	locked = 0 // Start unlocked so roboticist can set them to patrol.

	if(radio_controller)
		radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)

/obj/machinery/bot/cleanbot/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,beacon_freq)
	return ..()

/obj/machinery/bot/cleanbot/turn_on()
	. = ..()
	icon_state = "cleanbot[on]"
	updateUsrDialog()

/obj/machinery/bot/cleanbot/turn_off()
	..()
	if(target)
		target.targeted_by = null
	target = null
	oldtarget = null
	oldloc = null
	icon_state = "cleanbot[on]"
	path = new()
	updateUsrDialog()

/obj/machinery/bot/cleanbot/ui_interact(mob/user)
	var/dat
	dat += text({"
		<TT><B>Automatic Station Cleaner v1.0</B></TT><BR><BR>
		Status: []<BR>
		Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
		Maintenance panel is [open ? "opened" : "closed"]"},
		text("<A href='?src=\ref[src];operation=start'>[on ? "On" : "Off"]</A>"))
	if(!src.locked || issilicon(user) || isobserver(user))
		dat += text({"<BR>Cleans Blood: []<BR>"}, text("<A href='?src=\ref[src];operation=blood'>[blood ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=\ref[src];operation=patrol'>[should_patrol ? "Yes" : "No"]</A>"))
	//	dat += text({"<BR>Beacon frequency: []<BR>"}, text("<A href='?src=\ref[src];operation=freq'>[beacon_freq]</A>"))
	if(src.open && !src.locked)
		dat += text({"
			Odd looking screw twiddled: []<BR>
			Weird button pressed: []"},
			text("<A href='?src=\ref[src];operation=screw'>[screwloose ? "Yes" : "No"]</A>"),
			text("<A href='?src=\ref[src];operation=oddbutton'>[oddbutton ? "Yes" : "No"]</A>"))

	var/datum/browser/popup = new(user, "window=autocleaner", src.name)
	popup.set_content(dat)
	popup.open()

/obj/machinery/bot/cleanbot/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	switch(href_list["operation"])
		if("start")
			if (on)
				turn_off()
			else
				turn_on()
		if("blood")
			blood =!blood
			get_targets()
		if("patrol")
			should_patrol =!should_patrol
			patrol_path = null
		if("freq")
			var/freq = input("Select frequency for  navigation beacons", "Frequnecy", num2text(beacon_freq / 10)) as num
			if (freq > 0)
				beacon_freq = freq * 10
		if("screw")
			screwloose = !screwloose
			to_chat(usr, "<span class='notice'>You twiddle the screw.</span>")
		if("oddbutton")
			oddbutton = !oddbutton
			to_chat(usr, "<span class='notice'>You press the weird button.</span>")
	updateUsrDialog()

/obj/machinery/bot/cleanbot/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(usr) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the [src] behaviour controls.</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>This [src] doesn't seem to respect your authority.</span>")
	else
		return ..()

/obj/machinery/bot/cleanbot/emag_act(mob/user)
	..()
	if(open && !locked)
		if(user)
			to_chat(user, "<span class='notice'>The [src] buzzes and beeps.</span>")
		oddbutton = 1
		screwloose = 1

/obj/machinery/bot/cleanbot/is_on_patrol()
	return should_patrol

/obj/machinery/bot/cleanbot/process()
	if(!on)
		return
	if(cleaning)
		return
	if(!inaction_check())
		return

	if(!screwloose && !oddbutton && prob(5))
		visible_message("<span class='notice'>[src] makes an excited beeping booping sound!</span>")

	if(screwloose && prob(5))
		if(istype(loc,/turf/simulated))
			var/turf/simulated/T = loc
			T.make_wet_floor(WATER_FLOOR)
	if(oddbutton && prob(5))
		visible_message("<span class='warning'>Something flies out of [src]. He seems to be acting oddly.</span>")
		var/obj/effect/decal/cleanable/blood/gibs/gib = new /obj/effect/decal/cleanable/blood/gibs(loc)
		//gib.streak(list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		oldtarget = gib
	if(!target)
		for (var/obj/effect/decal/cleanable/D in view(7,src))
			for(var/T in target_types)
				if(!D.targeted_by && (D.type == T || D.parent_type == T) && D != oldtarget)   // If the mess isn't targeted
					oldtarget = D								 // or if it is but the bot is gone.
					target = D									 // and it's stuff we clean?  Clean it.
					D.targeted_by = src	// Claim the mess we are targeting.
					return

	if(!target || target == null)
		if(loc != oldloc)
			oldtarget = null

		if (!should_patrol)
			return

		if (!patrol_path || patrol_path.len < 1)
			find_patrol_path()
		else
			patrol_move()
		return

	if(target && path.len == 0)
		INVOKE_ASYNC(src, .proc/find_target_path)
		return
	if(path.len > 0 && target)
		step_to(src, path[1])
		path -= path[1]
	else if(path.len == 1)
		step_to(src, target)

	if(target)
		patrol_path = null
		if(loc == target.loc)
			clean(target)
			path = new()
			target = null
			return

	oldloc = loc

/obj/machinery/bot/cleanbot/proc/find_target_path()
	if(!target)
		return
	path = get_path_to(src, get_turf(target), /turf/proc/Distance_cardinal, 0, 30, id=botcard)
	if(path.len == 0)
		oldtarget = target
		target.targeted_by = null
		target = null

		if(should_patrol) // so we switch to patrolling if we can't get to target
			if(!patrol_path || patrol_path.len < 1)
				find_patrol_path()
			else
				patrol_move()

/obj/machinery/bot/cleanbot/proc/find_patrol_path()
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(beacon_freq)

	if(!frequency)
		return

	closest_dist = 9999
	closest_loc = null

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	signal.data = list("findbeacon" = "patrol")
	frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	addtimer(CALLBACK(src, .proc/receive_patrol_path), 5)

/obj/machinery/bot/cleanbot/proc/receive_patrol_path()
	if (!next_dest_loc)
		next_dest_loc = closest_loc
	if (next_dest_loc)
		patrol_path = get_path_to(src, next_dest_loc, /turf/proc/Distance_cardinal, 0, 120, id=botcard, exclude=null)

/obj/machinery/bot/cleanbot/proc/patrol_move()
	if (patrol_path.len <= 0)
		return

	var/next = patrol_path[1]
	patrol_path -= next
	if (next == loc)
		return

	var/moved = step_towards(src, next)
	if (!moved)
		failed_steps++
	if (failed_steps > 4)
		patrol_path = null
		next_dest = null
		failed_steps = 0
	else
		failed_steps = 0

/obj/machinery/bot/cleanbot/receive_signal(datum/signal/signal)
	var/recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return
	var/dist = get_dist(src, signal.source.loc)
	var/closest_dest = null
	if (dist < closest_dist && signal.source.loc != src.loc)
		closest_dist = dist
		closest_loc = signal.source.loc
		closest_dest = recv
	if(next_dest == null || patrol_path == null || next_dest_loc == null)
		next_dest_loc = closest_loc
		next_dest = closest_dest
	if(next_dest_loc == src.loc && recv == next_dest)
		next_dest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

/obj/machinery/bot/cleanbot/proc/get_targets()
	src.target_types = new/list()
	target_types += /obj/effect/decal/cleanable/blood/oil
	target_types += /obj/effect/decal/cleanable/blood/gibs/robot
	target_types += /obj/effect/decal/cleanable/vomit
	target_types += /obj/effect/decal/cleanable/crayon
	target_types += /obj/effect/decal/cleanable/liquid_fuel
	target_types += /obj/effect/decal/cleanable/mucus
	target_types += /obj/effect/decal/cleanable/dirt
	target_types += /obj/effect/decal/cleanable/flour
	target_types += /obj/effect/decal/cleanable/tomato_smudge
	target_types += /obj/effect/decal/cleanable/egg_smudge
	target_types += /obj/effect/decal/cleanable/pie_smudge
	target_types += /obj/effect/fluid
	target_types += /obj/effect/decal/cleanable/molten_item
	target_types += /obj/effect/decal/cleanable/ash
	target_types += /obj/effect/decal/cleanable/greenglow
	target_types += /obj/effect/decal/cleanable/spiderling_remains
	if(src.blood)
		target_types += /obj/effect/decal/cleanable/blood
		target_types += /obj/effect/decal/cleanable/blood/gibs
		target_types += /obj/effect/decal/cleanable/blood/tracks
		target_types += /obj/effect/decal/cleanable/blood/tracks/footprints
		target_types += /obj/effect/decal/cleanable/blood/tracks/wheels
		target_types += /obj/effect/decal/cleanable/blood/splatter
		target_types += /obj/effect/decal/cleanable/blood/drip
		target_types += /obj/effect/decal/cleanable/blood/trail_holder

/obj/machinery/bot/cleanbot/proc/clean(obj/effect/decal/cleanable/target)
	anchored = 1
	icon_state = "cleanbot-c"
	visible_message("<span class='warning'>[src] begins to clean up the [target]</span>")
	cleaning = 1
	var/cleantime = 50
	if(istype(target,/obj/effect/decal/cleanable/dirt))		// Clean Dirt much faster
		cleantime = 10
	spawn(cleantime)
		if(istype(loc,/turf/simulated))
			var/turf/simulated/f = loc
			f.dirt = 0
		cleaning = 0
		qdel(target)
		icon_state = "cleanbot[on]"
		anchored = 0
		target = null

/obj/machinery/bot/cleanbot/explode()
	on = 0
	visible_message("<span class='warning bold'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return

/obj/item/weapon/bucket_sensor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/robot_parts/l_arm) || istype(I, /obj/item/robot_parts/r_arm))
		qdel(I)
		var/turf/T = get_turf(loc)
		var/obj/machinery/bot/cleanbot/A = new /obj/machinery/bot/cleanbot(T)
		A.name = created_name
		to_chat(user, "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>")
		qdel(src)

	else if (istype(I, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter new robot name", name, input_default(created_name)), MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && loc != usr)
			return
		created_name = t

	else
		return ..()
