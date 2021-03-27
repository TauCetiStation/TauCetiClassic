/obj/item/weapon/gun/grenadelauncher
	name = "grenade launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = ITEM_SIZE_LARGE
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/grenades = new/list()
	var/max_grenades = 3
	m_amt = 2000
	slot_flags = SLOT_FLAGS_BACK
	can_be_holstered = FALSE

/obj/item/weapon/gun/grenadelauncher/examine(mob/user)
	..()
	if(src in view(2, user))
		to_chat(user, "<span class='notice'>[grenades.len] / [max_grenades] Grenades.</span>")

/obj/item/weapon/gun/grenadelauncher/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/grenade))
		if(grenades.len < max_grenades)
			user.drop_from_inventory(I, src)
			grenades += I
			to_chat(user, "<span class='notice'>You put the grenade in the grenade launcher.</span>")
			to_chat(user, "<span class='notice'>[grenades.len] / [max_grenades] Grenades.</span>")
		else
			to_chat(usr, "<span class='warning'>The grenade launcher cannot hold more grenades.</span>")
	else
		return ..()

/obj/item/weapon/gun/grenadelauncher/afterattack(atom/target, mob/user, proximity, params)
	if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(grenades.len)
		spawn(0) fire_grenade(target,user)
	else
		to_chat(usr, "<span class='warning'>The grenade launcher is empty.</span>")

/obj/item/weapon/gun/grenadelauncher/proc/fire_grenade(atom/target, mob/user)
	user.visible_message("<span class='warning'>[user] fired a grenade!</span>", self_message = "<span class='warning'>You fire the grenade launcher!</span>")
	var/obj/item/weapon/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.loc = user.loc
	F.throw_at(target, 30, 2, user)
	message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from a grenade launcher ([src.name]). [ADMIN_JMP(user)]")
	log_game("[key_name(user)] used a grenade ([src.name]).")
	F.active = 1
	F.icon_state = initial(F.icon_state) + "_active"
	playsound(user, 'sound/weapons/armbomb.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	spawn(15)
		F.prime()
