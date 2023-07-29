/datum/element/satchel_slowdown
	element_flags = ELEMENT_DETACH

/datum/element/satchel_slowdown/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_SLOWDOWN_HUMAN, PROC_REF(slowdown_user))

/datum/element/satchel_slowdown/proc/is_armorsuit_weared(list/slots_list)
	. = FALSE
	for(var/i in slots_list)
		if(istype(i, /obj/item/clothing/suit/armor/riot))
			. = TRUE
			break
		if(istype(i, /obj/item/clothing/suit/armor/hos))
			. = TRUE
			break
		if(istype(i, /obj/item/clothing/suit/storage/flak))
			. = TRUE
			break

/datum/element/satchel_slowdown/proc/slowdown_user(datum/source, list/reflist)
	SIGNAL_HANDLER
	if(is_armorsuit_weared(reflist[2]))
		reflist[1] += 0.5

/datum/element/satchel_slowdown/Detach(datum/source)
	UnregisterSignal(source, COMSIG_SLOWDOWN_HUMAN)
	return ..()
