/obj/item/modular/accessory
	name = "accessory"
	var/parent

/obj/item/modular/accessory/proc/deactivate()
	return

/obj/item/modular/accessory/optical
	name = "Optical"
	icon_state = "optical_icon"
	icon_overlay = "optical"
	var/range = 12
	var/zoom = FALSE

/obj/item/modular/accessory/optical/verb/zoom()
	set category = "Gun"
	set name = "Use Sniper Scope"
	set popup_menu = 0
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
		zoom = TRUE
	else
		usr.client.view = world.view
		if(usr.hud_used)
			usr.hud_used.show_hud(HUD_STYLE_STANDARD)
		zoom = FALSE
	to_chat(usr, "<font color='[zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>")
	return

/obj/item/modular/accessory/optical/deactivate(mob/user)
	if(zoom)
		if(user.client)
			user.client.view = world.view
		if(user.hud_used)
			user.hud_used.show_hud(HUD_STYLE_STANDARD)
		zoom = FALSE

