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

//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	//weight = 1.0E7
	var/amount = 10
	var/repairing = 0
	var/improvefloors = 0
	var/eattiles = 0
	var/maketiles = 0
	var/turf/target
	var/turf/oldtarget
	var/oldloc = null
	req_access = list(access_construction)
	var/path[] = new()
	var/targetdirection


/obj/machinery/bot/floorbot/atom_init()
	. = ..()
	updateicon()

/obj/machinery/bot/floorbot/turn_on()
	. = ..()
	src.updateicon()
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/turn_off()
	..()
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.updateicon()
	src.path = new()
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/ui_interact(mob/user)
	var/dat
	dat += "<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [src.open ? "opened" : "closed"]<BR>"
	dat += "Tiles left: [src.amount]<BR>"
	dat += "Behvaiour controls are [src.locked ? "locked" : "unlocked"]<BR>"
	if(!src.locked || issilicon(user) ||isobserver(user))
		dat += "Improves floors: <A href='?src=\ref[src];operation=improve'>[src.improvefloors ? "Yes" : "No"]</A><BR>"
		dat += "Finds tiles: <A href='?src=\ref[src];operation=tiles'>[src.eattiles ? "Yes" : "No"]</A><BR>"
		dat += "Make singles pieces of metal into tiles when empty: <A href='?src=\ref[src];operation=make'>[src.maketiles ? "Yes" : "No"]</A><BR>"
		var/bmode
		if (src.targetdirection)
			bmode = dir2text(src.targetdirection)
		else
			bmode = "Disabled"
		dat += "<BR><BR>Bridge Mode : <A href='?src=\ref[src];operation=bridgemode'>[bmode]</A><BR>"

	user << browse("<HEAD><TITLE>Repairbot v1.0 controls</TITLE></HEAD>[entity_ja(dat)]", "window=autorepair")
	onclose(user, "autorepair")


/obj/machinery/bot/floorbot/attackby(obj/item/W , mob/user)
	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(src.amount >= 50)
			return
		var/loaded = min(50-src.amount, T.get_amount())
		T.use(loaded)
		src.amount += loaded
		to_chat(user, "<span class='notice'>You load [loaded] tiles into the floorbot. He now contains [src.amount] tiles.</span>")
		src.updateicon()
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(src.allowed(usr) && !open && !emagged)
			src.locked = !src.locked
			to_chat(user, "<span class='notice'>You [src.locked ? "lock" : "unlock"] the [src] behaviour controls.</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
		src.updateUsrDialog()
	else
		..()

/obj/machinery/bot/floorbot/Emag(mob/user)
	..()
	if(open && !locked && user)
		to_chat(user, "<span class='notice'>The [src] buzzes and beeps.</span>")

/obj/machinery/bot/floorbot/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	switch(href_list["operation"])
		if("start")
			if (src.on)
				turn_off()
			else
				turn_on()
		if("improve")
			src.improvefloors = !src.improvefloors
		if("tiles")
			src.eattiles = !src.eattiles
		if("make")
			src.maketiles = !src.maketiles
		if("bridgemode")
			switch(src.targetdirection)
				if(null)
					targetdirection = 1
				if(1)
					targetdirection = 2
				if(2)
					targetdirection = 4
				if(4)
					targetdirection = 8
				if(8)
					targetdirection = null
				else
					targetdirection = null
	src.updateUsrDialog()

/obj/machinery/bot/floorbot/process()
	//set background = 1

	if(!src.on)
		return
	if(src.repairing)
		return
	var/list/floorbottargets = list()
	if(src.amount <= 0 && ((src.target == null) || !src.target))
		if(src.eattiles)
			for(var/obj/item/stack/tile/plasteel/T in view(7, src))
				if(T != src.oldtarget && !(target in floorbottargets))
					src.oldtarget = T
					src.target = T
					return
		if(src.target == null || !src.target)
			if(src.maketiles)
				for(var/obj/item/stack/sheet/metal/M in view(7, src))
					if(!(M in floorbottargets) && M != src.oldtarget && M.get_amount() == 1 && !(istype(M.loc, /turf/simulated/wall)))
						src.oldtarget = M
						src.target = M
						return
		else
			return
	if(prob(5))
		visible_message("[src] makes an excited booping beeping sound!")

	if((!src.target || src.target == null) && emagged < 2)
		if(targetdirection != null)
			/*
			for (var/turf/space/D in view(7,src))
				if(!(D in floorbottargets) && D != src.oldtarget)			// Added for bridging mode -- TLE
					if(get_dir(src, D) == targetdirection)
						src.oldtarget = D
						src.target = D
						break
			*/
			var/turf/T = get_step(src, targetdirection)
			if(istype(T, /turf/space))
				src.oldtarget = T
				src.target = T
		if(!src.target || src.target == null)
			for (var/turf/space/D in view(7,src))
				if(!(D in floorbottargets) && D != src.oldtarget && (D.loc.name != "Space"))
					src.oldtarget = D
					src.target = D
					break
		if((!src.target || src.target == null ) && src.improvefloors)
			for (var/turf/simulated/floor/F in view(7,src))
				if(!(F in floorbottargets) && F != src.oldtarget && F.icon_state == "Floor1" && !(istype(F, /turf/simulated/floor/plating)))
					src.oldtarget = F
					src.target = F
					break
		if((!src.target || src.target == null) && src.eattiles)
			for(var/obj/item/stack/tile/plasteel/T in view(7, src))
				if(!(T in floorbottargets) && T != src.oldtarget)
					src.oldtarget = T
					src.target = T
					break

	if((!src.target || src.target == null) && emagged == 2)
		if(!src.target || src.target == null)
			for (var/turf/simulated/floor/D in view(7,src))
				if(!(D in floorbottargets) && D != src.oldtarget && D.floor_type)
					src.oldtarget = D
					src.target = D
					break

	if(!src.target || src.target == null)
		if(src.loc != src.oldloc)
			src.oldtarget = null
		return

	if(src.target && (src.target != null) && src.path.len == 0)
		spawn(0)
			if(!istype(src.target, /turf))
				src.path = get_path_to(src, get_turf(src.target), /turf/proc/Distance_cardinal, 0, 30, id=botcard, simulated_only = FALSE)
			else
				src.path = get_path_to(src, get_turf(src.target), /turf/proc/Distance_cardinal, 0, 30, id=botcard, simulated_only = FALSE)
			if(src.path.len == 0)
				src.oldtarget = src.target
				src.target = null
		return
	if(src.path.len > 0 && src.target && (src.target != null))
		step_to(src, src.path[1])
		src.path -= src.path[1]
	else if(src.path.len == 1)
		step_to(src, target)
		src.path = new()

	if(src.loc == src.target || src.loc == src.target.loc)
		if(istype(src.target, /obj/item/stack/tile/plasteel))
			src.eattile(src.target)
		else if(istype(src.target, /obj/item/stack/sheet/metal))
			src.maketile(src.target)
		else if(istype(src.target, /turf) && emagged < 2)
			repair(src.target)
		else if(emagged == 2 && istype(src.target,/turf/simulated/floor))
			var/turf/simulated/floor/F = src.target
			src.anchored = 1
			src.repairing = 1
			if(prob(90))
				F.break_tile_to_plating()
			else
				F.ReplaceWithLattice()
			visible_message("\red [src] makes an excited booping sound.")
			spawn(50)
				src.amount ++
				src.anchored = 0
				src.repairing = 0
				src.target = null
		src.path = new()
		return

	src.oldloc = src.loc


/obj/machinery/bot/floorbot/proc/repair(turf/target)
	if(istype(target, /turf/space))
		if(target.loc.name == "Space")
			return
	else if(!istype(target, /turf/simulated/floor))
		return
	if(src.amount <= 0)
		return
	src.anchored = 1
	src.icon_state = "floorbot-c"
	if(istype(target, /turf/space))
		visible_message("\red [src] begins to repair the hole")
		var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
		src.repairing = 1
		spawn(50)
			T.build(src.loc)
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			src.target = null
	else
		visible_message("\red [src] begins to improve the floor.")
		src.repairing = 1
		spawn(50)
			src.loc.icon_state = "floor"
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			src.target = null

/obj/machinery/bot/floorbot/proc/eattile(obj/item/stack/tile/plasteel/T)
	if(!istype(T))
		return
	visible_message("\red [src] begins to collect tiles.")
	src.repairing = 1
	spawn(20)
		if(QDELETED(T))
			src.target = null
			src.repairing = 0
			return
		if(src.amount + T.get_amount() > 50)
			var/i = 50 - src.amount
			src.amount += i
			T.use(i)
		else
			src.amount += T.get_amount()
			qdel(T)
		src.updateicon()
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/maketile(obj/item/stack/sheet/metal/M)
	if(!istype(M))
		return
	if(M.get_amount() > 1)
		return
	visible_message("\red [src] begins to create tiles.")
	src.repairing = 1
	spawn(20)
		if(QDELETED(M))
			src.target = null
			src.repairing = 0
			return
		new /obj/item/stack/tile/plasteel(M.loc, 4)
		qdel(M)
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/updateicon()
	if(src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"

/obj/machinery/bot/floorbot/explode()
	src.on = 0
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
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


/obj/item/weapon/storage/toolbox/mechanical/attackby(obj/item/stack/tile/plasteel/T, mob/user)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		..()
		return
	if(src.contents.len >= 1)
		to_chat(user, "<span class='notice'>They wont fit in as there is already stuff inside.</span>")
		return
	if(user.s_active)
		user.s_active.close(user)
	qdel(T)
	var/obj/item/weapon/toolbox_tiles/B = new /obj/item/weapon/toolbox_tiles
	user.put_in_hands(B)
	to_chat(user, "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>")
	user.drop_from_inventory(src)
	qdel(src)

/obj/item/weapon/toolbox_tiles/attackby(obj/item/W, mob/user)
	..()
	if(isprox(W))
		qdel(W)
		var/obj/item/weapon/toolbox_tiles_sensor/B = new /obj/item/weapon/toolbox_tiles_sensor()
		B.created_name = src.created_name
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the sensor to the toolbox and tiles!</span>")
		user.drop_from_inventory(src)
		qdel(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter new robot name", src.name, input_default(src.created_name)),MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t

/obj/item/weapon/toolbox_tiles_sensor/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		qdel(W)
		var/turf/T = get_turf(user.loc)
		var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot(T)
		A.name = src.created_name
		to_chat(user, "<span class='notice'>You add the robot arm to the odd looking toolbox assembly! Boop beep!</span>")
		user.drop_from_inventory(src)
		qdel(src)
	else if (istype(W, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter new robot name", src.name, input_default(src.created_name)), MAX_NAME_LEN)

		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t

/obj/machinery/bot/floorbot/Process_Spacemove(movement_dir = 0)
	return 1
