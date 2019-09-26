/obj/item/weapon/shield
	name = "shield"
	var/block_chance = 65

	can_push = TRUE
	hit_on_harm_push = TRUE
	can_sweep = TRUE
	interupt_on_sweep_hit_types = list(/turf, /obj/structure/table, /obj/machinery/disposal, /obj/structure/rack)

	var/next_shield_push = 0

/obj/item/weapon/shield/on_sweep_hit(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, atom/A, mob/living/user)
	var/is_stunned = is_type_in_list(A, interupt_on_sweep_hit_types)
	if(is_stunned)
		to_chat(user, "<span class='warning'>Your [src] has hit [A]! There's not enough space for broad sweeps here!</span>")

	if(user.a_intent != I_HELP)
		var/resolved = A.attackby(src, user, list())
		if(!resolved && src)
			afterattack(A, user, TRUE, list()) // 1 indicates adjacency

	if(isliving(A) && prob(Get_shield_chance())) // Better shields have more chance to stun.
		var/mob/living/M = A
		user.visible_message("<span class='warning'>[M] is stunned by [user] with [src]!</span>", "<span class='warning'>You stun [M] with [src]!</span>")
		if(M.buckled)
			M.buckled.user_unbuckle_mob(M)

		M.apply_effect(2, STUN, 0)
		M.apply_effect(2, WEAKEN, 0)
		M.apply_effect(4, STUTTER, 0)
		shake_camera(M, 1, 1)

	return is_stunned

/obj/item/weapon/shield/on_sweep_push_success(atom/target, mob/user)
	var/turf/T_target = get_turf(target)

	if(hit_on_harm_push && user.a_intent != I_HELP)
		var/resolved = target.attackby(src, user, list())
		if(!resolved && src)
			afterattack(target, user, TRUE, list()) // 1 indicates adjacency

	if(!has_gravity(src) && !istype(target, /turf/space))
		step_away(user, T_target)
	else if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		if(!AM.anchored)
			var/turf/to_move = get_step(target, get_dir(user, target))
			step_away(target, get_turf(src))
			if(AM.loc != to_move && isliving(AM) && next_shield_push < world.time) // We tried pushing them, but pushed them into something, IT'S FALLING DOWN TIME.
				next_shield_push = world.time + 4 SECONDS
				var/mob/living/M = AM

				user.attack_log += "\[[time_stamp()]\]<font color='red'>pushed [M.name] ([M.ckey]) with [src.name].</font>"
				M.attack_log += "\[[time_stamp()]\]<font color='orange'>pushed [user.name] ([user.ckey]) with [src.name].</font>"
				msg_admin_attack("[key_name(user)] pushed [key_name(M)] with [src.name].", user)
				user.visible_message("<span class='warning'>[M] is stunned by [user] with [src]!</span>", "<span class='warning'>You stun [M] with [src]!</span>")
				if(M.buckled)
					M.buckled.user_unbuckle_mob(M)

				M.apply_effect(2, STUN, 0)
				M.apply_effect(2, WEAKEN, 0)
				M.apply_effect(4, STUTTER, 0)
				shake_camera(M, 1, 1)

/obj/item/weapon/shield/riot
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
	w_class = ITEM_SIZE_LARGE
	g_amt = 7500
	m_amt = 1000
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time

/obj/item/weapon/shield/riot/Get_shield_chance()
	return block_chance

/obj/item/weapon/shield/riot/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user, 'sound/effects/shieldbash.ogg', VOL_EFFECTS_MASTER)
			cooldown = world.time
	else
		..()

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
	w_class = ITEM_SIZE_SMALL
	block_chance = 30
	origin_tech = "materials=4;magnets=3;syndicate=4"
	attack_verb = list("shoved", "bashed")
	var/active = 0
	var/emp_cooldown = 0

/obj/item/weapon/shield/energy/can_push()
	return can_push && active

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
	w_class = ITEM_SIZE_NORMAL
	var/active = 0

/obj/item/weapon/shield/riot/tele/can_push()
	return can_push && active

/obj/item/weapon/shield/riot/tele/Get_shield_chance()
	if(active)
		return block_chance
	return 0

/obj/item/weapon/shield/riot/tele/attack_self(mob/living/user)
	active = !active
	icon_state = "teleriot[active]"
	playsound(src, 'sound/weapons/batonextend.ogg', VOL_EFFECTS_MASTER)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = ITEM_SIZE_LARGE
		slot_flags = SLOT_FLAGS_BACK
		to_chat(user, "<span class='notice'>You extend \the [src].</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = ITEM_SIZE_NORMAL
		slot_flags = null
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)

/obj/item/weapon/shield/riot/roman
	name = "roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	item_state = "roman_shield"

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
	w_class = ITEM_SIZE_SMALL
	origin_tech = "magnets=3;syndicate=4"

/obj/item/weapon/cloaking_device/attack_self(mob/user)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "<span class='notice'>The cloaking device is now active.</span>")
		src.icon_state = "shield1"
	else
		to_chat(user, "<span class='notice'>The cloaking device is now inactive.</span>")
		src.icon_state = "shield0"
	src.add_fingerprint(user)
	return

/obj/item/weapon/cloaking_device/emp_act(severity)
	active = 0
	icon_state = "shield0"
	if(ismob(loc))
		loc:update_icons()
	..()
*/
