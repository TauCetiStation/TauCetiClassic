/mob/living/carbon/ian/Life()
	..()

	if(soap_eaten) //Yeshhh, even dead, as long as body exist or timer runs out, its a chemical reaction after all!
		hiccup()

	if(incapacitated())
		return

	//Feeding, chasing food, FOOOOODDDD
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
		throw_alert("ian_oxy")
	else
		clear_alert("ian_oxy")
	if(phoron_alert)
		throw_alert("ian_tox")
	else
		clear_alert("ian_tox")
	if(fire_alert)
		throw_alert("ian_hot")
	else
		clear_alert("ian_hot")

	return TRUE


/mob/living/carbon/ian/breathe()
	// This is Ian, he knows that every space helmet has infinite breathable air inside!
	if(!loc || istype(head, /obj/item/clothing/head/helmet/space) || reagents && reagents.has_reagent("lexorin"))
		return
	else
		..()


/mob/living/carbon/ian/handle_chemicals_in_body()
	stamina = min(stamina + 1, 100) //i don't want a whole new proc just for one variable, so i leave this here.
	..()

/mob/living/carbon/ian/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.

	if(istype(head, /obj/item/clothing/head/helmet/space) || (adjusted_pressure < WARNING_HIGH_PRESSURE && adjusted_pressure > WARNING_LOW_PRESSURE && abs(environment.temperature - 293.15) < 20 && abs(bodytemperature - 310.14) < 0.5 && environment.phoron < MOLES_PHORON_VISIBLE))
		clear_alert("pressure")
		return

	..()
