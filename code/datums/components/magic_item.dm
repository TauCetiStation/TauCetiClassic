#define MAGIC_TIP "Магическая вещь."

/datum/mechanic_tip/self_effect
	tip_name = MAGIC_TIP

/datum/mechanic_tip/self_effect/New(datum/component/C, _description)
	description = _description


/datum/component/magic_item
	var/description
	var/clothing_description

/datum/component/magic_item/Initialize()
	if(!isitem(parent) || !description)
		return COMPONENT_INCOMPATIBLE

	var/tip_desc = description
	if(istype(parent, /obj/item/clothing) && clothing_description)
		tip_desc = clothing_description

	var/datum/callback/can_callback = CALLBACK(src, PROC_REF(can_show_tip))

	var/datum/mechanic_tip/self_effect/effect_tip = new(src, tip_desc)
	parent.AddComponent(/datum/component/mechanic_desc, list(effect_tip), can_callback)

/datum/component/magic_item/proc/can_show_tip(obj/item/source, mob/user)
	return TRUE

/datum/component/magic_item/wizard
	description = "Вы можете колдовать, используя этот предмет."
	clothing_description = "Вы сможете колдовать, если вы наденете комплект таких вещей."

/datum/component/magic_item/wizard/can_show_tip(obj/item/source, mob/user)
	return iswizard(user) || iswizardapprentice(user)

#undef MAGIC_TIP
