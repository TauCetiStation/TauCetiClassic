//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	var/health = 100
	layer = 2.55

/obj/structure/stool/bed/nest/user_unbuckle_mob(mob/user)
	if(buckled_mob)
		if(user.is_busy())
			return

		if(buckled_mob.buckled == src)
			if(buckled_mob != user)
				buckled_mob.visible_message(\
					"<span class='notice'>[user.name] pulls [buckled_mob.name] free from the sticky nest!</span>",\
					"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
					"<span class='notice'>You hear squelching...</span>")
				buckled_mob.pixel_y = 0
				unbuckle_mob()
			else
				if(user.is_busy()) return
				buckled_mob.visible_message(\
					"<span class='warning'>[buckled_mob.name] struggles to break free of the gelatinous resin...</span>",\
					"<span class='warning'>You struggle to break free from the gelatinous resin...</span>",\
					"<span class='notice'>You hear squelching...</span>")
				if(do_after(buckled_mob, 3000, target = user))
					if(user && buckled_mob && user.buckled == src)
						buckled_mob.pixel_y = 0
						unbuckle_mob()
			add_fingerprint(user)
	return

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
	if(can_user_buckle(M, user) && buckle_mob(M))
		M.visible_message(\
			"<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into [src]!</span>",\
			"<span class='warning'>[user.name] drenches you in a foul-smelling resin, trapping you in the [src]!</span>",\
			"<span class='notice'>You hear squelching...</span>")
		M.pixel_y = 2
		return TRUE
	return FALSE

/obj/structure/stool/bed/nest/attackby(obj/item/weapon/W, mob/user)
	var/aforce = W.force
	health = max(0, health - aforce)
	user.SetNextMove(CLICK_CD_MELEE)
	playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
	visible_message("<span class='warning'>[user] hits [src] with [W]!</span>")
	healthcheck()

/obj/structure/stool/bed/nest/proc/healthcheck()
	if(health <=0)
		density = FALSE
		qdel(src)
	return
