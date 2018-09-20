/****************************************************
				BODYPARTS
****************************************************/
/obj/item/organ/external
	name = "external"

	// Strings
	var/broken_description            // fracture string if any.
	var/damage_state = "00"           // Modifier used for generating the on-mob damage overlay for this limb.

	// Damage vars.
	var/brute_dam = 0                 // Actual current brute damage.
	var/burn_dam = 0                  // Actual current burn damage.
	var/last_dam = -1                 // used in healing/processing calculations.
	var/max_damage = 0                // Damage cap

	// Appearance vars.
	var/body_part = null              // Part flag
	var/body_zone = null              // Unique identifier of this limb.
	var/icon_position = 0             // Used in mob overlay layering calculations.

	// Wound and structural data.
	var/wound_update_accuracy = 1     // how often wounds should be updated, a higher number means less often
	var/list/wounds = list()          // wound datum list.
	var/number_wounds = 0             // number of wounds, which is NOT wounds.len!
	var/list/children = list()        // Sub-limbs.
	var/list/bodypart_organs = list() // Internal organs of this body part
	var/sabotaged = 0                 // If a prosthetic limb is emagged, it will detonate when it fails.
	var/list/implants = list()        // Currently implanted objects.

	// Joint/state stuff.
	var/cannot_amputate               // Impossible to amputate.
	var/artery_name = "artery"        // Flavour text for cartoid artery, aorta, etc.
	var/arterial_bleed_severity = 1   // Multiplier for bleeding in a limb.

	// Surgery vars.
	var/open = 0
	var/stage = 0
	var/cavity = 0
	var/atom/movable/applied_pressure

	// Will be removed, moved or refactored.
	var/obj/item/hidden = null // relation with cavity
	var/tmp/perma_injury = 0
	var/tmp/destspawn = 0 //Has it spawned the broken limb?
	var/tmp/amputated = 0 //Whether this has been cleanly amputated, thus causing no pain
	var/limb_layer = 0
	var/damage_msg = "\red You feel an intense pain"

	var/regen_bodypart_penalty = 0 // This variable determines how much time it would take to regenerate a bodypart, and the cost of it's regeneration.

/obj/item/organ/external/insert_organ()
	..()

	owner.bodyparts += src
	owner.bodyparts_by_name[body_zone] = src

	if(parent)
		parent.children += src

/****************************************************
			   DAMAGE PROCS
****************************************************/

/obj/item/organ/external/proc/is_damageable(additional_damage = 0)
	//Continued damage to vital organs can kill you, and robot organs don't count towards total damage so no need to cap them.
	return (vital || (status & ORGAN_ROBOT) || brute_dam + burn_dam + additional_damage < max_damage)


/obj/item/organ/external/emp_act(severity)
	if(!(status & ORGAN_ROBOT)) // meatbags do not care about EMP
		return

	var/burn_damage = 0
	switch(severity)
		if(1)
			burn_damage = 15
		if(2)
			burn_damage = 7
		if(3)
			burn_damage = 3

	if(burn_damage)
		take_damage(null, burn_damage)

// Paincrit knocks someone down once they hit 60 shock_stage, so by default make it so that close to 100 additional damage needs to be dealt,
// so that it's similar to PAIN. Lowered it a bit since hitting paincrit takes much longer to wear off than a halloss stun.
// These control the damage thresholds for the various ways of removing limbs
#define DROPLIMB_THRESHOLD_EDGE    5
#define DROPLIMB_THRESHOLD_TEAROFF 2
#define DROPLIMB_THRESHOLD_DESTROY 1
#define ORGAN_DAMAGE_SPILLOVER_MULTIPLIER 0.005
/obj/item/organ/external/proc/take_damage(brute = 0, burn = 0, damage_flags = 0, used_weapon = null)
	brute = round(brute * owner.species.brute_mod, 0.1)
	burn = round(burn * owner.species.burn_mod, 0.1)

	if((brute <= 0) && (burn <= 0))
		return 0

	if(status & ORGAN_DESTROYED)
		return 0

	var/sharp = (damage_flags & DAM_SHARP)
	var/edge  = (damage_flags & DAM_EDGE)
	var/laser = (damage_flags & DAM_LASER)

	// High brute damage or sharp objects may damage internal organs
	var/damage_amt = brute
	var/cur_damage = brute_dam
	var/pure_brute = brute
	var/pure_burn = burn
	if(laser)
		damage_amt += burn
		cur_damage += burn_dam

	if(bodypart_organs.len && (cur_damage + damage_amt >= max_damage || (((sharp && damage_amt >= 5) || damage_amt >= 10) && prob(5))))
		// Damage an internal organ
		var/obj/item/organ/internal/IO = pick(bodypart_organs)
		IO.take_damage(damage_amt / 2)
		brute /= 2
		if(laser)
			burn /= 2

	if((status & ORGAN_BROKEN) && prob(40) && brute)
		owner.emote("scream",,, 1)	//getting hit on broken hand hurts
	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)

	var/can_cut = (prob(brute * 2) || sharp) && !(status & ORGAN_ROBOT)

	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	// Non-vital organs are limited to max_damage. You can't kill someone by bludeonging their arm all the way to 200 -- you can
	// push them faster into paincrit though, as the additional damage is converted into shock.
	// (TauCeti) Excess damage will be capped by update_damages() proc.

	var/datum/wound/created_wound
	if(brute)
		if(can_cut)
			//need to check sharp again here so that blunt damage that was strong enough to break skin doesn't give puncture wounds
			if(sharp && !edge)
				created_wound = createwound( PIERCE, brute )
			else
				created_wound = createwound( CUT, brute )
		else
			createwound( BRUISE, brute )
	if(burn)
		if(laser)
			createwound( LASER, burn )
		else
			createwound( BURN, burn )

	// If there are still hurties to dispense
	var/spillover = cur_damage + damage_amt + burn_dam + burn - max_damage // excess damage goes off into shock_stage, this var also can prevent dismemberment, if result is negative.

	if(spillover > 0)
		owner.shock_stage += spillover * ORGAN_DAMAGE_SPILLOVER_MULTIPLIER

	// sync the organ's damage with its wounds
	update_damages()
	owner.updatehealth() //droplimb will call updatehealth() again if it does end up being called

	//If limb took enough damage, try to cut or tear it off
	if(owner && !(status & ORGAN_DESTROYED))
		if(!cannot_amputate && (brute_dam + burn_dam + brute + burn + spillover) >= (max_damage * config.organ_health_multiplier))
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
					if(W.w_class >= w_class)
						edge_eligible = 1
				else
					edge_eligible = 1

			if(edge_eligible && pure_brute >= max_damage / DROPLIMB_THRESHOLD_EDGE && prob(pure_brute))
				droplimb(null, null, DROPLIMB_EDGE)
			else if(pure_burn >= max_damage / DROPLIMB_THRESHOLD_DESTROY && prob(pure_burn / 3))
				droplimb(null, null, DROPLIMB_BURN)
			else if(pure_brute >= max_damage / DROPLIMB_THRESHOLD_DESTROY && prob(pure_brute))
				droplimb(null, null, DROPLIMB_BLUNT)
			else if(pure_brute >= max_damage / DROPLIMB_THRESHOLD_TEAROFF && prob(pure_brute / 3))
				droplimb(null, null, DROPLIMB_EDGE)

	if(update_damstate())
		owner.UpdateDamageIcon(src)

	return created_wound
#undef DROPLIMB_THRESHOLD_EDGE
#undef DROPLIMB_THRESHOLD_TEAROFF
#undef DROPLIMB_THRESHOLD_DESTROY
#undef ORGAN_DAMAGE_SPILLOVER_MULTIPLIER

/obj/item/organ/external/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(status & ORGAN_ROBOT && !robo_repair)
		return

	//Heal damage on the individual wounds
	for(var/datum/wound/W in wounds)
		if(brute == 0 && burn == 0)
			break

		switch(W.damage_type)
			if(BURN, LASER) // heal burn damage
				burn = W.heal_damage(burn)
			else // heal brute damage
				brute = W.heal_damage(brute)

	if(internal)
		status &= ~ORGAN_BROKEN
		perma_injury = 0

	//Sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	var/result = update_damstate()
	if(result)
		owner.UpdateDamageIcon(src)
	return result

/*
This function completely restores a damaged organ to perfect condition.
*/
/obj/item/organ/external/proc/rejuvenate()
	damage_state = "00"
	if(status & ORGAN_ROBOT) // Robotic body parts stay robotic.  Fix because right click rejuvinate makes IPC's body parts organic.
		status = ORGAN_ROBOT
	else
		status = 0

	amputated = 0
	destspawn = 0
	perma_injury = 0
	brute_dam = 0
	open = 0
	burn_dam = 0
	germ_level = 0
	for(var/datum/wound/W in wounds)
		W.embedded_objects.Cut()
	wounds.Cut()
	number_wounds = 0

	// handle organs
	for(var/obj/item/organ/internal/IO in bodypart_organs)
		IO.rejuvenate()

	// remove embedded objects and drop them on the floor
	for(var/obj/implanted_object in implants)
		if(!istype(implanted_object,/obj/item/weapon/implant))	// We don't want to remove REAL implants. Just shrapnel etc.
			implanted_object.forceMove(owner.loc)
			implants -= implanted_object

	owner.updatehealth()

/obj/item/organ/external/head/rejuvenate()
	..()
	owner.client.perspective = MOB_PERSPECTIVE
	owner.client.eye = owner // Deheading species that do not need a head causes them to view the world from a perspective of their head.

/obj/item/organ/external/proc/createwound(type = CUT, damage)
	if(damage == 0)
		return

	//moved this before the open_wound check so that having many small wounds for example doesn't somehow protect you from taking internal damage (because of the return)
	//Brute damage can possibly trigger an internal wound, too.
	var/local_damage = brute_dam + burn_dam + damage
	if((type in list(CUT, PIERCE, BRUISE)) && damage > 15 && local_damage > 30)

		var/internal_damage
		if(prob(damage) && sever_artery())
			internal_damage = TRUE
		if(internal_damage)
			owner.custom_pain("You feel something rip in your [name]!", 1)

	//Burn damage can cause fluid loss due to blistering and cook-off
	if((type in list(BURN, LASER)) && (damage > 5 || damage + burn_dam >= 15) && !(status & ORGAN_ROBOT))
		var/fluid_loss_severity
		switch(type)
			if(BURN)  fluid_loss_severity = FLUIDLOSS_WIDE_BURN
			if(LASER) fluid_loss_severity = FLUIDLOSS_CONC_BURN
		var/fluid_loss = (damage / (owner.maxHealth - config.health_threshold_dead)) * 560/*owner.species.blood_volume*/ * fluid_loss_severity
		owner.remove_blood(fluid_loss)

	// first check whether we can widen an existing wound
	if(wounds.len > 0 && prob(max(50 + (number_wounds - 1) * 10, 90)))
		if((type == CUT || type == BRUISE) && damage >= 5)
			//we need to make sure that the wound we are going to worsen is compatible with the type of damage...
			var/list/compatible_wounds = list()
			for (var/datum/wound/W in wounds)
				if (W.can_worsen(type, damage))
					compatible_wounds += W

			if(compatible_wounds.len)
				var/datum/wound/W = pick(compatible_wounds)
				W.open_wound(damage)
				if(prob(25))
					if(status & ORGAN_ROBOT)
						owner.visible_message(
							"<span class='danger'>The damage to [owner.name]'s [name] worsens.</span>",
							"<span class='danger'>The damage to your [name] worsens.</span>",
							"<span class='danger'>You hear the screech of abused metal.</span>"
							)
					else
						owner.visible_message(
							"<span class='danger'>The wound on [owner.name]'s [name] widens with a nasty ripping voice.</span>",
							"<span class='danger'>The wound on your [name] widens with a nasty ripping voice.</span>",
							"<span class='danger'>You hear a nasty ripping noise, as if flesh is being torn apart.</span>"
							)
				return W

	//Creating wound
	var/wound_type = get_wound_type(type, damage)

	if(wound_type)
		var/datum/wound/W = new wound_type(damage)

		//Check whether we can add the wound to an existing wound
		for(var/datum/wound/other in wounds)
			if(other.can_merge(W))
				other.merge_wound(W)
				W = null // to signify that the wound was added
				break
		if(W)
			wounds += W
		return W

/****************************************************
			   PROCESSING & UPDATING
****************************************************/

//Determines if we even need to process this organ.

/obj/item/organ/external/proc/need_process()
	if(status && (status & ORGAN_ROBOT)) // If it's robotic, that's fine it will have a status.
		return 1
	if(brute_dam || burn_dam)
		return 1
	if(last_dam != brute_dam + burn_dam) // Process when we are fully healed up.
		last_dam = brute_dam + burn_dam
		return 1
	else
		last_dam = brute_dam + burn_dam
	if(germ_level)
		return 1
	return 0

/obj/item/organ/external/process()
	// Process wounds, doing healing etc. Only do this every few ticks to save processing power
	if(owner.life_tick % wound_update_accuracy == 0)
		update_wounds()

	//Chem traces slowly vanish
	if(owner.life_tick % 10 == 0)
		for(var/chemID in trace_chemicals)
			trace_chemicals[chemID] = trace_chemicals[chemID] - 1
			if(trace_chemicals[chemID] <= 0)
				trace_chemicals.Remove(chemID)

	if(parent)
		if(parent.status & ORGAN_DESTROYED)
			status |= ORGAN_DESTROYED
			owner.update_body()
			return

	if(!(status & ORGAN_BROKEN))
		perma_injury = 0

	//Infections
	update_germs()

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
/obj/item/organ/external/proc/update_germs()

	if((status & (ORGAN_ROBOT|ORGAN_DESTROYED)) || (owner.species && owner.species.flags[IS_PLANT])) //Robotic limbs shouldn't be infected, nor should nonexistant limbs.
		germ_level = 0
		return

	if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Syncing germ levels with external wounds
		handle_germ_sync()

		//** Handle antibiotics and curing infections
		handle_antibiotics()

		//** Handle the effects of infections
		handle_germ_effects()

/obj/item/organ/external/proc/handle_germ_sync()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")
	for(var/datum/wound/W in wounds)
		//Open wounds can become infected
		if (owner.germ_level > W.germ_level && W.infection_check())
			W.germ_level++

	if (antibiotics < 5)
		for(var/datum/wound/W in wounds)
			//Infected wounds raise the organ's germ level
			if (W.germ_level > germ_level)
				germ_level = min(W.amount + germ_level, W.germ_level) //faster infections from dirty wounds, but not faster than natural wound germification.

/obj/item/organ/external/proc/handle_germ_effects()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE && prob(60))	//this could be an else clause, but it looks cleaner this way
		germ_level--	//since germ_level increases at a rate of 1 per second with dirty wounds, prob(60) should give us about 5 minutes before level one.

	if(germ_level >= INFECTION_LEVEL_ONE)
		//having an infection raises your body temperature
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		//need to make sure we raise temperature fast enough to get around environmental cooling preventing us from reaching fever_temperature
		owner.bodytemperature += between(0, (fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature)

		if(prob(round(germ_level/10)))
			if (antibiotics < 5)
				germ_level++

			if (prob(10))	//adjust this to tweak how fast people take toxin damage from infections
				owner.adjustToxLoss(1)

	if(germ_level >= INFECTION_LEVEL_TWO && antibiotics < 5)
		//spread the infection to organs
		var/obj/item/organ/internal/target_organ = null	//make organs become infected one at a time instead of all at once
		for (var/obj/item/organ/internal/IO in bodypart_organs)
			if (IO.germ_level > 0 && IO.germ_level < min(germ_level, INFECTION_LEVEL_TWO))	//once the organ reaches whatever we can give it, or level two, switch to a different one
				if (!target_organ || IO.germ_level > target_organ.germ_level)	//choose the organ with the highest germ_level
					target_organ = IO

		if (!target_organ)
			//figure out which organs we can spread germs to and pick one at random
			var/list/candidate_organs = list()
			for (var/obj/item/organ/internal/IO in bodypart_organs)
				if (IO.germ_level < germ_level)
					candidate_organs += IO
			if (candidate_organs.len)
				target_organ = pick(candidate_organs)

		if (target_organ)
			target_organ.germ_level++

		//spread the infection to child and parent bodyparts
		if (children)
			for (var/obj/item/organ/external/BP in children)
				if (BP.germ_level < germ_level && !(BP.status & ORGAN_ROBOT))
					if (BP.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30))
						BP.germ_level++

		if (parent)
			if (parent.germ_level < germ_level && !(parent.status & ORGAN_ROBOT))
				if (parent.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30))
					parent.germ_level++

	if(germ_level >= INFECTION_LEVEL_THREE && antibiotics < 30)	//overdosing is necessary to stop severe infections
		if (!(status & ORGAN_DEAD))
			status |= ORGAN_DEAD
			to_chat(owner, "<span class='notice'>You can't feel your [name] anymore...</span>")
			owner.update_body()

		germ_level++
		owner.adjustToxLoss(1)

//Updating wounds. Handles wound natural I had some free spachealing, internal bleedings and infections
/obj/item/organ/external/proc/update_wounds()

	if(status & ORGAN_ROBOT) //Robotic limbs don't heal or get worse.
		for(var/datum/wound/W in wounds) //Repaired wounds disappear though
			if(W.damage <= 0)  //and they disappear right away
				wounds -= W    //TODO: robot wounds for robot limbs
		return

	for(var/datum/wound/W in wounds)
		// wounds can disappear after 10 minutes at the earliest
		if(W.damage <= 0 && W.created + (10 MINUTES) <= world.time)
			wounds -= W
			continue
			// let the GC handle the deletion of the wound

		// slow healing
		var/heal_amt = 0

		// if damage >= 50 AFTER treatment then it's probably too severe to heal within the timeframe of a round.
		if (W.can_autoheal() && W.wound_damage() < 50)
			heal_amt += 0.5

		//we only update wounds once in [wound_update_accuracy] ticks so have to emulate realtime
		heal_amt = heal_amt * wound_update_accuracy
		//configurable regen speed woo, no-regen hardcore or instaheal hugbox, choose your destiny
		heal_amt = heal_amt * config.organ_regeneration_multiplier
		// amount of healing is spread over all the wounds
		heal_amt = heal_amt / (wounds.len + 1)
		// making it look prettier on scanners
		heal_amt = round(heal_amt,0.1)
		W.heal_damage(heal_amt)

		// Salving also helps against infection
		if(W.germ_level > 0 && W.salved && prob(2))
			W.disinfected = 1
			W.germ_level = 0

	// sync the organ's damage with its wounds
	src.update_damages()
	if(update_damstate())
		owner.UpdateDamageIcon(src)

//Updates brute_damn and burn_damn from wound damages. Updates BLEEDING status.
/obj/item/organ/external/proc/update_damages()
	number_wounds = 0
	brute_dam = 0
	burn_dam = 0
	status &= ~ORGAN_BLEEDING
	var/clamped = 0

	//update damage counts
	for(var/datum/wound/W in wounds)
		if(W.damage_type == BURN)
			burn_dam += W.damage
		else
			brute_dam += W.damage

		if(!(status & ORGAN_ROBOT) && W.bleeding() && (owner && owner.should_have_organ(O_HEART)))
			W.bleed_timer = max(0, W.bleed_timer - 1)
			status |= ORGAN_BLEEDING

		clamped |= W.clamped
		number_wounds += W.amount

	// Continued damage to vital organs can kill you, and robot organs don't count towards total damage so no need to cap them.
	if(!(vital || (status & ORGAN_ROBOT)))
		brute_dam = min(brute_dam, max_damage)
		burn_dam = min(burn_dam, max_damage)

	//things tend to bleed if they are CUT OPEN
	if(owner && owner.should_have_organ(O_HEART) && (open && !clamped))
		status |= ORGAN_BLEEDING

	//Bone fractures
	if(brute_dam > min_broken_damage * config.organ_health_multiplier && !(status & ORGAN_ROBOT))
		fracture()

// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)
/obj/item/organ/external/proc/update_damstate()
	var/n_is = damage_state_text()
	if(n_is != damage_state)
		damage_state = n_is
		return TRUE
	return FALSE

// new damage icon system
// returns just the brute/burn damage code
/obj/item/organ/external/proc/damage_state_text()
	if(status & ORGAN_DESTROYED)
		return "--"

	var/tburn = 0
	var/tbrute = 0

	if(burn_dam ==0)
		tburn =0
	else if (burn_dam < (max_damage * 0.25 / 2))
		tburn = 1
	else if (burn_dam < (max_damage * 0.75 / 2))
		tburn = 2
	else
		tburn = 3

	if (brute_dam == 0)
		tbrute = 0
	else if (brute_dam < (max_damage * 0.25 / 2))
		tbrute = 1
	else if (brute_dam < (max_damage * 0.75 / 2))
		tbrute = 2
	else
		tbrute = 3
	return "[tbrute][tburn]"

/****************************************************
			   DISMEMBERMENT
****************************************************/

//Recursive setting of all child bodyparts to amputated
/obj/item/organ/external/proc/setAmputatedTree()
	for(var/obj/item/organ/external/BP in children)
		BP.amputated = amputated
		BP.setAmputatedTree()

//Handles dismemberment
/obj/item/organ/external/proc/droplimb(no_explode = FALSE, clean = FALSE, disintegrate = DROPLIMB_EDGE)
	if(cannot_amputate)
		return

	if(destspawn)
		return

	status |= ORGAN_DESTROYED

	switch(disintegrate)
		if(DROPLIMB_EDGE)
			if(!clean)
				var/gore_sound = "[(status & ORGAN_ROBOT) ? "tortured metal" : "ripping tendons and flesh"]"
				owner.visible_message(
					"<span class='danger'>\The [owner]'s [name] flies off in an arc!</span>",
					"<span class='moderate'><b>Your [name] goes flying off!</b></span>",
					"<span class='danger'>You hear a terrible sound of [gore_sound].</span>")
		if(DROPLIMB_BURN)
			var/gore = "[(status & ORGAN_ROBOT) ? "": " of burning flesh"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [name] flashes away into ashes!</span>",
				"<span class='moderate'><b>Your [name] flashes away into ashes!</b></span>",
				"<span class='danger'>You hear a crackling sound[gore].</span>")
		if(DROPLIMB_BLUNT)
			var/gore = "[(status & ORGAN_ROBOT) ? "": " in shower of gore"]"
			var/gore_sound = "[(status & ORGAN_ROBOT) ? "rending sound of tortured metal" : "sickening splatter of gore"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [name] explodes[gore]!</span>",
				"<span class='moderate'><b>Your [name] explodes[gore]!</b></span>",
				"<span class='danger'>You hear the [gore_sound].</span>")

	status &= ~(ORGAN_BROKEN | ORGAN_BLEEDING | ORGAN_SPLINTED | ORGAN_ARTERY_CUT)

	for(var/implant in implants)
		qdel(implant)
	implants.Cut()
	wounds.Cut()

	// If any bodyparts are attached to this, destroy them
	for(var/obj/item/organ/external/BP in owner.bodyparts)
		if(BP.parent == src)
			BP.droplimb(null, clean, disintegrate)

	if(parent && !(parent.status & ORGAN_DESTROYED) && disintegrate != DROPLIMB_BURN)
		if(clean)
			if(prob(10))
				parent.sever_artery()
		else
			parent.sever_artery()

	destspawn = TRUE
	switch(disintegrate)
		if(DROPLIMB_EDGE)
			var/obj/bodypart // Dropped limb object
			add_blood(owner)

			switch(body_zone)
				if(BP_HEAD)
					if(owner.species.flags[IS_SYNTHETIC])
						bodypart = new /obj/item/weapon/organ/head/posi(owner.loc, owner)
					else
						bodypart = new /obj/item/weapon/organ/head(owner.loc, owner)
				if(BP_R_ARM)
					if(status & ORGAN_ROBOT)
						bodypart = new /obj/item/robot_parts/r_arm(owner.loc)
					else
						bodypart = new /obj/item/weapon/organ/r_arm(owner.loc, owner)
				if(BP_L_ARM)
					if(status & ORGAN_ROBOT)
						bodypart = new /obj/item/robot_parts/l_arm(owner.loc)
					else
						bodypart = new /obj/item/weapon/organ/l_arm(owner.loc, owner)
				if(BP_R_LEG)
					if(status & ORGAN_ROBOT)
						bodypart = new /obj/item/robot_parts/r_leg(owner.loc)
					else
						bodypart = new /obj/item/weapon/organ/r_leg(owner.loc, owner)
				if(BP_L_LEG)
					if(status & ORGAN_ROBOT)
						bodypart = new /obj/item/robot_parts/l_leg(owner.loc)
					else
						bodypart = new /obj/item/weapon/organ/l_leg(owner.loc, owner)

			if(bodypart)
				//Robotic limbs explode if sabotaged.
				if(status & ORGAN_ROBOT && !no_explode && sabotaged)
					explosion(get_turf(owner), -1, -1, 2, 3)
					var/datum/effect/effect/system/spark_spread/spark_system = new
					spark_system.set_up(5, 0, owner)
					spark_system.attach(owner)
					spark_system.start()
					spawn(10)
						qdel(spark_system)

				var/matrix/M = matrix()
				M.Turn(rand(180))
				bodypart.transform = M

				if(!clean)
					// Throw limb around.
					if(isturf(bodypart.loc))
						bodypart.throw_at(get_edge_target_turf(bodypart.loc, pick(alldirs)), rand(1, 3), throw_speed)
					dir = 2
		if(DROPLIMB_BURN)
			new /obj/effect/decal/cleanable/ash(get_turf(owner))
			for(var/obj/item/I in src)
				if(I.w_class > ITEM_SIZE_SMALL && !istype(I, /obj/item/organ))
					I.loc = get_turf(src)
		if(DROPLIMB_BLUNT)
			var/obj/effect/decal/cleanable/blood/gibs/gore
			if(status & ORGAN_ROBOT)
				gore = new /obj/effect/decal/cleanable/blood/gibs/robot(get_turf(owner))
			else
				gore = new /obj/effect/decal/cleanable/blood/gibs(get_turf(owner))
				gore.fleshcolor = owner.species.flesh_color
				gore.basedatum =  new/datum/dirt_cover(owner.species.blood_color)
				gore.update_icon()

			gore.throw_at(get_edge_target_turf(owner, pick(alldirs)), rand(1, 3), throw_speed)

			for(var/obj/item/I in src)
				I.loc = get_turf(src)
				I.throw_at(get_edge_target_turf(owner, pick(alldirs)), rand(1, 3), throw_speed)
	switch(body_zone)
		if(BP_HEAD)
			if(disintegrate == DROPLIMB_EDGE)
				owner.remove_from_mob(owner.head)
				owner.remove_from_mob(owner.glasses)
				owner.remove_from_mob(owner.l_ear)
				owner.remove_from_mob(owner.r_ear)
				owner.remove_from_mob(owner.wear_mask)
			else
				qdel(owner.head)
				qdel(owner.glasses)
				qdel(owner.l_ear)
				qdel(owner.r_ear)
				qdel(owner.wear_mask)
		if(BP_R_ARM)
			if(disintegrate == DROPLIMB_EDGE)
				owner.remove_from_mob(owner.gloves)
				owner.remove_from_mob(owner.r_hand)
			else
				qdel(owner.gloves)
				qdel(owner.r_hand)
		if(BP_L_ARM)
			if(disintegrate == DROPLIMB_EDGE)
				owner.remove_from_mob(owner.gloves)
				owner.remove_from_mob(owner.l_hand)
			else
				qdel(owner.gloves)
				qdel(owner.l_hand)
		if(BP_R_LEG , BP_L_LEG)
			if(disintegrate == DROPLIMB_EDGE)
				owner.remove_from_mob(owner.shoes)
			else
				qdel(owner.shoes)

	owner.update_body()

	// OK so maybe your limb just flew off, but if it was attached to a pair of cuffs then hooray! Freedom!
	release_restraints()

	if(vital)
		owner.death()

	update_damages()
	owner.updatehealth()

	if(update_damstate())
		owner.UpdateDamageIcon(src)

/obj/item/organ/external/proc/sever_artery()
	if(!(status & (ORGAN_ARTERY_CUT | ORGAN_ROBOT)) && owner.organs_by_name[O_HEART])
		status |= ORGAN_ARTERY_CUT
		return TRUE
	return FALSE

/****************************************************
			   HELPERS
****************************************************/

/obj/item/organ/external/proc/release_restraints()
	if (owner.handcuffed && body_part in list(ARM_LEFT, ARM_RIGHT))
		owner.visible_message(\
			"\The [owner.handcuffed.name] falls off of [owner.name].",\
			"\The [owner.handcuffed.name] falls off you.")

		owner.drop_from_inventory(owner.handcuffed)

	if (owner.legcuffed && body_part in list(LEG_LEFT, LEG_RIGHT))
		owner.visible_message(\
			"\The [owner.legcuffed.name] falls off of [owner.name].",\
			"\The [owner.legcuffed.name] falls off you.")

		owner.drop_from_inventory(owner.legcuffed)

// checks if all wounds on the organ are bandaged
/obj/item/organ/external/proc/is_bandaged()
	for(var/datum/wound/W in wounds)
		if(!W.bandaged)
			return 0
	return 1

// checks if all wounds on the organ are salved
/obj/item/organ/external/proc/is_salved()
	for(var/datum/wound/W in wounds)
		if(!W.salved)
			return 0
	return 1

// checks if all wounds on the organ are disinfected
/obj/item/organ/external/proc/is_disinfected()
	for(var/datum/wound/W in wounds)
		if(!W.disinfected)
			return 0
	return 1

/obj/item/organ/external/proc/bandage()
	var/rval = 0
	src.status &= ~ORGAN_BLEEDING
	for(var/datum/wound/W in wounds)
		rval |= !W.bandaged
		W.bandaged = 1
	return rval

/obj/item/organ/external/proc/disinfect()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		rval |= !W.disinfected
		W.disinfected = 1
		W.germ_level = 0
	return rval

/obj/item/organ/external/proc/clamp()
	var/rval = 0
	src.status &= ~ORGAN_BLEEDING
	for(var/datum/wound/W in wounds)
		rval |= !W.clamped
		W.clamped = 1
	return rval

/obj/item/organ/external/proc/salve()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		rval |= !W.salved
		W.salved = 1
	return rval

/obj/item/organ/external/proc/fracture()

	if(owner.dna && owner.dna.mutantrace == "adamantine")
		return

	if(status & ORGAN_BROKEN)
		return

	owner.visible_message(\
		"\red You hear a loud cracking sound coming from \the [owner].",\
		"\red <b>Something feels like it shattered in your [name]!</b>",\
		"You hear a sickening crack.")

	if(owner.species && !owner.species.flags[NO_PAIN])
		owner.emote("scream",,, 1)

	playsound(owner, "fracture", 100, 1, -2)
	status |= ORGAN_BROKEN
	broken_description = pick("broken","fracture","hairline fracture")
	perma_injury = brute_dam

	// Fractures have a chance of getting you out of restraints
	if (prob(25))
		release_restraints()

	// This is mostly for the ninja suit to stop ninja being so crippled by breaks.
	// TODO: consider moving this to a suit proc or process() or something during
	// hardsuit rewrite.
	if(!(status & ORGAN_SPLINTED) && istype(owner,/mob/living/carbon/human))

		var/mob/living/carbon/human/H = owner

		if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))

			var/obj/item/clothing/suit/space/suit = H.wear_suit

			if(isnull(suit.supporting_limbs))
				return

			to_chat(owner, "You feel \the [suit] constrict about your [name], supporting it.")
			status |= ORGAN_SPLINTED
			suit.supporting_limbs |= src

/obj/item/organ/external/proc/robotize()
	status &= ~ORGAN_BROKEN
	status &= ~ORGAN_BLEEDING
	status &= ~ORGAN_SPLINTED
	status &= ~ORGAN_CUT_AWAY
	status &= ~ORGAN_ATTACHABLE
	status &= ~ORGAN_DESTROYED
	status &= ~ORGAN_ARTERY_CUT
	status |= ORGAN_ROBOT
	destspawn = 0
	amputated = 0
	for (var/obj/item/organ/external/BP in children)
		BP.robotize()

/obj/item/organ/external/proc/mutate()
	src.status |= ORGAN_MUTATED
	owner.update_body()

/obj/item/organ/external/proc/unmutate()
	src.status &= ~ORGAN_MUTATED
	owner.update_body()

/obj/item/organ/external/proc/get_damage()	//returns total damage
	return max(brute_dam + burn_dam - perma_injury, perma_injury)	//could use health?

/obj/item/organ/external/proc/has_infected_wound()
	for(var/datum/wound/W in wounds)
		if(W.germ_level > INFECTION_LEVEL_ONE)
			return 1
	return 0

/obj/item/organ/external/get_icon(icon/race_icon, icon/deform_icon, gender = "", fat = "")
	if(!owner.species.has_gendered_icons)
		gender = ""

	if (status & ORGAN_ROBOT && !(owner.species && owner.species.flags[IS_SYNTHETIC]))
		return new /icon('icons/mob/human_races/robotic.dmi', "[body_zone][gender ? "_[gender]" : ""]")

	if (status & ORGAN_MUTATED)
		return new /icon(deform_icon, "[body_zone][gender ? "_[gender]" : ""][fat ? "_[fat]" : ""]")

	return new /icon(race_icon, "[body_zone][gender ? "_[gender]" : ""][fat ? "_[fat]" : ""]")

/obj/item/organ/external/head/get_icon(icon/race_icon, icon/deform_icon)
	if (!owner)
		return ..()

	var/g = ""
	if(owner.species.has_gendered_icons)
		g = owner.gender == FEMALE ? "_f" : "_m"

	if(status & ORGAN_MUTATED)
		. = new /icon(deform_icon, "[body_zone][g]")
	else
		. = new /icon(race_icon, "[body_zone][g]")

/obj/item/organ/external/proc/is_usable()
	return !(status & (ORGAN_DESTROYED|ORGAN_MUTATED|ORGAN_DEAD))

/obj/item/organ/external/proc/is_broken()
	return ((status & ORGAN_BROKEN) && !(status & ORGAN_SPLINTED))

/obj/item/organ/external/proc/is_malfunctioning()
	return ((status & ORGAN_ROBOT) && prob(brute_dam + burn_dam))

//for arms and hands
/obj/item/organ/external/proc/process_grasp(obj/item/c_hand, hand_name)
	if (!c_hand)
		return

	if(status & ORGAN_ZOMBIE)
		return

	if(is_broken())
		owner.drop_from_inventory(c_hand)
		var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
		owner.emote("me", 1, "[(owner.species && owner.species.flags[NO_PAIN]) ? "" : emote_scream ] drops what they were holding in their [hand_name]!")
	if(is_malfunctioning())
		owner.drop_from_inventory(c_hand)
		owner.emote("me", 1, "drops what they were holding, their [hand_name] malfunctioning!")
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, owner)
		spark_system.attach(owner)
		spark_system.start()
		spawn(10)
			qdel(spark_system)

/obj/item/organ/external/proc/embed(obj/item/weapon/W, silent = 0, supplied_message, datum/wound/supplied_wound)
	if(owner.species.flags[NO_EMBED])
		return

	if(!silent)
		if(supplied_message)
			owner.visible_message("<span class='danger'>[supplied_message]</span>")
		else
			owner.visible_message("<span class='danger'>\The [W] sticks in the wound!</span>")

	if(!istype(supplied_wound))
		supplied_wound = null // in case something returns numbers or anything thats not datum.
		for(var/datum/wound/wound in wounds)
			if((wound.damage_type == CUT || wound.damage_type == PIERCE) && wound.damage >= W.w_class * 5)
				supplied_wound = wound
				break
	if(!supplied_wound)
		supplied_wound = createwound(PIERCE, W.w_class * 5)

	if(!supplied_wound || (W in supplied_wound.embedded_objects)) // Just in case.
		return

	owner.throw_alert("embeddedobject")

	supplied_wound.embedded_objects += W
	implants += W
	owner.embedded_flag = 1
	owner.verbs += /mob/proc/yank_out_object
	W.add_blood(owner)
	if(ismob(W.loc))
		var/mob/living/H = W.loc
		H.drop_from_inventory(W)
	W.loc = owner

/****************************************************
			   ORGAN DEFINES
****************************************************/

/obj/item/organ/external/chest
	name = "chest"
	artery_name = "aorta"

	body_part = UPPER_TORSO
	body_zone = BP_CHEST
	limb_layer = LIMB_TORSO_LAYER
	regen_bodypart_penalty = 150

	cannot_amputate = TRUE

	max_damage = 75
	min_broken_damage = 35
	vital = TRUE
	w_class = ITEM_SIZE_HUGE // Used for dismembering thresholds, in addition to storage. Humans are w_class 6, so it makes sense that chest is w_class 5.


/obj/item/organ/external/groin
	name = "groin"
	artery_name = "iliac artery"

	body_part = LOWER_TORSO
	body_zone = BP_GROIN
	parent_bodypart = BP_CHEST
	limb_layer = LIMB_GROIN_LAYER
	regen_bodypart_penalty = 90

	cannot_amputate = TRUE

	max_damage = 50
	min_broken_damage = 35
	vital = TRUE
	w_class = ITEM_SIZE_LARGE


/obj/item/organ/external/head
	name = "head"
	artery_name = "cartoid artery"

	body_part = HEAD
	body_zone = BP_HEAD
	parent_bodypart = BP_CHEST
	limb_layer = LIMB_HEAD_LAYER
	regen_bodypart_penalty = 100

	max_damage = 75
	min_broken_damage = 35
	vital = TRUE
	w_class = ITEM_SIZE_NORMAL

	var/disfigured = FALSE

/obj/item/organ/external/head/diona
	vital = FALSE

/obj/item/organ/external/head/ipc
	vital = FALSE

/obj/item/organ/external/l_arm
	name = "left arm"
	artery_name = "basilic vein"

	body_part = ARM_LEFT
	body_zone = BP_L_ARM
	parent_bodypart = BP_CHEST
	limb_layer = LIMB_L_ARM_LAYER
	regen_bodypart_penalty = 75

	arterial_bleed_severity = 0.75
	max_damage = 50
	min_broken_damage = 30
	w_class = ITEM_SIZE_NORMAL

/obj/item/organ/external/l_arm/process()
	..()
	process_grasp(owner.l_hand, "left hand")


/obj/item/organ/external/r_arm
	name = "right arm"
	artery_name = "basilic vein"

	body_part = ARM_RIGHT
	body_zone = BP_R_ARM
	parent_bodypart = BP_CHEST
	limb_layer = LIMB_R_ARM_LAYER
	regen_bodypart_penalty = 75

	arterial_bleed_severity = 0.75
	max_damage = 50
	min_broken_damage = 30
	w_class = ITEM_SIZE_NORMAL

/obj/item/organ/external/r_arm/process()
	..()
	process_grasp(owner.r_hand, "right hand")

/obj/item/organ/external/l_leg
	name = "left leg"
	artery_name = "femoral artery"

	body_part = LEG_LEFT
	body_zone = BP_L_LEG
	parent_bodypart = BP_GROIN
	limb_layer = LIMB_L_LEG_LAYER
	icon_position = LEFT
	regen_bodypart_penalty = 75

	arterial_bleed_severity = 0.75
	max_damage = 50
	min_broken_damage = 30
	w_class = ITEM_SIZE_NORMAL


/obj/item/organ/external/r_leg
	name = "right leg"
	artery_name = "femoral artery"

	body_part = LEG_RIGHT
	body_zone = BP_R_LEG
	parent_bodypart = BP_GROIN
	limb_layer = LIMB_R_LEG_LAYER
	icon_position = RIGHT
	regen_bodypart_penalty = 75

	arterial_bleed_severity = 0.75
	max_damage = 50
	min_broken_damage = 30
	w_class = ITEM_SIZE_NORMAL

/obj/item/organ/external/head/take_damage(brute, burn, damage_flags, used_weapon)
	if(!disfigured)
		if(brute_dam > 40)
			if (prob(50))
				disfigure("brute")
		if(burn_dam > 40)
			disfigure("burn")

	return ..()

/obj/item/organ/external/head/proc/disfigure(type = "brute")
	if (disfigured)
		return
	if(type == "brute")
		owner.visible_message("\red You hear a sickening cracking sound coming from \the [owner]'s face.",	\
		"\red <b>Your face becomes unrecognizible mangled mess!</b>",	\
		"\red You hear a sickening crack.")
	else
		owner.visible_message("\red [owner]'s face melts away, turning into mangled mess!",	\
		"\red <b>Your face melts off!</b>",	\
		"\red You hear a sickening sizzle.")
	disfigured = 1

/****************************************************
			   EXTERNAL ORGAN ITEMS
****************************************************/

/obj/item/weapon/organ
	icon = 'icons/mob/human_races/r_human.dmi'
	var/specie = HUMAN

/obj/item/weapon/organ/atom_init(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return
	if(H.dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[H.dna.unique_enzymes] = H.dna.b_type
	if(H.species)
		specie = H.species.name

	//Forming icon for the limb

	//Setting base icon for this mob's race
	var/icon/base
	if(H.species && H.species.icobase)
		base = icon(H.species.icobase)
	else
		base = icon('icons/mob/human_races/r_human.dmi')

	if(base)
		//Changing limb's skin tone to match owner
		if(!H.species || H.species.flags[HAS_SKIN_TONE])
			if (H.s_tone >= 0)
				base.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
			else
				base.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)

	if(base)
		//Changing limb's skin color to match owner
		if(!H.species || H.species.flags[HAS_SKIN_COLOR])
			base.Blend(rgb(H.r_skin, H.g_skin, H.b_skin), ICON_ADD)

	icon = base
	dir = SOUTH
	src.transform = turn(src.transform, rand(70,130))


/****************************************************
			   EXTERNAL ORGAN ITEMS DEFINES
****************************************************/
/obj/item/weapon/organ/l_arm
	name = "left arm"
	icon_state = BP_L_ARM

/obj/item/weapon/organ/l_leg
	name = "left leg"
	icon_state = BP_L_LEG

/obj/item/weapon/organ/r_arm
	name = "right arm"
	icon_state = BP_R_ARM

/obj/item/weapon/organ/r_leg
	name = "right leg"
	icon_state = BP_R_LEG

/obj/item/weapon/organ/head
	name = "head"
	icon_state = BP_HEAD
	var/mob/living/carbon/brain/brainmob
	var/brain_op_stage = 0

/obj/item/weapon/organ/head/posi
	name = "robotic head"

/obj/item/weapon/organ/head/atom_init(mapload, mob/living/carbon/human/H)
	if(istype(H))
		src.icon_state = H.gender == MALE? "head_m" : "head_f"
	. = ..()
	//Add (facial) hair.
	if(H.f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.f_style]
		if(facial_hair_style)
			var/image/facial = image("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial.color = rgb(H.r_facial, H.g_facial, H.b_facial)

			overlays.Add(facial) // icon.Blend(facial, ICON_OVERLAY)

	if(H.h_style && !(H.head && (H.head.flags & BLOCKHEADHAIR)))
		var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
		if(hair_style)
			var/image/hair = image("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair.color = rgb(H.r_hair, H.g_hair, H.b_hair)

			overlays.Add(hair) //icon.Blend(hair, ICON_OVERLAY)

	var/obj/item/organ/internal/IO = H.organs_by_name[O_BRAIN]
	if(IO && IO.parent_bodypart == BP_HEAD)
		spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud

		//if(ishuman(H))
		//	if(H.gender == FEMALE)
		//		H.icon_state = "head_f"
		transfer_identity(H)

		name = "[H.real_name]'s head"

		H.stat = DEAD
		H.death()
		brainmob.stat = DEAD
		brainmob.death()
		if(brainmob && brainmob.mind && brainmob.mind.changeling) //cuz fuck runtimes
			var/datum/changeling/Host = brainmob.mind.changeling
			if(Host.chem_charges >= 35 && Host.geneticdamage < 10)
				for(var/obj/effect/proc_holder/changeling/headcrab/crab in Host.purchasedpowers)
					if(istype(crab))
						crab.sting_action(brainmob)
						H.gib()
	else
		H.h_style = "Bald"
		H.f_style = "Shaved"
		H.client.perspective = EYE_PERSPECTIVE
		H.client.eye = src
	H.update_body()
	H.update_hair()

/obj/item/weapon/organ/head/proc/transfer_identity(mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->head
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob.container = src

/obj/item/weapon/organ/head/attackby(obj/item/weapon/W, mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(istype(W,/obj/item/weapon/scalpel))
		switch(brain_op_stage)
			if(0)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] is beginning to have \his head cut open with [W] by [user].", 1)
				to_chat(brainmob, "\red [user] begins to cut open your head with [W]!")
				to_chat(user, "\red You cut [brainmob]'s head open with [W]!")

				brain_op_stage = 1

			if(2)
				if(!(specie in list(DIONA, IPC)))
					for(var/mob/O in (oviewers(brainmob) - user))
						O.show_message("\red [brainmob] is having \his connections to the brain delicately severed with [W] by [user].", 1)
					to_chat(brainmob, "\red [user] begins to cut open your head with [W]!")
					to_chat(user, "\red You cut [brainmob]'s head open with [W]!")

					brain_op_stage = 3.0
			else
				..()
	else if(istype(W,/obj/item/weapon/circular_saw))
		switch(brain_op_stage)
			if(1)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] has \his head sawed open with [W] by [user].", 1)
				to_chat(brainmob, "\red [user] begins to saw open your head with [W]!")
				to_chat(user, "\red You saw [brainmob]'s head open with [W]!")

				brain_op_stage = 2
			if(3)
				if(!(specie in list(DIONA, IPC)))
					for(var/mob/O in (oviewers(brainmob) - user))
						O.show_message("\red [brainmob] has \his spine's connection to the brain severed with [W] by [user].", 1)
					to_chat(brainmob, "\red [user] severs your brain's connection to the spine with [W]!")
					to_chat(user, "\red You sever [brainmob]'s brain's connection to the spine with [W]!")

					user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [brainmob.name] ([brainmob.ckey]) with [W.name] (INTENT: [uppertext(user.a_intent)])</font>"
					brainmob.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [W.name] (INTENT: [uppertext(user.a_intent)])</font>"
					msg_admin_attack("[user.name] ([user.ckey]) debrained [brainmob.name] ([brainmob.ckey]) (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					if(istype(src,/obj/item/weapon/organ/head/posi))
						var/obj/item/device/mmi/posibrain/B = new(loc)
						B.transfer_identity(brainmob)
					else
						var/obj/item/brain/B = new(loc)
						B.transfer_identity(brainmob)

					brain_op_stage = 4.0
			else
				..()
	else
		..()

/obj/item/organ/external/proc/get_wounds_desc()
	if(status == ORGAN_ROBOT)
		var/list/descriptors = list()
		if(brute_dam)
			switch(brute_dam)
				if(0 to 20)
					descriptors += "some dents"
				if(21 to INFINITY)
					descriptors += pick("a lot of dents","severe denting")
		if(burn_dam)
			switch(burn_dam)
				if(0 to 20)
					descriptors += "some burns"
				if(21 to INFINITY)
					descriptors += pick("a lot of burns","severe melting")
		if(open)
			descriptors += "an open panel"

		return english_list(descriptors)

	var/list/flavor_text = list()
	if(status & ORGAN_DESTROYED)
		flavor_text += "a tear and hangs by a scrap of flesh" // TODO ZAKONCHIT'

	var/list/wound_descriptors = list()
	if(open > 1)
		wound_descriptors["an open incision"] = 1
	else if (open)
		wound_descriptors["an incision"] = 1
	for(var/datum/wound/W in wounds)
		var/this_wound_desc = W.desc

		if(W.damage_type == BURN && W.salved)
			this_wound_desc = "salved [this_wound_desc]"

		if(W.bleeding())
			if(W.wound_damage() > W.bleed_threshold)
				this_wound_desc = "<b>bleeding</b> [this_wound_desc]"
			else
				this_wound_desc = "bleeding [this_wound_desc]"
		else if(W.bandaged)
			this_wound_desc = "bandaged [this_wound_desc]"

		if(W.germ_level > 600)
			this_wound_desc = "badly infected [this_wound_desc]"
		else if(W.germ_level > 330)
			this_wound_desc = "lightly infected [this_wound_desc]"

		if(wound_descriptors[this_wound_desc])
			wound_descriptors[this_wound_desc] += W.amount
		else
			wound_descriptors[this_wound_desc] = W.amount

	for(var/wound in wound_descriptors)
		switch(wound_descriptors[wound])
			if(1)
				flavor_text += "a [wound]"
			if(2)
				flavor_text += "a pair of [wound]s"
			if(3 to 5)
				flavor_text += "several [wound]s"
			if(6 to INFINITY)
				flavor_text += "a ton of [wound]\s"

	return english_list(flavor_text)
