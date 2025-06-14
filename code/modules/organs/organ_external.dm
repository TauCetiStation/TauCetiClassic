#define PICK_DAMAGE_STATE "[pick(0, 0, 1, 1, 1, 2, 2, 2, 3, 3)][pick(0, 0, 1, 1, 1, 2, 2, 2, 3, 3)]"

/****************************************************
				BODYPARTS
****************************************************/
/obj/item/organ/external
	name = "external"

	icon = 'icons/mob/human/human.dmi'

	var/list/mutable_appearance/layers = list()

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
	var/body_part = null              // Part flag, mostly used for clothing coverage
	var/body_zone = null              // Unique identifier of this limb.
	var/default_icon_layer = BODY_LAYER  // mob overlay layer
	var/organ_suffix                  // suffix for organs with variations
	var/datum/species/species
	var/b_type = BLOOD_A_PLUS
	var/is_rejecting = FALSE

	// Wound and structural data.
	var/wound_update_accuracy = 1     // how often wounds should be updated, a higher number means less often
	var/list/wounds = list()          // wound datum list.
	var/number_wounds = 0             // number of wounds, which is NOT wounds.len!
	var/list/children = list()        // Sub-limbs.
	var/list/bodypart_organs = list() // Internal organs of this body part
	var/sabotaged = 0                 // If a prosthetic limb is emagged, it will detonate when it fails.
	var/list/embedded_objects = list() // Currently implanted objects. Includes embed objects, implants like mindshield, borers...
	var/bandaged = FALSE              // Are there any visual bandages on this bodypart
	var/is_stump = FALSE              // Is it just a leftover of a destroyed bodypart
	var/leaves_stump = TRUE           // Does this bodypart leaves a stump when destroyed
	// PUMPED, yo
	var/pumped = 0
	// Value after which the bodypart changes it's sprite
	var/pumped_threshold = 20
	var/max_pumped = 60

	// Joint/state stuff.
	var/cannot_amputate               // Impossible to amputate.
	var/artery_name = "artery"        // Flavour text for cartoid artery, aorta, etc.
	var/arterial_bleed_severity = 1   // Multiplier for bleeding in a limb.

	// Surgery vars.
	var/open = 0
	var/stage = 0
	var/cavity = 0
	var/trauma_kit = FALSE
	var/burn_kit = FALSE
	var/atom/movable/applied_pressure

	// Misc
	var/list/butcher_results

	// Will be removed, moved or refactored.
	var/obj/item/hidden = null // relation with cavity
	var/tmp/perma_injury = 0
	var/limb_layer = 0 // organ damage layer
	var/damage_msg = "<span class='warning'>You feel an intense pain</span>"

	var/regen_bodypart_penalty = 0 // This variable determines how much time it would take to regenerate a bodypart, and the cost of it's regeneration.

	// cache our holes so they don't move with every appearance generation
	var/zombie_overlay_pick
	var/burnt_overlay_pick
	var/husk_overlay_pick

	// copy of owner prefs for cases of dismembering
	var/owner_gender
	var/r_skin = /datum/preferences::r_skin
	var/g_skin = /datum/preferences::g_skin
	var/b_skin = /datum/preferences::b_skin
	var/s_tone = /datum/preferences::s_tone
	var/r_belly = /datum/preferences::r_belly // second species color, we should rename it from the "belly"
	var/g_belly = /datum/preferences::g_belly
	var/b_belly = /datum/preferences::b_belly

	var/is_slime
	var/is_zombie
	var/is_skeleton
	var/is_husk
	var/is_burnt

// todo: currently it's impossible to spawn organs out of body 
// as insert_organ() call with owner is required for proper init
/*
/obj/item/organ/external/atom_init(mapload)
	..()

	controller = new controller_type(src)
*/

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
	QDEL_LIST(bodypart_organs)
	if(pumped)
		owner.mob_metabolism_mod.RemoveMods(src)
	return ..()

// owner can be optional
/obj/item/organ/external/set_owner(mob/living/carbon/human/H)
	..()

	b_type = owner.dna.b_type

// species for external organs must always exist, our icon depends on it
/obj/item/organ/external/proc/set_species(datum/species/S)
	SHOULD_CALL_PARENT(TRUE)
	species = S

// organs should keep a copy of owner preferences they need for appearance generation
// at minimum we need skin colors and gender
// todo: this should look better when we datumize prefs
/obj/item/organ/external/proc/set_preferences(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)

	owner_gender = H.gender
	r_skin = H.r_skin
	g_skin = H.g_skin
	b_skin = H.b_skin
	s_tone = H.s_tone
	r_belly = H.r_belly
	g_belly = H.g_belly
	b_belly = H.b_belly

/obj/item/organ/external/proc/set_traits(mob/living/carbon/human/H)
	is_slime = HAS_TRAIT(H, ELEMENT_TRAIT_SLIME)
	is_zombie = HAS_TRAIT(H, ELEMENT_TRAIT_ZOMBIE)
	is_skeleton = HAS_TRAIT(H, ELEMENT_TRAIT_SKELETON) // conflicts with that fact that skeleton limbs is already a separated object, we can move it to skeleton bodyparts, or remove skeleton bodyparts and do all our logic in common organs
	is_husk = HAS_TRAIT(H, TRAIT_HUSK)
	is_burnt = HAS_TRAIT(H, TRAIT_BURNT)

// mostly for homunculus
/obj/item/organ/external/proc/randomize_preferences()
	owner_gender = pick(MALE, FEMALE)

	// fuck why we still use 3 variables per color in preferences instead of hex
	var/list/skin_color = rgb2num(pick(COLOR_GREEN, COLOR_LIGHT_PINK, COLOR_ROSE_PINK, COLOR_VIOLET, COLOR_DEEP_SKY_BLUE, COLOR_RED, COLOR_LIME, COLOR_PINK))
	r_skin = skin_color[1]
	g_skin = skin_color[2]
	b_skin = skin_color[3]

	skin_color = rgb2num(pick(COLOR_GREEN, COLOR_LIGHT_PINK, COLOR_ROSE_PINK, COLOR_VIOLET, COLOR_DEEP_SKY_BLUE, COLOR_RED, COLOR_LIME, COLOR_PINK))
	r_belly = skin_color[1]
	g_belly = skin_color[2]
	b_belly = skin_color[3]

	s_tone = random_skin_tone()

/obj/item/organ/external/insert_organ(mob/living/carbon/human/H, surgically = FALSE, datum/species/S)
	..()

	if (!surgically) // body creation, should set it all
		if(!S)
			S = H.species
		set_species(S) // species should always be set, we use previous one if we surgically installed
		set_preferences(H) // cache owner preferences, can be freely updated if needed

	owner.bodyparts += src
	owner.bodyparts_by_name[body_zone] = src

	if(!controller)
		controller = new controller_type(src)

	for(var/obj/item/organ/internal/IO in bodypart_organs)
		IO.insert_organ(owner)

	if(parent)
		parent.children += src

	if(surgically)
		check_rejection()

/obj/item/organ/external/proc/mod_skin_color(original_color)
	// sorted in priority, maybe some day someone will experiment with colors mixing
	if(is_slime)
		return rgb(5, 255, 251, 127) // #05fffb + alpha
	else if(is_skeleton)
		return null
	else if(is_zombie)
		return "#4a730c"
	else if(is_burnt)
		return "#333333"
	else if(is_husk || status & ORGAN_DEAD)
		return list(0.2,0.2,0.2, 0.36,0.36,0.36, 0.07,0.07,0.07) // grayscale matrix but darker
	else if(owner && (HULK in owner.mutations))
		return "#30e028"
	else
		return original_color

/obj/item/organ/external/proc/get_skin_color()
	// should allow color for IPC, but not for protheses
	// todo: protheses should have own color and we should not rewrite it with preferences
	if(controller_type == /datum/bodypart_controller/robot)
		return null
	else if(species.flags[HAS_SKIN_COLOR])
		. = rgb(r_skin, g_skin, b_skin)
	else if(species.flags[HAS_SKIN_TONE])
		var/datum/skin_tone/tone = global.skin_tones_by_name[s_tone]
		. = tone.hex

	. = mod_skin_color(.)

/obj/item/organ/external/proc/get_skin_second_color()
	if(controller_type == /datum/bodypart_controller/robot)
		return null

	var/original_color = rgb(r_belly, g_belly, b_belly)
	. = mod_skin_color(original_color)

	if(. != original_color && istext(.)) // so we use mod color
		. = color_shift_luminance(., -5) // just make it darker then

/obj/item/organ/external/proc/get_blood_color()
	var/datum/dirt_cover/blood_datum
	if(owner)
		blood_datum = owner.get_blood_datum()
	else
		if(is_slime)
			blood_datum = /datum/dirt_cover/blue_blood
		else if(species.blood_datum_path)
			blood_datum = species.blood_datum_path
		else
			blood_datum = /datum/dirt_cover/red_blood
	return blood_datum::color

// updates icon and icon_state based on our current species/prefs/owner
/obj/item/organ/external/proc/update_sprite()
	if(is_skeleton && species.skeleton)
		icon = species.skeleton
		icon_state = get_icon_state(gender_state = FALSE, fat_state = FALSE, pump_state = FALSE)
		return

	if ((status & ORGAN_MUTATED) && species.deformed) // todo: make it filters
		icon = species.deformed
	else
		icon = species.icobase

	icon_state = get_icon_state()

/obj/item/organ/external/proc/get_icon_state(gender_state = TRUE, fat_state = TRUE, pump_state = TRUE)
	var/gender_suffix
	var/fat_suffix
	var/pump_suffix

	if(gender_state)
		var/gender_icon = FALSE
		switch(body_zone)
			if(BP_CHEST, BP_GROIN, BP_HEAD)
				gender_icon = species.gender_body_icons
			if(BP_R_ARM, BP_L_ARM, BP_R_LEG, BP_L_LEG)
				gender_icon = species.gender_limb_icons
			if(BP_TAIL)
				gender_icon = species.gender_tail_icons
			if(BP_WINGS)
				gender_icon = species.gender_wings_icons

		if(gender_icon)
			gender_suffix = (owner_gender == FEMALE ? "_f" : "_m")

	if(fat_state && owner && HAS_TRAIT(owner, TRAIT_FAT))
		if(body_zone == BP_CHEST)
			fat_suffix = "_fat"
		else if(species.fat_limb_icons == TRUE && (body_zone in list(BP_GROIN, BP_HEAD, BP_R_ARM, BP_L_ARM, BP_R_LEG, BP_L_LEG)))
			fat_suffix = "_fat"

	if(pump_state && !fat_suffix && pumped > pumped_threshold)
		pump_suffix = "_pumped"

	return "[body_zone][organ_suffix][gender_suffix][fat_suffix][pump_suffix]"

// generates list of (mutable) appearances
// should work even without owner
// order is important if you place them on the same layer, later overlays usually higher
/obj/item/organ/external/proc/generate_appearances(update_preferences = FALSE)
	RETURN_TYPE(/list)
	SHOULD_CALL_PARENT(TRUE)

	if(is_stump)
		return

	// todo: it can rewrite things we don't want to rewrite
	// in the future we can use list of datums for preferences we want to update
	if(update_preferences && owner)
		set_preferences(owner)

	if(owner) // pull actual traits every time while owner is still attached
		set_traits(owner)

	update_sprite()

	. = list()

	var/mutable_appearance/base_appearance = mutable_appearance(icon, icon_state, -default_icon_layer)
	. += base_appearance

	if(species.alpha_color_mask)
		var/mutable_appearance/alpha_color_appearance = mutable_appearance(icon, "alpha_[icon_state]")
		alpha_color_appearance.color = get_skin_color()
		base_appearance.add_overlay(alpha_color_appearance)
	else
		base_appearance.color = get_skin_color()

	if(species.second_color_mask && icon_exists(icon, "color_[icon_state]"))
		var/mutable_appearance/second_color_appearance = mutable_appearance(icon, "color_[icon_state]")
		second_color_appearance.appearance_flags = RESET_COLOR | RESET_ALPHA
		second_color_appearance.color = get_skin_second_color()
		base_appearance.add_overlay(second_color_appearance)

	// attach bones to base appearance for slimepeople (if we not skeleton already)
	if(is_slime && species.skeleton && controller.bodypart_type != BODYPART_SKELETON)
		var/mutable_appearance/bones_appearance = mutable_appearance(species.skeleton, get_icon_state(gender_state = FALSE, fat_state = FALSE, pump_state = FALSE))
		bones_appearance.appearance_flags = RESET_COLOR | RESET_ALPHA
		bones_appearance.blend_mode = BLEND_INSET_OVERLAY // inset fixes some clipping issues
		// because we can't combine inset with underlays (or other blend modes) we need to add alpha to make it appear "under" skin
		// unfortunately it makes skeleton unnecessarily transparent
		bones_appearance.alpha = 127
		base_appearance.add_overlay(bones_appearance)

	// sometimes we can see the insides of the mob
	if(is_zombie && species.skeleton)
		if(!zombie_overlay_pick)
			zombie_overlay_pick = PICK_DAMAGE_STATE
		// reuse of damage overlays here, feel free to create own overlays set for things like this
		if(zombie_overlay_pick != "00" && icon_exists('icons/mob/human/masks/damage_overlays.dmi', "[body_zone]_[zombie_overlay_pick]"))
			var/mutable_appearance/zombie_holes = mutable_appearance('icons/mob/human/masks/damage_overlays.dmi', "[body_zone]_[zombie_overlay_pick]", -BODY_FEATURES_LAYER)
			zombie_holes.color = get_blood_color()
			zombie_holes.appearance_flags = KEEP_TOGETHER
			var/mutable_appearance/zombie_bones_appearance = mutable_appearance(species.skeleton, get_icon_state(gender_state = FALSE, fat_state = FALSE, pump_state = FALSE))
			zombie_bones_appearance.blend_mode = BLEND_MULTIPLY
			zombie_holes.add_overlay(zombie_bones_appearance)
			. += zombie_holes

	if(is_burnt && species.skeleton)
		if(!burnt_overlay_pick)
			burnt_overlay_pick = PICK_DAMAGE_STATE
		if(burnt_overlay_pick != "00" && icon_exists('icons/mob/human/masks/damage_overlays.dmi', "[body_zone]_[burnt_overlay_pick]"))
			var/mutable_appearance/burnt_holes = mutable_appearance('icons/mob/human/masks/damage_overlays.dmi', "[body_zone]_[burnt_overlay_pick]", -BODY_FEATURES_LAYER)
			burnt_holes.color = "#cf7516"
			burnt_holes.appearance_flags = KEEP_TOGETHER
			var/mutable_appearance/zombie_bones_appearance = mutable_appearance(species.skeleton, get_icon_state(gender_state = FALSE, fat_state = FALSE, pump_state = FALSE))
			zombie_bones_appearance.blend_mode = BLEND_MULTIPLY
			burnt_holes.add_overlay(zombie_bones_appearance)
			. += burnt_holes

	if(is_husk)
		if(!husk_overlay_pick)
			husk_overlay_pick = PICK_DAMAGE_STATE
		if(husk_overlay_pick != "00" && icon_exists('icons/mob/human/masks/damage_overlays.dmi', "[body_zone]_[husk_overlay_pick]"))
			var/mutable_appearance/husk_holes = mutable_appearance('icons/mob/human/masks/damage_overlays.dmi', "[body_zone]_[husk_overlay_pick]", -BODY_FEATURES_LAYER)
			husk_holes.color = rgb(60, 60, 60, 127)
			. += husk_holes

// update how the organ looks for when it separated
// no point to call it when organ is inside (attached to) the body
/obj/item/organ/external/proc/apply_appearance()
	overlays = generate_appearances()

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

/****************************************************
			   DAMAGE PROCS
****************************************************/

/obj/item/organ/external/proc/is_damageable(additional_damage = 0)
	return controller.is_damageable(additional_damage)

/obj/item/organ/external/emp_act(severity)
	controller.emp_act(severity)

/obj/item/organ/external/take_damage(brute = 0, burn = 0, damage_flags = 0, used_weapon = null)
	if(!isnum(burn))
		return // prevent basic take_damage usage (TODO remove workaround)
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

	// todo: need to write better logic for dismembering and embedded_objects
	for(var/obj/item/weapon/implant/implanted_object in embedded_objects)
		qdel(implanted_object)
		if(prob(25))
			new /obj/item/weapon/implant/meltdown(owner.loc)

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
					"<span class='userdanger'><b>Your [name] goes flying off!</b></span>",
					"<span class='danger'>You hear a terrible sound of [gore_sound].</span>")
		if(DROPLIMB_BURN)
			var/gore = "[is_robotic() ? "": " of burning flesh"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [name] flashes away into ashes!</span>",
				"<span class='userdanger'><b>Your [name] flashes away into ashes!</b></span>",
				"<span class='danger'>You hear a crackling sound[gore].</span>")
		if(DROPLIMB_BLUNT)
			var/gore = "[is_robotic() ? "": " in shower of gore"]"
			var/gore_sound = "[is_robotic() ? "rending sound of tortured metal" : "sickening splatter of gore"]"
			owner.visible_message(
				"<span class='danger'>\The [owner]'s [name] explodes[gore]!</span>",
				"<span class='userdanger'><b>Your [name] explodes[gore]!</b></span>",
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
			add_blood(owner)
			//Robotic limbs explode if sabotaged.
			if(is_robotic() && !no_explode && sabotaged)
				explosion(get_turf(owner), 0, 0, 2, 3)
				var/datum/effect/effect/system/spark_spread/spark_system = new
				spark_system.set_up(5, 0, owner)
				spark_system.attach(owner)
				spark_system.start()
				spawn(10)
					qdel(spark_system)
		if(DROPLIMB_BURN)
			new /obj/effect/decal/cleanable/ash(get_turf(owner))
			for(var/obj/item/I in src)
				if(I.w_class > SIZE_TINY && !istype(I, /obj/item/organ))
					I.loc = get_turf(src)
			should_delete = TRUE
		if(DROPLIMB_BLUNT)
			var/obj/effect/decal/cleanable/blood/gibs/gore
			if(is_robotic())
				gore = new /obj/effect/decal/cleanable/blood/gibs/robot(get_turf(owner))
			else
				gore = new /obj/effect/decal/cleanable/blood/gibs(get_turf(owner), owner)

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
	if(pumped)
		owner.mob_metabolism_mod.RemoveMods(src)

	if(body_zone == BP_HEAD)
		owner.handle_decapitation(src)
	// OK so maybe your limb just flew off, but if it was attached to a pair of cuffs then hooray! Freedom!
	release_restraints()

	if(vital)
		owner.death()

	for(var/obj/item/organ/internal/IO in bodypart_organs)
		owner.organs -= IO
		owner.organs_by_name -= IO.organ_tag
		IO.owner = null

	owner.UpdateDamageIcon(src)
	if(!clean && leaves_stump)
		var/obj/item/organ/external/stump/S = new(null)
		S.copy_original_limb(src)
		S.insert_organ(owner, FALSE)

	owner.updatehealth()
	owner.update_body(body_zone)
	owner.update_underwear()

	if(!should_delete)
		forceMove(owner.loc)
		owner = null
		apply_appearance()

		var/matrix/M = matrix()
		transform = M.Turn(rand(180))

		if(!clean)
			// Throw limb around.
			if(isturf(loc))
				throw_at(get_edge_target_turf(loc, pick(alldirs)), rand(1, 3), throw_speed)
		handle_cut()
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
	owner.update_body(body_zone)

/obj/item/organ/external/proc/unmutate()
	src.status &= ~ORGAN_MUTATED
	owner.update_body(body_zone)

/obj/item/organ/external/proc/get_damage()	//returns total damage
	return max(brute_dam + burn_dam - perma_injury, perma_injury)	//could use health?

/obj/item/organ/external/proc/has_infected_wound()
	for(var/datum/wound/W in wounds)
		if(W.germ_level > INFECTION_LEVEL_ONE)
			return 1
	return 0

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

/obj/item/organ/external/proc/is_artery_cut()
	return (status & ORGAN_ARTERY_CUT)

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
		owner.emote("grunt")
	if(is_malfunctioning())
		owner.drop_from_inventory(c_hand)
		owner.emote("grunt")
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, owner)
		spark_system.attach(owner)
		spark_system.start()
		spawn(10)
			qdel(spark_system)

/obj/item/organ/external/proc/embed(obj/item/weapon/W, silent = 0, supplied_message, datum/wound/supplied_wound)
	if(!owner || HAS_TRAIT(owner, TRAIT_NO_EMBED))
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

	owner.throw_alert("embeddedobject", /atom/movable/screen/alert/embeddedobject)

	supplied_wound.embedded_objects += W
	embedded_objects += W
	owner.sec_hud_set_implants()
	owner.embedded_flag = TRUE
	owner.verbs += /mob/proc/yank_out_object
	W.add_blood(owner)
	if(ismob(W.loc))
		var/mob/living/H = W.loc
		H.drop_from_inventory(W)
	W.loc = owner

/obj/item/organ/external/proc/adjust_pumped(value, cap)
	return controller.adjust_pumped(value, cap)

/****************************************************
			   ORGAN DEFINES
****************************************************/

/obj/item/organ/external/chest
	name = "chest"
	cases = list("грудь", "груди", "груди", "грудь", "грудью", "груди")
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
	w_class = SIZE_BIG // Used for dismembering thresholds, in addition to storage. Humans are w_class 6, so it makes sense that chest is w_class 5.

/obj/item/organ/external/chest

/obj/item/organ/external/groin
	name = "groin"
	cases = list("пах", "паха", "паху", "пах", "пахом", "пахе")
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
	w_class = SIZE_NORMAL

/obj/item/organ/external/tail
	name = "tail"
	cases = list("хвост", "хвоста", "хвосту", "хвост", "хвостом", "хвосте")

	icon_state = "tail"
	default_icon_layer = BODY_INFRONT_LAYER // todo: we can make it two layers with BODY_BEHIND_LAYER like wings

	// not in TARGET_ZONE_ALL so can't be targeted and damaged, i hope
	body_zone = BP_TAIL
	parent_bodypart = BP_GROIN

	cannot_amputate = TRUE
	leaves_stump = FALSE

	max_pumped = 0

	vital = FALSE

/obj/item/organ/external/tail/generate_appearances()

	var/render_flags = 0
	if(owner)
		render_flags = owner.wear_suit?.render_flags

	if(render_flags & HIDE_TAIL)
		return

	. = ..()

	// some shitty copypaste for second BEHIND base appearance
	// skipping alpha_color_mask/second_color_mask/damage holes for this as currently it's useless for tails
	// one day when we rewrite body rendering with cut masks based on coverage and merge tails (and wings) in one layer we can remove this

	var/mutable_appearance/base_appearance_behind = mutable_appearance(icon, "[icon_state]_BEHIND", -BODY_BEHIND_LAYER)
	base_appearance_behind.color = get_skin_color()
	. += base_appearance_behind

	// attach bones to base appearance for slimepeople (if we not skeleton already)
	if(is_slime && species.skeleton && controller.bodypart_type != BODYPART_SKELETON)
		var/mutable_appearance/bones_appearance_behind = mutable_appearance(species.skeleton, "[get_icon_state(get_icon_state(gender_state = FALSE, fat_state = FALSE, pump_state = FALSE))]_BEHIND")
		bones_appearance_behind.appearance_flags = RESET_COLOR | RESET_ALPHA
		bones_appearance_behind.blend_mode = BLEND_INSET_OVERLAY
		bones_appearance_behind.alpha = 175
		base_appearance_behind.add_overlay(bones_appearance_behind)

/obj/item/organ/external/wings
	name = "wings"
	cases = list("крылья", "крыльев", "крыльям", "крылья", "крыльями", "крыльях")

	icon_state = "wings"
	default_icon_layer = BODY_INFRONT_LAYER

	body_zone = BP_WINGS
	parent_bodypart = BP_CHEST

	cannot_amputate = TRUE
	leaves_stump = FALSE

	max_pumped = 0

	vital = FALSE

/obj/item/organ/external/wings/generate_appearances()
	var/render_flags = 0
	if(owner)
		render_flags = owner.wear_suit?.render_flags

	if(render_flags & HIDE_WINGS)
		return

	. = ..()

	// todo: same cover problem as in https://github.com/TauCetiStation/TauCetiClassic/issues/8846
	// we use hack from tg with second layer just for one dir
	// need to find some universal solution for all these problems

	var/mutable_appearance/base_appearance_behind = mutable_appearance(icon, "[icon_state]_BEHIND", -BODY_BEHIND_LAYER)
	base_appearance_behind.color = get_skin_color()
	. += base_appearance_behind

// moth wings variations
/obj/item/organ/external/wings/moth
	species = /datum/species/moth // it does nothing, just for spawns
	organ_suffix = "_atlas" // wings_atlas is the default state for moths

/obj/item/organ/external/wings/moth/atom_init()
	if(SSholiday.holidays[NEW_YEAR])
		organ_suffix = pick("_royal", "_feathery")

	icon_state += organ_suffix

/obj/item/organ/external/head
	name = "head"
	cases = list("голова", "головы", "голове", "голову", "головой", "голове")
	desc = "This one will be silent forever. Isn't it beautiful?"
	force = 5
	throwforce = 10
	artery_name = "carotid artery"

	icon_state = "head_m"

	temp_coeff = 1.05

	body_part = HEAD
	body_zone = BP_HEAD
	parent_bodypart = BP_CHEST
	limb_layer = LIMB_HEAD_LAYER
	regen_bodypart_penalty = 100

	max_damage = 75
	min_broken_damage = 35
	vital = TRUE
	w_class = SIZE_SMALL

	// No PUMPED sprite for the head means you can't pump it.
	// Threshold is still there to not be interpreted as FULLY PUMPED
	pumped_threshold = 20
	max_pumped = 0

	var/disfigured = FALSE
	var/mob/living/carbon/brain/brainmob
	var/brain_op_stage = 0

	// cache hair prefs so that we can use it if our owner decides to part with his head
	var/f_style
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
	var/r_eyes
	var/g_eyes
	var/b_eyes
	var/lip_style
	var/lip_color

/obj/item/organ/external/head/Destroy()
	lost_heads_list -= src
	QDEL_NULL(brainmob)
	return ..()

/obj/item/organ/external/head/is_compatible(mob/living/carbon/human/H)
	if(H.get_species() in list(IPC, DIONA, PODMAN))
		return FALSE

	return TRUE

/obj/item/organ/external/head/set_preferences(mob/living/carbon/human/H)
	..()

	// facial hair
	f_style = H.f_style
	r_facial = H.r_facial
	g_facial = H.g_facial
	b_facial = H.b_facial
	dyed_r_facial = H.dyed_r_facial
	dyed_g_facial = H.dyed_g_facial
	dyed_b_facial = H.dyed_b_facial
	facial_painted = H.facial_painted

	// hair
	h_style = H.h_style
	grad_style = H.grad_style
	r_hair = H.r_hair
	g_hair = H.g_hair
	b_hair = H.b_hair
	dyed_r_hair = H.dyed_r_hair
	dyed_g_hair = H.dyed_g_hair
	dyed_b_hair = H.dyed_b_hair
	r_grad = H.r_grad
	g_grad = H.g_grad
	b_grad = H.b_grad
	hair_painted = H.hair_painted

	// eyes
	r_eyes = H.r_eyes
	g_eyes = H.g_eyes
	b_eyes = H.b_eyes

	// lips
	lip_style = H.lip_style
	lip_color = H.lip_color

/obj/item/organ/external/head/generate_appearances()
	. = ..()

	// eyes
	// todo: should move it to own organ, make /eyes external
	if(species.eyes_static_layer)
		var/mutable_appearance/eyes_static_layer = mutable_appearance(
			species.eyes_icon, 
			species.eyes_static_layer, 
			-EYES_LAYER
		)

		if(owner && HAS_TRAIT(owner, TRAIT_PLUVIAN_BLESSED))
			eyes_static_layer.color = "#88ffff"

		. += eyes_static_layer

	if(species.eyes_colorable_layer)
		var/mutable_appearance/eyes_colorable_layer = mutable_appearance(
			species.eyes_icon, 
			species.eyes_colorable_layer, 
			-EYES_LAYER
		)

		eyes_colorable_layer.color = rgb(r_eyes, g_eyes, b_eyes)
		if(owner)
			if(HAS_TRAIT(owner, TRAIT_PLUVIAN_BLESSED))
				eyes_colorable_layer.color = "#00ffff"
			else if((HULK in owner.mutations) || (LASEREYES in owner.mutations) || iszombie(owner) || HAS_TRAIT(owner, TRAIT_CULT_EYES)) // todo: red eyes trait
				eyes_colorable_layer.color = "#ff0000"

			if(HAS_TRAIT(owner, TRAIT_GLOWING_EYES))
				eyes_colorable_layer.plane = LIGHTING_LAMPS_PLANE
				eyes_colorable_layer.layer = ABOVE_LIGHTING_LAYER

		. += eyes_colorable_layer

	// lips
	if(lip_style && species.flags[HAS_LIPS])
		var/mutable_appearance/lips_appearance = mutable_appearance('icons/mob/human_face.dmi', "lips_[lip_style]_s", -default_icon_layer)
		lips_appearance.color = lip_color

		lips_appearance.pixel_x = species.offset_features[OFFSET_FACE][1]
		lips_appearance.pixel_y = species.offset_features[OFFSET_FACE][2]

		. += lips_appearance

	var/should_render_facial = TRUE
	var/should_render_hair = TRUE

	if(is_burnt)
		should_render_facial = FALSE
		should_render_hair = FALSE
	else if(owner)
		var/render_flags = owner.head?.render_flags || owner.wear_mask?.render_flags || owner.wear_suit?.render_flags || owner.w_uniform?.render_flags
		if(render_flags & HIDE_FACIAL_HAIR)
			should_render_facial = FALSE
		if(render_flags & HIDE_TOP_HAIR)
			should_render_hair = FALSE

	// facial hair
	if(f_style && should_render_facial)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/mutable_appearance/facial_appearance = mutable_appearance(facial_hair_style.icon, "[facial_hair_style.icon_state]_s", -HAIR_LAYER)

			facial_appearance.pixel_x = species.offset_features[OFFSET_FACE][1]
			facial_appearance.pixel_y = species.offset_features[OFFSET_FACE][2]

			if(facial_hair_style.do_colouration)
				if(is_husk)
					facial_appearance.color = RGB_CONTRAST(178, 178, 178)
				else
					facial_appearance.color = facial_painted ? RGB_CONTRAST(dyed_r_facial, dyed_g_facial, dyed_b_facial) : RGB_CONTRAST(r_facial, g_facial, b_facial)
			. += facial_appearance

	// hair
	if(h_style && should_render_hair)
		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style)
			var/mutable_appearance/hair_appearance = mutable_appearance(hair_style.icon, "[hair_style.icon_state]_s", -HAIR_LAYER)
			if(hair_style.do_colouration)
				if(is_husk || grad_style == "none") // no gradients, just fill with color
					var/mycolor
					if(is_husk)
						mycolor = RGB_CONTRAST(178, 178, 178)
					else if (hair_painted)
						mycolor = RGB_CONTRAST(dyed_r_hair, dyed_g_hair, dyed_b_hair)
					else
						mycolor = RGB_CONTRAST(r_hair, g_hair, b_hair)
					hair_appearance.color = mycolor
				else // messy part, gradients
					var/mutable_appearance/gradient = mutable_appearance('icons/mob/human/masks/hair_gradients.dmi', hair_gradients[grad_style])
					gradient.appearance_flags = KEEP_TOGETHER
					gradient.blend_mode = BLEND_INSET_OVERLAY // i think we can cut additional hair overlay if we use BLEND_MULTIPLY here, but need to make hair sprites white and ditch RGB_CONTRAST
					gradient.color = hair_painted ? RGB_CONTRAST(dyed_r_hair, dyed_g_hair, dyed_b_hair) : RGB_CONTRAST(r_grad, g_grad, b_grad)
					var/mutable_appearance/hair_appearance2 = new(hair_appearance)
					hair_appearance2.blend_mode = BLEND_INSET_OVERLAY
					gradient.add_overlay(hair_appearance2)

					var/mutable_appearance/main_color = new(hair_appearance)
					main_color.color = hair_painted ? RGB_CONTRAST(dyed_r_hair, dyed_g_hair, dyed_b_hair) : RGB_CONTRAST(r_hair, g_hair, b_hair)

					hair_appearance.appearance_flags = KEEP_TOGETHER
					hair_appearance.add_overlay(list(main_color, gradient))

			hair_appearance.pixel_x = species.offset_features[OFFSET_HAIR][1]
			hair_appearance.pixel_y = species.offset_features[OFFSET_HAIR][2]

			. += hair_appearance

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

	else if(istype(I, /obj/item/weapon/circular_saw) || isprying(I) || istype(I, /obj/item/weapon/hatchet))
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
					SEND_SIGNAL(user, COMSIG_HUMAN_HARMED_OTHER, brainmob)


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
	controller_type = /datum/bodypart_controller/nymph

/obj/item/organ/external/head/podman
	controller_type = /datum/bodypart_controller/plant

/obj/item/organ/external/head/diona/is_compatible(mob/living/carbon/human/H)
	return species.name == H.species.name

/obj/item/organ/external/head/abomination
	vital = FALSE

/obj/item/organ/external/l_arm
	name = "left arm"
	cases = list("левая рука", "левой руки", "левой руке", "левую руку", "левой рукой", "левой руке")
	desc = "Need a hand?"
	force = 7

	icon_state = "l_arm"

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
	w_class = SIZE_SMALL
	hitsound = list('sound/weapons/genhit1.ogg')

/obj/item/organ/external/l_arm/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.can_push = TRUE
	SCB.can_pull = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/organ/external/l_arm/process()
	..()
	if(owner)
		process_grasp(owner.l_hand, "left hand")

/obj/item/organ/external/l_arm/diona
	name = "left upper tendril"
	cases = list("левый верхний отросток", "левого верхнего отростка", "левому верхнему отростку", "левый верхний отросток", "левым верхним отростком", "левом верхнем отростком")
	vital = FALSE
	controller_type = /datum/bodypart_controller/nymph

/obj/item/organ/external/l_arm/diona/podman
	controller_type = /datum/bodypart_controller/plant

/obj/item/organ/external/r_arm
	name = "right arm"
	cases = list("правая рука", "правой руки", "правой руке", "правую руку", "правой рукой", "правой руке")
	desc = "A right hand for the job."
	force = 7
	artery_name = "basilic vein"

	icon_state = "r_arm"

	temp_coeff = 1.0

	body_part = ARM_RIGHT
	body_zone = BP_R_ARM
	parent_bodypart = BP_CHEST
	limb_layer = LIMB_R_ARM_LAYER
	regen_bodypart_penalty = 75

	arterial_bleed_severity = 0.75
	max_damage = 50
	min_broken_damage = 30
	w_class = SIZE_SMALL
	hitsound = list('sound/weapons/genhit1.ogg')

/obj/item/organ/external/r_arm/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.can_push = TRUE
	SCB.can_pull = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/organ/external/r_arm/process()
	..()
	if(owner)
		process_grasp(owner.r_hand, "right hand")

/obj/item/organ/external/r_arm/diona
	name = "right upper tendril"
	cases = list("правый верхний отросток", "правого верхнего отростка", "правому верхнему отростку", "правый верхний отросток", "правым верхним отростком", "правым верхнем отростком")
	vital = FALSE
	controller_type = /datum/bodypart_controller/nymph

/obj/item/organ/external/r_arm/diona/podman
	controller_type = /datum/bodypart_controller/plant

/obj/item/organ/external/l_leg
	name = "left leg"
	cases = list("левая нога", "левой ноги", "левой ноге", "левую ногу", "левой ногой", "левой ноге")
	desc = "Break a leg! Somebody else's leg. With this leg."
	force = 9
	artery_name = "femoral artery"

	icon_state = "l_leg"

	temp_coeff = 0.75

	body_part = LEG_LEFT
	body_zone = BP_L_LEG
	parent_bodypart = BP_GROIN
	limb_layer = LIMB_L_LEG_LAYER
	regen_bodypart_penalty = 75

	arterial_bleed_severity = 0.75
	max_damage = 50
	min_broken_damage = 30
	w_class = SIZE_SMALL
	hitsound = list('sound/weapons/genhit1.ogg')

/obj/item/organ/external/l_leg/diona
	name = "left lower tendril"
	cases = list("левый нижний отросток", "левого нижнего отростка", "левому нижнему отростку", "левый нижний отросток", "левым нижним отростком", "левом нижнем отростком")
	vital = FALSE
	controller_type = /datum/bodypart_controller/nymph

/obj/item/organ/external/l_leg/diona/podman
	controller_type = /datum/bodypart_controller/plant

/obj/item/organ/external/r_leg
	name = "right leg"
	cases = list("правая нога", "правой ноги", "правой ноге", "правую ногу", "правой ногой", "правой ноге")
	desc = "The infamous third leg."
	force = 9

	artery_name = "femoral artery"

	icon_state = "r_leg"

	temp_coeff = 0.75

	body_part = LEG_RIGHT
	body_zone = BP_R_LEG
	parent_bodypart = BP_GROIN
	limb_layer = LIMB_R_LEG_LAYER
	regen_bodypart_penalty = 75

	arterial_bleed_severity = 0.75
	max_damage = 50
	min_broken_damage = 30
	w_class = SIZE_SMALL
	hitsound = list('sound/weapons/genhit1.ogg')

/obj/item/organ/external/r_leg/diona
	name = "right lower tendril"
	cases = list("правый нижний отросток", "правого нижнего отростка", "правому нижнему отростку", "правый нижний отросток", "правым нижним отростком", "правым нижнем отростком")
	vital = FALSE
	controller_type = /datum/bodypart_controller/nymph

/obj/item/organ/external/r_leg/diona/podman
	controller_type = /datum/bodypart_controller/plant

/obj/item/organ/external/head/take_damage(brute, burn, damage_flags, used_weapon)
	if(!disfigured)
		if(brute_dam > 40)
			if (prob(50))
				disfigure(BRUTE)
		if(burn_dam > 40)
			disfigure(BURN)

	return ..()

/obj/item/organ/external/head/proc/disfigure(type = BRUTE)
	if (disfigured)
		return
	if(type == BRUTE)
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

		return get_english_list(descriptors)

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

	return get_english_list(flavor_text)

/mob/living/carbon/human/proc/get_missing_bodyparts()
	var/list/missing = list()
	for(var/BP in species.has_bodypart)
		if(!bodyparts_by_name[BP])
			missing += BP
	return missing

// lol yes
/obj/item/organ/external/chest/homunculus
/obj/item/organ/external/chest/homunculus/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SACRIFICE, RELIGION_TRAIT)

/obj/item/organ/external/groin/homunculus
/obj/item/organ/external/groin/homunculus/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SACRIFICE, RELIGION_TRAIT)

/obj/item/organ/external/head/homunculus
/obj/item/organ/external/head/homunculus/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SACRIFICE, RELIGION_TRAIT)

/obj/item/organ/external/l_arm/homunculus
/obj/item/organ/external/l_arm/homunculus/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SACRIFICE, RELIGION_TRAIT)

/obj/item/organ/external/r_arm/homunculus
/obj/item/organ/external/r_arm/homunculus/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SACRIFICE, RELIGION_TRAIT)

/obj/item/organ/external/l_leg/homunculus
/obj/item/organ/external/l_leg/homunculus/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SACRIFICE, RELIGION_TRAIT)

/obj/item/organ/external/r_leg/homunculus
/obj/item/organ/external/r_leg/homunculus/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SACRIFICE, RELIGION_TRAIT)

#undef PICK_DAMAGE_STATE
