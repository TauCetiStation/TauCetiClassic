/mob/living/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	if (!can_feel_pain())
		src.traumatic_shock = 0
		return 0

	src.traumatic_shock = 			\
	1	* src.getOxyLoss() + 		\
	0.7	* src.getToxLoss() + 		\
	1.5	* src.getFireLoss() + 		\
	1.2	* src.getBruteLoss() + 		\
	1.7	* src.getCloneLoss() + 		\
	2	* src.halloss

	if(reagents.has_reagent("alkysine"))
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
		for(var/obj/item/bodypart/BP in M.bodyparts)
			if(BP.is_stump() && !(BP.status & ORGAN_CUT_AWAY))
				src.traumatic_shock += 60
			else if(BP.status & ORGAN_BROKEN || BP.open)
				src.traumatic_shock += 30
				if(BP.status & ORGAN_SPLINTED)
					src.traumatic_shock -= 25

			traumatic_shock += (  2 * BP.get_pain())

	if(src.traumatic_shock < 0)
		src.traumatic_shock = 0

	return src.traumatic_shock


/mob/living/carbon/proc/handle_shock() // TODO optimize this.
	updateshock()

	if(status_flags & GODMODE)
		return 0	//godmode
	if(!can_feel_pain())
		shock_stage = 0
		return

	if(analgesic || (species && species.flags[NO_PAIN])) return // analgesic avoids all traumatic shock temporarily

	if(health < config.health_threshold_softcrit)// health 0 makes you immediately collapse
		shock_stage = max(shock_stage, 61)

	if(traumatic_shock >= 80)
		shock_stage += 1
	else if(health < config.health_threshold_softcrit)
		shock_stage = max(shock_stage, 61)
	else
		shock_stage = min(shock_stage, 160)
		shock_stage = max(shock_stage-1, 0)
		return

	if(shock_stage == 10)
		to_chat(src, "<font color='red'><b>"+pick("It hurts so much!", "You really need some painkillers..", "Dear god, the pain!"))

	if(shock_stage >= 30)
		if(shock_stage == 30)
			emote("me",1,"is having trouble keeping their eyes open.")
		eye_blurry = max(2, eye_blurry)
		stuttering = max(stuttering, 5)

	if(shock_stage == 40)
		to_chat(src, "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!"))

	if (shock_stage >= 60)
		if(shock_stage == 60)
			emote("me",1,"'s body becomes limp.")
		if (prob(2))
			to_chat(src, "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!"))
			Weaken(20)

	if(shock_stage >= 80)
		if (prob(5))
			to_chat(src, "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!"))
			Weaken(20)

	if(shock_stage >= 120)
		if (prob(2))
			to_chat(src, "<font color='red'><b>"+pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness."))
			Paralyse(5)

	if(shock_stage == 150)
		emote("me",1,"can no longer stand, collapsing!")
		Weaken(20)

	if(shock_stage >= 150)
		Weaken(20)
