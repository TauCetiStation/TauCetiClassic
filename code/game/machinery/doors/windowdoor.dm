/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	visible = 0.0
	flags = ON_BORDER
	opacity = 0
	explosion_resistance = 5
	air_properties_vary_with_direction = 1
	door_open_sound  = 'sound/machines/windowdoor.ogg'
	door_close_sound = 'sound/machines/windowdoor.ogg'
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/base_state = "left"
	var/health = 150.0 //If you change this, consider changing ../door/window/brigdoor/ health at the bottom of this .dm file

/obj/machinery/door/window/atom_init()
	. = ..()

	if (req_access && req_access.len)
		icon_state = "[icon_state]"
		base_state = icon_state

	color = color_windows()

/obj/machinery/door/window/Destroy()
	density = 0
	update_nearby_tiles()
	electronics = null
	return ..()

/obj/machinery/door/window/proc/open_and_close()
	open()
	if(src.check_access(null))
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

/obj/machinery/door/window/proc/shatter(display_message = 1)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/weapon/shard(loc)
		new /obj/item/weapon/shard(loc)
		new /obj/item/stack/rods(loc, 2)
		new /obj/item/stack/cable_coil/red(loc, 2)
		var/obj/item/weapon/airlock_electronics/ae
		if(!electronics)
			ae = new/obj/item/weapon/airlock_electronics( src.loc )
			if(!src.req_access)
				src.check_access()
			if(src.req_access.len)
				ae.conf_access = src.req_access
			else if (src.req_one_access.len)
				ae.conf_access = src.req_one_access
				ae.one_access = 1
		else
			ae = electronics
			electronics = null
			ae.loc = src.loc
		if(operating == -1)
			ae.icon_state = "door_electronics_smoked"
			ae.broken = TRUE
			operating = 0
	src.density = 0
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	if(display_message)
		visible_message("[src] shatters!")
	qdel(src)

//painter
/obj/machinery/door/window/proc/change_paintjob(obj/item/C, mob/user)
	var/obj/item/weapon/airlock_painter/W
	if(istype(C, /obj/item/weapon/airlock_painter))
		W = C
	else
		return

	if(!W.can_use(user, 1))
		return

	var/new_color = input(user, "Choose color!") as color|null
	if(!new_color) return

	if((!in_range(src, usr) && src.loc != usr) || !W.use(1))
		return
	else
		color = new_color

/obj/machinery/door/window/Bumped(atom/movable/AM)
	if( operating || !src.density )
		return
	if (!( ismob(AM) ))
		var/obj/machinery/bot/bot = AM
		if(istype(bot))
			if(src.check_access(bot.botcard))
				open_and_close()
			else
				do_animate("deny")
		else if(istype(AM, /obj/mecha))
			var/obj/mecha/mecha = AM
			if(mecha.occupant && src.allowed(mecha.occupant))
				open_and_close()
			else
				do_animate("deny")
		return
	if (!( SSticker ))
		return
	var/mob/M = AM
	if(!M.restrained())
		bumpopen(M)
	return

/obj/machinery/door/window/bumpopen(mob/user)
	if( operating || !src.density )
		return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(allowed(user))
		open_and_close()
	else
		do_animate("deny")
	return

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		//if(air_group) return 0
		return !density
	else
		return 1

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
	explosion_resistance = 0
	update_nearby_tiles()

/obj/machinery/door/window/do_close()
	if(hasPower())
		use_power(15)
	playsound(src, door_close_sound, VOL_EFFECTS_MASTER)
	do_animate("closing")
	icon_state = base_state
	density = TRUE
	block_air_zones = TRUE
	explosion_resistance = initial(explosion_resistance)
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


/obj/machinery/door/window/proc/take_damage(damage)
	src.health = max(0, src.health - damage)
	if(src.health <= 0)
		shatter()
		return

/obj/machinery/door/window/bullet_act(obj/item/projectile/Proj)
	if(Proj.damage)
		take_damage(round(Proj.damage / 2))
	..()

//When an object is thrown at the window
/obj/machinery/door/window/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)

	..()
	visible_message("<span class='warning'><B>The glass door was hit by [AM].</B></span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
	take_damage(tforce)
	//..() //Does this really need to be here twice? The parent proc doesn't even do anything yet. - Nodrak
	return

/obj/machinery/door/window/proc/attack_generic(mob/user, damage = 0)
	if(src.operating)
		return
	user.do_attack_animation(src)
	playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='danger'>[user] smashes against the [src.name].</span>", \
						"<span class='userdanger'>[user] smashes against the [src.name].</span>")
	take_damage(damage)

/obj/machinery/door/window/attack_alien(mob/user)
	if(isxenolarva(user))
		return
	user.SetNextMove(CLICK_CD_MELEE)
	attack_generic(user, 25)

/obj/machinery/door/window/attack_animal(mob/living/simple_animal/attacker)
	..()
	if(attacker.melee_damage <= 0)
		return
	attack_generic(attacker, attacker.melee_damage)

/obj/machinery/door/window/attack_slime(mob/living/carbon/slime/user)
	if(!istype(user, /mob/living/carbon/slime/adult))
		return
	user.SetNextMove(CLICK_CD_MELEE)
	attack_generic(user, 25)

/obj/machinery/door/window/attackby(obj/item/weapon/I, mob/user)

	//If it's in the process of opening/closing, ignore the click
	if (src.operating == 1)
		return

	if(istype(I, /obj/item/weapon/airlock_painter))
		change_paintjob(I, user)
		return

	if( istype(I,/obj/item/weapon/changeling_hammer))
		var/obj/item/weapon/changeling_hammer/W = I
		user.SetNextMove(CLICK_CD_MELEE)
		if(W.use_charge(user, 6))
			visible_message("<span class='red'><B>[user]</B> has punched [src]!</span>")
			playsound(user, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), VOL_EFFECTS_MASTER)
			shatter()
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
		if(isscrewdriver(I))
			if(src.density || src.operating == 1)
				to_chat(user, "<span class='warning'>You need to open the [src.name] to access the maintenance panel.</span>")
				return
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			src.p_open = !( src.p_open )
			to_chat(user, "<span class='notice'>You [p_open ? "open":"close"] the maintenance panel of the [src.name].</span>")
			return

		if(iscrowbar(I))
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
								WA.anchored = 1
						WA.state= "02"
						WA.dir = src.dir
						WA.ini_dir = src.dir
						WA.update_icon()
						WA.created_name = src.name

						to_chat(user, "<span class='notice'>You removed the airlock electronics!</span>")

						var/obj/item/weapon/airlock_electronics/ae
						if(!electronics)
							ae = new/obj/item/weapon/airlock_electronics( src.loc )
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

						if(operating == -1)
							ae.icon_state = "door_electronics_smoked"
							ae.broken = TRUE
							operating = 0

						qdel(src)
				return


	//If windoor is unpowered, crowbar, fireaxe and armblade can force it.
	if(iscrowbar(I) || istype(I, /obj/item/weapon/twohanded/fireaxe) || istype(I, /obj/item/weapon/melee/arm_blade) )
		if(!hasPower())
			user.SetNextMove(CLICK_CD_INTERACT)
			if(density)
				open(1)
			else
				close(1)
			return

	//If it's a weapon, smash windoor. Unless it's an id card, agent card, ect.. then ignore it (Cards really shouldnt damage a door anyway)
	if(src.density && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card))
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		if( (I.flags&NOBLUDGEON) || !I.force )
			return
		var/aforce = I.force
		playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='warning'><B>[src] was hit by [I].</B></span>")
		if(I.damtype == BRUTE || I.damtype == BURN)
			take_damage(aforce)
		return

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

/obj/machinery/door/window/brigdoor
	name = "Secure Door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(access_security)
	var/id = null
	health = 300.0 //Stronger doors for prison (regular window door health is 200)

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
