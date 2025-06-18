/mob/living/carbon/monkey/Life()
	set invisibility = 0
	//set background = 1
	if (notransform)
		return
	if (update_muts)
		update_muts=0
		domutcheck(src,null,MUTCHK_FORCED)
	..()

	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(loc)
		environment = loc.return_air()

	if (stat != DEAD && !IS_IN_STASIS(src))
		if(!istype(src,/mob/living/carbon/monkey/diona))
			//First, resolve location and get a breath
			if(SSmobs.times_fired%4==2)
				//Only try to take a breath every 4 seconds, unless suffocating
				breathe()
			else //Still give containing object the chance to interact
				if(istype(loc, /obj))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src, 0)

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

		//Virus updates, duh
		handle_virus_updates()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	reset_alerts()
	blinded = null

	//Handle temperature/pressure differences between body and environment
	if(environment)	// More error checking -- TLE
		handle_environment(environment)

	//Check if we're on fire
	handle_fire()

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	if(!client && stat == CONSCIOUS)

		if(prob(33) && canmove && !crawling && isturf(loc) && !pulledby) //won't move if being pulled

			step(src, pick(cardinal))

		if(prob(1))
			var/list/rand_emote = list(
				"scratches.",
				"jumps!",
				"rolls.",
				"waves his tail.",
			)
			me_emote(pick(rand_emote))
	updatehealth()
	if(client)
		handle_alerts()

/mob/living/carbon/monkey/proc/handle_disabilities()

	if (disabilities & EPILEPSY || HAS_TRAIT(src, TRAIT_EPILEPSY))
		if (prob(1))
			to_chat(src, "<span class='warning'>You have a seizure!</span>")
			Paralyse(10)
	if (disabilities & COUGHING || HAS_TRAIT(src, TRAIT_COUGH))
		if ((prob(5) && !paralysis))
			drop_item()
			spawn( 0 )
				emote("cough")
				return
	if (disabilities & TOURETTES || HAS_TRAIT(src, TRAIT_TOURETTE))
		if (prob(10) && !paralysis)
			Stun(10)
			spawn( 0 )
				emote("twitch")
				return
	if (disabilities & NERVOUS || HAS_TRAIT(src, TRAIT_NERVOUS))
		if (prob(10))
			Stuttering(10)

/mob/living/carbon/monkey/proc/handle_mutations_and_radiation()

	if(getFireLoss())
		if((COLD_RESISTANCE in mutations) || prob(50))
			switch(getFireLoss())
				if(1 to 50)
					adjustFireLoss(-1)
				if(51 to 100)
					adjustFireLoss(-5)

	if ((HULK in mutations) && health <= 25)
		mutations.Remove(HULK)
		to_chat(src, "<span class='warning'>You suddenly feel very weak.</span>")
		Stun(1)
		Weaken(3)
		emote("collapse")

	if (radiation)

		if(istype(src,/mob/living/carbon/monkey/diona)) //Filthy check. Dionaea don't take rad damage.
			var/rads = radiation/25
			radiation -= rads
			nutrition += rads
			heal_overall_damage(rads,rads)
			adjustOxyLoss(-(rads))
			adjustToxLoss(-(rads))
			return

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

/mob/living/carbon/monkey/proc/handle_virus_updates()
	if(status_flags & GODMODE)	return 0	//godmode
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
			if(!V) continue

			// check if we're immune
			if(V.antigen & src.antibodies)
				V.dead = 1

	return

/mob/living/carbon/monkey/is_skip_breathe()
	return ..() || reagents?.has_reagent("lexorin") || istype(loc, /obj/item/weapon/holder)

/mob/living/carbon/monkey/get_breath_from_internal(volume_needed)
	if(!internal)
		return null
	if(!(contents.Find(internal) && wear_mask && (wear_mask.flags & MASKINTERNALS)))
		internal = null
		return null

	return internal.remove_air_volume(volume_needed)

/mob/living/carbon/monkey/proc/handle_chemicals_in_body()

	if(reagents && reagents.reagent_list.len)
		reagents.metabolize(src)

	if (drowsyness)
		drowsyness--
		blurEyes(2)
		if (prob(5))
			Sleeping(2 SECONDS)
			Paralyse(5)

	AdjustConfused(-1)
	AdjustDrunkenness(-1)

	if(crawling)
		dizziness = max(0, dizziness - 5)
	else
		dizziness = max(0, dizziness - 1)

	return //TODO: DEFERRED

/mob/living/carbon/monkey/proc/handle_regular_status_updates()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		updatehealth()
		if(health < config.health_threshold_dead || !has_brain())
			death()
			blinded = 1
			stat = DEAD
			silent = 0
			return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 25) || (config.health_threshold_crit > health) )
			if( health <= 20 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_reagent("inaprovaline"))
				losebreath = max(losebreath + 1, 2)
			Paralyse(3)
		if(halloss > 100)
			visible_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.", self_message = "<span class='notice'>You're in too much pain to keep going...</span>")
			Paralyse(10)
			setHalLoss(99)

		if(paralysis)
			blinded = 1
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(IsSleeping())
			blinded = TRUE
		else if(crawling)
			if(halloss > 0)
				adjustHalLoss(-3)
		//CONSCIOUS
		else
			stat = CONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-1)

		//Eyes
		if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(eye_blurry)			//blurry eyes heal slowly
			adjustBlurriness(-1)

		//Ears
		if(sdisabilities & DEAF)		//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf-1, 0)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage-0.05, 0)

		//Other
		if(stuttering > 0)
			AdjustStuttering(-1)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			adjustDrugginess(-1)
	return 1

/mob/living/carbon/monkey/handle_regular_hud_updates()
	if(!client)
		return

	update_sight()

	..()

/mob/living/carbon/monkey/proc/handle_random_events()
	if (prob(1) && prob(2))
		spawn(0)
			emote("scratch")
			return

///FIRE CODE
/mob/living/carbon/monkey/handle_fire()
	if(..())
		return
	adjust_bodytemperature(BODYTEMP_HEATING_MAX)
	return
//END FIRE CODE

/mob/living/carbon/monkey/diona/Life()
	if(stat != DEAD)
		var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
		if(gestalt && isturf(gestalt.loc))
			var/turf/T = gestalt.loc
			light_amount = round((T.get_lumcount()*10)-5)
		else if(isturf(loc)) //else, there's considered to be no light
			var/turf/T = loc
			light_amount = round((T.get_lumcount()*10)-5)

		nutrition += light_amount
		traumatic_shock -= light_amount

		if(nutrition > NUTRITION_LEVEL_NORMAL)
			nutrition = NUTRITION_LEVEL_NORMAL
		if(light_amount > 2) //if there's enough light, heal
			adjustBruteLoss(-1)
			adjustToxLoss(-1)
			adjustOxyLoss(-1)
		else if(light_amount < -3)
			if(race == DIONA && prob(5))
				emote("chirp")
		if(injecting)
			if(gestalt && nutrition > 210)
				gestalt.reagents.add_reagent(injecting,1)
				nutrition -= 10
			else
				injecting = null
	..()
