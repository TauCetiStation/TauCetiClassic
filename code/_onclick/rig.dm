/mob/living/carbon/human/RegularClickOn(atom/A)
	if(..())
		return TRUE
	if(next_move >= world.time)
		return FALSE
	var/obj/item/clothing/suit/space/rig/rig = wear_suit
	if(!(istype(rig) && rig.selected_module) || rig.offline)
		return FALSE
	rig.selected_module.engage(A)
	if(ismob(A)) // No instant mob attacking - though modules have their own cooldowns
		SetNextMove(CLICK_CD_RAPID)
	return TRUE
