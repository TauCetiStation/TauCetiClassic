/****************************************************
				BODYPARTS
****************************************************/
/mob/living/carbon/var/list/bodyparts = list()
/mob/living/carbon/var/list/bodyparts_by_name = list() // map bodypart names to bodyparts

/obj/item/bodypart
	name = "limb"
	desc = "why is it detached..."
	icon = null // ''
	icon_state = null // ""
	layer = BELOW_MOB_LAYER

	var/body_part = null // Part flag (used in clothes for protection or other purpose).
	var/body_zone = null // Unique identifier (used in targetting, icon_state, get_bodypart, etc).
	var/parent_bodypart = null // Bodypart holding this object.

	var/obj/item/bodypart/parent
	var/list/obj/item/bodypart/children = list()
	var/list/obj/item/organ/organs = list() // Internal organs of this body part

	var/limb_layer = 0
	var/limb_layer_priority = 0 //chest and groin must be drawn under arms, head and legs.

	var/mob/living/carbon/owner = null
	var/datum/species/species = null
	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() // traces of chemicals in the bodypart,
									  // links chemical IDs to number of ticks for which they'll stay in the blood

	// Strings
	var/broken_description             // fracture string if any.
	var/damage_state = "00"            // Modifier used for generating the on-mob damage overlay for this limb.
	var/damage_msg = "\red You feel an intense pain"

	// Damage vars.
	var/brute_mod = 1                  // Multiplier for incoming brute damage.
	var/burn_mod = 1                   // As above for burn.
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/max_size = 0
	var/last_dam = -1

	var/list/wounds = list()
	var/number_wounds = 0 // cache the number of wounds, which is NOT wounds.len!

	// Appearance vars.
	var/nonsolid // Used for slime limbs.

	// Joint/state stuff.
	var/cannot_amputate = FALSE // Impossible to amputate.
	var/artery_name = "artery" // Flavour text for cartoid artery, aorta, etc.
	var/arterial_bleed_severity = 1 // Multiplier for bleeding in a limb.
	var/amputation_point // Descriptive string used in amputation.

	var/min_broken_damage = 30

	var/vital //Lose a vital limb, die immediately.
	var/status = 0
	var/open = 0
	var/stage = 0
	var/cavity = 0
	var/sabotaged = 0 //If a prosthetic limb is emagged, it will detonate when it fails.

	var/obj/item/hidden = null
	var/list/implants = list()

	// how often wounds should be updated, a higher number means less often
	var/wound_update_accuracy = 1

	germ_level = 0

/obj/item/bodypart/New(loc, mob/living/carbon/C)
	if(!max_damage)
		max_damage = min_broken_damage * 2

	if(istype(C))
		owner = C
		//w_class = max(w_class + mob_size_difference(owner.mob_size, MOB_MEDIUM), 1) //smaller mobs have smaller bodyparts.

		owner.bodyparts += src
		owner.bodyparts_by_name[body_zone] = src

		if(parent_bodypart)
			parent = owner.bodyparts_by_name[parent_bodypart]
			if(!parent)
				CRASH("[src] spawned in [owner] without a parent bodypart: [parent].")

			parent.children += src

		species = owner.species

		if(species.flags[IS_SYNTHETIC])
			status |= ORGAN_ROBOT

	create_reagents(5 * (w_class-1)**2)
	reagents.add_reagent("nutriment", reagents.maximum_volume) // Bay12: protein

	return ..()

/obj/item/bodypart/Destroy()
	for(var/datum/wound/W in wounds)
		W.embedded_objects.Cut()
	wounds.Cut()

	if(parent && parent.children)
		parent.children -= src

	if(children)
		for(var/obj/item/bodypart/BP in children)
			qdel(BP)

	if(organs)
		for(var/obj/item/organ/O in organs)
			qdel(O)

	species = null // species are global, don't do anything to them.

	if(owner)
		owner.bodyparts -= src
		owner.bodyparts_by_name[body_zone] = null
		owner.bodyparts_by_name -= body_zone
		while(null in owner.bodyparts)
			owner.bodyparts -= null
		owner = null

	if(autopsy_data)
		autopsy_data.Cut()

	if(trace_chemicals)
		trace_chemicals.Cut()

	return ..()

/obj/item/bodypart/proc/removed(mob/living/user, ignore_children = 0) // TODO implement this proc properly
	if(!istype(owner))
		return

	var/is_robotic = (status & ORGAN_ROBOT)

	var/obj/item/bodypart/BP = owner.get_bodypart(parent_bodypart)
	if(BP)
		status |= ORGAN_CUT_AWAY
		forceMove(owner.loc)

	START_PROCESSING(SSobj, src)
	//rejecting = null
	if(is_robotic)
		var/datum/reagent/blood/organ_blood = locate(/datum/reagent/blood) in reagents.reagent_list //TODO fix this and all other occurences of locate(/datum/reagent/blood) horror
		if(!organ_blood || !organ_blood.data["blood_DNA"])
			owner.vessel.trans_to(src, 5, 1, 1)

	if(vital)
		if(user)
			user.attack_log += "\[[time_stamp()]\]<font color='red'>Removed a vital organ ([src]) from [owner.name] ([owner.ckey])</font>"
			owner.attack_log += "\[[time_stamp()]\]<font color='orange'>Had a vital organ ([src]) removed by [user.name] ([user.ckey])</font>"
			msg_admin_attack("[user.name] ([user.ckey]) removed a vital organ ([src]) from [owner.name] ([owner.ckey]) ([ADMIN_JMP(user)])")
		owner.death()

	owner.bad_bodyparts -= src

	//remove_splint()
	for(var/atom/movable/implant in implants)
		//large items and non-item objs fall to the floor, everything else stays
		var/obj/item/I = implant
		if(istype(I) && I.w_class < ITEM_SIZE_NORMAL)
			//implant.forceMove(src)

			// let actual implants still inside know they're no longer implanted
			//if(istype(I, /obj/item/weapon/implant))
			//	var/obj/item/weapon/implant/imp_device = I
			//	imp.imp_in = null
			//	imp.implanted = 0
			//	if(istype(imp,/obj/item/weapon/implant/storage))
			//		var/obj/item/weapon/implant/storage/Simp = imp
			//		Simp.removed()
		else
			//implants.Remove(implant)
			implant.forceMove(get_turf(src))

	// Attached organs also fly off.
	if(!ignore_children)
		for(var/obj/item/bodypart/limb in children)
			limb.removed()
			/*if(limb)
				limb.forceMove(src)

				// if we didn't lose the organ we still want it as a child
				children += limb
				limb.parent = src*/

	// Grab all the internal giblets too.
	for(var/obj/item/organ/IO in organs)
		IO.removed(null, 0)  // Organ stays inside and connected

	// Remove parent references
	if(parent)
		parent.children -= src
		parent = null

	//release_restraints(owner)
	owner.bodyparts -= src
	owner.bodyparts_by_name[body_zone] = null // Remove from owner's vars.

	//Robotic limbs explode if sabotaged.
	if(is_robotic && sabotaged)
		owner.visible_message(
			"<span class='danger'>\The [owner]'s [src.name] explodes violently!</span>",\
			"<span class='danger'>Your [src.name] explodes!</span>",\
			"<span class='danger'>You hear an explosion!</span>")
		explosion(get_turf(owner),-1,-1,2,3)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, owner)
		spark_system.attach(owner)
		spark_system.start()
		spawn(10)
			qdel(spark_system)
		qdel(src)

	owner.update_bodypart(body_zone)
	owner = null

// Used in surgery, replaces amputated limb with this one.
/obj/item/bodypart/proc/replace_stump(mob/living/carbon/target)
	if(istype(target))
		var/obj/item/bodypart/stump = target.get_bodypart(src.body_zone)
		if(!stump || !stump.is_stump())
			return 0

		qdel(stump)

		src.transform = matrix()
		src.dir = target.dir

		loc = null
		owner = target

		owner.bodyparts += src
		owner.bodyparts_by_name[body_zone] = src

		if(parent_bodypart)
			parent = owner.bodyparts_by_name[parent_bodypart]
			if(!parent)
				CRASH("[src] attached to [owner] without a parent bodypart: [parent].")

			parent.children += src
			//Remove all stump wounds since limb is not missing anymore
			for(var/datum/wound/lost_limb/W in parent.wounds)
				parent.wounds -= W
				qdel(W)
				break
			parent.update_damages()

		owner.update_body() // TODO check if this procs are necessary
		owner.updatehealth()
		owner.update_bodypart(src.body_zone)
		return 1

	return 0

/obj/item/bodypart/proc/update_limb()
	if(!owner)
		return

	var/has_gender = owner.species.flags[HAS_GENDERED_ICONS]
	var/has_color = TRUE
	var/husk = (owner.disabilities & HUSK)

	if(owner.species.flags[IS_SYNTHETIC]) // TODO: bodyparts for this and ROBOT.
		icon = owner.species.icobase
		has_gender = FALSE
		has_color = FALSE
	else if(status & ORGAN_ROBOT)
		icon = 'icons/mob/human_races/robotic.dmi'
		has_gender = FALSE
		has_color = FALSE
	else if(husk) // TODO implement this for exact bodyparts.
		overlays.Cut()
		icon = 'icons/mob/human_races/bad_limb.dmi'
		icon_state = body_zone + "_husk"
		has_gender = FALSE
		has_color = FALSE
		return
	else if(status & ORGAN_MUTATED)
		icon = owner.species.deform
	else
		icon = owner.species.icobase

	if(has_gender)
		var/g = (owner.gender == FEMALE ? "_f" : "_m")
		switch(body_zone)
			if(BP_CHEST)
				icon_state = body_zone + g
			if(BP_GROIN, BP_HEAD)
				icon_state = body_zone + g
			else
				icon_state = body_zone
		if(owner.species.name == S_HUMAN && (owner.disabilities & FAT))
			icon_state += "_fat"
	else
		icon_state = body_zone

	if(has_color)
		if(status & ORGAN_DEAD)
			color = list(0.03,0,0, 0,0.2,0, 0,0,0, 0.3,0.3,0.3)
		else if(HULK in owner.mutations)
			color = list(0.18,0,0, 0,0.87,0, 0,0,0.15, 0,0,0)
		else
			if(owner.species.flags[HAS_SKIN_TONE])
				color = list(1,0,0, 0,1,0, 0,0,1, owner.s_tone/255,owner.s_tone/255,owner.s_tone/255)
			if(owner.species.flags[HAS_SKIN_COLOR])
				color = list(1,0,0, 0,1,0, 0,0,1, owner.r_skin/255,owner.g_skin/255,owner.b_skin/255)
	else
		color = null

	// Damage overlays
	if( (status & ORGAN_ROBOT) || damage_state == "00")
		return

	overlays.Cut()
	var/image/damage_overlay = image(icon = 'icons/mob/human_races/damage_overlays.dmi', icon_state = "[body_zone]_[damage_state]", layer = -DAMAGE_LAYER + limb_layer_priority)
	damage_overlay.color = owner.species.blood_color
	overlays += damage_overlay

/obj/item/bodypart/proc/get_icon()
	return image(icon = src, layer = -BODYPARTS_LAYER + limb_layer_priority)

/obj/item/bodypart/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < 5)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 6	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes

//Handles chem traces
/mob/living/carbon/proc/handle_trace_chems()
	//New are added for reagents to random bodyparts.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/obj/item/bodypart/BP = pick(bodyparts)
		BP.trace_chemicals[A.name] = 100

//Adds autopsy data for used_weapon.
/obj/item/bodypart/proc/add_autopsy_data(used_weapon, damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

/****************************************************
			   DAMAGE PROCS
****************************************************/

/obj/item/bodypart/emp_act(severity)
	if(!(status & ORGAN_ROBOT))	//meatbags do not care about EMP
		return
	var/burn_damage = 0
	switch (severity)
		if (1)
			burn_damage = 15
		if (2)
			burn_damage = 7
		if (3)
			burn_damage = 3
	if(burn_damage)
		take_damage(0, burn_damage, 1, 1, used_weapon = "EMP")

/obj/item/bodypart/proc/is_damageable(additional_damage = 0)
	//Continued damage to vital organs can kill you, and robot organs don't count towards total damage so no need to cap them.
	return (vital || (status & ORGAN_ROBOT) || brute_dam + burn_dam + additional_damage < max_damage)

/obj/item/bodypart/proc/take_damage(brute, burn, sharp, edge, used_weapon = null) // TODO proper port from Bay12 with LASER and damage flags.
	brute = round(brute * brute_mod, 0.1)
	burn = round(burn * burn_mod, 0.1)
	if((brute <= 0) && (burn <= 0))
		return 0

	//var/sharp = (damage_flags & DAM_SHARP)
	//var/edge  = (damage_flags & DAM_EDGE)
	//var/laser = (damage_flags & DAM_LASER)

	// High brute damage or sharp objects may damage internal organs
	var/damage_amt = brute
	var/cur_damage = brute_dam
	//if(laser)
	//	damage_amt += burn
	//	cur_damage += burn_dam
	if(organs && (cur_damage + damage_amt >= max_damage || (((sharp && damage_amt >= 5) || damage_amt >= 10) && prob(5))))
		// Damage an internal organ
		if(organs && organs.len)
			var/obj/item/organ/IO = pick(organs)
			IO.take_damage(damage_amt / 2)
			brute /= 2
			//if(laser)
			//	burn /= 2

	//if(status & ORGAN_BROKEN && brute)
	//	jostle_bone(brute)
	//	if(can_feel_pain() && prob(40))
	//		owner.emote("scream")	//getting hit on broken hand hurts
	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)
	var/can_cut = (prob(brute*2) || sharp) && !(status & ORGAN_ROBOT)
	var/spillover = 0
	var/pure_brute = brute
	if(!is_damageable(brute + burn))
		spillover =  brute_dam + burn_dam + brute - max_damage
		if(spillover > 0)
			brute -= spillover
		else
			spillover = brute_dam + burn_dam + brute + burn - max_damage
			if(spillover > 0)
				burn -= spillover
	// If the limbs can break, make sure we don't exceed the maximum damage a limb can take before breaking
	// Non-vital organs are limited to max_damage. You can't kill someone by bludeonging their arm all the way to 200 -- you can
	// push them faster into paincrit though, as the additional damage is converted into shock.

	var/datum/wound/created_wound
	if(is_damageable(brute + burn))
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
			//if(laser)
			//	createwound( LASER, burn )
			//else
			//	createwound( BURN, burn )
			createwound( BURN, burn )
	else
		//If there are still hurties to dispense
		if (spillover)
			owner.shock_stage += spillover * 0.005 // Bay12 default value

	// sync the organ's damage with its wounds
	src.update_damages()
	owner.updatehealth() //droplimb will call updatehealth() again if it does end up being called
	//If limb took enough damage, try to cut or tear it off
	if(owner && !is_stump())
		if(!cannot_amputate && (brute_dam + burn_dam + brute + burn + spillover) >= (max_damage * config.organ_health_multiplier))
			//organs can come off in three cases
			//1. If the damage source is edge_eligible and the brute damage dealt exceeds the edge threshold, then the organ is cut off.
			//2. If the damage amount dealt exceeds the disintegrate threshold, the organ is completely obliterated.
			//3. If the organ has already reached or would be put over it's max damage amount (currently redundant),
			//   and the brute damage dealt exceeds the tearoff threshold, the organ is torn off.
			//Check edge eligibility
			var/edge_eligible = 0
			if(edge)
				if(istype(used_weapon,/obj/item))
					var/obj/item/W = used_weapon
					if(W.w_class >= w_class)
						edge_eligible = 1
				else
					edge_eligible = 1
			brute = pure_brute
			if(edge_eligible && brute >= max_damage / DROPLIMB_THRESHOLD_EDGE && prob(brute))
				droplimb(0, DROPLIMB_EDGE)
			else if(burn >= max_damage / DROPLIMB_THRESHOLD_DESTROY && prob(burn/3))
				droplimb(0, DROPLIMB_BURN)
			else if(brute >= max_damage / DROPLIMB_THRESHOLD_DESTROY && prob(brute))
				droplimb(0, DROPLIMB_BLUNT)
			else if(brute >= max_damage / DROPLIMB_THRESHOLD_TEAROFF && prob(brute/3))
				droplimb(0, DROPLIMB_EDGE)

	if(owner && update_damstate())
		owner.update_bodypart(src.body_zone)

	return created_wound

/obj/item/bodypart/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	if(status & ORGAN_ROBOT && !robo_repair)
		return

	//Heal damage on the individual wounds
	for(var/datum/wound/W in wounds)
		if(brute == 0 && burn == 0)
			break

		// heal brute damage
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute = W.heal_damage(brute)
		else if(W.damage_type == BURN)
			burn = W.heal_damage(burn)

	if(internal)
		status &= ~ORGAN_BROKEN

	//Sync the bodypart's damage with its wounds
	src.update_damages()
	owner.updatehealth()

	var/result = update_damstate()
	if(result)
		owner.update_bodypart(src.body_zone)
	return result

/*
This function completely restores a damaged bodypart to perfect condition.
*/
/obj/item/bodypart/proc/rejuvenate()
	damage_state = "00"
	if(status & ORGAN_ROBOT)	//Robotic bodyparts stay robotic.  Fix because right click rejuvinate makes IPC's bodyparts organic.
		status = ORGAN_ROBOT
	else
		status = 0

	brute_dam = 0
	open = 0
	burn_dam = 0
	germ_level = 0
	for(var/datum/wound/wound in wounds)
		wound.embedded_objects.Cut()
	wounds.Cut()
	number_wounds = 0

	// handle internal organs
	for(var/obj/item/organ/IO in organs)
		IO.rejuvenate()

	// remove embedded objects and drop them on the floor
	for(var/obj/implanted_object in implants)
		if(!istype(implanted_object,/obj/item/weapon/implant))	// We don't want to remove REAL implants. Just shrapnel etc.
			implanted_object.loc = get_turf(src)
			implants -= implanted_object

	if(owner)
		owner.updatehealth()


/obj/item/bodypart/proc/createwound(type = CUT, damage)
	if(damage == 0)
		return

	//moved this before the open_wound check so that having many small wounds for example doesn't somehow protect you from taking internal damage (because of the return)
	//Brute damage can possibly trigger an internal wound, too.
	var/local_damage = brute_dam + burn_dam + damage
	if( (type in list(CUT, PIERCE, BRUISE)) && damage > 15 && local_damage > 30)

		var/internal_damage
		if(prob(damage) && sever_artery())
			internal_damage = TRUE
		if(internal_damage)
			owner.custom_pain("You feel something rip in your [name]!", 1)

	//Burn damage can cause fluid loss due to blistering and cook-off
	if( (type in list(BURN, LASER)) && (damage > 5 || damage + burn_dam >= 15) && !(status & ORGAN_ROBOT))
		var/fluid_loss_severity
		switch(type)
			if(BURN)
				fluid_loss_severity = FLUIDLOSS_WIDE_BURN
			if(LASER)
				fluid_loss_severity = FLUIDLOSS_CONC_BURN
		var/fluid_loss = (damage / (owner.maxHealth - config.health_threshold_dead)) * 560 * fluid_loss_severity
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
						owner.visible_message("<span class='danger'>The damage to [owner.name]'s [name] worsens.</span>",\
						"<span class='danger'>The damage to your [name] worsens.</span>",\
						"<span class='danger'>You hear the screech of abused metal.</span>")
					else
						owner.visible_message("\red The wound on [owner.name]'s [name] widens with a nasty ripping voice.",\
						"\red The wound on your [name] widens with a nasty ripping voice.",\
						"You hear a nasty ripping noise, as if flesh is being torn apart.")
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

//Determines if we even need to process this bodypart.

/obj/item/bodypart/proc/need_process()
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

/obj/item/bodypart/process()
	if(owner)
		//if(pain)
		//	pain = max(0, pain - owner.lying ? 3 : 1)


		// Process wounds, doing healing etc. Only do this every few ticks to save processing power
		if(owner.life_tick % wound_update_accuracy == 0)
			update_wounds()

		//Chem traces slowly vanish
		if(owner.life_tick % 10 == 0)
			for(var/chemID in trace_chemicals)
				trace_chemicals[chemID] = trace_chemicals[chemID] - 1
				if(trace_chemicals[chemID] <= 0)
					trace_chemicals.Remove(chemID)

		//Bone fracurtes
		if(brute_dam > min_broken_damage * config.organ_health_multiplier && !(status & ORGAN_ROBOT))
			src.fracture()

		//Infections
		update_germs()
	else
		//pain = 0
		//..()

		//dead already, no need for more processing
		if(status & ORGAN_DEAD)
			return
		// Don't process if we're in a freezer, an MMI or a stasis bag.or a freezer or something I dunno
		if(istype(loc,/obj/item/device/mmi))
			return
		if(istype(loc,/obj/structure/closet/body_bag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer) || istype(loc,/obj/structure/closet/secure_closet/freezer))
			return
		//Process infections
		if (status & ORGAN_ROBOT)
			germ_level = 0
			return

		if(reagents)
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
			if(B && prob(40))
				reagents.remove_reagent("blood",0.1)
				blood_splatter(src,B,1)
			germ_level += rand(2,6)
			if(germ_level >= INFECTION_LEVEL_TWO)
				germ_level += rand(2,6)
			if(germ_level >= INFECTION_LEVEL_THREE)
				die()

/obj/item/bodypart/proc/die()
	if(status & ORGAN_ROBOT)
		return
	status |= ORGAN_DEAD
	STOP_PROCESSING(SSobj, src)
	if(owner && vital)
		owner.death()

//Updating germ levels. Handles bodypart germ levels and necrosis.
/*
The INFECTION_LEVEL values defined in setup.dm control the time it takes to reach the different
infection levels. Since infection growth is exponential, you can adjust the time it takes to get
from one germ_level to another using the rough formula:

desired_germ_level = initial_germ_level*e^(desired_time_in_seconds/1000)

So if I wanted it to take an average of 15 minutes to get from level one (100) to level two
I would set INFECTION_LEVEL_TWO to 100*e^(15*60/1000) = 245. Note that this is the average time,
the actual time is dependent on RNG.

INFECTION_LEVEL_ONE		below this germ level nothing happens, and the infection doesn't grow
INFECTION_LEVEL_TWO		above this germ level the infection will start to spread to internal and adjacent organs
INFECTION_LEVEL_THREE	above this germ level the player will take additional toxin damage per second, and will die in minutes without
						antitox. also, above this germ level you will need to overdose on spaceacillin to reduce the germ_level.

Note that amputating the affected bodypart does in fact remove the infection from the player's body.
*/
/obj/item/bodypart/proc/update_germs()

	if((status & ORGAN_ROBOT) || (owner.species && owner.species.flags[IS_PLANT])) //Robotic limbs shouldn't be infected, nor should nonexistant limbs.
		germ_level = 0
		return

	if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Syncing germ levels with external wounds
		handle_germ_sync()

		//** Handle antibiotics and curing infections
		handle_antibiotics()

		//** Handle the effects of infections
		handle_germ_effects()

/obj/item/bodypart/proc/handle_germ_sync()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")
	for(var/datum/wound/W in wounds)
		//Open wounds can become infected
		if (owner.germ_level > W.germ_level && W.infection_check())
			W.germ_level++

	if (antibiotics < 5)
		for(var/datum/wound/W in wounds)
			//Infected wounds raise the bodypart's germ level
			if (W.germ_level > germ_level)
				germ_level++
				break	//limit increase to a maximum of one per second

/obj/item/bodypart/proc/handle_germ_effects()
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
		//spread the infection to internal organs
		var/obj/item/organ/target_bodypart = null	//make internal organs become infected one at a time instead of all at once
		for (var/obj/item/organ/IO in organs)
			if (IO.germ_level > 0 && IO.germ_level < min(germ_level, INFECTION_LEVEL_TWO))	//once the organ reaches whatever we can give it, or level two, switch to a different one
				if (!target_bodypart || IO.germ_level > target_bodypart.germ_level)	//choose the organ with the highest germ_level
					target_bodypart = IO

		if (!target_bodypart)
			//figure out which organs we can spread germs to and pick one at random
			var/list/candidate_organs = list()
			for (var/obj/item/organ/IO in organs)
				if (IO.germ_level < germ_level)
					candidate_organs += IO
			if (candidate_organs.len)
				target_bodypart = pick(candidate_organs)

		if (target_bodypart)
			target_bodypart.germ_level++

		//spread the infection to child and parent bodyparts
		if (children)
			for (var/obj/item/bodypart/child in children)
				if (child.germ_level < germ_level && !(child.status & ORGAN_ROBOT))
					if (child.germ_level < INFECTION_LEVEL_ONE*2 || prob(30))
						child.germ_level++

		if (parent)
			if (parent.germ_level < germ_level && !(parent.status & ORGAN_ROBOT))
				if (parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30))
					parent.germ_level++

	if(germ_level >= INFECTION_LEVEL_THREE && antibiotics < 30)	//overdosing is necessary to stop severe infections
		if (!(status & ORGAN_DEAD))
			status |= ORGAN_DEAD
			to_chat(owner, "<span class='notice'>You can't feel your [name] anymore...</span>")
			owner.update_body()

		germ_level++
		owner.adjustToxLoss(1)

//Updating wounds. Handles wound natural I had some free spachealing, internal bleedings and infections
/obj/item/bodypart/proc/update_wounds()

	if((status & ORGAN_ROBOT)) //Robotic limbs don't heal or get worse.
		return

	for(var/datum/wound/W in wounds)
		// wounds can disappear after 10 minutes at the earliest
		if(W.damage <= 0 && W.created + 10 * 10 * 60 <= world.time)
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

	// sync the bodypart's damage with its wounds
	src.update_damages()
	if(update_damstate())
		owner.update_bodypart(src.body_zone)

//Updates brute_damn and burn_damn from wound damages. Updates BLEEDING status.
/obj/item/bodypart/proc/update_damages()
	number_wounds = 0
	brute_dam = 0
	burn_dam = 0
	status &= ~ORGAN_BLEEDING
	var/clamped = 0
	for(var/datum/wound/W in wounds)
		if(W.damage_type == CUT || W.damage_type == BRUISE)
			brute_dam += W.damage
		else if(W.damage_type == BURN)
			burn_dam += W.damage

		if(!(status & ORGAN_ROBOT) && W.bleeding())
			W.bleed_timer--
			status |= ORGAN_BLEEDING

		clamped |= W.clamped

		number_wounds += W.amount

	if (open && !clamped)	//things tend to bleed if they are CUT OPEN
		status |= ORGAN_BLEEDING


//Returns 1 if damage_state changed
/obj/item/bodypart/proc/update_damstate()
	var/n_is = damage_state_text()
	if(n_is != damage_state)
		damage_state = n_is
		return TRUE
	return FALSE

// new damage icon system
// returns just the brute/burn damage code
/obj/item/bodypart/proc/damage_state_text()
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

//Handles dismemberment
/obj/item/bodypart/proc/droplimb(clean, disintegrate = DROPLIMB_EDGE, ignore_children, mob/living/user)
	if(cannot_amputate || !owner)
		return

	if(disintegrate == DROPLIMB_EDGE && nonsolid)
		disintegrate = DROPLIMB_BLUNT //splut

	switch(disintegrate)
		if(DROPLIMB_EDGE)
			if(!clean)
				var/gore_sound = "[(status & ORGAN_ROBOT) ? "tortured metal" : "ripping tendons and flesh"]"
				owner.visible_message(
					"<span class='danger'>\The [owner]'s [src.name] flies off in an arc!</span>",\
					"<span class='moderate'><b>Your [src.name] goes flying off!</b></span>",\
					"<span class='danger'>You hear a terrible sound of [gore_sound].</span>")
		if(DROPLIMB_BURN)
			var/gore = "[(status & ORGAN_ROBOT) ? "": " of burning flesh"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [src.name] flashes away into ashes!</span>",\
				"<span class='moderate'><b>Your [src.name] flashes away into ashes!</b></span>",\
				"<span class='danger'>You hear a crackling sound[gore].</span>")
		if(DROPLIMB_BLUNT)
			var/gore = "[(status & ORGAN_ROBOT) ? "": " in shower of gore"]"
			var/gore_sound = "[(status & ORGAN_ROBOT) ? "rending sound of tortured metal" : "sickening splatter of gore"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [src.name] explodes[gore]!</span>",\
				"<span class='moderate'><b>Your [src.name] explodes[gore]!</b></span>",\
				"<span class='danger'>You hear the [gore_sound].</span>")

	var/mob/living/carbon/human/victim = owner //Keep a reference for post-removed().
	var/obj/item/bodypart/parent_bodypart = parent

	var/use_flesh_colour = species.flesh_color
	var/use_blood_colour = species.blood_color

	removed(user, ignore_children)
	victim.traumatic_shock += 60

	if(parent_bodypart)
		var/datum/wound/lost_limb/W = new (src, disintegrate, clean)
		var/obj/item/bodypart/stump/stump = new (null, victim, src)
		stump.arterial_bleed_severity = arterial_bleed_severity
		if(status & ORGAN_ROBOT)
			stump.robotize()
		stump.wounds |= W

		if(clean)
			stump.artery_name = artery_name
			stump.status |= ORGAN_CUT_AWAY
		else
			stump.artery_name = "mangled [artery_name]"
			if(disintegrate != DROPLIMB_BURN)
				stump.sever_artery()

		stump.update_damages()

	spawn(1) // TODO check if we really need that.
		victim.updatehealth()
		victim.update_bodypart(body_zone)
		//victim.UpdateDamageIcon()
		//victim.regenerate_icons()
		dir = 2

	switch(disintegrate)
		if(DROPLIMB_EDGE)
			update_limb()//compile_icon()
			add_blood(victim)
			var/matrix/M = matrix()
			M.Turn(rand(180))
			src.transform = M
			forceMove(get_turf(src))
			if(!clean)
				// Throw limb around.
				if(src && istype(loc,/turf))
					throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1,3),30)
				dir = 2
		if(DROPLIMB_BURN)
			new /obj/effect/decal/cleanable/ash(get_turf(victim))
			for(var/obj/item/I in src)
				if(I.w_class > ITEM_SIZE_SMALL && !istype(I,/obj/item/organ))
					I.loc = get_turf(src)
			qdel(src)
		if(DROPLIMB_BLUNT)
			var/obj/effect/decal/cleanable/blood/gibs/gore
			if(status & ORGAN_ROBOT)
				gore = new /obj/effect/decal/cleanable/blood/gibs/robot(get_turf(victim))
			else
				gore = new /obj/effect/decal/cleanable/blood/gibs(get_turf(victim))
				if(species)
					gore.fleshcolor = use_flesh_colour
					gore.basecolor =  use_blood_colour
					gore.update_icon()

			gore.throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1,3),30)

			for(var/obj/item/organ/IO in organs)
				IO.removed()
				if(istype(loc,/turf))
					IO.throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1,3),30)

			for(var/obj/item/I in src)
				I.loc = get_turf(src)
				I.throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1,3),30)

			qdel(src)

/****************************************************
			   HELPERS
****************************************************/
/obj/item/bodypart/proc/sever_artery()
	if(!(status & (ORGAN_ARTERY_CUT|ORGAN_ROBOT)) && owner && owner.organs_by_name[BP_HEART])
		status |= ORGAN_ARTERY_CUT
		return TRUE
	return FALSE

/obj/item/bodypart/proc/release_restraints()
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

// checks if all wounds on the bodypart are bandaged
/obj/item/bodypart/proc/is_bandaged()
	for(var/datum/wound/W in wounds)
		if(!W.bandaged)
			return 0
	return 1

// checks if all wounds on the bodypart are salved
/obj/item/bodypart/proc/is_salved()
	for(var/datum/wound/W in wounds)
		if(!W.salved)
			return 0
	return 1

// checks if all wounds on the bodypart are disinfected
/obj/item/bodypart/proc/is_disinfected()
	for(var/datum/wound/W in wounds)
		if(!W.disinfected)
			return 0
	return 1

/obj/item/bodypart/proc/bandage()
	var/rval = 0
	src.status &= ~ORGAN_BLEEDING
	for(var/datum/wound/W in wounds)
		rval |= !W.bandaged
		W.bandaged = 1
	return rval

/obj/item/bodypart/proc/disinfect()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		rval |= !W.disinfected
		W.disinfected = 1
		W.germ_level = 0
	return rval

/obj/item/bodypart/proc/clamp()
	var/rval = 0
	src.status &= ~ORGAN_BLEEDING
	for(var/datum/wound/W in wounds)
		rval |= !W.clamped
		W.clamped = 1
	return rval

/obj/item/bodypart/proc/salve()
	var/rval = 0
	for(var/datum/wound/W in wounds)
		rval |= !W.salved
		W.salved = 1
	return rval

/obj/item/bodypart/proc/fracture()

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

	status |= ORGAN_BROKEN
	broken_description = pick("broken","fracture","hairline fracture")

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
	return

/obj/item/bodypart/proc/robotize()
	src.status &= ~ORGAN_BROKEN
	src.status &= ~ORGAN_BLEEDING
	src.status &= ~ORGAN_SPLINTED
	//src.status &= ~ORGAN_CUT_AWAY
	//src.status &= ~ORGAN_ATTACHABLE
	src.status |= ORGAN_ROBOT
	for (var/obj/item/bodypart/BP in children)
		if(BP)
			BP.robotize()

/obj/item/bodypart/proc/mutate()
	src.status |= ORGAN_MUTATED
	owner.update_body()

/obj/item/bodypart/proc/unmutate()
	src.status &= ~ORGAN_MUTATED
	owner.update_body()

/obj/item/bodypart/proc/get_damage()	//returns total damage
	return (brute_dam + burn_dam)	//could use health?

/obj/item/bodypart/proc/has_infected_wound()
	for(var/datum/wound/W in wounds)
		if(W.germ_level > INFECTION_LEVEL_ONE)
			return 1
	return 0

/obj/item/bodypart/proc/is_usable()
	return !(status & (ORGAN_MUTATED|ORGAN_DEAD))

/obj/item/bodypart/proc/is_broken()
	return ((status & ORGAN_BROKEN) && !(status & ORGAN_SPLINTED))

/obj/item/bodypart/proc/is_malfunctioning()
	return ((status & ORGAN_ROBOT) && prob(brute_dam + burn_dam))

//for arms and hands
/obj/item/bodypart/proc/process_grasp(obj/item/c_hand, hand_name)
	if (!c_hand)
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

/obj/item/bodypart/proc/embed(obj/item/weapon/W, silent = 0)
	if(!owner) //|| loc != owner)
		return
	if(owner.species.flags[NO_EMBED])
		return
	if(!silent)
		owner.visible_message("<span class='danger'>\The [W] sticks in the wound!</span>")

	var/datum/wound/supplied_wound
	for(var/datum/wound/wound in wounds)
		if((wound.damage_type == CUT || wound.damage_type == PIERCE) && wound.damage >= W.w_class * 5)
			supplied_wound = wound
			break
	if(!supplied_wound)
		supplied_wound = createwound(PIERCE, W.w_class * 5)

	if(!supplied_wound || (W in supplied_wound.embedded_objects)) // Just in case.
		return

	supplied_wound.embedded_objects += W
	implants += W
	owner.throw_alert("embeddedobject")
	owner.embedded_flag = 1
	owner.verbs += /mob/proc/yank_out_object
	W.add_blood(owner)
	if(ismob(W.loc))
		var/mob/living/H = W.loc
		H.drop_item()
	W.loc = owner

/****************************************************
			   BODYPART DEFINES
****************************************************/

/obj/item/bodypart/chest
	name = "chest"
	icon_state = "chest"
	w_class = ITEM_SIZE_HUGE

	body_part = UPPER_TORSO
	body_zone = BP_CHEST
	parent_bodypart = null
	limb_layer = BP_TORSO_LAYER
	limb_layer_priority = -0.2

	max_damage = 75
	min_broken_damage = 40

	vital = TRUE
	cannot_amputate = TRUE
	amputation_point = "spine"
	artery_name = "aorta"

/obj/item/bodypart/groin
	name = "groin"
	icon_state = "groin"
	w_class = ITEM_SIZE_LARGE

	body_part = LOWER_TORSO
	body_zone = BP_GROIN
	parent_bodypart = BP_CHEST
	limb_layer = BP_GROIN_LAYER
	limb_layer_priority = -0.1

	max_damage = 50
	min_broken_damage = 30

	vital = TRUE
	cannot_amputate = TRUE
	amputation_point = "lumbar"
	artery_name = "iliac artery"

/obj/item/bodypart/head
	name = "head"
	icon_state = "head"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL

	body_part = HEAD
	body_zone = BP_HEAD
	parent_bodypart = BP_CHEST
	limb_layer = BP_HEAD_LAYER

	max_damage = 75
	min_broken_damage = 40

	vital = TRUE
	amputation_point = "neck"
	artery_name = "cartoid artery"

	var/disfigured = 0

/obj/item/bodypart/head/take_damage(brute, burn, sharp, edge, used_weapon = null, list/forbidden_limbs = list())
	. = ..(brute, burn, sharp, edge, used_weapon, forbidden_limbs)
	if(!disfigured)
		if(brute_dam > 40)
			if (prob(50))
				disfigure("brute")
		if(burn_dam > 40)
			disfigure("burn")

/obj/item/bodypart/head/proc/disfigure(type = "brute")
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

/obj/item/bodypart/l_arm
	name = "left arm"
	icon_state = "l_arm"
	w_class = ITEM_SIZE_NORMAL

	body_part = ARM_LEFT
	body_zone = BP_L_ARM
	parent_bodypart = BP_CHEST
	limb_layer = BP_L_ARM_LAYER

	max_damage = 80
	min_broken_damage = 35

	amputation_point = "left shoulder"
	artery_name = "basilic vein"
	arterial_bleed_severity = 0.75

/obj/item/bodypart/l_arm/process()
	..()
	if(owner)
		process_grasp(owner.l_hand, "left hand")

/obj/item/bodypart/r_arm
	name = "right arm"
	icon_state = "r_arm"
	w_class = ITEM_SIZE_NORMAL

	body_part = ARM_RIGHT
	body_zone = BP_R_ARM
	parent_bodypart = BP_CHEST
	limb_layer = BP_R_ARM_LAYER

	max_damage = 80
	min_broken_damage = 35

	amputation_point = "right shoulder"
	artery_name = "basilic vein"
	arterial_bleed_severity = 0.75

/obj/item/bodypart/r_arm/process()
	..()
	if(owner)
		process_grasp(owner.r_hand, "right hand")

/obj/item/bodypart/l_leg
	name = "left leg"
	icon_state = "l_leg"
	w_class = ITEM_SIZE_NORMAL

	body_part = LEG_LEFT
	body_zone = BP_L_LEG
	parent_bodypart = BP_GROIN
	limb_layer = BP_L_LEG_LAYER

	max_damage = 80
	min_broken_damage = 35

	amputation_point = "left hip"
	artery_name = "femoral artery"
	arterial_bleed_severity = 0.75

/obj/item/bodypart/r_leg
	name = "right leg"
	icon_state = "r_leg"
	w_class = ITEM_SIZE_NORMAL

	body_part = LEG_RIGHT
	body_zone = BP_R_LEG
	parent_bodypart = BP_GROIN
	limb_layer = BP_R_LEG_LAYER

	max_damage = 80
	min_broken_damage = 35

	amputation_point = "right hip"
	artery_name = "femoral artery"
	arterial_bleed_severity = 0.75

/obj/item/bodypart/stump
	name = "limb stump"
	icon = 'icons/mob/human_races/bad_limb.dmi'
	//dislocated = -1

/obj/item/bodypart/stump/New(loc, mob/living/carbon/C, obj/item/bodypart/lost_limb)
	if(istype(lost_limb))
		body_part = lost_limb.body_part
		body_zone = lost_limb.body_zone
		parent_bodypart = lost_limb.parent_bodypart
		limb_layer = lost_limb.limb_layer
		amputation_point = lost_limb.amputation_point
		//joint = lost_limb.joint
	else if(ispath(lost_limb))
		body_part = initial(lost_limb.body_part)
		body_zone = initial(lost_limb.body_zone)
		parent_bodypart = initial(lost_limb.parent_bodypart)
		limb_layer = initial(lost_limb.limb_layer)
		amputation_point = initial(lost_limb.amputation_point)
		max_damage = initial(lost_limb.max_damage)

	name = "stump of \a [parse_zone(body_zone)]"

	..(null, C)

	if(istype(lost_limb))
		max_damage = lost_limb.max_damage
		if((lost_limb.status & ORGAN_ROBOT) && (!parent || (parent.status & ORGAN_ROBOT)))
			robotize() //if both limb and the parent are robotic, the stump is robotic too
	else if(ispath(lost_limb))
		if(!parent || (parent.status & ORGAN_ROBOT))
			robotize()

/obj/item/bodypart/stump/removed()
	..()
	qdel(src)

/obj/item/bodypart/stump/update_limb() // TODO: separate stump icons from body.
	if(status & ORGAN_CUT_AWAY)
		icon_state = null
		return

	if(status & ORGAN_ROBOT)
		icon_state = body_zone + "_robot_stump"
	else
		icon_state = body_zone + "_stump"
	return

/obj/item/bodypart/stump/get_icon()
	return image(icon = src.icon, icon_state = src.icon_state, layer = -BODYPARTS_LAYER)

/obj/item/bodypart/stump/fracture()
	return

/obj/item/bodypart/proc/is_stump()
	return FALSE

/obj/item/bodypart/stump/is_stump()
	return TRUE

/obj/item/bodypart/stump/is_usable()
	return FALSE


/****************************************************
			   EXTERNAL ORGAN ITEMS
****************************************************/

/obj/item/weapon/organ
	icon = 'icons/mob/human_races/r_human.dmi'

/obj/item/weapon/organ/New(loc, mob/living/carbon/human/H)
	..(loc)
	if(!istype(H))
		return
	if(H.dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[H.dna.unique_enzymes] = H.dna.b_type

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
	icon_state = "l_arm"
/obj/item/weapon/organ/l_leg
	name = "left leg"
	icon_state = "l_leg"
/obj/item/weapon/organ/r_arm
	name = "right arm"
	icon_state = "r_arm"
/obj/item/weapon/organ/r_leg
	name = "right leg"
	icon_state = "r_leg"
/obj/item/weapon/organ/head
	name = "head"
	icon_state = "head_m"
	var/mob/living/carbon/brain/brainmob
	var/brain_op_stage = 0

/obj/item/weapon/organ/head/posi
	name = "robotic head"

/obj/item/weapon/organ/head/New(loc, mob/living/carbon/human/H)
	if(istype(H))
		src.icon_state = H.gender == MALE? "head_m" : "head_f"
	..()
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
	spawn(5)
	if(brainmob && brainmob.client)
		brainmob.client.screen.len = null //clear the hud

	//if(ishuman(H))
	//	if(H.gender == FEMALE)
	//		H.icon_state = "head_f"
	transfer_identity(H)

	name = "[H.real_name]'s head"

	H.regenerate_icons()

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
/obj/item/weapon/organ/head/proc/transfer_identity(mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->head
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob.container = src

/obj/item/weapon/organ/head/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/scalpel))
		switch(brain_op_stage)
			if(0)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] is beginning to have \his head cut open with [W] by [user].", 1)
				to_chat(brainmob, "\red [user] begins to cut open your head with [W]!")
				to_chat(user, "\red You cut [brainmob]'s head open with [W]!")

				brain_op_stage = 1

			if(2)
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

/obj/item/bodypart/proc/get_wounds_desc()
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
	if(is_stump() && !(status & ORGAN_ATTACHABLE))
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
