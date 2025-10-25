/obj/item/organ/internal/lungs
	name = "lungs"
	cases = list("лёгкие", "лёгких", "лёгким", "лёгкие", "лёгкими", "лёгких")
	icon_state = "lungs"
	item_state_world = "lungs_world"
	organ_tag = O_LUNGS
	parent_bodypart = BP_CHEST
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	var/exhale_type = "carbon_dioxide"
	var/breath_type = "oxygen"
	var/has_gills = FALSE
	var/active_breathing = TRUE
	var/min_breath_pressure = 16
	var/last_int_pressure
	var/last_ext_pressure
	var/max_pressure_diff = 60
	var/breath_fail_ratio // How badly they failed a breath. Higher is worse.
	var/poison_type = "phoron"
	var/last_successful_breath
	var/breathing = FALSE


/obj/item/organ/internal/lungs/proc/handle_breath(datum/gas_mixture/breath, forced)


	var/const/safe_exhaled_max = 10 // Yes it's an arbitrary value who cares?
	var/const/safe_toxins_max = 0.005
	var/const/safe_fractol_max = 0.15
	var/const/SA_para_min = 1
	var/const/SA_sleep_min = 5
	var/const/SA_giggle_min = 0.15

	var/list/breath_gas = breath.gas
	var/breath_total_moles = breath.total_moles

	var/inhaling = breath_gas[breath_type]
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
	var/druggy_breath_type = "fractol"
	var/druggy_inhaling = breath_gas[druggy_breath_type]
	var/druggy_inhale_pp = druggy_inhaling ? (druggy_inhaling / breath_total_moles) * breath_pressure : 0

	breath_type = inhale_pp >= druggy_inhale_pp ? breath_type : druggy_breath_type
	inhaling = inhale_pp >= druggy_inhale_pp ? inhaling : druggy_inhaling
	inhale_pp = inhale_pp >= druggy_inhale_pp ? inhale_pp : druggy_inhale_pp


	if(!owner)
		return TRUE

	if(!breath || (max_damage <= 0))
		breath_fail_ratio = 1
		handle_failed_breath()
		return TRUE

	var/datum/gas_mixture/environment = owner.loc.return_air_for_internal_lifeform()
	last_ext_pressure = environment && environment.return_pressure()
	last_int_pressure = breath_pressure
	if(breath.total_moles == 0)
		breath_fail_ratio = 1
		handle_failed_breath()
		return TRUE

	var/safe_pressure_min = min_breath_pressure // Minimum safe partial pressure of breathable gas in kPa
	// Lung damage increases the minimum safe pressure.
	safe_pressure_min *= 1 + rand(1,4) * damage/max_damage

	var/failed_inhale = FALSE
	var/failed_exhale = FALSE

	var/inhale_efficiency = min(round(((inhaling/breath.total_moles)*breath_pressure)/safe_pressure_min, 0.001), 3)

	if(inhale_pp < safe_pressure_min)
		if(prob(20)&& active_breathing)
			owner.emote("gasp")
		if(inhale_pp > 0)
			var/ratio = inhale_pp / safe_pressure_min

			// Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
			owner.adjustOxyLoss(HUMAN_MAX_OXYLOSS * (1 - ratio))
			inhaled_gas_used = inhaling * ratio * BREATH_USED_PART
		else
			owner.adjustOxyLoss(HUMAN_MAX_OXYLOSS)

		failed_inhale = TRUE
		owner.inhale_alert = TRUE

	breath.adjust_gas(breath_type, -inhaled_gas_used, update = FALSE) //update afterwards

	if(exhale_type)
		breath.adjust_gas_temp(exhale_type, inhaled_gas_used, owner.bodytemperature, update = FALSE) //update afterwards

		// CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2,
		// this will hurt you, but only once per 4 ticks, instead of once per tick.

		if(exhaled_pp > safe_exhaled_max)

			// If it's the first breath with too much CO2 in it, lets start a counter,
			// then have them pass out after 12s or so.
			if(!owner.co2overloadtime)
				owner.co2overloadtime = world.time
			else if(world.time - owner.co2overloadtime > 120)
				// Lets hurt em a little, let them know we mean business
				owner.Paralyse(3)
				owner.adjustOxyLoss(3)

				// They've been in here 30s now, lets start to kill them for their own good!
				if(world.time - owner.co2overloadtime > 300)
					owner.adjustOxyLoss(8)

			// Lets give them some chance to know somethings not right though I guess.
			if(prob(20))
				owner.emote("cough")
		else
			owner.co2overloadtime = null

	if(druggy_inhale_pp > safe_fractol_max)
		owner.adjustDrugginess(1)
		if(prob(5))
			owner.emote("twitch")
			owner.random_move()
		else if(prob(7))
			owner.emote(pick("drool","moan","giggle"))

	// Too much poison in the air.
	if(poison_pp > safe_toxins_max)
		var/ratio = (poison / safe_toxins_max) * 10
		if(owner.reagents)
			owner.reagents.add_reagent("toxin", clamp(ratio, MIN_TOXIN_DAMAGE, MAX_TOXIN_DAMAGE))
		breath.adjust_gas(poison_type, -poison * BREATH_USED_PART, update = FALSE) //update after
		owner.poison_alert = TRUE
	else
		owner.poison_alert = FALSE
	// Moved after reagent injection so we don't instantly poison ourselves with CO2 or whatever.
	if(exhale_type && (!istype(owner.wear_mask)))
		breath.adjust_gas_temp(exhale_type, inhaled_gas_used, owner.bodytemperature, update = 0) //update afterwards

	// If there's some other shit in the air lets deal with it here.
	if(sleeping_agent)
		// Enough to make us paralysed for a bit
		if(SA_pp > SA_para_min)
			// 3 gives them one second to wake up and run away a bit!
			owner.Paralyse(3)

			// Enough to make us sleep as well
			if(SA_pp > SA_sleep_min)
				owner.Sleeping(10 SECONDS)
				owner.analgesic = clamp(owner.analgesic + 5, 0, 10)

		// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
		else if(SA_pp > SA_giggle_min)
			if(prob(20))
				owner.emote(pick("giggle", "laugh"))

		breath.adjust_gas("sleeping_agent", -sleeping_agent * BREATH_USED_PART, update = FALSE) //update after

	// Were we able to breathe?
	var/failed_breath = failed_inhale || failed_exhale
	if(!failed_breath)
		owner.adjustOxyLoss(-5 * inhale_efficiency)

	handle_breath_temperature(breath)
	breath.update_values()

	if(failed_breath)
		handle_failed_breath()
	else
		owner.inhale_alert = FALSE
	return failed_breath

/obj/item/organ/internal/lungs/proc/handle_failed_breath()
	if(owner.reagents.has_reagent("inaprovaline") || HAS_TRAIT(src, TRAIT_EXTERNAL_VENTILATION))
		return
	if(prob(15))
		if(!owner.species.flags[IS_SYNTHETIC])
			if(active_breathing)
				owner.emote("gasp")
		else
			owner.emote(pick("shiver","twitch"))

	owner.adjustOxyLoss(HUMAN_MAX_OXYLOSS*breath_fail_ratio)

	owner.inhale_alert = TRUE
	last_int_pressure = 0

/obj/item/organ/internal/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath)
	// Hot air hurts :(
	if(breath.temperature > owner.species.heat_level_1)
		if(breath.temperature > owner.species.heat_level_3)
			owner.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, BP_HEAD, used_weapon = "Excessive Heat")
		else if(breath.temperature > owner.species.heat_level_2)
			owner.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, BP_HEAD, used_weapon = "Excessive Heat")
		else
			owner.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, BP_HEAD, used_weapon = "Excessive Heat")
	else if(breath.temperature < owner.species.breath_cold_level_1)
		if(breath.temperature >= owner.species.breath_cold_level_2)
			owner.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, BP_HEAD, used_weapon = "Excessive Cold")
		else if(breath.temperature >= owner.species.breath_cold_level_3)
			owner.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, BP_HEAD, used_weapon = "Excessive Cold")
		else
			owner.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, BP_HEAD, used_weapon = "Excessive Cold")

	//breathing in hot/cold air also heats/cools you a bit
	var/affecting_temp = (breath.temperature - owner.bodytemperature) * breath.return_relative_density()

	owner.adjust_bodytemperature(affecting_temp / 5, use_insulation = TRUE, use_steps = TRUE)



/obj/item/organ/internal/lungs/process()
	..()

	if(!owner)
		return

	if(owner.species && HAS_TRAIT(owner, TRAIT_NO_BREATHE))
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(!owner.reagents.has_reagent("dextromethorphan") && prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised())
		if(prob(4))
			owner.emote("cough")
			owner.drip(10)


/obj/item/organ/internal/lungs/vox
	name = "air capillary sack"
	cases = list("воздушно-капиллярный мешок", "воздушно-капиллярного мешка", "воздушно-капиллярному мешку", "воздушно-капиллярный мешок", "воздушно-капиллярным мешком", "воздушно-капиллярном мешке")
	desc = "They're filled with dust....wow."
	parent_bodypart = BP_GROIN
	icon = 'icons/obj/special_organs/vox.dmi'
	compability = list(VOX)
	sterile = TRUE
	breath_type = "nitrogen"
	poison_type = "oxygen"


/obj/item/organ/internal/lungs/tajaran
	name = "tajaran lungs"
	icon = 'icons/obj/special_organs/tajaran.dmi'

/obj/item/organ/internal/lungs/unathi
	name = "unathi lungs"
	icon = 'icons/obj/special_organs/unathi.dmi'

/obj/item/organ/internal/lungs/skrell
	name = "respiration sac"
	cases = list("дыхательная сумка", "дыхательной сумки", "дыхательной сумке", "дыхательную сумку", "дыхательной сумкой", "дыхательной сумке")
	has_gills = TRUE
	icon = 'icons/obj/special_organs/skrell.dmi'

/obj/item/organ/internal/lungs/diona
	name = "virga inopinatus"
	cases = list("полая ветка", "полой ветки", "полой ветки", "полую ветку", "полой веткой", "полой ветке")
	process_accuracy = 10
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	item_state_world = "nymph"
	compability = list(DIONA)
	tough = TRUE

/obj/item/organ/internal/lungs/cybernetic
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. It functions the same as an organic lung and is merely meant as a replacement."
	icon_state = "lungs-prosthetic"
	item_state_world = "lungs-prosthetic_world"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	durability = 0.8
	compability = list(HUMAN, PLUVIAN, UNATHI, TAJARAN, SKRELL)
	can_relocate = TRUE

/obj/item/organ/internal/lungs/cybernetic/voxc
	parent_bodypart = BP_GROIN
	compability = list(VOX)

/obj/item/organ/internal/lungs/cybernetic/insert_organ(mob/living/carbon/human/H, surgically, datum/species/S)

	..()

	if(owner)
		breath_type = owner.species.inhale_type
		poison_type = owner.species.poison_type

/obj/item/organ/internal/lungs/ipc
	name = "cooling element"
	cases = list("охлаждающий элемент", "охлаждающего элемента", "охлаждающему элементу", "охлаждающий элемент", "охлаждающим элементом", "охлаждающем элементе")

	var/refrigerant_max = 50
	var/refrigerant = 50
	var/refrigerant_rate = 5
	var/bruised_loss = 3
	requires_robotic_bodypart = TRUE
	status = ORGAN_ROBOT
	durability = 0.8
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "working"
	item_state_world = "working"

/obj/item/organ/internal/lungs/ipc/process()
	if(!owner)
		return
	if(owner.nutrition < 1)
		return
	var/temp_gain = owner.species.synth_temp_gain

	if(refrigerant > 0 && !is_broken())
		var/refrigerant_spent = refrigerant_rate
		refrigerant -= refrigerant_rate
		if(refrigerant < 0)
			refrigerant_spent += refrigerant
			refrigerant = 0

		if(is_bruised())
			refrigerant_spent -= bruised_loss

		if(refrigerant_spent > 0)
			temp_gain -= refrigerant_spent

	if(HAS_TRAIT(owner, TRAIT_EXTERNAL_COOLING) & owner.bodytemperature > 290)
		owner.adjust_bodytemperature(-50)

	if(temp_gain > 0)
		owner.adjust_bodytemperature(temp_gain, max_temp = owner.species.synth_temp_max)

/obj/item/organ/internal/lungs/ipc/proc/add_refrigerant(volume)
	if(refrigerant < refrigerant_max)
		refrigerant += volume
		if(refrigerant > refrigerant_max)
			refrigerant = refrigerant_max
