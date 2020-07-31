/datum/event/organ_failure

/datum/event/organ_failure/setup()
	announceWhen = rand(0, 300)
	endWhen = announceWhen + 1
	severity = rand(1, 3)

/datum/event/organ_failure/announce()
	command_alert("Confirmed outbreak of level [rand(3,7)] biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", "outbreak7")

/datum/event/organ_failure/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in player_list)
		if(G.mind && G.mind.current && G.mind.current.stat != DEAD && G.health > 70 && G.organs)
			candidates += G
	if(!candidates.len)	return
	candidates = shuffle(candidates)//Incorporating Donkie's list shuffle

	while(severity > 0 && candidates.len)
		var/mob/living/carbon/human/C = candidates[1]

		var/acute = prob(15)
		if (prob(75))
			//internal organ infection
			var/obj/item/organ/internal/IO = pick(C.organs)

			if (acute)
				IO.germ_level = max(INFECTION_LEVEL_TWO, IO.germ_level)
			else
				IO.germ_level = max(rand(INFECTION_LEVEL_ONE,INFECTION_LEVEL_ONE*2), IO.germ_level)
		else
			//external organ infection
			var/obj/item/organ/external/BP = pick(C.bodyparts)

			if (acute)
				BP.germ_level = max(INFECTION_LEVEL_TWO, BP.germ_level)
			else
				BP.germ_level = max(rand(INFECTION_LEVEL_ONE,INFECTION_LEVEL_ONE*2), BP.germ_level)

			C.bad_bodyparts |= BP

		severity--
