/obj/item/modular/accessory
	name = "accessory"
	m_amt = 1000
	var/activated
	var/list/modul_size = ALL_SIZE_ATTACH
	var/list/conflicts = list()
	var/attacked = FALSE
	var/usering = FALSE
	var/mob/user_parent
	var/attachment_point

/obj/item/modular/accessory/Destroy()
	src.deactivate(user_parent)
	user_parent = null
	return ..()
/obj/item/modular/accessory/attackby(obj/item/A, mob/user)
	if(!attacked)
		return

/obj/item/modular/accessory/proc/deactivate(mob/user = user_parent)
	if(user != null && usering)
		return
	activated = FALSE

/obj/item/modular/accessory/proc/activate(mob/user = user_parent)
	if(user != null && usering)
		return
	activated = TRUE

/obj/item/modular/accessory/optical
	name = "optical"
	icon_state = "optical_icon"
	icon_overlay = "optical"
	gun_type = list(LASER, BULLET)
	modul_size = ALL_SIZE_ATTACH
	usering = TRUE
	attachment_point = CHAMBER
	var/range = 12
	var/zoom = FALSE
	var/x_lock
	var/y_lock

/obj/item/modular/accessory/optical/small
	name = "small optical"
	icon_state = "optical_small_icon"
	icon_overlay = "optical_small"
	range = 9
	zoom = FALSE
	lessdamage = 0
	lessdispersion = 0.1
	lessfiredelay= -1
	lessrecoil = 0
	size = 0.1
	modul_size = list(BARREL_ALL, CHAMBER_ALL, GRIP_ALL)

/obj/item/modular/accessory/optical/medium
	name = "medium optical"
	icon_state = "optical_medium_icon"
	icon_overlay = "optical_medium"
	range = 12
	zoom = FALSE
	lessdamage = 0
	lessdispersion = 0.2
	lessfiredelay= -2
	lessrecoil = 0
	size = 0.2
	modul_size = list(BARREL_MEDIUM, BARREL_LARGE, CHAMBER_ALL, GRIP_ALL)

/obj/item/modular/accessory/optical/large
	name = "large optical"
	icon_state = "optical_large_icon"
	icon_overlay = "optical_large"
	range = 16
	zoom = FALSE
	lessdamage = 0
	lessdispersion = 0.4
	lessfiredelay= -3
	lessrecoil = 0
	size = 0.4
	modul_size = list(BARREL_LARGE, CHAMBER_ALL, GRIP_ALL)

/obj/item/modular/accessory/optical/process()
	if((x_lock != user_parent.loc.x) || (y_lock != user_parent.loc.y))
		if(zoom)
			if(user_parent.client)
				user_parent.client.view = world.view
			if(user_parent.hud_used)
				user_parent.hud_used.show_hud(HUD_STYLE_STANDARD)
			zoom = FALSE
			STOP_PROCESSING(SSobj, src)

/obj/item/modular/accessory/optical/verb/zoom()
	set category = "Gun"
	set name = "Use Sniper Scope"
	set popup_menu = 0

	if(activated)
		if(usr.stat || !(istype(usr,/mob/living/carbon/human)))
			to_chat(user_parent, "You are unable to focus down the scope of the rifle.")
			return
		//if(!zoom && global_hud.darkMask[1] in usr.client.screen)
		//	usr << "Your welding equipment gets in the way of you looking down the scope"
		//	return
		if(!zoom && usr.get_active_hand() != parent)
			to_chat(usr, "You are too distracted to look down the scope, perhaps if it was in your active hand this might work better")
			return

		if(usr.client.view == world.view)
			if(usr.hud_used)
				usr.hud_used.show_hud(HUD_STYLE_REDUCED)
			usr.client.view = range
			x_lock = usr.loc.x
			y_lock = usr.loc.y
			zoom = TRUE
			START_PROCESSING(SSobj, src)
		else
			usr.client.view = world.view
			if(usr.hud_used)
				usr.hud_used.show_hud(HUD_STYLE_STANDARD)
			zoom = FALSE
		to_chat(usr, "<font color='[zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>")
	return

/obj/item/modular/accessory/optical/activate(mob/user)
	..()
	src.loc = user
	user_parent = user

/obj/item/modular/accessory/optical/deactivate(mob/user)
	..()
	if(zoom)
		if(user.client)
			user_parent.client.view = world.view
		if(user.hud_used)
			user_parent.hud_used.show_hud(HUD_STYLE_STANDARD)
		zoom = FALSE
	user_parent = null
	src.loc = parent

/obj/item/modular/accessory/silenser
	name = "silenser"
	icon_state = "silenser_icon"
	icon_overlay = "silenser"
	conflicts = list(/obj/item/modular/barrel/medium/bullet_pistol)
	attachment_point = BARREL
	modul_size = list(BARREL_SMALL, BARREL_MEDIUM, CHAMBER_ALL, GRIP_ALL)
	gun_type = list(BULLET)

/obj/item/modular/accessory/silenser/activate(mob/user)
	..()
	parent.silenced = TRUE
	activated = TRUE

/obj/item/modular/accessory/silenser/deactivate(mob/user)
	..()
	parent.silenced = FALSE
	activated = FALSE

/obj/item/modular/accessory/bayonet
	name = "bayonet"
	icon_state = "bayonet_icon"
	icon_overlay = "bayonet"
	gun_type = ALL_TYPE_MODULARGUN
	force = 10
	sharp = 1
	edge = 1
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	modul_size = list(BARREL_MEDIUM, CHAMBER_ALL, GRIP_ALL)
	attachment_point = BARREL
	conflicts = list()

/obj/item/modular/accessory/bayonet/activate(mob/user)
	..()
	parent.force += force

/obj/item/modular/accessory/bayonet/deactivate(mob/user)
	..()
	parent.force -= force

/obj/item/modular/accessory/additional_battery
	name = "Additional battery"
	icon_state = "additional_battery_icon"
	icon_overlay = "additional_battery"
	modul_size = list(BARREL_MEDIUM, BARREL_LARGE, CHAMBER_ALL, GRIP_ALL)
	gun_type = list(LASER)
	attachment_point = BARREL
	conflicts = list(/obj/item/modular/accessory/bayonet)
	var/add_max_charge = 10000

/obj/item/modular/accessory/additional_battery/activate(mob/user)
	..()
	if(parent)
		if(parent.power_supply)
			parent.power_supply.maxcharge += add_max_charge

/obj/item/modular/accessory/additional_battery/deactivate(mob/user)
	..()
	if(parent)
		if(parent.power_supply)
			parent.power_supply.maxcharge = parent.power_supply.start_maxcharge

/obj/item/modular/accessory/grenade_launcher
	name = "Grenade launcher"
	icon_state = "additional_battery_icon"
	icon_overlay = "additional_battery"
	modul_size = list(BARREL_MEDIUM, BARREL_LARGE, CHAMBER_ALL, GRIP_ALL)
	gun_type = ALL_TYPE_MODULARGUN
	attachment_point = BARREL
	conflicts = list(/obj/item/modular/accessory/bayonet)
	attacked = TRUE
	usering = TRUE
	var/max_grenades = 1
	var/list/grenades = list()

/obj/item/modular/accessory/grenade_launcher/attackby(obj/item/I, mob/user)
	.=..()
	if((istype(I, /obj/item/weapon/grenade)))
		if(grenades.len < max_grenades)
			user.drop_item()
			I.loc = src
			grenades += I
			to_chat(user, "\blue You put the grenade in the grenade launcher.")
			to_chat(user, "\blue [grenades.len] / [max_grenades] Grenades.")
		else
			to_chat(usr, "\red The grenade launcher cannot hold more grenades.")

/obj/item/modular/accessory/grenade_launcher/afterattack(obj/target, mob/user , flag)
	if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(grenades.len)
		spawn(0) fire_grenade(target,user)
	else
		to_chat(usr, "\red The grenade launcher is empty.")

/obj/item/modular/accessory/grenade_launcher/proc/fire_grenade(atom/target, mob/user)
	for(var/mob/O in viewers(world.view, user))
		O.show_message(text("\red [] fired a grenade!", user), 1)
	to_chat(user, "\red You fire the grenade launcher!")
	var/obj/item/weapon/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.loc = user.loc
	F.throw_at(target, 30, 2, user)
	message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from a grenade launcher ([src.name]). (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	log_game("[key_name_admin(user)] used a grenade ([src.name]).")
	F.active = TRUE
	F.icon_state = initial(F.icon_state) + "_active"
	playsound(user, 'sound/weapons/armbomb.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	spawn(15)
		F.prime()

/obj/item/modular/accessory/grenade_launcher/verb/activate_deactivate()
	set category = "Gun"
	set name = "Activate/deactivate grenade launcher"
	set popup_menu = 0

	if(activated)
		attacked = !attacked

/obj/item/modular/accessory/grenade_launcher/activate(mob/user)
	..()
	src.loc = user
	user_parent = user
	to_chat(usr, "Activate grenade launcher. Grenade loaded [grenades.len]")
/obj/item/modular/accessory/grenade_launcher/deactivate(mob/user)
	..()
	user_parent = null
	src.loc = parent
	to_chat(usr, "Deactivate grenade launcher. Grenade loaded [grenades.len]")

