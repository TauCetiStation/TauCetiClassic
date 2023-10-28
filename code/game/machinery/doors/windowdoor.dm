ADD_TO_GLOBAL_LIST(/obj/machinery/door/window, windowdoor_list)

/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	always_transparent = TRUE
	flags = ON_BORDER
	opacity = 0
	explosive_resistance = 0
	air_properties_vary_with_direction = 1
	door_open_sound  = 'sound/machines/windowdoor.ogg'
	door_close_sound = 'sound/machines/windowdoor.ogg'

	can_wedge_items = FALSE

	var/obj/item/weapon/airlock_electronics/electronics = null
	var/base_state = "left"
	max_integrity = 150
	integrity_failure = 0
	armor = list(MELEE = 20, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 0, FIRE = 70, ACID = 100)
	// For use with door control buttons. Currently just that.
	var/id = null

/obj/machinery/door/window/atom_init()
	. = ..()

	if (req_access && req_access.len)
		icon_state = "[icon_state]"
		base_state = icon_state

	color = SSstation_coloring.get_default_color()

	if(unres_sides)
		//remove unres_sides from directions it can't be bumped from
		switch(dir)
			if(NORTH,SOUTH)
				unres_sides &= ~EAST
				unres_sides &= ~WEST
			if(EAST,WEST)
				unres_sides &= ~NORTH
				unres_sides &= ~SOUTH

	src.unres_sides = unres_sides

/obj/machinery/door/window/Destroy()
	density = FALSE
	update_nearby_tiles()
	QDEL_NULL(electronics)
	return ..()

/obj/machinery/door/window/proc/open_and_close()
	open()
	if(check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	close()

/obj/machinery/door/window/update_icon()
	if(density)
		icon_state = base_state
	else
		icon_state = "[src.base_state]open"
	SSdemo.mark_dirty(src)

/obj/machinery/door/window/proc/shatter()
	if(!(flags & NODECONSTRUCT))
		new /obj/item/weapon/shard(loc)
		new /obj/item/weapon/shard(loc)
		new /obj/item/stack/rods(loc, 2)
		new /obj/item/stack/cable_coil/red(loc, 2)
		var/obj/item/weapon/airlock_electronics/ae
		if(!electronics)
			ae = new (src.loc)
			if(!src.req_access)
				check_access()
			if(src.req_access.len)
				ae.conf_access = src.req_access
			else if (src.req_one_access.len)
				ae.conf_access = src.req_one_access
				ae.one_access = 1
		else
			ae = electronics
			electronics = null
			ae.loc = src.loc
		ae.unres_sides = unres_sides
		if(operating == -1)
			ae.icon_state = "door_electronics_smoked"
			ae.broken = TRUE
			operating = 0
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	visible_message("[src] shatters!")
	qdel(src)

//painter
/obj/machinery/door/window/proc/change_paintjob(obj/item/weapon/airlock_painter/W, mob/user)
	if(!istype(W))
		return

	if(!W.can_use(user, 1))
		return

	var/new_color = input(user, "Choose color!") as color|null

	if(!new_color)
		return

	if(W.use_tool(src, user, 50, 1))
		color = new_color

/obj/machinery/door/window/Bumped(atom/movable/AM)
	if(operating || !src.density)
		return
	if(!ismob(AM))
		if(allowed(AM))
			open_and_close()
		else
			do_animate("deny")
		return
	var/mob/M = AM
	if(!M.restrained())
		bumpopen(M)

/obj/machinery/door/window/bumpopen(mob/user)
	if( operating || !src.density )
		return
	add_fingerprint(user)
	if(!requiresID())
		user = null

	if(allowed(user))
		open_and_close()
	else
		do_animate("deny")
	return

/obj/machinery/door/window/c_airblock(turf/other)
	if(get_dir(loc, other) == dir) //Make sure looking at appropriate border (so we wont zoneblock every direction)
		return ..()
	return NONE

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		//if(air_group) return 0
		return !density
	else
		return 1

/obj/machinery/door/window/unrestricted_side(mob/opener)
	if(get_turf(opener) == loc)
		return turn(dir,180) & unres_sides
	return ..()

/obj/machinery/door/window/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	return !density || (dir != to_dir) || (check_access(ID) && hasPower())

/obj/machinery/door/window/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/window/normal_open_checks()
	if(hasPower() && !emagged)
		return TRUE
	return FALSE

/obj/machinery/door/window/normal_close_checks()
	if(hasPower() && !emagged)
		return TRUE
	return FALSE

/obj/machinery/door/window/do_open()
	if(hasPower())
		use_power(15)
	playsound(src, door_open_sound, VOL_EFFECTS_MASTER)
	do_animate("opening")
	icon_state = "[base_state]open"
	sleep(10)
	density = FALSE
	block_air_zones = FALSE // We merge zones if door is open.
	explosive_resistance = 0
	update_nearby_tiles()

/obj/machinery/door/window/do_close()
	if(hasPower())
		use_power(15)
	playsound(src, door_close_sound, VOL_EFFECTS_MASTER)
	do_animate("closing")
	icon_state = base_state
	density = TRUE
	block_air_zones = TRUE
	explosive_resistance = initial(explosive_resistance)
	update_nearby_tiles()

/obj/machinery/door/window/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[base_state]opening", src)
		if("closing")
			flick("[base_state]closing", src)
		if("deny")
			flick("[base_state]deny", src)
	return

/obj/machinery/door/window/deconstruct(disassembled)
	shatter()

/obj/machinery/door/window/bullet_act(obj/item/projectile/Proj, def_zone)
	if(Proj.pass_flags & PASSGLASS)
		return PROJECTILE_FORCE_MISS
	return ..()

/obj/machinery/door/window/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glasshit.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/machinery/door/window/attack_generic(mob/user)
	if(operating)
		return
	user.visible_message("<span class='danger'>[user] smashes against the [src.name].</span>", \
						"<span class='userdanger'>[user] smashes against the [src.name].</span>")
	return ..()

/obj/machinery/door/window/attack_slime(mob/living/carbon/slime/user)
	if(!isslimeadult(user))
		return
	attack_generic(user, 25)

/obj/machinery/door/window/attackby(obj/item/weapon/I, mob/user)

	//If it's in the process of opening/closing, ignore the click
	if (src.operating == 1)
		return

	if(istype(I, /obj/item/weapon/airlock_painter))
		change_paintjob(I, user)
		return

	//Emags and ninja swords? You may pass.
	if (density && istype(I, /obj/item/weapon/melee/energy/blade))
		flick("[src.base_state]spark", src)
		user.SetNextMove(CLICK_CD_MELEE)
		sleep(6)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='warning'> The glass door was sliced open by [user]!</span>")
		open(1)
		return

	if(!(flags & NODECONSTRUCT))
		if(isscrewing(I))
			if(src.density || src.operating == 1)
				to_chat(user, "<span class='warning'>You need to open the [src.name] to access the maintenance panel.</span>")
				return
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			src.p_open = !( src.p_open )
			to_chat(user, "<span class='notice'>You [p_open ? "open":"close"] the maintenance panel of the [src.name].</span>")
			return

		if(isprying(I))
			if(p_open && !src.density)
				if(user.is_busy(src)) return
				user.visible_message("<span class='warning'>[user] removes the electronics from the [src.name].</span>", \
									 "You start to remove electronics from the [src.name].")
				if(I.use_tool(src, user, 40, volume = 100))
					if(src.p_open && !src.density && src.loc)
						var/obj/structure/windoor_assembly/WA = new /obj/structure/windoor_assembly(src.loc)
						switch(base_state)
							if("left")
								WA.icon_state = "l_windoor_assembly02"
							if("right")
								WA.icon_state = "r_windoor_assembly02"
							if("leftsecure")
								WA.icon_state = "l_secure_windoor_assembly02"
								WA.secure = 1
							if("rightsecure")
								WA.icon_state = "r_secure_windoor_assembly02"
								WA.secure = 1
								WA.anchored = TRUE
						WA.state= "02"
						WA.set_dir(src.dir)
						WA.ini_dir = src.dir
						WA.update_icon()
						WA.created_name = src.name

						to_chat(user, "<span class='notice'>You removed the airlock electronics!</span>")

						var/obj/item/weapon/airlock_electronics/ae
						if(!electronics)
							ae = new (src.loc)
							if(!req_access)
								check_access()
							if(req_access.len)
								ae.conf_access = req_access
							else if(req_one_access.len)
								ae.conf_access = req_one_access
								ae.one_access = 1
							else
						else
							ae = electronics
							electronics = null
							ae.loc = src.loc
						ae.unres_sides = unres_sides

						if(operating == -1)
							ae.icon_state = "door_electronics_smoked"
							ae.broken = TRUE
							operating = 0

						qdel(src)
				return


	//If windoor is unpowered, crowbar, fireaxe and armblade can force it.
	if(isprying(I))
		if(!hasPower())
			user.SetNextMove(CLICK_CD_INTERACT)
			if(density)
				open(1)
			else
				close(1)
			return

	//If it's a weapon, smash windoor. Unless it's an id card, agent card, ect.. then ignore it (Cards really shouldnt damage a door anyway)
	if(src.density && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card))
		return ..()

	try_open(user)

/obj/machinery/door/window/emag_act(mob/user)
	if(density)
		flick("[src.base_state]spark", src)
		user.SetNextMove(CLICK_CD_MELEE)
		sleep(6)
		open()
		operating = -1
		return TRUE
	return FALSE

/obj/machinery/door/window/emp_act(severity)
	if(prob(20/severity))
		open()
	if(prob(40/severity))
		if(secondsElectrified == 0)
			secondsElectrified = -1
			diag_hud_set_electrified()
			spawn(300)
				secondsElectrified = 0
				diag_hud_set_electrified()
	..()

/obj/machinery/door/window/brigdoor
	name = "Secure Door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(access_security)
	max_integrity = 300 //Stronger doors for prison (regular window door health is 150)

/obj/machinery/door/window/brigdoor/atom_init()
	. = ..()
	brigdoor_list += src

/obj/machinery/door/window/brigdoor/Destroy()
	brigdoor_list -= src
	return ..()

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"
