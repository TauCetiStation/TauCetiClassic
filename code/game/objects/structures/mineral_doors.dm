//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its
//machineryness

/obj/structure/mineral_door
	name = "mineral door"
	density = 1
	anchored = 1
	opacity = 1

	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = "metal"

	var/mineralType = "metal"
	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0
	var/oreAmount = 7

	var/health = 100

/obj/structure/mineral_door/New(location)
	..()
	icon_state = mineralType
	name = "[mineralType] door"
	update_nearby_tiles(need_rebuild=1)

/obj/structure/mineral_door/Destroy()
	update_nearby_tiles()
	..()

/obj/structure/mineral_door/Bumped(atom/user)
	..()
	if(!state)
		return TryToSwitchState(user)
	return

/obj/structure/mineral_door/attack_ai(mob/user as mob) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user)) //but cyborgs can
		if(get_dist(user,src) <= 1) //not remotely though
			return TryToSwitchState(user)

/obj/structure/mineral_door/attack_paw(mob/user as mob)
	return TryToSwitchState(user)

/obj/structure/mineral_door/attack_hand(mob/user as mob)
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
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 100, 1)
	flick("[mineralType]opening",src)
	sleep(10)
	density = 0
	opacity = 0
	state = 1
	update_icon()
	isSwitchingStates = 0
	update_nearby_tiles()

/obj/structure/mineral_door/proc/Close()
	isSwitchingStates = 1
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 100, 1)
	flick("[mineralType]closing",src)
	sleep(10)
	density = 1
	opacity = 1
	state = 0
	update_icon()
	isSwitchingStates = 0
	update_nearby_tiles()

/obj/structure/mineral_door/update_icon()
	if(state)
		icon_state = "[mineralType]open"
	else
		icon_state = mineralType

/obj/structure/mineral_door/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/digTool = W
		user << "You start digging the [name]."
		if(do_after(user,digTool.digspeed, target = src) && src)
			user << "You finished digging."
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
			if(WT.remove_fuel(0, user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
				user.visible_message("[user] dissassembles [src].", "You start to dissassemble [src].")
				if(do_after(user, 60, target = src))
					user << "\blue You dissasembled [src]!"
					Dismantle()
				else
					return
			else
				user << "\blue You need more welding fuel."
				return
		else if (istype(W, /obj/item/weapon/wrench))
			if(!istype(src, /obj/structure/mineral_door/wood))
				health -= W.force
				CheckHealth()
				return ..()
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user.visible_message("[user] dissassembles [src].", "You start to dissassemble [src].")
			if(do_after(user, 40, target = src))
				user << "\blue You dissasembled [src]!"
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

/obj/structure/mineral_door/proc/update_nearby_tiles(need_rebuild) //Copypasta from airlock code
	if(!air_master)
		return 0
	air_master.mark_for_update(get_turf(src))
	return 1

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

/obj/structure/mineral_door/transparent/phoron/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			TemperatureAct(100)
	..()

/obj/structure/mineral_door/transparent/phoron/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		TemperatureAct(exposed_temperature)

/obj/structure/mineral_door/transparent/phoron/proc/TemperatureAct(temperature)
	for(var/turf/simulated/floor/target_tile in range(2,loc))

		var/datum/gas_mixture/napalm = new

		var/phoronToDeduce = temperature/10

		napalm.phoron = phoronToDeduce
		napalm.temperature = 200+T0C

		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(temperature, 400)

		health -= phoronToDeduce/100
		CheckHealth()

/obj/structure/mineral_door/transparent/diamond
	mineralType = "diamond"
	health = 1000

/obj/structure/mineral_door/wood
	mineralType = "wood"

/obj/structure/mineral_door/wood/Open()
	isSwitchingStates = 1
	playsound(loc, 'sound/effects/doorcreaky.ogg', 100, 1)
	flick("[mineralType]opening",src)
	sleep(10)
	density = 0
	opacity = 0
	state = 1
	update_icon()
	isSwitchingStates = 0

/obj/structure/mineral_door/wood/Close()
	isSwitchingStates = 1
	playsound(loc, 'sound/effects/doorcreaky.ogg', 100, 1)
	flick("[mineralType]closing",src)
	sleep(10)
	density = 1
	opacity = 1
	state = 0
	update_icon()
	isSwitchingStates = 0

/obj/structure/mineral_door/wood/Dismantle(devastated = 0)
	if(!devastated)
		for(var/i = 1, i <= oreAmount, i++)
			new/obj/item/stack/sheet/wood(get_turf(src))
	qdel(src)

/obj/structure/mineral_door/resin
	icon = 'tauceti/icons/mob/alien.dmi'
	mineralType = "resin"
	health = 150
	var/close_delay = 100

/obj/structure/mineral_door/resin/TryToSwitchState(atom/user)
	if(isalien(user))
		return ..()

/obj/structure/mineral_door/resin/Open()
	isSwitchingStates = 1
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	flick("[mineralType]opening",src)
	sleep(10)
	density = 0
	opacity = 0
	state = 1
	update_icon()
	isSwitchingStates = 0

	spawn(close_delay)
		if(!isSwitchingStates && state == 1)
			Close()

/obj/structure/mineral_door/resin/Close()
	isSwitchingStates = 1
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	flick("[mineralType]closing",src)
	sleep(10)
	density = 1
	opacity = 1
	state = 0
	update_icon()
	isSwitchingStates = 0

/obj/structure/mineral_door/resin/Dismantle(devastated = 0)
	qdel(src)

/obj/structure/mineral_door/resin/CheckHealth()
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	..()

