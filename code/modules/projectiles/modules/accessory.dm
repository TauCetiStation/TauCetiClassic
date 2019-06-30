/obj/item/modular/accessory
	name = "accessory"
	var/obj/item/weapon/gun/projectile/modulargun/parent
	var/activated
	var/fixation = TRUE
	var/list/barrel_size = BARREL_ALL

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
	var/uloc
	gun_type = list("laser", "bullet")
	barrel_size = BARREL_ALL

/obj/item/modular/accessory/optical/small
	name = "small optical"
	icon_state = "optical_small_icon"
	icon_overlay = "optical_small"
	range = 9
	zoom = FALSE
	lessdamage = 0
	lessdispersion = -0.1
	lessfiredelay= 0
	lessrecoil = 0
	size = 0.1
	gun_type = list("laser", "bullet")
	barrel_size = BARREL_ALL

/obj/item/modular/accessory/optical/medium
	name = "medium optical"
	icon_state = "optical_medium_icon"
	icon_overlay = "optical_medium"
	range = 12
	zoom = FALSE
	lessdamage = 0
	lessdispersion = -0.2
	lessfiredelay= 0
	lessrecoil = 0
	size = 0.2
	gun_type = list("laser", "bullet")
	barrel_size = list(BARREL_MEDIUM, BARREL_LARGE)

/obj/item/modular/accessory/optical/large
	name = "large optical"
	icon_state = "optical_large_icon"
	icon_overlay = "optical_large"
	range = 16
	zoom = FALSE
	lessdamage = 0
	lessdispersion = -0.4
	lessfiredelay= 0
	lessrecoil = 0
	size = 0.4
	gun_type = list("laser", "bullet")
	barrel_size = list(BARREL_LARGE)

/obj/item/modular/accessory/optical/process()
	if(uloc != src.locs)
		zoom()

/obj/item/modular/accessory/optical/verb/zoom()
	set category = "Gun"
	set name = "Use Sniper Scope"
	set popup_menu = 0

	uloc = src.locs
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
			START_PROCESSING(SSobj, src)
		else
			usr.client.view = world.view
			if(usr.hud_used)
				usr.hud_used.show_hud(HUD_STYLE_STANDARD)
			zoom = FALSE
			STOP_PROCESSING(SSobj, src)
		to_chat(usr, "<font color='[zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>")
	return

/obj/item/modular/accessory/optical/activate(mob/user)
	..()
	src.loc = user
	uloc = src.locs
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
	barrel_size = list(BARREL_MEDIUM)

/obj/item/modular/accessory/bayonet/activate(mob/user)
	..()
	parent.force += force
	activated = TRUE

/obj/item/modular/accessory/bayonet/deactivate(mob/user)
	..()
	parent.force -= force
	activated = FALSE
