/datum/component/autopickup_bag
	var/list/autopickup
	var/mob/wearer

/datum/component/autopickup_bag/Initialize()
	if (!istype(parent, /obj/item/weapon/storage/bag))
		return COMPONENT_INCOMPATIBLE

	autopickup = typecacheof(list(/obj/item/weapon/ore))

/datum/component/autopickup_bag/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	if isrobot(usr)
		wearer = usr
		RegisterSignal(wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_equipper_moved))

/datum/component/autopickup_bag/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED
	))
	if isrobot(wearer)
		UnregisterSignal(wearer, COMSIG_MOVABLE_MOVED)

/datum/component/autopickup_bag/proc/on_equipped(obj/item/weapon/storage/bag/B, mob/equipper, slot)
	SIGNAL_HANDLER
	if (wearer)
		return
	RegisterSignal(equipper, COMSIG_MOVABLE_MOVED, PROC_REF(on_equipper_moved))
	wearer = equipper

/datum/component/autopickup_bag/proc/on_dropped(obj/item/weapon/storage/bag/B, mob/dropper)
	SIGNAL_HANDLER
	if (!wearer)
		return
	UnregisterSignal(wearer, COMSIG_MOVABLE_MOVED)
	wearer = null

/datum/component/autopickup_bag/proc/on_equipper_moved(mob/living/user, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	var/turf/tile = get_turf(user)
	if (!isturf(tile))
		return

	INVOKE_ASYNC(src, PROC_REF(handle_move), user, tile)

/datum/component/autopickup_bag/proc/handle_move(mob/living/user, turf/tile)
	if (user.stat != CONSCIOUS || user.restrained())
		return

	for(var/atom/thing as anything in tile)
		if(!is_type_in_typecache(thing, autopickup))
			continue
		pickup_all_ore(thing, user)
		break

/datum/component/autopickup_bag/proc/pickup_all_ore(obj/item/weapon/ore/O, mob/user)
	var/obj/item/weapon/storage/bag/B = parent
	O.attackby(B, user)

/datum/component/autopickup_bag/Destroy()
	if (wearer)
		UnregisterSignal(wearer, COMSIG_MOVABLE_MOVED)
		wearer = null
	return ..()
