/mob/living/carbon/human
	var/prev_gender = null // Debug for plural genders


/mob/living/carbon/human/Life(seconds)
	set invisibility = 0
	set background = 1

	if (notransform)
		return
	if(!loc)
		return	// Fixing a null error that occurs when the mob isn't found in the world -- TLE

	..()

	/*
	//This code is here to try to determine what causes the gender switch to plural error. Once the error is tracked down and fixed, this code should be deleted
	//Also delete var/prev_gender once this is removed.
	if(prev_gender != gender)
		prev_gender = gender
		if(gender in list(PLURAL, NEUTER))
			message_admins("[src] ([ckey]) gender has been changed to plural or neuter. Please record what has happened recently to the person and then notify coders. (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>)  (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?priv_msg=\ref[src]'>PM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>)")
	*/
	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null
	reset_alerts()

	//TODO: seperate this out
	// update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++
	var/datum/gas_mixture/environment = loc.return_air()

	voice = GetVoice()

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD && !IS_IN_STASIS(src))
		if(SSmobs.times_fired%4==2 || failed_last_breath || (health < config.health_threshold_crit)) 	//First, resolve location and get a breath
			breathe() 				//Only try to take a breath every 4 ticks, unless suffocating

		else //Still give containing object the chance to interact
			if(isobj(loc))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		if(stat != DEAD) // incase if anyone wonder why - mob can die while any of those procs run, so we recheck stat where needed.
			//Mutations and radiation
			handle_mutations_and_radiation()

		if(stat != DEAD)
			//Disabilities
			handle_disabilities()

			//Random events (vomiting etc)
			handle_random_events()

			handle_virus_updates()

			handle_shock()

			handle_pain()

			handle_heart_beat()

			//This block was in handle_regular_status_updates under != DEAD
			stabilize_body_temperature()	//Body temperature adjusts itself
			handle_bodyparts()	//Optimized.
			if(!species.flags[NO_BLOOD] && bodytemperature >= 170)
				handle_blood()

			handle_drunkenness()

	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000))	//We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
		return											//We go ahead and process them 5 times for HUD images and other stuff though.

	//Chemicals in the body
	handle_chemicals_in_body()

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)		//Optimized a good bit.

	//Check if we're on fire
	handle_fire()

	//Status updates, death etc.
	handle_regular_status_updates()		//Optimized a bit
	update_canmove()

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name() // why in life wtf

	//Species-specific update.
	if(species)
		species.on_life(src)

	pulse = handle_pulse()

	if(client)
		handle_alerts()

//Much like get_heat_protection(), this returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
/mob/living/carbon/human/proc/get_pressure_protection(pressure_check = STOPS_PRESSUREDMAGE)
	var/pressure_adjustment_coefficient = 1	//Determins how much the clothing you are wearing protects you in percent.

	if((head && (head.flags_pressure & pressure_check))&&(wear_suit && (wear_suit.flags_pressure & pressure_check)))
		pressure_adjustment_coefficient = 0

		//Handles breaches in your space suit. 10 suit damage equals a 100% loss of pressure reduction.
		if(istype(wear_suit,/obj/item/clothing/suit/space))
			var/obj/item/clothing/suit/space/S = wear_suit
			if(S.can_breach && S.damage)
				var/pressure_loss = S.damage * 0.1
				pressure_adjustment_coefficient = pressure_loss

	pressure_adjustment_coefficient = CLAMP01(pressure_adjustment_coefficient) //So it isn't less than 0 or larger than 1.
	pressure_adjustment_coefficient *= 1 - species.get_pressure_protection(src)

	return 1 - pressure_adjustment_coefficient	//want 0 to be bad protection, 1 to be good protection

/mob/living/carbon/human/calculate_affecting_pressure(pressure)
	var/pressure_difference = abs( pressure - ONE_ATMOSPHERE )

	if(pressure > ONE_ATMOSPHERE)
		pressure_difference = pressure_difference * (1 - get_pressure_protection(STOPS_HIGHPRESSUREDMAGE))
		return ONE_ATMOSPHERE + pressure_difference
	else
		pressure_difference = pressure_difference * (1 - get_pressure_protection(STOPS_LOWPRESSUREDMAGE))
		return ONE_ATMOSPHERE - pressure_difference

var/global/list/tourette_bad_words= list(
	HUMAN = list("ГОВНО","ЖОПА","ЕБАЛ","БЛЯДИНА","ХУЕСОС","СУКА","ЗАЛУПА",
 				 "УРОД","БЛЯ","ХЕР","ШЛЮХА","ДАВАЛКА","ПИЗДЕЦ","УЕБИЩЕ",
				 "ПИЗДА","ЕЛДА","ШМАРА","СУЧКА","ПУТАНА","ААА","ГНИДА",
				 "ГОНДОН","ЕЛДА","КРЕТИН","НАХУЙ","ХУЙ","ЕБАТЬ","ЕБЛО"),
	TAJARAN = list("ГОВНО","ЖОПА","ЕБАЛ","БЛЯДИНА","ХУЕСОС","СУКА","ЗАЛУПА",
 				   "УРОД","БЛЯ","ХЕР","ШЛЮХА","ДАВАЛКА","ПИЗДЕЦ","УЕБИЩЕ",
	 			   "ПИЗДА","ЕЛДА","ШМАРА","СУЧКА","ПУТАНА","ААА","ГНИДА",
	 			   "ГОНДОН","ЕЛДА","КРЕТИН","НАХУЙ","ХУЙ","ЕБАТЬ","ЕБЛО"),
	UNATHI = list("ГОВНО","ЖОПА","ЕБАЛ","БЛЯДИНА","ХУЕСОС","СУКА","ЗАЛУПА",
				  "УРОД","БЛЯ","ХЕР","ШЛЮХА","ДАВАЛКА","ПИЗДЕЦ","УЕБИЩЕ",
				  "ПИЗДА","ЕЛДА","ШМАРА","СУЧКА","ПУТАНА","ААА","ГНИДА",
	 			  "ГОНДОН","ЕЛДА","КРЕТИН","НАХУЙ","ХУЙ","ЕБАТЬ","ЕБЛО"),
	VOX = list("ГОВНО", "СЕДАЛИЩЕ", "ЧКАЛ", "СПАРИВАЛ", "ТВАРЬ",
	 		   "ГНИЛОЙ", "МРАЗЬ", "ХВОСТ", "НАХВОСТ", "ХВОСТОЛИЗ",
			   "КЛОАКА", "СКРЯТЬ", "СКАРАПУШ", "САМКА", "СКРЯПЫШ")
			   )

/mob/living/carbon/human/proc/handle_disabilities()
	SEND_SIGNAL(src, COMSIG_HANDLE_DISABILITIES)
	if ((disabilities & COUGHING || HAS_TRAIT(src, TRAIT_COUGH)) && !reagents.has_reagent("dextromethorphan"))
		if (prob(5) && !paralysis)
			drop_item()
			spawn( 0 )
				emote("cough")
				return
	if (disabilities & TOURETTES || HAS_TRAIT(src, TRAIT_TOURETTE))
		if(!(get_species() in tourette_bad_words))
			return
		speech_problem_flag = 1
		if (prob(10))
			spawn( 0 )
				switch(rand(1, 3))
					if(1)
						emote("twitch")
					if(2 to 3)
						say(pick(tourette_bad_words[get_species()]))
				var/old_x = pixel_x
				var/old_y = pixel_y
				if(prob(25))
					shake_camera(src, rand(1, 2), 4)
					spin(4, 1)
				pixel_x += rand(-2,2)
				pixel_y += rand(-1,1)
				sleep(2)
				pixel_x = old_x
				pixel_y = old_y
				return
	if (disabilities & NERVOUS || HAS_TRAIT(src, TRAIT_NERVOUS))
		speech_problem_flag = 1
		if (prob(10))
			Stuttering(10)

	if(stat != DEAD)
		if(gnomed) // if he's dead he's gnomed foreva-a-ah
			if(prob(6))
				say(pick("A-HA-HA-HA!", "U-HU-HU-HU!", "IM A GNOME", "I'm a GnOme!", "Don't GnoMe me!", "I'm gnot a gnoblin!", "You've been GNOMED!"))
				playsound(src, 'sound/magic/GNOMED.ogg', VOL_EFFECTS_MASTER)
			gnomed--
			if(gnomed <= 0)
				to_chat(src, "<span class='notice'>You are no longer gnomed!</span>")
				gnomed = FALSE
				if(wear_mask)
					wear_mask.canremove = TRUE
				if(head)
					head.canremove = TRUE
				if(w_uniform)
					w_uniform.canremove = TRUE
				if(wear_suit)
					remove_from_mob(wear_suit)
				var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
				smoke.set_up(3, 0, src.loc)
				smoke.start()
				playsound(src, 'sound/magic/cult_revive.ogg', VOL_EFFECTS_MASTER)
				if(SMALLSIZE in mutations)
					dna.SetSEState(SMALLSIZEBLOCK, 0)
					domutcheck(src, null)

		switch(rand(0, 200))
			if(0 to 3)
				if(getBrainLoss() >= 5)
					custom_pain("Your head feels numb and painful.")

			if(4 to 6)
				if(getBrainLoss() >= 15 && eye_blurry <= 0)
					to_chat(src, "<span class='warning'>It becomes hard to see for some reason.</span>")
					blurEyes(10)

			if(7 to 9)
				if(getBrainLoss() >= 35 && get_active_hand())
					to_chat(src, "<span class='warning'>Your hand won't respond properly, you drop what you're holding.</span>")
					drop_item()

			if(10 to 12)
				if(getBrainLoss() >= 50 && !lying)
					to_chat(src, "<span class='warning'>Your legs won't respond properly, you fall down.</span>")
					SetCrawling(TRUE)

			if(13 to 18)
				if(getBrainLoss() >= 60 && (!HAS_TRAIT(src, TRAIT_STRONGMIND) || get_species() != SKRELL))
					switch(rand(1, 3))
						if(1)
							say(pick("азазаа!", "Я не смалгей!", "ХОС ХУЕСОС!", "[pick("", "ебучий трейтор")] [pick("морган", "моргун", "морген", "мрогун")] [pick("джемес", "джамес", "джаемес")] грефонет миня шпасит;е!!!", "ти можыш дать мне [pick("тилипатию","халку","эпиллепсию")]?", "ХАчу стать боргом!", "ПОЗОвите детектива!", "Хочу стать мартышкой!", "ХВАТЕТ ГРИФОНЕТЬ МИНЯ!!!!", "ШАТОЛ!"))
						if(2)
							say(pick("Как минять руки?","ебучие фурри!", "Подебил", "Проклятые трапы!", "лолка!", "вжжжжжжжжж!!!", "джеф скваааад!", "БРАНДЕНБУРГ!", "БУДАПЕШТ!", "ПАУУУУУК!!!!", "ПУКАН БОМБАНУЛ!", "ПУШКА", "РЕВА ПОЦОНЫ", "Пати на хопа!"))
						if(3)
							emote("drool")

			if(19 to 200)
				return

/mob/living/carbon/human/proc/handle_mutations_and_radiation()

	if(species.flags[IS_SYNTHETIC]) //Robots don't suffer from mutations or radloss.
		return

	// DNA2 - Gene processing.
	// The HULK stuff that was here is now in the hulk gene.
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			speech_problem_flag = 1
			gene.OnMobLife(src)

	if(dna_inject_count > 0 && prob(2))
		dna_inject_count--

	if(radiation)
		if(species.flags[RAD_IMMUNE])
			return

		if (radiation > 100)
			radiation = 100
			if(!species.flags[RAD_ABSORB])
				Stun(5)
				Weaken(10)
				if(!lying)
					to_chat(src, "<span class='warning'>You feel weak.</span>")
					emote("collapse")

		if (radiation < 0)
			radiation = 0

		else

			if(species.flags[RAD_ABSORB])
				var/rads = radiation/25
				radiation -= rads
				nutrition += rads
				adjustBruteLoss(-(rads))
				adjustOxyLoss(-(rads))
				adjustToxLoss(-(rads))
				updatehealth()
				return

			var/damage = 0
			radiation--
			if(prob(25))
				damage = 1

			if(radiation > 50)
				radiation--
				damage = 1
				if(prob(5) && species.flags[HAS_HAIR] && prob(radiation) && (h_style != "Bald" || f_style != "Shaved"))
					h_style = "Bald"
					f_style = "Shaved"
					update_hair()
					to_chat(src, "<span class='notice'>Suddenly you lost your hair!</span>")
				if(prob(5))
					radiation -= 5
					Weaken(3)
					if(!lying)
						to_chat(src, "<span class='warning'>You feel weak.</span>")
						emote("collapse")
			if(radiation > 75)
				radiation--
				damage = 3
				if(prob(1))
					to_chat(src, "<span class='warning'>You mutate!</span>")
					randmutb(src)
					domutcheck(src,null)
					emote("gasp")

			if(damage)
				adjustToxLoss(damage)
				updatehealth()
				if (bodyparts.len)
					var/obj/item/organ/external/BP = pick(bodyparts)
					if(istype(BP))
						BP.add_autopsy_data("Radiation Poisoning", damage)

/mob/living/carbon/human/is_cant_breathe()
	return (handle_drowning() || health < config.health_threshold_crit) && !(reagents.has_reagent("inaprovaline") || HAS_TRAIT(src, TRAIT_AV))

/mob/living/carbon/human/handle_external_pre_breathing(datum/gas_mixture/breath)
	..()

	if(!is_lung_ruptured())
		if(!breath || breath.total_moles < BREATH_MOLES / 5 || breath.total_moles > BREATH_MOLES * 5)
			if(prob(5))
				rupture_lung()

/mob/living/carbon/human/breathe()
	var/datum/gas_mixture/breath = ..()

	failed_last_breath = inhale_alert

	if(breath)
		//spread some viruses while we are at it
		if (virus2.len > 0)
			if (prob(10) && get_infection_chance(src))
				for(var/mob/living/carbon/M in view(1,src))
					spread_disease_to(M)

/mob/living/carbon/human/get_breath_from_internal(volume_needed)
	if(!internal)
		return null

	if(!(HAS_TRAIT(src, TRAIT_AV) || (contents.Find(internal) && wear_mask && (wear_mask.flags & MASKINTERNALS))))
		internal = null
		return null

	//internal breath sounds
	if(internal.distribute_pressure >= 16)
		var/breathsound = pick(SOUNDIN_BREATHMASK)

		if(alpha >= 50) // leave the quietest breath for stealth
			if(istype(head, /obj/item/clothing/head/helmet/space) && istype(wear_suit, /obj/item/clothing/suit/space))
				breathsound = pick(SOUNDIN_RIGBREATH)
			else if(istype(wear_mask, /obj/item/clothing/mask/gas))
				breathsound = 'sound/misc/gasmaskbreath.ogg'

		playsound(src, breathsound, VOL_EFFECTS_MASTER, null, FALSE, null, -6)
	return internal.remove_air_volume(volume_needed)

/mob/living/carbon/human/handle_breath_temperature(datum/gas_mixture/breath)
	// Hot air hurts :(
	if(breath.temperature > species.heat_level_1)
		if(breath.temperature > species.heat_level_3)
			apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, BP_HEAD, used_weapon = "Excessive Heat")
		else if(breath.temperature > species.heat_level_2)
			apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, BP_HEAD, used_weapon = "Excessive Heat")
		else
			apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, BP_HEAD, used_weapon = "Excessive Heat")
	else if(breath.temperature < species.breath_cold_level_1)
		if(breath.temperature >= species.breath_cold_level_2)
			apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, BP_HEAD, used_weapon = "Excessive Cold")
		else if(breath.temperature >= species.breath_cold_level_3)
			apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, BP_HEAD, used_weapon = "Excessive Cold")
		else
			apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, BP_HEAD, used_weapon = "Excessive Cold")

	//breathing in hot/cold air also heats/cools you a bit
	var/affecting_temp = (breath.temperature - bodytemperature) * breath.return_relative_density()

	adjust_bodytemperature(affecting_temp / 5, use_insulation = TRUE, use_steps = TRUE)

/mob/living/carbon/human/handle_suffocating(datum/gas_mixture/breath)
	if(suiciding)
		adjustOxyLoss(HUMAN_MAX_OXYLOSS * 2)//If you are suiciding, you should die a little bit faster
	else if(health > config.health_threshold_crit)
		adjustOxyLoss(HUMAN_MAX_OXYLOSS)
	else
		adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

/mob/living/carbon/human/handle_alerts()
	if(inhale_alert)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "suffocation", /datum/mood_event/suffocation)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "suffocation")

	if(temp_alert > 0)
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "hot", /datum/mood_event/hot)
	else if(temp_alert < 0)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "cold", /datum/mood_event/cold)
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "hot")
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "hot")

	..()

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	//Moved pressure calculations here for use in skip-processing check.
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure)

	if(environment.total_moles) //space is not meant to change your body temperature.
		var/loc_temp = get_temperature(environment)

		//If you're on fire, you do not heat up or cool down based on surrounding gases.
		if(!on_fire)
			//Use heat transfer as proportional to the gas activity (density)
			var/affecting_temp = (loc_temp - bodytemperature) * environment.return_relative_density()
			//Body temperature adjusts depending on surrounding atmosphere based on your thermal protection
			adjust_bodytemperature(affecting_temp, use_insulation = TRUE, use_steps = TRUE)

	else if(!species.flags[IS_SYNTHETIC] && !species.flags[RAD_IMMUNE] && isspaceturf(get_turf(src)))
		if(istype(loc, /obj/mecha) || istype(loc, /obj/structure/transit_tube_pod))
			return
		if(HAS_ROUND_ASPECT(ROUND_ASPECT_HIGH_SPACE_RADIATION))
			irradiate_one_mob(src, 5)
		if(!(istype(head, /obj/item/clothing/head/helmet/space) && istype(wear_suit, /obj/item/clothing/suit/space)) && radiation < 100)
			irradiate_one_mob(src, 5)

	if(status_flags & GODMODE)
		return 1	//godmode

	if(bodytemperature > species.heat_level_1)
		//Body temperature is too hot.
		if(bodytemperature > species.heat_level_3)
			temp_alert = 3
			take_overall_damage(burn=HEAT_DAMAGE_LEVEL_3, used_weapon = "High Body Temperature")
		else if(bodytemperature > species.heat_level_2)
			if(on_fire)
				temp_alert = 3
				take_overall_damage(burn=HEAT_DAMAGE_LEVEL_3, used_weapon = "High Body Temperature")
			else
				temp_alert = 2
				take_overall_damage(burn=HEAT_DAMAGE_LEVEL_2, used_weapon = "High Body Temperature")
		else
			temp_alert = 1
			take_overall_damage(burn=HEAT_DAMAGE_LEVEL_1, used_weapon = "High Body Temperature")
	else if(bodytemperature < species.cold_level_1 && !istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		if(bodytemperature < species.cold_level_3)
			temp_alert = -3
			take_overall_damage(burn=COLD_DAMAGE_LEVEL_3, used_weapon = "Low Body Temperature")
		else if(bodytemperature < species.cold_level_2)
			temp_alert = -2
			take_overall_damage(burn=COLD_DAMAGE_LEVEL_2, used_weapon = "Low Body Temperature")
		else
			temp_alert = -1
			take_overall_damage(burn=COLD_DAMAGE_LEVEL_1, used_weapon = "Low Body Temperature")

	if(bodytemperature < species.cold_level_1 && get_species() == UNATHI)
		if(bodytemperature < species.cold_level_3)
			drowsyness  = max(drowsyness, 20)
		else if(prob(50) && bodytemperature < species.cold_level_2)
			drowsyness = max(drowsyness, 10)
		else if(prob(10))
			drowsyness = max(drowsyness, 2)

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

	if(adjusted_pressure > species.warning_high_pressure)
		if(adjusted_pressure > species.hazard_high_pressure)
			var/pressure_damage = min( ( (adjusted_pressure / species.hazard_high_pressure) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE)
			take_overall_damage(brute=pressure_damage, used_weapon = "High Pressure")
			pressure_alert = 2
		else
			pressure_alert = 1
	else if(adjusted_pressure < species.warning_low_pressure)
		if(adjusted_pressure >= species.hazard_low_pressure)
			pressure_alert = -1
		else
			pressure_alert = -2
			take_overall_damage(burn=LOW_PRESSURE_DAMAGE, used_weapon = "Low Pressure")

	//Check for contaminants before anything else because we don't want to skip it.
	for(var/g in environment.gas)
		if(gas_data.flags[g] & XGM_GAS_CONTAMINANT && environment.gas[g] > gas_data.overlay_limit[g] + 1)
			pl_effects()
			break

///FIRE CODE
/mob/living/carbon/human/handle_fire()
	if(..())
		return
	var/thermal_protection = get_heat_protection(30000) //If you don't have fire suit level protection, you get a temperature increase
	if(thermal_protection < 1)
		adjust_bodytemperature(BODYTEMP_HEATING_MAX)
	return
//END FIRE CODE


/*
/mob/living/carbon/human/proc/adjust_body_temperature(current, loc_temp, boost)
	var/temperature = current
	var/difference = abs(current-loc_temp)	//get difference
	var/increments// = difference/10			//find how many increments apart they are
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
*/

/mob/living/carbon/human/stabilize_body_temperature()
	if (species.flags[IS_SYNTHETIC])
		return

	var/body_temperature_difference = species.body_temperature - bodytemperature

	if (abs(body_temperature_difference) < 0.5)
		return //fuck this precision

	if(bodytemperature < species.cold_level_1) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
		if(nutrition >= 2) //If we are very, very cold we'll use up quite a bit of nutriment to heat us up.
			nutrition -= 2
		var/recovery_amt = max((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
		//world << "Cold. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Cold. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
		adjust_bodytemperature(recovery_amt)
	else if(species.cold_level_1 <= bodytemperature && bodytemperature <= species.heat_level_1)
		var/recovery_amt = body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR
		//world << "Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
		adjust_bodytemperature(recovery_amt)
	else if(bodytemperature > species.heat_level_1) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
		//We totally need a sweat system cause it totally makes sense...~
		var/recovery_amt = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers
		//world << "Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
		adjust_bodytemperature(recovery_amt)

//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, UPPER_TORSO, LOWER_TORSO, etc. See setup.dm for the full list)
/mob/living/carbon/human/proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = 0
	//Handle normal clothing
	if(head)
		if(head.max_heat_protection_temperature && head.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= head.heat_protection
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature && wear_suit.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_suit.heat_protection
	if(w_uniform)
		if(w_uniform.max_heat_protection_temperature && w_uniform.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= w_uniform.heat_protection
	if(shoes)
		if(shoes.max_heat_protection_temperature && shoes.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= shoes.heat_protection
	if(gloves)
		if(gloves.max_heat_protection_temperature && gloves.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= gloves.heat_protection
	if(wear_mask)
		if(wear_mask.max_heat_protection_temperature && wear_mask.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_mask.heat_protection

	return thermal_protection_flags

/mob/living/carbon/human/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.
	if(RESIST_HEAT in mutations) //#Z2
		return 1 //Fully protected from the fire. //##Z2

	var/thermal_protection_flags = get_heat_protection_flags(temperature)

	var/thermal_protection = 0.0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & UPPER_TORSO)
			thermal_protection += THERMAL_PROTECTION_UPPER_TORSO
		if(thermal_protection_flags & LOWER_TORSO)
			thermal_protection += THERMAL_PROTECTION_LOWER_TORSO
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT

	return min(1,thermal_protection)

//See proc/get_heat_protection_flags(temperature) for the description of this proc.
/mob/living/carbon/human/proc/get_cold_protection_flags(temperature)
	var/thermal_protection_flags = 0
	//Handle normal clothing

	if(head)
		if(head.min_cold_protection_temperature && head.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= head.cold_protection
	if(wear_suit)
		if(wear_suit.min_cold_protection_temperature && wear_suit.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_suit.cold_protection
	if(w_uniform)
		if(w_uniform.min_cold_protection_temperature && w_uniform.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= w_uniform.cold_protection
	if(shoes)
		if(shoes.min_cold_protection_temperature && shoes.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= shoes.cold_protection
	if(gloves)
		if(gloves.min_cold_protection_temperature && gloves.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= gloves.cold_protection
	if(wear_mask)
		if(wear_mask.min_cold_protection_temperature && wear_mask.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_mask.cold_protection

	return thermal_protection_flags

/mob/living/carbon/human/get_cold_protection(temperature)

	if(COLD_RESISTANCE in mutations)
		return 1 //Fully protected from the cold.

	temperature = max(temperature, 2.7) //There is an occasional bug where the temperature is miscalculated in ares with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	var/thermal_protection_flags = get_cold_protection_flags(temperature)

	var/thermal_protection = 0.0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & UPPER_TORSO)
			thermal_protection += THERMAL_PROTECTION_UPPER_TORSO
		if(thermal_protection_flags & LOWER_TORSO)
			thermal_protection += THERMAL_PROTECTION_LOWER_TORSO
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT

	return min(1,thermal_protection)

/mob/living/carbon/human/proc/handle_chemicals_in_body()
	if(get_metabolism_factor() <= 0)
		return

	if(reagents && !species.flags[IS_SYNTHETIC]) //Synths don't process reagents.
		reagents.metabolize(src)

		var/total_phoronloss = 0
		for(var/obj/item/I in src)
			if(I.contaminated)
				total_phoronloss += vsc.plc.CONTAMINATION_LOSS
		if(!(status_flags & GODMODE)) adjustToxLoss(total_phoronloss)

	if(status_flags & GODMODE)	return 0	//godmode

	species.regen(src)

	//The fucking FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(HAS_TRAIT_FROM(src, TRAIT_FAT, OBESITY_TRAIT))
		if(!has_quirk(/datum/quirk/fatness) && overeatduration < 100)
			to_chat(src, "<span class='notice'>You feel fit again!</span>")
			REMOVE_TRAIT(src, TRAIT_FAT, OBESITY_TRAIT)
			metabolism_factor.RemoveModifier("Fat")
			update_body()
			update_mutations()
			update_inv_w_uniform()
			update_inv_wear_suit()
			update_size_class()
	else
		if((has_quirk(/datum/quirk/fatness) || overeatduration >= 500) && isturf(loc))
			if(!species.flags[IS_SYNTHETIC] && !species.flags[IS_PLANT] && !species.flags[NO_FAT])
				ADD_TRAIT(src, TRAIT_FAT, OBESITY_TRAIT)
				metabolism_factor.AddModifier("Fat", base_additive = -0.3)
				update_body()
				update_mutations()
				update_inv_w_uniform()
				update_inv_wear_suit()
				update_size_class()

	AdjustConfused(-1)
	AdjustDrunkenness(-1)
	// decrement dizziness counter, clamped to 0
	if((crawling) || (buckled))
		dizziness = max(0, dizziness - 15)
		jitteriness = max(0, jitteriness - 15)
	else
		dizziness = max(0, dizziness - 3)
		jitteriness = max(0, jitteriness - 3)

	if(!species.flags[IS_SYNTHETIC])
		handle_trace_chems()

	updatehealth()

	return //TODO: DEFERRED

/mob/living/carbon/human/proc/handle_regular_status_updates()
	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
		clear_stat_indicator()
	else				//ALIVE. LIGHTS ARE ON
		updatehealth()	//TODO

		if(health <= config.health_threshold_dead || (!has_brain() && should_have_organ(O_BRAIN)))
			death()
			blinded = 1
			silent = 0
			return 1

		// the analgesic effect wears off slowly
		analgesic = max(0, analgesic - 1)

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 50) || (config.health_threshold_crit > health) )
			Paralyse(3)

			/* Done by handle_breath()
			if( health <= 20 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_reagent("inaprovaline"))
				adjustOxyLoss(1)*/
		if(species.flags[IS_SYNTHETIC])
			hallucination = 0

		if(hallucination)
			if(hallucination >= 20)
				if(hallucination > 1000)
					hallucination = 1000
				if(!handling_hal)
					spawn handle_hallucinations() //The not boring kind!

			if(hallucination <= 2)
				hallucination = 0
				setHalLoss(0)
			else
				hallucination -= 2

		else
			for(var/atom/a in hallucinations)
				qdel(a)

			if(halloss > 100)
				//src << "<span class='notice'>You're in too much pain to keep going...</span>"
				//for(var/mob/O in oviewers(src, null))
				//	O.show_messageold("<B>[src]</B> slumps to the ground, too weak to continue fighting.", 1)
				var/long_shock_allowed = !HAS_TRAIT_FROM(src, TRAIT_STEEL_NERVES, VIRUS_TRAIT)
				if(long_shock_allowed)
					if(prob(3))
						Paralyse(10)
					else
						Stun(5)
						Weaken(10)
				setHalLoss(99)

		if(paralysis)
			blinded = 1
			stat = UNCONSCIOUS
			drop_from_inventory(l_hand)
			drop_from_inventory(r_hand)
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(IsSleeping())
			blinded = TRUE
		//CONSCIOUS
		else
			stat = CONSCIOUS
			if(halloss > 0)
				if((crawling) || (buckled))
					adjustHalLoss(-3)
				else
					adjustHalLoss(-1)

		if(stat == UNCONSCIOUS)
			if(client)
				throw_stat_indicator(IND_STAT)
			else
				throw_stat_indicator(IND_STAT_NOCLIENT)
		else
			clear_stat_indicator()

		if(embedded_flag && !(life_tick % 10))
			var/list/E
			E = get_visible_implants(0)
			if(!E.len)
				embedded_flag = 0


		//Eyes
		if(should_have_organ(O_EYES) && !has_organ(O_EYES))
			blinded = 1
		else if(sdisabilities & BLIND || HAS_TRAIT(src, TRAIT_BLIND))	//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold) || istype(head, /obj/item/weapon/reagent_containers/glass/bucket))	//resting your eyes with a blindfold heals blurry eyes faster
			adjustBlurriness(-3)
			blinded = 1
		else if(eye_blurry)	//blurry eyes heal slowly
			adjustBlurriness(-1)

		//Ears
		if(sdisabilities & DEAF || HAS_TRAIT(src, TRAIT_DEAF))	//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf-1, 0)
		else if(istype(l_ear, /obj/item/clothing/ears/earmuffs) || istype(r_ear, /obj/item/clothing/ears/earmuffs))	//resting your ears with earmuffs heals ear damage faster
			ear_damage = max(ear_damage-0.15, 0)
			ear_deaf = max(ear_deaf, 1)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage-0.05, 0)

		//Other
		if(stunned)
			speech_problem_flag = 1

		if(stuttering)
			speech_problem_flag = 1
			AdjustStuttering(-1)
		if (slurring)
			speech_problem_flag = 1
			slurring = max(slurring-1, 0)
		if(silent)
			speech_problem_flag = 1
			silent = max(silent-1, 0)

		if(druggy)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "drugged", /datum/mood_event/drugged)
			adjustDrugginess(-1)

		if (drowsyness)
			drowsyness = max(0, drowsyness - 1)
			blurEyes(2)
			if(prob(5))
				emote("yawn")
				Sleeping(10 SECONDS)
				Paralyse(5)

		// If you're dirty, your gloves will become dirty, too.
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1

	return 1

/mob/living/carbon/human/update_health_hud()
	if(stat == DEAD)
		healths?.icon_state = "health7"	//DEAD healthmeter
		if(healthdoll)
			healthdoll.icon_state = "healthdoll_DEAD"
			healthdoll.cut_overlays()
		return

	if(healthdoll)
		healthdoll.cut_overlays()
		healthdoll.icon_state = "healthdoll_EMPTY"
		for(var/obj/item/organ/external/BP in bodyparts)
			if(SEND_SIGNAL(BP, COMSIG_BODYPART_UPDATING_HEALTH_HUD, src) & COMPONENT_OVERRIDE_BODYPART_HEALTH_HUD)
				continue

			if(!BP || BP.is_stump)
				continue

			var/damage = BP.burn_dam + BP.brute_dam
			var/icon_num

			if(damage <= 0)
				icon_num = 0
			else switch(damage / BP.max_damage)
				if(0 to 0.2)
					icon_num = 1
				if(0.2 to 0.4)
					icon_num = 2
				if(0.4 to 0.6)
					icon_num = 3
				if(0.6 to 0.8)
					icon_num = 4
				else
					icon_num = 5

			healthdoll.add_overlay(image('icons/hud/screen_gen.dmi',"[BP.body_zone][icon_num]"))

	if(!healths)
		return

	switch(hal_screwyhud)
		if(1)
			healths.icon_state = "health6"
			return
		if(2)
			healths.icon_state = "health7"
			return

	switch(100 - ((species && species.flags[NO_PAIN] && !species.flags[IS_SYNTHETIC]) ? 0 : traumatic_shock))
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

/mob/living/carbon/human/handle_regular_hud_updates()
	if(!client)
		return

	if(stat == UNCONSCIOUS && health <= 0)
		//Critical damage passage overlay
		var/severity = 0
		switch(health)
			if(-20 to -10)			severity = 1
			if(-30 to -20)			severity = 2
			if(-40 to -30)			severity = 3
			if(-50 to -40)			severity = 4
			if(-60 to -50)			severity = 5
			if(-70 to -60)			severity = 6
			if(-80 to -70)			severity = 7
			if(-90 to -80)			severity = 8
			if(-95 to -90)			severity = 9
			if(-INFINITY to -95)	severity = 10
		overlay_fullscreen("crit", /atom/movable/screen/fullscreen/crit, severity)
	else
		clear_fullscreen("crit")
		//Oxygen damage overlay
		if(oxyloss)
			var/severity = 0
			switch(oxyloss)
				if(10 to 20)		severity = 1
				if(20 to 25)		severity = 2
				if(25 to 30)		severity = 3
				if(30 to 35)		severity = 4
				if(35 to 40)		severity = 5
				if(40 to 45)		severity = 6
				if(45 to INFINITY)	severity = 7
			overlay_fullscreen("oxy", /atom/movable/screen/fullscreen/oxy, severity)
		else
			clear_fullscreen("oxy")

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			var/severity = 0
			switch(hurtdamage)
				if(10 to 25)		severity = 1
				if(25 to 40)		severity = 2
				if(40 to 55)		severity = 3
				if(55 to 70)		severity = 4
				if(70 to 85)		severity = 5
				if(85 to INFINITY)	severity = 6
			overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

	update_sight()

	if(stat == DEAD)
		return ..()

	if(nutrition_icon)
		var/full_perc // Nutrition pecentage
		var/fullness_icon = species.flags[IS_SYNTHETIC] ? "lowcell" : "burger"
		var/get_nutrition_max
		if (species.flags[IS_SYNTHETIC])
			var/obj/item/organ/internal/liver/IO = organs_by_name[O_LIVER]
			var/obj/item/weapon/stock_parts/cell/I = locate(/obj/item/weapon/stock_parts/cell) in IO
			if (I)
				get_nutrition_max = I.maxcharge
			else
				get_nutrition_max = 1 // IPC nutrition should be set to zero to this moment
		else
			get_nutrition_max = NUTRITION_LEVEL_FAT
		full_perc = clamp(((get_satiation() / get_nutrition_max) * 100), NUTRITION_PERCENT_ZERO, NUTRITION_PERCENT_MAX)
		nutrition_icon.icon_state = "[fullness_icon][CEILING(full_perc, 20)]"

	//OH cmon...
	var/impaired    = 0
	if(istype(head, /obj/item/clothing/head/welding) || istype(head, /obj/item/clothing/head/helmet/space/unathi))
		var/obj/item/clothing/head/welding/O = head
		if(!O.up && tinted_weldhelh)
			impaired = 2
	if(istype(wear_mask, /obj/item/clothing/mask/gas/welding) )
		var/obj/item/clothing/mask/gas/welding/O = wear_mask
		if(!O.up && tinted_weldhelh)
			impaired = 2
	if(istype(glasses, /obj/item/clothing/glasses/welding) )
		var/obj/item/clothing/glasses/welding/O = glasses
		if(!O.up && tinted_weldhelh)
			impaired = max(impaired, 2)
	if(impaired)
		overlay_fullscreen("impaired", /atom/movable/screen/fullscreen/impaired, impaired)
	else
		clear_fullscreen("impaired")

	update_eye_blur()

	if(!machine)
		var/isRemoteObserve = 0
		if((REMOTE_VIEW in mutations) && remoteview_target)
			if(getBrainLoss() <= 100)//#Z2 We burn our brain with active remote_view mutation
				if(remoteview_target.stat==CONSCIOUS)
					isRemoteObserve = 1
					if(getBrainLoss() > 50)
						adjustBrainLoss(2)
					else
						adjustBrainLoss(1)
			else
				to_chat(src, "Too hard to concentrate...")
				remoteview_target = null
				reset_view(null)//##Z2
		if(force_remote_viewing)
			isRemoteObserve = TRUE
		if(!isRemoteObserve && client && !client.adminobs)
			remoteview_target = null
			reset_view(null)

	..()

/mob/living/carbon/human/update_sight()
	if(!..())
		return FALSE

	if(daltonism)
		set_EyesVision(sightglassesmod)
		return FALSE

	see_in_dark = species.darksight

	var/obj/item/clothing/glasses/G = glasses
	if(istype(G))
		see_in_dark += G.darkness_view
		if(G.vision_flags) // MESONS
			sight |= G.vision_flags
		if(!isnull(G.lighting_alpha))
			lighting_alpha = min(lighting_alpha, G.lighting_alpha)
		if(G.sightglassesmod && (G.active || !G.toggleable))
			sightglassesmod = G.sightglassesmod
		else
			sightglassesmod = null
	else
		sightglassesmod = null

	if(species.nighteyes)
		var/light_amount = 0
		var/turf/T = get_turf(src)
		light_amount = round(T.get_lumcount()*10)
		if(light_amount < 1)
			if(sightglassesmod)
				sightglassesmod = "nightsight_glasses"
			else
				sightglassesmod = "nightsight"

	if(sightglassesmod)
		set_EyesVision(sightglassesmod)
		return TRUE

	if(moody_color)
		animate(client, color = moody_color, time = 5)
	else
		animate(client, color = null, time = 5)

	return TRUE

/mob/living/carbon/human/proc/handle_random_events()
	// Puke if toxloss is too high
	if(stat == CONSCIOUS)
		if (getToxLoss() >= 45)
			invoke_vomit_async()

	//0.1% chance of playing a scary sound to someone who's in complete darkness
	if(isturf(loc) && rand(1,1000) == 1)
		var/turf/T = loc
		if(T.get_lumcount() < 0.1)
			playsound_local(src, pick(SOUNDIN_SCARYSOUNDS), VOL_EFFECTS_MASTER)

/mob/living/carbon/human/proc/handle_virus_updates()
	if(status_flags & GODMODE)	return 0	//godmode
	if(bodytemperature > 406)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			V.cure(src)

	if(life_tick % 3) //don't spam checks over all objects in view every tick.
		for(var/obj/effect/decal/cleanable/O in view(1,src))
			if(istype(O,/obj/effect/decal/cleanable/blood))
				var/obj/effect/decal/cleanable/blood/B = O
				if(B && B.virus2 && B.virus2.len)
					for (var/ID in B.virus2)
						var/datum/disease2/disease/V = B.virus2[ID]
						if(V.spreadtype == DISEASE_SPREAD_CONTACT)
							infect_virus2(src,V.getcopy())

			else if(istype(O,/obj/effect/decal/cleanable/mucus))
				var/obj/effect/decal/cleanable/mucus/M = O
				if(M && M.virus2 && M.virus2.len)
					for (var/ID in M.virus2)
						var/datum/disease2/disease/V = M.virus2[ID]
						if(V.spreadtype == DISEASE_SPREAD_CONTACT)
							infect_virus2(src,V.getcopy())


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

/mob/living/carbon/human/handle_shock()
	..()
	if(status_flags & GODMODE)	return 0	//godmode
	if(species && species.flags[NO_PAIN])
		return
	if(analgesic && !reagents.has_reagent("prismaline"))
		return // analgesic avoids all traumatic shock temporarily

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
		to_chat(src, "<span class='danger'>[pick("It hurts so much!", "You really need some painkillers..", "Dear god, the pain!")]</span>")

	if(shock_stage >= 30)
		if(shock_stage == 30) me_emote("is having trouble keeping their eyes open.")
		blurEyes(2)
		stuttering = max(stuttering, 5)

	if(shock_stage == 40)
		to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")

	if (shock_stage >= 60)
		if(shock_stage == 60)
			visible_message("<span class='name'>[src]'s</span> body becomes limp.")
		if (prob(2))
			to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Stun(10)
			Weaken(20)

	if(shock_stage >= 80)
		if (prob(5))
			to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Stun(10)
			Weaken(20)

	if(shock_stage >= 120)
		if (prob(2))
			to_chat(src, "<span class='danger'>[pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness.")]</span>")
			Paralyse(5)

	if(shock_stage == 150)
		me_emote("can no longer stand, collapsing!")
		Stun(10)
		Weaken(20)

	if(shock_stage >= 150)
		Stun(10)
		Weaken(20)

/mob/living/carbon/human/proc/handle_heart_beat()

	if(pulse == PULSE_NONE) return

	if(pulse == PULSE_2FAST || shock_stage >= 10 || isspaceturf(get_turf(src)))

		var/temp = (5 - pulse)/2

		if(heart_beat >= temp)
			heart_beat = 0
			playsound_local(null, 'sound/effects/singlebeat.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		else if(temp != 0)
			heart_beat++

/mob/living/carbon/human/proc/handle_pulse()

	if(life_tick % 5)
		return pulse	//update pulse every 5 life ticks (~1 tick/sec, depending on server load)

	if(species && species.flags[NO_BLOOD])
		return PULSE_NONE //No blood, no pulse.

	if(HAS_TRAIT(src, TRAIT_CPB))
		return PULSE_NORM

	if(stat == DEAD)
		return PULSE_NONE	//that's it, you're dead, nothing can influence your pulse

	var/obj/item/organ/internal/heart/IO = organs_by_name[O_HEART]
	if(life_tick % 10)
		switch(IO.heart_status)
			if(HEART_FAILURE)
				to_chat(src, "<span class='userdanger'>Your feel a prick in your heart!</span>")
				apply_effect(5,AGONY,0)
				return PULSE_NONE
			if(HEART_FIBR)
				to_chat(src, "<span class='danger'>Your heart hurts a little.</span>")
				playsound_local(null, 'sound/machines/cardio/pulse_fibrillation.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
				apply_effect(1,AGONY,0)
				return PULSE_SLOW

	var/temp = PULSE_NORM

	if(blood_amount() <= BLOOD_VOLUME_BAD)	//how much blood do we have
		temp = PULSE_THREADY	//not enough :(

	if(status_flags & FAKEDEATH)
		temp = PULSE_NONE		//pretend that we're dead. unlike actual death, can be inflienced by meds

	//handles different chems' influence on pulse
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.id in bradycardics)
			if(temp <= PULSE_THREADY && temp >= PULSE_NORM)
				temp--
		if(R.id in tachycardics)
			if(temp <= PULSE_FAST && temp >= PULSE_NONE)
				temp++
		if(R.id in heartstopper) //To avoid using fakedeath
			temp = PULSE_NONE
		if(R.id in cheartstopper) //Conditional heart-stoppage
			if(R.volume >= R.overdose)
				temp = PULSE_NONE

	return temp

/mob/living/carbon/human/handle_nutrition()
	. = ..()
	if(nutrition > NUTRITION_LEVEL_WELL_FED)
		if(overeatduration < 600) //capped so people don't take forever to unfat
			overeatduration++
	else
		if(overeatduration > 1)
			overeatduration -= 2 //doubled the unfat rate

	if(species.flags[REQUIRE_LIGHT])
		if(nutrition < 200)
			take_overall_damage(2,0)
			traumatic_shock++

/*
	Called by life(), instead of having the individual hud items update icons each tick and check for status changes
	we only set those statuses and icons upon changes.  Then those HUD items will simply add those pre-made images.

*/

#undef HUMAN_MAX_OXYLOSS
#undef HUMAN_CRIT_MAX_OXYLOSS

#undef LIGHT_DAM_THRESHOLD
#undef LIGHT_HEAL_THRESHOLD
#undef LIGHT_DAMAGE_TAKEN
