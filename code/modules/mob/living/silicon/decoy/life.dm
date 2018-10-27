/mob/living/silicon/decoy/Life()
	if (src.stat == DEAD)
		return
	else
		if (src.health <= src.health_threshold_dead && src.stat != DEAD)
			death()
			return


/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
