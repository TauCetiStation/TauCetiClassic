/mob/living/carbon
	var/traumatic_shock = 0
	var/painkiller_overlay_time = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	traumatic_shock = 			\
	0.5	* getToxLoss() + 		\
	1.5	* getFireLoss() + 		\
	1.0	* getBruteLoss() + 		\
	1.0	* getCloneLoss() + 		\
	1.0	* halloss

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

	traumatic_shock *= get_painkiller_effect()

	if(traumatic_shock < 0)
		traumatic_shock = 0
	if(painkiller_overlay_time > 0)
		painkiller_overlay_time--

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
	var/current_health = round(100 - traumatic_shock)
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

/mob/living/carbon/proc/painkiller_byeffect(chance, yawn_chance)
	if(stat != CONSCIOUS)
		return
	if(traumatic_shock >= TRAUMATIC_SHOCK_MINOR)
		return
	if(!prob(chance))
		return
	adjustBlurriness(3)
	painkiller_overlay_time += 3
	to_chat(src, "<span class='italics'>[pick("Вы невольно закрываете глаза.", "Вы чувствуете себя подавленным.", "Вы чувствуете себя расслабленным.", "Вы чувствуете себя размякшим.", "Вы ощущаете сонливость.", "Вы чувствуете себя уставшим.", "Вы чувствуете, как силы покидают вас.", "Вам сложно держаться на ногах.")]</span>")
	if(dizziness <= 5)
		make_dizzy(150)
	if(prob(yawn_chance))
		emote("yawn")

/mob/living/carbon/proc/get_painkiller_effect()
	var/painkiller_effect = 1.0
	var/painkiller_multiplier = 1.0
	if(reagents.has_reagent("prismaline"))
		painkiller_multiplier = 3

	if(reagents.has_reagent("stimulants"))
		painkiller_effect *= min(0.1 * painkiller_multiplier, 1)
	else if(reagents.has_reagent("oxycodone"))
		painkiller_effect *= min(0.3 * painkiller_multiplier, 1)
	else if(reagents.has_reagent("tramadol") || reagents.has_reagent("endorphine"))
		painkiller_effect *= min(0.5 * painkiller_multiplier, 1)
	else if(druggy)
		painkiller_effect *= min(0.6 * painkiller_multiplier, 1)
	else if(reagents.has_reagent("paracetamol") || reagents.has_reagent("synaptizine"))
		painkiller_effect *= min(0.75 * painkiller_multiplier, 1)
	else if(reagents.has_reagent("inaprovaline"))
		painkiller_effect *= min(0.8 * painkiller_multiplier, 1)
	if(slurring && drunkenness > DRUNKENNESS_SLUR)
		painkiller_effect *= min((DRUNKENNESS_PASS_OUT - drunkenness) / 1000, 1)
	if(analgesic && !reagents.has_reagent("prismaline"))
		painkiller_effect = 0

	return painkiller_effect
