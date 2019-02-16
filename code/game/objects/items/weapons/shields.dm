/obj/item/weapon/shield
	name = "shield"
	var/block_chance = 65

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
	w_class = 4.0
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
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
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
	w_class = 2
	block_chance = 30
	origin_tech = "materials=4;magnets=3;syndicate=4"
	attack_verb = list("shoved", "bashed")
	var/active = 0
	var/emp_cooldown = 0

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

/obj/item/weapon/shield/riot/tele/Get_shield_chance()
	if(active)
		return block_chance
	return 0

/obj/item/weapon/shield/riot/tele/attack_self(mob/living/user)
	active = !active
	icon_state = "teleriot[active]"
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = 4
		slot_flags = SLOT_FLAGS_BACK
		to_chat(user, "<span class='notice'>You extend \the [src].</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = 3
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
	w_class = 2.0
	origin_tech = "magnets=3;syndicate=4"

/obj/item/weapon/cloaking_device/attack_self(mob/user)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "\blue The cloaking device is now active.")
		src.icon_state = "shield1"
	else
		to_chat(user, "\blue The cloaking device is now inactive.")
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
