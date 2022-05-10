#define MAGIC_TIP "Магическая вещь."

/datum/mechanic_tip/self_effect
	tip_name = MAGIC_TIP

/datum/mechanic_tip/self_effect/New(datum/component/C, _description)
	description = _description


/datum/component/magic_item
	var/group

/datum/component/magic_item/Initialize(_group)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	group = _group


	var/description
	var/datum/callback/can_callback
	switch(group)
		if(WIZARD_ITEM)
			can_callback = CALLBACK(src, .proc/is_wizard)
			if(istype(parent, /obj/item/clothing))
				description = "Вы сможете колдовать, если вы наденете комплект таких вещей."
			else
				description = "Вы можете колдовать, используя этот предмет."

	var/datum/mechanic_tip/self_effect/effect_tip = new(src, description)
	parent.AddComponent(/datum/component/mechanic_desc, list(effect_tip), can_callback)

/datum/component/magic_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MAGIC_ITEM_CAN_USE, .proc/can_use_item)

/datum/component/magic_item/proc/can_use_item(obj/item/source, group_to_check)
	if(group != group_to_check)
		return COMPONENT_BLOCK_MAGIC_ITEM
	return COMPONENT_ALLOW_MAGIC_ITEM

/datum/component/magic_item/Destroy()
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(MAGIC_TIP))
	return ..()


// WIZARD_ITEM
/datum/component/magic_item/proc/is_wizard(obj/item/source, mob/user)
	return iswizard(user) || iswizardapprentice(user)

#undef MAGIC_TIP
