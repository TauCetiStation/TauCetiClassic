/* Weapons
 * Contains:
 *		Banhammer
 *		Sword
 *		Classic Baton
 *		Energy Blade
 *		Energy Axe
 *		Energy Shield
 */

/*
 * Banhammer
 */
/obj/item/weapon/banhammer/attack(mob/M, mob/user)
	to_chat(M, "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>")
	to_chat(user, "<font color='red'> You have <b>BANNED</b> [M]</font>")
	M.playsound_local(M, 'sound/effects/adminhelp.ogg', 50, 0)

/*
 * Sword
 */
/obj/item/weapon/melee/energy/sword/Get_shield_chance()
	if(active)
		return 40
	return 0

/obj/item/weapon/melee/energy/add_blood()
	return

/obj/item/weapon/melee/energy/sword/atom_init()
	. = ..()
	item_color = pick("red","blue","green","purple","yellow","pink","black")

/obj/item/weapon/melee/energy/sword/attack_self(mob/living/user)
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "\red You accidentally cut yourself with [src].")
		user.take_bodypart_damage(5, 5)
	active = !active
	if (active)
		force = 30
		hitsound = 'sound/weapons/blade1.ogg'
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass1"
		else
			icon_state = "sword[item_color]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		to_chat(user, "\blue [src] is now active.")

	else
		force = 3
		hitsound = initial(hitsound)
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass0"
		else
			icon_state = "sword0"
		w_class = 2
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		to_chat(user, "\blue [src] can now be concealed.")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

	add_fingerprint(user)
	return


/*
 * Classic Baton
 */
/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_FLAGS_BELT
	force = 10

/obj/item/weapon/melee/classic_baton/attack(mob/M, mob/living/user)
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "\red You club yourself over the head.")
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2 * force, BRUTE, BP_HEAD)
		else
			user.take_bodypart_damage(2 * force)
		return
/*this is already called in ..()
	src.add_fingerprint(user)
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
*/
	if (user.a_intent == "hurt")
		if(!..()) return
		playsound(src.loc, "swing_hit", 50, 1, -1)
		if (M.stuttering < 8 && (!(HULK in M.mutations))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.stuttering = 8
		M.Stun(8)
		M.Weaken(8)
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been beaten with \the [src] by [user]!</B>", 1, "\red You hear someone fall", 2)
	else
		playsound(src.loc, 'sound/weapons/Genhit.ogg', 50, 1, -1)
		M.Stun(5)
		M.Weaken(5)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
		msg_admin_attack("[key_name(user)] attacked [key_name(user)] with [src.name] (INTENT: [uppertext(user.a_intent)])")
		src.add_fingerprint(user)

		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been stunned with \the [src] by [user]!</B>", 1, "\red You hear someone fall", 2)

//Telescopic baton
/obj/item/weapon/melee/telebaton
	name = "telescopic baton"
	desc = "A compact yet rebalanced personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = null
	slot_flags = SLOT_FLAGS_BELT
	w_class = 2
	force = 3
	var/on = 0


/obj/item/weapon/melee/telebaton/attack_self(mob/user)
	on = !on
	if(on)
		user.visible_message("\red With a flick of their wrist, [user] extends their telescopic baton.",\
		"\red You extend the baton.",\
		"You hear an ominous click.")
		icon_state = "telebaton_1"
		item_state = "telebaton"
		w_class = 3
		force = 15//quite robust
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message("\blue [user] collapses their telescopic baton.",\
		"\blue You collapse the baton.",\
		"You hear a click.")
		icon_state = "telebaton_0"
		item_state = null
		w_class = 2
		force = 3//not so robust now
		attack_verb = list("hit", "punched")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

	playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
	add_fingerprint(user)

	if(blood_overlay && blood_DNA && (blood_DNA.len >= 1)) //updates blood overlay, if any
		overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

		var/icon/I = new /icon(src.icon, src.icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
		blood_overlay = I

		overlays += blood_overlay

	return

/obj/item/weapon/melee/telebaton/attack(mob/target, mob/living/user)
	if(on)
		if ((CLUMSY in user.mutations) && prob(50))
			to_chat(user, "\red You club yourself over the head.")
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2 * force, BRUTE, BP_HEAD)
			else
				user.take_bodypart_damage(2 * force)
			return
		if(..())
			playsound(src.loc, "swing_hit", 50, 1, -1)
			return
	else
		return ..()


/*
 *Energy Blade
 */
//Most of the other special functions are handled in their own files.

/obj/item/weapon/melee/energy/sword/green/atom_init()
	. = ..()
	item_color = "green"

/obj/item/weapon/melee/energy/sword/red/atom_init()
	. = ..()
	item_color = "red"

/obj/item/weapon/melee/energy/sword/blue/atom_init()
	. = ..()
	item_color = "blue"

/obj/item/weapon/melee/energy/sword/purple/atom_init()
	. = ..()
	item_color = "purple"

/obj/item/weapon/melee/energy/sword/yellow/atom_init()
	. = ..()
	item_color = "yellow"

/obj/item/weapon/melee/energy/sword/pink/atom_init()
	. = ..()
	item_color = "pink"

/obj/item/weapon/melee/energy/sword/black/atom_init()
	. = ..()
	item_color = "black"


/obj/item/weapon/melee/energy/blade/atom_init()
	. = ..()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/*
 * Energy Axe
 */

/obj/item/weapon/melee/energy/axe/attack_self(mob/user)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "\blue The axe is now energised.")
		src.force = 150
		src.icon_state = "axe1"
		src.w_class = 5
	else
		to_chat(user, "\blue The axe can now be concealed.")
		src.force = 40
		src.icon_state = "axe0"
		src.w_class = 5
	src.add_fingerprint(user)
	return


/*
 * Energy Shield
 */
/obj/item/weapon/shield/energy/Get_shield_chance()
	if(active)
		return block_chance
	return 0

/obj/item/weapon/shield/energy/attack_self(mob/living/user)
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='danger'> You beat yourself in the head with [src].</span>")
		user.take_bodypart_damage(5)
	if(emp_cooldown >= world.time)
		to_chat(user, "<span class='userdanger'>[src] is recalibrating!</span>")
		return
	active = !active
	if(active)
		turn_on(user)
	else
		turn_off(user)
	add_fingerprint(user)

/obj/item/weapon/shield/energy/proc/turn_on(mob/living/user)
	force = 10
	icon_state = "eshield[active]"
	w_class = 4
	playsound(loc, 'sound/weapons/saberon.ogg', 50, 1)
	to_chat(user, "<span class='notice'> [src] is now active.</span>")
	update_icon()

/obj/item/weapon/shield/energy/proc/turn_off(mob/living/user)
	force = 3
	icon_state = "eshield[active]"
	w_class = 1
	playsound(loc, 'sound/weapons/saberoff.ogg', 50, 1)
	update_icon()
	if(user)
		to_chat(user, "<span class='notice'> [src] can now be concealed.</span>")

/obj/item/weapon/shield/energy/update_icon()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_l_hand()
		H.update_inv_r_hand()
