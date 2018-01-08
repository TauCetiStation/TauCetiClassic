/obj/structure/stool
	name = "bar stool"
	icon = 'icons/obj/objects.dmi'
	icon_state = "bar_chair"

/obj/structure/stool/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
	return

/obj/structure/stool/blob_act()
	if(prob(75))
		new /obj/item/stack/sheet/metal(loc)
		qdel(src)

/obj/structure/stool/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(loc)
		qdel(src)
	if(istype(W, /obj/item/weapon/melee/energy))
		if(istype(W, /obj/item/weapon/melee/energy/blade) || W:active)
			user.do_attack_animation(src)
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(src.loc, "sparks", 50, 1)
			for(var/mob/O in viewers(user, 4))
				O.show_message("\blue [src] was sliced apart by [user]!", 1, "\red You hear [src] coming apart.", 2)
			if(!(flags&NODECONSTRUCT))
				new /obj/item/stack/sheet/metal(loc)
			qdel(src)
	return