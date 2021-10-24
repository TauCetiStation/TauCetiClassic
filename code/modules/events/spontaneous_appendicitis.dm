/datum/event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(human_list))
		if(!H.client || H.stat == DEAD || H.species.flags[VIRUS_IMMUNE])
			continue
		if(H.viruses.len) //don't infect someone that already has the virus
			continue

		var/datum/disease/D = new /datum/disease/appendicitis
		D.holder = H
		D.affected_mob = H
		H.viruses += D
		break
