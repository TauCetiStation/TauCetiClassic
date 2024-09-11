// admins gib the mafia players and break all CODE
/mob/living/carbon/human/mafia
	name = "Mafia-Immortal Human"
	status_flags = GODMODE
	health = 50000
	universal_understand = TRUE

/mob/living/carbon/human/mafia/gib()
	return

/mob/living/carbon/human/mafia/dust()
	return

/mob/living/carbon/human/mafia/attack_hand(mob/living/carbon/human/attacker)
	return

/mob/living/carbon/human/mafia/attackby(obj/item/I, mob/user, params)
	return

// This is copypaste of death proc of human, but only necessary ones are left
/mob/living/carbon/human/mafia/death()
	SEND_SIGNAL(src, COMSIG_MOB_DIED)
	INVOKE_ASYNC(src, PROC_REF(emote), "deathgasp")
	stat = DEAD
	dizziness = 0
	jitteriness = 0
	med_hud_set_health()
	med_hud_set_status()
	update_canmove()
	drop_r_hand()
	drop_l_hand()
	alive_mob_list -= src
	dead_mob_list += src
	clear_fullscreens()
