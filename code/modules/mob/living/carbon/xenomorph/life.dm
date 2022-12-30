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

/mob/living/carbon/xenomorph/proc/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if(isxenoadult(src))
			if(health < config.health_threshold_dead)
				death()
				blinded = 1
				stat = DEAD
				silent = 0
				return 1
		else if(isfacehugger(src) || isxenolarva(src))
			if(health < 0)
				death()
				blinded = 1
				stat = DEAD
				silent = 0
				return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 50) || (config.health_threshold_crit > health) )
			Paralyse(3)
		if(paralysis)
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
			adjustBlurriness(-1)

		//Ears
		if(sdisabilities & DEAF)		//No ear damage for aliums!
			ear_deaf = 0
		else if(ear_deaf)
			ear_deaf = 0
		else if(ear_damage < 25)
			ear_damage = 0

		//Other
		if(stuttering > 0)
			setStuttering(0)

		if(silent)
			silent = 0

		if(druggy)
			setDrugginess(0)

		if(confused)
			SetConfused(0)
	return 1

/mob/living/carbon/xenomorph/update_sight()
	if(!..())
		return FALSE

	see_in_dark = 8
	set_EyesVision(null)

	if(nightvision)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		see_invisible = SEE_INVISIBLE_LIVING
	else
		lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	return TRUE

///FIRE CODE
/mob/living/carbon/xenomorph/handle_fire()
	if(..())
		return
	adjustFireLoss(12)
	return
//END FIRE CODE

//Xenomorphs will not be blind in ventilation
/mob/living/carbon/xenomorph/is_vision_obstructed()
	if(istype(loc, /obj/machinery/atmospherics/pipe))
		return FALSE
	return ..()
