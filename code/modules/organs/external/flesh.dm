// This thing allows to create unique bodyparts very easy just by changing bodypart controller type
/datum/bodypart_controller
	var/name = "Flesh bodypart controller"
	var/obj/item/organ/external/BP
	var/bodypart_type = BODYPART_ORGANIC
	var/damage_threshold = 0

/datum/bodypart_controller/New(obj/item/organ/external/B)
	BP = B

	if(BP.species && BP.species.bodypart_butcher_results)
		BP.butcher_results = BP.species.bodypart_butcher_results.Copy()
	else if(bodypart_type == BODYPART_ORGANIC)
		BP.butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/human = 1)
	else if(bodypart_type == BODYPART_ROBOTIC)
		BP.butcher_results = list(/obj/item/stack/sheet/plasteel = 1)

/datum/bodypart_controller/Destroy()
	BP = null

/datum/bodypart_controller/proc/is_damageable(additional_damage = 0)
	//Continued damage to vital organs can kill you
	return (BP.vital || BP.brute_dam + BP.burn_dam + additional_damage < BP.max_damage)

/datum/bodypart_controller/proc/emp_act(severity)
	return // meatbags do not care about EMP

// Paincrit knocks someone down once they hit 60 shock_stage, so by default make it so that close to 100 additional damage needs to be dealt,
// so that it's similar to PAIN. Lowered it a bit since hitting paincrit takes much longer to wear off than a halloss stun.
// These control the damage thresholds for the various ways of removing limbs
/datum/bodypart_controller/proc/take_damage(brute = 0, burn = 0, damage_flags = 0, used_weapon = null)
	brute = round(brute * BP.owner.species.brute_mod, 0.1)
	burn = round(burn * BP.owner.species.burn_mod, 0.1)

	if((brute <= 0) && (burn <= 0))
		return 0

	if(damage_threshold > brute + burn)
		return 0

	if(BP.is_stump)
		return 0

	var/sharp = (damage_flags & DAM_SHARP)
	var/edge  = (damage_flags & DAM_EDGE)
	var/laser = (damage_flags & DAM_LASER)

	// High brute damage or sharp objects may damage internal organs
	var/damage_amt = brute
	var/cur_damage = BP.brute_dam
	var/pure_brute = brute
	var/pure_burn = burn
	if(laser)
		damage_amt += burn
		cur_damage += BP.burn_dam

	if(BP.bodypart_organs.len && (cur_damage + damage_amt >= BP.max_damage || (((sharp && damage_amt >= 5) || damage_amt >= 10) && prob(5))))
		// Damage an internal organ
		var/obj/item/organ/internal/IO = pick(BP.bodypart_organs)
		IO.take_damage(damage_amt / 2)
		brute /= 2
		if(laser)
			burn /= 2

	if(used_weapon)
		if(brute > 0 && burn == 0)
			BP.add_autopsy_data("[used_weapon]", brute, type_damage = BRUTE)
		else if(brute == 0 && burn > 0)
			BP.add_autopsy_data("[used_weapon]", burn, type_damage = BURN)
		else if(brute > 0 && burn > 0)
			BP.add_autopsy_data("[used_weapon]", brute + burn, type_damage = "mixed")

	var/can_cut = (prob(brute * 2) || sharp) && (bodypart_type != BODYPART_ROBOTIC)

	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	// Non-vital organs are limited to max_damage. You can't kill someone by bludeonging their arm all the way to 200 -- you can
	// push them faster into paincrit though, as the additional damage is converted into shock.
	// (TauCeti) Excess damage will be capped by update_damages() proc.

	var/datum/wound/created_wound
	if(brute)
		if(ishuman(BP.owner))
			var/mob/living/carbon/human/HU = BP.owner
			if(HU.w_uniform && istype(HU.w_uniform, /obj/item/clothing/under/rank/clown))
				playsound(HU, 'sound/effects/squeak.ogg', VOL_EFFECTS_MISC, vol = 65)
		if(can_cut)
			//need to check sharp again here so that blunt damage that was strong enough to break skin doesn't give puncture wounds
			if(sharp && !edge)
				created_wound = BP.createwound( PIERCE, brute )
			else
				created_wound = BP.createwound( CUT, brute )
		else
			created_wound = BP.createwound( BRUISE, brute )
	if(burn)
		if(laser)
			created_wound = BP.createwound( LASER, burn )
		else
			created_wound = BP.createwound( BURN, burn )

	// If there are still hurties to dispense
	var/spillover = cur_damage + damage_amt + BP.burn_dam + burn - BP.max_damage // excess damage goes off into shock_stage, this var also can prevent dismemberment, if result is negative.

	if(spillover > 0)
		BP.owner.shock_stage += spillover * ORGAN_DAMAGE_SPILLOVER_MULTIPLIER

	// sync the organ's damage with its wounds
	BP.update_damages()
	BP.owner.updatehealth() //droplimb will call updatehealth() again if it does end up being called
	BP.owner.time_of_last_damage = world.time

	// sounds
	var/current_bp_damage = BP.get_damage()
	var/pain_emote_name
	var/previous_pain_emote_name
	var/total_weapon_damage = round(brute + burn)
	if(BP.owner.stat == CONSCIOUS)
		switch(total_weapon_damage)
			if(1 to 4)
				if(HAS_TRAIT(BP.owner, TRAIT_LOW_PAIN_THRESHOLD) && prob(total_weapon_damage * 15))
					previous_pain_emote_name = "grunt"
			if(5 to 19)
				if(HAS_TRAIT(BP.owner, TRAIT_LOW_PAIN_THRESHOLD) && prob(total_weapon_damage * 5))
					pain_emote_name = "scream"
				else if(HAS_TRAIT(BP.owner, TRAIT_HIGH_PAIN_THRESHOLD) && prob(total_weapon_damage * 5))
					previous_pain_emote_name = "grunt"
				else
					previous_pain_emote_name = "grunt"
			if(20 to INFINITY)
				if(HAS_TRAIT(BP.owner, TRAIT_HIGH_PAIN_THRESHOLD) && !prob(total_weapon_damage))
					pain_emote_name = "grunt"
				else if(HAS_TRAIT(BP.owner, TRAIT_LOW_PAIN_THRESHOLD) || prob(total_weapon_damage * 3))
					previous_pain_emote_name = "scream"
				else
					previous_pain_emote_name = "grunt"
		switch(current_bp_damage)
			if(1 to 15)
				if((!HAS_TRAIT(BP.owner, TRAIT_HIGH_PAIN_THRESHOLD) && prob(current_bp_damage * 4)) || (HAS_TRAIT(BP.owner, TRAIT_LOW_PAIN_THRESHOLD) && prob(current_bp_damage * 6)))
					pain_emote_name = "grunt"
			if(15 to 29)
				if(total_weapon_damage < 20)
					if(HAS_TRAIT(BP.owner, TRAIT_LOW_PAIN_THRESHOLD) && prob(current_bp_damage * 3))
						pain_emote_name = "scream"
					else if(HAS_TRAIT(BP.owner, TRAIT_HIGH_PAIN_THRESHOLD) && prob(current_bp_damage * 3))
						pain_emote_name = "grunt"
					else
						pain_emote_name = "grunt"
			if(30 to INFINITY)
				if(HAS_TRAIT(BP.owner, TRAIT_HIGH_PAIN_THRESHOLD) && !prob(current_bp_damage))
					pain_emote_name = "grunt"
				else if(prob(current_bp_damage + total_weapon_damage * 4) || HAS_TRAIT(BP.owner, TRAIT_LOW_PAIN_THRESHOLD))
					pain_emote_name = "scream"
				else
					pain_emote_name = "grunt"
		if(pain_emote_name)
			BP.owner.time_of_last_damage = world.time // don't cry from the pain that just came
			if(previous_pain_emote_name == "scream" || pain_emote_name == "scream") // "scream" sounds have priority
				BP.owner.emote("scream")
			else
				BP.owner.emote("grunt")

	//If limb took enough damage, try to cut or tear it off
	if(BP.owner && !(BP.is_stump))
		if(!BP.cannot_amputate && (BP.brute_dam + BP.burn_dam + brute + burn + spillover) >= (BP.max_damage * config.organ_health_multiplier))
			//organs can come off in three cases
			//1. If the damage source is edge_eligible and the brute damage dealt exceeds the edge threshold, then the organ is cut off.
			//2. If the damage amount dealt exceeds the disintegrate threshold, the organ is completely obliterated.
			//3. If the organ has already reached or would be put over it's max damage amount (currently redundant),
			//   and the brute damage dealt exceeds the tearoff threshold, the organ is torn off.
			//Check edge eligibility
			var/edge_eligible = 0
			if(edge)
				if(istype(used_weapon, /obj/item))
					var/obj/item/W = used_weapon
					if(W.w_class >= BP.w_class)
						edge_eligible = 1
				else
					edge_eligible = 1

			if(edge_eligible && pure_brute >= BP.max_damage / DROPLIMB_THRESHOLD_EDGE && prob(pure_brute))
				BP.droplimb(null, null, DROPLIMB_EDGE)
			else if(pure_burn >= BP.max_damage / DROPLIMB_THRESHOLD_DESTROY && prob(pure_burn / 3))
				BP.droplimb(null, null, DROPLIMB_BURN)
			else if(pure_brute >= BP.max_damage / DROPLIMB_THRESHOLD_DESTROY && prob(pure_brute))
				BP.droplimb(null, null, DROPLIMB_BLUNT)
			else if(pure_brute >= BP.max_damage / DROPLIMB_THRESHOLD_TEAROFF && prob(pure_brute / 3))
				BP.droplimb(null, null, DROPLIMB_EDGE)

	if(BP && BP.update_damstate() && BP.owner)
		BP.owner.UpdateDamageIcon(BP)

	return created_wound

/datum/bodypart_controller/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(bodypart_type == BODYPART_ROBOTIC && !robo_repair)
		return

	//Heal damage on the individual wounds
	for(var/datum/wound/W in BP.wounds)
		if(brute == 0 && burn == 0)
			break

		switch(W.damage_type)
			if(BURN, LASER) // heal burn damage
				burn = W.heal_damage(burn)
			else // heal brute damage
				brute = W.heal_damage(brute)

	if(internal)
		BP.status &= ~ORGAN_BROKEN
		BP.perma_injury = 0

	//Sync the organ's damage with its wounds
	BP.update_damages()
	BP.owner.updatehealth()

	var/result = BP.update_damstate()
	if(result)
		BP.owner.UpdateDamageIcon(BP)
	return result

/*
This function completely restores a damaged organ to perfect condition.
*/
/datum/bodypart_controller/proc/rejuvenate()
	BP.damage_state = "00"
	BP.status = 0

	BP.perma_injury = 0
	BP.brute_dam = 0
	BP.open = 0
	BP.burn_dam = 0
	BP.germ_level = 0
	for(var/datum/wound/W in BP.wounds)
		W.embedded_objects.Cut()
	BP.wounds.Cut()
	BP.number_wounds = 0

	// handle organs
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		IO.rejuvenate()

	// remove embedded objects and drop them on the floor
	for(var/obj/implanted_object in BP.implants)
		if(!istype(implanted_object,/obj/item/weapon/implant))	// We don't want to remove REAL implants. Just shrapnel etc.
			implanted_object.forceMove(BP.owner.loc)
			BP.implants -= implanted_object

	BP.owner.updatehealth()

/datum/bodypart_controller/proc/createwound(type = CUT, damage)
	if(damage == 0)
		return

	//moved this before the open_wound check so that having many small wounds for example doesn't somehow protect you from taking internal damage (because of the return)
	//Brute damage can possibly trigger an internal wound, too.
	var/local_damage = BP.brute_dam + BP.burn_dam + damage
	if((type in list(CUT, PIERCE, BRUISE)) && damage > 15 && local_damage > 30)

		var/internal_damage
		if(prob(damage) && BP.sever_artery())
			internal_damage = TRUE
		if(internal_damage)
			BP.owner.custom_pain("You feel something rip in your [BP.name]!", 1)

	//Burn damage can cause fluid loss due to blistering and cook-off
	if((type in list(BURN, LASER)) && (damage > 5 || damage + BP.burn_dam >= 15) && bodypart_type != BODYPART_ROBOTIC)
		var/fluid_loss_severity
		switch(type)
			if(BURN)  fluid_loss_severity = FLUIDLOSS_WIDE_BURN
			if(LASER) fluid_loss_severity = FLUIDLOSS_CONC_BURN
		var/fluid_loss = (damage / (BP.owner.maxHealth - config.health_threshold_dead)) * 560/*owner.species.blood_volume*/ * fluid_loss_severity
		BP.owner.remove_blood(fluid_loss)

	// first check whether we can widen an existing wound
	if(BP.wounds.len > 0 && prob(max(50 + (BP.number_wounds - 1) * 10, 90)))
		if((type == CUT || type == BRUISE) && damage >= 5)
			//we need to make sure that the wound we are going to worsen is compatible with the type of damage...
			var/list/compatible_wounds = list()
			for (var/datum/wound/W in BP.wounds)
				if (W.can_worsen(type, damage))
					compatible_wounds += W

			if(compatible_wounds.len)
				var/datum/wound/W = pick(compatible_wounds)
				W.open_wound(damage)
				if(prob(25))
					if(bodypart_type == BODYPART_ROBOTIC)
						BP.owner.visible_message(
							"<span class='danger'>The damage to [BP.owner.name]'s [BP.name] worsens.</span>",
							"<span class='danger'>The damage to your [BP.name] worsens.</span>",
							"<span class='danger'>You hear the screech of abused metal.</span>"
							)
					else
						BP.owner.visible_message(
							"<span class='danger'>The wound on [BP.owner.name]'s [BP.name] widens with a nasty ripping voice.</span>",
							"<span class='danger'>The wound on your [BP.name] widens with a nasty ripping voice.</span>",
							"<span class='danger'>You hear a nasty ripping noise, as if flesh is being torn apart.</span>"
							)
				return W

	//Creating wound
	var/wound_type = get_wound_type(type, damage)

	if(wound_type)
		var/datum/wound/W = new wound_type(damage)

		//Check whether we can add the wound to an existing wound
		for(var/datum/wound/other in BP.wounds)
			if(other.can_merge(W))
				other.merge_wound(W)
				W = null // to signify that the wound was added
				break
		if(W)
			BP.wounds += W
		return W

//Determines if we even need to process this organ.

/datum/bodypart_controller/proc/need_process()
	if(BP.brute_dam || BP.burn_dam)
		return TRUE
	if(BP.last_dam != BP.brute_dam + BP.burn_dam) // Process when we are fully healed up.
		BP.last_dam = BP.brute_dam + BP.burn_dam
		return TRUE
	else
		BP.last_dam = BP.brute_dam + BP.burn_dam
	if(BP.germ_level)
		return TRUE
	if(BP.is_rejecting)
		return TRUE
	return FALSE

/datum/bodypart_controller/process()
	if(!BP.is_attached()) // rot if we are not inside a body
		process_outside()
		return

	// Process wounds, doing healing etc. Only do this every few ticks to save processing power
	if(BP.owner.life_tick % BP.wound_update_accuracy == 0)
		BP.update_wounds()

	//Chem traces slowly vanish
	if(BP.owner.life_tick % 10 == 0)
		for(var/chemID in BP.trace_chemicals)
			BP.trace_chemicals[chemID] = BP.trace_chemicals[chemID] - 1
			if(BP.trace_chemicals[chemID] <= 0)
				BP.trace_chemicals.Remove(chemID)

	/*if(BP.parent)
		if(BP.parent.is_stump)
			BP.status |= ORGAN_DESTROYED
			BP.owner.update_body()
			return*/

	if(!(BP.status & ORGAN_BROKEN))
		BP.perma_injury = 0

	//Infections
	BP.update_germs()


//Updating germ levels. Handles organ germ levels and necrosis.
/*
The INFECTION_LEVEL values defined in setup.dm control the time it takes to reach the different
infection levels. Since infection growth is exponential, you can adjust the time it takes to get
from one germ_level to another using the rough formula:

desired_germ_level = initial_germ_level*e^(desired_time_in_seconds/1000)

So if I wanted it to take an average of 15 minutes to get from level one (100) to level two
I would set INFECTION_LEVEL_TWO to 100*e^(15*60/1000) = 245. Note that this is the average time,
the actual time is dependent on RNG.

INFECTION_LEVEL_ONE		below this germ level nothing happens, and the infection doesn't grow
INFECTION_LEVEL_TWO		above this germ level the infection will start to spread to internal and adjacent bodyparts
INFECTION_LEVEL_THREE	above this germ level the player will take additional toxin damage per second, and will die in minutes without
						antitox. also, above this germ level you will need to overdose on spaceacillin to reduce the germ_level.

Note that amputating the affected organ does in fact remove the infection from the player's body.
*/
/datum/bodypart_controller/proc/update_germs()
	if(BP.owner.species && BP.owner.species.flags[IS_PLANT]) //Robotic limbs shouldn't be infected, nor should nonexistant limbs.
		BP.germ_level = 0
		return

	if(BP.owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Syncing germ levels with external wounds
		handle_germ_sync()

		//** Handle antibiotics and curing infections
		BP.handle_antibiotics()

		//** Handle rejection because of incompatibility
		handle_rejection()

		//** Handle the effects of infections
		handle_germ_effects()

/datum/bodypart_controller/proc/handle_germ_sync()
	var/antibiotics = BP.owner.reagents.get_reagent_amount("spaceacillin")
	for(var/datum/wound/W in BP.wounds)
		//Open wounds can become infected
		if (BP.owner.germ_level > W.germ_level && W.infection_check())
			W.germ_level++

	if (antibiotics < 5)
		for(var/datum/wound/W in BP.wounds)
			//Infected wounds raise the organ's germ level
			if (W.germ_level > BP.germ_level)
				BP.germ_level = min(W.amount + BP.germ_level, W.germ_level) //faster infections from dirty wounds, but not faster than natural wound germification.

/datum/bodypart_controller/proc/handle_germ_effects()
	var/antibiotics = BP.owner.reagents.get_reagent_amount("spaceacillin")

	if (BP.germ_level > 0 && BP.germ_level < INFECTION_LEVEL_ONE && prob(60))	//this could be an else clause, but it looks cleaner this way
		BP.germ_level--	//since germ_level increases at a rate of 1 per second with dirty wounds, prob(60) should give us about 5 minutes before level one.

	if(BP.germ_level >= INFECTION_LEVEL_ONE)
		//having an infection raises your body temperature
		var/fever_temperature = (BP.owner.species.heat_level_1 - BP.owner.species.body_temperature - 5)* min(BP.germ_level/INFECTION_LEVEL_TWO, 1) + BP.owner.species.body_temperature
		//need to make sure we raise temperature fast enough to get around environmental cooling preventing us from reaching fever_temperature
		BP.owner.bodytemperature += between(0, (fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - BP.owner.bodytemperature)

		if(prob(round(BP.germ_level/10)))
			if (antibiotics < 5)
				BP.germ_level++

			if (prob(10))	//adjust this to tweak how fast people take toxin damage from infections
				BP.owner.adjustToxLoss(1)

	if(BP.germ_level >= INFECTION_LEVEL_TWO && antibiotics < 5)
		//spread the infection to organs
		var/obj/item/organ/internal/target_organ = null	//make organs become infected one at a time instead of all at once
		for (var/obj/item/organ/internal/IO in BP.bodypart_organs)
			if (IO.germ_level > 0 && IO.germ_level < min(BP.germ_level, INFECTION_LEVEL_TWO))	//once the organ reaches whatever we can give it, or level two, switch to a different one
				if (!target_organ || IO.germ_level > target_organ.germ_level)	//choose the organ with the highest germ_level
					target_organ = IO

		if (!target_organ)
			//figure out which organs we can spread germs to and pick one at random
			var/list/candidate_organs = list()
			for (var/obj/item/organ/internal/IO in BP.bodypart_organs)
				if (IO.germ_level < BP.germ_level)
					candidate_organs += IO
			if (candidate_organs.len)
				target_organ = pick(candidate_organs)

		if (target_organ)
			target_organ.germ_level++

		//spread the infection to child and parent bodyparts
		if (BP.children)
			for (var/obj/item/organ/external/ChildBP in BP.children)
				if (ChildBP.germ_level < BP.germ_level && !ChildBP.is_robotic())
					if (ChildBP.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30))
						ChildBP.germ_level++

		if (BP.parent)
			if (BP.parent.germ_level < BP.germ_level && !BP.parent.is_robotic())
				if (BP.parent.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30))
					BP.parent.germ_level++

	if(BP.germ_level >= INFECTION_LEVEL_THREE && antibiotics < 30)	//overdosing is necessary to stop severe infections
		if (!(BP.status & ORGAN_DEAD))
			BP.status |= ORGAN_DEAD
			to_chat(BP.owner, "<span class='notice'>You can't feel your [BP.name] anymore...</span>")
			BP.owner.update_body()

		BP.germ_level++
		BP.owner.adjustToxLoss(1)

//Updating wounds. Handles wound natural I had some free spachealing, internal bleedings and infections
/datum/bodypart_controller/proc/update_wounds()
	for(var/datum/wound/W in BP.wounds)
		// wounds can disappear after 10 minutes at the earliest
		if(W.damage <= 0 && W.created + (10 MINUTES) <= world.time)
			BP.wounds -= W
			continue
			// let the GC handle the deletion of the wound

		// slow healing
		var/heal_amt = 0

		// if damage >= 50 AFTER treatment then it's probably too severe to heal within the timeframe of a round.
		if (W.can_autoheal() && W.wound_damage() < 50)
			heal_amt += 0.5
			var/mob/living/carbon/H = BP.owner
			if(H.IsSleeping())
				if(istype(H.buckled, /obj/structure/stool/bed))
					heal_amt += 0.2
				else if((locate(/obj/structure/table) in H.loc))
					heal_amt += 0.1
				if((locate(/obj/item/weapon/bedsheet) in H.loc))
					heal_amt += 0.1

		//we only update wounds once in [wound_update_accuracy] ticks so have to emulate realtime
		heal_amt = heal_amt * BP.wound_update_accuracy
		//configurable regen speed woo, no-regen hardcore or instaheal hugbox, choose your destiny
		heal_amt = heal_amt * config.organ_regeneration_multiplier
		// amount of healing is spread over all the wounds
		heal_amt = heal_amt / (BP.wounds.len + 1)
		// making it look prettier on scanners
		heal_amt = round(heal_amt,0.1)
		W.heal_damage(heal_amt)

		// Salving also helps against infection
		if(W.germ_level > 0 && W.salved && prob(2))
			W.disinfected = 1
			W.germ_level = 0

	// sync the organ's damage with its wounds
	BP.update_damages()
	if(BP.update_damstate())
		BP.owner.UpdateDamageIcon(BP)

//Updates brute_damn and burn_damn from wound damages. Updates BLEEDING status.
/datum/bodypart_controller/proc/update_damages()
	BP.number_wounds = 0
	BP.brute_dam = 0
	BP.burn_dam = 0
	BP.status &= ~ORGAN_BLEEDING
	var/clamped = 0

	//update damage counts
	for(var/datum/wound/W in BP.wounds)
		if(W.damage_type == BURN)
			BP.burn_dam += W.damage
		else
			BP.brute_dam += W.damage

		if(W.bleeding() && (BP.owner && BP.owner.should_have_organ(O_HEART)))
			W.bleed_timer = max(0, W.bleed_timer - 1)
			BP.status |= ORGAN_BLEEDING

		clamped |= W.clamped
		BP.number_wounds += W.amount

	// Continued damage to vital organs can kill you, and robot organs don't count towards total damage so no need to cap them.
	if(!BP.vital)
		BP.brute_dam = min(BP.brute_dam, BP.max_damage)
		BP.burn_dam = min(BP.burn_dam, BP.max_damage)

	//things tend to bleed if they are CUT OPEN
	if(BP.owner && BP.owner.should_have_organ(O_HEART) && (BP.open && !clamped))
		BP.status |= ORGAN_BLEEDING

	//Bone fractures
	if(BP.brute_dam > BP.min_broken_damage * config.organ_health_multiplier)
		BP.fracture()

/datum/bodypart_controller/proc/damage_state_color()
	return BP.species.blood_datum.color

/datum/bodypart_controller/proc/sever_artery()
	if(!(BP.status & ORGAN_ARTERY_CUT) && BP.owner.organs_by_name[O_HEART])
		BP.status |= ORGAN_ARTERY_CUT
		return TRUE
	return FALSE

/datum/bodypart_controller/proc/fracture()
	if(BP.owner.dna && BP.owner.dna.mutantrace == "adamantine")
		return

	if(BP.status & ORGAN_BROKEN)
		return

	BP.owner.visible_message(
		"<span class='warning'>You hear a loud cracking sound coming from \the [BP.owner].</span>",
		"<span class='warning'><b>Something feels like it shattered in your [BP.name]!</b></span>",
		"You hear a sickening crack.")

	if(BP.owner.species && !BP.owner.species.flags[NO_PAIN])
		BP.owner.emote("scream")

	if((HULK in BP.owner.mutations) && BP.owner.hulk_activator == ACTIVATOR_BROKEN_BONE)
		BP.owner.try_mutate_to_hulk()

	playsound(BP.owner, pick(SOUNDIN_BONEBREAK), VOL_EFFECTS_MASTER, null, null, -2)
	BP.status |= ORGAN_BROKEN
	BP.broken_description = pick("broken", "fracture", "hairline fracture")
	BP.perma_injury = BP.brute_dam

	// Fractures have a chance of getting you out of restraints
	if (prob(25))
		BP.release_restraints()

	// This is mostly for the ninja suit to stop ninja being so crippled by breaks.
	// TODO: consider moving this to a suit proc or process() or something during
	// hardsuit rewrite.
	if(!(BP.status & ORGAN_SPLINTED) && istype(BP.owner,/mob/living/carbon/human))

		var/mob/living/carbon/human/H = BP.owner

		if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))

			var/obj/item/clothing/suit/space/suit = H.wear_suit

			if(isnull(suit.supporting_limbs))
				return

			to_chat(BP.owner, "You feel \the [suit] constrict about your [BP.name], supporting it.")
			BP.status |= ORGAN_SPLINTED
			suit.supporting_limbs |= BP

/datum/bodypart_controller/proc/handle_cut()
	START_PROCESSING(SSobj, BP) // STOP_PROCESSING will be called from insert_organ()

/datum/bodypart_controller/proc/process_outside()
	if(BP.is_preserved())
		return

	BP.germ_level += rand(2,6)
	if(BP.germ_level >= INFECTION_LEVEL_TWO)
		BP.germ_level += rand(2,6)
	if(BP.germ_level >= INFECTION_LEVEL_THREE)
		STOP_PROCESSING(SSobj, BP)
		BP.status |= ORGAN_DEAD
		BP.update_sprite()

// Runs once when attached
/datum/bodypart_controller/proc/check_rejection()
	BP.is_rejecting = TRUE
	var/chances = 100

	if(BP.owner.species.name != BP.species.name)
		chances *= 0.02

	if(blood_incompatible(BP.owner.dna.b_type, BP.b_type))
		chances *= 0.4

	if(prob(chances))
		BP.is_rejecting = FALSE

/datum/bodypart_controller/proc/handle_rejection()
	if(!BP.is_rejecting)
		return

	BP.germ_level += rand(2,6)

	if(prob(2))
		to_chat(BP.owner, "<span class='warning'>Your [BP.name] really hurts...</span>")
		BP.owner.adjustToxLoss(rand(1,5))
