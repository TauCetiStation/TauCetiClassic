/obj/structure/snow
	name = "snow"
	desc = "It's just a pile of snow."
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
	if(istype(W, /obj/item/weapon/shovel))
		if(user.is_busy())
			return
		visible_message("<span class='notice'>[user] starts digging \the [src] with \the [W].</span>")
		if(do_after(user, 30, target = src))
			for(var/i = 0 to 4)
				new /obj/item/snowball(get_turf(src))
			health -= 5
			health_check()
	else
		return

/obj/structure/snow/attack_hand(mob/user)
	if(user.is_busy())
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
		check_overlay()
		for(var/obj/structure/snow/O in range(1, src))
			O.check_overlay()
		qdel(src)

/obj/structure/snow/proc/check_overlay()
	overlays.Cut()
	for(var/direction_to_check in cardinal)
		if(!istype(get_step(src, direction_to_check), /turf/space) && !istype(get_step(src, direction_to_check), /turf/simulated/wall) && !istype(get_step(src, direction_to_check), /obj/structure/snow))
			var/image/snow_side = image('icons/turf/snow.dmi', "[direction_to_check]")
			snow_side.layer = LOW_OBJ_LAYER
			switch(direction_to_check)
				if(1)
					snow_side.pixel_y += 32
				if(2)
					snow_side.pixel_y += -32
				if(4)
					snow_side.pixel_x += 32
				if(8)
					snow_side.pixel_x += -32
			overlays += snow_side

/obj/item/snowball
	name = "snowball"
	desc = "Get ready for a snowball fight!"
	force = 0
	throwforce = 10
	icon_state = "snowball"

/obj/item/snowball/throw_impact(atom/target)
	..()
	qdel(src)

/obj/item/snowball/fire_act()
	qdel(src)

/obj/item/snowball/ex_act(severity)
	qdel(src)
