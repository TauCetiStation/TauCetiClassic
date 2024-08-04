//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	layer = 2.55
	flags = NODECONSTRUCT
	material = null

/obj/structure/stool/bed/nest/user_unbuckle_mob(mob/user)
	if(!buckled_mob || user.is_busy())
		return
	var/mob/living/L = buckled_mob
	add_fingerprint(user)
	if(L != user)
		L.visible_message(
			"<span class='notice'>[user.name] pulls [L.name] free from the sticky nest!</span>",
			"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",
			"<span class='notice'>You hear squelching...</span>")

	else
		L.visible_message(
			"<span class='warning'>[L.name] struggles to break free of the gelatinous resin...</span>",
			"<span class='warning'>You struggle to break free from the gelatinous resin...</span>",
			"<span class='notice'>You hear squelching...</span>")

		if(!(do_after(L, 3 MINUTES, target = L) && buckled_mob == L))
			return

	L.pixel_y = L.default_pixel_y
	unbuckle_mob()
	to_chat(L, "<span class='notice'>You successfly break free from the nest!</span>")
	L.visible_message(
			"<span class='warning'>[L.name] break free from the nest...</span>",)

/obj/structure/stool/bed/nest/can_user_buckle(mob/living/M, mob/user)
	if(isxeno(M) || !isxenoadult(user))
		return FALSE
	if(!user.Adjacent(M) || user.incapacitated() || user.lying)
		return FALSE
	if(user.is_busy())
		to_chat(user, "<span class='warning'>You can't buckle [M] while doing something.</span>")
		return FALSE
	return TRUE

/obj/structure/stool/bed/nest/user_buckle_mob(mob/M, mob/user)
	if(!(can_user_buckle(M, user) && buckle_mob(M)))
		return FALSE
	M.visible_message(
		"<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into [src]!</span>",
		"<span class='warning'>[user.name] drenches you in a foul-smelling resin, trapping you in the [src]!</span>",
		"<span class='notice'>You hear squelching...</span>")
	M.pixel_y = 2
	return TRUE

/obj/structure/stool/bed/nest/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/bed/nest/post_buckle_mob(mob/living/buckling_mob)
	. = ..()
	buckling_mob.reagents.add_reagent("xenojelly_n", 30)
