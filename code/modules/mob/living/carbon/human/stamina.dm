/mob/living/carbon/human/proc/handle_stamina()
	if(isnull(maxStamina))
		return
	if(HAS_TRAIT(src, TRAIT_NOSTAMINAREGEN))
		return
	adjustStamina(stamina_regen)

/mob/living/carbon/proc/handle_stamina_bar()
	if(!hud_used || !hud_used.staminadisplay)
		return
	if(isnull(maxStamina))
		hud_used.staminadisplay.invisibility = 101
		return

	if(getStamina() <= 0)
		hud_used.staminadisplay.icon_state = "stam_bar_0"
		return
	hud_used.staminadisplay.icon_state = "stam_bar_[round((getStamina() / maxStamina) * 100, 5)]"
