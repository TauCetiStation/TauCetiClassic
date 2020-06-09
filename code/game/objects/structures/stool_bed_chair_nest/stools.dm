/obj/structure/stool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	anchored = 1.0

/obj/structure/stool/bar
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
	if(iswrench(W) && !(flags & NODECONSTRUCT))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		new /obj/item/stack/sheet/metal(loc)
		qdel(src)
		return
	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/obj/item/weapon/melee/energy/blade/B = W
		if(B.active)
			user.do_attack_animation(src)
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			visible_message("<span class='notice'>[src] was sliced apart by [user]!</span>", "<span class='notice'>You hear [src] coming apart.</span>")
			if(!(flags & NODECONSTRUCT))
				new /obj/item/stack/sheet/metal(loc)
			qdel(src)
			return

	else if(istype(W, /obj/item/weapon/twohanded/sledgehammer))
		var/obj/item/weapon/twohanded/sledgehammer/S = W
		if(S.wielded && !(flags & NODECONSTRUCT))
			new /obj/item/stack/sheet/metal(loc)
			playsound(user, 'sound/items/sledgehammer_hit.ogg', VOL_EFFECTS_MASTER)
			shake_camera(user, 1, 1)
			qdel(src)
			return
	else
		..()

/obj/structure/stool/MouseDrop(atom/over_object)
	if(ishuman(over_object) && type == /obj/structure/stool)
		var/mob/living/carbon/human/H = over_object
		if(H == usr && !H.restrained() && !H.stat && in_range(src, over_object))
			var/obj/item/weapon/stool/S = new
			S.origin_stool = src
			src.loc = S
			H.put_in_hands(S)
			H.visible_message("<span class='red'>[H] grabs [src] from the floor!</span>", "<span class='red'>You grab [src] from the floor!</span>")
			return
	return ..()

/obj/item/weapon/stool
	name = "stool"
	desc = "Uh-hoh, bar is heating up."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	force = 10
	hitsound = list('sound/items/chair_fall.ogg')
	throwforce = 10
	w_class = ITEM_SIZE_HUGE
	var/obj/structure/stool/origin_stool = null

/obj/item/weapon/stool/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback)
	return

/obj/item/weapon/stool/atom_init()
	. = ..()
	flags |= DROPDEL

/obj/item/weapon/stool/Destroy()
	if(origin_stool)
		qdel(origin_stool)
		origin_stool = null
	return ..()

/obj/item/weapon/stool/attack_self(mob/user)
	user.drop_from_inventory(src)
	user.visible_message("<span class='notice'>[user] dropped [src].</span>", "<span class='notice'>You dropped [src].</span>")

/obj/item/weapon/stool/dropped(mob/user)
	if(origin_stool)
		origin_stool.loc = src.loc
		origin_stool = null
	..()

/obj/item/weapon/stool/attack(mob/M, mob/user)
	if (prob(5) && isliving(M))
		user.visible_message("<span class='red'>[user] breaks [src] over [M]'s back!</span>")
		new /obj/item/stack/sheet/metal(get_turf(src))
		qdel(src)
		var/mob/living/T = M
		T.Weaken(10)
		T.apply_damage(20)
		return
	..()
