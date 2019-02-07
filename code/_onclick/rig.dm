/mob/living/MiddleClickOn(atom/A)
	if(client && client.prefs.hardsuit_activation == HARDSUIT_ACTIVATION_MIDDLE_CLICK)
		if(HardsuitClickOn(A))
			return TRUE
	..()

/mob/living/AltClickOn(atom/A)
	if(client && client.prefs.hardsuit_activation == HARDSUIT_ACTIVATION_ALT_CLICK)
		if(HardsuitClickOn(A))
			return TRUE
	..()

/mob/living/CtrlClickOn(atom/A)
	if(client && client.prefs.hardsuit_activation == HARDSUIT_ACTIVATION_CTRL_CLICK)
		if(HardsuitClickOn(A))
			return TRUE
	..()

/mob/living/CtrlShiftClickOn(atom/A)
	if(client && client.prefs.hardsuit_activation == HARDSUIT_ACTIVATION_CTRL_SHIFT_CLICK)
		if(HardsuitClickOn(A))
			return TRUE
	..()

/atom/proc/get_rig()
	return null

/obj/item/clothing/suit/space/rig/get_rig()
	return src

/mob/living/carbon/human/get_rig()
	return wear_suit

/mob/living/proc/can_use_rig()
	return 0

/mob/living/carbon/human/can_use_rig()
	return 1

/mob/living/proc/HardsuitClickOn(var/atom/A)
	if(!can_use_rig() || next_move >= world.time)
		return 0
	var/obj/item/clothing/suit/space/rig/rig = get_rig()
	if(istype(rig) && !rig.offline && rig.selected_module)
		rig.selected_module.engage(A)
		if(ismob(A)) // No instant mob attacking - though modules have their own cooldowns
			next_click = world.time + 1
		return 1
	return 0