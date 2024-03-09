/mob/living/carbon/atom_init()
	. = ..()
	carbon_list += src

/mob/living/carbon/Destroy()
	carbon_list -= src
	return ..()

/mob/living/carbon/Life()
	if(!loc)
		return

	..()

	// Increase germ_level regularly
	if(germ_level < GERM_LEVEL_AMBIENT && prob(80) && !IS_IN_STASIS(src))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
		germ_level++

/mob/living/carbon/proc/reset_alerts()
	inhale_alert = FALSE
	poison_alert = FALSE
	pressure_alert = 0
	temp_alert = 0

/mob/living/carbon/proc/handle_alerts()
	if(inhale_alert)
		throw_alert("oxy", /atom/movable/screen/alert/oxy)
	else
		clear_alert("oxy")

	if(poison_alert)
		throw_alert("tox", /atom/movable/screen/alert/tox_in_air)
	else
		clear_alert("tox")

	if(temp_alert > 0)
		throw_alert("temp", /atom/movable/screen/alert/hot, temp_alert)
	else if(temp_alert < 0)
		throw_alert("temp", /atom/movable/screen/alert/cold, -temp_alert)
	else
		clear_alert("temp")

	if(pressure_alert > 0)
		throw_alert("pressure", /atom/movable/screen/alert/highpressure, pressure_alert)
	else if(pressure_alert < 0)
		throw_alert("pressure", /atom/movable/screen/alert/lowpressure, -pressure_alert)
	else
		clear_alert("pressure")

/mob/living/carbon/proc/is_skip_breathe()
	return !loc || (flags & GODMODE)

/mob/living/carbon/proc/is_cant_breathe()
	return handle_drowning() || health < 0

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	return null

/mob/living/carbon/proc/handle_external_pre_breathing(datum/gas_mixture/breath)
	if(istype(wear_mask, /obj/item/clothing/mask/gas) && breath)
		var/obj/item/clothing/mask/gas/G = wear_mask
		for(var/g in  G.filter)
			if(breath.gas[g])
				breath.gas[g] -= breath.gas[g] * G.gas_filter_strength

		breath.update_values()

/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	if(breath.temperature > BODYTEMP_HEAT_DAMAGE_LIMIT) // Hot air hurts :(
		if(prob(20))
			to_chat(src, "<span class='warning'>You feel a searing heat in your lungs!</span>")
		temp_alert = 1

/mob/living/carbon/proc/handle_suffocating(datum/gas_mixture/breath)
	adjustOxyLoss(HUMAN_MAX_OXYLOSS)

/mob/living/carbon/proc/handle_breath(datum/gas_mixture/breath)
	var/const/safe_pressure_min = 16 // Minimum safe partial pressure of breathable gas in kPa
	var/const/safe_exhaled_max = 10 // Yes it's an arbitrary value who cares?
	var/const/safe_toxins_max = 0.005
	var/const/safe_fractol_max = 0.15
	var/const/SA_para_min = 1
	var/const/SA_sleep_min = 5
	var/const/SA_giggle_min = 0.15

	var/list/breath_gas = breath.gas
	var/breath_total_moles = breath.total_moles

	var/inhale_type = inhale_gas
	var/exhale_type = exhale_gas
	var/poison_type = poison_gas

	var/inhaling = breath_gas[inhale_type]
	var/exhaling = breath_gas[exhale_type]
	var/poison = breath_gas[poison_type]
	var/sleeping_agent = breath_gas["sleeping_agent"]

	var/inhaled_gas_used = 0
	var/breath_pressure = breath.return_pressure()

	var/inhale_pp = inhaling ? (inhaling / breath_total_moles) * breath_pressure : 0
	var/exhaled_pp = exhaling ? (exhaling / breath_total_moles) * breath_pressure : 0
	var/poison_pp = poison ? (poison / breath_total_moles) * breath_pressure : 0
	var/SA_pp = sleeping_agent ? (sleeping_agent / breath_total_moles) * breath_pressure : 0

	// Anyone can breath this!
	var/druggy_inhale_type = "fractol"
	var/druggy_inhaling = breath_gas[druggy_inhale_type]
	var/druggy_inhale_pp = druggy_inhaling ? (druggy_inhaling / breath_total_moles) * breath_pressure : 0

	inhale_type = inhale_pp >= druggy_inhale_pp ? inhale_type : druggy_inhale_type
	inhaling = inhale_pp >= druggy_inhale_pp ? inhaling : druggy_inhaling
	inhale_pp = inhale_pp >= druggy_inhale_pp ? inhale_pp : druggy_inhale_pp

	if(inhale_pp < safe_pressure_min)
		if(prob(20))
			emote("gasp")
		if(inhale_pp > 0)
			var/ratio = inhale_pp / safe_pressure_min

			// Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS * (1 - ratio))
			inhaled_gas_used = inhaling * ratio * BREATH_USED_PART
		else
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)

		inhale_alert = TRUE
	else
		// We're in safe limits
		adjustOxyLoss(-5)
		inhaled_gas_used = inhaling * BREATH_USED_PART

	breath.adjust_gas(inhale_type, -inhaled_gas_used, update = FALSE) //update afterwards

	if(exhale_type)
		breath.adjust_gas_temp(exhale_type, inhaled_gas_used, bodytemperature, update = FALSE) //update afterwards

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
				emote("cough")
		else
			co2overloadtime = null

	if(druggy_inhale_pp > safe_fractol_max)
		adjustDrugginess(1)
		if(prob(5))
			emote("twitch")
			random_move()
		else if(prob(7))
			emote(pick("drool","moan","giggle"))

	// Too much poison in the air.
	if(poison_pp > safe_toxins_max)
		var/ratio = (poison / safe_toxins_max) * 10
		if(reagents)
			reagents.add_reagent("toxin", clamp(ratio, MIN_TOXIN_DAMAGE, MAX_TOXIN_DAMAGE))
		breath.adjust_gas(poison_type, -poison * BREATH_USED_PART, update = FALSE) //update after
		poison_alert = TRUE

	// If there's some other shit in the air lets deal with it here.
	if(sleeping_agent)
		// Enough to make us paralysed for a bit
		if(SA_pp > SA_para_min)
			// 3 gives them one second to wake up and run away a bit!
			Paralyse(3)

			// Enough to make us sleep as well
			if(SA_pp > SA_sleep_min)
				Sleeping(10 SECONDS)

		// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
		else if(SA_pp > SA_giggle_min)
			if(prob(20))
				emote(pick("giggle", "laugh"))

		breath.adjust_gas("sleeping_agent", -sleeping_agent * BREATH_USED_PART, update = FALSE) //update after

	handle_breath_temperature(breath)

	breath.update_values()

/mob/living/carbon/proc/breathe()
	if(is_skip_breathe())
		return null

	//First, check if we can breathe at all
	if(suiciding || is_cant_breathe())
		losebreath = max(2, losebreath + 1)

	if(losebreath > 0) //Suffocating so do not take a breath
		losebreath--
		if (prob(10)) //Gasp per 10 ticks? Sounds about right.
			emote("gasp")
		if(isobj(loc))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)

		handle_suffocating()
		inhale_alert = TRUE
		return null

	//First, check for air from internal atmosphere (using an air tank and mask generally)
	var/datum/gas_mixture/breath = get_breath_from_internal(BREATH_VOLUME)

	if(breath)
		if(isobj(loc)) //Still give containing object the chance to interact
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else //No breath from internal atmosphere so get breath from location
		if(isobj(loc))
			var/obj/location_as_object = loc
			breath = location_as_object.handle_internal_lifeform(src, BREATH_MOLES)
		else if(isturf(loc))
			var/datum/gas_mixture/environment = loc.return_air()
			breath = loc.remove_air(environment.total_moles * BREATH_PERCENTAGE)

			if(!(wear_mask && (wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)))
				for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
					if(smoke.reagents.total_volume)
						smoke.reagents.reaction(src, INGEST)
						spawn(5)
							if(smoke)
								smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
						break

		handle_external_pre_breathing(breath)

	if(!breath || (breath.total_moles <= 0))
		handle_suffocating()
		inhale_alert = TRUE
		return

	breath.volume = BREATH_VOLUME

	handle_breath(breath)

	loc.assume_air(breath)

	return breath

/mob/living/carbon/calculate_affecting_pressure(pressure)
	return pressure

/mob/living/carbon/proc/stabilize_body_temperature()
	adjust_bodytemperature((BODYTEMP_NORMAL - bodytemperature) / BODYTEMP_AUTORECOVERY_DIVISOR)

/mob/living/carbon/handle_environment(datum/gas_mixture/environment)
	if(stat != DEAD) // lets put this shit somewhere here
		stabilize_body_temperature()

	if(!environment)
		return

	var/pressure = environment.return_pressure()
	var/temperature = environment.temperature
	var/affecting_temp = (temperature - bodytemperature) * environment.return_relative_density()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.

	if(!on_fire)
		adjust_bodytemperature(affecting_temp, use_insulation = TRUE, use_steps = TRUE)

	if(flags & GODMODE)
		return

	switch(bodytemperature)
		if(BODYTEMP_HEAT_DAMAGE_LIMIT to INFINITY)
			temp_alert = 2
			adjustFireLoss(HEAT_DAMAGE_LEVEL_2)
		if(-INFINITY to BODYTEMP_COLD_DAMAGE_LIMIT)
			temp_alert = -2
			adjustFireLoss(COLD_DAMAGE_LEVEL_2)

	//Account for massive pressure differences
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 ) * PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			pressure_alert = 2
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			pressure_alert = 1
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			pressure_alert = -1
		if(-INFINITY to HAZARD_LOW_PRESSURE)
			if( !(COLD_RESISTANCE in mutations) )
				adjustBruteLoss( LOW_PRESSURE_DAMAGE )
				pressure_alert = -2
			else
				pressure_alert = -1

/mob/living/carbon/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	var/turf/oldLoc = loc

	. = ..()

	if(!. || ISDIAGONALDIR(Dir))
		return .

	handle_phantom_move(NewLoc, Dir)

	if(HAS_TRAIT(src, TRAIT_FAT) && m_intent == "run" && bodytemperature <= 360)
		adjust_bodytemperature(2)

	// Moving around increases germ_level faster
	if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
		germ_level++

	handle_rig_move(NewLoc, Dir)

	handle_footsteps(oldLoc, NewLoc, Dir)

/mob/living/carbon/proc/handle_footsteps(turf/oldLoc, turf/newLoc, Dir)
	if(lying && !crawling)
		return

	// check if oldLoc and newLoc are turfs and at least one doesn't have the NOBLOODY flag
	if(!isturf(oldLoc) || !isturf(newLoc) || ((oldLoc.flags & NOBLOODY) && (newLoc.flags & NOBLOODY)))
		return

	// Tracking blood
	var/list/bloodDNA = null
	var/datum/dirt_cover/blooddatum
	if(shoes)
		var/obj/item/clothing/shoes/S = shoes
		if(S.track_blood && S.blood_DNA)
			bloodDNA   = S.blood_DNA
			blooddatum = new/datum/dirt_cover(S.dirt_overlay)
			S.track_blood--
	else
		if(track_blood && feet_blood_DNA)
			bloodDNA   = feet_blood_DNA
			blooddatum = new/datum/dirt_cover(feet_dirt_color)
			track_blood--

	if (bloodDNA)
		oldLoc.AddTracks(src, bloodDNA, 0, Dir, blooddatum) // from
		newLoc.AddTracks(src, bloodDNA, Dir, 0, blooddatum) // to

/mob/living/carbon/relaymove(mob/user, direction)
	if(isessence(user))
		user.setMoveCooldown(1)
		var/mob/living/parasite/essence/essence = user
		if(!(essence.flags_allowed & ESSENCE_PHANTOM))
			to_chat(user, "<span class='userdanger'>Your host forbrade you to own phantom</span>")
			return

		if(!essence.phantom.showed)
			essence.phantom.show_phantom()
			return
		var/tile = get_turf(get_step(essence.phantom, direction))
		if(get_dist(tile, essence.host) < 8)
			essence.phantom.set_dir(direction)
			essence.phantom.loc = tile
		return

/mob/living/carbon/attack_animal(mob/living/simple_animal/attacker)
	if(istype(attacker, /mob/living/simple_animal/headcrab))
		var/mob/living/simple_animal/headcrab/crab = attacker
		crab.Infect(src)
		return TRUE
	return ..()

/mob/living/carbon/gib()
	for(var/mob/M in src)
		M.loc = src.loc
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")
	. = ..()

/mob/living/carbon/MiddleClickOn(atom/A)
	if(mind)
		var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
		if(stat == CONSCIOUS && C && C.chosen_sting && (iscarbon(A)) && (A != src))
			next_click = world.time + 5
			C.chosen_sting.try_to_sting(src, A)
		else
			..()

/mob/living/carbon/AltClickOn(atom/A)
	if(mind)
		var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
		if(stat == CONSCIOUS && C && C.chosen_sting && (iscarbon(A)) && (A != src))
			next_click = world.time + 5
			C.chosen_sting.try_to_sting(src, A)
		else
			..()

/mob/living/carbon/attack_unarmed(mob/living/carbon/attacker)
	if(istype(attacker))
		var/spread = TRUE
		if(ishuman(attacker))
			var/mob/living/carbon/human/H = attacker
			if(H.gloves)
				spread = FALSE

		if(spread)
			attacker.spread_disease_to(src, DISEASE_SPREAD_CONTACT)

	return ..()

/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
	if(status_flags & GODMODE)	return 0	//godmode

	var/turf/T = get_turf(src)
	var/obj/effect/fluid/F = locate() in T
	if(F)
		attack_log += "\[[time_stamp()]\]<font color='red'> [src] was shocked by the [source] and started chain-reaction with water!</font>"
		msg_admin_attack("[key_name(src)] was shocked by the [source] and started chain-reaction with water!", src)
		F.electrocute_act(shock_damage)

	shock_damage *= siemens_coeff
	if(shock_damage<1)
		return 0
	if(def_zone)
		apply_damage(shock_damage, BURN, def_zone, used_weapon = "Electrocution")
	else
		take_overall_damage(burn = shock_damage, used_weapon = "Electrocution")

	if(shock_damage > 10)
		playsound(src, 'sound/effects/electric_shock.ogg', VOL_EFFECTS_MASTER, tesla_shock ? 10 : 50, FALSE) //because Tesla proc causes a lot of sounds
		visible_message(
			"<span class='rose'>[src] was shocked by the [source]!</span>", \
			"<span class='danger'>You feel a powerful shock course through your body!</span>", \
			"<span class='rose'>You hear a heavy electrical crack.</span>" \
		)
		make_jittery(1000)
		AdjustStuttering(2)
		if(!tesla_shock || (tesla_shock && siemens_coeff > 0.5))
			Stun(2)
		spawn(20)
			jitteriness = max(jitteriness - 990, 10) //Still jittery, but vastly less
			if(!tesla_shock || (tesla_shock && siemens_coeff > 0.5))
				Stun(8)
				Weaken(8)
	else
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		visible_message(
			"<span class='rose'>[src] was mildly shocked by the [source].</span>", \
			"<span class='rose'>You feel a mild shock course through your body.</span>", \
			"<span class='rose'>You hear a light zapping.</span>" \
		)
	return shock_damage


/mob/living/carbon/swap_hand()
	var/obj/item/item_in_hand = get_active_hand()
	if(SEND_SIGNAL(src, COMSIG_MOB_SWAP_HANDS, item_in_hand) & COMPONENT_BLOCK_SWAP)
		to_chat(src, "<span class='warning'>Your other hand is too busy holding [item_in_hand].</span>")
		return

	if(item_in_hand)
		SEND_SIGNAL(item_in_hand, COMSIG_ITEM_BECOME_INACTIVE, src)

	src.hand = !( src.hand )
	item_in_hand = get_active_hand()
	if(item_in_hand)
		SEND_SIGNAL(item_in_hand, COMSIG_ITEM_BECOME_ACTIVE, src)
	if(hud_used && l_hand_hud_object && r_hand_hud_object)
		l_hand_hud_object.update_icon(src)
		r_hand_hud_object.update_icon(src)

	/*if (!( src.hand ))
		src.hands.dir = NORTH
	else
		src.hands.dir = SOUTH*/
	return

/mob/living/carbon/proc/activate_hand(selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()

/mob/living/carbon/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	help_shake_act(attacker)
	return TRUE

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if (src.health >= config.health_threshold_crit)
		if(src == M && ishuman(src))
			var/mob/living/carbon/human/H = src
			visible_message( \
				text("<span class='notice'>[src] examines [].</span>",src.gender==MALE?"himself":"herself"), \
				"<span class='notice'>You check yourself for injuries.</span>" \
				)

			for(var/obj/item/organ/external/BP in H.bodyparts)
				var/status = ""
				var/BPname = BP.name
				var/brutedamage = BP.brute_dam
				var/burndamage = BP.burn_dam
				if(halloss > 0)
					if(prob(30))
						brutedamage += halloss
					if(prob(30))
						burndamage += halloss

				if(brutedamage > 40)
					status = "mangled"
				else if(brutedamage > 20)
					status = "bleeding"
				else if(brutedamage > 0)
					status = "bruised"

				if(brutedamage > 0 && burndamage > 0)
					status += " and "

				if(burndamage > 40)
					status += "peeling away"
				else if(burndamage > 10)
					status += "blistered"
				else if(burndamage > 0)
					status += "numb"

				if(BP.is_stump)
					status = "MISSING!"
					BPname = parse_zone(BP.body_zone)
				if(BP.status & ORGAN_MUTATED)
					status = "weirdly shapen."
				if(status == "")
					status = "OK"
				to_chat(src, "\t <span class='[status == "OK" ? "notice " : "warning"]'>My [BPname] is [status].</span>")

			if(roundstart_quirks.len)
				to_chat(src, "<span class='notice'>You have these traits: [get_trait_string()].</span>")

			if((isskeleton(H)) && !H.w_uniform && !H.wear_suit)
				H.play_xylophone()
		else
			var/t_him = "it"
			if (src.gender == MALE)
				t_him = "him"
			else if (src.gender == FEMALE)
				t_him = "her"
			if (ishuman(src) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)

			if(on_fire && M != src)
				fire_stacks--
				M.visible_message("<span class='danger'>[M] trying to extinguish [src].</span>", \
								"<span class='rose'>You trying to extinguish [src].</span>")
				if(fire_stacks <= 0)
					ExtinguishMob()
					M.visible_message("<span class='danger'>[M] has successfully extinguished [src]!</span>", \
									"<span class='notice'>You extinguish [src]!</span>")
			else if(lying)
				AdjustSleeping(-10 SECONDS)
				if (!M.lying)
					if((!IsSleeping()) || ((src.crawling) && (crawl_can_use())))
						SetCrawling(FALSE)
					M.visible_message("<span class='notice'>[M] shakes [src] trying to wake [t_him] up!</span>", \
										"<span class='notice'>You shake [src] trying to wake [t_him] up!</span>")
				else
					if(!IsSleeping())
						M.visible_message("<span class='notice'>[M] cuddles with [src] to make [t_him] feel better!</span>", \
								"<span class='notice'>You cuddle with [src] to make [t_him] feel better!</span>")
					else
						M.visible_message("<span class='notice'>[M] gently touches [src] trying to wake [t_him] up!</span>", \
										"<span class='notice'>You gently touch [src] trying to wake [t_him] up!</span>")
			else
				switch(M.get_targetzone())
					if(BP_R_ARM, BP_L_ARM)
						M.visible_message( "<span class='notice'>[M] shakes [src]'s hand.</span>", \
										"<span class='notice'>You shake [src]'s hand.</span>", )
						if(HAS_TRAIT(M, TRAIT_WET_HANDS) && ishuman(src))
							var/mob/living/carbon/human/H = src
							var/obj/item/organ/external/BP = H.get_bodypart(M.get_targetzone())
							if(BP && BP.is_robotic())
								var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
								sparks.set_up(3, 0, get_turf(H))
								sparks.start()
								to_chat(src, "<span class='userdanger'>[M]'s hand is wet!</span>")
					if(BP_HEAD)
						M.visible_message("<span class='notice'>[M] pats [src] on the head.</span>", \
										"<span class='notice'>You pat [src] on the head.</span>", )
					if(O_EYES)
						M.visible_message("<span class='notice'>[M] looks into [src]'s eyes.</span>", \
										"<span class='notice'>You look into [src]'s eyes.</span>", )
					if(BP_GROIN)
						M.visible_message("<span class='notice'>[M] does something to [src] to make [t_him] feel better!</span>", \
										"<span class='notice'>You do something to [src] to make [t_him] feel better!</span>", )
					else
						M.visible_message("<span class='notice'>[M] hugs [src] to make [t_him] feel better!</span>", \
										"<span class='notice'>You hug [src] to make [t_him] feel better!</span>")

				if(HAS_TRAIT(M, TRAIT_FRIENDLY))
					var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
					if(mood)
						if(mood.mood_level >= MOOD_LEVEL_HAPPY2)
							new /obj/effect/temp_visual/heart(loc)
							SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "friendly_hug", /datum/mood_event/besthug, M)
						else if(mood.mood_level >= MOOD_LEVEL_NEUTRAL)
							SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "friendly_hug", /datum/mood_event/betterhug, M)
						SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "friendly_hug", /datum/mood_event/hug)
				else
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "friendly_hug", /datum/mood_event/hug)

			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)

			playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)

/mob/living/carbon/proc/eyecheck()
	return 0

/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash)
	if(eyecheck() < intensity || override_blindness_check)
		return ..()

// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(datum/dna/newDNA)
	dna = newDNA

// ++++ROCKDTBEN++++ MOB PROCS //END

//Throwing stuff
/mob/living/carbon/throw_mode_off()
	..()
	if(throw_icon) //in case we don't have the HUD and we use the hotkey
		throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/throw_mode_on()
	..()
	if(throw_icon)
		throw_icon.icon_state = "act_throw_on"
	if(!COOLDOWN_FINISHED(src, toggle_throw_message))
		return
	var/obj/item/I = get_active_hand()
	if(!I || (I.flags & (ABSTRACT|NODROP|DROPDEL)))
		return
	visible_message("<span class='notice'>[src] prepares to throw [I]!</span>",
					"<span class='notice'>Вы замахиваетесь.</span>")
	COOLDOWN_START(src, toggle_throw_message, 5 SECONDS)

/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	throw_mode_off()
	if(usr.incapacitated() || !target)
		return
	if(target.type == /atom/movable/screen)
		return

	var/atom/movable/item = get_active_hand()
	if(!item)
		return

	item = item.be_thrown(src, target)

	if(!item)
		return // Some items may not want to be thrown

	if(item.loc == src)
		// Holder and the mob holding it.
		item.jump_from_contents(rec_level=2)
		if(!isturf(item.loc))
			return
		if(!remove_from_mob(item, item.loc))
			return

	//actually throw it!
	if (item)
		visible_message("<span class='rose'>[src] has thrown [item].</span>")

		if(isitem(item))
			var/obj/item/O = item
			if(O.w_class >= SIZE_SMALL)
				playsound(loc, 'sound/effects/mob/hits/miss_1.ogg', VOL_EFFECTS_MASTER)

		do_attack_animation(target, has_effect = FALSE)

		newtonian_move(get_dir(target, src))

		item.throw_at(target, item.throw_range, item.throw_speed, src)

		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
				var/obj/item/clothing/suit/V = H.wear_suit
				V.attack_reaction(H, REACTION_THROWITEM)

/mob/living/carbon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	bodytemperature = max(bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT+10)

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/stool/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if (handcuffed)
		return 1
	return

/mob/living/carbon/u_equip(obj/item/W)
	if(!W)
		return

	else if (W == handcuffed)
		handcuffed = null
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()

	else if (W == legcuffed)
		legcuffed = null

	..()

/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)
	var/dat

	dat += "<table>"
	dat += "<tr><td><B>Left Hand:</B></td><td><A href='?src=\ref[src];item=[SLOT_L_HAND]'>[(l_hand && !(l_hand.flags & ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "<tr><td><B>Right Hand:</B></td><td><A href='?src=\ref[src];item=[SLOT_R_HAND]'>[(r_hand && !(r_hand.flags & ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=\ref[src];item=[SLOT_BACK]'>[(back && !(back.flags & ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank))
		dat += "&nbsp;<A href='?src=\ref[src];internal=[SLOT_BACK]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
	dat += "</td></tr>"

	dat += "<tr><td><B>Mask:</B></td><td><A href='?src=\ref[src];item=[SLOT_WEAR_MASK]'>[(wear_mask && !(wear_mask.flags & ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B></td><td><A href='?src=\ref[src];item=[SLOT_HANDCUFFED]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><B>Legcuffed:</B></td><td><A href='?src=\ref[src];item=[SLOT_LEGCUFFED]'>Remove</A></td></tr>"

	dat += "</table>"

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat)
	popup.open()

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(IsSleeping())
		to_chat(src, "<span class='rose'>You are already sleeping</span>")
		return
	if(tgui_alert(src, "You sure you want to sleep for a while?","Sleep", list("Yes","No")) == "Yes")
		SetSleeping(40 SECONDS) //Short nap

//Check for brain worms in head.
/mob/proc/has_brain_worms()
	for(var/mob/living/simple_animal/borer/B in contents)
		return B
	return null

//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()
	set category = "Borer"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B)
		return

	if(B.controlling)
		to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain].</span>")
		to_chat(B.host_brain, "<span class='danger'>Your vision swims as the alien parasite releases control of your body.</span>")
		B.ckey = ckey
		B.controlling = FALSE

	if(B.host_brain.ckey)
		ckey = B.host_brain.ckey
		B.host_brain.ckey = null
		B.host_brain.name = "host brain"
		B.host_brain.real_name = "host brain"

	verbs -= /mob/living/carbon/proc/release_control
	verbs -= /mob/living/carbon/proc/punish_host
	verbs -= /mob/living/carbon/proc/spawn_larvae

	med_hud_set_status()

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Borer"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B)
		return

	if(B.host_brain.ckey)
		to_chat(src, "<span class='danger'>You send a punishing spike of psychic agony lancing into your host's brain.</span>")
		to_chat(B.host_brain, "<span class='danger'><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></span>")

/mob/living/carbon/proc/spawn_larvae()
	set category = "Borer"
	set name = "Reproduce(100)"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B)
		return

	if(B.chemicals < 100)
		to_chat(src, "<span class='info'>You do not have enough chemicals stored to reproduce.</span>")
		return

	to_chat(src, "<span class='danger'>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</span>")
	B.chemicals -= 100
	B.has_reproduced = TRUE

	vomit()
	new /mob/living/simple_animal/borer(loc, TRUE, B.generation + 1)

/mob/living/carbon/proc/uncuff()
	remove_from_mob(handcuffed)
	remove_from_mob(legcuffed)

//-TG- port for smooth lying/standing animations
/mob/living/carbon/get_pixel_y_offset(lying_current = FALSE)
	if(lying)
		if(buckled && istype(buckled, /obj/structure/stool/bed/roller))
			return 1
		else if(locate(/obj/structure/stool/bed/roller, src.loc))
			return -5
		else if(locate(/obj/machinery/optable, src.loc) || locate(/obj/structure/stool/bed, src.loc) || locate(/obj/structure/altar_of_gods, src.loc))	//we need special pixel shift for beds & optable to make mob lying centered
			return -4
		else
			return -6
	else
		return initial(pixel_y)

/mob/living/carbon/get_pixel_x_offset(lying_current = FALSE)
	if(lying)
		if(locate(/obj/machinery/optable, src.loc) || locate(/obj/structure/stool/bed, src.loc) || locate(/obj/structure/altar_of_gods, src.loc))	//we need special pixel shift for beds & optable to make mob lying centered
			switch(src.lying_current)
				if(90)	return 2
				if(270)	return -2
	else
		return initial(pixel_x)

/mob/living/carbon/proc/bloody_hands(mob/living/source, amount = 2)
	return

/mob/living/carbon/proc/bloody_body(mob/living/source)
	return

/mob/living/carbon/is_nude(maximum_coverage = 0, pos_slots = list(src.head, src.shoes, src.neck, src.mouth))
	// We for some reason assume that the creature wearing human clothes has human-like anatomy. Mind-boggling, huh?
	var/percentage_covered = 0

	var/head_covered = FALSE
	var/face_covered = FALSE
	var/eyes_covered = FALSE
	var/mouth_covered = FALSE
	var/chest_covered = FALSE
	var/groin_covered = FALSE
	var/legs_covered = 0
	var/arms_covered = 0

	for(var/obj/item/I in pos_slots)
		if(!eyes_covered && ((I.flags & (GLASSESCOVERSEYES|MASKCOVERSEYES|HEADCOVERSEYES)) || I.flags_inv & HIDEEYES)) // All of them refer to the same value, but for reader's sake...
			percentage_covered += EYES_COVERAGE
			eyes_covered = TRUE
		if(!mouth_covered && ((I.flags & (MASKCOVERSMOUTH|HEADCOVERSMOUTH)) || I.flags_inv & HIDEMASK))
			percentage_covered += MOUTH_COVERAGE
			mouth_covered = TRUE
		if(!face_covered && (I.flags_inv & HIDEFACE))
			percentage_covered += FACE_COVERAGE
			face_covered = TRUE
		if(!head_covered && (I.body_parts_covered & HEAD))
			percentage_covered += HEAD_COVERAGE
			head_covered = TRUE
		if(!chest_covered && (I.body_parts_covered & UPPER_TORSO))
			percentage_covered += CHEST_COVERAGE
			chest_covered = TRUE
		if(!groin_covered && (I.body_parts_covered & LOWER_TORSO))
			percentage_covered += GROIN_COVERAGE
			groin_covered = TRUE
		if(legs_covered < 2 && (I.body_parts_covered & LEG_LEFT))
			percentage_covered += LEGS_COVERAGE
			legs_covered++
		if(legs_covered < 2 && (I.body_parts_covered & LEG_RIGHT)) // Because one thing can cover both and we need to check seperately and asdosadas
			percentage_covered += LEGS_COVERAGE
			legs_covered++
		if(arms_covered < 2 && (I.body_parts_covered & ARM_LEFT))
			percentage_covered += ARMS_COVERAGE
			arms_covered++
		if(arms_covered < 2 && (I.body_parts_covered & ARM_RIGHT))
			percentage_covered += ARMS_COVERAGE
			arms_covered++

	return percentage_covered <= maximum_coverage

/mob/living/carbon/naturechild_check()
	return is_nude(maximum_coverage = 20) && !istype(head, /obj/item/clothing/head/bearpelt) && !istype(head, /obj/item/weapon/holder)

/mob/living/carbon/proc/handle_phantom_move(NewLoc, direct)
	if(!ischangeling(src))
		return
	var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
	if(length(C.essences) < 1)
		return
	if(loc == NewLoc)
		for(var/mob/living/parasite/essence/essence in C.essences)
			if(essence.phantom.showed)
				essence.phantom.loc = get_turf(get_step(essence.phantom, direct))

/mob/living/carbon/proc/remove_passemotes_flag()
	for(var/thing in src)
		if(istype(thing, /obj/item/weapon/holder))
			return
		if(istype(thing, /mob/living/carbon/monkey/diona))
			return
	remove_status_flags(PASSEMOTES)

/mob/living/carbon/proc/can_eat(flags = 255) //I don't know how and why does it work
	return TRUE

/mob/living/carbon/proc/crawl_in_blood(obj/effect/decal/cleanable/blood/floor_blood)
	return

/mob/living/carbon/get_satiation()
	return nutrition + (reagents.get_reagent_amount("nutriment") \
					+ reagents.get_reagent_amount("plantmatter") \
					+ reagents.get_reagent_amount("protein") \
					+ reagents.get_reagent_amount("dairy") \
				) * 8 // We multiply by this "magic" number, because all of these are equal to 8 nutrition.

/mob/living/carbon/get_metabolism_factor()
	var/met = metabolism_factor.Get()
	if(met < 0)
		met = 0
	return met


/mob/living/carbon/proc/perform_av(mob/living/carbon/human/user) // don't forget to INVOKE_ASYNC this proc if sleep is a problem.
	if(!ishuman(src) && !isIAN(src))
		return
	if(user.is_busy(src))
		return

	visible_message("<span class='danger'>[user] is trying perform AV on [src]!</span>")

	if(health <= (config.health_threshold_dead + 5))
		var/suff = min(getOxyLoss(), 2) //Pre-merge level, less healing, more prevention of dieing.
		adjustOxyLoss(-suff)

	if(do_mob(user, src, HUMAN_STRIP_DELAY))
		 // yes, we check this after the action, allowing player to try this even if it looks wrong (for fun).
		if(user.species && user.species.flags[NO_BREATHE])
			to_chat(user, "<span class='notice bold'>Your species can not perform AV!</span>")
			return
		if((user.head && (user.head.flags & HEADCOVERSMOUTH)) || (user.wear_mask && (user.wear_mask.flags & MASKCOVERSMOUTH)))
			to_chat(user, "<span class='notice bold'>Remove your mask!</span>")
			return

		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.species && H.species.flags[NO_BREATHE])
				to_chat(user, "<span class='notice bold'>You can not perform AV on these species!</span>")
				return
			if(wear_mask && wear_mask.flags & MASKCOVERSMOUTH)
				to_chat(user, "<span class='notice bold'>Remove [src] [wear_mask]!</span>")
				return

		if(head && head.flags & HEADCOVERSMOUTH)
			to_chat(user, "<span class='notice bold'>Remove [src] [head]!</span>")
			return

		if (health > config.health_threshold_dead && health < config.health_threshold_crit)
			var/suff = min(getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
			adjustOxyLoss(-suff)
			visible_message("<span class='warning'>[user] performs AV on [src]!</span>")
			to_chat(src, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
			to_chat(user, "<span class='warning'>Repeat at least every 7 seconds.</span>")
		updatehealth()

/mob/living/carbon/Topic(href, href_list)
	..()

	if (href_list["item"] && usr.CanUseTopicInventory(src))
		var/slot = text2num(href_list["item"])
		var/obj/item/item_to_add = usr.get_active_hand()

		if(item_to_add && (item_to_add.flags & (ABSTRACT | DROPDEL)))
			item_to_add = null

		if(item_to_add && get_slot_ref(slot))
			if(item_to_add.w_class > SIZE_TINY)
				to_chat(usr, "<span class='red'>[src] is already wearing something. You need empty hand to take that off (or holding small item).</span>")
				return
			item_to_add = null

		stripPanelUnEquip(usr, slot, item_to_add)

		if(usr.machine == src && Adjacent(usr))
			show_inv(usr)
		else
			usr << browse(null, "window=mob\ref[src]")

	if (href_list["internal"] && usr.CanUseTopicInventory(src))
		var/slot = text2num(href_list["internal"])
		var/obj/item/weapon/tank/ITEM = get_equipped_item(slot)
		if(ITEM && istype(ITEM) && wear_mask && (wear_mask.flags & MASKINTERNALS))
			visible_message("<span class='danger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM.name].</span>")

			if(do_mob(usr, src, HUMAN_STRIP_DELAY))
				var/mob/living/carbon/C = src
				var/gas_log_string = ""
				var/internalsound
				if (internal)
					internal.add_fingerprint(usr)
					internal = null
					internalsound = 'sound/misc/internaloff.ogg'
					if(ishuman(C)) // Because only human can wear a spacesuit
						var/mob/living/carbon/human/H = C
						if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
							internalsound = 'sound/misc/riginternaloff.ogg'
					playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, null, -5)
				else if(ITEM && istype(ITEM, /obj/item/weapon/tank) && wear_mask && (wear_mask.flags & MASKINTERNALS))
					internal = ITEM
					internal.add_fingerprint(usr)
					internalsound = 'sound/misc/internalon.ogg'
					if(ishuman(C)) // Because only human can wear a spacesuit
						var/mob/living/carbon/human/H = C
						if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
							internalsound = 'sound/misc/riginternalon.ogg'
					playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, null, -5)

					if(ITEM.air_contents && length(ITEM.air_contents.gas))
						gas_log_string = " (gases:"
						for(var/G in ITEM.air_contents.gas)
							gas_log_string += " - [G]=[ITEM.air_contents.gas[G]]"
						gas_log_string += ")"
					else
						gas_log_string = " (gases: empty)"

				visible_message("<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM.name].</span>")
				attack_log += text("\[[time_stamp()]\] <font color='orange'>Had their internals [internal ? "open" : "close"] by [usr.name] ([usr.ckey])[gas_log_string]</font>")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>[internal ? "opens" : "closes"] the valve on [src]'s [ITEM.name][gas_log_string]</font>")

/mob/living/carbon/vomit(punched = FALSE, masked = FALSE, vomit_type = DEFAULT_VOMIT, stun = TRUE, force = FALSE)
	var/mask_ = masked
	if(head && (head.flags & HEADCOVERSMOUTH))
		mask_ = TRUE

	. = ..(punched, mask_, vomit_type, stun, force)
	if(. && !mask_)
		if(reagents.total_volume > 0)
			var/toxins_puked = 0
			var/datum/reagents/R = new(10)

			while(TRUE)
				var/datum/reagent/R_V = pick(reagents.reagent_list)
				toxins_puked += R_V.toxin_absorption
				reagents.trans_id_to(R, R_V.id, 1)
				if(R.total_volume >= 10)
					break
				if(reagents.total_volume <= 0)
					break
			R.reaction(loc)
			adjustToxLoss(-toxins_puked)
			AdjustDrunkenness(-toxins_puked * 2)

/mob/living/carbon/update_stat()
	if(stat == DEAD)
		return
	if(IsSleeping())
		stat = UNCONSCIOUS
		blinded = TRUE
	med_hud_set_status()

/mob/living/carbon/update_sight()
	if(!..())
		return FALSE

	if(HAS_TRAIT(src, TRAIT_BLUESPACE_MOVING))
		return TRUE

	if(blinded)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
		set_EyesVision("greyscale")
		return FALSE

	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)

	var/datum/species/S = all_species[get_species()]
	if(S)
		see_in_dark = S.darksight

	see_invisible = see_in_dark > 2 ? SEE_INVISIBLE_LEVEL_ONE : SEE_INVISIBLE_LIVING

	if(changeling_aug)
		sight |= SEE_MOBS
		see_in_dark = 8
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	if(XRAY in mutations)
		sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
		see_in_dark = 8
		if(!druggy)
			see_invisible = SEE_INVISIBLE_LEVEL_TWO

	if(istype(wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja))
		var/obj/item/clothing/mask/gas/voice/space_ninja/O = wear_mask
		switch(O.mode)
			if(0)
				O.togge_huds()
				if(!druggy)
					lighting_alpha = initial(lighting_alpha)
					see_invisible = SEE_INVISIBLE_LIVING
			if(1)
				see_in_dark = 8
				if(!druggy)
					lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			if(2)
				sight |= SEE_MOBS
				see_in_dark = initial(see_in_dark)
				if(!druggy)
					lighting_alpha = initial(lighting_alpha)
					see_invisible = SEE_INVISIBLE_LEVEL_TWO
			if(3)
				sight |= SEE_TURFS
				if(!druggy)
					lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	return TRUE

/mob/living/carbon/get_unarmed_attack()
	var/retDam = 2
	var/retDamType = BRUTE
	var/retFlags = 0
	var/retVerb = "attacks"
	var/retSound = null
	var/retMissSound = 'sound/effects/mob/hits/miss_1.ogg'

	var/specie = get_species()
	var/datum/species/S = all_species[specie]
	if(S)
		var/datum/unarmed_attack/attack = S.unarmed

		retDam = 2 + attack.damage
		retDamType = attack.damType
		retFlags = attack.damage_flags()
		retVerb = pick(attack.attack_verb)

		if(length(attack.attack_sound))
			retSound = pick(attack.attack_sound)

		retMissSound = 'sound/effects/mob/hits/miss_1.ogg'

	if(HULK in mutations)
		retDam += 4

	return list("damage" = retDam, "type" = retDamType, "flags" = retFlags, "verb" = retVerb, "sound" = retSound,
				"miss_sound" = retMissSound)

/mob/living/carbon/set_m_intent(intent)
	if(intent == MOVE_INTENT_RUN)
		if(legcuffed)
			to_chat(src, "<span class='notice'>You are legcuffed! You cannot run until you get [legcuffed] removed!</span>")
			return FALSE

	return ..()

/mob/living/carbon/accent_sounds(txt, datum/language/speaking)
	if(speaking && (speaking.flags & SIGNLANG))
		return txt

	var/datum/species/S = all_species[get_species()]
	if(S && S.flags[IS_SYNTHETIC])
		return txt

	for(var/datum/language/L as anything in languages)
		if(L == speaking)
			continue

		if(languages[L] != LANGUAGE_NATIVE)
			continue

		txt = L.accentuate(txt, speaking)
	return txt


/**
 * Get the insulation that is appropriate to the temperature you're being exposed to.
 * All clothing, natural insulation, and traits are combined returning a single value.
 *
 * required temperature The Temperature that you're being exposed to
 *
 * return the percentage of protection as a value from 0 - 1
**/
/mob/living/carbon/proc/get_insulation_protection(temperature)
	return (temperature > bodytemperature) ? get_heat_protection(temperature) : get_cold_protection(temperature)

/// This returns the percentage of protection from heat as a value from 0 - 1
/// temperature is the temperature you're being exposed to
/mob/living/carbon/proc/get_heat_protection(temperature)
	return 0

/// This returns the percentage of protection from cold as a value from 0 - 1
/// temperature is the temperature you're being exposed to
/mob/living/carbon/proc/get_cold_protection(temperature)
	return 0


/**
 * Adjust the body temperature of a mob
 * expanded for carbon mobs allowing the use of insulation and change steps
 *
 * vars:
 * * amount The amount of degrees to change body temperature by
 * * min_temp (optional) The minimum body temperature after adjustment
 * * max_temp (optional) The maximum body temperature after adjustment
 * * use_insulation (optional) modifies the amount based on the amount of insulation the mob has
 * * use_steps (optional) Use the body temp divisors and max change rates
 * * capped (optional) default True used to cap step mode
 */
/mob/living/carbon/adjust_bodytemperature(amount, min_temp=0, max_temp=INFINITY, use_insulation=FALSE, use_steps=FALSE, capped=TRUE)
	// apply insulation to the amount of change
	if(use_insulation)
		var/protection = get_insulation_protection(bodytemperature + amount)
		if(protection >= 1)
			return
		amount *= (1 - protection)

	// Use the bodytemp divisors to get the change step, with max step size
	if(use_steps)
		if(amount > 0)
			amount /=  BODYTEMP_HEAT_DIVISOR
			if(capped)
				amount = min(amount, BODYTEMP_HEATING_MAX)
		else
			amount /=  BODYTEMP_COLD_DIVISOR
			if(capped)
				amount = max(amount, BODYTEMP_COOLING_MAX)

	..(amount, min_temp, max_temp)

/mob/living/carbon/handle_nutrition()
	var/met_factor = get_metabolism_factor()
	if(!met_factor)
		return
	var/nutrition_to_remove = 0
	nutrition_to_remove += 0.16
	if(HAS_TRAIT(src, TRAIT_STRESS_EATER))
		var/pain = getHalLoss()
		if(pain > 0)
			nutrition_to_remove += pain * 0.01
	nutrition_to_remove *= met_factor
	nutrition = max(0.0, nutrition - nutrition_to_remove)
