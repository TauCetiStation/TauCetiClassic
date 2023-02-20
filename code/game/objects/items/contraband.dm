//Let's get some REAL contraband stuff in here. Because come on, getting brigged for LIPSTICK is no fun.

//Illicit drugs~
/obj/item/weapon/storage/pill_bottle/happy
	name = "Happy pills"
	desc = "Highly illegal drug. When you want to see the rainbow."

/obj/item/weapon/storage/pill_bottle/happy/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/happy(src)

/obj/item/weapon/storage/pill_bottle/zoom
	name = "Zoom pills"
	desc = "Highly illegal drug. Trade brain for speed."

/obj/item/weapon/storage/pill_bottle/zoom/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/zoom(src)


/obj/item/weapon/methamphetamine_shard //I have no idea where to put it
	name = "Methamphetamine shard"
	desc = "A piece of crystal clear methamphetamine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "methshard"
	force = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = SIZE_MINUSCULE

/obj/item/weapon/methamphetamine_shard/attack_self(mob/user)
	. = ..()
	var/mob/living/M = user
	if(!CanEat(user, M, src, "sniff"))
		return

	to_chat(M, "<span class='notice'>You're trying to use methamphetamine...</span>")
	if(do_after(M, 50, can_move = FALSE))
		visible_message("<span class='warning'>[M.name] crushes a piece of meth and inhales it.</span>")
		M.reagents.add_reagent("methamphetamine", 15)
		M.emote("woo")
		qdel(src)
	else
		return

/obj/item/weapon/methamphetamine_shard/after_throw(datum/callback/callback)
	..()
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	new /obj/effect/decal/cleanable/ash/meth(loc)
	qdel(src)
