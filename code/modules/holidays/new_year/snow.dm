/obj/structure/snow
	name = "snow"
	desc = "It's just a pile of snow..."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	anchored = TRUE
	density = FALSE
	var/health = 50
	layer = LOW_OBJ_LAYER

/obj/structure/snow/atom_init()
	. = ..()
	check_overlay()
	for(var/obj/structure/snow/O in range(1, src))
		O.check_overlay()

/obj/structure/snow/attackby(obj/item/W, mob/user)
	if(user.is_busy())
		return
	if(istype(W, /obj/item/weapon/shovel) && !user.is_busy(src))
		visible_message("<span class='notice'>[user] starts digging \the [src] with \the [W].</span>")
		if(W.use_tool(src, user, 30, volume = 50))
			for(var/i = 0 to 4)
				new /obj/item/snowball(get_turf(src))
			health -= 5
			health_check()
	return

/obj/structure/snow/attack_hand(mob/user)
	if(user.is_busy(src))
		return
	visible_message("<span class='notice'>[user] starts digging \the [src] by his hand.</span>")
	if(do_after(user, 10, target = src))
		new /obj/item/snowball(get_turf(src))
		health -= 2
		health_check()
	return

/obj/structure/snow/proc/health_check()
	if(health <= 0)
		visible_message("<span class='notice'>[src] is cleared.</span>")
		for(var/obj/structure/snow/O in range(1, src))
			O.check_overlay()
		qdel(src)

/obj/structure/snow/proc/check_overlay()
	cut_overlays()
	for(var/direction_to_check in cardinal)
		if(!istype(get_step(src, direction_to_check), /turf/space) && !istype(get_step(src, direction_to_check), /turf/simulated/wall) && !istype(get_step(src, direction_to_check), /obj/structure/snow))
			var/image/snow_side = image('icons/turf/snow.dmi', "[direction_to_check]")
			snow_side.layer = LOW_OBJ_LAYER
			switch(direction_to_check)
				if(NORTH)
					snow_side.pixel_y += 32
				if(SOUTH)
					snow_side.pixel_y += -32
				if(EAST)
					snow_side.pixel_x += 32
				if(WEST)
					snow_side.pixel_x += -32
			add_overlay(snow_side)

/obj/item/snowball
	name = "snowball"
	desc = "Get ready for a snowball fight!"
	force = 0
	throwforce = 1
	icon_state = "snowball"

/obj/item/snowball/attack_hand(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()

/obj/item/snowball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	qdel(src)

/obj/item/snowball/fire_act()
	qdel(src)

/obj/item/snowball/ex_act(severity)
	qdel(src)
