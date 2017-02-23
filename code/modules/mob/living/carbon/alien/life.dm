/mob/living/carbon/alien/Life()
	set invisibility = 0
	//set background = 1

	if(monkeyizing)
		return

	..()

	var/datum/gas_mixture/environment = loc.return_air()

	if (stat != DEAD) //still breathing

		//First, resolve location and get a breath

		if(SSmob.times_fired%4==2)
			//Only try to take a breath every 4 seconds, unless suffocating
			spawn(0) breathe()

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		//Mutations and radiation
		handle_mutations_and_radiation()

		update_icons()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)

	//stuff in the stomach
	handle_stomach()

	//Handle being on fire
	handle_fire()
	if(on_fire && fire_stacks > 0)
		fire_stacks -= 0.5
	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(client)
		handle_regular_hud_updates()


/mob/living/carbon/alien
	proc/breathe()
		if(reagents)
			if(reagents.has_reagent("lexorin")) return

		if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

		var/datum/gas_mixture/environment = loc.return_air()
		var/datum/gas_mixture/breath
		// HACK NEED CHANGING LATER
		if(health < 0)
			losebreath++

		if(losebreath>0) //Suffocating so do not take a breath
			losebreath--
			if (prob(75)) //High chance of gasping for air
				spawn emote("gasp")
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)
		else
			//First, check for air from internal atmosphere (using an air tank and mask generally)
			breath = get_breath_from_internal(BREATH_VOLUME)

			//No breath from internal atmosphere so get breath from location
			if(!breath)
				if(istype(loc, /obj/))
					var/obj/location_as_object = loc
					breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
				else if(istype(loc, /turf/))
					var/breath_moles = 0
					/*if(environment.return_pressure() > ONE_ATMOSPHERE)
						// Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
						breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
					else*/
						// Not enough air around, take a percentage of what's there to model this properly
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

					breath = loc.remove_air(breath_moles)

					// Handle chem smoke effect  -- Doohl
					for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(src, INGEST)
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
							break // If they breathe in the nasty stuff once, no need to continue checking


			else //Still give containing object the chance to interact
				if(istype(loc, /obj/))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src, 0)

		handle_breath(breath)

		if(breath)
			loc.assume_air(breath)


	proc/get_breath_from_internal(volume_needed)
		if(internal)
			if (!contents.Find(internal))
				internal = null
			if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
				internal = null
			if(internal)
				if (internals)
					internals.icon_state = "internal1"
				return internal.remove_air_volume(volume_needed)
			else
				if (internals)
					internals.icon_state = "internal0"
		return null

	proc/handle_breath(datum/gas_mixture/breath)
		if(status_flags & GODMODE)
			return

		if(!breath || (breath.total_moles == 0))
			//Aliens breathe in vaccuum
			return 0

		var/phoron_used = 0
		var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

		//Partial pressure of the phoron in our breath
		var/Toxins_pp = (breath.phoron/breath.total_moles())*breath_pressure

		if(Toxins_pp) // Detect phoron in air

			adjustToxLoss(breath.phoron*250)
			throw_alert("alien_tox")
			phoron_used = breath.phoron

		else
			clear_alert("alien_tox")

		//Breathe in phoron and out oxygen
		breath.phoron -= phoron_used
		breath.oxygen += phoron_used

		return 1



	proc/adjust_body_temperature(current, loc_temp, boost)
		var/temperature = current
		var/difference = abs(current-loc_temp)	//get difference
		var/increments// = difference/10			//find how many increments apart they are
		if(!on_fire)
			if(difference > 50)
				increments = difference/5
			else
				increments = difference/10
			var/change = increments*boost	// Get the amount to change by (x per increment)
			var/temp_change
			if(current < loc_temp)
				temperature = min(loc_temp, temperature+change)
			else if(current > loc_temp)
				temperature = max(loc_temp, temperature-change)
			temp_change = (temperature - current)
			return temp_change

	/*
	proc/get_thermal_protection()
		var/thermal_protection = 1.0
		//Handle normal clothing
		if(head && (head.body_parts_covered & HEAD))
			thermal_protection += 0.5
		if(wear_suit && (wear_suit.body_parts_covered & UPPER_TORSO))
			thermal_protection += 0.5
		if(wear_suit && (wear_suit.body_parts_covered & LEGS))
			thermal_protection += 0.2
		if(wear_suit && (wear_suit.body_parts_covered & ARMS))
			thermal_protection += 0.2
		if(wear_suit && (wear_suit.body_parts_covered & HANDS))
			thermal_protection += 0.2
		if(wear_suit && (wear_suit.flags & SUITSPACE))
			thermal_protection += 3
		if(COLD_RESISTANCE in mutations)
			thermal_protection += 5

		return thermal_protection

	proc/add_fire_protection(temp)
		var/fire_prot = 0
		if(head)
			if(head.protective_temperature > temp)
				fire_prot += (head.protective_temperature/10)
		if(wear_mask)
			if(wear_mask.protective_temperature > temp)
				fire_prot += (wear_mask.protective_temperature/10)
		if(wear_suit)
			if(wear_suit.protective_temperature > temp)
				fire_prot += (wear_suit.protective_temperature/10)


		return fire_prot
	*/

	proc/handle_regular_status_updates()
		updatehealth()

		if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
			blinded = 1
			silent = 0
		else				//ALIVE. LIGHTS ARE ON
			if(isalienadult(src))
				if(health < config.health_threshold_dead || brain_op_stage == 4.0)
					death()
					blinded = 1
					stat = DEAD
					silent = 0
					return 1
			else if(isfacehugger(src) || islarva(src))
				if(health < 0 || brain_op_stage == 4.0)
					death()
					blinded = 1
					stat = DEAD
					silent = 0
					return 1

			//UNCONSCIOUS. NO-ONE IS HOME
			if( (getOxyLoss() > 50) || (config.health_threshold_crit > health) )
				Paralyse(3)
			if(paralysis)
				AdjustParalysis(-1)
				blinded = 1
				stat = UNCONSCIOUS
			else if(sleeping)
				sleeping = max(sleeping-1, 0)
				blinded = 1
				stat = UNCONSCIOUS
			//CONSCIOUS
			else
				stat = CONSCIOUS

			/*	What in the living hell is this?*/
			if(move_delay_add > 0)
				move_delay_add = max(0, move_delay_add - rand(1, 2))

			//Eyes
			if(sdisabilities & BLIND)		//disabled-blind, doesn't get better on its own
				blinded = 1
			else if(eye_blind)			//blindness, heals slowly over time
				eye_blind = max(eye_blind-1,0)
				blinded = 1
			else if(eye_blurry)	//blurry eyes heal slowly
				eye_blurry = max(eye_blurry-1, 0)

			//Ears
			if(sdisabilities & DEAF)		//No ear damage for aliums!
				ear_deaf = 0
			else if(ear_deaf)
				ear_deaf = 0
			else if(ear_damage < 25)
				ear_damage = 0

			//Other
			if(stunned)
				AdjustStunned(-1)
				if(!stunned)
					update_icons()

			if(weakened)
				weakened = max(weakened-1,0)	//before you get mad Rockdtben: I done this so update_canmove isn't called multiple times

			if(stuttering)
				stuttering = 0

			if(silent)
				silent = 0

			if(druggy)
				druggy = 0
		return 1


	handle_regular_hud_updates()
		if(!client)
			return 0

		handle_hud_icons()

		if(pullin)
			if(pulling)
				pullin.icon_state = "pull1"
			else
				pullin.icon_state = "pull0"

		..()

		return 1


	proc/handle_hud_icons()

		handle_hud_icons_health()

		return 1

	handle_vision()

		if(stat == DEAD)
			sight |= SEE_TURFS
			sight |= SEE_MOBS
			sight |= SEE_OBJS
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		else
			sight |= SEE_MOBS
			sight &= ~SEE_TURFS
			sight &= ~SEE_OBJS
			if(nightvision)
				see_in_dark = 8
				see_invisible = SEE_INVISIBLE_MINIMUM
			else if(!nightvision)
				see_in_dark = 4
				see_invisible = 45
		..()

	proc/handle_hud_icons_health()
		return

	proc/handle_stomach()
		spawn(0)
			for(var/mob/living/M in stomach_contents)
				if(M.loc != src)
					stomach_contents.Remove(M)
					continue
				if(istype(M, /mob/living/carbon) && stat != DEAD)
					if(M.stat == DEAD)
						M.death(1)
						stomach_contents.Remove(M)
						qdel(M)
						continue
					if(SSmob.times_fired%3==1)
						if(!(status_flags & GODMODE))
							M.adjustBruteLoss(5)
						nutrition += 10


///FIRE CODE
	handle_fire()
		if(..())
			return
		adjustFireLoss(6)
		return
//END FIRE CODE

