/datum/component/tactical
	var/allowed_slot
	var/override // Allows you to hide the previous image

/datum/component/tactical/Initialize(allowed_slot, override)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_slot = allowed_slot
	src.override = override

/datum/component/tactical/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(modify))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(unmodify))

/datum/component/tactical/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	unmodify()

/datum/component/tactical/Destroy()
	unmodify()
	return ..()

/datum/component/tactical/proc/modify(obj/item/source, mob/user, slot)
	if(allowed_slot && slot != allowed_slot)
		unmodify()
		return

	var/obj/item/master = parent
	var/image/I = image(icon = master.icon, icon_state = master.icon_state, loc = user)
	I.copy_overlays(master)
	I.override = override
	source.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "tactical_component", I)
	I.layer = INFRONT_MOB_LAYER

/datum/component/tactical/proc/unmodify(obj/item/source, mob/user)
	var/obj/item/master = source || parent
	if(!user)
		if(!ismob(master.loc))
			return
		user = master.loc

	user.remove_alt_appearance("tactical_component")
