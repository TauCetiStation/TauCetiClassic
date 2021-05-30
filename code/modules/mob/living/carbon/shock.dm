/mob/living/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	src.traumatic_shock = 			\
	1	* src.getOxyLoss() + 		\
	0.7	* src.getToxLoss() + 		\
	1.5	* src.getFireLoss() + 		\
	1.2	* src.getBruteLoss() + 		\
	1.7	* src.getCloneLoss() + 		\
	2	* src.halloss

	if(reagents.has_reagent("alkysine"))
		src.traumatic_shock -= 10
	if(reagents.has_reagent("dextromethorphan"))
		src.traumatic_shock -= 10
	if(reagents.has_reagent("inaprovaline"))
		src.traumatic_shock -= 25
	if(reagents.has_reagent("synaptizine"))
		src.traumatic_shock -= 40
	if(reagents.has_reagent("paracetamol"))
		src.traumatic_shock -= 50
	if(reagents.has_reagent("tramadol"))
		src.traumatic_shock -= 80
	if(reagents.has_reagent("oxycodone"))
		src.traumatic_shock -= 200
	if(src.slurring)
		src.traumatic_shock -= 20
	if(src.analgesic)
		src.traumatic_shock = 0

	// broken or ripped off bodyparts will add quite a bit of pain
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		for(var/obj/item/organ/external/BP in M.bodyparts)
			if(BP.is_stump)
				src.traumatic_shock += 60
			else if((BP.status & ORGAN_BROKEN) || BP.open)
				src.traumatic_shock += 30
				if(BP.status & ORGAN_SPLINTED)
					src.traumatic_shock -= 25

	if(src.traumatic_shock < 0)
		src.traumatic_shock = 0

	play_pain_sound()

	return src.traumatic_shock

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
		emote(pain_sound_name, auto = TRUE)
		last_pain_emote_sound = world.time + (HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) ? rand(15 SECONDS, 30 SECONDS) : rand(30 SECONDS, 60 SECONDS))
		if(pain_sound_name == "scream") // don't cry out in pain too often
			last_pain_emote_sound += (HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) ? rand(5 SECONDS, 10 SECONDS) : rand(10 SECONDS, 20 SECONDS))
