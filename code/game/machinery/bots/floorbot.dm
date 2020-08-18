//Floorbot assemblies
/obj/item/weapon/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top."
	name = "tiles and toolbox"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/created_name = "Floorbot"

/obj/item/weapon/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached."
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/created_name = "Floorbot"

// Floorbot states
#define FLOORBOT_IDLE                0
#define FLOORBOT_MOVING_TO_REPAIR    1
#define FLOORBOT_MOVING_TO_PICKUP    2
#define FLOORBOT_BUSY                3
#define FLOORBOT_BRIDGE              4

// Floorbot tasks
#define FLOORBOT_TASK_NOTHING        0
#define FLOORBOT_TASK_FIXHOLE        1
#define FLOORBOT_TASK_PLACETILE      2
#define FLOORBOT_TASK_FIXTILE        3
#define FLOORBOT_TASK_BREAKTILE      4

//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	layer = 5.0
	density = FALSE
	anchored = FALSE
	health = 25
	maxhealth = 25
	//weight = 1.0E7
	var/amount = 10
	var/eattiles = FALSE
	var/maketiles = FALSE
	var/turf/target
	req_access = list(access_construction)
	var/path[] = new()
	var/targetdirection
	var/state = FLOORBOT_IDLE
	var/task = FLOORBOT_TASK_NOTHING
	var/fixtiles = FALSE
	var/placetiles = FALSE
	var/boringness = 0


/obj/machinery/bot/floorbot/atom_init()
	. = ..()
	updateicon()

/obj/machinery/bot/floorbot/turn_on()
	. = ..()
	updateicon()
	updateUsrDialog()
	state = FLOORBOT_IDLE

/obj/machinery/bot/floorbot/turn_off()
	..()
	target = null
	updateicon()
	path = new()
	updateUsrDialog()

/obj/machinery/bot/floorbot/ui_interact(mob/user)
	var/dat
	dat += "<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];operation=start'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "Tiles left: [amount]<BR>"
	dat += "Behvaiour controls are [locked ? "locked" : "unlocked"]<BR>"
	if(!src.locked || issilicon(user) || isobserver(user))
		dat += "Repair damaged tiles and platings: <A href='?src=\ref[src];operation=fixtiles'>[fixtiles ? "Yes" : "No"]</A><BR>"
		dat += "Place floor tiles: <A href='?src=\ref[src];operation=placetiles'>[placetiles ? "Yes" : "No"]</A><BR>"
		dat += "Finds tiles: <A href='?src=\ref[src];operation=tiles'>[eattiles ? "Yes" : "No"]</A><BR>"
		dat += "Make singles pieces of metal into tiles when empty: <A href='?src=\ref[src];operation=make'>[maketiles ? "Yes" : "No"]</A><BR>"
		var/bmode
		if (targetdirection)
			bmode = dir2text(targetdirection)
		else
			bmode = "Disabled"
		dat += "<BR><BR>Bridge Mode : <A href='?src=\ref[src];operation=bridgemode'>[bmode]</A><BR>"

	var/datum/browser/popup = new(user, "autorepair", "Repairbot v1.0 controls", 300, 400)
	popup.set_content(dat)
	popup.open()

	onclose(user, "autorepair")


/obj/machinery/bot/floorbot/attackby(obj/item/W , mob/user)
	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(amount >= 50)
			return
		var/loaded = min(50-amount, T.get_amount())
		T.use(loaded)
		amount += loaded
		to_chat(user, "<span class='notice'>You load [loaded] tiles into the floorbot. He now contains [src.amount] tiles.</span>")
		updateicon()
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(usr) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the [src] behaviour controls.</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
		updateUsrDialog()
	else
		..()

/obj/machinery/bot/floorbot/emag_act(mob/user)
	..()
	if(open && !locked && user)
		to_chat(user, "<span class='notice'>The [src] buzzes and beeps.</span>")

/obj/machinery/bot/floorbot/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	switch(href_list["operation"])
		if("start")
			if (on)
				turn_off()
			else
				turn_on()
		if("fixtiles")
			fixtiles = !fixtiles
		if("placetiles")
			placetiles = !placetiles
		if("tiles")
			eattiles = !eattiles
		if("make")
			maketiles = !maketiles
		if("bridgemode")
			var/setdir = input("Select construction direction:") as null|anything in list("north","east","south","west","disable")
			switch(setdir)
				if("north")
					targetdirection = 1
				if("south")
					targetdirection = 2
				if("east")
					targetdirection = 4
				if("west")
					targetdirection = 8
				if("disable")
					targetdirection = null
	updateUsrDialog()


/obj/machinery/bot/floorbot/proc/is_hull_breach(turf/t) //Ignore space tiles not considered part of a structure, also ignores shuttle docking areas.
	if(!t || !istype(t, /turf/space))
		return FALSE

	if(targetdirection) // Bridge mode, ignore areas
		return TRUE

	var/area/t_area = get_area(t)

	if(istype(t_area, /area/station/))
		return TRUE

/obj/machinery/bot/floorbot/proc/is_broken(turf/simulated/floor/t)
	if(!istype(t))
		return FALSE
	return t.broken || t.burnt

/obj/machinery/bot/floorbot/proc/is_plating(turf/simulated/floor/t)
	if(!istype(t))
		return FALSE
	return t.is_plating() && !is_broken(t)


/obj/machinery/bot/floorbot/proc/do_task(turf/t, new_task)
	state = FLOORBOT_MOVING_TO_REPAIR
	task = new_task
	target = t
	path = new()

/obj/machinery/bot/floorbot/proc/attempt_move(atom)
	if(get_turf(atom) == get_turf(src))
		return TRUE

	if(!path || path.len == 0)
		path = get_path_to(src, get_turf(atom), /turf/proc/Distance_cardinal, 0, 30, id=botcard, simulated_only = FALSE)
	else if(path.len > 0)
		step_to(src, path[1])
		path -= path[1]

	return FALSE

/obj/machinery/bot/floorbot/proc/start_task()
	var/turf/t = target

	if(task == FLOORBOT_TASK_FIXHOLE && is_hull_breach(t))
		state = FLOORBOT_BUSY
		if(targetdirection)
			visible_message("<span class='warning'>[src] begins installing a bridge plating</span>")
		else
			visible_message("<span class='warning'>[src] begins to repair the hole</span>")
		anchored = TRUE
		icon_state = "floorbot-c"

		addtimer(CALLBACK(src, .proc/finish_task), 50)
	else if(task == FLOORBOT_TASK_PLACETILE && placetiles && is_plating(t))
		state = FLOORBOT_BUSY
		visible_message("<span class='warning'>[src] begins to place the floor tiles.</span>")
		anchored = TRUE
		icon_state = "floorbot-c"

		addtimer(CALLBACK(src, .proc/finish_task), 20)
	else if(task == FLOORBOT_TASK_FIXTILE && fixtiles && is_broken(t))
		state = FLOORBOT_BUSY
		visible_message("<span class='warning'>[src] begins repairing the floor.</span>")
		anchored = TRUE
		icon_state = "floorbot-c"

		addtimer(CALLBACK(src, .proc/finish_task), 50)
	else if(task == FLOORBOT_TASK_BREAKTILE && istype(t, /turf/simulated/floor))
		state = FLOORBOT_BUSY
		visible_message("<span class='warning'>[src] begins repairing the floor.</span>") // troll message
		anchored = TRUE
		icon_state = "floorbot-c"

		addtimer(CALLBACK(src, .proc/finish_task), 50)
	else
		state = FLOORBOT_IDLE

/obj/machinery/bot/floorbot/proc/finish_task()
	var/turf/t = target

	if(task == FLOORBOT_TASK_FIXHOLE && is_hull_breach(t))
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		T.build(t)
		amount -= 1
	else if(task == FLOORBOT_TASK_PLACETILE && placetiles && is_plating(t))
		var/turf/simulated/floor/F = t
		F.make_plasteel_floor()
		amount -= 1
	else if(task == FLOORBOT_TASK_FIXTILE && fixtiles && is_broken(t))
		var/turf/simulated/floor/F = t
		if(F.is_plating())
			if(!F.floor_type)
				F.floor_type = /obj/item/stack/tile/plasteel
			F.make_plating()
		else
			F.make_plasteel_floor()
			amount -= 1
	else if(task == FLOORBOT_TASK_BREAKTILE && istype(t, /turf/simulated/floor))
		var/turf/simulated/floor/F = t
		if(prob(90))
			F.break_tile_to_plating()
		else
			F.ReplaceWithLattice()
		amount += 1
		visible_message("<span class='warning'>[src] makes an excited booping sound.</span>")

	updateicon()
	anchored = FALSE
	target = null
	if(targetdirection)
		state = FLOORBOT_BRIDGE
	else
		state = FLOORBOT_IDLE
	task = FLOORBOT_TASK_NOTHING

/obj/machinery/bot/floorbot/proc/create_tiles(obj/item/stack/sheet/metal/M)
	if(!istype(M))
		state = FLOORBOT_IDLE
		return
	if(get_turf(M) != get_turf(src))
		state = FLOORBOT_IDLE
		return
	if(M.get_amount() > 1)
		state = FLOORBOT_IDLE
		return
	visible_message("<span class='warning'>[src] created some tiles from a metal sheet.</span>")
	new /obj/item/stack/tile/plasteel(M.loc, 4)
	qdel(M)
	state = FLOORBOT_IDLE

/obj/machinery/bot/floorbot/process()
	if(!on)
		return

	if(state == FLOORBOT_MOVING_TO_REPAIR || state == FLOORBOT_MOVING_TO_PICKUP)
		boringness += 1
		if(boringness > 15)
			visible_message("<span class='warning'>[src] makes an angry beeping noise.</span>")
			state = FLOORBOT_IDLE
			return

	if(prob(5))
		visible_message("<span class='notice'>[src] makes an excited booping beeping sound!</span>")

	if(state == FLOORBOT_IDLE)

		if(emagged == 2)
			for (var/turf/simulated/floor/F in shuffle(view(7,src)))
				if(F.floor_type)
					do_task(F, FLOORBOT_TASK_BREAKTILE)
					return
			return

		if(targetdirection)
			state = FLOORBOT_BRIDGE
			return


		if(amount > 0)
			for (var/turf/space/D in shuffle(view(7,src)))
				if(is_hull_breach(D))
					boringness = 0
					do_task(D, FLOORBOT_TASK_FIXHOLE)
					return

			if(placetiles || fixtiles)
				for (var/turf/simulated/floor/F in shuffle(view(7,src)))
					if(placetiles && is_plating(F))
						boringness = 0
						do_task(F, FLOORBOT_TASK_PLACETILE)
						return
					if(fixtiles && is_broken(F))
						boringness = 0
						do_task(F, FLOORBOT_TASK_FIXTILE)
						return
		else
			if(eattiles)
				for(var/obj/item/stack/tile/plasteel/T in shuffle(view(7, src)))
					state = FLOORBOT_MOVING_TO_PICKUP
					boringness = 0
					target = T
					path = new()
					return
			if(maketiles)
				for(var/obj/item/stack/sheet/metal/M in shuffle(view(7, src)))
					if(M.get_amount() == 1 && !(istype(M.loc, /turf/simulated/wall)))
						state = FLOORBOT_MOVING_TO_PICKUP
						boringness = 0
						target = M
						path = new()
						return


	if(state == FLOORBOT_MOVING_TO_REPAIR)

		if(!target)
			state = FLOORBOT_IDLE

		if(task == FLOORBOT_TASK_FIXHOLE && !is_hull_breach(target))
			state = FLOORBOT_IDLE
		if(task == FLOORBOT_TASK_PLACETILE && (!is_plating(target) || !placetiles))
			state = FLOORBOT_IDLE
		if(task == FLOORBOT_TASK_FIXTILE && (!is_broken(target) || !fixtiles))
			state = FLOORBOT_IDLE

		if(attempt_move(target)) // If we reached the destination
			start_task()
			return

	if(state == FLOORBOT_MOVING_TO_PICKUP)
		if(!target)
			state = FLOORBOT_IDLE

		if(attempt_move(target)) // If we reached the destination
			if(istype(target, /obj/item/stack/tile/plasteel))
				var/obj/item/stack/tile/plasteel/T = target

				visible_message("<span class='notice'>[src] collects some tiles.</span>")
				if(amount + T.get_amount() > 50)
					var/i = 50 - amount
					amount += i
					T.use(i)
				else
					amount += T.get_amount()
					qdel(T)
				updateicon()
				state = FLOORBOT_IDLE
				return
			else if(istype(target, /obj/item/stack/sheet/metal))
				var/obj/item/stack/sheet/metal/M = target
				visible_message("<span class='warning'>[src] begins to create tiles from a metal sheet.</span>")
				state = FLOORBOT_BUSY
				addtimer(CALLBACK(src, .proc/create_tiles, M), 20)
				return
			else
				state = FLOORBOT_IDLE
				return

	if(state == FLOORBOT_BRIDGE)
		if(!targetdirection || amount == 0)
			state = FLOORBOT_IDLE
			targetdirection = null
			return

		var/turf/s = get_turf(src)
		if(istype(s, /turf/space))
			task = FLOORBOT_TASK_FIXHOLE
			target = s
			start_task()
			return

		var/turf/T = get_step(src, targetdirection)
		if(T.density)
			visible_message("<span class='warning'>[src] beeps as it hits the wall and stops.</span>")
			state = FLOORBOT_IDLE
			targetdirection = null
			return

		step_to(src, T)


/obj/machinery/bot/floorbot/proc/updateicon()
	if(src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"

/obj/machinery/bot/floorbot/explode()
	src.on = 0
	src.visible_message("<span class='warning'><B>[src] blows apart!</B></span>")
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/storage/toolbox/mechanical/N = new /obj/item/weapon/storage/toolbox/mechanical(Tsec)
	N.contents = list()

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	while (amount)//Dumps the tiles into the appropriate sized stacks
		if(amount >= 16)
			new /obj/item/stack/tile/plasteel(Tsec, 16)
			amount -= 16
		else
			new /obj/item/stack/tile/plasteel(Tsec, amount)
			amount = 0

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return


/obj/item/weapon/storage/toolbox/mechanical/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/stack/tile/plasteel))
		return ..()
	var/obj/item/stack/tile/plasteel/T = I

	if(src.contents.len >= 1)
		to_chat(user, "<span class='notice'>They wont fit in as there is already stuff inside.</span>")
		return
	if(user.s_active)
		user.s_active.close(user)
	qdel(T)
	var/obj/item/weapon/toolbox_tiles/B = new /obj/item/weapon/toolbox_tiles
	user.put_in_hands(B)
	to_chat(user, "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>")
	qdel(src)

/obj/item/weapon/toolbox_tiles/attackby(obj/item/I, mob/user, params)
	if(isprox(I))
		qdel(I)
		var/obj/item/weapon/toolbox_tiles_sensor/B = new /obj/item/weapon/toolbox_tiles_sensor()
		B.created_name = src.created_name
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the sensor to the toolbox and tiles!</span>")
		qdel(src)

	else if (istype(I, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter new robot name", name, input_default(created_name)),MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		created_name = t

	else
		return ..()

/obj/item/weapon/toolbox_tiles_sensor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/robot_parts/l_arm) || istype(I, /obj/item/robot_parts/r_arm))
		qdel(I)
		var/turf/T = get_turf(user.loc)
		var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot(T)
		A.name = src.created_name
		to_chat(user, "<span class='notice'>You add the robot arm to the odd looking toolbox assembly! Boop beep!</span>")
		qdel(src)

	else if (istype(I, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter new robot name", src.name, input_default(src.created_name)), MAX_NAME_LEN)

		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		created_name = t

	else
		return ..()

/obj/machinery/bot/floorbot/Process_Spacemove(movement_dir = 0)
	return 1
