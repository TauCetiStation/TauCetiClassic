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
		if(module.parent && !active)
			module.activate()
		else
			module.deactivate()

/obj/item/weapon/modul_gun/accessory
	name = "accessory"
	var/mob/user_parent = null

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
	active = FALSE
/obj/item/weapon/modul_gun/accessory/action/proc/deactivate()
	active = TRUE
////////////////////////ACTION
