/proc/random_blood_type()
	return pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

/proc/random_hair_style(gender, species = HUMAN, ipc_head)
	var/h_style = "Bald"

	var/list/valid_hairstyles = get_valid_styles_from_cache(hairs_cache, species, gender, ipc_head)

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)

	return h_style

/proc/random_gradient_style()
	return pick(hair_gradients)

/proc/random_facial_hair_style(gender, species = HUMAN)
	var/f_style = "Shaved"

	var/list/valid_facialhairstyles = get_valid_styles_from_cache(facial_hairs_cache, species, gender)

	if(valid_facialhairstyles.len)
		f_style = pick(valid_facialhairstyles)

		return f_style

/proc/random_unique_name(gender, attempts_to_find_unique_name = 10)
	for(var/i in 1 to attempts_to_find_unique_name)
		if(gender == FEMALE)
			. = capitalize(pick(global.first_names_female)) + " " + capitalize(pick(global.last_names))
		else
			. = capitalize(pick(global.first_names_male)) + " " + capitalize(pick(global.last_names))

		if(!findname(.))
			break

/proc/random_name(gender, species = HUMAN)
	if(gender==FEMALE)	return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	else				return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

/proc/random_skin_tone()
	switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
		if("caucasian")		. = -10
		if("afroamerican")	. = -115
		if("african")		. = -165
		if("latino")		. = -55
		if("albino")		. = 34
		else				. = rand(-185,34)
	return min(max( .+rand(-25, 25), -185),34)

/proc/skintone2racedescription(tone)
	switch (tone)
		if(30 to INFINITY)		return "albino"
		if(20 to 30)			return "pale"
		if(5 to 15)				return "light skinned"
		if(-10 to 5)			return "white"
		if(-25 to -10)			return "tan"
		if(-45 to -25)			return "darker skinned"
		if(-65 to -45)			return "brown"
		if(-INFINITY to -65)	return "black"
		else					return "unknown"

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)			return "infant"
		if(1 to 3)			return "toddler"
		if(3 to 13)			return "child"
		if(13 to 19)		return "teenager"
		if(19 to 30)		return "young adult"
		if(30 to 45)		return "adult"
		if(45 to 60)		return "middle-aged"
		if(60 to 70)		return "aging"
		if(70 to INFINITY)	return "elderly"
		else				return "unknown"

//helper for inverting armor blocked values into a multiplier
#define blocked_mult(blocked) max(1 - (blocked / 100), 0)

/proc/do_mob(mob/user , mob/target, time = 30, check_target_zone = FALSE, uninterruptible = FALSE, progress = TRUE, datum/callback/extra_checks = null)
	if(!user || !target)
		return FALSE

	time *= (1.0 + user.mood_multiplicative_actionspeed_modifier)

	var/busy_hand = user.hand
	user.become_busy(_hand = busy_hand)

	target.in_use_action = TRUE

	if(check_target_zone)
		check_target_zone = user.get_targetzone()

	var/user_loc = user.loc

	var/target_loc = target.loc

	var/holding = user.get_active_hand()
	var/datum/progressbar/progbar
	if (progress)
		if(user.client && (user.client.prefs.toggles & SHOW_PROGBAR))
			progbar = new(user, time, target)
		else
			progress = FALSE

	var/endtime = world.time+time
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)
		if(QDELETED(user) || QDELETED(target))
			. = FALSE
			break
		if(uninterruptible)
			continue
		if(user.loc != user_loc || target.loc != target_loc || user.incapacitated() || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break

		if(HAS_TRAIT(user, TRAIT_MULTITASKING))
			if(user.hand != busy_hand)
				if(user.get_inactive_hand() != holding)
					. = FALSE
					break
			else
				if(user.get_active_hand() != holding)
					. = FALSE
					break
		else
			if(user.hand != busy_hand)
				. = FALSE
				break
			if(user.get_active_hand() != holding)
				. = FALSE
				break

		if(check_target_zone && user.get_targetzone() != check_target_zone)
			. = FALSE
			break
	if(progress)
		qdel(progbar)
	if(user)
		user.become_not_busy(_hand = busy_hand)
	if(target)
		target.in_use_action = FALSE

/proc/do_after(mob/user, delay, needhand = TRUE, atom/target, can_move = FALSE, progress = TRUE, datum/callback/extra_checks)
	if(!user || target && QDELING(target))
		return FALSE

	delay *= (1.0 + user.mood_multiplicative_actionspeed_modifier)

	var/busy_hand = user.hand
	user.become_busy(_hand = busy_hand)

	var/target_null = TRUE
	var/atom/Tloc = null
	if(target)
		target_null = FALSE
		if(target != user)
			target.in_use_action = TRUE
			Tloc = target.loc

	var/atom/Uloc = null
	if(!can_move)
		Uloc = user.loc

	var/obj/item/holding = user.get_active_hand()

	var/holdingnull = TRUE //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = FALSE //Users hand started holding something, check to see if it's still holding that

	var/datum/progressbar/progbar
	if (progress)
		if(user.client && (user.client.prefs.toggles & SHOW_PROGBAR))
			progbar = new(user, delay, target)
		else
			progress = FALSE

	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)

		if(QDELETED(user) || !target_null && QDELETED(target))
			. = FALSE
			break

		if(user.incapacitated(NONE))
			. = FALSE
			break

		if(Uloc && (user.loc != Uloc) || Tloc && (Tloc != target.loc))
			. = FALSE
			break
		if(extra_checks && !extra_checks.Invoke(user, target))
			. = FALSE
			break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull && QDELETED(holding))
				. = FALSE
				break

			if(HAS_TRAIT(user, TRAIT_MULTITASKING))
				if(user.hand != busy_hand)
					if(user.get_inactive_hand() != holding)
						. = FALSE
						break
				else
					if(user.get_active_hand() != holding)
						. = FALSE
						break
			else
				if(user.hand != busy_hand)
					. = FALSE
					break
				if(user.get_active_hand() != holding)
					. = FALSE
					break

	if(progress)
		qdel(progbar)
	if(user)
		user.become_not_busy(_hand = busy_hand)
	if(target && target != user)
		target.in_use_action = FALSE

//Returns true if this person has a job which is a department head
/mob/proc/is_head_role()
	. = FALSE
	if(!mind || !mind.assigned_job)
		return
	return mind.assigned_job.head_position

/mob/proc/IsShockproof()
	return HAS_TRAIT(src, TRAIT_SHOCKIMMUNE)

/mob/proc/IsClumsy()
	return HAS_TRAIT(src, TRAIT_CLUMSY)

/mob/proc/ClumsyProbabilityCheck(probability)
	if(HAS_TRAIT(src, TRAIT_CLUMSY) && prob(probability))
		return TRUE
	return FALSE

/proc/health_analyze(mob/living/M, mob/living/user, mode, output_to_chat, hide_advanced_information)
	var/message = ""
	var/insurance_type
	
	if(ishuman(M))
		insurance_type = get_insurance_type(M)

	if(!output_to_chat)
		message += "<HTML><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'><title>[M.name]'s scan results</title></head><BODY>"

	if(user.ClumsyProbabilityCheck(50) || (user.getBrainLoss() >= 60 && prob(50)))
		user.visible_message("<span class='warning'>[user] has analyzed the floor's vitals!</span>", "<span class = 'warning'>You try to analyze the floor's vitals!</span>")
		message += "<span class='notice'>Analyzing Results for The floor:\n&emsp; Overall Status: Healthy</span><br>"
		message += "<span class='notice'>&emsp; Damage Specifics: [0]-[0]-[0]-[0]</span><br>"
		message += "<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span><br>"
		message += "<span class='notice'>Body Temperature: ???</span>"
		if(!output_to_chat)
			message += "</BODY></HTML>"
		return message
	user.visible_message("<span class='notice'>[user] has analyzed [M]'s vitals.</span>","<span class='notice'>You have analyzed [M]'s vitals.</span>")

	var/fake_oxy = max(rand(1,40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	var/OX = M.getOxyLoss() > 50 	? 	"<b>[M.getOxyLoss()]</b>" 		: M.getOxyLoss()
	var/TX = M.getToxLoss() > 50 	? 	"<b>[M.getToxLoss()]</b>" 		: M.getToxLoss()
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
		message += "<span class='notice'>Analyzing Results for [M]:\n&emsp; Overall Status: dead</span><br>"
	else
		message += "<span class='notice'>Analyzing Results for [M]:\n&emsp; Overall Status: [M.stat > 1 ? "dead" : "[M.health - M.halloss]% healthy"]</span><br>"
	message += "&emsp; Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font><br>"
	message += "&emsp; Damage Specifics: <font color='blue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font><br>"
	message += "<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span><br>"
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		message += "<span class='notice'>Time of Death: [M.tod]</span><br>"
	if(ishuman(M) && mode)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_bodyparts(1, 1)
		message += "<span class='notice'>Localized Damage, Brute/Burn:</span><br>"
		if(length(damaged))
			for(var/obj/item/organ/external/BP in damaged)
				message += "<span class='notice'>&emsp; [capitalize(BP.name)]: [(BP.brute_dam > 0) ? "<span class='warning'>[BP.brute_dam]</span>" : 0][(BP.status & ORGAN_BLEEDING) ? "<span class='warning bold'>\[Bleeding\]</span>" : "&emsp;"] - [(BP.burn_dam > 0) ? "<font color='#FFA500'>[BP.burn_dam]</font>" : 0]</span><br>"
		else
			message += "<span class='notice'>&emsp; Limbs are OK.</span><br>"
	
	if(hide_advanced_information)
		if(!output_to_chat)
			message += "</BODY></HTML>"
		
		return message
	
	OX = M.getOxyLoss() > 50 ? "<font color='blue'><b>Severe oxygen deprivation detected</b></font>" : "Subject bloodstream oxygen level normal"
	TX = M.getToxLoss() > 50 ? "<font color='green'><b>Dangerous amount of toxins detected</b></font>" : "Subject bloodstream toxin level minimal"
	BU = M.getFireLoss() > 50 ? "<font color='#FFA500'><b>Severe burn damage detected</b></font>" : "Subject burn injury status O.K"
	BR = M.getBruteLoss() > 50 ? "<font color='red'><b>Severe anatomical damage detected</b></font>" : "Subject brute-force injury status O.K"
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? 		"<span class='warning'>Severe oxygen deprivation detected</span>" : "Subject bloodstream oxygen level normal"
	message += "[OX]<br>[TX]<br>[BU]<br>[BR]<br>"
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.reagents.total_volume || C.is_infected_with_zombie_virus())
			message += "<span class='warning'>Warning: Unknown substance detected in subject's blood.</span><br>"
		if(C.virus2.len)
			for (var/ID in C.virus2)
				if (ID in virusDB)
					var/datum/data/record/V = virusDB[ID]
					message += "<span class='warning'>Warning: Pathogen [V.fields["name"]] detected in subject's blood. Known antigen : [V.fields["antigen"]]</span><br>"
//			user.oldshow_message(text("<span class='warning'>Warning: Unknown pathogen detected in subject's blood.</span>"))
		if(C.roundstart_quirks.len)
			message += "\t<span class='info'>Subject has the following physiological traits: [C.get_trait_string()].</span><br>"
	if(M.getCloneLoss())
		to_chat(user, "<span class='warning'>Subject appears to have been imperfectly cloned.</span>")
	if(M.reagents && M.reagents.get_reagent_amount("inaprovaline"))
		message += "<span class='notice'>Bloodstream Analysis located [M.reagents:get_reagent_amount("inaprovaline")] units of rejuvenation chemicals.</span><br>"
	if(M.has_brain_worms())
		message += "<span class='warning'>Subject suffering from aberrant brain activity. Recommend further scanning.</span><br>"
	else if(M.getBrainLoss() >= 100 || (ishuman(M) && !M:has_brain() && M:should_have_organ(O_BRAIN)))
		message += "<span class='warning'>Subject is brain dead.</span>"
	else if(M.getBrainLoss() >= 60)
		message += "<span class='warning'>Severe brain damage detected. Subject likely to have mental retardation.</span><br>"
	else if(M.getBrainLoss() >= 10)
		message += "<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span><br>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/found_bleed
		var/found_broken
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(BP.status & ORGAN_BROKEN)
				if(((BP.body_zone == BP_L_ARM) || (BP.body_zone == BP_R_ARM) || (BP.body_zone == BP_L_LEG) || (BP.body_zone == BP_R_LEG)) && !(BP.status & ORGAN_SPLINTED))
					message += "<span class='warning'>Unsecured fracture in subject [BP.name]. Splinting recommended for transport.</span><br>"
				if(!found_broken)
					found_broken = TRUE

			if(!found_bleed && (BP.status & ORGAN_ARTERY_CUT))
				found_bleed = TRUE

			if(BP.has_infected_wound())
				message += "<span class='warning'>Infected wound detected in subject [BP.name]. Disinfection recommended.</span><br>"

		if(found_bleed)
			message += "<span class='warning'>Arterial bleeding detected. Advanced scanner required for location.</span><br>"
		if(found_broken)
			message += "<span class='warning'>Bone fractures detected. Advanced scanner required for location.</span><br>"

		var/blood_volume = H.blood_amount()
		var/blood_percent =  100.0 * blood_volume / BLOOD_VOLUME_NORMAL
		var/blood_type = H.dna.b_type
		if(blood_volume <= BLOOD_VOLUME_SAFE && blood_volume > BLOOD_VOLUME_OKAY)
			message += "<span class='warning bold'>Warning: Blood Level LOW: [blood_percent]% [blood_volume]cl.</span><span class='notice'>Type: [blood_type]</span><br>"
		else if(blood_volume <= BLOOD_VOLUME_OKAY)
			message += "<span class='warning bold'>Warning: Blood Level CRITICAL: [blood_percent]% [blood_volume]cl.</span><span class='notice bold'>Type: [blood_type]</span><br>"
		else
			message += "<span class='notice'>Blood Level Normal: [blood_percent]% [blood_volume]cl. Type: [blood_type]</span><br>"

		var/obj/item/organ/internal/heart/Heart = H.organs_by_name[O_HEART]
		if(Heart)
			switch(Heart.heart_status)
				if(HEART_FAILURE)
					message += "<span class='notice'><font color='red'>Warning! Subject's heart stopped!</font></span><br>"
				if(HEART_FIBR)
					message += "<span class='notice'>Subject's Heart status: <font color='blue'>Attention! Subject's heart fibrillating.</font></span><br>"
			message += "<span class='notice'>Subject's pulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse(GETPULSE_TOOL)] bpm.</font></span><br>"

	if(insurance_type)
		message += "<span class='notice'><font color='blue'>Страховка: [insurance_type]</font></span><br>"

	if(!output_to_chat)
		message += "</BODY></HTML>"
		
	return message
