/mob/living/carbon/ian/Life()
	if (notransform)
		return

	..()

	if(soap_eaten) //Yeshhh, even dead, as long as body exist or timer runs out, its a chemical reaction after all!
		hiccup()

	//Feeding, chasing food, FOOOOODDDD
	if(!incapacitated() && !resting && !buckled && !lying)
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
						dir = WEST
					else if (movement_target.loc.x > src.x)
						dir = EAST
					else if (movement_target.loc.y < src.y)
						dir = SOUTH
					else if (movement_target.loc.y > src.y)
						dir = NORTH
					else
						dir = SOUTH

					if(isturf(movement_target.loc) )
						movement_target.attack_animal(src)
					else if(ishuman(movement_target.loc) )
						if(prob(20))
							emote("me",1,"stares at the [movement_target] that [movement_target.loc] has with a sad puppy-face")

		if(prob(1))
			emote("me",1,pick("dances around","chases its tail"))
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
				dir = i
				sleep(1)

	//Movement - this, speaking, simple_animal_A.I. code - should be converted into A.I. datum later on, for now - dirty copypasta of simple_animal.dm Life() proc.
	if(!client && !stop_automated_movement && wander && !anchored)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
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
							emote(pick(emote_see),1)
						else
							emote(pick(emote_hear),2)
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote(pick(emote_see),1)
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote(pick(emote_hear),2)
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote(pick(emote_see),1)
					else
						emote(pick(emote_hear),2)

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

	//handle_regular_hud_updates() mob/living/Life() handles this already. i'l leave this as reminder. need to fix for human, monkey and maybe aliens also.

/mob/living/carbon/ian/handle_regular_hud_updates()
	if(!..())
		return FALSE

	if (stat == DEAD || (XRAY in mutations))
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != DEAD)
		sight &= ~SEE_TURFS
		sight &= ~SEE_MOBS
		sight &= ~SEE_OBJS
		see_in_dark = 2
		see_invisible = SEE_INVISIBLE_LIVING

	if(healths)
		if(stat != DEAD)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(hud_used && hud_used.staminadisplay)
		var/obj/screen/corgi/stamina_bar/SB = hud_used.staminadisplay
		SB.icon_state = "stam_bar_[round(stamina, 5)]"

	if(oxygen_alert)
		throw_alert("ian_oxy", /obj/screen/alert/ian_oxy)
	else
		clear_alert("ian_oxy")
	if(phoron_alert)
		throw_alert("ian_tox", /obj/screen/alert/ian_tox)
	else
		clear_alert("ian_tox")
	if(fire_alert)
		throw_alert("ian_hot", /obj/screen/alert/ian_hot)
	else
		clear_alert("ian_hot")

	return TRUE

/mob/living/carbon/ian/proc/breathe()
	if(status_flags & GODMODE) // Do we even need GODMODE? ~Zve
		return

	// This is Ian, he knows that every space helmet has infinite breathable air inside!
	if(!loc || istype(head, /obj/item/clothing/head/helmet/space) || reagents && reagents.has_reagent("lexorin"))
		return

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/breath
	if(handle_drowning() || health < 0)
		losebreath = max(2, losebreath + 1)
	if(losebreath > 0) //Suffocating so do not take a breath
		losebreath--
		if (prob(75)) //High chance of gasping for air
			emote("gasp")
		if(isobj(loc))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		if(isobj(loc))
			var/obj/location_as_object = loc
			breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
		else if(isturf(loc))
			var/breath_moles = environment.total_moles * BREATH_PERCENTAGE
			breath = loc.remove_air(breath_moles)

			var/block = FALSE
			if(istype(wear_mask, /obj/item/clothing/mask/gas))
				var/obj/item/clothing/mask/gas/G = wear_mask
				var/datum/gas_mixture/filtered = new

				for(var/g in  list("phoron", "sleeping_agent"))
					if(breath.gas[g])
						filtered.gas[g] = breath.gas[g] * G.gas_filter_strength
						breath.gas[g] -= filtered.gas[g]

				breath.update_values()
				filtered.update_values()

				block = TRUE

			if(!block)
				for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
					if(smoke.reagents.total_volume)
						smoke.reagents.reaction(src, INGEST)
						sleep(5)
						if(smoke)
							smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
						break // If they breathe in the nasty stuff once, no need to continue checking

	if(!breath || (breath.total_moles == 0))
		adjustOxyLoss(7)
		oxygen_alert = TRUE
		return FALSE

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_phoron_max = 0.5
	var/SA_para_min = 0.5
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/breath_pressure = (breath.total_moles * R_IDEAL_GAS_EQUATION * breath.temperature) / BREATH_VOLUME

	//Partial pressure of the O2 in our breath
	var/O2_pp = (breath.gas["oxygen"] / breath.total_moles) * breath_pressure
	// Same, but for the phoron
	var/Toxins_pp = (breath.gas["phoron"] / breath.total_moles) * breath_pressure
	// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
	var/CO2_pp = (breath.gas["carbon_dioxide"] / breath.total_moles) * breath_pressure

	if(O2_pp < safe_oxygen_min) 			// Too little oxygen
		if(prob(20))
			emote("gasp")
		if (O2_pp == 0)
			O2_pp = 0.01
		var/ratio = safe_oxygen_min/O2_pp
		adjustOxyLoss(min(5 * ratio, 7)) // Don't fuck them up too fast (space only does 7 after all!)
		oxygen_used = breath.gas["oxygen"] * ratio / 6
		oxygen_alert = TRUE
	else // We're in safe limits
		adjustOxyLoss(-5)
		oxygen_used = breath.gas["oxygen"] / 6
		oxygen_alert = FALSE

	breath.adjust_gas("oxygen", oxygen_used, update = FALSE)
	breath.adjust_gas_temp("carbon_dioxide", oxygen_used, bodytemperature, update = FALSE) //update afterwards

	if(CO2_pp > safe_co2_max)
		if(!co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Paralyse(3)
			adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
			if(world.time - co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
				adjustOxyLoss(8)
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			emote("cough")

	else
		co2overloadtime = 0

	if(Toxins_pp > safe_phoron_max) // Too much phoron
		var/ratio = (breath.gas["phoron"]/safe_phoron_max) * 10
		//adjustToxLoss(clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))	//Limit amount of damage toxin exposure can do per second
		if(reagents)
			reagents.add_reagent("toxin", clamp(ratio, MIN_TOXIN_DAMAGE, MAX_TOXIN_DAMAGE))
		phoron_alert = TRUE
	else
		phoron_alert = FALSE

	if(breath.gas["sleeping_agent"]) // If there's some other shit in the air lets deal with it here.
		var/SA_pp = (breath.gas["sleeping_agent"] / breath.total_moles) * breath_pressure
		if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
			Paralyse(3) // 3 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				Sleeping(10 SECONDS)
		else if(SA_pp > 0.01) // There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				emote(pick("giggle", "laugh"))

	if(breath.temperature > (T0C + 66)) // Hot air hurts :(
		if(prob(20))
			to_chat(src, "<span class='warning'>You feel a searing heat in your lungs!</span>")
		fire_alert = TRUE
	else
		fire_alert = FALSE

	//if(breath)
	//	loc.assume_air(breath)
	breath.update_values()

	return TRUE

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
		Weaken(3)
		emote("collapse")

	if (radiation)
		if (radiation > 100)
			radiation = 100
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
		eye_blurry = max(2, eye_blurry)
		if (prob(5))
			Sleeping(2 SECONDS)
			Paralyse(5)

	if(confused)
		confused = max(0, confused - 1)

	stamina = min(stamina + 1, 100) //i don't want a whole new proc just for one variable, so i leave this here.

	if(resting)
		dizziness = max(0, dizziness - 5)
		jitteriness = max(0, jitteriness - 5)
	else
		dizziness = max(0, dizziness - 1)
		jitteriness = max(0, jitteriness - 1)

/mob/living/carbon/ian/proc/handle_disabilities()
	if (disabilities & EPILEPSY || HAS_TRAIT(src, TRAIT_EPILEPSY))
		if (prob(1) && paralysis < 10)
			to_chat(src, "<span class='warning'>You have a seizure!</span>")
			Paralyse(10)
	if (disabilities & COUGHING || HAS_TRAIT(src, TRAIT_COUGH))
		if (prob(5) && paralysis <= 1)
			drop_item()
			emote("cough")
	if (disabilities & TOURETTES || HAS_TRAIT(src, TRAIT_TOURETTE))
		if (prob(10) && paralysis <= 1)
			Stun(10)
			emote("twitch")
	if (disabilities & NERVOUS || HAS_TRAIT(src, TRAIT_NERVOUS))
		if (prob(10))
			stuttering = max(10, stuttering)

/mob/living/carbon/ian/proc/handle_virus_updates()
	if(status_flags & GODMODE)
		return FALSE
	if(bodytemperature > 406)
		for(var/datum/disease/D in viruses)
			D.cure()
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
				V.activate(src)
			// activate may have deleted the virus
			if(!V)
				continue

			// check if we're immune
			if(V.antigen & src.antibodies)
				V.dead = TRUE

/mob/living/carbon/ian/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.

	if(istype(head, /obj/item/clothing/head/helmet/space) || (adjusted_pressure < WARNING_HIGH_PRESSURE && adjusted_pressure > WARNING_LOW_PRESSURE && abs(environment.temperature - 293.15) < 20 && abs(bodytemperature - 310.14) < 0.5))
		clear_alert("pressure")
		return

	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity
	if(!on_fire)
		if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
			var/transfer_coefficient = 1

			handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity * transfer_coefficient)
	if(stat == DEAD)
		bodytemperature += 0.1 * (environment.temperature - bodytemperature) * environment_heat_capacity / (environment_heat_capacity + 270000)

	//Account for massive pressure differences
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 ) * PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			throw_alert("pressure", /obj/screen/alert/highpressure, 2)
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			throw_alert("pressure", /obj/screen/alert/highpressure, 1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			clear_alert("pressure")
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			throw_alert("pressure", /obj/screen/alert/lowpressure, 1)
		else
			if( !(COLD_RESISTANCE in mutations) )
				adjustBruteLoss( LOW_PRESSURE_DAMAGE )
				throw_alert("pressure", /obj/screen/alert/lowpressure, 2)
			else
				throw_alert("pressure", /obj/screen/alert/lowpressure, 1)

/mob/living/carbon/ian/handle_fire()
	if(..())
		return
	adjustFireLoss(6)
	return

/mob/living/carbon/ian/calculate_affecting_pressure(pressure)
	..()
	return pressure

/mob/living/carbon/ian/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()

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
				adjustOxyLoss(1)
			Paralyse(3)
		if(halloss > 100)
			to_chat(src, "<span class='notice'>You're in too much pain to keep going...</span>")
			visible_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.")
			Paralyse(10)
			setHalLoss(99)

		if(paralysis)
			AdjustParalysis(-1)
			blinded = TRUE
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(IsSleeping())
			blinded = TRUE
		else if(resting)
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
			eye_blurry = max(eye_blurry - 1, 0)

		//Ears
		if(sdisabilities & DEAF)		//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf - 1, 0)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage - 0.05, 0)

		//Other
		if(stunned)
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened - 1,0)	//before you get mad Rockdtben: I done this so update_canmove isn't called multiple times

		if(stuttering)
			stuttering = max(stuttering - 1, 0)

		if(silent)
			silent = max(silent - 1, 0)

		if(druggy)
			druggy = max(druggy - 1, 0)
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
	if(healths)
		healths.icon_state = "health5"

	stat = DEAD

	if(!gibbed)
		emote("deathgasp")
		update_canmove()

	tod = worldtime2text()
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
	if(SSticker.mode)
		SSticker.mode.check_win()		//Calls the rounds wincheck, mainly for wizard, malf, and changeling now

	return ..(gibbed)
