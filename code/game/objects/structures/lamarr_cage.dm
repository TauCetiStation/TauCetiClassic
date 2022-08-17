/obj/structure/lamarr // TODO, refactor into displaycase
	name = "Lab Cage"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = TRUE
	anchored = TRUE
	unacidable = 1//Dissolving the case would also delete Lamarr
	max_integrity = 100
	integrity_failure = 0.7
	var/occupied = 1
	var/destroyed = 0

/obj/structure/lamarr/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE, BURN)
			playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)

/obj/structure/lamarr/atom_break(damage_flag)
	..()
	if(flags & NODECONSTRUCT || destroyed)
		return
	density = FALSE
	destroyed = TRUE
	new /obj/item/weapon/shard( src.loc )
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	Break()

/obj/structure/lamarr/update_icon()
	if(src.destroyed)
		src.icon_state = "labcageb[src.occupied]"
	else
		src.icon_state = "labcage[src.occupied]"
	return

/obj/structure/lamarr/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/lamarr/attack_hand(mob/user)
	if (src.destroyed)
		return
	else
		user.SetNextMove(CLICK_CD_MELEE)
		visible_message("<span class='userdanger'>[user] kicks the lab cage.</span>")
		take_damage(2, BRUTE, MELEE)
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
