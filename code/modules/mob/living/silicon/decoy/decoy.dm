/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/AI.dmi'//
	icon_state = "ai"
	anchored = 1 // -- TLE
	canmove = 0
	hud_list = list()

/mob/living/silicon/decoy/atom_init()
	. = ..()
	silicon_list -= src //because fake ai break round end statistics
	for(var/datum/atom_hud/hud in global.huds)
		hud.remove_hud_from(src)
		hud.remove_from_hud(src)

/mob/living/silicon/decoy/prepare_huds()
	return

/mob/living/silicon/decoy/diag_hud_set_status()
	return

/mob/living/silicon/decoy/diag_hud_set_health()
	return
