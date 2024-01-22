/mob/living/carbon/ian/Life()
	if (notransform)
		return

	..()

	if(soap_eaten) //Yeshhh, even dead, as long as body exist or timer runs out, its a chemical reaction after all!
		hiccup()

	//Feeding, chasing food, FOOOOODDDD
	if(!incapacitated() && !crawling && !buckled && !lying && !ian_sit)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = FALSE
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = FALSE
				for(var/obj/item/weapon/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				stop_automated_movement = TRUE
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)

				if(movement_target) // Not redundant due to sleeps, Item can be gone in 6 decisecomds
					if (movement_target.loc.x < src.x)
						set_dir(WEST)
					else if (movement_target.loc.x > src.x)
						set_dir(EAST)
					else if (movement_target.loc.y < src.y)
						set_dir(SOUTH)
					else if (movement_target.loc.y > src.y)
						set_dir(NORTH)
					else
						set_dir(SOUTH)

					if(isturf(movement_target.loc))
						movement_target.bite_food(src)
					else if(ishuman(movement_target.loc) )
						if(prob(20))
							me_emote("stares at the [movement_target] that [movement_target.loc] has with a sad puppy-face")

		if(prob(1))
			emote("dance")

	//Movement - this, speaking, simple_animal_A.I. code - should be converted into A.I. datum later on, for now - dirty copypasta of simple_animal.dm Life() proc.
	if(!client && !stop_automated_movement && wander && !anchored)
		if(isturf(src.loc) && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
					var/anydir = pick(cardinal)
					if(Process_Spacemove(anydir))
						Move(get_step(src,anydir), anydir)
						turns_since_move = 0

	//Speaking
	if(!client && speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							me_emote(pick(emote_see), SHOWMSG_VISUAL)
						else
							me_emote(pick(emote_hear), SHOWMSG_AUDIO)
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					me_emote(pick(emote_see), SHOWMSG_VISUAL)
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					me_emote(pick(emote_hear), SHOWMSG_AUDIO)
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						me_emote(pick(emote_see), SHOWMSG_VISUAL)
					else
						me_emote(pick(emote_hear), SHOWMSG_AUDIO)

	reset_alerts()

	if (stat != DEAD && !IS_IN_STASIS(src))
		if(SSmobs.times_fired%4==2)
			//Only try to take a breath every 4 seconds, unless suffocating
			breathe()
		else if(isobj(loc)) //Still give containing object the chance to interact
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)

		handle_mutations_and_radiation()
		handle_chemicals_in_body()
		handle_disabilities()
		handle_virus_updates()

	blinded = null

	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		handle_environment(environment)

	handle_fire()

	handle_regular_status_updates()
	update_canmove()

	if(client)
		handle_alerts()

/mob/living/carbon/ian/handle_regular_hud_updates()
	if(!client)
		return

	update_sight()

	if(hud_used)
		staminadisplay?.update_icon(src)

	..()

/mob/living/carbon/ian/is_skip_breathe()
	return ..() || istype(head, /obj/item/clothing/head/helmet/space) || reagents?.has_reagent("lexorin")

/mob/living/carbon/ian/proc/handle_mutations_and_radiation()
	if(getFireLoss())
		if((COLD_RESISTANCE in mutations) || prob(50))
			switch(getFireLoss())
				if(50 to 100)
					adjustFireLoss(-5)
				if(1 to 50)
					adjustFireLoss(-1)

	if ((HULK in mutations) && health <= 25)
		mutations.Remove(HULK)
		to_chat(src, "<span class='warning'>You suddenly feel very weak.</span>")
		Stun(1)
		Weaken(3)
		emote("collapse")

	if (radiation)
		if (radiation > 100)
			radiation = 100
			Stun(5)
			Weaken(10)
			if(!lying)
				to_chat(src, "<span class='warning'>You feel weak.</span>")
				emote("collapse")

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
					Stun(1)
					Weaken(3)
					if(!lying)
						to_chat(src, "<span class='warning'>You feel weak.</span>")
						emote("collapse")

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				if(prob(1))
					to_chat(src, "<span class='warning'>You mutate!</span>")
					randmutb(src)
					domutcheck(src,null)
					emote("gasp")

/mob/living/carbon/ian/proc/handle_chemicals_in_body()
	if(reagents && reagents.reagent_list.len)
		reagents.metabolize(src)

		var/total_phoronloss = 0
		for(var/obj/item/I in src)
			if(I.contaminated)
				total_phoronloss += vsc.plc.CONTAMINATION_LOSS
		adjustToxLoss(total_phoronloss)

	// nutrition decrease
	if (nutrition > 0)
		nutrition = max(0, nutrition - get_metabolism_factor() / 10)

	if (nutrition > 450)
		if(overeatduration < 600)
			overeatduration++
	else
		if(overeatduration > 1)
			overeatduration = max(0, overeatduration - 2) //doubled the unfat rate

	if (drowsyness)
		drowsyness--
		blurEyes(2)
		if (prob(5))
			Sleeping(2 SECONDS)
			Paralyse(5)

	AdjustConfused(-1)
	AdjustDrunkenness(-1)

	stamina = min(stamina + 1, 100) //i don't want a whole new proc just for one variable, so i leave this here.

	if(crawling)
		dizziness = max(0, dizziness - 5)
		jitteriness = max(0, jitteriness - 5)
	else
		dizziness = max(0, dizziness - 1)
		jitteriness = max(0, jitteriness - 1)

/mob/living/carbon/ian/proc/handle_disabilities()
	if (disabilities & EPILEPSY || HAS_TRAIT(src, TRAIT_EPILEPSY))
		if (prob(1))
			to_chat(src, "<span class='warning'>You have a seizure!</span>")
			Paralyse(10)
	if (disabilities & COUGHING || HAS_TRAIT(src, TRAIT_COUGH))
		if (prob(5) && !paralysis)
			drop_item()
			emote("cough")
	if (disabilities & TOURETTES || HAS_TRAIT(src, TRAIT_TOURETTE))
		if (prob(10) && !paralysis)
			Stun(10)
			emote("twitch")
	if (disabilities & NERVOUS || HAS_TRAIT(src, TRAIT_NERVOUS))
		if (prob(10))
			Stuttering(10)

/mob/living/carbon/ian/proc/handle_virus_updates()
	if(status_flags & GODMODE)
		return FALSE
	if(bodytemperature > 406)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			V.cure(src)

	for(var/obj/effect/decal/cleanable/O in view(1,src))
		if(istype(O,/obj/effect/decal/cleanable/blood))
			var/obj/effect/decal/cleanable/blood/B = O
			if(B.virus2.len)
				for (var/ID in B.virus2)
					var/datum/disease2/disease/V = B.virus2[ID]
					infect_virus2(src,V)

		else if(istype(O,/obj/effect/decal/cleanable/mucus))
			var/obj/effect/decal/cleanable/mucus/M = O

			if(M.virus2.len)
				for (var/ID in M.virus2)
					var/datum/disease2/disease/V = M.virus2[ID]
					infect_virus2(src,V)

	if(virus2.len)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			if(isnull(V)) // Trying to figure out a runtime error that keeps repeating
				CRASH("virus2 nulled before calling activate()")
			else
				V.on_process(src)
			// activate may have deleted the virus
			if(!V)
				continue

			// check if we're immune
			if(V.antigen & src.antibodies)
				V.dead = TRUE

/mob/living/carbon/ian/handle_alerts()
	if(inhale_alert)
		throw_alert("oxy", /atom/movable/screen/alert/ian_oxy)
	else
		clear_alert("oxy")

	if(poison_alert)
		throw_alert("tox", /atom/movable/screen/alert/ian_tox)
	else
		clear_alert("tox")

	if(temp_alert > 0)
		throw_alert("temp", /atom/movable/screen/alert/ian_hot)
	else if(temp_alert < 0)
		throw_alert("temp", /atom/movable/screen/alert/ian_cold)
	else
		clear_alert("temp")

	if(pressure_alert > 0)
		throw_alert("pressure", /atom/movable/screen/alert/highpressure, pressure_alert)
	else if(pressure_alert < 0)
		throw_alert("pressure", /atom/movable/screen/alert/lowpressure, -pressure_alert)
	else
		clear_alert("pressure")

/mob/living/carbon/ian/handle_environment(datum/gas_mixture/environment)
	if(istype(head, /obj/item/clothing/head/helmet/space))
		stabilize_body_temperature()
		return

	..()

/mob/living/carbon/ian/handle_fire()
	if(..())
		return
	adjust_bodytemperature(BODYTEMP_HEATING_MAX)
	return

/mob/living/carbon/ian/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
		med_hud_set_health()

/mob/living/carbon/ian/proc/handle_regular_status_updates()
	if(stat == DEAD)
		blinded = TRUE
		silent = 0
	else
		updatehealth()
		if(health < config.health_threshold_dead)
			death()
			blinded = TRUE
			stat = DEAD
			silent = 0
			return TRUE

		if( (getOxyLoss() > 25) || (config.health_threshold_crit > health) )
			if( health <= 20 && prob(1) )
				emote("gasp")
			if(!reagents.has_reagent("inaprovaline"))
				losebreath = max(losebreath + 1, 2)
			Paralyse(3)
		if(halloss > 100)
			to_chat(src, "<span class='notice'>You're in too much pain to keep going...</span>")
			visible_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.")
			Paralyse(10)
			setHalLoss(99)

		if(paralysis)
			blinded = TRUE
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(IsSleeping())
			blinded = TRUE
		else if(crawling)
			if(halloss > 0)
				adjustHalLoss(-3)
		else
			stat = CONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-1)

		//Eyes
		if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
			blinded = TRUE
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind - 1,0)
			blinded = TRUE
		else if(eye_blurry)			//blurry eyes heal slowly
			adjustBlurriness(-1)

		//Ears
		if(sdisabilities & DEAF)		//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf - 1, 0)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage - 0.05, 0)

		//Other
		if(stuttering > 0)
			AdjustStuttering(-1)

		if(silent)
			silent = max(silent - 1, 0)

		if(druggy)
			adjustDrugginess(-1)
	return TRUE

/mob/living/carbon/ian/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE)
		return
	var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity) / 2000000, 1.0)

	if(exposed_temperature > bodytemperature)
		adjustFireLoss(20.0 * discomfort)

	else
		adjustFireLoss(5.0 * discomfort)

//and death!
/mob/living/carbon/ian/death(gibbed)
	if(stat == DEAD)
		return

	stat = DEAD

	if(!gibbed)
		emote("deathgasp")
		update_canmove()

	tod = worldtime2text()
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)

	return ..(gibbed)
