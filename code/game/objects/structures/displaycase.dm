/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for prized possessions. It taunts you to kick it."
	density = TRUE
	anchored = TRUE
	unacidable = 1//Dissolving the case would also delete the gun.
	max_integrity = 60
	integrity_failure = 0.5
	var/occupied = 1
	var/destroyed = 0

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassboxb[src.occupied]"
	else
		src.icon_state = "glassbox[src.occupied]"
	return

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glasshit.ogg', VOL_EFFECTS_MASTER, 75, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/displaycase/atom_break()
	..()
	if(destroyed || flags & NODECONSTRUCT)
		return
	density = FALSE
	destroyed = TRUE
	new /obj/item/weapon/shard(loc)
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	update_icon()

/obj/structure/displaycase/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	if(occupied)
		new /obj/item/weapon/gun/energy/laser/selfcharging/captain(loc)
		occupied = FALSE
	if(!destroyed)
		new /obj/item/weapon/shard(loc)
	..()

/obj/structure/displaycase/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user)
	if(destroyed && occupied)
		new /obj/item/weapon/gun/energy/laser/selfcharging/captain(loc)
		occupied = FALSE
		to_chat(user, "<b>You deactivate the hover field built into the case.</b>")
		add_fingerprint(user)
		update_icon()
		return
	user.SetNextMove(CLICK_CD_MELEE)
	visible_message("<span class='userdanger'>[user] kicks the display case.</span>")
	take_damage(2, BRUTE, MELEE)


