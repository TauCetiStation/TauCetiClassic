/datum/event/viral_infection
	var/infected = 2
	var/chance = 33

/datum/event/viral_infection/setup()
	announceWhen = rand(0, 300)
	endWhen = announceWhen + 1
	infected = severity * rand(1, 2)
	chance = (severity - 1) * 33

/datum/event/viral_infection/announce()
	command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", "outbreak5")

/datum/event/viral_infection/start()
	for(var/mob/living/carbon/human/H in shuffle(human_list))
		if(!infected)
			break
		if(!H.client || H.stat == DEAD || H.species.flags[VIRUS_IMMUNE])
			continue
		if(prob(chance))
			infect_mob_random_greater(H)
		else
			infect_mob_random_lesser(H)
		infected--
