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
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)
		return
	candidates = shuffle(candidates)//Incorporating Donkie's list shuffle

	while(infected > 0 && candidates.len)
		if(prob(chance))
			infect_mob_random_greater(candidates[1])
			to_chat(world, "greater[chance]")
		else
			infect_mob_random_lesser(candidates[1])
			to_chat(world, "lesser[chance]")

		candidates.Remove(candidates[1])
		infected--
