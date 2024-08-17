/mob/living/carbon
	var/traumatic_shock = 0
	var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	traumatic_shock = 			\
	1	* getOxyLoss() + 		\
	0.7	* getToxLoss() + 		\
	1.5	* getFireLoss() + 		\
	1.2	* getBruteLoss() + 		\
	1.7	* getCloneLoss() + 		\
	2	* halloss

	var/painkiller_effectiveness = 1.0
	if(reagents.has_reagent("prismaline"))
		painkiller_effectiveness = 0.3

	if(reagents.has_reagent("alkysine"))
		traumatic_shock -= 10 * painkiller_effectiveness
		shock_stage -= 1 * painkiller_effectiveness
	if(reagents.has_reagent("dextromethorphan"))
		traumatic_shock -= 10 * painkiller_effectiveness
		shock_stage -= 1 * painkiller_effectiveness
	if(reagents.has_reagent("jenkem"))
		traumatic_shock -= 15 * painkiller_effectiveness
		shock_stage -= 1.5 * painkiller_effectiveness
	if(reagents.has_reagent("inaprovaline"))
		traumatic_shock -= 25 * painkiller_effectiveness
		shock_stage -= 2.5 * painkiller_effectiveness
	if(reagents.has_reagent("ambrosium"))
		traumatic_shock -= 30 * painkiller_effectiveness
		shock_stage -= 3 * painkiller_effectiveness
	if(reagents.has_reagent("synaptizine"))
		traumatic_shock -= 40 * painkiller_effectiveness
		shock_stage -= 4 * painkiller_effectiveness
	if(reagents.has_reagent("paracetamol"))
		traumatic_shock -= 50 * painkiller_effectiveness
		shock_stage -= 5 * painkiller_effectiveness
	if(reagents.has_reagent("space_drugs"))
		traumatic_shock -= 60 * painkiller_effectiveness
		shock_stage -= 6 * painkiller_effectiveness
	if(reagents.has_reagent("tramadol") || reagents.has_reagent("endorphine"))
		traumatic_shock -= 80 * painkiller_effectiveness
		shock_stage -= 8 * painkiller_effectiveness
	if(reagents.has_reagent("oxycodone"))
		traumatic_shock -= 200 * painkiller_effectiveness
		shock_stage -= 20 * painkiller_effectiveness
	if(slurring && drunkenness > DRUNKENNESS_SLUR)
		traumatic_shock -= min(drunkenness - DRUNKENNESS_SLUR, 40)
		shock_stage -= min(drunkenness - DRUNKENNESS_SLUR, 40)
	if(analgesic && !reagents.has_reagent("prismaline"))
		traumatic_shock = 0
		shock_stage = 0

	// broken or ripped off bodyparts will add quite a bit of pain
	if(ishuman(src))
		var/mob/living/carbon/human/M = src
		for(var/obj/item/organ/external/BP in M.bodyparts)
			if(BP.is_stump)
				traumatic_shock += 60
			else if((BP.status & ORGAN_BROKEN) || BP.open)
				traumatic_shock += 30
				if(BP.status & ORGAN_SPLINTED)
					traumatic_shock -= 25

	if(traumatic_shock < 0)
		traumatic_shock = 0

	play_pain_sound()

	return traumatic_shock

/mob/living/carbon/human/updateshock()
	if (species && species.flags[NO_PAIN])
		return
	..()

/mob/living/carbon/proc/handle_shock()
	updateshock()

/mob/living/carbon/proc/play_pain_sound()
	return

/mob/living/carbon/human/play_pain_sound()
	if(stat != CONSCIOUS)
		return
	if(last_pain_emote_sound > world.time)
		return
	if(species.flags[NO_PAIN] || species.flags[IS_SYNTHETIC])
		return
	if(time_of_last_damage + 15 SECONDS > world.time) // don't cry from the pain that just came
		return

	var/pain_sound_name
	var/current_health = round(100 - (traumatic_shock - (getOxyLoss() + 0.7 * getToxLoss()))) // don't consider suffocation and toxins
	switch(current_health)
		if(80 to 99)
			if(HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) && prob(20))
				pain_sound_name = "groan"
		if(40 to 80)
			if(!HAS_TRAIT(src, TRAIT_HIGH_PAIN_THRESHOLD) && prob(110 - current_health))
				pain_sound_name = "groan"
		if(10 to 39)
			if(HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) && prob(80 - current_health))
				pain_sound_name = "scream"
			if(!HAS_TRAIT(src, TRAIT_HIGH_PAIN_THRESHOLD) || !prob(current_health))
				pain_sound_name = "groan"
		if(-INFINITY to 9)
			if(HAS_TRAIT(src, TRAIT_HIGH_PAIN_THRESHOLD) && prob(25))
				pain_sound_name = "groan"
			else
				pain_sound_name = "scream"
	if(pain_sound_name)
		emote(pain_sound_name)
		last_pain_emote_sound = world.time + (HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) ? rand(15 SECONDS, 30 SECONDS) : rand(30 SECONDS, 60 SECONDS))
		if(pain_sound_name == "scream") // don't cry out in pain too often
			last_pain_emote_sound += (HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) ? rand(5 SECONDS, 10 SECONDS) : rand(10 SECONDS, 20 SECONDS))
