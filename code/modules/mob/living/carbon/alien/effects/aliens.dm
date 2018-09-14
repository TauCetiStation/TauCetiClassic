/* Alien Effects!
 * Contains:
 *		effect/alien
 *		Resin
 *		Weeds
 *		Acid
 *		Egg
 */

/*
 * effect/alien
 */

#define WEED_SOUTH_EDGING 1
#define WEED_NORTH_EDGING 2
#define WEED_WEST_EDGING  4
#define WEED_EAST_EDGING  8

/obj/effect/alien
	name = "alien thing"
	desc = "theres something alien about this."
	icon = 'icons/mob/xenomorph.dmi'
//	unacidable = 1 //Aliens won't ment their own.


/*
 * Resin
 */
/obj/effect/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "resin"

	density = 1
	opacity = 1
	anchored = 1
	layer = 3.14
	var/health = 250
	var/resintype = null
	//var/mob/living/affecting = null

/obj/effect/alien/resin/wall
		name = "resin wall"
		desc = "Purple slime solidified into a wall."
		icon_state = "wall0" //same as resin, but consistency ho!
		resintype = "wall"

/obj/effect/alien/resin/membrane
		name = "resin membrane"
		desc = "Purple slime just thin enough to let light pass through."
		icon_state = "membrane0"
		opacity = 0
		health = 160
		resintype = "membrane"

/obj/effect/alien/resin/wall/shadowling
	name = "chrysalis wall"
	desc = "Some sort of purple substance in an egglike shape. It pulses and throbs from within and seems impenetrable."
	health = INFINITY

/obj/effect/alien/resin/atom_init()
	relativewall_neighbours()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/alien/resin/atom_init_late()
	var/turf/T = get_turf(src)
	T.thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

/obj/effect/alien/resin/Destroy()
	var/turf/T = get_turf(src)
	T.thermal_conductivity = initial(T.thermal_conductivity)
	return ..()

/obj/effect/alien/resin/proc/healthcheck()
	if(health <=0)
		density = 0
		var/turf/T = loc
		qdel(src)
		for (var/obj/structure/alien/weeds/W in range(1,T))
			W.updateWeedOverlays()
	return

/obj/effect/alien/resin/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/effect/alien/resin/ex_act(severity)
	switch(severity)
		if(1.0)
			health-=50
		if(2.0)
			health-=50
		if(3.0)
			if (prob(50))
				health-=50
			else
				health-=25
	healthcheck()
	return

/obj/effect/alien/resin/blob_act()
	health-=50
	healthcheck()
	return

/obj/effect/alien/resin/meteorhit()
	health-=50
	healthcheck()
	return

/obj/effect/alien/resin/hitby(AM)
	..()
	for(var/mob/O in viewers(src, null))
		O.show_message("\red <B>[src] was hit by [AM].</B>", 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health = max(0, health - tforce)
	healthcheck()
	..()
	return

/obj/effect/alien/resin/attack_hand(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	if (HULK in user.mutations)
		to_chat(user, "\blue You easily destroy the [name].")
		for(var/mob/O in oviewers(src))
			O.show_message("\red [user] destroys the [name]!", 1)
		health = 0
	else
		to_chat(user, "\blue You claw at the [name].")
		for(var/mob/O in oviewers(src))
			O.show_message("\red [user] claws at the [name]!", 1)
		health -= rand(5,10)
	healthcheck()
	return

/obj/effect/alien/resin/attack_paw()
	return attack_hand()

/obj/effect/alien/resin/attack_alien(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	if (islarva(usr) || isfacehugger(usr))//Safety check for larva. /N
		return
	to_chat(usr, "\green You claw at the [name].")
	for(var/mob/O in oviewers(src))
		O.show_message("\red [usr] claws at the resin!", 1)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= rand(40, 60)
	if(health <= 0)
		to_chat(usr, "\green You slice the [name] to pieces.")
		for(var/mob/O in oviewers(src))
			O.show_message("\red [usr] slices the [name] apart!", 1)
	healthcheck()
	return

/obj/effect/alien/resin/attackby(obj/item/weapon/W, mob/user)
	var/aforce = W.force
	user.SetNextMove(CLICK_CD_MELEE)
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	..()
	return

/obj/effect/alien/resin/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density


/*
 * Weeds
 */
#define NODERANGE 3

/obj/structure/alien/weeds
	name = "resin floor"
	desc = "A thick resin surface covers the floor."
	icon = 'icons/mob/xenomorph.dmi'
	icon_state = "weeds"

	anchored = 1
	density = 0
	layer = 2.5
	var/health = 15
	var/obj/structure/alien/weeds/node/linked_node = null
	var/static/list/weedImageCache

/obj/structure/alien/weeds/node
	icon_state = "weednode"
	name = "glowing resin"
	desc = "Blue bioluminescence shines from beneath the surface."
	layer = 2.5
	light_range = 0
	var/node_range = NODERANGE
	light_color = "#24C1FF"

/obj/structure/alien/weeds/node/atom_init(mapload)
	. = ..(mapload, src)

/obj/structure/alien/weeds/node/atom_init_late()
	for (var/obj/structure/alien/weeds/W in loc)
		if (W != src)
			qdel(W)
	set_light(2)
	..()

/obj/structure/alien/weeds/atom_init(mapload, node)
	..()
	if(istype(loc, /turf/space))
		return INITIALIZE_HINT_QDEL
	linked_node = node
	if(icon_state == "weeds")
		icon_state = pick("weeds", "weeds1", "weeds2")
	return INITIALIZE_HINT_LATELOAD

/obj/structure/alien/weeds/atom_init_late()
	if(!weedImageCache)
		weedImageCache = list()
		weedImageCache["[WEED_NORTH_EDGING]"] = image('icons/mob/xenomorph.dmi', "weeds_side_n", layer=2.11, pixel_y = -32)
		weedImageCache["[WEED_SOUTH_EDGING]"] = image('icons/mob/xenomorph.dmi', "weeds_side_s", layer=2.11, pixel_y = 32)
		weedImageCache["[WEED_EAST_EDGING]"]  = image('icons/mob/xenomorph.dmi', "weeds_side_e", layer=2.11, pixel_x = -32)
		weedImageCache["[WEED_WEST_EDGING]"]  = image('icons/mob/xenomorph.dmi', "weeds_side_w", layer=2.11, pixel_x = 32)

	fullUpdateWeedOverlays()
	addtimer(CALLBACK(src, .proc/Life), rand(150, 200))

/obj/structure/alien/weeds/Destroy()
	fullUpdateWeedOverlays()
	linked_node = null
	return ..()

/obj/structure/alien/weeds/proc/updateWeedOverlays()
	overlays.Cut()

	for(var/dir in cardinal)
		var/turf/T = get_step(src, dir)
		var/obj/structure/alien/weeds = locate() in T

		if(!weeds || QDESTROYING(weeds))
			if(istype(T, /turf/simulated/floor))
				overlays += weedImageCache["[dir]"]

/obj/structure/alien/weeds/proc/fullUpdateWeedOverlays()
	for(var/obj/structure/alien/weeds/W in range(1, src))
		W.updateWeedOverlays()

/obj/structure/alien/weeds/proc/Life()
	//set background = 1
	var/turf/U = get_turf(src)

	if (istype(U, /turf/space))
		qdel(src)
		return

	if(!linked_node || (get_dist(linked_node, src) > linked_node.node_range) )
		return

	check_next_dir:
		for(var/dirn in cardinal)
			var/turf/T = get_step(src, dirn)

			if (!istype(T) || T.density || locate(/obj/structure/alien/weeds) in T || istype(T, /turf/space))
				continue

			for(var/obj/machinery/door/D in T)
				if(D.density)
					continue check_next_dir

			var/obj/structure/window/W = locate() in T

			if(W && W.density)
				continue

			new /obj/structure/alien/weeds(T, linked_node)


/obj/structure/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)

/obj/structure/alien/weeds/attackby(obj/item/weapon/W, mob/user)
	if(W.attack_verb.len)
		visible_message("\red <B>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]")
	else
		visible_message("\red <B>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]")

	var/damage = W.force / 4.0
	user.SetNextMove(CLICK_CD_MELEE)

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()


/obj/structure/alien/weeds/temperature_expose(null, temperature, volume)
	if(temperature > T0C+200)
		health -= 1 * temperature
		healthcheck()

/obj/structure/alien/weeds/proc/healthcheck()
	if(health <= 0)
		var/turf/T = loc
		qdel(src)
		for (var/obj/structure/alien/weeds/W in range(1,T))
			W.updateWeedOverlays()

/obj/structure/alien/weeds/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/obj/structure/alien/weeds/bullet_act(obj/item/projectile/Proj)
	return -1

/*/obj/effect/alien/weeds/burn(fi_amount)
	if (fi_amount > 18000)
		spawn( 0 )
			qdel(src)
			return
		return 0
	return 1
*/

#undef NODERANGE


/*
 * Acid
 */
/obj/effect/alien/acid
	name = "acid"
	desc = "Burbling corrossive stuff. I wouldn't want to touch it."
	icon_state = "acid"

	density = 0
	opacity = 0
	anchored = 1

	var/atom/target
	var/ticks = 0
	var/target_strength = 0

/obj/effect/alien/acid/atom_init(mapload, target)
	..()
	src.target = target
	return INITIALIZE_HINT_LATELOAD

/obj/effect/alien/acid/atom_init_late()
	if(isturf(target)) // Turf take twice as long to take down.
		target_strength = 8
	else if(istype(target, /obj/machinery/atmospherics/components/unary/vent_pump))
		target_strength = 2 //Its just welded, what??
	else
		target_strength = 4
	tick()

/obj/effect/alien/acid/proc/tick()
	if(!target)
		qdel(src)

	ticks += 1

	if(ticks >= target_strength)

		for(var/mob/O in hearers(src, null))
			O.show_message("\green <B>[src.target] collapses under its own weight into a puddle of goop and undigested debris!</B>", 1)

		if(istype(target, /turf/simulated/wall)) // I hate turf code.
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else if(istype(target, /obj/machinery/atmospherics/components/unary/vent_pump))
			var/obj/machinery/atmospherics/components/unary/vent_pump/VP = target
			VP.welded = 0
			VP.update_icon()
		else
			qdel(target)
		qdel(src)
		return

	switch(target_strength - ticks)
		if(6)
			visible_message("\green <B>[src.target] is holding up against the acid!</B>")
		if(4)
			visible_message("\green <B>[src.target]\s structure is being melted by the acid!</B>")
		if(2)
			visible_message("\green <B>[src.target] is struggling to withstand the acid!</B>")
		if(0 to 1)
			visible_message("\green <B>[src.target] begins to crumble under the acid!</B>")
	spawn(rand(150, 200)) tick()

/*
 * Egg
 */
/var/const //for the status var
	BURST = 0
	BURSTING = 1
	GROWING = 2
	GROWN = 3

	MIN_GROWTH_TIME = 1800 //time it takes to grow a hugger
	MAX_GROWTH_TIME = 3000

/obj/effect/alien/egg
	desc = "It looks like a weird egg."
	name = "egg"
	icon_state = "egg_growing"
	density = 0
	anchored = 1

	var/health = 100
	var/status = GROWING //can be GROWING, GROWN or BURST; all mutually exclusive
	var/used = 0

/obj/effect/alien/egg/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, .proc/Grow), rand(MIN_GROWTH_TIME,MAX_GROWTH_TIME))

/obj/effect/alien/egg/attack_paw(mob/user)
	if(isalien(user))
		switch(status)
			if(GROWING)
				to_chat(user, "\red The child is not developed yet.")
				return
			if(BURST)
				to_chat(user, "You clear the hatched egg.")
				user.SetNextMove(CLICK_CD_MELEE)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
				qdel(src)
				return
	else
		return attack_hand(user)

/obj/effect/alien/egg/attack_hand(mob/user)
	to_chat(user, "It feels slimy.")
	user.SetNextMove(CLICK_CD_MELEE)

/obj/effect/alien/egg/proc/Grow()
	icon_state = "egg"
	status = GROWN
	new /obj/item/clothing/mask/facehugger(src)

/obj/effect/alien/egg/proc/Burst()
	if(status == GROWN || status == GROWING)
		icon_state = "egg_hatched"
		flick("egg_opening", src)
		status = BURSTING
		spawn(15)
			status = BURST

/obj/effect/alien/egg/attack_ghost(mob/living/user)
	if(!(src in view()))
		to_chat(user, "Your soul is too far away.")
		return
	if(used)
		to_chat(user, "Someone else used that egg.")
		return
	switch(status)
		if(GROWING)
			to_chat(user, "\red The child is not developed yet.")
			return
		if(GROWN)
			used = 1
			var/mob/living/carbon/alien/facehugger/FH = new /mob/living/carbon/alien/facehugger(get_turf(src))
			FH.key = user.key
			to_chat(FH, "\green You are now a facehugger, go hug some human faces <3")
			icon_state = "egg_hatched"
			flick("egg_opening", src)
			status = BURSTING
			spawn(15)
				status = BURST

/obj/effect/alien/egg/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/effect/alien/egg/process()
	if(prob(10))
		var/turf/T = get_turf(src);
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment.return_pressure()
		if(pressure < WARNING_LOW_PRESSURE)
			if(prob(25))
				audible_message("<span class='warning'>\The [src] is cracking!</span>")
			health -= 5
			healthcheck()

/obj/effect/alien/egg/attackby(obj/item/weapon/W, mob/user)
	if(health <= 0)
		return
	if(W.attack_verb.len)
		src.visible_message("\red <B>\The [src] has been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]")
	else
		src.visible_message("\red <B>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")
	var/damage = W.force / 4.0
	user.SetNextMove(CLICK_CD_MELEE)

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

	src.health -= damage
	src.healthcheck()


/obj/effect/alien/egg/proc/healthcheck()
	if(health <= 0)
		Burst()

/obj/effect/alien/egg/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()

#undef WEED_SOUTH_EDGING
#undef WEED_NORTH_EDGING
#undef WEED_WEST_EDGING
#undef WEED_EAST_EDGING
