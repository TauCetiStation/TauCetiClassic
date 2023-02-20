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


/obj/item/weapon/crystallephrine_shard //I have no idea where to put it
	name = "crystallephrine shard"
	desc = "A piece of crystal clear crystallephrine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "crystshard"
	force = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = SIZE_MINUSCULE

/obj/item/weapon/crystallephrine_shard/attack_self(mob/user)
	. = ..()
	var/mob/living/M = user
	if(!CanEat(user, M, src, "sniff"))
		return

	to_chat(M, "<span class='notice'>You're trying to use crystallephrine...</span>")
	if(do_after(M, 50, can_move = FALSE))
		visible_message("<span class='warning'>[M.name] crushes a piece of crystallephrine and inhales it.</span>")
		M.reagents.add_reagent("crystallephrine", 15)
		M.emote("woo")
		qdel(src)
	else
		return

/obj/item/weapon/crystallephrine_shard/after_throw(datum/callback/callback)
	..()
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	new /obj/effect/decal/cleanable/ash/cryst(loc)
	qdel(src)
