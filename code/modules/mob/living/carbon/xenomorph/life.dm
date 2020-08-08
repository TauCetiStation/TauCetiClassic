/mob/living/carbon/xenomorph/Life()
	set invisibility = 0
	//set background = 1

	if(notransform)
		return

	..()

	var/datum/gas_mixture/environment = loc.return_air()

	if (stat != DEAD && !IS_IN_STASIS(src)) //still "breathing"
		//Mutations and radiation
		handle_mutations_and_radiation()

		//stuff in the stomach
		handle_stomach()

		update_icons()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)

	//Handle being on fire
	handle_fire()

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	if(client)
		handle_regular_hud_updates()

/mob/living/carbon/xenomorph/proc/adjust_body_temperature(current, loc_temp, boost)
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
/mob/living/carbon/xenomorph/proc/get_thermal_protection()
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

/mob/living/carbon/xenomorph/proc/add_fire_protection(temp)
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

/mob/living/carbon/xenomorph/proc/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if(isxenoadult(src))
			if(health < config.health_threshold_dead || !has_brain())
				death()
				blinded = 1
				stat = DEAD
				silent = 0
				return 1
		else if(isfacehugger(src) || isxenolarva(src))
			if(health < 0 || !has_brain())
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
		else if(IsSleeping())
			blinded = TRUE
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


/mob/living/carbon/xenomorph/handle_regular_hud_updates()
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


/mob/living/carbon/xenomorph/proc/handle_hud_icons()

	handle_hud_icons_health()

	return 1

/mob/living/carbon/xenomorph/handle_vision()

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

/mob/living/carbon/xenomorph/proc/handle_hud_icons_health()
	return

/mob/living/carbon/xenomorph/proc/handle_stomach()
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
				if(SSmobs.times_fired%3==1)
					if(!(status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10


///FIRE CODE
/mob/living/carbon/xenomorph/handle_fire()
	if(..())
		return
	adjustFireLoss(6)
	return
//END FIRE CODE
