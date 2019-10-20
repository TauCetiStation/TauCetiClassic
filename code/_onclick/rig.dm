/mob/proc/HardsuitClickOn(atom/A)
	if(!ishuman(src) || next_move >= world.time)
		return FALSE
	var/mob/living/carbon/human/H = src
	var/obj/item/clothing/suit/space/rig/rig = H.wear_suit
	if(istype(rig) && !rig.offline && rig.selected_module)
		rig.selected_module.engage(A)
		if(ismob(A)) // No instant mob attacking - though modules have their own cooldowns
			next_click = world.time + 1
		return TRUE
	return FALSE
