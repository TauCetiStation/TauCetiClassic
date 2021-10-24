/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/AI.dmi'//
	icon_state = "ai"
	anchored = TRUE // -- TLE
	canmove = 0
	hud_possible = null

/mob/living/silicon/decoy/atom_init()
	. = ..()
	silicon_list -= src //because fake ai break round end statistics

/mob/living/silicon/decoy/prepare_huds()
	return

/mob/living/silicon/decoy/diag_hud_set_status()
	return

/mob/living/silicon/decoy/diag_hud_set_health()
	return
