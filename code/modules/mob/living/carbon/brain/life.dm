/mob/living/carbon/brain/Life()
	set invisibility = 0
	//set background = 1

	if (notransform)
		return

	..()

	if(stat != DEAD)
		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(loc)
		environment = loc.return_air()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	reset_alerts()
	blinded = null

	//Handle temperature/pressure differences between body and environment
	if(environment)	// More error checking -- TLE
		handle_environment(environment)

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	if(client)
		handle_alerts()


/mob/living/carbon/brain/proc/handle_mutations_and_radiation()

	if (radiation)
		if (radiation > 100)
			radiation = 100
			if(!container)//If it's not in an MMI
				to_chat(src, "<span class='warning'>You feel weak.</span>")
			else//Fluff-wise, since the brain can't detect anything itself, the MMI handles thing like that
				to_chat(src, "<span class='warning'>STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED.</span>")

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)
					updatehealth()

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
					if(!container)
						to_chat(src, "<span class='warning'>You feel weak.</span>")
					else
						to_chat(src, "<span class='warning'>STATUS: DANGEROUS LEVELS OF RADIATION DETECTED.</span>")
				updatehealth()

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				updatehealth()

/mob/living/carbon/brain/proc/handle_chemicals_in_body()

	if(reagents) reagents.metabolize(src)

	AdjustConfused(-1)
	AdjustDrunkenness(-1)
	// decrement dizziness counter, clamped to 0
	if(crawling)
		dizziness = max(0, dizziness - 5)
	else
		dizziness = max(0, dizziness - 1)

	updatehealth()

	return //TODO: DEFERRED


/mob/living/carbon/brain/proc/handle_regular_status_updates()	//TODO: comment out the unused bits >_>
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if( !container && (health < config.health_threshold_dead || ((world.time - timeofhostdeath) > config.revival_brain_life)) )
			death()
			blinded = 1
			silent = 0
			return 1

		//Handling EMP effect in the Life(), it's made VERY simply, and has some additional effects handled elsewhere
		if(emp_damage)			//This is pretty much a damage type only used by MMIs, dished out by the emp_act
			if(!(container && isMMI(container)))
				emp_damage = 0
			else
				emp_damage = round(emp_damage,1)//Let's have some nice numbers to work with
			switch(emp_damage)
				if(31 to INFINITY)
					emp_damage = 30//Let's not overdo it
				if(21 to 30)//High level of EMP damage, unable to see, hear, or speak
					eye_blind = 1
					blinded = 1
					ear_deaf = 1
					silent = 1
					if(!alert)//Sounds an alarm, but only once per 'level'
						emote("buzz")
						to_chat(src, "<span class='warning'>Major electrical distruption detected: System rebooting.</span>")
						alert = 1
					if(prob(75))
						emp_damage -= 1
				if(20)
					alert = 0
					blinded = 0
					eye_blind = 0
					ear_deaf = 0
					silent = 0
					emp_damage -= 1
				if(11 to 19)//Moderate level of EMP damage, resulting in nearsightedness and ear damage
					blurEyes(1)
					ear_damage = 1
					if(!alert)
						emote("buzz")
						to_chat(src, "<span class='warning'>Primary systems are now online.</span>")
						alert = 1
					if(prob(50))
						emp_damage -= 1
				if(10)
					alert = 0
					setBlurriness(0)
					ear_damage = 0
					emp_damage -= 1
				if(2 to 9)//Low level of EMP damage, has few effects(handled elsewhere)
					if(!alert)
						emote("ping")
						to_chat(src, "<span class='warning'>System reboot nearly complete.</span>")
						alert = 1
					if(prob(25))
						emp_damage -= 1
				if(1)
					alert = 0
					to_chat(src, "<span class='warning'>All systems restored.</span>")
					emp_damage -= 1

		//Other
		if(stuttering)
			AdjustStuttering(-1)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			adjustDrugginess(-1)
	return 1

/mob/living/carbon/brain/handle_regular_hud_updates()
	if(!client)
		return

	update_sight()

	..()
