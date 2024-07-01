/datum/component/weapon_ammo_bar/Initialize()
	RegisterSignal(parent, list(COMSIG_ITEM_BECOME_ACTIVE, COMSIG_ITEM_BECOME_INACTIVE, COSMIG_GUN_AMMO_CHANGED, COMSIG_PARENT_QDELETING, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(on_signal))

/datum/component/weapon_ammo_bar/proc/on_destroyed()
	qdel(src)

/datum/component/weapon_ammo_bar/Destroy()
	UnregisterSignal(parent, list(COMSIG_ITEM_BECOME_ACTIVE, COMSIG_ITEM_BECOME_INACTIVE, COSMIG_GUN_AMMO_CHANGED, COMSIG_PARENT_QDELETING, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	return ..()

/datum/component/weapon_ammo_bar/proc/on_signal(_, mob/user)
	SIGNAL_HANDLER
	if(ismob(user))
		update_ammo_hud(user)
	else
		var/obj/item/parent_item = parent
		if(istype(parent_item) && ismob(parent_item.loc))
			update_ammo_hud(parent_item.loc)

/datum/component/weapon_ammo_bar/proc/update_ammo_hud(mob/user)
	if(user && user.ammo_hud)
		user.ammo_hud.update_icon(user)


