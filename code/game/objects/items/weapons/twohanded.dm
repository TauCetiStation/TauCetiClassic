/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 */

/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

//Rewrote TwoHanded weapons stuff and put it all here. Just copypasta fireaxe to make new ones ~Carn
//This rewrite means we don't have two variables for EVERY item which are used only by a few weapons.
//It also tidies stuff up elsewhere.

/*
 * Twohanded
 */
/obj/item/weapon/twohanded
	var/wielded = 0
	var/force_unwielded = 0
	var/force_wielded = 0
	var/wieldsound = null
	var/unwieldsound = null

/obj/item/weapon/twohanded/proc/unwield()
	wielded = 0
	force = force_unwielded
	name = "[initial(name)]"
	update_icon()

/obj/item/weapon/twohanded/proc/wield()
	wielded = 1
	force = force_wielded
	name = "[initial(name)] (Wielded)"
	update_icon()

/obj/item/weapon/twohanded/mob_can_equip(M, slot)
	//Cannot equip wielded items.
	if(wielded)
		to_chat(M, "<span class='warning'>Unwield the [initial(name)] first!</span>")
		return 0

	return ..()

/obj/item/weapon/twohanded/dropped(mob/user)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		var/obj/item/weapon/twohanded/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
	return	unwield()

/obj/item/weapon/twohanded/update_icon()
	return

/obj/item/weapon/twohanded/pickup(mob/user)
	unwield()

/obj/item/weapon/twohanded/attack_self(mob/user)
	if( istype(user,/mob/living/carbon/monkey) )
		to_chat(user, "<span class='warning'>It's too heavy for you to wield fully.</span>")
		return

	..()
	if(wielded) //Trying to unwield it
		unwield()
		to_chat(user, "<span class='notice'>You are now carrying the [name] with one hand.</span>")
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()

		if (src.unwieldsound)
			playsound(src.loc, unwieldsound, 50, 1)

		var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
		if(O && istype(O))
			O.unwield()
		return

	else //Trying to wield it
		if(user.get_inactive_hand())
			to_chat(user, "<span class='warning'>You need your other hand to be empty</span>")
			return
		wield()
		to_chat(user, "<span class='notice'>You grab the [initial(name)] with both hands.</span>")
		if (src.wieldsound)
			playsound(src.loc, wieldsound, 50, 1)

		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()

		var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
		O.name = "[initial(name)] - offhand"
		O.desc = "Your second grip on the [initial(name)]"
		user.put_in_inactive_hand(O)
		return

///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	w_class = 5.0
	icon_state = "offhand"
	name = "offhand"

	unwield()
		qdel(src)

	wield()
		qdel(src)

/*
 * Fireaxe
 */
/obj/item/weapon/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	sharp = 1
	edge = 1
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 40
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")

/obj/item/weapon/twohanded/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[wielded]"
	return

/obj/item/weapon/twohanded/fireaxe/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	..()
	if(A && wielded && (istype(A,/obj/structure/window) || istype(A,/obj/structure/grille))) //destroys windows and grilles in one hit
		if(istype(A,/obj/structure/window)) //should just make a window.Break() proc but couldn't bother with it
			var/obj/structure/window/W = A

			new /obj/item/weapon/shard( W.loc )
			if(W.reinf) new /obj/item/stack/rods( W.loc)

			if (W.dir == SOUTHWEST)
				new /obj/item/weapon/shard( W.loc )
				if(W.reinf) new /obj/item/stack/rods( W.loc)
		else if(istype(A,/obj/structure/grille))
			var/obj/structure/grille/G = A
			new /obj/item/stack/rods(G.loc)
		qdel(A)


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/twohanded/dualsaber
	var/reflect_chance = 0
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	item_color = "green"
	force_unwielded = 3
	force_wielded = 45
	var/hacked
	var/slicing
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	flags = NOSHIELD
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1
	can_embed = 0

/obj/item/weapon/twohanded/dualsaber/New()
	reflect_chance = rand(50,85)
	item_color = pick("red", "blue", "green", "purple")

/obj/item/weapon/twohanded/dualsaber/update_icon()
	if(wielded)
		icon_state = "dualsaber[item_color][wielded]"
	else
		icon_state = "dualsaber0"
	clean_blood()//blood overlays get weird otherwise, because the sprite changes.

/obj/item/weapon/twohanded/dualsaber/attack(target, mob/living/user)
	..()
	if((CLUMSY in user.mutations) && (wielded) &&prob(40))
		to_chat(user, "\red You twirl around a bit before losing your balance and impaling yourself on the [src].")
		user.take_organ_damage(20,25)
		return
	if((wielded) && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.dir = i
				sleep(1)

/obj/item/weapon/twohanded/dualsaber/IsShield()
	if(wielded)
		return 1
	else
		return 0

/obj/item/weapon/twohanded/dualsaber/IsReflect(def_zone, hol_dir, hit_dir)
	if(wielded && prob(reflect_chance))
		if(hol_dir == NORTH && (hit_dir in list(SOUTH, SOUTHEAST, SOUTHWEST)))
			return TRUE
		else if(hol_dir == SOUTH && (hit_dir in list(NORTH, NORTHEAST, NORTHWEST)))
			return TRUE
		else if(hol_dir == EAST && (hit_dir in list(WEST, NORTHWEST, SOUTHWEST)))
			return TRUE
		else if(hol_dir == WEST && (hit_dir in list(EAST, NORTHEAST, SOUTHEAST)))
			return TRUE
	return FALSE

/obj/item/weapon/twohanded/dualsaber/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		if(!hacked)
			hacked = 1
			to_chat(user,"<span class='warning'>2XRNBW_ENGAGE</span>")
			item_color = "rainbow"
			update_icon()
		else
			to_chat(user,"<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")
	else
		return ..()

/obj/item/weapon/twohanded/dualsaber/afterattack(obj/O, mob/user, proximity)
	if(!istype(O,/obj/machinery/door/airlock))
		return
	if(O.density && src.wielded && proximity)
		user.visible_message("<span class='danger'>[user] start slicing the [O] </span>")
		playsound(user.loc, 'sound/items/Welder2.ogg', 100, 1, -1)
		src.slicing = 1
		var/obj/machinery/door/airlock/D = O
		var/obj/effect/I = new /obj/effect/overlay/slice(D.loc)
		if(do_after(user, 450, target = D) && D.density && !(D.operating == -1))
			sleep(6)
			var/obj/structure/door_scrap/S = new /obj/structure/door_scrap(D.loc)
			var/iconpath = D.icon
			var/icon/IC = new(iconpath, "closed")
			IC.Blend(S.door, ICON_OVERLAY, 1, 1)
			IC.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
			S.icon = IC
			qdel(D)
			qdel(IC)
			playsound(user.loc, 'sound/weapons/blade1.ogg', 100, 1, -1)
		src.slicing = 0
		qdel(I)


/obj/item/weapon/twohanded/dualsaber/dropped(mob/user)
 	..()
 	src.slicing = 0

/obj/item/weapon/twohanded/dualsaber/attack_self(mob/user)
	if(src.slicing)
		return
	else
		..()
