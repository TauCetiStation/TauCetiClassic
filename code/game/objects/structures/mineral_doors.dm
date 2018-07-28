//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its
//machineryness

/obj/structure/mineral_door
	name = "mineral door"
	density = 1
	anchored = 1
	opacity = 1

	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = "metal"

	var/operating_sound = 'sound/effects/stonedoor_openclose.ogg'
	var/mineralType = "metal"
	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0
	var/oreAmount = 7

	var/health = 100

/obj/structure/mineral_door/atom_init()
	. = ..()
	icon_state = mineralType
	name = "[mineralType] door"
	update_nearby_tiles(need_rebuild = 1)

/obj/structure/mineral_door/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/mineral_door/Bumped(atom/user)
	..()
	if(!state)
		return TryToSwitchState(user)
	return

/obj/structure/mineral_door/attack_ai(mob/user) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user)) //but cyborgs can
		if(get_dist(user,src) <= 1) //not remotely though
			return TryToSwitchState(user)

/obj/structure/mineral_door/attack_paw(mob/user)
	return TryToSwitchState(user)

/obj/structure/mineral_door/attack_hand(mob/user)
	return TryToSwitchState(user)

/obj/structure/mineral_door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/mineral_door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates) return
	if(ismob(user))
		var/mob/M = user
		if(world.time - user.last_bumped <= 60) return //NOTE do we really need that?
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()
	else if(istype(user, /obj/mecha))
		SwitchState()

/obj/structure/mineral_door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()

/obj/structure/mineral_door/proc/Open()
	isSwitchingStates = 1
	playsound(loc, operating_sound, 100, 1)
	flick("[mineralType]opening",src)
	sleep(10)
	density = 0
	set_opacity(0)
	state = 1
	update_icon()
	isSwitchingStates = 0
	update_nearby_tiles()

/obj/structure/mineral_door/proc/Close()
	isSwitchingStates = 1
	playsound(loc, operating_sound, 100, 1)
	flick("[mineralType]closing",src)
	sleep(10)
	density = 1
	set_opacity(1)
	state = 0
	update_icon()
	isSwitchingStates = 0
	update_nearby_tiles()

/obj/structure/mineral_door/update_icon()
	if(state)
		icon_state = "[mineralType]open"
	else
		icon_state = mineralType

/obj/structure/mineral_door/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/pickaxe))
		if(user.is_busy()) return
		var/obj/item/weapon/pickaxe/digTool = W
		to_chat(user, "You start digging the [name].")
		if(do_after(user,digTool.digspeed, target = src) && src)
			to_chat(user, "You finished digging.")
			Dismantle()
	else if(istype(W, /obj/item/weapon))
		if (istype(W, /obj/item/weapon/weldingtool))
			if(istype(src, /obj/structure/mineral_door/resin) || istype(src, /obj/structure/mineral_door/wood))
				health -= W.force
				CheckHealth()
				return ..()
			var/obj/item/weapon/weldingtool/WT = W
			if(!src || !WT.isOn())
				return ..()
			if(user.is_busy()) return
			if(WT.remove_fuel(0, user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
				user.visible_message("[user] dissassembles [src].", "You start to dissassemble [src].")
				if(do_after(user, 60, target = src))
					to_chat(user, "\blue You dissasembled [src]!")
					Dismantle()
				else
					return
			else
				to_chat(user, "\blue You need more welding fuel.")
				return
		else if (istype(W, /obj/item/weapon/wrench))
			if(!istype(src, /obj/structure/mineral_door/wood))
				health -= W.force
				CheckHealth()
				return ..()
			if(user.is_busy()) return
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user.visible_message("[user] dissassembles [src].", "You start to dissassemble [src].")
			if(do_after(user, 40, target = src))
				to_chat(user, "\blue You dissasembled [src]!")
				Dismantle()
			else
				return
		health -= W.force
		CheckHealth()
		return ..()
	else
		attack_hand(user)
	return

/obj/structure/mineral_door/proc/CheckHealth()
	if(health <= 0)
		Dismantle(1)

/obj/structure/mineral_door/proc/Dismantle(devastated = 0)
	if(!devastated)
		if (mineralType == "metal")
			var/ore = /obj/item/stack/sheet/metal
			for(var/i = 1, i <= oreAmount, i++)
				new ore(get_turf(src))
		else
			var/ore = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
			for(var/i = 1, i <= oreAmount, i++)
				new ore(get_turf(src))
	else
		if (mineralType == "metal")
			var/ore = /obj/item/stack/sheet/metal
			for(var/i = 3, i <= oreAmount, i++)
				new ore(get_turf(src))
		else
			var/ore = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
			for(var/i = 3, i <= oreAmount, i++)
				new ore(get_turf(src))
	qdel(src)

/obj/structure/mineral_door/ex_act(severity = 1)
	switch(severity)
		if(1)
			Dismantle(1)
		if(2)
			if(prob(20))
				Dismantle(1)
			else
				health--
				CheckHealth()
		if(3)
			health -= 0.1
			CheckHealth()
	return

/obj/structure/mineral_door/iron
	mineralType = "metal"
	health = 300

/obj/structure/mineral_door/silver
	mineralType = "silver"
	health = 300

/obj/structure/mineral_door/gold
	mineralType = "gold"

/obj/structure/mineral_door/uranium
	mineralType = "uranium"
	health = 300
	light_range = 2

/obj/structure/mineral_door/sandstone
	mineralType = "sandstone"
	health = 50

/obj/structure/mineral_door/transparent
	opacity = 0

/obj/structure/mineral_door/transparent/Close()
	..()
	opacity = 0

/obj/structure/mineral_door/transparent/phoron
	mineralType = "phoron"

/obj/structure/mineral_door/transparent/diamond
	mineralType = "diamond"
	health = 1000

/obj/structure/mineral_door/wood
	operating_sound = 'sound/effects/doorcreaky.ogg'
	mineralType = "wood"

/obj/structure/mineral_door/wood/Dismantle(devastated = 0)
	if(!devastated)
		for(var/i = 1, i <= oreAmount, i++)
			new/obj/item/stack/sheet/wood(get_turf(src))
	qdel(src)

/obj/structure/mineral_door/resin
	icon = 'icons/mob/alien.dmi'
	operating_sound = 'sound/effects/attackblob.ogg'
	mineralType = "resin"
	health = 150
	var/close_delay = 100

/obj/structure/mineral_door/resin/atom_init()
	var/turf/T = get_turf(loc)
	if(T)
		T.blocks_air = TRUE
	. = ..()

/obj/structure/mineral_door/resin/Destroy()
	var/turf/T = get_turf(loc)
	if(T)
		T.blocks_air = FALSE
	return ..()

/obj/structure/mineral_door/resin/TryToSwitchState(atom/user)
	if(isalien(user))
		return ..()

/obj/structure/mineral_door/resin/Open()
	..()
	addtimer(CALLBACK(src, .proc/TryToClose), close_delay)

/obj/structure/mineral_door/resin/proc/TryToClose()
	if(!isSwitchingStates && state == 1)
		Close()

/obj/structure/mineral_door/resin/Dismantle(devastated = 0)
	qdel(src)

/obj/structure/mineral_door/resin/CheckHealth()
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	..()

/obj/structure/mineral_door/resin/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	CheckHealth()
	return

/obj/structure/mineral_door/resin/attack_paw(mob/user)
	if(isalienadult(user) && user.a_intent == "hurt")
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		health -= rand(40, 60)
		if(health <= 0)
			user.visible_message("<span class='danger'>[user] slices the [name] to pieces!</span>")
		else
			user.visible_message("<span class='danger'>[user] claws at the resin!</span>")
		CheckHealth()
	else
		return ..()
