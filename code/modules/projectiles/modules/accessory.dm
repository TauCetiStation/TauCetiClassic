/datum/action/gun_module_toggle
	name = "Toggle module"

/datum/action/gun_module_toggle/New(Target)
	..()
	if(istype(Target, /obj/item/weapon/modul_gun/accessory/action))
		var/obj/item/weapon/modul_gun/accessory/action/module = Target
		name = "[module.name]"

/datum/action/gun_module_toggle/Trigger()
	if(!Checks())
		return

	if(istype(target, /obj/item/weapon/modul_gun/accessory/action))
		var/obj/item/weapon/modul_gun/accessory/action/module = target
		if(module.parent)
			module.activate()

/obj/item/weapon/modul_gun/accessory
	name = "accessory"
	var/mob/user_parent = null

/obj/item/weapon/modul_gun/accessory/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	if(condition_check(gun))
		parent = gun
		gun.accessory.Add(src)
		gun.accessory_type.Add(src.type)
		src.loc = gun
		user_parent = gun.user_parent
		parent.overlays += icon_overlay
		change_stat(gun, TRUE)
	else
		return
/obj/item/weapon/modul_gun/accessory/eject(obj/item/weapon/gun_modular/gun)
	change_stat(gun, FALSE)
	parent = null
	user_parent = null
	gun.accessory.Remove(src)
	gun.accessory_type.Remove(src.type)
	src.loc = get_turf(gun.loc)

/obj/item/weapon/modul_gun/accessory/condition_check(obj/item/weapon/gun_modular/gun)
	if(gun.accessory.len < gun.max_accessory && !is_type_in_list(src, gun.accessory_type))
		return TRUE
	return FALSE
/obj/item/weapon/modul_gun/accessory/action
	name = "accessory action"
	var/attacked = TRUE
	var/attacked_self = TRUE
	var/active = FALSE

/obj/item/weapon/modul_gun/accessory/passive
	name = "accessory_passive"

/obj/item/weapon/modul_gun/accessory/action/proc/action_button(mob/user, obj/item/weapon/gun_modular/gun, var/attach)
	if(attach)
		var/datum/action/gun_module_toggle/action = new(src)
		action.Grant(user)
		user.update_action_buttons()
	else
		var/datum/action/gun_module_toggle/action = new(src)
		action.Remove(user)
		user.update_action_buttons()

/obj/item/weapon/modul_gun/accessory/action/attackby(obj/item/A, mob/user)
	if(!attacked)
		return

/obj/item/weapon/modul_gun/accessory/action/proc/activate()
	active = !active
	if(active)
		return TRUE
	else
		return FALSE

////////////////////////ACTION
/obj/item/weapon/modul_gun/accessory/action/optical
	name = "accessory optical action"
	icon_state = "optical_large_icon"
	icon_overlay = "optical_large"
	attacked = FALSE
	active = FALSE
	var/range = 12
	var/zoom = FALSE
	var/x_lock
	var/y_lock

/obj/item/weapon/modul_gun/accessory/action/optical/activate()
	if(.==..())
		parent.selected_module = src
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
	else
		if(user_parent.client)
			user_parent.client.view = world.view
		if(user_parent.hud_used)
			user_parent.hud_used.show_hud(HUD_STYLE_STANDARD)
		zoom = FALSE

/obj/item/weapon/modul_gun/accessory/action/optical/process()
	if((x_lock != user_parent.loc.x) || (y_lock != user_parent.loc.y))
		if(zoom)
			if(user_parent.client)
				user_parent.client.view = world.view
			if(user_parent.hud_used)
				user_parent.hud_used.show_hud(HUD_STYLE_STANDARD)
			zoom = FALSE
			STOP_PROCESSING(SSobj, src)