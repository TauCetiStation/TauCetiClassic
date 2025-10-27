/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species
	var/name                     // Species name.

	var/icobase = 'icons/mob/human/human.dmi'      // Normal set
	var/deformed = 'icons/mob/human/human_deformed.dmi' // Mutated set (todo: replace this set with some effect)
	var/skeleton = 'icons/mob/human/human_skeleton.dmi'  // Skeleton set

	var/alpha_color_mask = FALSE  // use "alpha_" bodypart overlays to apply main colors
	var/second_color_mask = FALSE // use additional "color_" bodypart overlays for a second color set

	var/damage_mask = TRUE

	// todo: move logic to the eyes organ (make it external?)
	// after we can store icons with the rest of the species organs
	var/eyes_icon = 'icons/mob/human/eyes.dmi'
	var/eyes_colorable_layer = "default" // Part of the eye to which we apply a user color, for example colored human iris
	var/eyes_static_layer // Part that uses own predefined color, for example white human sclera

	var/gender_body_icons = TRUE // if TRUE = use icon_state with _f or _m for respective gender (see get_icon() external organ proc).
	var/gender_tail_icons = FALSE
	var/gender_wings_icons = FALSE
	var/gender_limb_icons = FALSE
	var/fat_limb_icons = FALSE

	var/hud_offset_x = 0                                 // As above, but specifically for the HUD indicator.
	var/hud_offset_y = 0                                 // As above, but specifically for the HUD indicator.
	var/blood_trail_type = /obj/effect/decal/cleanable/blood/tracks/footprints

	// Combat vars.
	var/total_health = 100                               // Point at which the mob will enter crit.
	var/datum/unarmed_attack/unarmed                                          // For empty hand harm-intent attack
	var/unarmed_type = /datum/unarmed_attack
	var/datum/action/innate/race/race_ability = null
	var/list/race_verbs = list()
	var/list/race_traits = list()

	// Multiplicative modificators of mob defenses. Setting it to 0 makes mob immune to damage
	var/brute_mod = 1                                    // Physical damage multiplier
	var/burn_mod = 1                                     // Burn damage multiplier
	var/oxy_mod = 1                                      // Oxyloss multiplier
	var/tox_mod = 1                                      // Toxloss multiplier
	var/clone_mod = 1                                    // Cloneloss multiplier
	var/brain_mod = 1                                    // Brainloss multiplier

	var/speed_mod =  0                                   // How fast or slow specific specie.
	var/speed_mod_no_shoes = 0                           // Speed modifier without shoes.
	var/siemens_coefficient = 1                          // How conductive is the specie.

	var/pluvian_social_credit = 1                        // Species default social credit for pluvian social credit system

	var/primitive                     // Lesser form, if any (ie. monkey for humans)
	var/language                      // Default racial language, if any.
	// Additional languages, to the primary. These can not be the forced ones.
	// Use LANGUAGE = LANGUAGE_CAN_UNDERSTAND to give languages which a specimen can understand, but not speak.
	var/list/additional_languages
	var/species_common_language = FALSE // If TRUE, racial language will be forced by default when speaking.

	var/list/butcher_drops = list(/obj/item/weapon/reagent_containers/food/snacks/meat/human = 5)
	// Perhaps one day make this an assoc list of BODYPART_NAME = list(drops) ? ~Luduk
	// Is used when a bodypart of this race is butchered. Otherwise there are overrides for flesh, robot, and bone bodyparts.
	var/list/bodypart_butcher_results

	var/list/restricted_inventory_slots = list() // Slots that the race does not have due to biological differences.

	var/inhale_type = "oxygen"           // Non-oxygen gas breathed, if any.
	var/exhale_type = "carbon_dioxide"   // Exhaled gas type.
	var/poison_type = "phoron"           // Poisonous air.

	var/cold_level_1 = BODYTEMP_COLD_DAMAGE_LIMIT		// Cold damage level 1 below this point.
	var/cold_level_2 = BODYTEMP_COLD_DAMAGE_LIMIT - 5	// Cold damage level 2 below this point.
	var/cold_level_3 = BODYTEMP_COLD_DAMAGE_LIMIT - 10	// Cold damage level 3 below this point.

	var/heat_level_1 = BODYTEMP_HEAT_DAMAGE_LIMIT		// Heat damage level 1 above this point.
	var/heat_level_2 = BODYTEMP_HEAT_DAMAGE_LIMIT + 40	// Heat damage level 2 above this point.
	var/heat_level_3 = BODYTEMP_HEAT_DAMAGE_LIMIT + 640	// Heat damage level 3 above this point.

	var/breath_cold_level_1 = BODYTEMP_COLD_DAMAGE_LIMIT - 15
	var/breath_cold_level_2 = BODYTEMP_COLD_DAMAGE_LIMIT - 30
	var/breath_cold_level_3 = BODYTEMP_COLD_DAMAGE_LIMIT - 45

	var/body_temperature = BODYTEMP_NORMAL	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/synth_temp_gain = 0					//IS_SYNTHETIC species will gain this much temperature every second
	var/synth_temp_max = 0					//IS_SYNTHETIC will cap at this value

	var/metabolism_mod = 1 // Multiplicative modificator of mob metabolism. Setting it to 0 disables species metabolism
	var/taste_sensitivity = TASTE_SENSITIVITY_NORMAL //the most widely used factor; humans use a different one
	var/dietflags = 0	// Make sure you set this, otherwise it won't be able to digest a lot of foods

	var/darksight = 2
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/list/flags = list()       // Various specific features. Please use race_traits.

	var/specie_suffix_fire_icon = "human"
	var/datum/dirt_cover/blood_datum_path = /datum/dirt_cover/red_blood //Red.
	var/specie_shoe_blood_state = "shoeblood"
	var/specie_hand_blood_state = "bloodyhands"
	var/flesh_color = "#ffc896" //Pink.
	var/default_skin_color // default skin color (r_skin, g_skin, b_skin)
	var/default_eyes_color

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		SPRITE_SHEET_HELD = 'icons/mob/path',
		SPRITE_SHEET_UNIFORM = 'icons/mob/path',
		SPRITE_SHEET_UNIFORM_FAT = 'icons/mob/path',
		SPRITE_SHEET_SUIT = 'icons/mob/path',
		SPRITE_SHEET_SUIT_FAT = 'icons/mob/path',
		SPRITE_SHEET_BELT = 'icons/mob/path'
		SPRITE_SHEET_HEAD = 'icons/mob/path',
		SPRITE_SHEET_BACK = 'icons/mob/path',
		SPRITE_SHEET_MASK = 'icons/mob/path',
		SPRITE_SHEET_EARS = 'icons/mob/path',
		SPRITE_SHEET_EYES = 'icons/mob/path',
		SPRITE_SHEET_FEET = 'icons/mob/path',
		SPRITE_SHEET_GLOVES = 'icons/mob/path'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/

	var/list/sprite_sheets = list()

	// This is default organs set which is mostly used upon mob creation.
	// Keep in mind that position of organ is important in those lists.
	// If hand connects to chest, then chest should go first.
	var/list/has_bodypart = list(
		 BP_CHEST  = /obj/item/organ/external/chest
		,BP_GROIN  = /obj/item/organ/external/groin
		,BP_HEAD   = /obj/item/organ/external/head
		,BP_L_ARM  = /obj/item/organ/external/l_arm
		,BP_R_ARM  = /obj/item/organ/external/r_arm
		,BP_L_LEG  = /obj/item/organ/external/l_leg
		,BP_R_LEG  = /obj/item/organ/external/r_leg
		)

	var/list/has_organ = list(
		 O_HEART   = /obj/item/organ/internal/heart
		,O_BRAIN   = /obj/item/organ/internal/brain
		,O_EYES    = /obj/item/organ/internal/eyes
		,O_LUNGS   = /obj/item/organ/internal/lungs
		,O_LIVER   = /obj/item/organ/internal/liver
		,O_KIDNEYS = /obj/item/organ/internal/kidneys
		)

	/// Wearing clothing (by slots) and body features (like hair) pixel_x/pixel_y offsets
	var/list/offset_features = list(
		OFFSET_UNIFORM = list(0,0),
		OFFSET_ID = list(0,0),
		OFFSET_GLOVES = list(0,0),
		OFFSET_GLASSES = list(0,0),
		OFFSET_EARS = list(0,0),
		OFFSET_SHOES = list(0,0),
		OFFSET_S_STORE = list(0,0),
		OFFSET_FACEMASK = list(0,0),
		OFFSET_HEAD = list(0,0),
		OFFSET_FACE = list(0,0),
		OFFSET_BELT = list(0,0),
		OFFSET_BACK = list(0,0),
		OFFSET_SUIT = list(0,0),
		OFFSET_NECK = list(0,0),
		OFFSET_ACCESSORY = list(0,0),
		OFFSET_HAIR = list(0,0),
	)

	var/list/survival_kit_items = list(/obj/item/clothing/mask/breath,
	                                   /obj/item/weapon/tank/emergency_oxygen,
	                                   /obj/item/weapon/reagent_containers/hypospray/autoinjector
	                                   )

	var/list/prevent_survival_kit_items = list()

	var/list/replace_outfit = list()

	var/min_age = 25 // The default, for Humans.
	var/max_age = 85

	var/list/prohibit_roles

	// What movesets do these species grant.
	var/list/moveset_types

	// Bubble can be changed depending on species
	var/typing_indicator_type = "default"

	// Emotes this species grants.
	var/list/emotes

	// The usual species for the station
	var/is_common = FALSE

	var/default_mood_event

	var/prothesis_icobase = 'icons/mob/human/robotic.dmi'

	var/surgery_icobase = 'icons/mob/surgery.dmi'

/datum/species/New()
	unarmed = new unarmed_type()

	if(!has_organ[O_HEART])
		race_traits += list(TRAIT_NO_BLOOD) // this status also uncaps vital body parts damage, since such species otherwise will be very hard to kill.

/datum/species/proc/can_be_role(role)
	if(!prohibit_roles)
		return TRUE
	return !(role in prohibit_roles)

/datum/species/proc/create_organs(mob/living/carbon/human/H, deleteOld = FALSE) //Handles creation of mob organs.
	if(deleteOld)
		for(var/obj/item/organ/external/BP in H.bodyparts)
			qdel(BP)
		for(var/obj/item/organ/internal/IO in H.organs)
			qdel(IO)

	create_bodyparts(H)

	for(var/type in has_organ)
		var/path = has_organ[type]
		var/obj/item/organ/internal/O = new path(null)
		O.insert_organ(H)

	if(flags[IS_SYNTHETIC])
		for(var/obj/item/organ/internal/IO in H.organs)
			IO.mechanize()

/datum/species/proc/create_bodyparts(mob/living/carbon/human/H)
	for(var/type in has_bodypart)
		var/path = has_bodypart[type]
		var/obj/item/organ/external/O = new path(null)
		O.insert_organ(H, FALSE, src)

/**
  * Replace human clothes in [outfit] on species clothes
  *
  * Called after pre_equip()
  */
/datum/species/proc/species_equip(mob/living/carbon/human/H, datum/outfit/O)
	species_replace_outfit(O, replace_outfit)
	call_species_equip_proc(H, O)
	return

// replaces default outfit (human outfit) on outfit from replace_outfit
/datum/species/proc/species_replace_outfit(datum/outfit/O, list/replace_outfit = null)
	if(replace_outfit.len)
		var/list/outfit_types = list(
			"[SLOT_W_UNIFORM]" = O.uniform,
			"[SLOT_WEAR_SUIT]" = O.suit,
			"[SLOT_BACK]" = O.back,
			"[SLOT_BELT]" = O.belt,
			"[SLOT_GLOVES]" = O.gloves,
			"[SLOT_SHOES]" = O.shoes,
			"[SLOT_HEAD]" = O.head,
			"[SLOT_WEAR_MASK]" = O.mask,
			"[SLOT_NECK]" = O.neck,
			"[SLOT_L_EAR]" = O.l_ear,
			"[SLOT_R_EAR]" = O.r_ear,
			"[SLOT_GLASSES]" = O.glasses
			)
		for(var/I in outfit_types)
			if(replace_outfit[outfit_types[I]])
				O.change_slot_equip(text2num(I), replace_outfit[outfit_types[I]])

/datum/species/proc/call_species_equip_proc(mob/living/carbon/human/H, datum/outfit/O)
	return

/datum/species/proc/handle_post_spawn(mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	return

/datum/species/proc/on_gain(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)

	if(default_skin_color)
		H.r_skin = HEX_VAL_RED(default_skin_color)
		H.g_skin = HEX_VAL_GREEN(default_skin_color)
		H.b_skin = HEX_VAL_BLUE(default_skin_color)
	else
		H.r_skin = initial(H.r_belly)
		H.g_skin = initial(H.g_belly)
		H.b_skin = initial(H.b_belly)

	if(default_eyes_color)
		H.r_eyes = HEX_VAL_RED(default_eyes_color)
		H.g_eyes = HEX_VAL_GREEN(default_eyes_color)
		H.b_eyes = HEX_VAL_BLUE(default_eyes_color)

	H.mob_brute_mod.ModMultiplicative(brute_mod, src)
	H.mob_burn_mod.ModMultiplicative(burn_mod, src)
	H.mob_oxy_mod.ModMultiplicative(oxy_mod, src)
	H.mob_tox_mod.ModMultiplicative(tox_mod, src)
	H.mob_clone_mod.ModMultiplicative(clone_mod, src)
	H.mob_brain_mod.ModMultiplicative(brain_mod, src)

	H.mob_metabolism_mod.ModMultiplicative(metabolism_mod, src)

	if(flags[NO_GENDERS])
		H.gender = NEUTER

	for(var/moveset in moveset_types)
		H.add_moveset(new moveset(), MOVESET_SPECIES)

	for(var/emote in emotes)
		var/datum/emote/E = global.all_emotes[emote]
		H.set_emote(E.key, E)

	H.inhale_gas = inhale_type
	H.exhale_gas = exhale_type
	H.poison_gas = poison_type

	if(race_ability)
		var/datum/action/A = new race_ability(H)
		A.Grant(H)
	H.verbs += race_verbs
	for(var/trait in race_traits)
		ADD_TRAIT(H, trait, SPECIES_TRAIT)

	SEND_SIGNAL(H, COMSIG_SPECIES_GAIN, src)

	if(default_mood_event)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "species", default_mood_event)

/datum/species/proc/on_loose(mob/living/carbon/human/H, new_species)
	SHOULD_CALL_PARENT(TRUE)

	H.mob_brute_mod.RemoveMods(src)
	H.mob_burn_mod.RemoveMods(src)
	H.mob_oxy_mod.RemoveMods(src)
	H.mob_tox_mod.RemoveMods(src)
	H.mob_clone_mod.RemoveMods(src)
	H.mob_brain_mod.RemoveMods(src)

	H.mob_metabolism_mod.RemoveMods(src)

	if(!flags[IS_SOCIAL])
		H.handle_socialization()

	H.remove_moveset_source(MOVESET_SPECIES)

	for(var/emote in emotes)
		H.clear_emote(emote)

	if(race_ability)
		var/datum/action/A = locate(race_ability) in H.actions
		qdel(A)
	H.verbs -= race_verbs
	for(var/trait in race_traits)
		REMOVE_TRAIT(H, trait, SPECIES_TRAIT)

	SEND_SIGNAL(H, COMSIG_SPECIES_LOSS, src, new_species)
	SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "species")

// for unique species behavior like regen
// called for not dead mob from humans/life()
/datum/species/proc/on_mob_life(mob/living/carbon/human/H)
	return

/datum/species/proc/handle_death(mob/living/carbon/human/H, gibbed) //Handles any species-specific death events (such nymph spawns).
	var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
	if(!IO)
		return
	IO.heart_stop()
	return

/datum/species/proc/before_job_equip(mob/living/carbon/human/H, datum/job/J, visualsOnly = FALSE) // Do we really need this proc? Perhaps.
	return

/datum/species/proc/after_job_equip(mob/living/carbon/human/H, datum/job/J, visualsOnly = FALSE)
	return

// For species who's skin acts as a spacesuit of sorts
// Return a value from 0 to 1, where 1 is full protection, and 0 is full weakness
/datum/species/proc/get_pressure_protection(mob/living/carbon/human/H)
	return 0

/datum/species/human
	name = HUMAN
	icobase = 'icons/mob/human/human.dmi'
	deformed = 'icons/mob/human/human_deformed.dmi'
	skeleton = 'icons/mob/human/human_skeleton.dmi'
	eyes_colorable_layer = "human_colorable"
	eyes_static_layer = "human"
	gender_limb_icons = TRUE
	fat_limb_icons = TRUE

	language = LANGUAGE_SOLCOMMON
	primitive = /mob/living/carbon/monkey
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = DIET_OMNI

	flags = list(
	 HAS_SKIN_TONE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_HAIR = TRUE
	,HAS_MUSCLES = TRUE
	,FACEHUGGABLE = TRUE
	,HAS_HAIR_COLOR = TRUE
	,IS_SOCIAL = TRUE
	)

	min_age = 25
	max_age = 85

	is_common = TRUE

/datum/species/pluvian
	name = PLUVIAN
	icobase = 'icons/mob/human/pluvian.dmi'
	deformed = null
	skeleton = 'icons/mob/human/human_skeleton.dmi' // same skeleton as humans
	eyes_colorable_layer = "pluvian_colorable"
	eyes_static_layer = "pluvian"
	gender_limb_icons = TRUE
	fat_limb_icons = TRUE

	language = LANGUAGE_SOLCOMMON
	primitive = /mob/living/carbon/monkey/pluvian
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = DIET_OMNI
	pluvian_social_credit = 0

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_HAIR = TRUE
	,HAS_MUSCLES = TRUE
	,FACEHUGGABLE = TRUE
	,HAS_HAIR_COLOR = TRUE
	,IS_SOCIAL = TRUE
	)

	min_age = 25
	max_age = 85

	is_common = TRUE

/datum/species/pluvian/on_loose(mob/living/M, new_species)
	if(global.pluvia_religion?.is_member(M)) // skip lobby dummy
		global.pluvia_religion.remove_member(M, HOLY_ROLE_PRIEST)
	..()

/datum/species/pluvian/handle_death(mob/living/carbon/human/H, gibbed)
	..()
	H.pluvian_reborn_if_worthy()

/datum/species/pluvian_spirit
	name = PLUVIAN_SPIRIT
	icobase = 'icons/mob/human/pluvian.dmi'
	deformed = null
	skeleton = null
	eyes_colorable_layer = "pluvian_colorable"
	eyes_static_layer = "pluvian"
	gender_limb_icons = TRUE
	fat_limb_icons = TRUE

	language = LANGUAGE_SOLCOMMON
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = 0
	brute_mod = 0
	burn_mod = 0
	oxy_mod = 0
	tox_mod = 0
	clone_mod = 0
	pluvian_social_credit = 0
	race_traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_NO_FINGERPRINT,
		TRAIT_NO_EMBED,
		TRAIT_NO_MINORCUTS,
		TRAIT_EMOTIONLESS,
		TRAIT_NO_VOMIT,
		TRAIT_NO_BLOOD,
		TRAIT_NEVER_FAT,
		TRAIT_NO_MESSY_GIBS,
		TRAIT_GLOWING_EYES,
		TRAIT_PLUVIAN_BLESSED,
	)
	flags = list(
	,NO_DNA = TRUE
	,HAS_UNDERWEAR = TRUE
	)
	min_age = 25
	max_age = 85

	warning_low_pressure = -1
	hazard_low_pressure = -1

/datum/species/unathi
	name = UNATHI
	icobase = 'icons/mob/human/unathi.dmi'
	deformed = 'icons/mob/human/unathi_deformed.dmi'
	skeleton = 'icons/mob/human/unathi_skeleton.dmi'
	eyes_colorable_layer = "unathi_colorable"
	eyes_static_layer = "unathi"
	second_color_mask = TRUE
	gender_tail_icons = TRUE
	gender_limb_icons = TRUE
	fat_limb_icons = TRUE

	language = LANGUAGE_SINTAUNATHI
	unarmed_type = /datum/unarmed_attack/claws
	race_verbs = list(/mob/living/carbon/human/proc/air_sample)
	dietflags = DIET_MEAT | DIET_DAIRY
	primitive = /mob/living/carbon/monkey/unathi
	darksight = 3

	cold_level_1 = BODYTEMP_COLD_DAMAGE_LIMIT + 20
	cold_level_2 = BODYTEMP_COLD_DAMAGE_LIMIT + 15
	cold_level_3 = BODYTEMP_COLD_DAMAGE_LIMIT + 13

	heat_level_1 = BODYTEMP_HEAT_DAMAGE_LIMIT + 60
	heat_level_2 = BODYTEMP_HEAT_DAMAGE_LIMIT + 120
	heat_level_3 = BODYTEMP_HEAT_DAMAGE_LIMIT + 740

	brute_mod = 0.80
	burn_mod = 0.90
	speed_mod = 0.7

	race_traits = list(
		TRAIT_NO_MINORCUTS,
	)

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_TAIL = TRUE
	,HAS_SKIN_COLOR = TRUE
	,HAS_HAIR_COLOR = TRUE
	,HAS_MUSCLES = TRUE
	,FACEHUGGABLE = TRUE
	,IS_SOCIAL = TRUE
	)

	flesh_color = "#34af10"
	default_skin_color = "#06aa00"
	default_eyes_color = "#ffc800"

	min_age = 25
	max_age = 85

	is_common = TRUE

	sprite_sheets = list(
		SPRITE_SHEET_HEAD     = 'icons/mob/species/unathi/helmet.dmi',
		SPRITE_SHEET_SUIT     = 'icons/mob/species/unathi/suit.dmi',
		SPRITE_SHEET_SUIT_FAT = 'icons/mob/species/unathi/suit_fat.dmi'
	)

/datum/species/unathi/New()
	. = ..()
	has_organ += list(BP_TAIL = /obj/item/organ/external/tail)

/datum/species/unathi/call_species_equip_proc(mob/living/carbon/human/H, datum/outfit/O)
	return O.unathi_equip(H)

/datum/species/unathi/on_gain(mob/living/carbon/human/H)
	..()

	if(default_skin_color) // move it to the parent on_gain() if there will be any other species with the second color set
		var/second_color = color_shift_luminance(default_skin_color, -5)
		H.r_belly = HEX_VAL_RED(second_color)
		H.g_belly = HEX_VAL_GREEN(second_color)
		H.b_belly = HEX_VAL_BLUE(second_color)
	else
		H.r_belly = initial(H.r_belly)
		H.g_belly = initial(H.g_belly)
		H.b_belly = initial(H.b_belly)

/datum/species/tajaran
	name = TAJARAN
	icobase = 'icons/mob/human/tajaran.dmi'
	deformed = 'icons/mob/human/tajaran_deformed.dmi'
	skeleton = 'icons/mob/human/tajaran_skeleton.dmi'
	eyes_colorable_layer = "tajaran_colorable"
	eyes_static_layer = "tajaran"
	gender_limb_icons = TRUE
	fat_limb_icons = TRUE
	gender_tail_icons = TRUE

	language = LANGUAGE_SIIKMAAS
	additional_languages = list(LANGUAGE_SIIKTAJR = LANGUAGE_NATIVE)
	unarmed_type = /datum/unarmed_attack/claws
	dietflags = DIET_OMNI
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	darksight = 8

	breath_cold_level_1 = BODYTEMP_COLD_DAMAGE_LIMIT - 40
	breath_cold_level_2 = BODYTEMP_COLD_DAMAGE_LIMIT - 50
	breath_cold_level_3 = BODYTEMP_COLD_DAMAGE_LIMIT - 60

	cold_level_1 = BODYTEMP_COLD_DAMAGE_LIMIT - 20
	cold_level_2 = BODYTEMP_COLD_DAMAGE_LIMIT - 40
	cold_level_3 = BODYTEMP_COLD_DAMAGE_LIMIT - 60

	heat_level_1 = BODYTEMP_HEAT_DAMAGE_LIMIT - 30
	heat_level_2 = BODYTEMP_HEAT_DAMAGE_LIMIT + 20
	heat_level_3 = BODYTEMP_HEAT_DAMAGE_LIMIT + 440

	primitive = /mob/living/carbon/monkey/tajara

	brute_mod = 1.20
	burn_mod = 1.20
	speed_mod = -0.7

	race_traits = list(
		TRAIT_NATURAL_AGILITY,
		TRAIT_NIGHT_EYES,
	)

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_TAIL = TRUE
	,HAS_SKIN_COLOR = TRUE
	,HAS_HAIR_COLOR = TRUE
	,HAS_HAIR = TRUE
	,HAS_MUSCLES = TRUE
	,FACEHUGGABLE = TRUE
	,IS_SOCIAL = TRUE
	,FUR = TRUE
	)

	flesh_color = "#afa59e"
	default_skin_color = "#bbbbbb"
	default_eyes_color = "#1ec81e"

	min_age = 25
	max_age = 85

	is_common = TRUE

	sprite_sheets = list(
		SPRITE_SHEET_HEAD     = 'icons/mob/species/tajaran/helmet.dmi',
		SPRITE_SHEET_SUIT     = 'icons/mob/species/tajaran/suit.dmi',
		SPRITE_SHEET_SUIT_FAT = 'icons/mob/species/tajaran/suit_fat.dmi'
	)

/datum/species/tajaran/New()
	. = ..()
	has_organ += list(BP_TAIL = /obj/item/organ/external/tail)

/datum/species/tajaran/call_species_equip_proc(mob/living/carbon/human/H, datum/outfit/O)
	return O.tajaran_equip(H)

/datum/species/skrell
	name = SKRELL
	icobase = 'icons/mob/human/skrell.dmi'
	deformed = 'icons/mob/human/skrell_deformed.dmi'
	skeleton = 'icons/mob/human/skrell_skeleton.dmi'
	eyes_colorable_layer = null
	eyes_static_layer = "skrell"
	gender_body_icons = FALSE
	fat_limb_icons = TRUE

	language = LANGUAGE_SKRELLIAN
	primitive = /mob/living/carbon/monkey/skrell
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = DIET_PLANT
	taste_sensitivity = TASTE_SENSITIVITY_DULL

	siemens_coefficient = 1.3 // Because they are wet and slimy.

	speed_mod = 1.5
	speed_mod_no_shoes = -2.2

	race_traits = list(
		TRAIT_NO_MINORCUTS,
	)

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_SKIN_COLOR = TRUE
	,FACEHUGGABLE = TRUE
	,HAS_HAIR_COLOR = TRUE
	,HAS_MUSCLES = TRUE
	,IS_SOCIAL = TRUE
	)

	has_organ = list(
		O_HEART   = /obj/item/organ/internal/heart,
		O_BRAIN   = /obj/item/organ/internal/brain,
		O_EYES    = /obj/item/organ/internal/eyes,
		O_LUNGS   = /obj/item/organ/internal/lungs/skrell,
		O_LIVER   = /obj/item/organ/internal/liver,
		O_KIDNEYS = /obj/item/organ/internal/kidneys
		)

	blood_datum_path = /datum/dirt_cover/purple_blood
	flesh_color = "#8cd7a3"

	min_age = 25
	max_age = 150

	is_common = TRUE

	sprite_sheets = list(
		SPRITE_SHEET_HEAD = 'icons/mob/species/skrell/helmet.dmi',
		SPRITE_SHEET_SUIT = 'icons/mob/species/skrell/suit.dmi'
	)

/datum/species/skrell/call_species_equip_proc(mob/living/carbon/human/H, datum/outfit/O)
	return O.skrell_equip(H)

/datum/species/vox
	name = VOX
	icobase = 'icons/mob/human/vox.dmi'
	deformed = 'icons/mob/human/vox_deformed.dmi'
	skeleton = 'icons/mob/human/vox_skeleton.dmi'
	eyes_colorable_layer = "vox_colorable"
	eyes_static_layer = null

	language = LANGUAGE_VOXPIDGIN
	additional_languages = list(LANGUAGE_TRADEBAND = LANGUAGE_CAN_SPEAK)
	gender_body_icons = FALSE
	surgery_icobase = 'icons/mob/species/vox/surgery.dmi'

	species_common_language = TRUE
	unarmed_type = /datum/unarmed_attack/claws	//I dont think it will hurt to give vox claws too.
	race_ability = /datum/action/innate/race/leap
	dietflags = DIET_OMNI

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	breath_cold_level_1 = 80
	breath_cold_level_2 = 50
	breath_cold_level_3 = 0

	inhale_type = "nitrogen"
	poison_type = "oxygen"

	race_traits = list(
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NEVER_FAT,
	)

	flags = list(
		IS_WHITELISTED = TRUE
		,FACEHUGGABLE = TRUE
		,HAS_TAIL = TRUE
		,HAS_HAIR_COLOR = TRUE
		,HAS_MUSCLES = TRUE
		,IS_SOCIAL = TRUE
		,NO_GENDERS = TRUE
	)
	has_organ = list(
		O_HEART   = /obj/item/organ/internal/heart/vox,
		O_BRAIN   = /obj/item/organ/internal/brain,
		O_EYES    = /obj/item/organ/internal/eyes,
		O_LUNGS   = /obj/item/organ/internal/lungs/vox,
		O_LIVER   = /obj/item/organ/internal/liver/vox,
		O_KIDNEYS = /obj/item/organ/internal/kidneys/vox
		)

	blood_datum_path = /datum/dirt_cover/blue_blood
	flesh_color = "#808d11"

	sprite_sheets = list(
		// SPRITE_SHEET_HELD = 'icons/mob/species/vox/held.dmi',
		SPRITE_SHEET_UNIFORM = 'icons/mob/species/vox/uniform.dmi',
		SPRITE_SHEET_SUIT = 'icons/mob/species/vox/suit.dmi',
		SPRITE_SHEET_BELT = 'icons/mob/belt.dmi',
		SPRITE_SHEET_HEAD = 'icons/mob/species/vox/helmet.dmi',
		SPRITE_SHEET_MASK = 'icons/mob/species/vox/masks.dmi',
		SPRITE_SHEET_EYES = 'icons/mob/species/vox/eyes.dmi',
		SPRITE_SHEET_FEET = 'icons/mob/species/vox/shoes.dmi',
		SPRITE_SHEET_GLOVES = 'icons/mob/species/vox/gloves.dmi',
		SPRITE_SHEET_BACK = 'icons/mob/species/vox/back.dmi'
		)

	survival_kit_items = list(
		/obj/item/weapon/tank/emergency_nitrogen,
		/obj/item/weapon/reagent_containers/syringe/nutriment,
	)

	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen) // So they don't get the big engi oxy tank, since they need no tank.

	min_age = 1
	max_age = 100

	is_common = TRUE

	prohibit_roles = list(ROLE_CHANGELING, ROLE_WIZARD)

	replace_outfit = list(
			/obj/item/clothing/mask/gas/syndicate = /obj/item/clothing/mask/gas/vox,
			)

	prothesis_icobase = 'icons/mob/human/robotic_vox.dmi'

/datum/species/vox/New()
	. = ..()
	has_organ += list(BP_TAIL = /obj/item/organ/external/tail)

/datum/species/vox/after_job_equip(mob/living/carbon/human/H, datum/job/J, visualsOnly = FALSE)
	..()

	if(H.wear_mask)
		qdel(H.wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/vox(src), SLOT_WEAR_MASK)

/datum/species/vox/call_species_equip_proc(mob/living/carbon/human/H, datum/outfit/O)
	return O.vox_equip(H)

// At 25 damage - no protection at all.
/datum/species/vox/get_pressure_protection(mob/living/carbon/human/H)
	var/damage = 0
	var/static/list/cavity_parts = list(BP_HEAD, BP_CHEST, BP_GROIN)
	for(var/bodypart in cavity_parts)
		var/obj/item/organ/external/BP = H.get_bodypart(bodypart)
		if(!BP)
			// We surely are not hermetized.
			damage += 100
			continue

		damage += BP.brute_dam + BP.burn_dam

	return 1 - CLAMP01(damage / 25)


/datum/species/vox/armalis
	name = VOX_ARMALIS
	icobase = 'icons/mob/human/armalis.dmi'
	deformed = null
	skeleton = null
	eyes_colorable_layer = null // eyes part of the head sprite
	eyes_static_layer = null

	damage_mask = FALSE
	language = LANGUAGE_VOXPIDGIN
	unarmed_type = /datum/unarmed_attack/claws/armalis
	race_ability = null
	race_verbs = list(/mob/living/carbon/human/proc/gut)
	dietflags = DIET_OMNI	//should inherit this from vox, this is here just in case

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	breath_cold_level_1 = 80
	breath_cold_level_2 = 50
	breath_cold_level_3 = 0

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	brute_mod = 0.2
	burn_mod = 0.2

	inhale_type = "nitrogen"
	poison_type = "oxygen"

	is_common = TRUE

	race_traits = list(
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_NO_BLOOD,
		TRAIT_NEVER_FAT,
	)

	flags = list(
	,HAS_TAIL = TRUE
	,IS_SOCIAL = TRUE
	,NO_GENDERS = TRUE
	)

	blood_datum_path = /datum/dirt_cover/blue_blood
	flesh_color = "#808d11"

	sprite_sheets = list(
		SPRITE_SHEET_SUIT = 'icons/mob/species/armalis/suit.dmi',
		SPRITE_SHEET_GLOVES = 'icons/mob/species/armalis/gloves.dmi',
		SPRITE_SHEET_FEET = 'icons/mob/species/armalis/feet.dmi',
		SPRITE_SHEET_HEAD = 'icons/mob/species/armalis/head.dmi',
		SPRITE_SHEET_HELD = 'icons/mob/species/armalis/held.dmi'
		)

	gender_body_icons = TRUE

/datum/species/diona
	name = DIONA
	icobase = 'icons/mob/human/diona.dmi'
	deformed = 'icons/mob/human/diona_deformed.dmi'
	skeleton = null
	eyes_colorable_layer = "default"
	eyes_static_layer = null

	language = LANGUAGE_ROOTSPEAK
	unarmed_type = /datum/unarmed_attack/diona
	dietflags = 0		//Diona regenerate nutrition in light, no diet necessary
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	primitive = /mob/living/carbon/monkey/diona
	pluvian_social_credit = 3

	siemens_coefficient = 0.5 // Because they are plants and stuff.

	hazard_low_pressure = DIONA_HAZARD_LOW_PRESSURE

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	breath_cold_level_1 = 50
	breath_cold_level_2 = -1
	breath_cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	burn_mod = 1.3
	oxy_mod = 0
	speed_mod = 7
	speed_mod_no_shoes = -2

	// restricted_inventory_slots = list(SLOT_WEAR_MASK, SLOT_GLASSES, SLOT_GLOVES, SLOT_SHOES) // These are trees. Not people. Deal with the fact that they don't have these. P.S. I may return to this one day ~Luduk.

	body_temperature = T0C + 15		//make the plant people have a bit lower body temperature, why not
	butcher_drops = list(/obj/item/stack/sheet/wood = 5)
	bodypart_butcher_results = list(/obj/item/stack/sheet/wood = 1)

	race_traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_NO_FINGERPRINT,
		TRAIT_EMOTIONLESS,
		TRAIT_NO_VOMIT,
		TRAIT_NO_BLOOD,
	)

	flags = list(
	 IS_WHITELISTED = TRUE
	,REQUIRE_LIGHT = TRUE
	,IS_PLANT = TRUE
	,RAD_ABSORB = TRUE
	,IS_SOCIAL = TRUE
	,NO_GENDERS = TRUE
	)

	has_bodypart = list(
		 BP_CHEST  = /obj/item/organ/external/chest
		,BP_GROIN  = /obj/item/organ/external/groin
		,BP_HEAD   = /obj/item/organ/external/head/diona
		,BP_L_ARM  = /obj/item/organ/external/l_arm/diona
		,BP_R_ARM  = /obj/item/organ/external/r_arm/diona
		,BP_L_LEG  = /obj/item/organ/external/l_leg/diona
		,BP_R_LEG  = /obj/item/organ/external/r_leg/diona
		)

	has_organ = list(
		O_HEART   = /obj/item/organ/internal/heart,
		O_BRAIN   = /obj/item/organ/internal/brain/diona,
		O_EYES    = /obj/item/organ/internal/eyes,
		O_LUNGS   = /obj/item/organ/internal/lungs/diona,
		O_LIVER   = /obj/item/organ/internal/liver/diona,
		O_KIDNEYS = /obj/item/organ/internal/kidneys/diona
		)

	blood_datum_path = /datum/dirt_cover/green_blood
	flesh_color = "#907e4a"

	gender_body_icons = FALSE

	survival_kit_items = list(/obj/item/device/flashlight/flare,
	                          /obj/item/device/plant_analyzer
	                          )

	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen) // So they don't get the big engi oxy tank, since they need no tank.

	min_age = 1
	max_age = 1000

	is_common = TRUE

	prohibit_roles = list(ROLE_CHANGELING, ROLE_CULTIST)

	// How fast do they regenerate. Podmen regenerate 50% slower.
	var/regen_mod = 1.0
	// Podmen don't.
	var/regen_limbs = TRUE
	var/list/signature_plant = list(
		/obj/structure/flora/ausbushes/genericbush,
		/obj/structure/flora/ausbushes/grassybush,
		/obj/structure/flora/ausbushes/pointybush,
		/obj/structure/flora/junglebush/b,
		/obj/item/weapon/flora/floorleaf,
		/obj/item/weapon/flora/pottedplant/aquatic,
		/obj/item/weapon/flora/pottedplant/decorative,
		/obj/item/weapon/flora/pottedplant/ficus,
		/obj/item/weapon/flora/pottedplant/minitree,
		/obj/item/weapon/flora/pottedplant/palm,
		/obj/item/weapon/flora/pottedplant/stoutbush,
		/obj/item/weapon/flora/pottedplant/thinbush,
		/obj/item/weapon/flora/pottedplant/tropical_2)

/datum/species/diona/on_gain(mob/living/carbon/human/H)
	..()
	// initialize hud_list for alt_appearance
	H.prepare_huds()
	var/obj/signature_obj = pick(signature_plant)
	var/image/I = image(signature_obj.icon, H, signature_obj.icon_state)
	I.override = 1
	H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/xenomorphs, "DIONA_xeno", I, null, null, NONE)
	H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/zombies, "DIONA_zombie", I, null, null, NONE)

/datum/species/diona/on_loose(mob/living/carbon/human/H, new_species)
	H.remove_alt_appearance("DIONA_xeno")
	H.remove_alt_appearance("DIONA_zombie")
	..()

/datum/species/diona/on_mob_life(mob/living/carbon/human/H)
	// todo: should this use mob metabolism modval?

	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = round(10 * T.get_lumcount() - 5)

	if(H.is_type_organ(O_LIVER, /obj/item/organ/internal/liver/diona) && !H.is_bruised_organ(O_LIVER)) // Specie may require light, but only plants, with chlorophyllic plasts can produce nutrition out of light!
		H.nutrition += light_amount

	if(H.is_type_organ(O_KIDNEYS, /obj/item/organ/internal/kidneys/diona)) // Diona's kidneys contain all the nutritious elements. Damaging them means they aren't held.
		var/obj/item/organ/internal/kidneys/KS = H.organs_by_name[O_KIDNEYS]
		if(!KS)
			H.nutrition = 0
		else if(H.nutrition > (500 - KS.damage*5))
			H.nutrition = 500 - KS.damage*5

	if(light_amount >= 5) // If you can regen organs - do so.
		for(var/obj/item/organ/internal/O in H.organs)
			if(O.damage)
				O.damage = max(0, O.damage - light_amount * regen_mod / 5)
				H.nutrition -= light_amount
				return

	if(H.nutrition > 350 && light_amount >= 4 && regen_limbs) // If you don't need to regen organs, regen bodyparts.
		if(!H.regenerating_bodypart) // If there is none currently, go ahead, find it.
			H.regenerating_bodypart = H.find_damaged_bodypart()
		if(H.regenerating_bodypart) // If it did find one.
			H.nutrition -= 1
			H.regen_bodyparts(0, TRUE)
			return

	if(light_amount >= 3) // If you don't need to regen bodyparts, fix up small things.
		H.adjustBruteLoss(-(light_amount * regen_mod))

/datum/species/diona/handle_death(mob/living/carbon/human/H, gibbed)
	var/mob/living/carbon/monkey/diona/S = new(get_turf(H))
	S.real_name = H.real_name
	S.name = S.real_name

	S.dna = H.dna.Clone()
	S.dna.SetSEState(MONKEYBLOCK, 1)
	S.dna.SetSEValueRange(MONKEYBLOCK, 0xDAC, 0xFFF)

	if(H.mind)
		H.mind.transfer_to(S)

	for(var/datum/language/L as anything in H.languages)
		S.add_language(L.name, H.languages[L])

	for(var/datum/quirk/Q in H.roundstart_quirks)
		S.saved_quirks += Q.type

	for(var/mob/living/carbon/monkey/diona/D in H.contents)
		D.splitting(H)

	H.visible_message("<span class='warning'>[H] splits apart with a wet slithering noise!</span>")

/datum/species/diona/podman
	name = PODMAN
	icobase = 'icons/mob/human/podman.dmi'
	deformed = 'icons/mob/human/diona_deformed.dmi'
	skeleton = null
	eyes_colorable_layer = "default"
	eyes_static_layer = null

	language = "Rootspeak"
	unarmed_type = /datum/unarmed_attack/diona/podman
	primitive = /mob/living/carbon/monkey/diona/podman
	pluvian_social_credit = 0 // too young to vote

	// Because they are less thicc than dionaea.
	siemens_coefficient = 0.75

	brute_mod = 1.3
	burn_mod = 1.3
	speed_mod = 2.7
	speed_mod_no_shoes = -2

	race_traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_NO_VOMIT,
		TRAIT_NO_BLOOD,
	)

	flags = list(
	 IS_WHITELISTED = TRUE
	,REQUIRE_LIGHT = TRUE
	,IS_PLANT = TRUE
	,RAD_ABSORB = TRUE
	,HAS_LIPS = TRUE
	,HAS_HAIR = TRUE
	,IS_SOCIAL = TRUE
	,NO_GENDERS = TRUE
	)

	has_bodypart = list(
		 BP_CHEST  = /obj/item/organ/external/chest
		,BP_GROIN  = /obj/item/organ/external/groin
		,BP_HEAD   = /obj/item/organ/external/head/podman
		,BP_L_ARM  = /obj/item/organ/external/l_arm/diona/podman
		,BP_R_ARM  = /obj/item/organ/external/r_arm/diona/podman
		,BP_L_LEG  = /obj/item/organ/external/l_leg/diona/podman
		,BP_R_LEG  = /obj/item/organ/external/r_leg/diona/podman
		)

	has_organ = list(
		O_HEART   = /obj/item/organ/internal/heart,
		O_BRAIN   = /obj/item/organ/internal/brain,
		O_EYES    = /obj/item/organ/internal/eyes,
		O_LUNGS   = /obj/item/organ/internal/lungs/diona,
		O_LIVER   = /obj/item/organ/internal/liver/diona,
		O_KIDNEYS = /obj/item/organ/internal/kidneys/diona
		)

	regen_mod = 0.5
	regen_limbs = FALSE

/datum/species/diona/podman/on_gain(mob/living/carbon/human/H)
	. = ..()
	H.AddComponent(/datum/component/logout_spawner, /datum/spawner/living/podman)

/datum/species/diona/podman/on_loose(mob/living/carbon/human/H)
	var/datum/component/component = H.GetComponent(/datum/component/logout_spawner)
	qdel(component)
	return ..()

/datum/species/diona/podman/handle_death(mob/living/carbon/human/H, gibbed)
	H.visible_message("<span class='warning'>[H] splits apart with a wet slithering noise!</span>")

/datum/species/machine
	name = IPC
	icobase = 'icons/mob/human/machine.dmi'
	deformed = null
	skeleton = null
	alpha_color_mask = TRUE
	eyes_colorable_layer = null
	eyes_static_layer = null

	language = LANGUAGE_TRINARY
	unarmed_type = /datum/unarmed_attack/punch
	race_verbs = list(
		/mob/living/carbon/human/proc/IPC_change_screen,
		/mob/living/carbon/human/proc/IPC_toggle_screen,
		/mob/living/carbon/human/proc/IPC_display_text)
	dietflags = 0		//IPCs can't eat, so no diet
	pluvian_social_credit = 0 // have no soul
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	surgery_icobase = 'icons/mob/species/ipc/surgery.dmi'
	eyes_colorable_layer = null

	warning_low_pressure = 50
	hazard_low_pressure = 0

	metabolism_mod = 0 // no metabolism for robots

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	breath_cold_level_1 = 50
	breath_cold_level_2 = -1
	breath_cold_level_3 = -1

	heat_level_1 = 400		//gives them about 25 seconds in space before taking damage
	heat_level_2 = 1000
	heat_level_3 = 2000

	// This should cause IPCs to stabilize at ~52 C in a 20 C environment with fully functional cooling system
	synth_temp_gain = 10
	// IPCs heat up until ~306C. No more 2000C IPCs
	synth_temp_max = 550

	brute_mod = 1.5
	burn_mod = 1
	oxy_mod = 0
	tox_mod = 0
	clone_mod = 0

	siemens_coefficient = 1.3 // ROBUTT.

	butcher_drops = list(/obj/item/stack/sheet/plasteel = 3)

	race_traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_NO_FINGERPRINT,
		TRAIT_NO_MINORCUTS,
		TRAIT_EMOTIONLESS,
		TRAIT_NO_VOMIT,
		TRAIT_NO_BLOOD,
	)

	flags = list(
	 IS_WHITELISTED = TRUE
	,NO_DNA = TRUE
	,HAS_HAIR_COLOR = TRUE
	,IS_SYNTHETIC = TRUE
	,HAS_SKIN_COLOR = TRUE
	,IS_SOCIAL = TRUE
	,NO_GENDERS = TRUE
	,NO_WILLPOWER = TRUE
	)

	has_bodypart = list(
		 BP_CHEST  = /obj/item/organ/external/chest/robot/ipc
		,BP_GROIN  = /obj/item/organ/external/groin/robot/ipc
		,BP_HEAD   = /obj/item/organ/external/head/robot/ipc
		,BP_L_ARM  = /obj/item/organ/external/l_arm/robot/ipc
		,BP_R_ARM  = /obj/item/organ/external/r_arm/robot/ipc
		,BP_L_LEG  = /obj/item/organ/external/l_leg/robot/ipc
		,BP_R_LEG  = /obj/item/organ/external/r_leg/robot/ipc
		)

	has_organ = list(
		 O_HEART   = /obj/item/organ/internal/heart/ipc
		,O_BRAIN   = /obj/item/organ/internal/brain/ipc
		,O_EYES    = /obj/item/organ/internal/eyes/ipc
		,O_LUNGS   = /obj/item/organ/internal/lungs/ipc
		,O_LIVER   = /obj/item/organ/internal/liver/ipc
		,O_KIDNEYS = /obj/item/organ/internal/kidneys/ipc
		)

	blood_datum_path = /datum/dirt_cover/oil
	flesh_color = "#575757"

	survival_kit_items = list(/obj/item/device/suit_cooling_unit/miniature,
	                          /obj/item/stack/nanopaste
	                          )

	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen) // So they don't get the big engi oxy tank, since they need no tank.

	min_age = 1
	max_age = 50

	is_common = TRUE

	prohibit_roles = list(ROLE_CHANGELING, ROLE_SHADOWLING, ROLE_CULTIST)

	emotes = list(
		/datum/emote/robot/beep,
		/datum/emote/robot/ping,
		/datum/emote/robot/buzz,
	)

	default_mood_event = /datum/mood_event/machine

	var/list/signature_machinery = list(
		/obj/machinery/pdapainter,
		/obj/machinery/computer/security/wooden_tv/miami,
		/obj/machinery/message_server,
		/obj/machinery/blackbox_recorder,
		/obj/machinery/vending/cigarette,
		/obj/machinery/kitchen_machine/microwave,
		/obj/machinery/kitchen_machine/oven,
		/obj/machinery/media/jukebox,
		/obj/machinery/washing_machine,
		/obj/machinery/telecomms/relay,
		/obj/machinery/portable_atmospherics/powered/pump,
		/obj/machinery/chem_master)

/datum/species/machine/on_gain(mob/living/carbon/human/H)
	..()
	var/obj/item/organ/external/head/robot/ipc/BP = H.bodyparts_by_name[BP_HEAD]
	if(BP)
		H.set_light(BP.screen_brightness)

	// initialize hud_list for alt_appearance
	H.prepare_huds()
	var/obj/signature_obj = pick(signature_machinery)
	var/image/I = image(signature_obj.icon, H, signature_obj.icon_state)
	I.override = 1
	H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/xenomorphs, "IPC_xeno", I, null, null, NONE)
	H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/zombies, "IPC_zombie", I, null, null, NONE)

/datum/species/machine/on_loose(mob/living/carbon/human/H, new_species)
	var/obj/item/organ/external/head/robot/ipc/BP = H.bodyparts_by_name[BP_HEAD]
	if(BP && BP.screen_toggle)
		H.set_light(0)

	H.remove_alt_appearance("IPC_xeno")
	H.remove_alt_appearance("IPC_zombie")
	..()

/datum/species/machine/handle_death(mob/living/carbon/human/H, gibbed)
	var/obj/item/organ/external/head/robot/ipc/BP = H.bodyparts_by_name[BP_HEAD]
	if(BP && BP.screen_toggle)
		H.r_hair = 15
		H.g_hair = 15
		H.b_hair = 15
		H.set_light(0)
		if(BP.ipc_head == "Default")
			H.h_style = /datum/sprite_accessory/hair/ipc_screen_off::name
		H.update_body(BP_HEAD, update_preferences = TRUE)

/datum/species/abductor
	name = ABDUCTOR
	icobase = 'icons/mob/human/abductor.dmi'
	deformed = null
	skeleton = 'icons/mob/human/human_skeleton.dmi'
	eyes_colorable_layer = null // eyes are part of the head sprite
	eyes_static_layer = null
	gender_body_icons = FALSE

	darksight = 3
	dietflags = DIET_OMNI
	flesh_color = "#808080"

	race_traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_NO_VOMIT,
		TRAIT_NO_BLOOD,
		TRAIT_NEVER_FAT,
	)

	flags = list(
	,NO_GENDERS = TRUE
	)

	blood_datum_path = /datum/dirt_cover/gray_blood

	min_age = 100
	max_age = 500

/datum/species/shadowling
	name = SHADOWLING
	icobase = 'icons/mob/human/shadowling.dmi'
	deformed = null
	skeleton = null
	eyes_colorable_layer = null
	eyes_static_layer = "shadowling"

	language = LANGUAGE_SOLCOMMON
	unarmed_type = /datum/unarmed_attack/claws
	dietflags = DIET_OMNI
	flesh_color = "#ff0000"

	warning_low_pressure = 50
	hazard_low_pressure = -1

	siemens_coefficient = 0 // Spooky shadows don't need to be hurt by your pesky electricity.

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	breath_cold_level_1 = 50
	breath_cold_level_2 = -1
	breath_cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	blood_datum_path = /datum/dirt_cover/black_blood
	darksight = 8

	butcher_drops = list() // They are just shadows. Why should they drop anything?
	bodypart_butcher_results = list()

	restricted_inventory_slots = list(SLOT_BELT, SLOT_WEAR_ID, SLOT_L_EAR, SLOT_R_EAR, SLOT_BACK, SLOT_L_STORE, SLOT_R_STORE)

	has_organ = list(O_HEART = /obj/item/organ/internal/heart) // A huge buff to be honest.

	race_traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_NO_FINGERPRINT,
		TRAIT_NO_EMBED,
		TRAIT_NO_MINORCUTS,
		TRAIT_EMOTIONLESS,
		TRAIT_NO_VOMIT,
		TRAIT_NO_BLOOD,
		TRAIT_GLOWING_EYES,
	)

	flags = list(
	,NO_GENDERS = TRUE
	)

	burn_mod = 2
	brain_mod = 0

	gender_body_icons = FALSE

	min_age = 1
	max_age = 10000

/datum/species/shadowling/on_mob_life(mob/living/carbon/human/H)
	H.nutrition = NUTRITION_LEVEL_NORMAL //i aint never get hongry

	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = round(10 * T.get_lumcount())

	if(light_amount > LIGHT_DAM_THRESHOLD)
		H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN)
		to_chat(H, "<span class='userdanger'>The light burns you!</span>")
		H.playsound_local(null, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	else if(light_amount < LIGHT_HEAL_THRESHOLD) //heal in the dark
		H.heal_overall_damage(5, 5)
		H.adjustToxLoss(-3)
		H.adjustBrainLoss(-25) //gibbering shadowlings are hilarious but also bad to have
		H.adjustCloneLoss(-1)
		H.adjustOxyLoss(-10)
		H.SetWeakened(0)
		H.SetStunned(0)

/datum/species/golem
	name = GOLEM
	icobase = 'icons/mob/human/golem.dmi'
	deformed = null
	skeleton = null
	eyes_colorable_layer = "default"
	eyes_static_layer = null

	dietflags = 0 //this is ROCK

	total_health = 100
	oxy_mod = 0
	tox_mod = 0
	brain_mod = 0
	speed_mod = 2

	metabolism_mod = 0

	blood_datum_path = /datum/dirt_cover/adamant_blood
	flesh_color = "#137e8f"

	butcher_drops = list(/obj/item/weapon/ore/diamond = 1, /obj/item/weapon/ore/slag = 3)
	bodypart_butcher_results = list(/obj/item/weapon/ore/slag = 1)

	pluvian_social_credit = 0

	race_traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_NO_FINGERPRINT,
		TRAIT_NO_EMBED,
		TRAIT_NO_MINORCUTS,
		TRAIT_EMOTIONLESS,
		TRAIT_NO_VOMIT,
		TRAIT_NO_BLOOD,
		TRAIT_NEVER_FAT,
	)

	flags = list(
		NO_DNA = TRUE,
		IS_SOCIAL = TRUE,
		NO_GENDERS = TRUE,
		NO_WILLPOWER = TRUE
		)

	has_organ = list(
		O_BRAIN = /obj/item/organ/internal/brain
		)

	gender_body_icons = FALSE

	min_age = 1
	max_age = 1000

	is_common = TRUE

	default_mood_event = /datum/mood_event/golem

/datum/species/golem/on_gain(mob/living/carbon/human/H)
	..()
	// Clothing on the Golem is created before the hud_list is generated in the atom
	H.prepare_huds()

	H.remove_status_flags(CANSTUN|CANWEAKEN|CANPARALYSE)
	H.real_name = text("Adamantine Golem ([rand(1, 1000)])")

	var/list/items_to_remove = H.get_all_slots()

	for(var/x in items_to_remove)
		if(x)
			H.remove_from_mob(x)

	H.equip_to_slot_or_del(new /obj/item/clothing/under/golem, SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/golem, SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/golem, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/golem, SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/golem, SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/golem, SLOT_GLOVES)

	for(var/x in items_to_remove)
		if(x)
			H.equip_to_appropriate_slot(x, TRUE)

/datum/species/golem/on_loose(mob/living/carbon/human/H, new_species)
	H.add_status_flags(MOB_STATUS_FLAGS_DEFAULT)
	H.real_name = "unknown"

	for(var/x in list(H.w_uniform, H.head, H.wear_suit, H.shoes, H.wear_mask, H.gloves))
		if(x)
			var/list/golem_items = list(
				/obj/item/clothing/under/golem,
				/obj/item/clothing/head/helmet/space/golem,
				/obj/item/clothing/suit/space/golem,
				/obj/item/clothing/shoes/golem,
				/obj/item/clothing/mask/gas/golem,
				/obj/item/clothing/gloves/golem
				)

			if(is_type_in_list(x, golem_items))
				qdel(x)

	..()

/datum/species/abomination
	name = ABOMINATION
	icobase = 'icons/mob/human/abomination.dmi'
	deformed = null
	skeleton = null
	eyes_colorable_layer = "default"
	eyes_static_layer = null

	language = LANGUAGE_SOLCOMMON
	unarmed_type = /datum/unarmed_attack/claws/abomination
	dietflags = DIET_OMNI

	warning_low_pressure = 50
	hazard_low_pressure = 0

	metabolism_mod = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	siemens_coefficient = 0.1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = BODYTEMP_HEAT_DAMAGE_LIMIT
	heat_level_2 = BODYTEMP_HEAT_DAMAGE_LIMIT + 10
	heat_level_3 = BODYTEMP_HEAT_DAMAGE_LIMIT + 20

	darksight = 8

	restricted_inventory_slots = list(SLOT_BELT, SLOT_NECK, SLOT_WEAR_ID, SLOT_L_EAR, SLOT_R_EAR, SLOT_BACK, SLOT_L_STORE, SLOT_R_STORE, SLOT_WEAR_SUIT, SLOT_W_UNIFORM, SLOT_SHOES, SLOT_GLOVES, SLOT_HEAD, SLOT_WEAR_MASK, SLOT_GLASSES)

	race_traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_NO_FINGERPRINT,
		TRAIT_NO_MINORCUTS,
		TRAIT_EMOTIONLESS,
		TRAIT_NO_VOMIT,
	)

	flags = list(
	,NO_GENDERS = TRUE
	)

	has_bodypart = list(
		 BP_CHEST  = /obj/item/organ/external/chest
		,BP_GROIN  = /obj/item/organ/external/groin
		,BP_HEAD   = /obj/item/organ/external/head/abomination
		,BP_L_ARM  = /obj/item/organ/external/l_arm
		,BP_R_ARM  = /obj/item/organ/external/r_arm
		,BP_L_LEG  = /obj/item/organ/external/l_leg
		,BP_R_LEG  = /obj/item/organ/external/r_leg
		)

	has_organ = list(
		O_BRAIN  = /obj/item/organ/internal/brain/abomination
		)
	burn_mod = 0.2
	brute_mod = 0.2
	brain_mod = 0

	gender_body_icons = FALSE

	min_age = 1
	max_age = 10000

	speed_mod_no_shoes = 5

/datum/species/abomination/on_gain(mob/living/carbon/human/H)
	..()
	H.remove_status_flags(CANSTUN|CANPARALYSE|CANWEAKEN)

/datum/species/homunculus
	name = HOMUNCULUS
	// homunculus is basically placeholder, we set species directly for our organs
	icobase = null
	deformed = null
	skeleton = null
	eyes_colorable_layer = null
	eyes_static_layer = null

	language = LANGUAGE_SOLCOMMON

	brute_mod = 2
	burn_mod = 2
	speed_mod = 2
	pluvian_social_credit = 0

	has_bodypart = list(
		 BP_CHEST = /obj/item/organ/external/chest/homunculus
		,BP_GROIN = /obj/item/organ/external/groin/homunculus
		,BP_HEAD  = /obj/item/organ/external/head/homunculus
		,BP_L_ARM = /obj/item/organ/external/l_arm/homunculus
		,BP_R_ARM = /obj/item/organ/external/r_arm/homunculus
		,BP_L_LEG = /obj/item/organ/external/l_leg/homunculus
		,BP_R_LEG = /obj/item/organ/external/r_leg/homunculus
		)

	race_traits = list(
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_EMOTIONLESS,
	)

	flags = list(
		NO_DNA = TRUE,
		RAD_ABSORB = TRUE,
		HAS_TAIL = TRUE,
		HAS_HAIR = TRUE,
		HAS_HAIR_COLOR = TRUE,
		NO_WILLPOWER = TRUE
		)

	gender_body_icons = FALSE

	min_age = 1
	max_age = 10

	is_common = FALSE

	default_mood_event = /datum/mood_event/homunculus

/datum/species/homunculus/create_bodyparts(mob/living/carbon/human/H)
	var/list/keys = get_list_of_primary_keys(global.all_species)
	keys -= list(PODMAN, IPC, DIONA, HOMUNCULUS, ABDUCTOR, SHADOWLING, VOX_ARMALIS, ABOMINATION, SERPENTID)

	// todo: wings, tails (but need to rework tails and port more wings)

	var/datum/species/eyes = global.all_species[pick(keys - VOX)]
	eyes_colorable_layer = eyes::eyes_colorable_layer
	eyes_static_layer = eyes::eyes_static_layer

	var/datum/species/head = global.all_species[pick(keys - VOX)]

	var/datum/species/chest = global.all_species[pick(keys - HUMAN)]
	var/datum/species/l_arm = global.all_species[pick(keys)]
	var/datum/species/r_arm = global.all_species[pick(keys)]

	var/datum/species/groin = global.all_species[pick(keys)]
	var/datum/species/l_leg = global.all_species[pick(keys)]
	var/datum/species/r_leg = global.all_species[pick(keys)]

	if(prob(10)) // serpentid legs looks good, almost like naga, but need to be paired with other parts
		chest = global.all_species[SERPENTID]
		groin = global.all_species[SERPENTID]
		l_leg = global.all_species[SERPENTID]
		r_leg = global.all_species[SERPENTID]

	var/list/bodypart_species = list(
		BP_HEAD  = head,
		BP_CHEST = chest,
		BP_L_ARM = l_arm,
		BP_R_ARM = r_arm,
		BP_GROIN = groin,
		BP_L_LEG = l_leg,
		BP_R_LEG = r_leg,
	)

	for(var/type in has_bodypart)
		if((type in list(BP_L_LEG, BP_R_LEG, BP_R_ARM, BP_L_ARM)) && prob(10))
			continue
		var/path = has_bodypart[type]
		var/obj/item/organ/external/O = new path(null)
		var/datum/species/part_species = bodypart_species[type]
		O.insert_organ(H, FALSE, part_species)
		O.randomize_preferences()
		O.adjust_pumped(rand(0, 60))

/datum/species/homunculus/handle_death(mob/living/carbon/human/H, gibbed)
	if(gibbed)
		return FALSE
	for(var/I in H.get_equipped_items())
		H.remove_from_mob(I)
	H.dust()
	return TRUE

/datum/species/serpentid
	name = SERPENTID
	icobase = 'icons/mob/human/serpentid.dmi'
	deformed = null
	skeleton = null
	eyes_icon = 'icons/mob/human/eyes_serpentid.dmi'
	eyes_colorable_layer = "serpentid_colorable"
	eyes_static_layer = null
	damage_mask = FALSE
	gender_body_icons = FALSE

	default_skin_color = "#336600"
	flesh_color = "#525252"
	blood_datum_path = /datum/dirt_cover/hemolymph
	specie_shoe_blood_state = "snakeshoeblood"
	specie_hand_blood_state = "snakebloodyhands"
	specie_suffix_fire_icon = "generic"
	min_age = 18
	max_age = 40
	hud_offset_y = 8
	brute_mod = 0.9
	burn_mod = 1.35
	oxy_mod = 0.5
	speed_mod = -0.5
	total_health = 200

	race_traits = list(
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_MINORCUTS,
		TRAIT_NEVER_FAT,
	)

	flags = list(
		NO_DNA = TRUE,
		IS_SOCIAL = TRUE,
		NO_GENDERS = TRUE,
		NO_SLIP = TRUE,
		NO_MED_HEALTH_SCAN = TRUE,
		HAS_SKIN_COLOR = TRUE,
		)
	has_organ = list(
		 O_HEART   = /obj/item/organ/internal/heart
		,O_BRAIN   = /obj/item/organ/internal/brain
		,O_EYES    = /obj/item/organ/internal/eyes
		,O_LUNGS   = /obj/item/organ/internal/lungs
		,O_LIVER   = /obj/item/organ/internal/liver/serpentid
		,O_KIDNEYS = /obj/item/organ/internal/kidneys
		)
	restricted_inventory_slots = list(SLOT_L_EAR, SLOT_NECK, SLOT_R_EAR, SLOT_SHOES, SLOT_GLASSES, SLOT_GLOVES, SLOT_W_UNIFORM, SLOT_WEAR_SUIT, SLOT_WEAR_MASK)
	heat_level_1 = BODYTEMP_HEAT_DAMAGE_LIMIT + 50
	heat_level_2 = BODYTEMP_HEAT_DAMAGE_LIMIT + 80
	heat_level_3 = BODYTEMP_HEAT_DAMAGE_LIMIT + 440
	unarmed_type = /datum/unarmed_attack/claws/serpentid
	blood_trail_type = /obj/effect/decal/cleanable/blood/tracks/snake
	darksight = 8
	offset_features = list(
		OFFSET_UNIFORM = list(0,0),
		OFFSET_ID = list(0,0),
		OFFSET_GLOVES = list(0,8),
		OFFSET_GLASSES = list(0,9),
		OFFSET_EARS = list(0,9),
		OFFSET_SHOES = list(0,0),
		OFFSET_S_STORE = list(0,0),
		OFFSET_FACEMASK = list(0,9),
		OFFSET_HEAD = list(0,9),
		OFFSET_FACE = list(0,8),
		OFFSET_BELT = list(0,0),
		OFFSET_BACK = list(0,7),
		OFFSET_SUIT = list(0,0),
		OFFSET_NECK = list(0,7),
		OFFSET_ACCESSORY = list(0,0),
		OFFSET_HAIR = list(0,9),
	)

/datum/species/serpentid/proc/try_eat_item(mob/living/carbon/human/source, obj/item/I, user, params)
	SIGNAL_HANDLER
	if(!istype(I, /obj/item/weapon/holder))
		if(!isbodypart(I))
			return
		var/obj/item/organ/external/BP = I
		if(BP.is_robotic())
			return
	source.nutrition += max(0, NUTRITION_LEVEL_FULL - source.nutrition)
	qdel(I)
	source.visible_message("<span class='warning'>[I] was swallowed by [source]!</span>",
						   "<span class='notice'>You ate [I]. Delicious!</span>")
	return COMPONENT_NO_AFTERATTACK

/datum/species/serpentid/on_gain(mob/living/carbon/human/H)
	..()
	H.real_name = pick(global.serpentid_names)
	H.name = H.real_name
	var/list/color_variables = list("#003300",
									"#333300",
									"#663300",
									"#800000",
									"#000066",
									"#660033",
									"#003366")
	var/color_gain = pick(color_variables)
	H.r_skin = hex2num(copytext(color_gain, 2, 4))
	H.g_skin = hex2num(copytext(color_gain, 4, 6))
	H.b_skin = hex2num(copytext(color_gain, 6, 8))
	H.update_body(update_preferences = TRUE)
	RegisterSignal(H, COMSIG_PARENT_ATTACKBY, PROC_REF(try_eat_item))
	RegisterSignal(H, COMSIG_S_CLICK_GRAB, PROC_REF(try_tear_body))
	H.reagents.add_reagent("dexalinp", 3.0)

/datum/species/serpentid/on_loose(mob/living/carbon/human/H, new_species)
	UnregisterSignal(H, list(COMSIG_PARENT_ATTACKBY, COMSIG_S_CLICK_GRAB))
	return ..()

/datum/species/serpentid/on_mob_life(mob/living/carbon/human/H)
	if(!H.on_fire && H.fire_stacks < 2)
		H.fire_stacks += 0.2

/datum/species/serpentid/proc/try_tear_body(mob/living/source, obj/item/weapon/grab/G)
	if(G.state < GRAB_KILL)
		return
	var/mob/living/assailant = source
	if(!ishuman(G.affecting))
		return FALSE

	if(assailant.is_busy()) //can't stack the attempts
		return FALSE

	var/mob/living/carbon/human/H = G.affecting
	var/hit_zone = assailant.get_targetzone()
	var/obj/item/organ/external/L = H.get_bodypart(hit_zone)
	if(!L || (L.is_stump) || istype(L, /obj/item/organ/external/chest) || istype(L, /obj/item/organ/external/groin))
		return FALSE
	var/limb_time = rand(40,60)
	if(istype(L, /obj/item/organ/external/head))
		limb_time = rand(90,110)

	assailant.visible_message("<span class='shadowling'>[assailant] begins pulling on [H]'s [L.name] with incredible strength!</span>", \
					"<span class='shadowling'>You begin to pull on [H]'s [L.name] with incredible strength!</span>")

	if(!do_after(assailant, limb_time, TRUE, H))
		to_chat(assailant, "<span class='notice'>You stop ripping off the limb.</span>")
		return FALSE

	if(!L || (L.is_stump))
		return FALSE

	if(L.is_robotic())
		L.take_damage(rand(30,40), 0, 0)
		assailant.visible_message("<span class='shadowling'>You hear [H]'s [L.name] being pulled beyond its load limits!</span>", \
						"<span class='shadowling'>[H]'s [L.name] begins to tear apart!</span>")
	else
		assailant.visible_message("<span class='shadowling'>You hear the bones in [H]'s [L.name] snap with a sickening crunch!</span>", \
						"<span class='shadowling'>[H]'s [L.name] bones snap with a satisfying crunch!</span>")
		L.take_damage(rand(15,25), 0, 0)
		L.fracture()

	assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>ripped the [L.name] off of [H.name] ([H.ckey]) 1/2 progress</font>")
	H.attack_log += text("\[[time_stamp()]\] <font color='orange'>had their [L.name] ripped off by [assailant.name] ([assailant.ckey]) 1/2 progress</font>")
	log_attack("[assailant.name] ([assailant.ckey]) ripped the [L.name] off of [H.name] ([H.ckey]) 1/2 progress")

	if(!do_after(assailant, limb_time, TRUE, H))
		to_chat(assailant, "<span class='notice'>You stop ripping off the limb.</span>")
		return FALSE

	if(!L || (L.is_stump))
		return FALSE

	assailant.visible_message("<span class='shadowling'>[assailant] rips [H]'s [L.name] away from \his body!</span>", \
					"<span class='shadowling'>[H]'s [L.name] rips away from \his body!</span>")
	assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>ripped the [L.name] off of [H.name] ([H.ckey]) 2/2 progress</font>")
	H.attack_log += text("\[[time_stamp()]\] <font color='orange'>had their [L.name] ripped off by [assailant.name] ([assailant.ckey]) 2/2 progress</font>")
	log_attack("[assailant.name] ([assailant.ckey]) ripped the [L.name] off of [H.name] ([H.ckey]) 2/2 progress")

	L.droplimb(TRUE, FALSE, DROPLIMB_EDGE)

	return TRUE

/datum/species/moth
	name = MOTH
	flesh_color = "00FF00"
	icobase = 'icons/mob/human/moth.dmi'
	deformed = null
	skeleton = null
	eyes_colorable_layer = null // eyes are part of the head sprite
	eyes_static_layer = null

	race_traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_NO_FINGERPRINT,
		TRAIT_NO_EMBED,
		TRAIT_NO_MINORCUTS,
		TRAIT_EMOTIONLESS,
		TRAIT_NO_VOMIT,
		TRAIT_NO_BLOOD,
		TRAIT_NEVER_FAT,
		TRAIT_NIGHT_EYES,
	)

	flags = list(
				NO_MED_HEALTH_SCAN = TRUE,
				NO_DNA = TRUE,
				NO_GENDERS = TRUE,
				)
	restricted_inventory_slots = list(SLOT_WEAR_ID, SLOT_BELT, SLOT_L_EAR, SLOT_R_EAR)
	unarmed_type = /datum/unarmed_attack/claws
	dietflags = DIET_OMNI
	blood_datum_path = /datum/dirt_cover/gray_blood
	butcher_drops = list(/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/alien_meat = 5)
	damage_mask = FALSE
	min_age = 1
	max_age = 5
	darksight = 8

	metabolism_mod = 0

/datum/species/moth/New()
	. = ..()
	has_organ += list(BP_WINGS = /obj/item/organ/external/wings/moth)

/datum/species/moth/on_gain(mob/living/carbon/human/H)
	H.real_name = "[pick(global.moth_first)] [pick(global.moth_second)]"
	H.name = H.real_name
	RegisterSignal(H, COMSIG_PARENT_ATTACKBY, PROC_REF(try_eat_item))
	. = ..()

/datum/species/moth/proc/try_eat_item(mob/living/carbon/human/source, obj/item/I, user, params)
	SIGNAL_HANDLER
	if(!istype(I, /obj/item/clothing) && !istype(I, /obj/item/organ))
		return
	source.nutrition += max(0, NUTRITION_LEVEL_FULL - source.nutrition / 4)
	if(istype(I, /obj/item/clothing))
		var/obj/O = I
		if(O.oldificated)
			to_chat(source, "<span class='warning'>[I] was already spoiled!</span>")
		else
			O.make_old()
			source.visible_message("<span class='warning'>[I] were chewed by [source]!</span>",
								"<span class='notice'>You chew a hole in [I]. Yummy!</span>")
	else
		new /obj/effect/decal/cleanable/ash(get_turf(source))
		qdel(I)
		source.visible_message("<span class='warning'>[I] was swallowed by [source]!</span>",
							"<span class='notice'>You ate [I]. Delicious!</span>")
	return COMPONENT_NO_AFTERATTACK

/datum/species/moth/on_loose(mob/living/carbon/human/H, new_species)
	UnregisterSignal(H, COMSIG_PARENT_ATTACKBY)
	return ..()
