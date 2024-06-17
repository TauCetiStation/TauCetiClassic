/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species
	var/name                     // Species name.

	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.
	var/damage_mask = TRUE
	var/eyes_icon = 'icons/mob/human_face.dmi'
	var/eyes = "eyes"                                    // Icon for eyes.
	var/eyes_glowing = FALSE                             // To make those eyes gloooow.
	var/gender_tail_icons = FALSE
	var/gender_limb_icons = FALSE
	var/fat_limb_icons = FALSE
	var/hud_offset_x = 0                                 // As above, but specifically for the HUD indicator.
	var/hud_offset_y = 0                                 // As above, but specifically for the HUD indicator.
	var/blood_trail_type = /obj/effect/decal/cleanable/blood/tracks/footprints

	// Combat vars.
	var/total_health = 100                               // Point at which the mob will enter crit.
	var/datum/unarmed_attack/unarmed                                          // For empty hand harm-intent attack
	var/unarmed_type = /datum/unarmed_attack
	var/brute_mod = 1                                    // Physical damage multiplier (0 == immunity).
	var/burn_mod = 1                                     // Burn damage multiplier.
	var/oxy_mod = 1                                      // Oxyloss multiplier.
	var/tox_mod = 1                                      // Toxloss multiplier.
	var/clone_mod = 1                                    // Cloneloss multiplier
	var/brain_mod = 1                                    // Brainloss multiplier.
	var/speed_mod =  0                                   // How fast or slow specific specie.
	var/speed_mod_no_shoes = 0                           // Speed ​​modifier without shoes.
	var/siemens_coefficient = 1                          // How conductive is the specie.

	var/primitive                     // Lesser form, if any (ie. monkey for humans)
	var/tail                          // Name of tail image in species effects icon file.
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

	var/metabolism_mod = METABOLISM_FACTOR // Whether the xeno has custom metabolism? Is not additive, does override.
	var/taste_sensitivity = TASTE_SENSITIVITY_NORMAL //the most widely used factor; humans use a different one
	var/dietflags = 0	// Make sure you set this, otherwise it won't be able to digest a lot of foods

	var/darksight = 2
	var/nighteyes = FALSE
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/list/flags = list()       // Various specific features.

	var/specie_suffix_fire_icon = "human"
	var/blood_datum_path = /datum/dirt_cover/red_blood //Red.
	var/datum/dirt_cover/blood_datum // this will contain reference and should only be used as read only.
	var/specie_shoe_blood_state = "shoeblood"
	var/specie_hand_blood_state = "bloodyhands"
	var/flesh_color = "#ffc896" //Pink.
	var/base_color      //Used when setting species.

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

	///Clothing offsets. If a species has a different body than other species, you can offset clothing so they look less weird.
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

	var/has_gendered_icons = TRUE // if TRUE = use icon_state with _f or _m for respective gender (see get_icon() external organ proc).

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

	// The type of skeleton species they would be turned into. default is human
	var/skeleton_type = SKELETON

	var/default_mood_event

	var/prothesis_icobase = 'icons/mob/human_races/robotic.dmi'

	var/surgery_icobase = 'icons/mob/surgery.dmi'


/datum/species/New()
	blood_datum = new blood_datum_path
	unarmed = new unarmed_type()

	if(!has_organ[O_HEART])
		flags[NO_BLOOD] = TRUE // this status also uncaps vital body parts damage, since such species otherwise will be very hard to kill.

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
			"[SLOT_TIE]" = O.neck,
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

	SEND_SIGNAL(H, COMSIG_SPECIES_GAIN, src)

	if(default_mood_event)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "species", default_mood_event)

/datum/species/proc/on_loose(mob/living/carbon/human/H, new_species)
	SHOULD_CALL_PARENT(TRUE)

	if(!flags[IS_SOCIAL])
		H.handle_socialization()

	H.remove_moveset_source(MOVESET_SPECIES)

	for(var/emote in emotes)
		H.clear_emote(emote)

	SEND_SIGNAL(H, COMSIG_SPECIES_LOSS, src, new_species)
	SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "species")

/datum/species/proc/regen(mob/living/carbon/human/H) // Perhaps others will regenerate in different ways?
	return

/datum/species/proc/call_digest_proc(mob/living/M, datum/reagent/R) // Humans don't have a seperate proc, but need to return TRUE so general proc is called.
	return TRUE

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

/datum/species/proc/on_life(mob/living/carbon/human/H)
	return

// For species who's skin acts as a spacesuit of sorts
// Return a value from 0 to 1, where 1 is full protection, and 0 is full weakness
/datum/species/proc/get_pressure_protection(mob/living/carbon/human/H)
	return 0

/datum/species/human
	name = HUMAN
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
	,FACEHUGGABLE = TRUE
	,HAS_HAIR_COLOR = TRUE
	,IS_SOCIAL = TRUE
	)

	min_age = 25
	max_age = 85

	is_common = TRUE

/datum/species/unathi
	name = UNATHI
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	gender_tail_icons = TRUE
	gender_limb_icons = TRUE
	fat_limb_icons = TRUE
	language = LANGUAGE_SINTAUNATHI
	tail = "unathi"
	unarmed_type = /datum/unarmed_attack/claws
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

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_TAIL = TRUE
	,HAS_SKIN_COLOR = TRUE
	,HAS_HAIR_COLOR = TRUE
	,NO_MINORCUTS = TRUE
	,FACEHUGGABLE = TRUE
	,IS_SOCIAL = TRUE
	)

	flesh_color = "#34af10"
	base_color = "#066000"

	min_age = 25
	max_age = 85

	is_common = TRUE

	skeleton_type = SKELETON_UNATHI

	sprite_sheets = list(
		SPRITE_SHEET_HEAD     = 'icons/mob/species/unathi/helmet.dmi',
		SPRITE_SHEET_SUIT     = 'icons/mob/species/unathi/suit.dmi',
		SPRITE_SHEET_SUIT_FAT = 'icons/mob/species/unathi/suit_fat.dmi'
	)

/datum/species/unathi/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_unathi_digest(M)

/datum/species/unathi/call_species_equip_proc(mob/living/carbon/human/H, datum/outfit/O)
	return O.unathi_equip(H)

/datum/species/unathi/on_gain(mob/living/carbon/human/M)
	..()
	M.verbs += /mob/living/carbon/human/proc/air_sample
	M.r_belly = HEX_VAL_RED(base_color)
	M.g_belly = HEX_VAL_GREEN(base_color)
	M.b_belly = HEX_VAL_BLUE(base_color)

/datum/species/unathi/on_loose(mob/living/M, new_species)
	M.verbs -= /mob/living/carbon/human/proc/air_sample
	..()

/datum/species/tajaran
	name = TAJARAN
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	gender_limb_icons = TRUE
	fat_limb_icons = TRUE
	language = LANGUAGE_SIIKMAAS
	additional_languages = list(LANGUAGE_SIIKTAJR = LANGUAGE_NATIVE)
	tail = "tajaran"
	unarmed_type = /datum/unarmed_attack/claws
	dietflags = DIET_OMNI
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	darksight = 8
	nighteyes = TRUE

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

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_TAIL = TRUE
	,HAS_SKIN_COLOR = TRUE
	,HAS_HAIR_COLOR = TRUE
	,HAS_HAIR = TRUE
	,FACEHUGGABLE = TRUE
	,IS_SOCIAL = TRUE
	,FUR = TRUE
	)

	flesh_color = "#afa59e"
	base_color = "#333333"

	min_age = 25
	max_age = 85

	is_common = TRUE

	skeleton_type = SKELETON_TAJARAN

	sprite_sheets = list(
		SPRITE_SHEET_HEAD     = 'icons/mob/species/tajaran/helmet.dmi',
		SPRITE_SHEET_SUIT     = 'icons/mob/species/tajaran/suit.dmi',
		SPRITE_SHEET_SUIT_FAT = 'icons/mob/species/tajaran/suit_fat.dmi'
	)

/datum/species/tajaran/on_gain(mob/living/M)
	..()
	ADD_TRAIT(M, TRAIT_NATURAL_AGILITY, GENERIC_TRAIT)

/datum/species/tajaran/on_loose(mob/living/M)
	..()
	REMOVE_TRAIT(M, TRAIT_NATURAL_AGILITY, GENERIC_TRAIT)

/datum/species/tajaran/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_tajaran_digest(M)

/datum/species/tajaran/call_species_equip_proc(mob/living/carbon/human/H, datum/outfit/O)
	return O.tajaran_equip(H)

/datum/species/skrell
	name = SKRELL
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = LANGUAGE_SKRELLIAN
	primitive = /mob/living/carbon/monkey/skrell
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = DIET_PLANT
	taste_sensitivity = TASTE_SENSITIVITY_DULL

	siemens_coefficient = 1.3 // Because they are wet and slimy.
	has_gendered_icons = FALSE

	speed_mod = 1.5
	speed_mod_no_shoes = -2.2

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_SKIN_COLOR = TRUE
	,FACEHUGGABLE = TRUE
	,HAS_HAIR_COLOR = TRUE
	,IS_SOCIAL = TRUE
	,NO_MINORCUTS = TRUE
	)

	has_organ = list(
		O_HEART   = /obj/item/organ/internal/heart,
		O_BRAIN   = /obj/item/organ/internal/brain,
		O_EYES    = /obj/item/organ/internal/eyes,
		O_LUNGS   = /obj/item/organ/internal/lungs/skrell,
		O_LIVER   = /obj/item/organ/internal/liver,
		O_KIDNEYS = /obj/item/organ/internal/kidneys
		)

	eyes = "skrell_eyes"
	blood_datum_path = /datum/dirt_cover/purple_blood
	flesh_color = "#8cd7a3"

	min_age = 25
	max_age = 150

	is_common = TRUE

	skeleton_type = SKELETON_SKRELL

	sprite_sheets = list(
		SPRITE_SHEET_HEAD = 'icons/mob/species/skrell/helmet.dmi',
		SPRITE_SHEET_SUIT = 'icons/mob/species/skrell/suit.dmi'
	)

/datum/species/skrell/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_skrell_digest(M)

/datum/species/skrell/call_species_equip_proc(mob/living/carbon/human/H, datum/outfit/O)
	return O.skrell_equip(H)

/datum/species/vox
	name = VOX
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	language = LANGUAGE_VOXPIDGIN
	additional_languages = list(LANGUAGE_TRADEBAND = LANGUAGE_CAN_SPEAK)
	tail = "vox_prim"
	has_gendered_icons = FALSE
	surgery_icobase = 'icons/mob/species/vox/surgery.dmi'

	species_common_language = TRUE
	unarmed_type = /datum/unarmed_attack/claws	//I dont think it will hurt to give vox claws too.
	dietflags = DIET_OMNI

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	breath_cold_level_1 = 80
	breath_cold_level_2 = 50
	breath_cold_level_3 = 0

	eyes = "vox_eyes"

	inhale_type = "nitrogen"
	poison_type = "oxygen"

	flags = list(
		IS_WHITELISTED = TRUE
		,NO_SCAN = TRUE
		,FACEHUGGABLE = TRUE
		,HAS_TAIL = TRUE
		,HAS_HAIR_COLOR = TRUE
		,NO_FAT = TRUE
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
		SPRITE_SHEET_EARS = 'icons/mob/ears.dmi',
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

	skeleton_type = SKELETON_VOX

	prothesis_icobase = 'icons/mob/human_races/robotic_vox.dmi'

/datum/species/vox/after_job_equip(mob/living/carbon/human/H, datum/job/J, visualsOnly = FALSE)
	..()

	if(H.wear_mask)
		qdel(H.wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/vox(src), SLOT_WEAR_MASK)

/datum/species/vox/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_vox_digest(M)

/datum/species/vox/call_species_equip_proc(mob/living/carbon/human/H, datum/outfit/O)
	return O.vox_equip(H)

/datum/species/vox/on_gain(mob/living/carbon/human/H)
	if(name != VOX_ARMALIS)
		H.leap_icon = new /atom/movable/screen/leap()

		if(H.hud_used)
			H.leap_icon.add_to_hud(H.hud_used)

	else
		H.verbs += /mob/living/carbon/human/proc/gut
	..()

/datum/species/vox/on_loose(mob/living/carbon/human/H, new_species)
	if(name != VOX_ARMALIS)
		if(H.leap_icon)
			if(H.hud_used)
				H.leap_icon.remove_from_hud(H.hud_used)
			QDEL_NULL(H.leap_icon)

	else
		H.verbs -= /mob/living/carbon/human/proc/gut
	..()

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
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	deform = 'icons/mob/human_races/r_armalis.dmi'
	damage_mask = FALSE
	language = LANGUAGE_VOXPIDGIN
	unarmed_type = /datum/unarmed_attack/claws/armalis
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

	eyes = null
	inhale_type = "nitrogen"
	poison_type = "oxygen"

	is_common = TRUE

	flags = list(
	 NO_SCAN = TRUE
	,NO_BLOOD = TRUE
	,HAS_TAIL = TRUE
	,NO_PAIN = TRUE
	,NO_FAT = TRUE
	,IS_SOCIAL = TRUE
	,NO_GENDERS = TRUE
	)

	blood_datum_path = /datum/dirt_cover/blue_blood
	flesh_color = "#808d11"
	tail = "vox_armalis"

	sprite_sheets = list(
		SPRITE_SHEET_SUIT = 'icons/mob/species/armalis/suit.dmi',
		SPRITE_SHEET_GLOVES = 'icons/mob/species/armalis/gloves.dmi',
		SPRITE_SHEET_FEET = 'icons/mob/species/armalis/feet.dmi',
		SPRITE_SHEET_HEAD = 'icons/mob/species/armalis/head.dmi',
		SPRITE_SHEET_HELD = 'icons/mob/species/armalis/held.dmi'
		)

	has_gendered_icons = TRUE

	skeleton_type = SKELETON_VOX

/datum/species/diona
	name = DIONA
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	language = LANGUAGE_ROOTSPEAK
	unarmed_type = /datum/unarmed_attack/diona
	dietflags = 0		//Diona regenerate nutrition in light, no diet necessary
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	primitive = /mob/living/carbon/monkey/diona

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

	flags = list(
	 IS_WHITELISTED = TRUE
	,NO_BREATHE = TRUE
	,REQUIRE_LIGHT = TRUE
	,NO_SCAN = TRUE
	,NO_EMOTION = TRUE
	,NO_BLOOD = TRUE
	,NO_PAIN = TRUE
	,NO_FINGERPRINT = TRUE
	,IS_PLANT = TRUE
	,NO_VOMIT = TRUE
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

	has_gendered_icons = FALSE

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

/datum/species/diona/regen(mob/living/carbon/human/H)
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

/datum/species/diona/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_diona_digest(M)

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
	icobase = 'icons/mob/human_races/r_podman.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'

	language = "Rootspeak"
	unarmed_type = /datum/unarmed_attack/diona/podman
	primitive = /mob/living/carbon/monkey/diona/podman

	// Because they are less thicc than dionaea.
	siemens_coefficient = 0.75

	brute_mod = 1.3
	burn_mod = 1.3
	speed_mod = 2.7
	speed_mod_no_shoes = -2

	flags = list(
	 IS_WHITELISTED = TRUE
	,NO_BREATHE = TRUE
	,REQUIRE_LIGHT = TRUE
	,NO_SCAN = TRUE
	,NO_BLOOD = TRUE
	,NO_PAIN = TRUE
	,IS_PLANT = TRUE
	,NO_VOMIT = TRUE
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
	icobase = 'icons/mob/human_races/r_machine.dmi'
	deform = 'icons/mob/human_races/r_machine.dmi'
	language = LANGUAGE_TRINARY
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = 0		//IPCs can't eat, so no diet
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	surgery_icobase = 'icons/mob/species/ipc/surgery.dmi'

	eyes = null

	warning_low_pressure = 50
	hazard_low_pressure = 0

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

	flags = list(
	 IS_WHITELISTED = TRUE
	,NO_BREATHE = TRUE
	,NO_SCAN = TRUE
	,NO_BLOOD = TRUE
	,NO_DNA = TRUE
	,NO_PAIN = TRUE
	,NO_EMOTION = TRUE
	,HAS_HAIR_COLOR = TRUE
	,IS_SYNTHETIC = TRUE
	,HAS_SKIN_COLOR = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_FINGERPRINT = TRUE
	,NO_MINORCUTS = TRUE
	,NO_VOMIT = TRUE
	,IS_SOCIAL = TRUE
	,NO_GENDERS = TRUE
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

/datum/species/machine/on_gain(mob/living/carbon/human/H)
	..()
	H.verbs += /mob/living/carbon/human/proc/IPC_change_screen
	H.verbs += /mob/living/carbon/human/proc/IPC_toggle_screen
	H.verbs += /mob/living/carbon/human/proc/IPC_display_text
	var/obj/item/organ/external/head/robot/ipc/BP = H.bodyparts_by_name[BP_HEAD]
	if(BP)
		H.set_light(BP.screen_brightness)

/datum/species/machine/on_loose(mob/living/carbon/human/H, new_species)
	H.verbs -= /mob/living/carbon/human/proc/IPC_change_screen
	H.verbs -= /mob/living/carbon/human/proc/IPC_toggle_screen
	H.verbs -= /mob/living/carbon/human/proc/IPC_display_text
	var/obj/item/organ/external/head/robot/ipc/BP = H.bodyparts_by_name[BP_HEAD]
	if(BP && BP.screen_toggle)
		H.set_light(0)
	..()

/datum/species/machine/handle_death(mob/living/carbon/human/H, gibbed)
	var/obj/item/organ/external/head/robot/ipc/BP = H.bodyparts_by_name[BP_HEAD]
	if(BP && BP.screen_toggle)
		H.r_hair = 15
		H.g_hair = 15
		H.b_hair = 15
		H.set_light(0)
		if(BP.ipc_head == "Default")
			H.h_style = "IPC off screen"
		H.update_hair()

/datum/species/abductor
	name = ABDUCTOR
	darksight = 3
	dietflags = DIET_OMNI

	icobase = 'icons/mob/human_races/r_abductor.dmi'
	deform = 'icons/mob/human_races/r_abductor.dmi'

	flesh_color = "#808080"

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_SCAN = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_VOMIT = TRUE
	,NO_GENDERS = TRUE
	)

	blood_datum_path = /datum/dirt_cover/gray_blood

	min_age = 100
	max_age = 500

/datum/species/abductor/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_abductor_digest(M)

/datum/species/skeleton
	name = SKELETON

	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'
	damage_mask = FALSE
	dietflags = DIET_ALL
	flesh_color = "#c0c0c0"

	brute_mod = 2
	oxy_mod = 0
	tox_mod = 0
	clone_mod = 0
	siemens_coefficient = 0

	butcher_drops = list()
	bodypart_butcher_results = list()

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_DNA = TRUE
	,NO_SCAN = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_FINGERPRINT = TRUE
	,NO_BLOOD_TRAILS = TRUE
	,NO_PAIN = TRUE
	,RAD_IMMUNE = TRUE
	,NO_EMBED = TRUE
	,NO_MINORCUTS = TRUE
	,NO_EMOTION = TRUE
	,NO_VOMIT = TRUE
	,NO_FAT = TRUE
	)

	has_bodypart = list(
		 BP_CHEST  = /obj/item/organ/external/chest/skeleton
		,BP_GROIN  = /obj/item/organ/external/groin/skeleton
		,BP_HEAD   = /obj/item/organ/external/head/skeleton
		,BP_L_ARM  = /obj/item/organ/external/l_arm/skeleton
		,BP_R_ARM  = /obj/item/organ/external/r_arm/skeleton
		,BP_L_LEG  = /obj/item/organ/external/l_leg/skeleton
		,BP_R_LEG  = /obj/item/organ/external/r_leg/skeleton
		)

	has_organ = list()

	min_age = 1
	max_age = 1000

	default_mood_event = /datum/mood_event/undead

/datum/species/skeleton/on_gain(mob/living/carbon/human/H)
	..()
	H.remove_status_flags(CANSTUN|CANPARALYSE)

/datum/species/skeleton/on_loose(mob/living/carbon/human/H, new_species)
	H.add_status_flags(MOB_STATUS_FLAGS_DEFAULT)
	..()

/datum/species/skeleton/regen(mob/living/carbon/human/H)
	H.nutrition = NUTRITION_LEVEL_NORMAL

/datum/species/skeleton/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_skeleton_digest(M)

/datum/species/skeleton/unathi
	name = SKELETON_UNATHI
	icobase = 'icons/mob/human_races/r_skeleton_lizard.dmi'
	deform = 'icons/mob/human_races/r_skeleton_lizard.dmi'
	tail = "unathi_skeleton"

/datum/species/skeleton/unathi/New()
	.=..()
	flags[HAS_TAIL]=TRUE

/datum/species/skeleton/tajaran
	name = SKELETON_TAJARAN
	icobase = 'icons/mob/human_races/r_skeleton_tajaran.dmi'
	deform = 'icons/mob/human_races/r_skeleton_tajaran.dmi'
	tail = "tajaran_skeleton"

/datum/species/skeleton/tajaran/New()
	.=..()
	flags[HAS_TAIL]=TRUE

/datum/species/skeleton/skrell
	name = SKELETON_SKRELL
	icobase = 'icons/mob/human_races/r_skeleton_skrell.dmi'
	deform = 'icons/mob/human_races/r_skeleton_skrell.dmi'

/datum/species/skeleton/vox
	name = SKELETON_VOX
	icobase = 'icons/mob/human_races/r_skeleton_vox.dmi'
	deform = 'icons/mob/human_races/r_skeleton_vox.dmi'
	tail = "vox_skeleton"

/datum/species/skeleton/vox/New()
	.=..()
	flags[HAS_TAIL]=TRUE

//Species unarmed attacks

/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// Extra empty hand attack damage.
	var/damType = BRUTE
	var/miss_sound = 'sound/effects/mob/hits/miss_1.ogg'
	var/sharp = FALSE
	var/edge = FALSE
	var/list/attack_sound

/datum/unarmed_attack/New()
	attack_sound = SOUNDIN_PUNCH_MEDIUM

/datum/unarmed_attack/proc/damage_flags()
	return (sharp ? DAM_SHARP : 0) | (edge ? DAM_EDGE : 0)

/datum/unarmed_attack/punch
	attack_verb = list("punch")

/datum/unarmed_attack/diona
	attack_verb = list("lash", "bludgeon")
	damage = 2

/datum/unarmed_attack/diona/podman
	damage = 1

/datum/unarmed_attack/slime_glomp
	attack_verb = list("glomp")
	damage = 5
	damType = CLONE

/datum/unarmed_attack/slime_glomp/New()
	attack_sound = list('sound/effects/attackblob.ogg')

/datum/unarmed_attack/claws
	attack_verb = list("scratch", "claw")
	miss_sound = 'sound/weapons/slashmiss.ogg'
	damage = 2
	sharp = TRUE
	edge = TRUE

/datum/unarmed_attack/claws/New()
	attack_sound = list('sound/weapons/slice.ogg')

/datum/unarmed_attack/claws/armalis
	attack_verb = list("slash", "claw")
	damage = 10	//they're huge! they should do a little more damage, i'd even go for 15-20 maybe...

/datum/unarmed_attack/claws/abomination
	attack_verb = list("slash", "claw", "lacerate")
	damage = 35

/datum/unarmed_attack/claws/serpentid
	attack_verb = list("mauled", "slashed", "struck", "pierced")
	damage = 6
	sharp = 1
	edge = 1

/datum/species/shadowling
	name = SHADOWLING
	icobase = 'icons/mob/human_races/r_shadowling.dmi'
	deform = 'icons/mob/human_races/r_shadowling.dmi'
	language = LANGUAGE_SOLCOMMON
	unarmed_type = /datum/unarmed_attack/claws
	dietflags = DIET_OMNI
	flesh_color = "#ff0000"

	eyes = "shadowling_ms_s"
	eyes_glowing = TRUE

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

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_EMBED = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_FINGERPRINT = TRUE
	,NO_SCAN = TRUE
	,NO_MINORCUTS = TRUE
	,NO_VOMIT = TRUE
	,NO_EMOTION = TRUE
	,NO_GENDERS = TRUE
	)

	burn_mod = 2
	brain_mod = 0

	has_gendered_icons = FALSE

	min_age = 1
	max_age = 10000

/datum/species/shadowling/regen(mob/living/carbon/human/H)
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

/datum/species/shadowling/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_shadowling_digest(M)

/datum/species/golem
	name = GOLEM

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'
	dietflags = 0 //this is ROCK

	total_health = 100
	oxy_mod = 0
	tox_mod = 0
	brain_mod = 0
	speed_mod = 2

	blood_datum_path = /datum/dirt_cover/adamant_blood
	flesh_color = "#137e8f"

	butcher_drops = list(/obj/item/weapon/ore/diamond = 1, /obj/item/weapon/ore/slag = 3)
	bodypart_butcher_results = list(/obj/item/weapon/ore/slag = 1)

	flags = list(
		NO_BLOOD = TRUE,
		NO_DNA = TRUE,
		NO_BREATHE = TRUE,
		NO_SCAN = TRUE,
		NO_PAIN = TRUE,
		NO_EMBED = TRUE,
		RAD_IMMUNE = TRUE,
		VIRUS_IMMUNE = TRUE,
		NO_VOMIT = TRUE,
		NO_FINGERPRINT = TRUE,
		NO_MINORCUTS = TRUE,
		NO_EMOTION = TRUE,
		NO_FAT = TRUE,
		IS_SOCIAL = TRUE,
		NO_GENDERS = TRUE,
		)

	has_organ = list(
		O_BRAIN = /obj/item/organ/internal/brain
		)

	has_gendered_icons = FALSE

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

/datum/species/golem/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_golem_digest(M)

/datum/species/zombie
	name = ZOMBIE
	darksight = 8
	nighteyes = TRUE
	dietflags = DIET_OMNI

	icobase = 'icons/mob/human_races/r_zombie.dmi'
	deform = 'icons/mob/human_races/r_zombie.dmi'
	has_gendered_icons = FALSE

	eyes = "zombie_ms_s"
	eyes_glowing = TRUE

	flags = list(
	NO_BREATHE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_EMOTION = TRUE
	,NO_EMBED = TRUE
	)

	brute_mod = 1.8
	burn_mod = 1
	oxy_mod = 0
	tox_mod = 0
	brain_mod = 0
	speed_mod_no_shoes = -1

	var/list/spooks = list('sound/voice/growl1.ogg', 'sound/voice/growl2.ogg', 'sound/voice/growl3.ogg')

	min_age = 25
	max_age = 85

	default_mood_event = /datum/mood_event/undead

/datum/species/zombie/on_gain(mob/living/carbon/human/H)
	..()

	ADD_TRAIT(H, TRAIT_HEMOCOAGULATION, GENERIC_TRAIT)

	H.remove_status_flags(CANSTUN|CANPARALYSE) //CANWEAKEN

	H.drop_l_hand()
	H.drop_r_hand()

	H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand, SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand/right, SLOT_R_HAND)

	var/obj/item/organ/external/head/O = H.bodyparts_by_name[BP_HEAD]
	O.max_damage = 1000

	add_zombie(H)

/datum/species/zombie/on_loose(mob/living/carbon/human/H, new_species)
	REMOVE_TRAIT(H, TRAIT_HEMOCOAGULATION, GENERIC_TRAIT)

	H.add_status_flags(MOB_STATUS_FLAGS_DEFAULT)

	if(istype(H.l_hand, /obj/item/weapon/melee/zombie_hand))
		qdel(H.l_hand)

	if(istype(H.r_hand, /obj/item/weapon/melee/zombie_hand))
		qdel(H.r_hand)

	remove_zombie(H)

	..()

/datum/species/zombie/tajaran
	name = ZOMBIE_TAJARAN

	icobase = 'icons/mob/human_races/r_zombie_tajaran.dmi'
	deform = 'icons/mob/human_races/r_zombie_tajaran.dmi'

	brute_mod = 2
	burn_mod = 1.2
	speed_mod = -0.6

	tail = "tajaran_zombie"

	flesh_color = "#afa59e"
	base_color = "#000000"

	flags = list(
	NO_BREATHE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,VIRUS_IMMUNE = TRUE
	,HAS_TAIL = TRUE
	,NO_EMOTION = TRUE
	,NO_EMBED = TRUE
	)

	min_age = 25
	max_age = 85

/datum/species/zombie/tajaran/on_gain(mob/living/M)
	..()
	ADD_TRAIT(M, TRAIT_NATURAL_AGILITY, GENERIC_TRAIT)

/datum/species/zombie/tajaran/on_loose(mob/living/M)
	..()
	REMOVE_TRAIT(M, TRAIT_NATURAL_AGILITY, GENERIC_TRAIT)

/datum/species/zombie/skrell
	name = ZOMBIE_SKRELL

	icobase = 'icons/mob/human_races/r_zombie_skrell.dmi'
	deform = 'icons/mob/human_races/r_zombie_skrell.dmi'

	blood_datum_path = /datum/dirt_cover/purple_blood
	flesh_color = "#8cd7a3"
	base_color = "#000000"

	min_age = 25
	max_age = 150

/datum/species/zombie/unathi
	name = ZOMBIE_UNATHI

	icobase = 'icons/mob/human_races/r_zombie_lizard.dmi'
	deform = 'icons/mob/human_races/r_zombie_lizard.dmi'

	brute_mod = 1.6
	burn_mod = 0.90
	speed_mod = 0.1

	tail = "unathi_zombie"

	flesh_color = "#34af10"
	base_color = "#000000"
	has_gendered_icons = FALSE

	flags = list(
	NO_BREATHE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,VIRUS_IMMUNE = TRUE
	,HAS_TAIL = TRUE
	,NO_EMOTION = TRUE
	,NO_EMBED = TRUE
	)

	min_age = 25
	max_age = 85

/datum/species/slime
	name = SLIME
	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_slime.dmi'

	blood_datum_path = /datum/dirt_cover/blue_blood
	flesh_color = "#05fffb"
	unarmed_type = /datum/unarmed_attack/slime_glomp
	has_gendered_icons = FALSE

	cold_level_1 = BODYTEMP_COLD_DAMAGE_LIMIT + 20
	cold_level_2 = BODYTEMP_COLD_DAMAGE_LIMIT - 10
	cold_level_3 = BODYTEMP_COLD_DAMAGE_LIMIT - 50

	darksight = 3

	flags = list(
	 NO_BREATHE = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,HAS_SKIN_COLOR = TRUE
	,HAS_UNDERWEAR = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	,IS_SOCIAL = TRUE
	)

	min_age = 1
	max_age = 85

	is_common = TRUE

/datum/species/slime/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_slime_digest(M)

/datum/species/abomination
	name = ABOMINATION
	icobase = 'icons/mob/human_races/r_abomination.dmi'
	deform = 'icons/mob/human_races/r_abomination.dmi'
	language = LANGUAGE_SOLCOMMON
	unarmed_type = /datum/unarmed_attack/claws/abomination
	dietflags = DIET_OMNI

	warning_low_pressure = 50
	hazard_low_pressure = 0

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

	restricted_inventory_slots = list(SLOT_BELT, SLOT_WEAR_ID, SLOT_L_EAR, SLOT_R_EAR, SLOT_BACK, SLOT_L_STORE, SLOT_R_STORE, SLOT_WEAR_SUIT, SLOT_W_UNIFORM, SLOT_SHOES, SLOT_GLOVES, SLOT_HEAD, SLOT_WEAR_MASK, SLOT_GLASSES)

	flags = list(
	 NO_BREATHE = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_FINGERPRINT = TRUE
	,NO_SCAN = TRUE
	,NO_MINORCUTS = TRUE
	,NO_VOMIT = TRUE
	,NO_EMOTION = TRUE
	,NO_PAIN = TRUE
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

	has_gendered_icons = FALSE

	min_age = 1
	max_age = 10000

	speed_mod_no_shoes = 5

/datum/species/abomination/on_gain(mob/living/carbon/human/H)
	..()
	H.remove_status_flags(CANSTUN|CANPARALYSE|CANWEAKEN)

/datum/species/abomination/call_digest_proc(mob/living/M, datum/reagent/R)
	return

/datum/species/homunculus
	name = HOMUNCULUS
	language = LANGUAGE_SOLCOMMON

	brute_mod = 2
	burn_mod = 2
	speed_mod = 2

	has_bodypart = list(
		 BP_CHEST = /obj/item/organ/external/chest/homunculus
		,BP_GROIN = /obj/item/organ/external/groin/homunculus
		,BP_HEAD  = /obj/item/organ/external/head/homunculus
		,BP_L_ARM = /obj/item/organ/external/l_arm/homunculus
		,BP_R_ARM = /obj/item/organ/external/r_arm/homunculus
		,BP_L_LEG = /obj/item/organ/external/l_leg/homunculus
		,BP_R_LEG = /obj/item/organ/external/r_leg/homunculus
		)

	flags = list(
		NO_DNA = TRUE,
		NO_SCAN = TRUE,
		NO_PAIN = TRUE,
		RAD_ABSORB = TRUE,
		VIRUS_IMMUNE = TRUE,
		NO_EMOTION = TRUE,
		HAS_TAIL = TRUE,
		HAS_HAIR = TRUE,
		HAS_HAIR_COLOR = TRUE,
		)

	has_gendered_icons = FALSE

	min_age = 1
	max_age = 10

	is_common = FALSE

	default_mood_event = /datum/mood_event/homunculus

/datum/species/homunculus/on_gain(mob/living/carbon/human/H)
	..()
	var/list/tail_list = icon_states('icons/mob/species/tail.dmi') - "vox_armalis"
	tail_list += ""
	H.random_tail_holder = pick(tail_list)

/datum/species/homunculus/create_bodyparts(mob/living/carbon/human/H)
	var/list/keys = get_list_of_primary_keys(global.all_species)
	keys -= list(PODMAN, IPC, SKELETON, SKELETON_UNATHI, SKELETON_TAJARAN, SKELETON_SKRELL, SKELETON_VOX, DIONA, HOMUNCULUS, ABDUCTOR, SHADOWLING, VOX_ARMALIS, ABOMINATION, SLIME)

	var/datum/species/head = global.all_species[pick(keys - VOX)]

	var/datum/species/chest = global.all_species[pick(keys - HUMAN)]
	var/datum/species/l_arm = global.all_species[pick(keys)]
	var/datum/species/r_arm = global.all_species[pick(keys)]

	var/datum/species/groin = global.all_species[pick(keys)]
	var/datum/species/l_leg = global.all_species[pick(keys)]
	var/datum/species/r_leg = global.all_species[pick(keys)]

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
		O.adjust_pumped(rand(0, 60))
		if(prob(80) && (part_species.name in list(UNATHI, SKRELL, TAJARAN)))
			O.original_color = pick(list(COLOR_GREEN, COLOR_LIGHT_PINK, COLOR_ROSE_PINK, COLOR_VIOLET, COLOR_DEEP_SKY_BLUE, COLOR_RED, COLOR_LIME, COLOR_PINK))

/datum/species/homunculus/handle_death(mob/living/carbon/human/H, gibbed)
	if(gibbed)
		return FALSE
	for(var/I in H.get_equipped_items())
		H.remove_from_mob(I)
	H.dust()
	return TRUE

/datum/species/serpentid
	name = SERPENTID
	icobase = 'icons/mob/human_races/r_serpentid.dmi'
	deform = 'icons/mob/human_races/r_serpentid.dmi'
	damage_mask = FALSE
	has_gendered_icons = FALSE
	eyes_icon = 'icons/mob/serpentid_face.dmi'
	eyes = "serpentid_eyes"
	base_color = "#336600"
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
	flags = list(
		NO_SCAN = TRUE,
		NO_DNA = TRUE,
		NO_FAT = TRUE,
		IS_SOCIAL = TRUE,
		NO_GENDERS = TRUE,
		NO_SLIP = TRUE,
		NO_MINORCUTS = TRUE,
		NO_MED_HEALTH_SCAN = TRUE,
		)
	has_organ = list(
		 O_HEART   = /obj/item/organ/internal/heart
		,O_BRAIN   = /obj/item/organ/internal/brain
		,O_EYES    = /obj/item/organ/internal/eyes
		,O_LUNGS   = /obj/item/organ/internal/lungs
		,O_LIVER   = /obj/item/organ/internal/liver/serpentid
		,O_KIDNEYS = /obj/item/organ/internal/kidneys
		)
	restricted_inventory_slots = list(SLOT_L_EAR, SLOT_R_EAR, SLOT_SHOES, SLOT_GLASSES, SLOT_GLOVES, SLOT_W_UNIFORM, SLOT_WEAR_SUIT, SLOT_WEAR_MASK)
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

/datum/species/serpentid/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_serpentid_digest(M)

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
	H.r_eyes = 255
	H.update_hair()
	RegisterSignal(H, COMSIG_PARENT_ATTACKBY, PROC_REF(try_eat_item))
	RegisterSignal(H, COMSIG_S_CLICK_GRAB, PROC_REF(try_tear_body))
	H.reagents.add_reagent("dexalinp", 3.0)

/datum/species/serpentid/on_loose(mob/living/carbon/human/H, new_species)
	UnregisterSignal(H, list(COMSIG_PARENT_ATTACKBY, COMSIG_S_CLICK_GRAB))
	return ..()

/datum/species/serpentid/on_life(mob/living/carbon/human/H)
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
	icobase = 'icons/mob/human_races/r_moth.dmi'
	deform = 'icons/mob/human_races/r_moth.dmi'
	tail = "moth_wings"
	flags = list(
				NO_BREATHE = TRUE,
				NO_BLOOD = TRUE,
				NO_EMBED = TRUE,
				RAD_IMMUNE = TRUE,
				VIRUS_IMMUNE = TRUE,
				NO_FINGERPRINT = TRUE,
				NO_SCAN = TRUE,
				NO_MED_HEALTH_SCAN = TRUE,
				NO_MINORCUTS = TRUE,
				NO_VOMIT = TRUE,
				NO_EMOTION = TRUE,
				HAS_TAIL = TRUE,
				NO_DNA = TRUE,
				NO_PAIN = TRUE,
				NO_GENDERS = TRUE,
				NO_FAT = TRUE,
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
	nighteyes = 1

/datum/species/moth/on_gain(mob/living/carbon/human/H)
	H.real_name = "[pick(global.moth_first)] [pick(global.moth_second)]"
	H.name = H.real_name
	RegisterSignal(H, COMSIG_PARENT_ATTACKBY, PROC_REF(try_eat_item))
	return ..()

/datum/species/moth/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_moth_digest(M)

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
