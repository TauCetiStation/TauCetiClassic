/obj/item/modular/accessory
	name = "accessory"
	var/obj/item/weapon/gun/projectile/modulargun/parent
	var/activated
	var/fixation = TRUE

/obj/item/modular/accessory/proc/deactivate()
	if(fixation)
		return

/obj/item/modular/accessory/proc/activate()
	if(fixation)
		return

/obj/item/modular/accessory/optical
	name = "optical"
	icon_state = "optical_icon"
	icon_overlay = "optical"
	var/range = 12
	var/zoom = FALSE
	gun_type = list("laser", "bullet")

/obj/item/modular/accessory/optical/verb/zoom()
	set category = "Gun"
	set name = "Use Sniper Scope"
	set popup_menu = 0
	if(activated)
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

/obj/item/modular/accessory/optical/activate(mob/user)
	..()
	src.loc = user
	activated = TRUE

/obj/item/modular/accessory/optical/deactivate(mob/user)
	..()
	if(zoom)
		if(user.client)
			user.client.view = world.view
		if(user.hud_used)
			user.hud_used.show_hud(HUD_STYLE_STANDARD)
		zoom = FALSE
	activated = FALSE
	src.loc = parent

/obj/item/modular/accessory/silenser
	name = "silenser"
	icon_state = "silenser_icon"
	icon_overlay = "silenser"
	gun_type = list("bullet")

/obj/item/modular/accessory/silenser/activate(mob/user)
	..()
	parent.silenced = TRUE
	activated = TRUE

/obj/item/modular/accessory/silenser/deactivate(mob/user)
	..()
	parent.silenced = FALSE
	activated = FALSE

