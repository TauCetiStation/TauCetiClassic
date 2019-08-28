/obj/item/weapon/gun_module/accessory
	name = "gun accessory"
	icon_state = "additional_battery"
	icon_overlay = "additional_battery_icon"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	attackbying = CONTINUED
	attackself = INTERRUPT

/obj/item/weapon/gun_module/accessory/attach(obj/item/weapon/gunmodule/gun)
	if(..(gun, condition_check(gun)))
		LAZYADD(parent.accessory, src)
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/accessory/condition_check(obj/item/weapon/gunmodule/gun)
	if(gun.chamber && !gun.collected && LAZYLEN(gun.accessory) < gun.max_accessory)
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/accessory/eject(obj/item/weapon/gunmodule/gun)
	LAZYREMOVE(parent.accessory, src)
	..()

/obj/item/weapon/gun_module/accessory/proc/deactivate(mob/user)
	return

/obj/item/weapon/gun_module/accessory/optical
	name = "gun optical"
	icon_state = "optical_large_icon"
	icon_overlay = "optical_large"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	attackbying = IGNORING
	attackself = IGNORING
	var/zoom = FALSE
	var/range = 20
	var/x_lock
	var/y_lock

/obj/item/weapon/gun_module/accessory/optical/verb/use_optical()
	set category = "Gun"
	set name = "Use Optical"

	if(usr.stat || !(istype(usr,/mob/living/carbon/human)))
		to_chat(usr, "You are unable to focus down the scope of the rifle.")
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
		START_PROCESSING(SSobj, src)
		zoom = TRUE
	else
		usr.client.view = world.view
		if(usr.hud_used)
			usr.hud_used.show_hud(HUD_STYLE_STANDARD)
		STOP_PROCESSING(SSobj, src)
		zoom = FALSE
		x_lock = null
		y_lock = null
	to_chat(usr, "<font color='[zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>")
	return

/obj/item/weapon/gun_module/accessory/optical/process()
	if((usr.loc.x != x_lock || usr.loc.y != y_lock) || usr.get_active_hand() != parent)
		if(usr.client)
			usr.client.view = world.view
		if(usr.hud_used)
			usr.hud_used.show_hud(HUD_STYLE_STANDARD)
		zoom = FALSE
		x_lock = null
		y_lock = null
		STOP_PROCESSING(SSobj, src)

/obj/item/weapon/gun_module/accessory/optical/deactivate(mob/user)
	if(zoom)
		if(user.client)
			user.client.view = world.view
		if(user.hud_used)
			user.hud_used.show_hud(HUD_STYLE_STANDARD)
		zoom = FALSE
		STOP_PROCESSING(SSobj, src)