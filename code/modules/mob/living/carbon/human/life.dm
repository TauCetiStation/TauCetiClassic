//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!
#define HUMAN_MAX_OXYLOSS 1 //Defines how much oxyloss humans can get per tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.
#define HUMAN_CRIT_MAX_OXYLOSS (SSmobs.wait/30) //The amount of damage you'll get when in critical condition. We want this to be a 5 minute deal = 300s. There are 50HP to get through, so (1/6)*last_tick_duration per second. Breaths however only happen every 4 ticks.

#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 4 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 8 //Amount of damage applied when your body temperature passes the 1000K point

#define COLD_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 3 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 3 //Amount of damage applied when the current breath's temperature passes the 120K point

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
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//TODO: seperate this out
	// update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++
	var/datum/gas_mixture/environment = loc.return_air()

	if(life_tick%30==15)
		hud_updateflag = 1022

	voice = GetVoice()

	handle_combat()

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD && !IS_IN_STASIS(src))
		if(SSmobs.times_fired%4==2 || failed_last_breath || (health < config.health_threshold_crit)) 	//First, resolve location and get a breath
			breathe() 				//Only try to take a breath every 4 ticks, unless suffocating

		else //Still give containing object the chance to interact
			if(istype(loc, /obj))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		if(stat != DEAD) // incase if anyone wonder why - mob can die while any of those procs run, so we recheck stat where needed.
			//Mutations and radiation
			handle_mutations_and_radiation()

		if(stat != DEAD)
			//Chemicals in the body
			handle_chemicals_in_body()

		if(stat != DEAD)
			//Disabilities
			handle_disabilities()

			//Random events (vomiting etc)
			handle_random_events()

			handle_virus_updates()

			//stuff in the stomach
			handle_stomach()

			handle_shock()

			handle_pain()

			handle_medical_side_effects()

			handle_heart_beat()

			//This block was in handle_regular_status_updates under != DEAD
			stabilize_body_temperature()	//Body temperature adjusts itself
			handle_bodyparts()	//Optimized.
			if(!species.flags[NO_BLOOD] && bodytemperature >= 170)
				var/blood_volume = round(vessel.get_reagent_amount("blood"))
				if(blood_volume > 0)
					handle_blood(blood_volume)

	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000))	//We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
		return											//We go ahead and process them 5 times for HUD images and other stuff though.

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)		//Optimized a good bit.

	//Check if we're on fire
	handle_fire()

	//Status updates, death etc.
	handle_regular_status_updates()		//Optimized a bit
	update_canmove()

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	handle_regular_hud_updates()

	//Updates the number of stored chemicals for powers and essentials
	handle_changeling()

	//Species-specific update.
	if(species)
		species.on_life(src)

	pulse = handle_pulse()


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

	return 1 - pressure_adjustment_coefficient	//want 0 to be bad protection, 1 to be good protection

/mob/living/carbon/human/calculate_affecting_pressure(var/pressure)
	..()
	var/pressure_difference = abs( pressure - ONE_ATMOSPHERE )

	if(pressure > ONE_ATMOSPHERE)
		pressure_difference = pressure_difference * (1 - get_pressure_protection(STOPS_HIGHPRESSUREDMAGE))
		return ONE_ATMOSPHERE + pressure_difference
	else
		pressure_difference = pressure_difference * (1 - get_pressure_protection(STOPS_LOWPRESSUREDMAGE))
		return ONE_ATMOSPHERE - pressure_difference

/mob/living/carbon/human/proc/handle_disabilities()
	if (disabilities & EPILEPSY || HAS_TRAIT(src, TRAIT_EPILEPSY))
		if ((prob(1) && paralysis < 1))
			visible_message("<span class='danger'>[src] starts having a seizure!</span>", self_message = "<span class='warning'>You have a seizure!</span>")
			Paralyse(10)
			make_jittery(1000)
	if ((disabilities & COUGHING || HAS_TRAIT(src, TRAIT_COUGH)) && !reagents.has_reagent("dextromethorphan"))
		if ((prob(5) && paralysis <= 1))
			drop_item()
			spawn( 0 )
				emote("cough")
				return
	if (disabilities & TOURETTES || HAS_TRAIT(src, TRAIT_TOURETTE))
		speech_problem_flag = 1
		if ((prob(10) && paralysis <= 1))
			Stun(10)
			spawn( 0 )
				switch(rand(1, 3))
					if(1)
						emote("twitch")
					if(2 to 3)
						if(config.rus_language)
							say(pick("ГОВНО", "ЖОПА", "ЕБАЛ", "ПИДАРА-АС", "ХУЕСОС", "СУКА", "МАТЬ ТВОЮ","А НУ ИДИ СЮДА","УРОД"))
						else
							say(pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS"))
				var/old_x = pixel_x
				var/old_y = pixel_y
				pixel_x += rand(-2,2)
				pixel_y += rand(-1,1)
				sleep(2)
				pixel_x = old_x
				pixel_y = old_y
				return
	if (disabilities & NERVOUS || HAS_TRAIT(src, TRAIT_NERVOUS))
		speech_problem_flag = 1
		if (prob(10))
			stuttering = max(10, stuttering)

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
					eye_blurry = 10

			if(7 to 9)
				if(getBrainLoss() >= 35 && get_active_hand())
					to_chat(src, "<span class='warning'>Your hand won't respond properly, you drop what you're holding.</span>")
					drop_item()

			if(10 to 12)
				if(getBrainLoss() >= 50 && !lying)
					to_chat(src, "<span class='warning'>Your legs won't respond properly, you fall down.</span>")
					resting = 1

			if(13 to 18)
				if(getBrainLoss() >= 60 && !HAS_TRAIT(src, TRAIT_STRONGMIND))
					if(config.rus_language)//TODO:CYRILLIC dictionary?
						switch(rand(1, 3))
							if(1)
								say(pick("азазаа!", "Я не смалгей!", "ХОС ХУЕСОС!", "[pick("", "ебучий трейтор")] [pick("морган", "моргун", "морген", "мрогун")] [pick("джемес", "джамес", "джаемес")] грефонет миня шпасит;е!!!", "ти можыш дать мне [pick("тилипатию","халку","эпиллепсию")]?", "ХАчу стать боргом!", "ПОЗОвите детектива!", "Хочу стать мартышкой!", "ХВАТЕТ ГРИФОНЕТЬ МИНЯ!!!!", "ШАТОЛ!"))
							if(2)
								say(pick("Как минять руки?","ебучие фурри!", "Подебил", "Проклятые трапы!", "лолка!", "вжжжжжжжжж!!!", "джеф скваааад!", "БРАНДЕНБУРГ!", "БУДАПЕШТ!", "ПАУУУУУК!!!!", "ПУКАН БОМБАНУЛ!", "ПУШКА", "РЕВА ПОЦОНЫ", "Пати на хопа!"))
							if(3)
								emote("drool")
					else
						switch(rand(1, 3))
							if(1)
								say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", "without oxigen blob don't evoluate?", "CAPTAINS A COMDOM", "[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", "can u give me [pick("telikesis","halk","eppilapse")]?", "THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", "I WANNA PET TEH monkeyS", "stop grifing me!!!!", "SOTP IT#"))
							if(2)
								say(pick("FUS RO DAH","fucking 4rries!", "stat me", ">my face", "roll it easy!", "waaaaaagh!!!", "red wonz go fasta", "FOR TEH EMPRAH", "lol2cat", "dem dwarfs man, dem dwarfs", "SPESS MAHREENS", "hwee did eet fhor khayosss", "lifelike texture ;_;", "luv can bloooom", "PACKETS!!!"))
							if(3)
								emote("drool")

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

/mob/living/carbon/human/proc/breathe()
	if(!need_breathe())
		return

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/breath

	//First, check if we can breathe at all
	if((handle_drowning() || health < config.health_threshold_crit) && !reagents.has_reagent("inaprovaline") && !HAS_TRAIT(src, TRAIT_AV))
		losebreath = max(2, losebreath + 1)

	if(losebreath>0) //Suffocating so do not take a breath
		losebreath--
		if (prob(10)) //Gasp per 10 ticks? Sounds about right.
			spawn emote("gasp")
		if(istype(loc, /obj))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME) // Super hacky -- TLE
		//breath = get_breath_from_internal(0.5) // Manually setting to old BREATH_VOLUME amount -- TLE

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(isobj(loc))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_MOLES)
			else if(isturf(loc))
				var/breath_moles = 0
				/*if(environment.return_pressure() > ONE_ATMOSPHERE)
					// Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
					breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
				else*/
					// Not enough air around, take a percentage of what's there to model this properly
				breath_moles = environment.total_moles * BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)

				// Handle filtering
				var/block = 0
				if(wear_mask)
					if(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1
				if(glasses)
					if(glasses.flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1
				if(head)
					if(head.flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1

				if(!block)

					for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(src, INGEST)
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
							break // If they breathe in the nasty stuff once, no need to continue checking

			if(istype(wear_mask, /obj/item/clothing/mask/gas) && breath)
				var/obj/item/clothing/mask/gas/G = wear_mask
				var/datum/gas_mixture/filtered = new
				for(var/g in  G.filter)
					if(breath.gas[g])
						filtered.gas[g] = breath.gas[g] * G.gas_filter_strength
						breath.gas[g] -= filtered.gas[g]

				breath.update_values()
				filtered.update_values()

			if(!is_lung_ruptured())
				if(!breath || breath.total_moles < BREATH_MOLES / 5 || breath.total_moles > BREATH_MOLES * 5)
					if(prob(5))
						rupture_lung()

		else //Still give containing object the chance to interact
			if(istype(loc, /obj))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	handle_breath(breath)

	if(breath)
		loc.assume_air(breath)

		//spread some viruses while we are at it
		if (virus2.len > 0)
			if (prob(10) && get_infection_chance(src))
//					log_debug("[src] : Exhaling some viruses")
				for(var/mob/living/carbon/M in view(1,src))
					src.spread_disease_to(M)

/mob/living/carbon/human/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
			internal = null
		if(internal)
					//internal breath sounds
			if(internal.distribute_pressure >= 16)
				var/breathsound = pick(SOUNDIN_BREATHMASK)
				if(istype(wear_mask, /obj/item/clothing/mask/gas))
					breathsound = 'sound/misc/gasmaskbreath.ogg'
				if(istype(head, /obj/item/clothing/head/helmet/space) && istype(wear_suit, /obj/item/clothing/suit/space))
					breathsound = pick(SOUNDIN_RIGBREATH)
				if(alpha < 50)
					breathsound = pick(SOUNDIN_BREATHMASK) // the quietest breath for stealth
				playsound(src, breathsound, VOL_EFFECTS_MASTER, null, FALSE, -6)
			return internal.remove_air_volume(volume_needed)
		else if(internals)
			internals.icon_state = "internal0"
	return null

/mob/living/carbon/human/proc/handle_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles == 0) || suiciding)
		if(suiciding)
			adjustOxyLoss(2)//If you are suiciding, you should die a little bit faster
			failed_last_breath = 1
			throw_alert("oxy", /obj/screen/alert/oxy)
			return 0
		if(health > config.health_threshold_crit)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			failed_last_breath = 1
		else
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
			failed_last_breath = 1

		throw_alert("oxy", /obj/screen/alert/oxy)

		return 0

	var/safe_pressure_min = 16 // Minimum safe partial pressure of breathable gas in kPa
	//var/safe_pressure_max = 140 // Maximum safe partial pressure of breathable gas in kPa (Not used for now)
	var/safe_exhaled_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_max = 0.005
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/inhaled_gas_used = 0

	var/breath_pressure = (breath.total_moles * R_IDEAL_GAS_EQUATION * breath.temperature) / BREATH_VOLUME

	var/inhaling = breath.gas[species.breath_type]
	var/poison = breath.gas[species.poison_type]
	var/exhaling = species.exhale_type ? breath.gas[species.exhale_type] : 0

	var/inhale_pp = (inhaling / breath.total_moles) * breath_pressure
	var/toxins_pp = (poison / breath.total_moles) * breath_pressure
	var/exhaled_pp = (exhaling / breath.total_moles) * breath_pressure

	if(inhale_pp < safe_pressure_min)
		if(prob(20))
			emote("gasp")
		if(inhale_pp > 0)
			var/ratio = inhale_pp/safe_pressure_min

			 // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
			adjustOxyLoss(min(5*(1 - ratio), HUMAN_MAX_OXYLOSS))
			failed_last_breath = 1
			inhaled_gas_used = inhaling*ratio/6

		else

			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			failed_last_breath = 1

		throw_alert("oxy", /obj/screen/alert/oxy)

	else
		// We're in safe limits
		failed_last_breath = 0
		adjustOxyLoss(-5)
		inhaled_gas_used = inhaling/6
		clear_alert("oxy")

	breath.adjust_gas(species.breath_type, -inhaled_gas_used, update = FALSE) //update afterwards

	if(species.exhale_type)
		breath.adjust_gas_temp(species.exhale_type, inhaled_gas_used, bodytemperature, update = FALSE) //update afterwards

		// CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2,
		// this will hurt you, but only once per 4 ticks, instead of once per tick.

		if(exhaled_pp > safe_exhaled_max)

			// If it's the first breath with too much CO2 in it, lets start a counter,
			// then have them pass out after 12s or so.
			if(!co2overloadtime)
				co2overloadtime = world.time

			else if(world.time - co2overloadtime > 120)

				// Lets hurt em a little, let them know we mean business
				Paralyse(3)
				adjustOxyLoss(3)

				// They've been in here 30s now, lets start to kill them for their own good!
				if(world.time - co2overloadtime > 300)
					adjustOxyLoss(8)

			// Lets give them some chance to know somethings not right though I guess.
			if(prob(20))
				spawn(0) emote("cough")
		else
			co2overloadtime = 0

	// Too much poison in the air.
	if(toxins_pp > safe_toxins_max)
		var/ratio = (poison/safe_toxins_max) * 10
		if(reagents)
			reagents.add_reagent("toxin", clamp(ratio, MIN_TOXIN_DAMAGE, MAX_TOXIN_DAMAGE))
		breath.adjust_gas(species.poison_type, -poison / 6, update = FALSE) //update after
		throw_alert("tox_in_air", /obj/screen/alert/tox_in_air)
	else
		clear_alert("tox_in_air")

	// If there's some other shit in the air lets deal with it here.
	if(breath.gas["sleeping_agent"])
		var/SA_pp = (breath.gas["sleeping_agent"] / breath.total_moles) * breath_pressure

		// Enough to make us paralysed for a bit
		if(SA_pp > SA_para_min)

			// 3 gives them one second to wake up and run away a bit!
			Paralyse(3)

			// Enough to make us sleep as well
			if(SA_pp > SA_sleep_min)
				Sleeping(10 SECONDS)

		// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
		else if(SA_pp > 0.15)
			if(prob(20))
				emote(pick("giggle", "laugh"))

		breath.adjust_gas("sleeping_agent", -breath.gas["sleeping_agent"] / 6, update = FALSE) //update after

	//handle_temperature_effects(breath)

	// Hot air hurts :(
	if( (breath.temperature < species.cold_level_1 || breath.temperature > species.heat_level_1))
	 // #Z2 Cold_resistance wont save us anymore, we have no_breath genetics power now @ZVe

		if(status_flags & GODMODE)
			return 1

		switch(breath.temperature)
			if(-INFINITY to species.cold_level_3)
				apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, BP_HEAD, used_weapon = "Excessive Cold")
			if(species.cold_level_3 to species.cold_level_2)
				apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, BP_HEAD, used_weapon = "Excessive Cold")
			if(species.cold_level_2 to species.cold_level_1)
				apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, BP_HEAD, used_weapon = "Excessive Cold")
			if(species.heat_level_1 to species.heat_level_2)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, BP_HEAD, used_weapon = "Excessive Heat")
			if(species.heat_level_2 to species.heat_level_3)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, BP_HEAD, used_weapon = "Excessive Heat")
			if(species.heat_level_3 to INFINITY)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, BP_HEAD, used_weapon = "Excessive Heat")

		//breathing in hot/cold air also heats/cools you a bit
		var/temp_adj = breath.temperature - bodytemperature
		if (temp_adj < 0)
			temp_adj /= (BODYTEMP_COLD_DIVISOR * 5)	//don't raise temperature as much as if we were directly exposed
		else
			temp_adj /= (BODYTEMP_HEAT_DIVISOR * 5)	//don't raise temperature as much as if we were directly exposed

		var/relative_density = breath.total_moles / (MOLES_CELLSTANDARD * BREATH_PERCENTAGE)
		temp_adj *= relative_density

		if (temp_adj > BODYTEMP_HEATING_MAX) temp_adj = BODYTEMP_HEATING_MAX
		if (temp_adj < BODYTEMP_COOLING_MAX) temp_adj = BODYTEMP_COOLING_MAX
		//world << "Breath: [breath.temperature], [src]: [bodytemperature], Adjusting: [temp_adj]"
		bodytemperature += temp_adj

	breath.update_values()

	return 1

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	//Moved pressure calculations here for use in skip-processing check.
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure)
	var/is_in_space = istype(get_turf(src), /turf/space)

	if(!is_in_space) //space is not meant to change your body temperature.
		var/loc_temp = get_temperature(environment)

		if(adjusted_pressure < species.warning_high_pressure && adjusted_pressure > species.warning_low_pressure && abs(loc_temp - bodytemperature) < 20 && bodytemperature < species.heat_level_1 && bodytemperature > species.cold_level_1)
			clear_alert("pressure")
			clear_alert("temp")
			return // Temperatures are within normal ranges, fuck all this processing. ~Ccomp

		//Body temperature adjusts depending on surrounding atmosphere based on your thermal protection
		var/temp_adj = 0
		//If you're on fire, you do not heat up or cool down based on surrounding gases.
		if(!on_fire)
			if(loc_temp < bodytemperature)			//Place is colder than we are
				var/thermal_protection = get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
				if(thermal_protection < 1)
					temp_adj = (1 - thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR)	//this will be negative
			else if (loc_temp > bodytemperature)			//Place is hotter than we are
				var/thermal_protection = get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
				if(thermal_protection < 1)
					temp_adj = (1 - thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)

			//Use heat transfer as proportional to the gas density. However, we only care about the relative density vs standard 101 kPa/20 C air. Therefore we can use mole ratios
			var/relative_density = (environment.total_moles / environment.volume) / (MOLES_CELLSTANDARD / CELL_VOLUME)
			temp_adj *= relative_density

			if (temp_adj > BODYTEMP_HEATING_MAX) temp_adj = BODYTEMP_HEATING_MAX
			if (temp_adj < BODYTEMP_COOLING_MAX) temp_adj = BODYTEMP_COOLING_MAX
			//world << "Environment: [loc_temp], [src]: [bodytemperature], Adjusting: [temp_adj]"
			bodytemperature += temp_adj

	else if(!species.flags[IS_SYNTHETIC] && !species.flags[IS_PLANT])
		if(istype(loc, /obj/mecha))
			return
		if(istype(loc, /obj/structure/transit_tube_pod))
			return
		var/protected = 0
		if( (head && istype(head, /obj/item/clothing/head/helmet/space)) && (wear_suit && istype(wear_suit, /obj/item/clothing/suit/space)))
			protected = 1
		if(!protected && radiation < 100)
			apply_effect(5, IRRADIATE)

	if(status_flags & GODMODE)
		return 1	//godmode

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > species.heat_level_1)
		//Body temperature is too hot.
		if(bodytemperature > species.heat_level_3)
			throw_alert("temp", /obj/screen/alert/hot, 3)
			take_overall_damage(burn=HEAT_DAMAGE_LEVEL_3, used_weapon = "High Body Temperature")
		else if(bodytemperature > species.heat_level_2)
			if(on_fire)
				throw_alert("temp", /obj/screen/alert/hot, 3)
				take_overall_damage(burn=HEAT_DAMAGE_LEVEL_3, used_weapon = "High Body Temperature")
			else
				throw_alert("temp", /obj/screen/alert/hot, 2)
				take_overall_damage(burn=HEAT_DAMAGE_LEVEL_2, used_weapon = "High Body Temperature")
		else
			throw_alert("temp", /obj/screen/alert/hot, 1)
			take_overall_damage(burn=HEAT_DAMAGE_LEVEL_1, used_weapon = "High Body Temperature")
	else if(bodytemperature < species.cold_level_1)
		if(!istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
			if(bodytemperature < species.cold_level_3)
				throw_alert("temp", /obj/screen/alert/cold, 3)
				take_overall_damage(burn=COLD_DAMAGE_LEVEL_3, used_weapon = "Low Body Temperature")
			else if(bodytemperature < species.cold_level_2)
				throw_alert("temp", /obj/screen/alert/cold, 2)
				take_overall_damage(burn=COLD_DAMAGE_LEVEL_2, used_weapon = "Low Body Temperature")
			else
				throw_alert("temp", /obj/screen/alert/cold, 1)
				take_overall_damage(burn=COLD_DAMAGE_LEVEL_1, used_weapon = "Low Body Temperature")
		else
			clear_alert("temp")
	else
		clear_alert("temp")

	if(bodytemperature < species.cold_level_1 && get_species() == UNATHI)
		if(bodytemperature < species.cold_level_3)
			drowsyness  = max(drowsyness, 20)
		else if(prob(50) && bodytemperature < species.cold_level_2)
			drowsyness = max(drowsyness, 10)
		else if(prob(10))
			drowsyness = max(drowsyness, 2)

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

	if(adjusted_pressure >= species.hazard_high_pressure)
		var/pressure_damage = min( ( (adjusted_pressure / species.hazard_high_pressure) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE)
		take_overall_damage(brute=pressure_damage, used_weapon = "High Pressure")
		throw_alert("pressure", /obj/screen/alert/highpressure, 2)
	else if(adjusted_pressure >= species.warning_high_pressure)
		throw_alert("pressure", /obj/screen/alert/highpressure, 1)
	else if(adjusted_pressure >= species.warning_low_pressure)
		clear_alert("pressure")
	else if(adjusted_pressure >= species.hazard_low_pressure)
		throw_alert("pressure", /obj/screen/alert/lowpressure, 1)
	else
		throw_alert("pressure", /obj/screen/alert/lowpressure, 2)
		apply_effect(is_in_space ? 15 : 7, AGONY, 0)
		take_overall_damage(burn=LOW_PRESSURE_DAMAGE, used_weapon = "Low Pressure")


//#Z2 - No more low pressure resistance with Cold Resistance genetic power, for now
		/*if( !(COLD_RESISTANCE in mutations))
			take_overall_damage(brute=LOW_PRESSURE_DAMAGE, used_weapon = "Low Pressure")
			pressure_alert = -2
		else
			pressure_alert = -1*/
//##Z2
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
	if((1 - thermal_protection) > 0.0001)
		bodytemperature += BODYTEMP_HEATING_MAX
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

/mob/living/carbon/human/proc/stabilize_body_temperature()
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
		bodytemperature += recovery_amt
	else if(species.cold_level_1 <= bodytemperature && bodytemperature <= species.heat_level_1)
		var/recovery_amt = body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR
		//world << "Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
		bodytemperature += recovery_amt
	else if(bodytemperature > species.heat_level_1) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
		//We totally need a sweat system cause it totally makes sense...~
		var/recovery_amt = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers
		//world << "Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
		bodytemperature += recovery_amt

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

/mob/living/carbon/human/proc/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.
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

/mob/living/carbon/human/proc/get_cold_protection(temperature)

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

/*
/mob/living/carbon/human/proc/add_fire_protection(var/temp)
	var/fire_prot = 0
	if(head)
		if(head.protective_temperature > temp)
			fire_prot += (head.protective_temperature/10)
	if(wear_mask)
		if(wear_mask.protective_temperature > temp)
			fire_prot += (wear_mask.protective_temperature/10)
	if(glasses)
		if(glasses.protective_temperature > temp)
			fire_prot += (glasses.protective_temperature/10)
	if(ears)
		if(ears.protective_temperature > temp)
			fire_prot += (ears.protective_temperature/10)
	if(wear_suit)
		if(wear_suit.protective_temperature > temp)
			fire_prot += (wear_suit.protective_temperature/10)
	if(w_uniform)
		if(w_uniform.protective_temperature > temp)
			fire_prot += (w_uniform.protective_temperature/10)
	if(gloves)
		if(gloves.protective_temperature > temp)
			fire_prot += (gloves.protective_temperature/10)
	if(shoes)
		if(shoes.protective_temperature > temp)
			fire_prot += (shoes.protective_temperature/10)

	return fire_prot

/mob/living/carbon/human/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(nodamage)
		return
	//world <<"body_part = [body_part], exposed_temperature = [exposed_temperature], exposed_intensity = [exposed_intensity]"
	var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)

	if(exposed_temperature > bodytemperature)
		discomfort *= 4

	if(mutantrace == "plant")
		discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT * 2 //I don't like magic numbers. I'll make mutantraces a datum with vars sometime later. -- Urist
	else
		discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT //Dangercon 2011 - now with less magic numbers!
	//world <<"[discomfort]"

	switch(body_part)
		if(HEAD)
			apply_damage(2.5*discomfort, BURN, BP_HEAD)
		if(UPPER_TORSO)
			apply_damage(2.5*discomfort, BURN, BP_CHEST)
		if(LEGS)
			apply_damage(0.6*discomfort, BURN, BP_L_LEG)
			apply_damage(0.6*discomfort, BURN, BP_R_LEG)
		if(ARMS)
			apply_damage(0.4*discomfort, BURN, BP_L_ARM)
			apply_damage(0.4*discomfort, BURN, BP_R_ARM)
*/

/mob/living/carbon/human/proc/handle_chemicals_in_body()

	if(reagents && !species.flags[IS_SYNTHETIC]) //Synths don't process reagents.
		reagents.metabolize(src)

		var/total_phoronloss = 0
		for(var/obj/item/I in src)
			if(I.contaminated)
				total_phoronloss += vsc.plc.CONTAMINATION_LOSS
		if(!(status_flags & GODMODE)) adjustToxLoss(total_phoronloss)

	if(status_flags & GODMODE)	return 0	//godmode

	if(species.flags[REQUIRE_LIGHT])
		var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
		if(isturf(loc)) //else, there's considered to be no light
			var/turf/T = loc
			light_amount = round((T.get_lumcount()*10)-5)

		if(is_type_organ(O_LIVER, /obj/item/organ/internal/liver/diona) && !is_bruised_organ(O_LIVER)) // Specie may require light, but only plants, with chlorophyllic plasts can produce nutrition out of light!
			nutrition += light_amount

		if(species.flags[IS_PLANT])
			if(is_type_organ(O_KIDNEYS, /obj/item/organ/internal/kidneys/diona)) // Diona's kidneys contain all the nutritious elements. Damaging them means they aren't held.
				var/obj/item/organ/internal/kidneys/KS = organs_by_name[O_KIDNEYS]
				if(!KS)
					nutrition = 0
				else if(nutrition > (500 - KS.damage*5))
					nutrition = 500 - KS.damage*5
			species.regen(src, light_amount)

	if(dna && dna.mutantrace == "shadow")
		var/light_amount = 0
		if(isturf(loc))
			var/turf/T = loc
			light_amount = round(T.get_lumcount()*10)

		if(light_amount > 2) //if there's enough light, start dying
			take_overall_damage(1,1)
		else if (light_amount < 2) //heal in the dark
			heal_overall_damage(1,1)

	if(dna && dna.mutantrace == "shadowling")
		var/light_amount = 0
		nutrition = 450 //i aint never get hongry
		if(isturf(loc))
			var/turf/T = loc
			light_amount = round(T.get_lumcount()*10)

		if(light_amount > LIGHT_DAM_THRESHOLD)
			take_overall_damage(0,LIGHT_DAMAGE_TAKEN)
			to_chat(src, "<span class='userdanger'>The light burns you!</span>")
			playsound_local(null, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		else if (light_amount < LIGHT_HEAL_THRESHOLD) //heal in the dark
			heal_overall_damage(5,5)
			adjustToxLoss(-3)
			adjustBrainLoss(-25) //gibbering shadowlings are hilarious but also bad to have
			adjustCloneLoss(-1)
			adjustOxyLoss(-10)
			SetWeakened(0)
			SetStunned(0)

	//The fucking FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(HAS_TRAIT_FROM(src, TRAIT_FAT, OBESITY_TRAIT))
		if(!has_quirk(/datum/quirk/fatness) && overeatduration < 100)
			to_chat(src, "<span class='notice'>You feel fit again!</span>")
			REMOVE_TRAIT(src, TRAIT_FAT, OBESITY_TRAIT)
			update_body()
			update_mutantrace()
			update_mutations()
			update_inv_w_uniform()
			update_inv_wear_suit()
	else
		if((has_quirk(/datum/quirk/fatness) || overeatduration >= 500) && isturf(loc))
			if(!species.flags[IS_SYNTHETIC] && !species.flags[IS_PLANT] && !species.flags[NO_FAT])
				ADD_TRAIT(src, TRAIT_FAT, OBESITY_TRAIT)
				update_body()
				update_mutantrace()
				update_mutations()
				update_inv_w_uniform()
				update_inv_wear_suit()

	// nutrition decrease
	if (nutrition > 0 && stat != DEAD)
		var/met_factor = get_metabolism_factor()
		nutrition = max(0, nutrition - met_factor * 0.1)
		if(HAS_TRAIT(src, TRAIT_STRESS_EATER))
			var/pain = getHalLoss()
			if(pain > 0)
				nutrition = max(0, nutrition - met_factor * pain * 0.01)

	if (nutrition > 450)
		if(overeatduration < 600) //capped so people don't take forever to unfat
			overeatduration++
	else
		if(overeatduration > 1)
			overeatduration -= 2 //doubled the unfat rate

	if(species.flags[REQUIRE_LIGHT])
		if(nutrition < 200)
			take_overall_damage(2,0)
			traumatic_shock++

	if (drowsyness)
		drowsyness = max(0, drowsyness - 1)
		eye_blurry = max(2, eye_blurry)
		if(prob(5))
			emote("yawn")
			Sleeping(10 SECONDS)
			Paralyse(5)

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
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

		if(hallucination)
			if(hallucination >= 20)
				if(hallucination > 1000)
					hallucination = 1000
				if(!handling_hal)
					spawn handle_hallucinations() //The not boring kind!

			if(hallucination <= 2)
				hallucination = 0
				halloss = 0
			else
				hallucination -= 2

		else
			for(var/atom/a in hallucinations)
				qdel(a)

			if(halloss > 100)
				//src << "<span class='notice'>You're in too much pain to keep going...</span>"
				//for(var/mob/O in oviewers(src, null))
				//	O.show_messageold("<B>[src]</B> slumps to the ground, too weak to continue fighting.", 1)
				if(prob(3))
					Paralyse(10)
				else
					Weaken(10)
				setHalLoss(99)

		if(paralysis)
			AdjustParalysis(-1)
			blinded = 1
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(IsSleeping())
			blinded = TRUE
		//CONSCIOUS
		else
			stat = CONSCIOUS
			if(halloss > 0)
				if(resting)
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
		if(sdisabilities & BLIND || HAS_TRAIT(src, TRAIT_BLIND))	//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold) || istype(head, /obj/item/weapon/reagent_containers/glass/bucket))	//resting your eyes with a blindfold heals blurry eyes faster
			eye_blurry = max(eye_blurry-3, 0)
			blinded = 1
		else if(eye_blurry)	//blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1, 0)

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
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened-1,0)	//before you get mad Rockdtben: I done this so update_canmove isn't called multiple times

		if(stuttering)
			speech_problem_flag = 1
			stuttering = max(stuttering-1, 0)
		if (slurring)
			speech_problem_flag = 1
			slurring = max(slurring-1, 0)
		if(silent)
			speech_problem_flag = 1
			silent = max(silent-1, 0)

		if(druggy)
			druggy = max(druggy-1, 0)

		// If you're dirty, your gloves will become dirty, too.
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1

	return 1

/mob/living/carbon/human/handle_regular_hud_updates()
	if(hud_updateflag)//? Below ?
		handle_hud_list()

	if(!client)
		return 0

	if(hud_updateflag)//Is there any reason for 2nd check? ~Zve
		handle_hud_list()

	for(var/image/hud in client.images)
		if(copytext(hud.icon_state,1,4) == "hud") //ugly, but icon comparison is worse, I believe
			client.images.Remove(hud)

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
		overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
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
			overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
		else
			clear_fullscreen("oxy")

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp
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
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

	if( stat == DEAD )
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		if(!druggy)		see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if(healths)		healths.icon_state = "health7"	//DEAD healthmeter
		if(client)
			if(client.view != world.view)
				if(locate(/obj/item/weapon/gun/energy/sniperrifle, contents))
					var/obj/item/weapon/gun/energy/sniperrifle/s = locate() in src
					if(s.zoom)
						s.toggle_zoom()

	else
		sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = species.darksight
		see_invisible = see_in_dark>2 ? SEE_INVISIBLE_LEVEL_ONE : SEE_INVISIBLE_LIVING
		if(dna)
			switch(dna.mutantrace)
				if("slime")
					see_in_dark = 3
					see_invisible = SEE_INVISIBLE_LEVEL_ONE
				if("shadow")
					see_in_dark = 8
					see_invisible = SEE_INVISIBLE_LEVEL_ONE

		if(XRAY in mutations)
			sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
			see_in_dark = 8
			if(!druggy)		see_invisible = SEE_INVISIBLE_LEVEL_TWO

		if(seer)
			var/obj/effect/rune/R = locate() in loc
			if(R && istype(R.power, /datum/cult/seer))
				see_invisible = SEE_INVISIBLE_CULT
			else
				see_invisible = SEE_INVISIBLE_LIVING
				seer = FALSE

		if(glasses)
			var/obj/item/clothing/glasses/G = glasses
			if(istype(G))
				see_in_dark += G.darkness_view
				if(G.vision_flags)		// MESONS
					sight |= G.vision_flags
					if(!druggy)
						see_invisible = SEE_INVISIBLE_MINIMUM
			if(istype(G,/obj/item/clothing/glasses/night/shadowling))
				var/obj/item/clothing/glasses/night/shadowling/S = G
				if(S.vision)
					see_invisible = SEE_INVISIBLE_LIVING
				else
					see_invisible = SEE_INVISIBLE_MINIMUM

/* HUD shit goes here, as long as it doesn't modify sight flags */
// The purpose of this is to stop xray and w/e from preventing you from using huds -- Love, Doohl

			if(istype(glasses, /obj/item/clothing/glasses/sunglasses/sechud))
				var/obj/item/clothing/glasses/sunglasses/sechud/O = glasses
				if(O.hud)
					O.hud.process_hud(src)
				if(!druggy)
					see_invisible = SEE_INVISIBLE_LIVING
			else if(istype(glasses, /obj/item/clothing/glasses/hud))
				var/obj/item/clothing/glasses/hud/O = glasses
				O.process_hud(src)
				if(!druggy)
					see_invisible = SEE_INVISIBLE_LIVING
			else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/hud/secmed))
				var/obj/item/clothing/glasses/sunglasses/hud/secmed/O = glasses
				O.process_hud(src)
				if(!druggy)
					see_invisible = SEE_INVISIBLE_LIVING

		else if(!seer)
			see_invisible = SEE_INVISIBLE_LIVING

		if(istype(wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja))
			var/obj/item/clothing/mask/gas/voice/space_ninja/O = wear_mask
			switch(O.mode)
				if(0)
					var/target_list[] = list()
					for(var/mob/living/target in oview(src))
						if( target.mind&&(target.mind.special_role||issilicon(target)) )//They need to have a mind.
							target_list += target
					if(target_list.len)//Everything else is handled by the ninja mask proc.
						O.assess_targets(target_list, src)
					if(!druggy)
						see_invisible = SEE_INVISIBLE_LIVING
				if(1)
					see_in_dark = 5
					//client.screen += global_hud.meson
					if(!druggy)
						see_invisible = SEE_INVISIBLE_MINIMUM
				if(2)
					sight |= SEE_MOBS
					//client.screen += global_hud.thermal
					if(!druggy)
						see_invisible = SEE_INVISIBLE_LEVEL_TWO
				if(3)
					sight |= SEE_TURFS
					//client.screen += global_hud.meson
					if(!druggy)
						see_invisible = SEE_INVISIBLE_MINIMUM

		if(changeling_aug)
			sight |= SEE_MOBS
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM

		if(blinded)
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_MINIMUM

		if(healths)
			if (analgesic)
				healths.icon_state = "health_health_numb"
			else
				switch(hal_screwyhud)
					if(1)
						healths.icon_state = "health6"
					if(2)
						healths.icon_state = "health7"
					else
						//switch(health - halloss)
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

		if(healthdoll)
			healthdoll.cut_overlays()
			if(stat == DEAD)
				healthdoll.icon_state = "healthdoll_DEAD"
			else
				healthdoll.icon_state = "healthdoll_EMPTY"
				for(var/obj/item/organ/external/BP in bodyparts)
					if(BP && !BP.is_stump)
						var/damage = BP.burn_dam + BP.brute_dam
						var/comparison = (BP.max_damage / 5)
						var/icon_num = 0
						if(damage)
							icon_num = 1
						if(damage > (comparison))
							icon_num = 2
						if(damage > (comparison*2))
							icon_num = 3
						if(damage > (comparison*3))
							icon_num = 4
						if(damage > (comparison*4))
							icon_num = 5
						healthdoll.add_overlay(image('icons/mob/screen_gen.dmi',"[BP.body_zone][icon_num]"))

		if(nutrition_icon)
			switch(get_nutrition())
				if(NUTRITION_LEVEL_FULL to INFINITY)
					nutrition_icon.icon_state = "fat"
				if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
					nutrition_icon.icon_state = "full"
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					nutrition_icon.icon_state = "well_fed"
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					nutrition_icon.icon_state = "fed"
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					nutrition_icon.icon_state = "hungry"
				else
					nutrition_icon.icon_state = "starving"

		if(pressure)
			pressure.icon_state = "pressure[pressure_alert]"

		if(pullin)
			if(pulling)
				pullin.icon_state = "pull1"
			else
				pullin.icon_state = "pull0"
		//OH cmon...
		var/nearsighted = 0
		var/impaired    = 0

		if(disabilities & NEARSIGHTED || HAS_TRAIT(src, TRAIT_NEARSIGHT))
			nearsighted = 1

		if(glasses)
			var/obj/item/clothing/glasses/G = glasses
			if(G.prescription)
				nearsighted = 0

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
				impaired = max(impaired, 1)

		if(eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
		else
			clear_fullscreen("blurry")

		if(druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
		else
			clear_fullscreen("high")
		if(nearsighted)
			overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		else
			clear_fullscreen("nearsighted")

		if(impaired)
			overlay_fullscreen("impaired", /obj/screen/fullscreen/impaired, impaired)
		else
			clear_fullscreen("impaired")

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


		if(mind && mind.changeling)
			hud_used.lingchemdisplay.invisibility = 0
			hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#dd66dd'>[mind.changeling.chem_charges]</font></div>"
		else
			hud_used.lingchemdisplay.invisibility = 101

	..()

	return 1

/mob/living/carbon/human/update_sight()
	sightglassesmod = null
	if(stat == DEAD)
		set_EyesVision(transition_time = 0)
		return
	if(blinded)
		set_EyesVision("greyscale")
		return
	var/obj/item/clothing/glasses/G = glasses
	if(istype(G) && G.sightglassesmod && (G.active || !G.toggleable))
		sightglassesmod = G.sightglassesmod

	if(species.nighteyes)
		var/light_amount = 0
		var/turf/T = get_turf(src)
		light_amount = round(T.get_lumcount()*10)
		if(light_amount < 1)
			if(sightglassesmod)
				sightglassesmod = "nightsight_glasses"
			else
				sightglassesmod = "nightsight"
	set_EyesVision(sightglassesmod)

/mob/living/carbon/human/proc/handle_random_events()
	// Puke if toxloss is too high
	if(!stat)
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
		for(var/datum/disease/D in viruses)
			D.cure()
		//for (var/ID in virus2) //disabled because of symptom that randomly ignites a mob, which triggers this
		//	var/datum/disease2/disease/V = virus2[ID]
		//	V.cure(src)
	if(life_tick % 3) //don't spam checks over all objects in view every tick.
		for(var/obj/effect/decal/cleanable/O in view(1,src))
			if(istype(O,/obj/effect/decal/cleanable/blood))
				var/obj/effect/decal/cleanable/blood/B = O
				if(B && B.virus2 && B.virus2.len)
					for (var/ID in B.virus2)
						var/datum/disease2/disease/V = B.virus2[ID]
						if(V.spreadtype == "Contact")
							infect_virus2(src,V.getcopy())

			else if(istype(O,/obj/effect/decal/cleanable/mucus))
				var/obj/effect/decal/cleanable/mucus/M = O
				if(M && M.virus2 && M.virus2.len)
					for (var/ID in M.virus2)
						var/datum/disease2/disease/V = M.virus2[ID]
						if(V.spreadtype == "Contact")
							infect_virus2(src,V.getcopy())


	if(virus2.len)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			if(isnull(V)) // Trying to figure out a runtime error that keeps repeating
				CRASH("virus2 nulled before calling activate()")
			else
				V.activate(src)
			// activate may have deleted the virus
			if(!V) continue

			// check if we're immune
			if(V.antigen & src.antibodies)
				V.dead = 1

	return

/mob/living/carbon/human/proc/handle_stomach()
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
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10

/mob/living/carbon/human/proc/handle_changeling()
	if(mind && mind.changeling)
		mind.changeling.regenerate()

/mob/living/carbon/human/handle_shock()
	..()
	if(status_flags & GODMODE)	return 0	//godmode
	if(analgesic || (species && species.flags[NO_PAIN])) return // analgesic avoids all traumatic shock temporarily

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
		if(shock_stage == 30) emote("me",1,"is having trouble keeping their eyes open.")
		eye_blurry = max(2, eye_blurry)
		stuttering = max(stuttering, 5)

	if(shock_stage == 40)
		to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")

	if (shock_stage >= 60)
		if(shock_stage == 60) emote("me",1,"'s body becomes limp.")
		if (prob(2))
			to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Weaken(20)

	if(shock_stage >= 80)
		if (prob(5))
			to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Weaken(20)

	if(shock_stage >= 120)
		if (prob(2))
			to_chat(src, "<span class='danger'>[pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness.")]</span>")
			Paralyse(5)

	if(shock_stage == 150)
		emote("me",1,"can no longer stand, collapsing!")
		Weaken(20)

	if(shock_stage >= 150)
		Weaken(20)

/mob/living/carbon/human/proc/handle_heart_beat()

	if(pulse == PULSE_NONE) return

	if(pulse == PULSE_2FAST || shock_stage >= 10 || istype(get_turf(src), /turf/space))

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

	var/obj/item/organ/internal/heart/IO = organs_by_name[O_HEART]
	if(IO.heart_status == HEART_FAILURE)
		return PULSE_NONE

	if(IO.heart_status == HEART_FIBR)
		return PULSE_SLOW

	if(stat == DEAD)
		return PULSE_NONE	//that's it, you're dead, nothing can influence your pulse

	var/temp = PULSE_NORM

	if(round(vessel.get_reagent_amount("blood")) <= BLOOD_VOLUME_BAD)	//how much blood do we have
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

/*
	Called by life(), instead of having the individual hud items update icons each tick and check for status changes
	we only set those statuses and icons upon changes.  Then those HUD items will simply add those pre-made images.
	This proc below is only called when those HUD elements need to change as determined by the mobs hud_updateflag.
*/


/mob/living/carbon/human/proc/handle_hud_list()

	if(hud_updateflag & 1 << HEALTH_HUD)
		var/image/holder = hud_list[HEALTH_HUD]
		if(stat == DEAD)
			holder.icon_state = "hudhealth-100" 	// X_X
		else
			holder.icon_state = "hud[RoundHealth(health)]"

		hud_list[HEALTH_HUD] = holder

	if(hud_updateflag & 1 << STATUS_HUD)
		var/foundVirus = 0
		for(var/datum/disease/D in viruses)
			if(!D.hidden[SCANNER])
				foundVirus++
		for (var/ID in virus2)
			if (ID in virusDB)
				foundVirus = 1
				break

		var/image/holder = hud_list[STATUS_HUD]
		var/image/holder2 = hud_list[STATUS_HUD_OOC]
		if(stat == DEAD)
			holder.icon_state = "huddead"
			holder2.icon_state = "huddead"
		else if(status_flags & XENO_HOST)
			holder.icon_state = "hudxeno"
			holder2.icon_state = "hudxeno"
		else if(foundVirus || iszombie(src))
			holder.icon_state = "hudill"
		else if(has_brain_worms())
			var/mob/living/simple_animal/borer/B = has_brain_worms()
			if(B.controlling)
				holder.icon_state = "hudbrainworm"
			else
				holder.icon_state = "hudhealthy"
			holder2.icon_state = "hudbrainworm"
		else
			holder.icon_state = "hudhealthy"
			if(virus2.len)
				holder2.icon_state = "hudill"
			else
				holder2.icon_state = "hudhealthy"

		hud_list[STATUS_HUD] = holder
		hud_list[STATUS_HUD_OOC] = holder2

	if(hud_updateflag & 1 << ID_HUD)
		var/image/holder = hud_list[ID_HUD]
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				holder.icon_state = "hud[ckey(I.GetJobName())]"
			else
				holder.icon_state = "hudunknown"
		else
			holder.icon_state = "hudunknown"


		hud_list[ID_HUD] = holder

	if(hud_updateflag & 1 << WANTED_HUD)
		var/image/holder = hud_list[WANTED_HUD]
		holder.icon_state = "hudblank"
		var/perpname = name
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				perpname = I.registered_name

		for(var/datum/data/record/E in data_core.general)
			if(E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						holder.icon_state = "hudwanted"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
						holder.icon_state = "hudprisoner"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Paroled"))
						holder.icon_state = "hudparoled"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
						holder.icon_state = "hudreleased"
						break
		hud_list[WANTED_HUD] = holder

	if(hud_updateflag & 1 << IMPLOYAL_HUD || hud_updateflag & 1 << IMPCHEM_HUD || hud_updateflag & 1 << IMPTRACK_HUD)
		var/image/holder1 = hud_list[IMPTRACK_HUD]
		var/image/holder2 = hud_list[IMPLOYAL_HUD]
		var/image/holder3 = hud_list[IMPCHEM_HUD]

		holder1.icon_state = "hudblank"
		holder2.icon_state = "hudblank"
		holder3.icon_state = "hudblank"

		var/has_loyal_implant = FALSE
		for(var/obj/item/weapon/implant/I in src)
			if(I.implanted)
				if(istype(I,/obj/item/weapon/implant/tracking))
					holder1.icon_state = "hud_imp_tracking"
				if(istype(I,/obj/item/weapon/implant/mindshield) && !has_loyal_implant)
					if(istype(I,/obj/item/weapon/implant/mindshield/loyalty))
						has_loyal_implant = TRUE
						holder2.icon_state = "hud_imp_loyal"
					else
						holder2.icon_state = "hud_imp_mindshield"
				if(istype(I,/obj/item/weapon/implant/chem))
					holder3.icon_state = "hud_imp_chem"

		hud_list[IMPTRACK_HUD] = holder1
		hud_list[IMPLOYAL_HUD] = holder2
		hud_list[IMPCHEM_HUD] = holder3

	if(hud_updateflag & 1 << SPECIALROLE_HUD)
		var/image/holder = hud_list[SPECIALROLE_HUD]
		holder.icon_state = "hudblank"
		if(mind)

			switch(mind.special_role)
				if("traitor","Syndicate")
					holder.icon_state = "hudsyndicate"
				if("Revolutionary")
					holder.icon_state = "hudrevolutionary"
				if("Head Revolutionary")
					holder.icon_state = "hudheadrevolutionary"
				if("Cultist")
					holder.icon_state = "hudcultist"
				if("Changeling")
					holder.icon_state = "hudchangeling"
				if("Wizard","Fake Wizard")
					holder.icon_state = "hudwizard"
				if("Death Commando")
					holder.icon_state = "huddeathsquad"
				if("Ninja")
					holder.icon_state = "hudninja"
				if("head_loyalist")
					holder.icon_state = "hudloyalist"
				if("loyalist")
					holder.icon_state = "hudloyalist"
				if("head_mutineer")
					holder.icon_state = "hudmutineer"
				if("mutineer")
					holder.icon_state = "hudmutineer"
				if("shadowling")
					holder.icon_state = "hudshadowling"
				if("thrall")
					holder.icon_state = "hudthrall"
				if("Clandestine Gang (A) Boss","Prima Gang (A) Boss","Zero-G Gang (A) Boss","Max Gang (A) Boss","Blasto Gang (A) Boss","Waffle Gang (A) Boss","North Gang (A) Boss","Omni Gang (A) Boss","Newton Gang (A) Boss","Cyber Gang (A) Boss","Donk Gang (A) Boss","Gene Gang (A) Boss","Gib Gang (A) Boss","Tunnel Gang (A) Boss","Diablo Gang (A) Boss","Psyke Gang (A) Boss","Osiron Gang (A) Boss")
					holder.icon_state = "gang_boss_a"
				if("Clandestine Gang (B) Boss","Prima Gang (B) Boss","Zero-G Gang (B) Boss","Max Gang (B) Boss","Blasto Gang (B) Boss","Waffle Gang (B) Boss","North Gang (B) Boss","Omni Gang (B) Boss","Newton Gang (B) Boss","Cyber Gang (B) Boss","Donk Gang (B) Boss","Gene Gang (B) Boss","Gib Gang (B) Boss","Tunnel Gang (B) Boss","Diablo Gang (B) Boss","Psyke Gang (B) Boss","Osiron Gang (B) Boss")
					holder.icon_state = "gang_boss_b"
				if("Clandestine Gang (A) Lieutenant","Prima Gang (A) Lieutenant","Zero-G Gang (A) Lieutenant","Max Gang (A) Lieutenant","Blasto Gang (A) Lieutenant","Waffle Gang (A) Lieutenant","North Gang (A) Lieutenant","Omni Gang (A) Lieutenant","Newton Gang (A) Lieutenant","Cyber Gang (A) Lieutenant","Donk Gang (A) Lieutenant","Gene Gang (A) Lieutenant","Gib Gang (A) Lieutenant","Tunnel Gang (A) Lieutenant","Diablo Gang (A) Lieutenant","Psyke Gang (A) Lieutenant","Osiron Gang (A) Lieutenant")
					holder.icon_state = "lieutenant_a"
				if("Clandestine Gang (B) Lieutenant","Prima Gang (B) Lieutenant","Zero-G Gang (B) Lieutenant","Max Gang (B) Lieutenant","Blasto Gang (B) Lieutenant","Waffle Gang (B) Lieutenant","North Gang (B) Lieutenant","Omni Gang (B) Lieutenant","Newton Gang (B) Lieutenant","Cyber Gang (B) Lieutenant","Donk Gang (B) Lieutenant","Gene Gang (B) Lieutenant","Gib Gang (B) Lieutenant","Tunnel Gang (B) Lieutenant","Diablo Gang (B) Lieutenant","Psyke Gang (B) Lieutenant","Osiron Gang (B) Lieutenant")
					holder.icon_state = "lieutenant_b"
				if("Clandestine Gang (A)","Prima Gang (A)","Zero-G Gang (A)","Max Gang (A)","Blasto Gang (A)","Waffle Gang (A)","North Gang (A)","Omni Gang (A)","Newton Gang (A)","Cyber Gang (A)","Donk Gang (A)","Gene Gang (A)","Gib Gang (A)","Tunnel Gang (A)","Diablo Gang (A)","Psyke Gang (A)","Osiron Gang (A)")
					holder.icon_state = "gangster_a"
				if("Clandestine Gang (B)","Prima Gang (B)","Zero-G Gang (B)","Max Gang (B)","Blasto Gang (B)","Waffle Gang (B)","North Gang (B)","Omni Gang (B)","Newton Gang (B)","Cyber Gang (B)","Donk Gang (B)","Gene Gang (B)","Gib Gang (B)","Tunnel Gang (B)","Diablo Gang (B)","Psyke Gang (B)","Osiron Gang (B)")
					holder.icon_state = "gangster_b"

			hud_list[SPECIALROLE_HUD] = holder
	hud_updateflag = 0


#undef HUMAN_MAX_OXYLOSS
#undef HUMAN_CRIT_MAX_OXYLOSS
