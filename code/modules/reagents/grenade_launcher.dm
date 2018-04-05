/obj/item/weapon/gun/grenadelauncher
	name = "grenade launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/grenades = new/list()
	var/max_grenades = 3
	m_amt = 2000

/obj/item/weapon/gun/grenadelauncher/examine(mob/user)
	..()
	if(src in view(2, user))
		to_chat(user, "<span class='notice'>[grenades.len] / [max_grenades] Grenades.</span>")

/obj/item/weapon/gun/grenadelauncher/attackby(obj/item/I, mob/user)

	if((istype(I, /obj/item/weapon/grenade)))
		if(grenades.len < max_grenades)
			user.drop_item()
			I.loc = src
			grenades += I
			to_chat(user, "\blue You put the grenade in the grenade launcher.")
			to_chat(user, "\blue [grenades.len] / [max_grenades] Grenades.")
		else
			to_chat(usr, "\red The grenade launcher cannot hold more grenades.")

/obj/item/weapon/gun/grenadelauncher/afterattack(obj/target, mob/user , flag)
	if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(grenades.len)
		spawn(0) fire_grenade(target,user)
	else
		to_chat(usr, "\red The grenade launcher is empty.")

/obj/item/weapon/gun/grenadelauncher/proc/fire_grenade(atom/target, mob/user)
	for(var/mob/O in viewers(world.view, user))
		O.show_message(text("\red [] fired a grenade!", user), 1)
	to_chat(user, "\red You fire the grenade launcher!")
	var/obj/item/weapon/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.loc = user.loc
	F.throw_at(target, 30, 2, user)
	message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from a grenade launcher ([src.name]). (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	log_game("[key_name_admin(user)] used a grenade ([src.name]).")
	F.active = 1
	F.icon_state = initial(icon_state) + "_active"
	playsound(user.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	spawn(15)
		F.prime()
