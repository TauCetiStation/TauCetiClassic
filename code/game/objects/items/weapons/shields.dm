/obj/item/weapon/shield
	name = "shield"
	var/block_chance = 65

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

/obj/item/weapon/shield/riot/attack(mob/living/M, mob/user)
	var/obj/item/weapon/shield/riot/tele/TS
	if(istype(src, /obj/item/weapon/shield/riot/tele))
		TS = src

	if(M != user && ((TS && TS.active) || !TS) && !isrobot(M))
		if(M.pulling)
			M.stop_pulling()

		user.do_attack_animation(M)
		user.visible_message("<span class='warning'>[user.name] pushed away [M.name] with a [src.name]</span>")
		addtimer(CALLBACK(GLOBAL_PROC, .proc/_step, M, user.dir), 1)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/_step, M, user.dir), 2)
		user.attack_log += "\[[time_stamp()]\]<font color='red'>pushed [M.name] ([M.ckey]) with [src.name].</font>"
		M.attack_log += "\[[time_stamp()]\]<font color='orange'>pushed [user.name] ([user.ckey]) with [src.name].</font>"
		msg_admin_attack("[key_name(user)] pushed [key_name(M)] with [src.name].", user)

		if(prob(20))
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.shoes)
					if(H.shoes.flags & NOSLIP)
						return
				M.Weaken(3)
				shake_camera(M, 1, 1)

	if(user.a_intent == I_HURT || M == user || (TS && !TS.active) || isrobot(M))
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
	w_class = ITEM_SIZE_NORMAL
	m_amt = 1000
	g_amt = 0
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")
	hitsound = list('sound/weapons/wood_shield_hit.ogg')
	var/cooldown = 0

/obj/item/weapon/shield/buckler/Get_shield_chance()
	return block_chance


/obj/item/weapon/shield/buckler/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/twohanded/spear))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] hits the buclker with spear!</span>")
			playsound(user, 'sound/effects/hits_to_w_shield.ogg', VOL_EFFECTS_MASTER)
			cooldown = world.time


// *BUCKLER CRAFT*

/obj/item/weapon/bucklerframe
	name = "buclker frame"
	desc = "A half-finished shield."
	icon_state = "bucklerframe0"
	var/buildstate = 0

/obj/item/weapon/bucklerframe/update_icon()
	icon_state = "bucklerframe[buildstate]"

/obj/item/weapon/bucklerframe/examine(mob/user)
	..()
	switch(buildstate)
		if(1)
			to_chat(user, "Consists of 3 unlinked boards.")
		if(2)
			to_chat(user, "Consists of 4 unlinked boards.")
		if(3)
			to_chat(user, "Consists of 5 unlinked boards.")
		if(4)
			to_chat(user, "Consists of 5 processed unbound boards.")
		if(5)
			to_chat(user, "Consists of 5 processed bound by wires boards.")
		if(6)
			to_chat(user, "Consists of 5 processed bound by wires boards, coated with strong plasteel.")

/obj/item/weapon/bucklerframe/attackby(obj/item/W, mob/user)
	if(isrobot(user))
		return

	if(istype(W, /obj/item/stack))
		var/obj/item/stack/S = W
		var/amount_to_use
		var/fail_msg
		var/success_msg

		if(istype(W, /obj/item/stack/sheet/wood) && (buildstate == 0 || buildstate == 1 || buildstate == 2))
			amount_to_use = 1
			success_msg = "<span class='notice'>You attach the board to the frame.</span>"
			fail_msg = "<span class='notice'>No more boards needed!</span>"

		if(istype(W, /obj/item/stack/sheet/plasteel) && buildstate == 5)
			amount_to_use = 4
			success_msg = "<span class='notice'>You attach plasteel to the frame.</span>"
			fail_msg = "<span class='notice'>Need 4 sheets of plasteel!</span>"

		if(amount_to_use)
			if(S.use(amount_to_use))
				to_chat(user, success_msg)
				buildstate++
				update_icon()
			else
				to_chat(user, fail_msg)

	else if(istype(W, /obj/item/weapon/wirecutters))
		if(buildstate == 3)
			if(do_after(user, 30, target = src))
				buildstate++
				update_icon()
				playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER, 50)

	else if(istype(W, /obj/item/weapon/handcuffs/cable) && buildstate == 4)
		playsound(src, 'sound/weapons/cablecuff.ogg', VOL_EFFECTS_MASTER, 50)
		if(do_after(user, 30, target = src))
			to_chat(user, "<span class='notice'>You bound boards with cable.</span>")
			buildstate++
			update_icon()
			qdel(W)

	else if(iswelder(W))
		if(buildstate == 6)
			var/obj/item/weapon/weldingtool/T = W
			if(T.use(0, user))
				if(!T.isOn())
					return
				if(do_after(user, 40, target = src))
					to_chat(user, "<span class='notice'>You successfully made a shield!</span>")
					playsound(src, 'sound/items/Welder2.ogg', VOL_EFFECTS_MASTER, 50)
					new /obj/item/weapon/shield/buckler(get_turf(src))
					qdel(src)

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
