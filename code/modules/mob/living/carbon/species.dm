/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species
	var/name                     // Species name.

	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.
	var/damage_mask = TRUE
	var/eyes = "eyes"                                    // Icon for eyes.

	// Combat vars.
	var/total_health = 100                               // Point at which the mob will enter crit.
	var/unarmed                                          // For empty hand harm-intent attack
	var/unarmed_type = /datum/unarmed_attack
	var/brute_mod = 1                                    // Physical damage multiplier (0 == immunity).
	var/burn_mod = 1                                     // Burn damage multiplier.
	var/oxy_mod = 1                                      // Oxyloss multiplier.
	var/tox_mod = 1                                      // Toxloss multiplier.
	var/clone_mod = 1                                    // Cloneloss multiplier
	var/brain_mod = 1                                    // Brainloss multiplier.
	var/speed_mod =  0                                   // How fast or slow specific specie.
	var/siemens_coefficient = 1                          // How conductive is the specie.

	var/primitive                     // Lesser form, if any (ie. monkey for humans)
	var/tail                          // Name of tail image in species effects icon file.
	var/language                      // Default racial language, if any.
	var/list/additional_languages = list() // Additional languages, to the primary. These can not be the forced ones.
	var/force_racial_language = FALSE // If TRUE, racial language will be forced by default when speaking.
	var/attack_verb = "punch"         // Empty hand hurt intent verb.
	var/punch_damage = 0              // Extra empty hand attack damage.
	var/mutantrace                    // Safeguard due to old code.
	var/list/butcher_drops = list(/obj/item/weapon/reagent_containers/food/snacks/meat/human = 5)
	// Perhaps one day make this an assoc list of BODYPART_NAME = list(drops) ? ~Luduk
	// Is used when a bodypart of this race is butchered. Otherwise there are overrides for flesh, robot, and bone bodyparts.
	var/list/bodypart_butcher_results

	var/list/restricted_inventory_slots = list() // Slots that the race does not have due to biological differences.

	var/breath_type = "oxygen"           // Non-oxygen gas breathed, if any.
	var/poison_type = "phoron"           // Poisonous air.
	var/exhale_type = "carbon_dioxide"   // Exhaled gas type.

	var/cold_level_1 = 260  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 1000 // Heat damage level 3 above this point.

	var/body_temperature = 310.15	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/synth_temp_gain = 0			//IS_SYNTHETIC species will gain this much temperature every second
	var/synth_temp_max = 0			//IS_SYNTHETIC will cap at this value

	var/metabolism_mod = METABOLISM_FACTOR // Whether the xeno has custom metabolism? Is not additive, does override.
	var/taste_sensitivity = TASTE_SENSITIVITY_NORMAL //the most widely used factor; humans use a different one
	var/dietflags = 0	// Make sure you set this, otherwise it won't be able to digest a lot of foods

	var/darksight = 2
	var/nighteyes = 0
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/list/flags = list()       // Various specific features.
	var/list/abilities = list()	// For species-derived or admin-given powers

	var/blood_datum_path = /datum/dirt_cover/red_blood //Red.
	var/datum/dirt_cover/blood_datum // this will contain reference and should only be used as read only.
	var/flesh_color = "#ffc896" //Pink.
	var/base_color      //Used when setting species.

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template

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

	for(var/type in has_bodypart)
		var/path = has_bodypart[type]
		new path(null, H)

	for(var/type in has_organ)
		var/path = has_organ[type]
		new path(null, H)

	if(flags[IS_SYNTHETIC])
		for(var/obj/item/organ/internal/IO in H.organs)
			IO.mechanize()


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
	return

/datum/species/proc/on_loose(mob/living/carbon/human/H)
	return

/datum/species/proc/regen(mob/living/carbon/human/H) // Perhaps others will regenerate in different ways?
	return

/datum/species/proc/call_digest_proc(mob/living/M, datum/reagent/R) // Humans don't have a seperate proc, but need to return TRUE so general proc is called.
	return TRUE

/datum/species/proc/handle_death(mob/living/carbon/human/H) //Handles any species-specific death events (such nymph spawns).
	if(flags[IS_SYNTHETIC])
 //H.make_jittery(200) //S-s-s-s-sytem f-f-ai-i-i-i-i-lure-ure-ure-ure
		H.h_style = ""
		spawn(100)
			//H.is_jittery = 0
			//H.jitteriness = 0
			H.update_hair()
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

/datum/species/human
	name = HUMAN
	language = "Sol Common"
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
	)

	//If you wanted to add a species-level ability:
	/*abilities = list(/client/proc/test_ability)*/

	min_age = 25
	max_age = 85

/datum/species/unathi
	name = UNATHI
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = "Sinta'unathi"
	tail = "unathi"
	unarmed_type = /datum/unarmed_attack/claws
	dietflags = DIET_MEAT | DIET_DAIRY
	primitive = /mob/living/carbon/monkey/unathi
	darksight = 3

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 130 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000

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
	)

	flesh_color = "#34af10"
	base_color = "#066000"

	min_age = 25
	max_age = 85

	sprite_sheets = list(
		SPRITE_SHEET_SUIT = 'icons/mob/species/unathi/suit.dmi',
		SPRITE_SHEET_SUIT_FAT = 'icons/mob/species/unathi/suit_fat.dmi'
	)
	
	replace_outfit = list(
			/obj/item/clothing/shoes/boots/combat = /obj/item/clothing/shoes/boots/combat/cut
			)

/datum/species/unathi/after_job_equip(mob/living/carbon/human/H, datum/job/J, visualsOnly = FALSE)
	..()
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), SLOT_SHOES, 1)

/datum/species/unathi/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_unathi_digest(M)

/datum/species/unathi/call_species_equip_proc(mob/living/carbon/human/H, var/datum/outfit/O)
	return O.unathi_equip(H)

/datum/species/unathi/on_gain(mob/living/M)
	M.verbs += /mob/living/carbon/human/proc/air_sample

/datum/species/unathi/on_loose(mob/living/M)
	M.verbs -= /mob/living/carbon/human/proc/air_sample

/datum/species/tajaran
	name = TAJARAN
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	language = "Siik'maas"
	additional_languages = list("Siik'tajr")
	tail = "tajaran"
	unarmed_type = /datum/unarmed_attack/claws
	dietflags = DIET_OMNI
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	darksight = 8
	nighteyes = 1

	cold_level_1 = 200 //Default 260
	cold_level_2 = 140 //Default 200
	cold_level_3 = 80 //Default 120

	heat_level_1 = 330 //Default 360
	heat_level_2 = 380 //Default 400
	heat_level_3 = 800 //Default 1000

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
	)

	flesh_color = "#afa59e"
	base_color = "#333333"

	min_age = 25
	max_age = 85

	sprite_sheets = list(
		SPRITE_SHEET_SUIT = 'icons/mob/species/tajaran/suit.dmi',
		SPRITE_SHEET_SUIT_FAT = 'icons/mob/species/tajaran/suit_fat.dmi'
	)
	
	replace_outfit = list(
			/obj/item/clothing/shoes/boots/combat = /obj/item/clothing/shoes/boots/combat/cut,
			)

/datum/species/tajaran/after_job_equip(mob/living/carbon/human/H, datum/job/J, visualsOnly = FALSE)
	..()
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), SLOT_SHOES, 1)

/datum/species/tajaran/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_tajaran_digest(M)

/datum/species/tajaran/call_species_equip_proc(mob/living/carbon/human/H, var/datum/outfit/O)
	return O.tajaran_equip(H)

/datum/species/skrell
	name = SKRELL
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = "Skrellian"
	primitive = /mob/living/carbon/monkey/skrell
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = DIET_PLANT
	taste_sensitivity = TASTE_SENSITIVITY_DULL

	siemens_coefficient = 1.3 // Because they are wet and slimy.

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_SKIN_COLOR = TRUE
	,FACEHUGGABLE = TRUE
	,HAS_HAIR_COLOR = TRUE
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

/datum/species/skrell/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_skrell_digest(M)

/datum/species/skrell/call_species_equip_proc(mob/living/carbon/human/H, var/datum/outfit/O)
	return O.skrell_equip(H)

/datum/species/vox
	name = VOX
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	language = "Vox-pidgin"
	force_racial_language = TRUE
	unarmed_type = /datum/unarmed_attack/claws	//I dont think it will hurt to give vox claws too.
	dietflags = DIET_OMNI

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes"

	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = list(
		IS_WHITELISTED = TRUE
		,NO_SCAN = TRUE
		,FACEHUGGABLE = TRUE
		,SPRITE_SHEET_RESTRICTION = TRUE
		,HAS_HAIR_COLOR = TRUE
		,HAS_SKIN_COLOR = TRUE
		,NO_FAT = TRUE
	)

	blood_datum_path = /datum/dirt_cover/blue_blood
	flesh_color = "#808d11"

	sprite_sheets = list(
		// SPRITE_SHEET_HELD = 'icons/mob/species/vox/held.dmi',
		SPRITE_SHEET_UNIFORM = 'icons/mob/species/vox/uniform.dmi',
		SPRITE_SHEET_SUIT = 'icons/mob/species/vox/suit.dmi',
		SPRITE_SHEET_BELT = 'icons/mob/belt.dmi',
		SPRITE_SHEET_HEAD = 'icons/mob/species/vox/helmet.dmi',
		SPRITE_SHEET_BACK = 'icons/mob/back.dmi',
		SPRITE_SHEET_MASK = 'icons/mob/species/vox/masks.dmi',
		SPRITE_SHEET_EARS = 'icons/mob/ears.dmi',
		SPRITE_SHEET_EYES = 'icons/mob/species/vox/eyes.dmi',
		SPRITE_SHEET_FEET = 'icons/mob/species/vox/shoes.dmi',
		SPRITE_SHEET_GLOVES = 'icons/mob/species/vox/gloves.dmi'
		)

	survival_kit_items = list(/obj/item/weapon/tank/emergency_nitrogen
	                          )

	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen) // So they don't get the big engi oxy tank, since they need no tank.


	min_age = 12
	max_age = 20

	prohibit_roles = list(ROLE_CHANGELING, ROLE_WIZARD)

	replace_outfit = list(
			/obj/item/clothing/shoes/boots/combat = /obj/item/clothing/shoes/magboots/vox
			)

/datum/species/vox/after_job_equip(mob/living/carbon/human/H, datum/job/J, visualsOnly = FALSE)
	..()
	if(H.wear_mask)
		qdel(H.wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/vox(src), SLOT_WEAR_MASK)
	if(!H.r_store)
		H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_nitrogen(src), SLOT_R_STORE)
		H.internal = H.r_store
	else if(!H.l_store)
		H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_nitrogen(src), SLOT_L_STORE)
		H.internal = H.l_store
	else if(!H.r_hand)
		H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_nitrogen(src), SLOT_R_HAND)
		H.internal = H.r_hand
	else if(!H.l_hand)
		H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_nitrogen(src), SLOT_L_HAND)
		H.internal = H.l_hand
	if(H.shoes)
		qdel(H.shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox(src), SLOT_SHOES)

/datum/species/vox/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_vox_digest(M)

/datum/species/vox/call_species_equip_proc(mob/living/carbon/human/H, var/datum/outfit/O)
	return O.vox_equip(H)

/datum/species/vox/on_gain(mob/living/carbon/human/H)
	if(name != VOX_ARMALIS)
		H.leap_icon = new /obj/screen/leap()
		H.leap_icon.screen_loc = "CENTER+3:20,SOUTH:5"

		if(H.hud_used)
			H.hud_used.adding += H.leap_icon
		if(H.client)
			H.client.screen += H.leap_icon

	else
		H.verbs += /mob/living/carbon/human/proc/gut

	return ..()

/datum/species/vox/on_loose(mob/living/carbon/human/H)
	if(name != VOX_ARMALIS)
		if(H.leap_icon)
			if(H.hud_used)
				H.hud_used.adding -= H.leap_icon
			if(H.client)
				H.client.screen -= H.leap_icon
			QDEL_NULL(H.leap_icon)

	else
		H.verbs -= /mob/living/carbon/human/proc/gut

	return ..()

/datum/species/vox/armalis
	name = VOX_ARMALIS
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	deform = 'icons/mob/human_races/r_armalis.dmi'
	damage_mask = FALSE
	language = "Vox-pidgin"
	unarmed_type = /datum/unarmed_attack/claws/armalis
	dietflags = DIET_OMNI	//should inherit this from vox, this is here just in case

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	brute_mod = 0.2
	burn_mod = 0.2

	eyes = null
	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = list(
	 NO_SCAN = TRUE
	,NO_BLOOD = TRUE
	,HAS_TAIL = TRUE
	,NO_PAIN = TRUE
	,SPRITE_SHEET_RESTRICTION = TRUE
	,NO_FAT = TRUE
	)

	blood_datum_path = /datum/dirt_cover/blue_blood
	flesh_color = "#808d11"
	tail = "vox_armalis"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

	sprite_sheets = list(
		SPRITE_SHEET_SUIT = 'icons/mob/species/armalis/suit.dmi',
		SPRITE_SHEET_GLOVES = 'icons/mob/species/armalis/gloves.dmi',
		SPRITE_SHEET_FEET = 'icons/mob/species/armalis/feet.dmi',
		SPRITE_SHEET_HEAD = 'icons/mob/species/armalis/head.dmi',
		SPRITE_SHEET_HELD = 'icons/mob/species/armalis/held.dmi'
		)

/datum/species/diona
	name = DIONA
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	language = "Rootspeak"
	unarmed_type = /datum/unarmed_attack/diona
	dietflags = 0		//Diona regenerate nutrition in light, no diet necessary
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	primitive = /mob/living/carbon/monkey/diona

	siemens_coefficient = 0.5 // Because they are plants and stuff.

	hazard_low_pressure = DIONA_HAZARD_LOW_PRESSURE

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	burn_mod = 1.3
	speed_mod = 7

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
	,RAD_ABSORB = TRUE
	)

	has_bodypart = list(
		 BP_CHEST  = /obj/item/organ/external/chest
		,BP_GROIN  = /obj/item/organ/external/groin
		,BP_HEAD   = /obj/item/organ/external/head/diona
		,BP_L_ARM  = /obj/item/organ/external/l_arm
		,BP_R_ARM  = /obj/item/organ/external/r_arm
		,BP_L_LEG  = /obj/item/organ/external/l_leg
		,BP_R_LEG  = /obj/item/organ/external/r_leg
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

	prohibit_roles = list(ROLE_CHANGELING, ROLE_CULTIST)

/datum/species/diona/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/diona/regen(mob/living/carbon/human/H, light_amount)
	if(light_amount >= 5) // If you can regen organs - do so.
		for(var/obj/item/organ/internal/O in H.organs)
			if(O.damage)
				O.damage -= light_amount/5
				H.nutrition -= light_amount
				return
	if(H.nutrition > 350 && light_amount >= 4) // If you don't need to regen organs, regen bodyparts.
		if(!H.regenerating_bodypart) // If there is none currently, go ahead, find it.
			H.regenerating_bodypart = H.find_damaged_bodypart()
		if(H.regenerating_bodypart) // If it did find one.
			H.nutrition -= 1
			H.apply_damages(0,0,1,1,0,0)
			H.regen_bodyparts(0, TRUE)
			return
	if(light_amount >= 3) // If you don't need to regen bodyparts, fix up small things.
		H.adjustBruteLoss(-(light_amount))
		H.adjustToxLoss(-(light_amount))
		H.adjustOxyLoss(-(light_amount))

/datum/species/diona/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_diona_digest(M)

/datum/species/diona/handle_death(mob/living/carbon/human/H)

	var/mob/living/carbon/monkey/diona/S = new(get_turf(H))

	if(H.mind)
		H.mind.transfer_to(S)

	for(var/mob/living/carbon/monkey/diona/D in H.contents)
		if(D.client)
			D.loc = H.loc
		else
			qdel(D)

	H.visible_message("<span class='warning'>[H] splits apart with a wet slithering noise!</span>")

/datum/species/machine
	name = IPC
	icobase = 'icons/mob/human_races/r_machine.dmi'
	deform = 'icons/mob/human_races/r_machine.dmi'
	language = "Trinary"
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = 0		//IPCs can't eat, so no diet
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE

	eyes = null

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 400		//gives them about 15 seconds in space before taking damage
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
	,BIOHAZZARD_IMMUNE = TRUE
	,NO_FINGERPRINT = TRUE
	,NO_MINORCUTS = TRUE
	,NO_VOMIT = TRUE
	,NO_MUTATION = TRUE
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
	max_age = 125

	prohibit_roles = list(ROLE_CHANGELING, ROLE_SHADOWLING, ROLE_CULTIST, ROLE_BLOB)

/datum/species/machine/on_gain(mob/living/carbon/human/H)
	H.verbs += /mob/living/carbon/human/proc/IPC_change_screen
	H.verbs += /mob/living/carbon/human/proc/IPC_toggle_screen
	var/obj/item/organ/external/head/robot/ipc/BP = H.bodyparts_by_name[BP_HEAD]
	if(BP)
		H.set_light(BP.screen_brightness)

/datum/species/machine/on_loose(mob/living/carbon/human/H)
	H.verbs -= /mob/living/carbon/human/proc/IPC_change_screen
	H.verbs -= /mob/living/carbon/human/proc/IPC_toggle_screen
	var/obj/item/organ/external/head/robot/ipc/BP = H.bodyparts_by_name[BP_HEAD]
	if(BP && BP.screen_toggle)
		H.set_light(0)

/datum/species/machine/handle_death(mob/living/carbon/human/H)
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

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_SCAN = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_VOMIT = TRUE
	)

	blood_datum_path = /datum/dirt_cover/gray_blood

	min_age = 100
	max_age = 500

/datum/species/abductor/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/abductor/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_abductor_digest(M)

/datum/species/skeleton
	name = SKELETON

	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'
	damage_mask = FALSE
	dietflags = DIET_ALL

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
	,NO_MUTATION = TRUE
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

	has_organ = list(
		 O_BRAIN   = /obj/item/organ/internal/brain
		,O_EYES    = /obj/item/organ/internal/eyes
		)

	min_age = 1
	max_age = 1000

/datum/species/skeleton/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/skeleton/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_skeleton_digest(M)

//Species unarmed attacks

/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// Extra empty hand attack damage.
	var/damType = BRUTE
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = FALSE
	var/edge = FALSE
	var/list/attack_sound

/datum/unarmed_attack/New()
	attack_sound = SOUNDIN_PUNCH

/datum/unarmed_attack/proc/damage_flags()
	return (sharp ? DAM_SHARP : 0) | (edge ? DAM_EDGE : 0)

/datum/unarmed_attack/punch
	attack_verb = list("punch")

/datum/unarmed_attack/diona
	attack_verb = list("lash", "bludgeon")
	damage = 2

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

/datum/species/shadowling
	name = SHADOWLING
	icobase = 'icons/mob/human_races/r_shadowling.dmi'
	deform = 'icons/mob/human_races/r_shadowling.dmi'
	language = "Sol Common"
	unarmed_type = /datum/unarmed_attack/claws
	dietflags = DIET_OMNI

	warning_low_pressure = 50
	hazard_low_pressure = -1

	siemens_coefficient = 0 // Spooky shadows don't need to be hurt by your pesky electricity.

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

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
	,NO_MUTATION = TRUE
	)

	burn_mod = 2
	brain_mod = 0

	has_gendered_icons = FALSE

	min_age = 1
	max_age = 10000

/datum/species/shadowling/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

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
		BIOHAZZARD_IMMUNE = TRUE,
		NO_VOMIT = TRUE,
		NO_FINGERPRINT = TRUE,
		NO_MINORCUTS = TRUE,
		NO_EMOTION = TRUE,
		NO_MUTATION = TRUE
		)

	has_organ = list(
		O_BRAIN = /obj/item/organ/internal/brain
		)

	has_gendered_icons = FALSE

	min_age = 1
	max_age = 1000

/datum/species/golem/on_gain(mob/living/carbon/human/H)
	H.status_flags &= ~(CANSTUN | CANWEAKEN | CANPARALYSE)
	H.dna.mutantrace = "adamantine"
	H.real_name = text("Adamantine Golem ([rand(1, 1000)])")

	for(var/x in list(H.w_uniform, H.head, H.wear_suit, H.shoes, H.wear_mask, H.gloves))
		if(x)
			H.remove_from_mob(x)

	H.equip_to_slot_or_del(new /obj/item/clothing/under/golem, SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/golem, SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/golem, SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/golem, SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/golem, SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/golem, SLOT_GLOVES)

	return ..()

/datum/species/golem/on_loose(mob/living/carbon/human/H)
	H.status_flags |= MOB_STATUS_FLAGS_DEFAULT
	H.dna.mutantrace = null
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

	return ..()

/datum/species/golem/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_golem_digest(M)

/datum/species/zombie
	name = ZOMBIE
	darksight = 8
	nighteyes = 1
	dietflags = DIET_OMNI

	icobase = 'icons/mob/human_races/r_zombie.dmi'
	deform = 'icons/mob/human_races/r_zombie.dmi'
	has_gendered_icons = FALSE

	flags = list(
	NO_BREATHE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_EMOTION = TRUE
	)

	brute_mod = 2
	burn_mod = 1
	oxy_mod = 0
	tox_mod = 0
	speed_mod = -0.2

	var/list/spooks = list('sound/voice/growl1.ogg', 'sound/voice/growl2.ogg', 'sound/voice/growl3.ogg')

	min_age = 25
	max_age = 85

/datum/species/zombie/handle_post_spawn(mob/living/carbon/human/H)
	return ..()

/datum/species/zombie/on_gain(mob/living/carbon/human/H)
	H.status_flags &= ~(CANSTUN  | CANPARALYSE) //CANWEAKEN

	H.drop_l_hand()
	H.drop_r_hand()

	H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand, SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand/right, SLOT_R_HAND)

	add_zombie(H)

	return ..()

/datum/species/zombie/on_loose(mob/living/carbon/human/H)
	H.status_flags |= MOB_STATUS_FLAGS_DEFAULT

	if(istype(H.l_hand, /obj/item/weapon/melee/zombie_hand))
		qdel(H.l_hand)

	if(istype(H.r_hand, /obj/item/weapon/melee/zombie_hand))
		qdel(H.r_hand)

	remove_zombie(H)

	return ..()


/datum/species/zombie/tajaran
	name = ZOMBIE_TAJARAN

	icobase = 'icons/mob/human_races/r_zombie_tajaran.dmi'
	deform = 'icons/mob/human_races/r_zombie_tajaran.dmi'

	brute_mod = 2.2
	burn_mod = 1.2
	speed_mod = -0.8

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
	)

	min_age = 25
	max_age = 85

/datum/species/zombie/skrell
	name = ZOMBIE_SKRELL

	icobase = 'icons/mob/human_races/r_zombie_skrell.dmi'
	deform = 'icons/mob/human_races/r_zombie_skrell.dmi'

	eyes = "skrell_eyes"
	blood_datum_path = /datum/dirt_cover/purple_blood
	flesh_color = "#8cd7a3"
	base_color = "#000000"

	min_age = 25
	max_age = 150

/datum/species/zombie/unathi
	name = ZOMBIE_UNATHI

	icobase = 'icons/mob/human_races/r_zombie_lizard.dmi'
	deform = 'icons/mob/human_races/r_zombie_lizard.dmi'

	brute_mod = 1.80
	burn_mod = 0.90
	speed_mod = -0.2

	tail = "unathi_zombie"

	flesh_color = "#34af10"
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

	cold_level_1 = 280
	cold_level_2 = 230
	cold_level_3 = 150

	flags = list(
	 NO_BREATHE = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,HAS_SKIN_COLOR = TRUE
	,HAS_UNDERWEAR = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	)

	min_age = 1
	max_age = 85

/datum/species/slime/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_slime_digest(M)
