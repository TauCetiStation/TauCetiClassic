/mob/living/proc/handle_stamina()
	if(isnull(maxStamina))
		return
	if(stat == DEAD)
		setStamina(minStamina)
		return	
	if(HAS_TRAIT(src, TRAIT_NOSTAMINAREGEN))
		return
	adjustStamina(stamina_regen)

/mob/living/proc/update_stamina_bar()
	if(!hud_used || !hud_used.staminadisplay)
		return
	if(isnull(maxStamina))
		//hud_used.staminadisplay.invisibility = 101
		return
	if(getStamina() == maxStamina)
		hud_used.staminadisplay.invisibility = 101
		return
	else
		hud_used.staminadisplay.invisibility = initial(hud_used.staminadisplay.invisibility)
	hud_used.staminadisplay.icon_state = "stam_bar_[round((getStamina() / maxStamina) * 100, 5)]"
