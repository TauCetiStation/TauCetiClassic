#define DUALSABER_BLOCK_CHANCE_MODIFIER 1.2

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
	var/obj/item/weapon/twohanded/offhand/offhand_item = /obj/item/weapon/twohanded/offhand

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
			user.drop_from_inventory(O)
	return	unwield()

/obj/item/weapon/twohanded/update_icon()
	return

/obj/item/weapon/twohanded/pickup(mob/living/user)
	unwield()

/obj/item/weapon/twohanded/attack_self(mob/user)
	if(istype(user,/mob/living/carbon/monkey))
		to_chat(user, "<span class='warning'>It's too heavy for you to wield fully.</span>")
		return

	if(wielded) //Trying to unwield it
		unwield()
		to_chat(user, "<span class='notice'>You are now carrying the [name] with one hand.</span>")
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()

		if (src.unwieldsound)
			playsound(src, unwieldsound, VOL_EFFECTS_MASTER)

		var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
		if(istype(O))
			user.drop_from_inventory(O)
		return

	else if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/W = H.wield(src, initial(name), wieldsound)
		if(W)
			wield()

///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	w_class = ITEM_SIZE_HUGE
	icon_state = "offhand"
	name = "offhand"
	flags = ABSTRACT

/obj/item/weapon/twohanded/offhand/unwield()
	qdel(src)

/obj/item/weapon/twohanded/offhand/wield()
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
	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_FLAGS_BACK
	force_unwielded = 10
	force_wielded = 40
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")

	sweep_step = 5

/obj/item/weapon/twohanded/fireaxe/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	SCB.can_sweep_call = CALLBACK(src, /obj/item/weapon/twohanded/fireaxe.proc/can_sweep)
	SCB.can_spin_call = CALLBACK(src, /obj/item/weapon/twohanded/fireaxe.proc/can_spin)

	AddComponent(/datum/component/swiping, SCB)

	hitsound = SOUNDIN_DESCERATION

/obj/item/weapon/twohanded/fireaxe/proc/can_sweep(mob/user)
	return wielded

/obj/item/weapon/twohanded/fireaxe/proc/can_spin(mob/user)
	return wielded

/obj/item/weapon/twohanded/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[wielded]"
	return

/obj/item/weapon/twohanded/fireaxe/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	..()
	if(target && wielded) //destroys windows and grilles in one hit
		if(istype(target,/obj/structure/window)) //should just make a window.Break() proc but couldn't bother with it
			var/obj/structure/window/W = target
			W.shatter()
		else if(istype(target,/obj/structure/grille))
			var/obj/structure/grille/G = target
			new /obj/item/stack/rods(G.loc)
			qdel(target)


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
	w_class = ITEM_SIZE_SMALL
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

	sweep_step = 2

/obj/item/weapon/twohanded/dualsaber/atom_init()
	. = ..()
	reflect_chance = rand(50, 65)
	item_color = pick("red", "blue", "green", "purple","yellow","pink","black")
	switch(item_color)
		if("red")
			light_color = COLOR_RED
		if("blue")
			light_color = COLOR_BLUE
		if("green")
			light_color = COLOR_GREEN
		if("purple")
			light_color = COLOR_PURPLE
			light_power = 2
		if("yellow")
			light_color = COLOR_YELLOW
		if("pink")
			light_color = COLOR_PINK
		if("black")
			light_color = COLOR_GRAY

	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list()

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	SCB.can_sweep_call = CALLBACK(src, /obj/item/weapon/twohanded/dualsaber.proc/can_swipe)
	SCB.can_spin_call = CALLBACK(src, /obj/item/weapon/twohanded/dualsaber.proc/can_swipe)
	SCB.on_get_sweep_objects = CALLBACK(src, /obj/item/weapon/twohanded/dualsaber.proc/get_sweep_objs)

	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/twohanded/dualsaber/proc/can_swipe(mob/user)
	return wielded

/obj/item/weapon/twohanded/dualsaber/proc/get_sweep_objs(turf/start, obj/item/I, mob/user, list/directions, sweep_delay)
	var/list/directions_opposite = list()
	for(var/dir_ in directions)
		directions_opposite += turn(dir_, 180)

	var/list/sweep_objects = list()
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions, sweep_delay)
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions_opposite, sweep_delay)
	return sweep_objects

/obj/item/weapon/twohanded/dualsaber/update_icon()
	if(wielded)
		icon_state = "dualsaber[item_color][wielded]"
	else
		icon_state = "dualsaber0"
	clean_blood()//blood overlays get weird otherwise, because the sprite changes.

/obj/item/weapon/twohanded/dualsaber/attack(target, mob/living/user)
	..()
	if((CLUMSY in user.mutations) && (wielded) && prob(40))
		to_chat(user, "<span class='userdanger'> You twirl around a bit before losing your balance and impaling yourself on the [src].</span>")
		user.take_bodypart_damage(20, 25)
		return
	if(wielded && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.dir = i
				sleep(1)

/obj/item/weapon/twohanded/dualsaber/Get_shield_chance()
	if(wielded && !slicing)
		return reflect_chance * DUALSABER_BLOCK_CHANCE_MODIFIER - 5
	else
		return 0

/obj/item/weapon/twohanded/dualsaber/IsReflect(def_zone, hol_dir, hit_dir)
	return !slicing && wielded && prob(reflect_chance) && is_the_opposite_dir(hol_dir, hit_dir)

/obj/item/weapon/twohanded/dualsaber/attackby(obj/item/I, mob/user, params)
	if(ismultitool(I))
		if(!hacked)
			hacked = TRUE
			to_chat(user,"<span class='warning'>2XRNBW_ENGAGE</span>")
			item_color = "rainbow"
			light_color = ""
			update_icon()
		else
			to_chat(user,"<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")
	else
		return ..()

/obj/item/weapon/twohanded/dualsaber/afterattack(atom/target, mob/user, proximity, params)
	if(!istype(target,/obj/machinery/door/airlock) || slicing)
		return
	if(target.density && wielded && proximity && in_range(user, target))
		user.visible_message("<span class='danger'>[user] start slicing the [target] </span>")
		playsound(user, 'sound/items/Welder2.ogg', VOL_EFFECTS_MASTER)
		slicing = TRUE
		var/obj/machinery/door/airlock/D = target
		var/obj/effect/I = new /obj/effect/overlay/slice(D.loc)
		if(do_after(user, 450, target = D) && D.density && !(D.operating == -1) && in_range(user, D))
			sleep(6)
			var/obj/structure/door_scrap/S = new /obj/structure/door_scrap(D.loc)
			var/iconpath = D.icon
			var/icon/IC = new(iconpath, "closed")
			IC.Blend(S.door, ICON_OVERLAY, 1, 1)
			IC.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
			S.icon = IC
			S.name = D.name
			S.name += " remains"
			qdel(D)
			qdel(IC)
			playsound(user, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
		slicing = FALSE
		qdel(I)


/obj/item/weapon/twohanded/dualsaber/dropped(mob/user)
 	..()
 	slicing = FALSE

/obj/item/weapon/twohanded/dualsaber/attack_self(mob/user)
	if(slicing)
		return
	..()

/obj/item/weapon/twohanded/dualsaber/unwield()
	set_light(0)
	hitsound = initial(hitsound)
	w_class = initial(w_class)
	return ..()

/obj/item/weapon/twohanded/dualsaber/wield()
	set_light(2)
	hitsound = list('sound/weapons/blade1.ogg')
	w_class = ITEM_SIZE_HUGE
	return ..()

#undef DUALSABER_BLOCK_CHANCE_MODIFIER
