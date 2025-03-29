/mob/living/silicon/decoy/Life()
	if (src.stat == DEAD)
		return
	else
		if (src.health <= config.health_threshold_dead && src.stat != DEAD)
			death()
			return


/mob/living/silicon/decoy/updatehealth()
	health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
