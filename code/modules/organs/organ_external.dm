/****************************************************
				BODYPARTS
****************************************************/
/obj/item/organ/external
	name = "external"

	// When measuring bodytemperature,
	// multiply by this coeff.
	var/temp_coeff = 1.0

	// Strings
	var/broken_description            // fracture string if any.
	var/damage_state = "00"           // Modifier used for generating the on-mob damage overlay for this limb.

	// Damage vars.
	var/brute_dam = 0                 // Actual current brute damage.
	var/burn_dam = 0                  // Actual current burn damage.
	var/last_dam = -1                 // used in healing/processing calculations.
	var/max_damage = 0                // Damage cap

	var/controller_type = /datum/bodypart_controller
	var/datum/bodypart_controller/controller

	// Appearance vars.
	var/body_part = null              // Part flag
	var/body_zone = null              // Unique identifier of this limb.
	var/datum/species/species
	var/original_color
	var/b_type = "A+"
	var/is_rejecting = FALSE

	// Wound and structural data.
	var/wound_update_accuracy = 1     // how often wounds should be updated, a higher number means less often
	var/list/wounds = list()          // wound datum list.
	var/number_wounds = 0             // number of wounds, which is NOT wounds.len!
	var/list/children = list()        // Sub-limbs.
	var/list/bodypart_organs = list() // Internal organs of this body part
	var/sabotaged = 0                 // If a prosthetic limb is emagged, it will detonate when it fails.
	var/list/implants = list()        // Currently implanted objects.
	var/bandaged = FALSE              // Are there any visual bandages on this bodypart
	var/is_stump = FALSE              // Is it just a leftover of a destroyed bodypart
	var/leaves_stump = TRUE           // Does this bodypart leaves a stump when destroyed

	// Joint/state stuff.
	var/cannot_amputate               // Impossible to amputate.
	var/artery_name = "artery"        // Flavour text for cartoid artery, aorta, etc.
	var/arterial_bleed_severity = 1   // Multiplier for bleeding in a limb.

	// Surgery vars.
	var/open = 0
	var/stage = 0
	var/cavity = 0
	var/atom/movable/applied_pressure

	// Misc
	var/list/butcher_results

	// Will be removed, moved or refactored.
	var/obj/item/hidden = null // relation with cavity
	var/tmp/perma_injury = 0
	var/limb_layer = 0
	var/damage_msg = "<span class='warning'>You feel an intense pain</span>"

	var/regen_bodypart_penalty = 0 // This variable determines how much time it would take to regenerate a bodypart, and the cost of it's regeneration.

/obj/item/organ/external/atom_init(mapload, mob/living/carbon/human/H)
	. = ..()
	recolor()
	controller = new controller_type(src)
	if(H)
		species = owner.species
		b_type = owner.dna.b_type
	else // Bodypart was spawned outside of the body so we need to update its sprite
		species = all_species[HUMAN]
		update_sprite()

/obj/item/organ/external/Destroy()
	if(parent)
		parent.children -= src
		parent = null
	QDEL_NULL(controller)
	if(owner)
		owner.bodyparts -= src
		if(owner.bodyparts_by_name[body_zone] == src)
			owner.bodyparts_by_name -= body_zone
		owner.bad_bodyparts -= src
	return ..()

/obj/item/organ/external/proc/harvest(obj/item/I, mob/user)
	if(!locate(/obj/structure/table) in loc)
		return
	if(!butcher_results)
		return

	for(var/path in butcher_results)
		for(var/i in 1 to butcher_results[path])
			new path(loc)
	visible_message("<span class='notice'>[user] butchers [src].</span>")
	qdel(src)

/obj/item/organ/external/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchenknife))
		harvest(I, user)
	else
		return ..()

/obj/item/organ/external/insert_organ(mob/living/carbon/human/H, surgically = FALSE)
	..()

	owner.bodyparts += src
	owner.bodyparts_by_name[body_zone] = src

	if(parent)
		parent.children += src

	if(surgically)
		check_rejection()

/obj/item/organ/external/proc/recolor()
	if(!owner)
		return
	if (owner.species.flags[HAS_SKIN_COLOR])
		original_color = RGB_CONTRAST(owner.r_skin, owner.g_skin, owner.b_skin)
	else if(owner.species.flags[HAS_SKIN_TONE])
		original_color = RGB_CONTRAST(owner.s_tone, owner.s_tone, owner.s_tone)

// Keep in mind that this proc should work even if owner = null
/obj/item/organ/external/proc/update_sprite()
	var/gender = owner ? owner.gender : MALE
	var/mutations = owner ? owner.mutations : list()
	var/fat
	var/g

	if(body_zone == BP_CHEST && owner)
		fat = HAS_TRAIT(owner, TRAIT_FAT) ? "fat" : null
	if(body_zone in list(BP_CHEST, BP_GROIN, BP_HEAD))
		g = (gender == FEMALE ? "f" : "m")

	if (!species.has_gendered_icons)
		g = null

	if (HUSK in mutations)
		icon = 'icons/mob/human_races/husk.dmi'
		icon_state = body_zone
	else if (status & ORGAN_MUTATED)
		icon = species.deform
		icon_state = "[body_zone][g ? "_[g]" : ""][fat ? "_[fat]" : ""]"
	else
		icon = species.icobase
		icon_state = "[body_zone][g ? "_[g]" : ""][fat ? "_[fat]" : ""]"

	if(status & ORGAN_DEAD)
		color = NECROSIS_COLOR_MOD
	else if (HUSK in mutations)
		color = null
	else if(HULK in mutations)
		color = HULK_SKIN_COLOR
	else
		color = original_color

/****************************************************
			   DAMAGE PROCS
****************************************************/

/obj/item/organ/external/proc/is_damageable(additional_damage = 0)
	return controller.is_damageable(additional_damage)

/obj/item/organ/external/emp_act(severity)
	controller.emp_act(severity)

/obj/item/organ/external/proc/take_damage(brute = 0, burn = 0, damage_flags = 0, used_weapon = null)
	return controller.take_damage(brute, burn, damage_flags, used_weapon)

/obj/item/organ/external/proc/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	return controller.heal_damage(brute, burn, internal, robo_repair)

/*
This function completely restores a damaged organ to perfect condition.
*/
/obj/item/organ/external/proc/rejuvenate()
	controller.rejuvenate()

/obj/item/organ/external/proc/createwound(type = CUT, damage)
	return controller.createwound(type, damage)

/****************************************************
			   PROCESSING & UPDATING
****************************************************/

//Determines if we even need to process this organ.

/obj/item/organ/external/proc/need_process()
	return controller.need_process()

/obj/item/organ/external/process()
	controller.process()

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
	controller.update_germs()

/obj/item/organ/external/proc/handle_germ_sync()
	controller.handle_germ_sync()

/obj/item/organ/external/proc/handle_germ_effects()
	controller.handle_germ_effects()

//Updating wounds. Handles wound natural I had some free spachealing, internal bleedings and infections
/obj/item/organ/external/proc/update_wounds()
	controller.update_wounds()

//Updates brute_damn and burn_damn from wound damages. Updates BLEEDING status.
/obj/item/organ/external/proc/update_damages()
	controller.update_damages()

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
	if(is_stump)
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

/obj/item/organ/external/proc/damage_state_color()
	return controller.damage_state_color()

/****************************************************
			   DISMEMBERMENT
****************************************************/

//Handles dismemberment
/obj/item/organ/external/proc/droplimb(no_explode = FALSE, clean = FALSE, disintegrate = DROPLIMB_EDGE)
	if(cannot_amputate || !owner)
		return

	owner.bodyparts -= src
	owner.bodyparts_by_name -= body_zone
	owner.bad_bodyparts -= src
	var/should_delete = FALSE

	switch(disintegrate)
		if(DROPLIMB_EDGE)
			if(!clean)
				var/gore_sound = "[is_robotic() ? "tortured metal" : "ripping tendons and flesh"]"
				owner.visible_message(
					"<span class='danger'>\The [owner]'s [name] flies off in an arc!</span>",
					"<span class='moderate'><b>Your [name] goes flying off!</b></span>",
					"<span class='danger'>You hear a terrible sound of [gore_sound].</span>")
		if(DROPLIMB_BURN)
			var/gore = "[is_robotic() ? "": " of burning flesh"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [name] flashes away into ashes!</span>",
				"<span class='moderate'><b>Your [name] flashes away into ashes!</b></span>",
				"<span class='danger'>You hear a crackling sound[gore].</span>")
		if(DROPLIMB_BLUNT)
			var/gore = "[is_robotic() ? "": " in shower of gore"]"
			var/gore_sound = "[is_robotic() ? "rending sound of tortured metal" : "sickening splatter of gore"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [name] explodes[gore]!</span>",
				"<span class='moderate'><b>Your [name] explodes[gore]!</b></span>",
				"<span class='danger'>You hear the [gore_sound].</span>")

	status &= ~(ORGAN_BROKEN | ORGAN_BLEEDING | ORGAN_SPLINTED | ORGAN_ARTERY_CUT)

	// If any bodyparts are attached to this, destroy them
	for(var/obj/item/organ/external/BP in owner.bodyparts)
		if(BP.parent == src)
			BP.droplimb(null, clean, disintegrate)

	if(parent && !(parent.is_stump) && disintegrate != DROPLIMB_BURN)
		if(clean)
			if(prob(10))
				parent.sever_artery()
		else
			parent.sever_artery()
	if(parent)
		parent.children -= src
	parent = null

	switch(disintegrate)
		if(DROPLIMB_EDGE)
			var/obj/bodypart = src // Dropped limb object
			add_blood(owner)
			bodypart.forceMove(owner.loc)

			if(bodypart)
				//Robotic limbs explode if sabotaged.
				if(is_robotic() && !no_explode && sabotaged)
					explosion(get_turf(owner), 0, 0, 2, 3)
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
			should_delete = TRUE
		if(DROPLIMB_BLUNT)
			var/obj/effect/decal/cleanable/blood/gibs/gore
			if(is_robotic())
				gore = new /obj/effect/decal/cleanable/blood/gibs/robot(get_turf(owner))
			else
				gore = new /obj/effect/decal/cleanable/blood/gibs(get_turf(owner))
				gore.fleshcolor = owner.species.flesh_color
				gore.basedatum =  new(owner.species.blood_datum)
				gore.update_icon()

			gore.throw_at(get_edge_target_turf(owner, pick(alldirs)), rand(1, 3), throw_speed)

			for(var/obj/item/I in src)
				I.loc = get_turf(src)
				I.throw_at(get_edge_target_turf(owner, pick(alldirs)), rand(1, 3), throw_speed)
			should_delete = TRUE
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
	if(body_zone == BP_HEAD)
		owner.update_hair()
		owner.handle_decapitation(src)

	// OK so maybe your limb just flew off, but if it was attached to a pair of cuffs then hooray! Freedom!
	release_restraints()

	if(vital)
		owner.death()

	owner.UpdateDamageIcon(src)
	if(!clean && leaves_stump)
		new /obj/item/organ/external/stump(null, owner, src)
	owner.updatehealth()

	if(!should_delete)
		handle_cut()
		owner = null
	else
		qdel(src)

// A limb got cut and exposed to air
/obj/item/organ/external/proc/handle_cut()
	return controller.handle_cut()

/obj/item/organ/external/proc/sever_artery()
	return controller.sever_artery()

/****************************************************
			   HELPERS
****************************************************/

/obj/item/organ/external/proc/release_restraints()
	if (owner.handcuffed && (body_part in list(ARM_LEFT, ARM_RIGHT)))
		owner.visible_message(\
			"\The [owner.handcuffed.name] falls off of [owner.name].",\
			"\The [owner.handcuffed.name] falls off you.")

		owner.drop_from_inventory(owner.handcuffed)

	if (owner.legcuffed && (body_part in list(LEG_LEFT, LEG_RIGHT)))
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

/obj/item/organ/external/proc/strap()
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
	controller.fracture()

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

/obj/item/organ/external/get_icon(icon_layer)
	if (!owner)
		return

	update_sprite()
	var/mutable_appearance/MA = mutable_appearance(icon, icon_state, -icon_layer)
	MA.color = color

	return MA

/obj/item/organ/external/head/get_icon(icon_layer)
	if (!owner)
		return

	update_sprite()
	var/mutable_appearance/MA = mutable_appearance(icon, icon_state, -icon_layer)
	MA.color = color
	. = list(MA)

	//Eyes
	if(species && species.eyes)
		var/mutable_appearance/img_eyes_s = mutable_appearance('icons/mob/human_face.dmi', species.eyes, -icon_layer)
		if(!(HULK in owner.mutations))
			img_eyes_s.color = rgb(owner.r_eyes, owner.g_eyes, owner.b_eyes)
		else
			img_eyes_s.color = "#ff0000"
		. += img_eyes_s

	//Mouth	(lipstick!)
	if(owner.lip_style && owner.species.flags[HAS_LIPS]) // skeletons are allowed to wear lipstick no matter what you think, agouri.
		var/mutable_appearance/lips = mutable_appearance('icons/mob/human_face.dmi', "lips_[owner.lip_style]_s", -icon_layer)
		lips.color = owner.lip_color
		. += lips

// Runs once when attached
/obj/item/organ/external/proc/check_rejection()
	controller.check_rejection()

// Can we attach this bodypart at all
/obj/item/organ/external/proc/is_compatible(mob/living/carbon/human/H)
	return TRUE

/obj/item/organ/external/proc/is_attached()
	return !!owner

/obj/item/organ/external/proc/is_flesh()
	return controller.bodypart_type == BODYPART_ORGANIC

/obj/item/organ/external/proc/is_robotic()
	return controller.bodypart_type == BODYPART_ROBOTIC

/obj/item/organ/external/proc/is_usable()
	return !(status & (ORGAN_MUTATED|ORGAN_DEAD)) && !is_rejecting

/obj/item/organ/external/proc/is_broken()
	return ((status & ORGAN_BROKEN) && !(status & ORGAN_SPLINTED))

/obj/item/organ/external/proc/is_malfunctioning()
	return (is_robotic() && prob(brute_dam + burn_dam))

//for arms and hands
/obj/item/organ/external/proc/process_grasp(obj/item/c_hand, hand_name)
	if (!c_hand)
		return

	if(iszombie(owner))
		return

	if(is_broken())
		owner.drop_from_inventory(c_hand)
		var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
		owner.emote("grunt", SHOWMSG_VISUAL, "[(owner.species && owner.species.flags[NO_PAIN]) ? "" : emote_scream ] drops what they were holding in their [hand_name]!")
	if(is_malfunctioning())
		owner.drop_from_inventory(c_hand)
		owner.emote("grunt", SHOWMSG_VISUAL, "drops what they were holding, their [hand_name] malfunctioning!")
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, owner)
		spark_system.attach(owner)
		spark_system.start()
		spawn(10)
			qdel(spark_system)

/obj/item/organ/external/proc/embed(obj/item/weapon/W, silent = 0, supplied_message, datum/wound/supplied_wound)
	if(!owner || owner.species.flags[NO_EMBED])
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

	owner.throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)

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

	temp_coeff = 1.08

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

	temp_coeff = 1.06

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

	temp_coeff = 1.05

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
	var/mob/living/carbon/brain/brainmob
	var/brain_op_stage = 0
	var/f_style // So we can put his haircut back when we attach the head
	var/h_style
	var/grad_style
	var/r_facial
	var/g_facial
	var/b_facial
	var/dyed_r_facial
	var/dyed_g_facial
	var/dyed_b_facial
	var/facial_painted
	var/r_hair
	var/g_hair
	var/b_hair
	var/dyed_r_hair
	var/dyed_g_hair
	var/dyed_b_hair
	var/r_grad
	var/g_grad
	var/b_grad
	var/hair_painted

/obj/item/organ/external/head/atom_init()
	. = ..()
	organ_head_list += src

/obj/item/organ/external/head/Destroy()
	organ_head_list -= src
	QDEL_NULL(brainmob)
	return ..()

/obj/item/organ/external/head/is_compatible(mob/living/carbon/human/H)
	if(H.species.name == IPC || H.species.name == DIONA)
		return FALSE

	return TRUE

/obj/item/organ/external/head/recolor()
	..()
	if(!owner)
		return

	cut_overlays()
	//Add (facial) hair.
	if(owner.f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[owner.f_style]
		if(facial_hair_style)
			f_style = owner.f_style
			r_facial = owner.r_facial
			g_facial = owner.g_facial
			b_facial = owner.b_facial
			dyed_r_facial = owner.dyed_r_facial
			dyed_g_facial = owner.dyed_g_facial
			dyed_b_facial = owner.dyed_b_facial
			facial_painted = owner.facial_painted
			var/mutable_appearance/facial = mutable_appearance(facial_hair_style.icon, "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				if(!facial_painted)
					facial.color = RGB_CONTRAST(r_facial, g_facial, b_facial)
				else
					facial.color = RGB_CONTRAST(dyed_r_facial, dyed_g_facial, dyed_b_facial)

			add_overlay(facial)

	if(owner.h_style)
		var/datum/sprite_accessory/hair_style = hair_styles_list[owner.h_style]
		if(hair_style)
			h_style = owner.h_style
			grad_style = owner.grad_style
			r_hair = owner.r_hair
			g_hair = owner.g_hair
			b_hair = owner.b_hair
			dyed_r_hair = owner.dyed_r_hair
			dyed_g_hair = owner.dyed_g_hair
			dyed_b_hair = owner.dyed_b_hair
			r_grad = owner.r_grad
			g_grad = owner.g_grad
			b_grad = owner.b_grad
			hair_painted = owner.hair_painted
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				var/icon/grad_s = new/icon("icon" = 'icons/mob/hair_gradients.dmi', "icon_state" = hair_gradients[grad_style])
				grad_s.Blend(hair_s, ICON_AND)
				if(!hair_painted)
					hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_AND)
					grad_s.Blend(rgb(r_grad, g_grad, b_grad), ICON_AND)
				else
					hair_s.Blend(rgb(dyed_r_hair, dyed_g_hair, dyed_b_hair), ICON_AND)
					grad_s.Blend(rgb(dyed_r_hair, dyed_g_hair, dyed_b_hair), ICON_AND)
				hair_s.Blend(grad_s, ICON_OVERLAY)

			add_overlay(mutable_appearance(hair_s, "[hair_style.icon_state]_s"))

/obj/item/organ/external/head/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/scalpel) || istype(I, /obj/item/weapon/kitchenknife) || istype(I, /obj/item/weapon/shard))
		switch(brain_op_stage)
			if(0)
				//todo: should be replaced with visible_message
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("<span class='warning'>[brainmob] is beginning to have \his head cut open with [I] by [user].</span>", SHOWMSG_VISUAL)
				to_chat(brainmob, "<span class='warning'>[user] begins to cut open your head with [I]!</span>")
				to_chat(user, "<span class='warning'>You cut [brainmob]'s head open with [I]!</span>")

				brain_op_stage = 1

			if(2)
				if(!(species in list(DIONA, IPC)))
					for(var/mob/O in (oviewers(brainmob) - user))
						O.show_message("<span class='warning'>[brainmob] is having \his connections to the brain delicately severed with [I] by [user].</span>", SHOWMSG_VISUAL)
					to_chat(brainmob, "<span class='warning'>[user] begins to cut open your head with [I]!</span>")
					to_chat(user, "<span class='warning'>You cut [brainmob]'s head open with [I]!</span>")

					brain_op_stage = 3.0
			else
				return ..()

	else if(istype(I, /obj/item/weapon/circular_saw) || istype(I, /obj/item/weapon/crowbar) || istype(I, /obj/item/weapon/hatchet))
		switch(brain_op_stage)
			if(1)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("<span class='warning'>[brainmob] has \his head sawed open with [I] by [user].</span>", SHOWMSG_VISUAL)
				to_chat(brainmob, "<span class='warning'>[user] begins to saw open your head with [I]!</span>")
				to_chat(user, "<span class='warning'>You saw [brainmob]'s head open with [I]!</span>")

				brain_op_stage = 2
			if(3)
				if(!(species in list(DIONA, IPC)))
					for(var/mob/O in (oviewers(brainmob) - user))
						O.show_message("<span class='warning'>[brainmob] has \his spine's connection to the brain severed with [I] by [user].</span>", SHOWMSG_VISUAL)
					to_chat(brainmob, "<span class='warning'>[user] severs your brain's connection to the spine with [I]!</span>")
					to_chat(user, "<span class='warning'>You sever [brainmob]'s brain's connection to the spine with [I]!</span>")

					brainmob.log_combat(user, "debrained with [I.name] (INTENT: [uppertext(user.a_intent)])")

					if(istype(src,/obj/item/organ/external/head/robot))
						var/obj/item/device/mmi/posibrain/B = new(loc)
						B.transfer_identity(brainmob)
					else
						var/obj/item/brain/B = new(loc)
						B.transfer_identity(brainmob)

					brain_op_stage = 4.0
			else
				return ..()
	else
		return ..()

/obj/item/organ/external/head/diona
	vital = FALSE

/obj/item/organ/external/head/diona/is_compatible(mob/living/carbon/human/H)
	if(H.species.name == DIONA)
		return TRUE

	return FALSE

/obj/item/organ/external/l_arm
	name = "left arm"
	artery_name = "basilic vein"

	temp_coeff = 1.0

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
	if(owner)
		process_grasp(owner.l_hand, "left hand")


/obj/item/organ/external/r_arm
	name = "right arm"
	artery_name = "basilic vein"

	temp_coeff = 1.0

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
	if(owner)
		process_grasp(owner.r_hand, "right hand")

/obj/item/organ/external/l_leg
	name = "left leg"
	artery_name = "femoral artery"

	temp_coeff = 0.75

	body_part = LEG_LEFT
	body_zone = BP_L_LEG
	parent_bodypart = BP_GROIN
	limb_layer = LIMB_L_LEG_LAYER
	regen_bodypart_penalty = 75

	arterial_bleed_severity = 0.75
	max_damage = 50
	min_broken_damage = 30
	w_class = ITEM_SIZE_NORMAL

/obj/item/organ/external/r_leg
	name = "right leg"
	artery_name = "femoral artery"

	temp_coeff = 0.75

	body_part = LEG_RIGHT
	body_zone = BP_R_LEG
	parent_bodypart = BP_GROIN
	limb_layer = LIMB_R_LEG_LAYER
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
		owner.visible_message("<span class='warning'>You hear a sickening cracking sound coming from \the [owner]'s face.</span>",	\
		"<span class='warning'><b>Your face becomes unrecognizible mangled mess!</b></span>",	\
		"<span class='warning'>You hear a sickening crack.</span>")
	else
		owner.visible_message("<span class='warning'>[owner]'s face melts away, turning into mangled mess!</span>",	\
		"<span class='warning'><b>Your face melts off!</b></span>",	\
		"<span class='warning'>You hear a sickening sizzle.</span>")
	disfigured = 1


/obj/item/organ/external/proc/get_wounds_desc()
	if(is_robotic())
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
	if(is_stump)
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

/mob/living/carbon/human/proc/get_missing_bodyparts()
	var/list/missing = list()
	for(var/BP in species.has_bodypart)
		if(!bodyparts_by_name[BP])
			missing += BP
	return missing

/mob/living/carbon/human/proc/apply_recolor()
	for(var/obj/item/organ/external/BP in bodyparts)
		BP.species = BP.owner.species
		BP.recolor()
