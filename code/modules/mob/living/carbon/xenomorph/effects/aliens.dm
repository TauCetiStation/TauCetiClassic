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

/obj/structure/alien
	name = "alien thing"
	desc = "theres something alien about this."
	icon = 'icons/mob/xenomorph.dmi'
//	unacidable = 1 //Aliens won't ment their own.


/*
 * Resin
 */
/obj/structure/alien/resin
	name = "resin"
	desc = "Looks like some kind of thick resin."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "box"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	layer = 3.14
	canSmoothWith = list(/obj/structure/alien/resin)
	smooth = SMOOTH_TRUE

	var/health = 250
	var/resintype = null

/obj/structure/alien/resin/wall
	name = "resin wall"
	desc = "Thick resin solidified into a wall."
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	resintype = "wall"
	canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/obj/structure/alien/resin/membrane
	name = "resin membrane"
	desc = "Resin just thin enough to let light pass through."
	icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi'
	opacity = FALSE
	health = 160
	resintype = "membrane"
	canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/obj/structure/alien/resin/wall/shadowling // maybe remove this type and make spawning normal wall while setting its hp?
	name = "chrysalis wall"
	desc = "Some sort of resin substance in an egglike shape. It pulses and throbs from within and seems impenetrable."
	health = INFINITY
	canSmoothWith = null // smooths with itself

/obj/structure/alien/resin/atom_init()
	. = ..()
	var/turf/T = get_turf(src)
	T.thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

/obj/structure/alien/resin/Destroy()
	var/turf/T = get_turf(src)
	T.thermal_conductivity = initial(T.thermal_conductivity)
	return ..()

/obj/structure/alien/resin/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/structure/alien/air_plant/bullet_act(obj/item/projectile/Proj)
	. = ..()
	if(. == PROJECTILE_ABSORBED || . == PROJECTILE_FORCE_MISS)
		return
	health -= Proj.damage
	healthcheck()

/obj/structure/alien/resin/ex_act(severity)
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

/obj/structure/alien/resin/blob_act()
	health-=50
	healthcheck()
	return

/obj/structure/alien/resin/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	..()
	visible_message("<span class='warning'><B>[src] was hit by [AM].</B></span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
	health = max(0, health - tforce)
	healthcheck()
	..()
	return

/obj/structure/alien/resin/attack_hand(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	if (HULK in user.mutations)
		user.visible_message("<span class='warning'>[user] destroys the [name]!</span>", self_message = "<span class='notice'>You easily destroy the [name].</span>")
		health = 0
	else
		user.visible_message("<span class='warning'>[user] claws at the [name]!</span>", self_message = "<span class='notice'>You claw at the [name].</span>")
		health -= rand(5,10)
	healthcheck()
	return

/obj/structure/alien/resin/attack_paw()
	return attack_hand()

/obj/structure/alien/resin/attack_alien(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	if (isxenolarva(usr) || isfacehugger(usr))//Safety check for larva. /N
		return
	user.visible_message("<span class='warning'>[usr] claws at the resin!</span>", self_message = "<span class='notice'>You claw at the [name].</span>")
	playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
	health -= rand(40, 60)
	if(health <= 0)
		user.visible_message("<span class='warning'>[usr] slices the [name] apart!</span>", self_message = "<span class='notice'>You slice the [name] to pieces.</span>")
	healthcheck()
	return

/obj/structure/alien/resin/attackby(obj/item/weapon/W, mob/user)
	var/aforce = W.force
	user.SetNextMove(CLICK_CD_MELEE)
	health = max(0, health - aforce)
	playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
	healthcheck()
	..()
	return

/obj/structure/alien/resin/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density


/*
 * Weeds
 */
/obj/structure/alien/weeds
	name = "resin floor"
	desc = "A thick resin surface covers the floor."
	icon = 'icons/mob/xenomorph.dmi'
	icon_state = "weeds"
	anchored = TRUE
	density = FALSE
	layer = 2.5
	plane = FLOOR_PLANE
	canSmoothWith = list(/obj/structure/alien/weeds, /turf/simulated/wall)
	smooth = SMOOTH_MORE

	var/health = 15
	var/obj/structure/alien/weeds/node/linked_node = null

/obj/structure/alien/weeds/atom_init(mapload, node)
	if(istype(loc, /turf/space))
		return INITIALIZE_HINT_QDEL

	if(icon == initial(icon))
		switch(rand(1, 3))
			if(1)
				icon = 'icons/obj/smooth_structures/alien/weeds1.dmi'
			if(2)
				icon = 'icons/obj/smooth_structures/alien/weeds2.dmi'
			if(3)
				icon = 'icons/obj/smooth_structures/alien/weeds3.dmi'
	pixel_x = -4
	pixel_y = -4 //so the sprites line up right in the map editor

	..()

	linked_node = node
	return INITIALIZE_HINT_LATELOAD

/obj/structure/alien/weeds/atom_init_late()
	addtimer(CALLBACK(src, .proc/Life), rand(150, 200))

/obj/structure/alien/weeds/Destroy()
	linked_node = null
	return ..()

/obj/structure/alien/weeds/proc/Life()
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
		visible_message("<span class='danger'>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='danger'>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]</span>")

	var/damage = W.force / 4.0
	user.SetNextMove(CLICK_CD_MELEE)

	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.use(0, user))
			damage = 15
			playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)

	health -= damage
	healthcheck()


/obj/structure/alien/weeds/temperature_expose(null, temperature, volume)
	if(temperature > T0C+200)
		health -= 1 * temperature
		healthcheck()

/obj/structure/alien/weeds/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/structure/alien/weeds/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/obj/structure/alien/weeds/bullet_act(obj/item/projectile/Proj)
	return PROJECTILE_FORCE_MISS

/*/obj/structure/alien/weeds/burn(fi_amount)
	if (fi_amount > 18000)
		spawn( 0 )
			qdel(src)
			return
		return 0
	return 1
*/

/obj/structure/alien/weeds/node
	icon_state = "weednode"
	name = "glowing resin"
	desc = "Blue bioluminescence shines from beneath the surface."
	layer = 2.5
	light_range = 0
	light_color = "#24c1ff"

	var/node_range = 3

/obj/structure/alien/weeds/node/atom_init(mapload)
	icon = 'icons/obj/smooth_structures/alien/weednode.dmi'
	. = ..(mapload, src)

/obj/structure/alien/weeds/node/atom_init_late()
	for (var/obj/structure/alien/weeds/W in loc)
		if (W != src)
			qdel(W)
	set_light(2)
	..()

/*
 * Acid
 */
/obj/effect/alien/acid
	name = "acid"
	desc = "Burbling corrossive stuff. I wouldn't want to touch it."
	icon = 'icons/mob/xenomorph.dmi'
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

		audible_message("<span class='notice'><B>[src.target] collapses under its own weight into a puddle of goop and undigested debris!</B></span>")

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
			visible_message("<span class='notice'><B>[src.target] is holding up against the acid!</B></span>")
		if(4)
			visible_message("<span class='notice'><B>[src.target]\s structure is being melted by the acid!</B></span>")
		if(2)
			visible_message("<span class='notice'><B>[src.target] is struggling to withstand the acid!</B></span>")
		if(0 to 1)
			visible_message("<span class='notice'><B>[src.target] begins to crumble under the acid!</B></span>")
	spawn(rand(150, 200)) tick()

/*
 * Egg
 */
// egg's status
#define BURST      0
#define BURSTING   1
#define GROWING    2
#define GROWN      3
// time it takes to grow a hugger
#define MIN_GROWTH_TIME 1800
#define MAX_GROWTH_TIME 3000

/obj/structure/alien/egg
	desc = "It looks like a weird egg."
	name = "egg"
	icon_state = "egg_growing"
	density = FALSE
	anchored = TRUE

	var/health = 100
	var/status = GROWING //can be GROWING, GROWN or BURST; all mutually exclusive

/obj/structure/alien/egg/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, .proc/Grow), rand(MIN_GROWTH_TIME, MAX_GROWTH_TIME))

/obj/structure/alien/egg/attack_paw(mob/user)
	if(isxeno(user))
		switch(status)
			if(GROWN)
				to_chat(user, "<span class='notice'>You retrieve the child.</span>")
				Burst(FALSE)
				return
			if(BURST)
				user.visible_message("[user] clears the hatched egg.", "You clear the hatched egg.")
				user.SetNextMove(CLICK_CD_MELEE)
				playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
				qdel(src)
				return
			if(GROWING)
				to_chat(user, "<span class='warning'>The facehugger hasn't grown yet.</span>")
				return
	else
		return attack_hand(user)

/obj/structure/alien/egg/attack_hand(mob/user)
	to_chat(user, "It feels slimy.")
	user.SetNextMove(CLICK_CD_MELEE)

/obj/structure/alien/egg/proc/Grow()
	icon_state = "egg"
	status = GROWN
	new /obj/item/clothing/mask/facehugger(src)

/obj/structure/alien/egg/proc/Burst(kill_fh = TRUE)
	STOP_PROCESSING(SSobj, src)
	if(status == GROWN || status == GROWING)
		icon_state = "egg_hatched"
		flick("egg_opening", src)
		status = BURSTING
		spawn(15)
			status = BURST
			var/obj/item/clothing/mask/facehugger/FH = new /obj/item/clothing/mask/facehugger(get_turf(src))
			if(kill_fh)
				FH.Die()


/obj/structure/alien/egg/attack_ghost(mob/living/user)
	if(facehuggers_control_type != FACEHUGGERS_PLAYABLE)
		to_chat(user, "<span class='notice'>You can't control the facehugger! This feature is disabled by the administrator, you can ask him to enable this feature.</span>")
		return
	if(!(src in view()))
		to_chat(user, "Your soul is too far away.")
		return
	switch(status)
		if(BURST, BURSTING)
			to_chat(user, "<span class='warning'>Someone else used that egg.</span>")
			return
		if(GROWING)
			to_chat(user, "<span class='warning'>The facehugger hasn't grown yet.</span>")
			return
		if(GROWN)
			var/mob/living/carbon/xenomorph/facehugger/FH = new /mob/living/carbon/xenomorph/facehugger(get_turf(src))
			FH.key = user.key
			to_chat(FH, "<span class='notice'>You are now a facehugger, go hug some human faces <3</span>")
			icon_state = "egg_hatched"
			flick("egg_opening", src)
			status = BURSTING
			spawn(15)
				status = BURST

/obj/structure/alien/air_plant/bullet_act(obj/item/projectile/Proj)
	. = ..()
	if(. == PROJECTILE_ABSORBED || . == PROJECTILE_FORCE_MISS)
		return
	health -= Proj.damage
	healthcheck()

/obj/structure/alien/egg/process()
	if(prob(10))
		var/turf/T = get_turf(src);
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment.return_pressure()
		if(pressure < WARNING_LOW_PRESSURE)
			if(prob(25))
				audible_message("<span class='warning'>\The [src] is cracking!</span>")
			health -= 5
			healthcheck()

/obj/structure/alien/egg/attackby(obj/item/weapon/W, mob/user)
	if(health <= 0)
		return
	if(W.attack_verb.len)
		src.visible_message("<span class='danger'>\The [src] has been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		src.visible_message("<span class='danger'>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]</span>")
	var/damage = W.force / 4.0
	user.SetNextMove(CLICK_CD_MELEE)

	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.use(0, user))
			damage = 15
			playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)

	src.health -= damage
	src.healthcheck()


/obj/structure/alien/egg/proc/healthcheck()
	if(health <= 0)
		Burst()

/obj/structure/alien/egg/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()

#undef BURST
#undef BURSTING
#undef GROWING
#undef GROWN

/*
 * Air generator
 */
/obj/structure/alien/air_plant
	name = "strange plant"
	desc = "Air restoring plant. Progressive aliens technologies..."
	icon_state = "air_plant"

	density = FALSE
	anchored = TRUE

	var/health = 15
	var/restoring_moles = MOLES_CELLSTANDARD/4

/obj/structure/alien/air_plant/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	set_light(2, 1, "#24c1ff")

/obj/structure/alien/air_plant/process()
	if(prob(25))
		var/turf/T = get_turf(src)

		if(istype(T, /turf/space) || istype(T, /turf/unsimulated))
			qdel(src)

		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment.return_pressure()

		//So aliens can detect dangerous pressure level for eggs
		if(pressure < WARNING_LOW_PRESSURE)
			if(light_color != "#ff6224")
				set_light(2, 1, "#ff6224")
		else if(light_color != "#24c1ff")
			set_light(2, 1, "#24c1ff")

		//actually restoring air
		if(pressure < (ONE_ATMOSPHERE*0.90))//it's pretty sloppy, but never mind
			environment.adjust_multi_temp("oxygen", restoring_moles*O2STANDARD, T20C, "nitrogen", restoring_moles*N2STANDARD, T20C)

/obj/structure/alien/air_plant/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/structure/alien/air_plant/attackby(obj/item/weapon/W, mob/user)
	var/aforce = W.force
	user.SetNextMove(CLICK_CD_MELEE)
	health = max(0, health - aforce)
	playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
	healthcheck()
	..()
	return

/obj/structure/alien/air_plant/bullet_act(obj/item/projectile/Proj)
	. = ..()
	if(. == PROJECTILE_ABSORBED || . == PROJECTILE_FORCE_MISS)
		return
	health -= Proj.damage
	healthcheck()

/obj/structure/alien/air_plant/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()

#undef WEED_SOUTH_EDGING
#undef WEED_NORTH_EDGING
#undef WEED_WEST_EDGING
#undef WEED_EAST_EDGING
