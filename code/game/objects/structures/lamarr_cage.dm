/obj/structure/lamarr
	name = "Lab Cage"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete Lamarr
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/lamarr/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			Break()
			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/lamarr/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/lamarr/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		Break()
		qdel(src)


/obj/structure/lamarr/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
			Break()
	else
		playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
	return

/obj/structure/lamarr/update_icon()
	if(src.destroyed)
		src.icon_state = "labcageb[src.occupied]"
	else
		src.icon_state = "labcage[src.occupied]"
	return


/obj/structure/lamarr/attackby(obj/item/weapon/W, mob/user)
	src.health -= W.force
	src.healthcheck()
	..()

/obj/structure/lamarr/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/lamarr/attack_hand(mob/user)
	if (src.destroyed)
		return
	else
		user.SetNextMove(CLICK_CD_MELEE)
		visible_message("<span class='userdanger'>[user] kicks the lab cage.</span>")
		src.health -= 2
		healthcheck()
		return

/obj/structure/lamarr/proc/Break()
	if(occupied)
		new /obj/item/clothing/mask/facehugger/lamarr(src.loc)
		occupied = 0
	update_icon()
	return

/obj/item/clothing/mask/facehugger/lamarr
	name = "Lamarr"
	desc = "The worst she might do is attempt to... couple with your head."//hope we don't get sued over a harmless reference, rite?
	sterile = 1
	gender = FEMALE

/obj/item/clothing/mask/facehugger/lamarr/atom_init_late()//to prevent deleting it if aliums are disabled
	return
