/obj/structure/stool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	anchored = 1.0
	flags = FPRINT
	pressure_resistance = 15

/obj/structure/stool/bar
	name = "bar stool"
	icon = 'tauceti/icons/obj/objects.dmi'
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
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)

/obj/structure/stool/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(src.loc)
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
			new /obj/item/stack/sheet/metal(src.loc)
			qdel(src)
	return

/obj/structure/stool/MouseDrop(atom/over_object)
	if (istype(over_object, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = over_object
		if (H==usr && !H.restrained() && !H.stat && in_range(src, over_object))
			var/obj/item/weapon/stool/S = new/obj/item/weapon/stool()
			S.origin = src
			src.loc = S
			H.put_in_hands(S)
			H.visible_message("\red [H] grabs [src] from the floor!", "\red You grab [src] from the floor!")

/obj/item/weapon/stool
	name = "stool"
	desc = "Uh-hoh, bar is heating up."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	force = 10
	throwforce = 10
	w_class = 5.0
	var/obj/structure/stool/origin = null

/obj/item/weapon/stool/attack_self(mob/user as mob)
	..()
	if(!user) return
	user.drop_from_inventory(src.origin)
	user.visible_message("[user] puts [src] down.", "<span class='notice'>You put [src] down.</span>")
	qdel(src)

/obj/item/weapon/stool/dropped()
	attack_self(usr)

/obj/item/weapon/stool/attack(mob/M as mob, mob/user as mob)
	if (prob(5) && istype(M,/mob/living))
		user.visible_message("\red [user] breaks [src] over [M]'s back!.")
		user.remove_from_mob(src)
		var/obj/item/stack/sheet/metal/m = new/obj/item/stack/sheet/metal
		m.loc = get_turf(src)
		qdel( src)
		var/mob/living/T = M
		T.Weaken(10)
		T.apply_damage(20)
		return
	..()
