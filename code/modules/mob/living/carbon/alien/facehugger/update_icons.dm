/mob/living/carbon/alien/facehugger/regenerate_icons()
	overlays = list()
	update_inv_r_hand(0)
	update_hud()
	update_icons()

/mob/living/carbon/alien/facehugger/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(stat == DEAD)
		icon_state = "facehugger_dead"
	else if(lying || resting)
		icon_state = "facehugger_inactive"
	else
		icon_state = "facehugger"

/mob/living/carbon/alien/facehugger/update_hud()
	//TODO
	if (client)
//		if(other)	client.screen |= hud_used.other		//Not used
//		else		client.screen -= hud_used.other		//Not used
		client.screen |= contents

/*----------------------------------------
Proc: RefreshInfectionImage()
Des: Removes all infection images from aliens and places an infection image on all infected mobs for aliens.
----------------------------------------*/
/obj/item/alien_embryo/proc/RefreshInfectionImage()
	for(var/mob/living/carbon/alien/alien in player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected"))
					qdel(I)
			for(var/mob/living/L in mob_list)
				if(iscorgi(L) || iscarbon(L))
					if(L.status_flags & XENO_HOST)
						var/I = image('icons/mob/alien.dmi', loc = L, icon_state = "infected[stage]")
						alien.client.images += I

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Checks if the passed mob (C) is infected with the alien egg, then gives each alien client an infected image at C.
----------------------------------------*/
/obj/item/alien_embryo/proc/AddInfectionImages(mob/living/C)
	if(C)
		for(var/mob/living/carbon/alien/alien in player_list)
			if(alien.client)
				if(C.status_flags & XENO_HOST)
					var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected[stage]")
					alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes the alien infection image from all aliens in the world located in passed mob (C).
----------------------------------------*/

/obj/item/alien_embryo/proc/RemoveInfectionImages(mob/living/C)
	if(C)
		for(var/mob/living/carbon/alien/alien in player_list)
			if(alien.client)
				for(var/image/I in alien.client.images)
					if(I.loc == C)
						if(dd_hasprefix_case(I.icon_state, "infected"))
							qdel(I)
