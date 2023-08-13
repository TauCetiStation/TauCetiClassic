/obj/item/weapon/shield
	name = "shield"
	var/block_chance = 65
	var/wall_of_shield_on = FALSE
	var/saved_dir = 0

/obj/item/weapon/shield/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf)

	SCB.can_sweep = TRUE

	SCB.can_push = TRUE

	SCB.on_sweep_hit = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield, on_sweep_hit))

	SCB.on_sweep_push_success = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield, on_sweep_push_success))

	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/shield/proc/on_sweep_hit(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, atom/target, mob/living/user)
	var/datum/component/swiping/SW = GetComponent(/datum/component/swiping)

	var/is_stunned = is_type_in_list(target, SW.interupt_on_sweep_hit_types)
	if(is_stunned)
		to_chat(user, "<span class='warning'>Your [src] has hit [target]! There's not enough space for broad sweeps here!</span>")

	melee_attack_chain(target, user)

	if(isliving(target) && prob(Get_shield_chance())) // Better shields have more chance to stun.
		var/mob/living/M = target
		user.visible_message("<span class='warning'>[M] is stunned by [user] with [src]!</span>", "<span class='warning'>You stun [M] with [src]!</span>")
		if(M.buckled)
			M.buckled.user_unbuckle_mob(M)

		M.apply_effect(4, STUTTER, 0)
		shake_camera(M, 1, 1)

	return is_stunned

/obj/item/weapon/shield/proc/on_sweep_push_success(atom/target, mob/user)
	var/turf/T_target = get_turf(target)

	if(user.a_intent != INTENT_HELP)
		melee_attack_chain(target, user)

	if(!has_gravity(src) && !isspaceturf(target))
		step_away(user, T_target)
	else if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		if(!AM.anchored)
			var/turf/to_move = get_step(target, get_dir(user, target))
			step_away(target, get_turf(src))
			if(AM.loc != to_move && isliving(AM)) // We tried pushing them, but pushed them into something, IT'S FALLING DOWN TIME.
				var/mob/living/M = AM

				M.log_combat(user, "pushed with [name]")

				user.visible_message("<span class='warning'>[M] is stunned by [user] with [src]!</span>", "<span class='warning'>You stun [M] with [src]!</span>")
				if(M.buckled)
					M.buckled.user_unbuckle_mob(M)

				M.apply_effect(6, STUTTER, 0)
				shake_camera(M, 1, 1)

/obj/item/weapon/shield/AltClick(mob/living/user)
	toggle_wallshield(user)

/obj/item/weapon/shield/proc/toggle_wallshield(mob/living/user)
	if(wall_of_shield_on)
		disable_wallshield(user)
		user.visible_message("<span class='notice'>[user] stopped holding the protective stance.</span>")
	else
		if(enable_wallshield(user))
			user.visible_message("<span class='warning'>[user] got into a defensive stance with [src].</span>",
								"<span class='notice'>You got into a defensive stance with [src].</span>")

/obj/item/weapon/shield/proc/enable_wallshield(mob/living/user)
	if(!user.is_in_hands(src))
		return FALSE
	user.SetNextMove(CLICK_CD_MELEE)
	saved_dir = user.dir
	wall_of_shield_on = TRUE
	add_filter("wallshield_outline", 2, outline_filter(1, "#c0c0c0"))
	update_icon()
	update_inv_mob()
	RegisterSignal(user, list(COMSIG_ATOM_CHANGE_DIR), PROC_REF(user_moved))
	return TRUE

/obj/item/weapon/shield/proc/disable_wallshield(mob/living/user)
	saved_dir = 0
	wall_of_shield_on = FALSE
	remove_filter("wallshield_outline")
	update_icon()
	if(user)
		to_chat(user, "<span class='info'>You interrupted the Wall of Shields technique.</span>")
		update_inv_mob()
		UnregisterSignal(user, list(COMSIG_ATOM_CHANGE_DIR))

/obj/item/weapon/shield/proc/user_moved(datum/source, dir)
	if(!wall_of_shield_on)
		return
	if(!saved_dir)
		return
	if(dir != saved_dir)
		disable_wallshield(source)

/obj/item/weapon/shield/update_icon()
	item_state = "[icon_state][wall_of_shield_on ? "_outline" : ""]"

//nothing happens but it should be because of logic
/obj/item/weapon/shield/dropped(mob/living/user)
	. = ..()
	if(wall_of_shield_on)
		disable_wallshield(user)

/obj/item/weapon/shield/Get_shield_chance()
	var/mob/living/carbon/human/M = loc
	if(!M || !M.is_in_hands(src) || !wall_of_shield_on)
		return block_chance
	var/add_block = 0
	var/turf/user_turf = get_turf(M)
	//find comrads without build a line or smth
	for(var/mob/living/carbon/human/H in range(1, user_turf))
		if(H == M)
			continue
		var/obj/item/weapon/shield/shield = H.is_in_hands(/obj/item/weapon/shield)
		//no_shields
		if(!shield)
			continue
		//should be in hand
		if(!shield.wall_of_shield_on)
			continue
		//Must face the same direction for balance
		if(shield.saved_dir != saved_dir)
			continue
		//should be more unbalanced because of promotion teamplay
		add_block += 15
	return block_chance + add_block

/obj/item/weapon/shield/riot
	hitsound = list('sound/weapons/metal_shield_hit.ogg')
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BACK
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = SIZE_NORMAL
	g_amt = 7500
	m_amt = 1000
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time

/obj/item/weapon/shield/riot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [I]!</span>")
			playsound(user, 'sound/effects/shieldbash.ogg', VOL_EFFECTS_MASTER)
			cooldown = world.time
	else
		return ..()

/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags = CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = SIZE_TINY
	block_chance = 30
	origin_tech = "materials=4;magnets=3;syndicate=4"
	attack_verb = list("shoved", "bashed")
	var/active = 0
	var/emp_cooldown = 0

/obj/item/weapon/shield/energy/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf)

	SCB.can_sweep = TRUE

	SCB.can_push = TRUE

	SCB.on_sweep_hit = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield, on_sweep_hit))

	SCB.on_sweep_push_success = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield, on_sweep_push_success))

	SCB.can_sweep_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield/energy, can_sweep))
	SCB.can_push_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield/energy, can_sweep_push))

	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/shield/energy/toggle_wallshield(mob/user)
	to_chat(user, "<span class='warning'>Why do I have to move so slowly?</span>")

/obj/item/weapon/shield/energy/proc/can_sweep(mob/user)
	return active

/obj/item/weapon/shield/energy/proc/can_sweep_push(mob/user)
	return active

/obj/item/weapon/shield/energy/IsReflect(def_zone, hol_dir, hit_dir)
	if(active)
		return is_the_opposite_dir(hol_dir, hit_dir)
	return FALSE

/obj/item/weapon/shield/energy/emp_act(severity)
	if(active)
		if(severity == 2 && prob(35))
			active = !active
			emp_cooldown = world.time + 200
			turn_off()
		else if(severity == 1)
			active = !active
			emp_cooldown = world.time + rand(200, 400)
			turn_off()

/obj/item/weapon/shield/energy/on_enter_storage(obj/item/weapon/storage/S)
	..()
	if(active)
		attack_self(usr)

/obj/item/weapon/shield/riot/tele
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "teleriot0"
	origin_tech = "materials=3;combat=4;engineering=4"
	slot_flags = null
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	block_chance = 50
	w_class = SIZE_SMALL
	var/active = 0

/obj/item/weapon/shield/riot/tele/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf)

	SCB.can_sweep = TRUE

	SCB.can_push = TRUE

	SCB.on_sweep_hit = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield, on_sweep_hit))

	SCB.on_sweep_push_success = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield, on_sweep_push_success))

	SCB.can_sweep_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield/riot/tele, can_sweep))
	SCB.can_push_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/shield/riot/tele, can_sweep_push))

	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/shield/riot/tele/proc/can_sweep(mob/user)
	return active

/obj/item/weapon/shield/riot/tele/proc/can_sweep_push(mob/user)
	return active

/obj/item/weapon/shield/riot/tele/Get_shield_chance()
	if(active)
		return ..()
	return 0

/obj/item/weapon/shield/riot/tele/toggle_wallshield(mob/living/user)
	if(active)
		return ..()

/obj/item/weapon/shield/riot/tele/attack_self(mob/living/user)
	active = !active
	icon_state = "teleriot[active]"
	playsound(src, 'sound/weapons/batonextend.ogg', VOL_EFFECTS_MASTER)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = SIZE_NORMAL
		slot_flags = SLOT_FLAGS_BACK
		to_chat(user, "<span class='notice'>You extend \the [src].</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = SIZE_SMALL
		slot_flags = null
		if(wall_of_shield_on)
			disable_wallshield(user)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)
	update_icon()

/obj/item/weapon/shield/riot/roman
	name = "roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	item_state = "roman_shield"

/obj/item/weapon/shield/buckler
	name = "buckler"
	desc = "A standard home-made shield, that can protect you from multiple shots. May break."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "buckler"
	flags = CONDUCT
	force = 6.0
	throwforce = 4.0
	throw_speed = 3
	throw_range = 5
	block_chance = 45
	w_class = SIZE_SMALL
	m_amt = 1000
	g_amt = 0
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")
	hitsound = list('sound/weapons/wood_shield_hit.ogg')
	var/cooldown = 0

/obj/item/weapon/shield/buckler/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/spear))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] hits the buclker with spear!</span>")
			playsound(user, 'sound/effects/hits_to_w_shield.ogg', VOL_EFFECTS_MASTER)
			cooldown = world.time

	else
		return ..()

// *(BUCKLER craft in recipes.dm)*

/obj/item/weapon/bucklerframe1
	name = "shield(1 stage)"
	desc = "To finish you need: cut with wirecutters; bound with cable restraints; attach 4 plasteel; weld it all."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bucklerframe1"

/obj/item/weapon/bucklerframe2
	name = "shield(2 stage)"
	desc = "To finish you need: bound with cable restraints; attach 4 plasteel; weld it all."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bucklerframe2"

/obj/item/weapon/bucklerframe3
	name = "shield(3 stage)"
	desc = "To finish you need: attach 4 plasteel; weld it all."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bucklerframe3"

/obj/item/weapon/bucklerframe4
	name = "shield(4 stage)"
	desc = "To finish you need: weld it all."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bucklerframe4"

/*
/obj/item/weapon/cloaking_device
	name = "cloaking device"
	desc = "Use this to become invisible to the human eyesocket."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	var/active = 0.0
	flags = CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = SIZE_TINY
	origin_tech = "magnets=3;syndicate=4"

/obj/item/weapon/cloaking_device/attack_self(mob/user)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "<span class='notice'>The cloaking device is now active.</span>")
		src.icon_state = "shield1"
	else
		to_chat(user, "<span class='notice'>The cloaking device is now inactive.</span>")
		src.icon_state = "shield0"
	add_fingerprint(user)
	return

/obj/item/weapon/cloaking_device/emp_act(severity)
	active = 0
	icon_state = "shield0"
	if(ismob(loc))
		loc:update_icons()
	..()
*/

/proc/check_shield_dir(mob/shield_bearer, attack_dir)
	if(istype(shield_bearer.l_hand, /obj/item/weapon/shield))
		if(shield_bearer.dir == NORTH && (attack_dir in list(SOUTH, EAST)))
			return TRUE
		else if(shield_bearer.dir == SOUTH && (attack_dir in list(NORTH, WEST)))
			return TRUE
		else if(shield_bearer.dir == EAST && (attack_dir in list(WEST, SOUTH)))
			return TRUE
		else if(shield_bearer.dir == WEST && (attack_dir in list(EAST, NORTH)))
			return TRUE
	if(istype(shield_bearer.r_hand, /obj/item/weapon/shield))
		if(shield_bearer.dir == NORTH && (attack_dir in list(SOUTH, WEST)))
			return TRUE
		else if(shield_bearer.dir == SOUTH && (attack_dir in list(NORTH, EAST)))
			return TRUE
		else if(shield_bearer.dir == EAST && (attack_dir in list(WEST, NORTH)))
			return TRUE
		else if(shield_bearer.dir == WEST && (attack_dir in list(EAST, SOUTH)))
			return TRUE
	return FALSE
