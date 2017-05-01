/****************************************************
				INTERNAL ORGANS
****************************************************/
/mob/living/carbon/var/list/organs = list()
/mob/living/carbon/var/list/organs_by_name = list() // so internal organs have less ickiness too

/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/dead_icon // Icon to use when the organ has died.
	germ_level = 0 // INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE

	// Strings.
	var/organ_tag = null // Unique identifier
	var/parent_bodypart = null

	// Status tracking.
	var/status = 0 // Various status flags
	var/vital = FALSE
	var/damage = 0 // Current damage to the organ
	var/robotic = 0

	// Reference data.
	var/mob/living/carbon/owner = null // Current mob owning the organ.
	var/datum/dna/dna = null // Original DNA.
	var/datum/species/species = null // Original species.

	// Damage vars.
	var/min_bruised_damage = 10 // Damage before considered bruised
	var/min_broken_damage = 30 // Damage before becoming broken
	var/max_damage // Damage cap
	var/rejecting // Is this organ already being rejected?


/obj/item/organ/New(loc, mob/living/carbon/C)
	if(!max_damage)
		max_damage = min_broken_damage * 2

	if(istype(C))
		inserted(C)

		w_class = max(w_class + mob_size_difference(owner.mob_size, MOB_MEDIUM), 1) //smaller mobs have smaller organs.

		if(owner.dna)
			dna = owner.dna.Clone()
			species = all_species[dna.species]
		else
			species = all_species[S_HUMAN]
			CRASH("[src] spawned in [owner] without a proper DNA.") // log_debug()

		if(species.flags[IS_SYNTHETIC])
			src.mechanize()

	if(dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[dna.unique_enzymes] = dna.b_type

	create_reagents(5 * (w_class-1)**2)
	reagents.add_reagent("nutriment", reagents.maximum_volume) // Bay12: protein

	return ..()

/obj/item/organ/Destroy()
	STOP_PROCESSING(SSobj, src)

	if(owner)
		var/obj/item/bodypart/BP = owner.bodyparts_by_name[parent_bodypart]
		if(BP)
			BP.organs_by_name[organ_tag] = null
			BP.organs_by_name -= organ_tag
			BP.organs -= src

		owner.organs_by_name[organ_tag] = null
		owner.organs_by_name -= organ_tag
		owner.organs -= src
		owner = null

	dna = null
	species = null

	return ..()

/obj/item/organ/proc/removed(mob/living/user, detach = TRUE)
	if(!istype(owner))
		return

	on_remove()
	remove_hud_data()

	owner.organs_by_name[organ_tag] = null
	owner.organs_by_name -= organ_tag
	owner.organs -= src

	if(detach)
		var/obj/item/bodypart/BP = owner.get_bodypart(parent_bodypart)
		if(BP)
			BP.organs -= src
			status |= ORGAN_CUT_AWAY
		forceMove(owner.loc)

	START_PROCESSING(SSobj, src)
	rejecting = null
	if(robotic < ORGAN_ROBOT)
		var/datum/reagent/blood/organ_blood = locate(/datum/reagent/blood) in reagents.reagent_list //TODO fix this and all other occurences of locate(/datum/reagent/blood) horror
		if(!organ_blood || !organ_blood.data["blood_DNA"])
			owner.vessel.trans_to(src, 5, 1, 1)

	if(vital)
		if(user)
			user.attack_log += "\[[time_stamp()]\]<font color='red'>Removed a vital organ ([src]) from [owner.name] ([owner.ckey])</font>"
			owner.attack_log += "\[[time_stamp()]\]<font color='orange'>Had a vital organ ([src]) removed by [user.name] ([user.ckey])</font>"
			msg_admin_attack("[user.name] ([user.ckey]) removed a vital organ ([src]) from [owner.name] ([owner.ckey]) ([ADMIN_JMP(user)])")
		owner.death()

	owner = null

/obj/item/organ/proc/inserted(mob/living/carbon/C)
	if(!istype(C))
		return FALSE

	STOP_PROCESSING(SSobj, src)

	loc = null
	owner = C

	owner.organs += src
	owner.organs_by_name[organ_tag] = src

	var/obj/item/bodypart/BP = owner.bodyparts_by_name[parent_bodypart]
	if(!BP)
		CRASH("[src] inserted into [owner] without a parent bodypart: [parent_bodypart].")

	BP.organs += src
	BP.organs_by_name[organ_tag] = src

	add_hud_data()
	on_insert()

	return TRUE

/obj/item/organ/proc/on_insert()
	return

/obj/item/organ/proc/on_remove()
	return

/obj/item/organ/proc/add_hud_data()
	return

/obj/item/organ/proc/remove_hud_data(destroy = FALSE)
	return

/obj/item/organ/process()
	//dead already, no need for more processing
	if(status & ORGAN_DEAD)
		return

	// Don't process if we're in a freezer, an MMI or a stasis bag.or a freezer or something I dunno
	if(istype(loc,/obj/item/device/mmi))
		return
	if(istype(loc,/obj/structure/closet/body_bag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer) || istype(loc,/obj/structure/closet/secure_closet/freezer))
		return
	//Process infections
	if ((robotic >= 2) || (owner && owner.species && (owner.species.flags[IS_PLANT])))
		germ_level = 0
		return

	if(!owner && reagents)
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
		if(B && prob(40))
			reagents.remove_reagent("blood",0.1)
			blood_splatter(src, B, 1)
		damage = min(damage += rand(1,3), max_damage)
		germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_TWO)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_THREE)
			die()

	else if(owner && owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()
		handle_rejection()
		handle_germ_effects()

	//check if we've hit max_damage
	if(damage >= max_damage)
		die()

/obj/item/organ/proc/handle_rejection()
	// Process unsuitable transplants. TODO: consider some kind of
	// immunosuppressant that changes transplant data to make it match.
	if(dna)
		if(!rejecting)
			if(blood_incompatible(dna.b_type, owner.dna.b_type))
				rejecting = 1
		else
			rejecting++ //Rejection severity increases over time.
			if(rejecting % 10 == 0) //Only fire every ten rejection ticks.
				switch(rejecting)
					if(1 to 50)
						germ_level++
					if(51 to 200)
						germ_level += rand(1,2)
					if(201 to 500)
						germ_level += rand(2,3)
					if(501 to INFINITY)
						germ_level += rand(3,5)
						owner.reagents.add_reagent("toxin", rand(1,2))

/obj/item/organ/proc/die()
	if(robotic >= 2)
		return
	damage = max_damage
	status |= ORGAN_DEAD
	STOP_PROCESSING(SSobj, src)
	if(owner && vital)
		owner.death()

/obj/item/organ/proc/handle_germ_effects()
	//** Handle the effects of infections
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(30))
		germ_level--

	if (germ_level >= INFECTION_LEVEL_ONE/2)
		//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
		if(antibiotics < 5 && prob(round(germ_level/6)))
			germ_level++

	if(germ_level >= INFECTION_LEVEL_ONE)
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		owner.bodytemperature += between(0, (fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature)

	if (germ_level >= INFECTION_LEVEL_TWO)
		var/obj/item/bodypart/parent = owner.get_bodypart(parent_bodypart)
		//spread germs
		if (antibiotics < 5 && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30) ))
			parent.germ_level++

		if (prob(3))	//about once every 30 seconds
			take_damage(1,silent=prob(30))

/obj/item/organ/proc/can_feel_pain()
	return (robotic < ORGAN_ROBOT && (!species || !(species.flags[NO_PAIN] || species.flags[IS_SYNTHETIC])))

/obj/item/organ/proc/receive_chem(chemical)
	return 0

/obj/item/organ/proc/rejuvenate()
	damage = 0

/obj/item/organ/proc/is_bruised()
	return damage >= min_bruised_damage

/obj/item/organ/proc/is_broken()
	return damage >= min_broken_damage

/obj/item/organ/proc/take_damage(amount, silent=0)
	amount = round(amount, 0.1)

	if(src.robotic == 2)
		src.damage = between(0, src.damage + (amount * 0.8), max_damage)
	else
		src.damage = between(0, src.damage + amount, max_damage)

	//only show this if the organ is not robotic
	if(owner && parent_bodypart && amount > 0)
		var/obj/item/bodypart/parent = owner.get_bodypart(parent_bodypart)
		if (!silent)
			owner.custom_pain("Something inside your [parent.name] hurts a lot.", amount, BP = parent)

/obj/item/organ/emp_act(severity)
	if(!robotic)
		return

	switch(robotic)
		if(1)
			switch(severity)
				if(1)
					take_damage(20)
				if(2)
					take_damage(7)
				if(3)
					take_damage(3)
		if(2)
			switch(severity)
				if(1)
					take_damage(40)
				if(2)
					take_damage(15)
				if(3)
					take_damage(10)

/obj/item/organ/proc/mechanize() //Being used to make robutt hearts, etc
	robotic = 2

/obj/item/organ/proc/mechassist() //Used to add things like pacemakers, etc
	robotic = 1
	min_bruised_damage = 15
	min_broken_damage = 35

/mob/living/carbon/proc/recheck_bad_external_organs()
	var/damage_this_tick = getToxLoss()
	for(var/obj/item/bodypart/BP in bodyparts)
		damage_this_tick += BP.burn_dam + BP.brute_dam

	if(damage_this_tick > last_dam)
		. = TRUE
	last_dam = damage_this_tick

//Germs
/obj/item/organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < 5)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 6	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes

// Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/proc/handle_organs()

	var/force_process = recheck_bad_external_organs()

	if(force_process)
		bad_bodyparts.Cut()
		for(var/obj/item/bodypart/bad in bodyparts)
			bad_bodyparts += bad

	//processing internal organs is pretty cheap, do that first.
	for(var/obj/item/organ/IO in organs)
		IO.process()

	handle_stance()
	handle_grasp()

	if(!force_process && !bad_bodyparts.len)
		return

	for(var/obj/item/bodypart/BP in bad_bodyparts)
		if(!BP)
			continue
		if(!BP.need_process())
			bad_bodyparts -= BP
			continue
		else
			BP.process()

			if (!lying && !buckled && world.time - l_move_time < 15)
			//Moving around with fractured ribs won't do you any good
				if (prob(10) && !stat && BP.is_broken() && BP.organs.len)
					if(can_feel_pain())
						custom_pain("Pain jolts through your broken [BP.encased ? BP.encased : BP.name], staggering you!", 50, BP = BP)
						drop_item(loc)
						Stun(2)

				//Moving makes open wounds get infected much faster
				if (BP.wounds.len)
					for(var/datum/wound/W in BP.wounds)
						if (W.infection_check())
							W.germ_level += 1

/mob/living/carbon/proc/handle_stance()
	// Don't need to process any of this if they aren't standing anyways
	// unless their stance is damaged, and we want to check if they should stay down
	if (species.num_of_legs == 0 || !stance_damage && (lying || resting) && (life_tick % 4) != 0)
		return

	stance_damage = 0

	// Buckled to a bed/chair. Stance damage is forced to 0 since they're sitting on something solid
	if (istype(buckled, /obj/structure/stool/bed))
		return

	var/limb_pain
	for(var/i = 1 to species.num_of_legs)
		if(i <= bodypart_legs.len)
			var/obj/item/bodypart/BP = bodypart_legs[i]
			if(!BP.is_usable())
				stance_damage += 4 // let it fail even if just foot&leg
			else if (BP.is_malfunctioning())
				//malfunctioning only happens intermittently so treat it as a missing limb when it procs
				stance_damage += 4
				if(prob(10))
					visible_message("\The [src]'s [BP.name] [pick("twitches", "shudders")] and sparks!")
					var/datum/effect/effect/system/spark_spread/spark_system = new ()
					spark_system.set_up(5, 0, src)
					spark_system.attach(src)
					spark_system.start()
					spawn(10)
						qdel(spark_system)
			else if (BP.is_broken())
				stance_damage += 2
			else if (BP.is_dislocated())
				stance_damage += 1

			if(BP)
				limb_pain = BP.can_feel_pain()
		else
			stance_damage += 4

	// Canes and crutches help you stand (if the latter is ever added)
	// One cane mitigates a broken leg+foot, or a missing foot.
	// Two canes are needed for a lost leg. If you are missing both legs, canes aren't gonna help you.
	for(var/obj/item/bodypart/BP in bodypart_hands)
		if(istype(BP.item_in_slot[1], /obj/item/weapon/cane))
			stance_damage -= 2

	// standing is poor
	if(stance_damage >= 4 || (stance_damage >= 2 && prob(5)))
		if(!(lying || resting))
			if(limb_pain)
				emote("scream",,, 1)
			emote("collapse")
		Weaken(5) //can't emote while weakened, apparently.

/mob/living/carbon/proc/handle_grasp() // TODO check this proc
	if(species.num_of_hands == 0)
		return

	for (var/obj/item/bodypart/BP in bodypart_hands)
		if(((BP.is_broken() || BP.is_dislocated()) && !(BP.status & ORGAN_SPLINTED)) || BP.is_malfunctioning())
			grasp_damage_disarm(BP)

/mob/living/carbon/proc/grasp_damage_disarm(obj/item/bodypart/BP)
	var/obj/item/thing = BP.item_in_slot[1]

	if(!thing)
		return

	dropItemToGround(thing)

	if(BP.status & ORGAN_ROBOT)
		visible_message("<B>\The [src]</B> drops what they were holding, \his [BP.name] malfunctioning!")

		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start()
		spawn(10)
			qdel(spark_system)

	else
		if(BP.can_feel_pain())
			var/emote_scream = pick("screams in pain", "lets out a sharp cry", "cries out")
			var/emote_scream_alt = pick("scream in pain", "let out a sharp cry", "cry out")
			visible_message(
				"<B>\The [src]</B> [emote_scream] and drops what they were holding in their [BP.name]!",
				null,
				"You hear someone [emote_scream_alt]!"
			)
			custom_pain("The sharp pain in your [BP.name] forces you to drop [thing]!", 30)
		else
			visible_message("<B>\The [src]</B> drops what they were holding in their [BP.name]!")


/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/

/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	dead_icon = "heart-off"
	organ_tag = BP_HEART
	parent_bodypart = BP_CHEST
	var/pulse = PULSE_NORM
	var/heartbeat = 0
	var/beat_sound = 'sound/effects/singlebeat.ogg'
	var/tmp/next_blood_squirt = 0

/obj/item/organ/heart/die()
	if(dead_icon)
		icon_state = dead_icon
	..()

/obj/item/organ/heart/process()
	if(owner)
		handle_pulse()
		if(pulse)
			handle_heartbeat()
		handle_blood()
	..()

/obj/item/organ/heart/proc/handle_pulse()

	if(owner.stat == DEAD || robotic >= 2)
		pulse = PULSE_NONE	//that's it, you're dead (or your metal heart is), nothing can influence your pulse
		return

	if(owner.life_tick % 5)
		return // update pulse every 5 life ticks (~1 tick/sec, depending on server load)

	pulse = PULSE_NORM

	if(species && species.flags[NO_BLOOD] || !owner.vessel)
		pulse = PULSE_NONE
		return

	pulse = PULSE_NORM

	if(round(owner.vessel.get_reagent_amount("blood")) <= BLOOD_VOLUME_BAD)	//how much blood do we have
		pulse = PULSE_THREADY	//not enough :(

	if(owner.status_flags & FAKEDEATH)
		pulse = PULSE_NONE		//pretend that we're dead. unlike actual death, can be inflienced by meds

	//handles different chems' influence on pulse
	for(var/datum/reagent/R in owner.reagents.reagent_list)
		if(R.id in bradycardics)
			if(pulse <= PULSE_THREADY && pulse >= PULSE_NORM)
				pulse--
		if(R.id in tachycardics)
			if(pulse <= PULSE_FAST && pulse >= PULSE_NONE)
				pulse++
		if(R.id in heartstopper) //To avoid using fakedeath
			pulse = PULSE_NONE
		if(R.id in cheartstopper) //Conditional heart-stoppage
			if(R.volume >= R.overdose)
				pulse = PULSE_NONE

/obj/item/organ/heart/proc/handle_heartbeat()
	if(pulse >= PULSE_2FAST || owner.shock_stage >= 10 || is_below_sound_pressure(get_turf(owner)))
		//PULSE_THREADY - maximum value for pulse, currently it 5.
		//High pulse value corresponds to a fast rate of heartbeat.
		//Divided by 2, otherwise it is too slow.
		var/rate = (PULSE_THREADY - pulse)/2

		if(heartbeat >= rate)
			heartbeat = 0
			owner << sound(beat_sound, 0, 0, 0, 50)
		else
			heartbeat++

/obj/item/organ/heart/proc/handle_blood()

	if(!owner)
		return

	if(species && species.flags[NO_BLOOD])
		return

	//Dead or cryosleep people do not pump the blood.
	if(!owner || owner.in_stasis || owner.stat == DEAD || owner.bodytemperature < 170)
		return

	if(pulse != PULSE_NONE || robotic >= 2)
		//Bleeding out
		var/blood_max = 0
		var/list/do_spray = list()
		for(var/obj/item/bodypart/BP in owner.bodyparts)

			if(BP.status & ORGAN_ROBOT)
				continue

			var/open_wound
			if(BP.status & ORGAN_BLEEDING)

				if (BP.open)
					blood_max += 2  //Yer stomach is cut open

				for(var/datum/wound/W in BP.wounds)

					if(!open_wound && (W.damage_type == CUT || W.damage_type == PIERCE) && W.damage && !W.is_treated())
						open_wound = TRUE

					if(W.bleeding())
						if(BP.applied_pressure)
							if(ishuman(BP.applied_pressure))
								var/mob/living/carbon/human/H = BP.applied_pressure
								H.bloody_hands(src, 0)
							//somehow you can apply pressure to every wound on the organ at the same time
							//you're basically forced to do nothing at all, so let's make it pretty effective
							var/min_eff_damage = max(0, W.damage - 10) / 6 //still want a little bit to drip out, for effect
							blood_max += max(min_eff_damage, W.damage - 30) / 40
						else
							blood_max += W.damage / 40

			if(BP.status & ORGAN_ARTERY_CUT)
				var/bleed_amount = Floor((owner.vessel.total_volume / (BP.applied_pressure ? 400 : 250))*BP.arterial_bleed_severity)
				if(bleed_amount)
					if(open_wound)
						blood_max += bleed_amount
						do_spray += "the [BP.artery_name] in \the [owner]'s [BP.name]"
					else
						owner.vessel.remove_reagent("blood", bleed_amount)

		switch(pulse)
			if(PULSE_SLOW)
				blood_max *= 0.8
			if(PULSE_FAST)
				blood_max *= 1.25
			if(PULSE_2FAST, PULSE_THREADY)
				blood_max *= 1.5

		if(reagents.has_reagent("inaprovaline"))
			blood_max *= 0.8

		if(world.time >= next_blood_squirt && istype(owner.loc, /turf) && do_spray.len)
			owner.visible_message("<span class='danger'>Blood squirts from [pick(do_spray)]!</span>")
			// It becomes very spammy otherwise. Arterial bleeding will still happen outside of this block, just not the squirt effect.
			next_blood_squirt = world.time + 100
			var/turf/sprayloc = get_turf(owner)
			blood_max -= owner.drip(ceil(blood_max/3), sprayloc)
			if(blood_max > 0)
				blood_max -= owner.blood_squirt(blood_max, sprayloc)
				if(blood_max > 0)
					owner.drip(blood_max, get_turf(owner))
		else
			owner.drip(blood_max)


/obj/item/organ/lungs
	name = "lungs"
	icon_state = "lungs"
	organ_tag = BP_LUNGS
	parent_bodypart = BP_CHEST

	var/breathing = FALSE

/obj/item/organ/lungs/process()
	..()

	if(!owner)
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised())
		if(prob(2))
			owner.visible_message(
				"<B>\The [owner]</B> coughs up blood!",
				"<span class='warning'>You cough up blood!</span>",
				"You hear someone coughing!",
			)
			owner.drip(10)
		if(prob(4))
			owner.visible_message(
				"<B>\The [owner]</B> gasps for air!",
				"<span class='danger'>You can't breathe!</span>",
				"You hear someone gasp for air!",
			)
			owner.losebreath += 15

// RETURN TRUE = failed to breath.
/obj/item/organ/lungs/proc/handle_breath(datum/gas_mixture/breath)
	if(!owner)
		return TRUE
	if(!breath)
		return TRUE

	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
	if(breath.total_moles() == 0)
		return TRUE

	var/safe_pressure_min = 16 // Minimum safe partial pressure of breathable gas in kPa
	// Lung damage increases the minimum safe pressure.
	if(is_broken())
		safe_pressure_min *= 1.5
	else if(is_bruised())
		safe_pressure_min *= 1.25


	var/failed_inhale = FALSE
	var/failed_exhale = FALSE

	var/safe_exhaled_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_max = 0.005
	var/SA_para_min = 1
	var/SA_sleep_min = 5

	var/inhaling
	var/exhaling
	var/poison
	var/no_exhale

	switch(species.breath_type)
		if("nitrogen") inhaling = breath.nitrogen
		if("phoron")   inhaling = breath.phoron
		if("C02")      inhaling = breath.carbon_dioxide
		else           inhaling = breath.oxygen

	switch(species.poison_type)
		if("oxygen")   poison = breath.oxygen
		if("nitrogen") poison = breath.nitrogen
		if("C02")      poison = breath.carbon_dioxide
		else           poison = breath.phoron

	switch(species.exhale_type)
		if("C02")      exhaling = breath.carbon_dioxide
		if("oxygen")   exhaling = breath.oxygen
		if("nitrogen") exhaling = breath.nitrogen
		if("phoron")   exhaling = breath.phoron
		else           no_exhale = 1

	var/inhale_pp = (inhaling/breath.total_moles())*breath_pressure
	var/toxins_pp = (poison/breath.total_moles())*breath_pressure
	var/exhaled_pp = (exhaling/breath.total_moles())*breath_pressure

	// Not enough to breathe
	if(inhale_pp < safe_pressure_min)
		if(prob(20))
			owner.emote("gasp")

		var/ratio = inhale_pp/safe_pressure_min
		owner.adjustOxyLoss(max(HUMAN_MAX_OXYLOSS*(1-ratio), 0))	// Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
		failed_inhale = 1

	var/inhaled_gas_used = inhaling/6

	switch(species.breath_type)
		if("nitrogen") breath.nitrogen -= inhaled_gas_used
		else           breath.oxygen -= inhaled_gas_used

	if(!no_exhale)
		switch(species.exhale_type)
			if("oxygen")         breath.oxygen += inhaled_gas_used
			if("nitrogen")       breath.nitrogen += inhaled_gas_used
			if("phoron")         breath.phoron += inhaled_gas_used
			if("carbon_dioxide") breath.carbon_dioxide += inhaled_gas_used

	// CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2,
	// this will hurt you, but only once per 4 ticks, instead of once per tick.

	if(exhaled_pp > safe_exhaled_max)
		// If it's the first breath with too much CO2 in it, lets start a counter,
		// then have them pass out after 12s or so.
		failed_exhale = TRUE
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
		owner.co2overloadtime = 0

	// Too much poison in the air.
	if(toxins_pp > safe_toxins_max)
		var/ratio = (poison/safe_toxins_max) * 10
		if(owner.reagents)
			owner.reagents.add_reagent("toxin", Clamp(ratio, MIN_TOXIN_DAMAGE, MAX_TOXIN_DAMAGE))
		//throw_alert("tox_in_air")
	//else
		//clear_alert("tox_in_air")

	// If there's some other shit in the air lets deal with it here.
	if(breath.trace_gases.len)
		for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
			var/SA_pp = (SA.moles/breath.total_moles())*breath_pressure

			// Enough to make us paralysed for a bit
			if(SA_pp > SA_para_min)
				// 3 gives them one second to wake up and run away a bit!
				owner.Paralyse(3)
				// Enough to make us sleep as well
				if(SA_pp > SA_sleep_min)
					owner.Sleeping(5)
			// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			else if(SA_pp > 0.15)
				if(prob(20))
					owner.emote(pick("giggle", "laugh"))
			SA.moles = 0

	// Hot air hurts :(
	if( (breath.temperature < species.cold_level_1 || breath.temperature > species.heat_level_1)) // mutation for lungs should be added.

		switch(breath.temperature)
			if(-INFINITY to species.cold_level_3)
				owner.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, BP_HEAD, used_weapon = "Excessive Cold")
			if(species.cold_level_3 to species.cold_level_2)
				owner.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, BP_HEAD, used_weapon = "Excessive Cold")
			if(species.cold_level_2 to species.cold_level_1)
				owner.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, BP_HEAD, used_weapon = "Excessive Cold")
			if(species.heat_level_1 to species.heat_level_2)
				owner.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, BP_HEAD, used_weapon = "Excessive Heat")
			if(species.heat_level_2 to species.heat_level_3)
				owner.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, BP_HEAD, used_weapon = "Excessive Heat")
			if(species.heat_level_3 to INFINITY)
				owner.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, BP_HEAD, used_weapon = "Excessive Heat")

		//breathing in hot/cold air also heats/cools you a bit
		var/temp_adj = breath.temperature - owner.bodytemperature
		if (temp_adj < 0)
			temp_adj /= (BODYTEMP_COLD_DIVISOR * 5)	//don't raise temperature as much as if we were directly exposed
		else
			temp_adj /= (BODYTEMP_HEAT_DIVISOR * 5)	//don't raise temperature as much as if we were directly exposed

		var/relative_density = breath.total_moles() / (MOLES_CELLSTANDARD * BREATH_PERCENTAGE)
		temp_adj *= relative_density

		if (temp_adj > BODYTEMP_HEATING_MAX) temp_adj = BODYTEMP_HEATING_MAX
		if (temp_adj < BODYTEMP_COOLING_MAX) temp_adj = BODYTEMP_COOLING_MAX
		//world << "Breath: [breath.temperature], [src]: [bodytemperature], Adjusting: [temp_adj]"
		owner.bodytemperature += temp_adj

	// Were we able to breathe?
	var/failed_breath = failed_inhale || failed_exhale
	if (!failed_breath)
		owner.adjustOxyLoss(-5)
		if(!(status & ORGAN_ROBOT) && species.breathing_sound && is_below_sound_pressure(get_turf(owner)))
			if(breathing || owner.shock_stage >= 10)
				owner << sound(species.breathing_sound,0,0,0,5)
				breathing = FALSE
			else
				breathing = TRUE

	return failed_breath

/obj/item/organ/lungs/xeno
	name = "lungs"
	icon_state = "lungs-x"
	organ_tag = BP_LUNGS
	parent_bodypart = BP_CHEST

	var/oxygen_reserve = 240     // starts with enough oxygen for about one minute.
	var/oxygen_reserve_max = 720 // lungs looses 16 every 4 ticks when there is not enough oxygen (holds oxygen at max for three minutes or so).

/obj/item/organ/lungs/xeno/handle_breath(datum/gas_mixture/breath)
	if(!owner)
		return TRUE

	var/safe_pressure_min = 16
	var/failed_inhale = FALSE

	if(!breath)
		oxygen_reserve = max(0, oxygen_reserve - safe_pressure_min)
		owner.clear_alert("alien_tox")
	else
		var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
		if(breath.total_moles() == 0)
			oxygen_reserve = max(0, oxygen_reserve - safe_pressure_min)
		else
			var/inhaling = breath.oxygen
			var/poison = breath.phoron

			var/inhale_pp = (inhaling/breath.total_moles())*breath_pressure
			var/toxins_pp = (poison/breath.total_moles())*breath_pressure

			// Not enough to breathe
			if(inhale_pp < safe_pressure_min)
				oxygen_reserve = max(0, oxygen_reserve - safe_pressure_min)
			else
				oxygen_reserve = min(oxygen_reserve + inhale_pp, oxygen_reserve_max)

			if(toxins_pp)
				owner.throw_alert("alien_tox")
				owner.adjustToxLoss(toxins_pp * 250)
			else
				owner.clear_alert("alien_tox")

	if(oxygen_reserve == 0)
		failed_inhale = TRUE

	// Were we able to breathe?
	if (!failed_inhale)
		owner.adjustOxyLoss(-5)

	return failed_inhale

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	organ_tag = BP_LIVER
	parent_bodypart = BP_CHEST
	var/process_accuracy = 10

/obj/item/organ/liver/process()
	..()

	if(!owner)
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			to_chat(owner, "<span class='danger'>Your skin itches.</span>")
	if (germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			INVOKE_ASYNC(owner, /mob/living/carbon/human.proc/vomit)

	if(owner.life_tick % process_accuracy == 0)
		if(src.damage < 0)
			src.damage = 0

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("anti_toxin"))
			//Healthy liver suffers on its own
			if (src.damage < min_broken_damage)
				src.damage += 0.2 * process_accuracy
			//Damaged one shares the fun
			else
				var/obj/item/organ/IO = pick(owner.organs)
				if(IO && IO.robotic < 2)
					IO.take_damage(0.2 * process_accuracy)

		//Detox can heal small amounts of damage
		if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("anti_toxin"))
			src.damage = max(0, src.damage - 0.2 * process_accuracy)

		// Get the effectiveness of the liver.
		var/filter_effect = 3
		if(is_bruised())
			filter_effect -= 1
		if(is_broken())
			filter_effect -= 2

		// Do some reagent processing.
		if(filter_effect < 3)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				// Ethanol and all drinks are bad
				if(istype(R, /datum/reagent/ethanol))
					if(!filter_effect)
						owner.adjustToxLoss(0.1 * process_accuracy)
					else
						take_damage(0.1 * process_accuracy, prob(1))
				// Can't cope with toxins at all
				if(istype(R, /datum/reagent/toxin))
					if(!filter_effect)
						owner.adjustToxLoss(0.3 * process_accuracy)
					else
						take_damage(0.3 * process_accuracy, prob(1))

	//Blood regeneration if there is some space
	var/blood_volume_raw = owner.vessel.get_reagent_amount("blood")
	if(blood_volume_raw < species.blood_volume)
		var/datum/reagent/blood/B = owner.get_blood(owner.vessel)
		B.volume += 0.1 // regenerate blood VERY slowly
		if (reagents.has_reagent("nutriment"))	//Getting food speeds it up
			B.volume += 0.4
			reagents.remove_reagent("nutriment", 0.1)
		if (reagents.has_reagent("iron"))	//Hematogen candy anyone?
			B.volume += 0.8
			reagents.remove_reagent("iron", 0.1)
		//if(CE_BLOODRESTORE in owner.chem_effects)
		//	B.volume += owner.chem_effects[CE_BLOODRESTORE]

	// Blood loss or liver damage make you lose nutriments
	var/blood_volume = owner.get_effective_blood_volume()
	if(blood_volume < BLOOD_VOLUME_SAFE || is_bruised())
		if(owner.nutrition >= 300)
			owner.nutrition -= 10
		else if(owner.nutrition >= 200)
			owner.nutrition -= 3


/obj/item/organ/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	organ_tag = BP_KIDNEYS
	parent_bodypart = BP_CHEST

/obj/item/organ/brain
	name = "brain"
	icon_state = "brain"
	organ_tag = BP_BRAIN
	parent_bodypart = BP_HEAD
	var/is_advanced_tool_user = TRUE

/obj/item/organ/brain/monkey
	is_advanced_tool_user = FALSE

/obj/item/organ/brain/monkey/nymph
	parent_bodypart = BP_CHEST

/obj/item/organ/brain/dog
	is_advanced_tool_user = FALSE

/obj/item/organ/brain/core
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"

	parent_bodypart = BP_CHEST
	is_advanced_tool_user = FALSE

	var/cores = 1 // size of brain :D

/obj/item/organ/brain/core/promethean
	parent_bodypart = BP_HEAD
	is_advanced_tool_user = TRUE

/obj/item/organ/brain/xeno
	name = "thinkpan"
	desc = "It looks kind of like an enormous wad of purple bubblegum."
	icon_state = "chitin"

	var/obj/screen/alien/nightvision/nightvisionicon

/obj/item/organ/brain/xeno/child
	name = "brain"
	icon_state = "brain-x"
	parent_bodypart = BP_CHEST

/obj/item/organ/brain/xeno/add_hud_data()
	if(!nightvisionicon)
		nightvisionicon = new
		nightvisionicon.screen_loc = ui_alien_nightvision

	if(owner && owner.client)
		owner.client.screen += nightvisionicon

/obj/item/organ/brain/xeno/remove_hud_data(destroy = FALSE)
	if(owner && owner.client)
		owner.client.screen -= nightvisionicon

	if(destroy)
		qdel(nightvisionicon)
		nightvisionicon = null


/obj/item/organ/brain/xeno/hunter
	var/obj/screen/alien/leap/leap_icon

/obj/item/organ/brain/xeno/hunter/add_hud_data()
	..()
	if(!leap_icon)
		leap_icon = new
		leap_icon.screen_loc = ui_storage2

	if(owner && owner.client)
		owner.client.screen += leap_icon

/obj/item/organ/brain/xeno/hunter/remove_hud_data(destroy = FALSE)
	if(owner && owner.client)
		owner.client.screen -= leap_icon

	if(destroy)
		qdel(leap_icon)
		leap_icon = null
	..()


/obj/item/organ/brain/process()
	if(!owner || !owner.should_have_organ(BP_HEART))
		return

	// No heart? You are going to have a very bad time. Not 100% lethal because heart transplants should be a thing.
	var/blood_volume = owner.get_effective_blood_volume()
	if(!owner.organs_by_name[BP_HEART])
		if(blood_volume > BLOOD_VOLUME_SURVIVE)
			blood_volume = BLOOD_VOLUME_SURVIVE
		owner.Paralyse(3)

	//Effects of bloodloss
	switch(blood_volume)
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			if(prob(1))
				to_chat(owner, "<span class='warning'>You feel [pick("dizzy","woosey","faint")]</span>")
			if(owner.getOxyLoss() < 20)
				owner.adjustOxyLoss(3)
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			owner.eye_blurry = max(owner.eye_blurry,6)
			if(owner.getOxyLoss() < 50)
				owner.adjustOxyLoss(10)
			owner.adjustOxyLoss(1)
			if(prob(15))
				owner.Paralyse(rand(1,3))
				to_chat(owner, "<span class='warning'>You feel extremely [pick("dizzy","woosey","faint")]</span>")
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			owner.adjustOxyLoss(5)
			if(owner.getToxLoss() < 15)
				owner.adjustToxLoss(3)
			if(prob(15))
				owner.Paralyse(3,5)
				to_chat(owner, "<span class='warning'>You feel extremely [pick("dizzy","woosey","faint")]</span>")
		if(-(INFINITY) to BLOOD_VOLUME_SURVIVE)
			owner.setOxyLoss(max(owner.getOxyLoss(), owner.maxHealth+10))

/obj/item/organ/eyes
	name = "eyes"
	icon_state = "eyeballs"
	organ_tag = BP_EYES
	parent_bodypart = BP_HEAD

/obj/item/organ/eyes/process() //Eye damage replaces the old eye_stat var.
	..()
	if(owner)
		if(is_bruised())
			owner.eye_blurry = 20
		if(is_broken())
			owner.eye_blind = 20

/obj/item/organ/tongue
	name = "tongue"
	icon_state = "tonguenormal"
	organ_tag = BP_MOUTH
	parent_bodypart = BP_HEAD

/obj/item/organ/tongue/xeno
	icon_state = "tonguexeno"

//XENOMORPH ORGANS
/obj/item/organ/xenos
	name = "xeno organ"
	desc = "It smells like an accident in a chemical factory."
	var/list/alien_powers = list()

/obj/item/organ/xenos/New()
	for(var/A in alien_powers)
		if(ispath(A))
			alien_powers -= A
			alien_powers += new A(src)
	..()

/obj/item/organ/xenos/on_insert()
	..()
	for(var/obj/effect/proc_holder/alien/P in alien_powers)
		owner.AddAbility(P)

/obj/item/organ/xenos/on_remove()
	..()
	for(var/obj/effect/proc_holder/alien/P in alien_powers)
		owner.RemoveAbility(P)

/obj/item/organ/xenos/eggsac
	name = "egg sac"
	icon_state = "eggsac"

	organ_tag = BP_EGG
	parent_bodypart = BP_GROIN
	alien_powers = list(/obj/effect/proc_holder/alien/lay_egg)

/obj/item/organ/xenos/plasmavessel
	name = "large plasma vessel"
	icon_state = "plasma_large"

	organ_tag = BP_PLASMA
	parent_bodypart = BP_CHEST
	alien_powers = list(/obj/effect/proc_holder/alien/plant, /obj/effect/proc_holder/alien/transfer)

	var/obj/screen/alien_plasma_display
	var/stored_plasma = 125
	var/max_plasma = 500
	var/heal_rate = 5
	var/plasma_rate = 15

/obj/item/organ/xenos/plasmavessel/add_hud_data()
	if(!alien_plasma_display)
		alien_plasma_display = new /obj/screen()
		alien_plasma_display.icon = 'icons/mob/screen1_xeno.dmi'
		alien_plasma_display.icon_state = "power_display3"
		alien_plasma_display.name = "plasma stored"
		alien_plasma_display.screen_loc = ui_alienplasmadisplay

	if(owner && owner.client)
		owner.client.screen += alien_plasma_display
		owner.updatePlasmaDisplay()

/obj/item/organ/xenos/plasmavessel/remove_hud_data(destroy = FALSE)
	if(owner && owner.client)
		owner.client.screen -= alien_plasma_display

	if(destroy)
		qdel(alien_plasma_display)
		alien_plasma_display = null

/obj/item/organ/xenos/plasmavessel/process()
	if(owner)
		//If there are alien weeds on the ground then heal if needed or give some plasma
		if(locate(/obj/structure/alien/weeds) in owner.loc)
			if(owner.health >= owner.maxHealth)
				owner.adjustPlasma(plasma_rate)
			else
				var/heal_amt = heal_rate
				if(!isalien(owner))
					..()
					heal_amt *= 0.2
				owner.adjustPlasma(plasma_rate*0.5)
				owner.adjustBruteLoss(-heal_amt)
				owner.adjustFireLoss(-heal_amt)
				owner.adjustOxyLoss(-heal_amt)
				owner.adjustCloneLoss(-heal_amt)

/obj/item/organ/xenos/plasmavessel/queen
	name = "bloated plasma vessel"
	icon_state = "plasma_large"

	max_plasma = 500
	plasma_rate = 20

/obj/item/organ/xenos/plasmavessel/sentinel
	name = "plasma vessel"
	icon_state = "plasma"

	max_plasma = 250
	plasma_rate = 10

/obj/item/organ/xenos/plasmavessel/hunter
	name = "small plasma vessel"
	icon_state = "plasma_small"

	max_plasma = 150
	plasma_rate = 5

/obj/item/organ/xenos/neurotoxin
	name = "neurotoxin gland"
	icon_state = "neurotox"

	organ_tag = BP_NEURO
	parent_bodypart = BP_HEAD
	alien_powers = list(/obj/effect/proc_holder/alien/neurotoxin)

/obj/item/organ/xenos/acidgland
	name = "acid gland"
	icon_state = "acid"

	organ_tag = BP_ACID
	parent_bodypart = BP_HEAD
	alien_powers = list(/obj/effect/proc_holder/alien/acid)

/obj/item/organ/xenos/hivenode
	name = "hive node"
	icon_state = "hivenode"

	organ_tag = BP_HIVE
	parent_bodypart = BP_CHEST
	alien_powers = list(/obj/effect/proc_holder/alien/whisper)

/obj/item/organ/xenos/hivenode/on_insert()
	..()
	owner.faction = "alien" // TODO faction as list.

/obj/item/organ/xenos/hivenode/on_remove()
	if(owner.faction == "alien")
		owner.faction = null
	..()

/obj/item/organ/xenos/resinspinner
	name = "resin spinner"
	icon_state = "stomach-x"

	organ_tag = BP_RESIN
	parent_bodypart = BP_HEAD
	alien_powers = list(/obj/effect/proc_holder/alien/resin)
