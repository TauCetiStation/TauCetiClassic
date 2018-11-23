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
	var/list/ignore_gene_icons = list() // Some species may want to ignore a visual of gene or two.

	var/datum/dirt_cover/blood_color = /datum/dirt_cover/red_blood //Red.
	var/flesh_color = "#FFC896" //Pink.
	var/base_color      //Used when setting species.

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		"held" = 'icons/mob/path',
		"uniform" = 'icons/mob/path',
		"suit" = 'icons/mob/path',
		"belt" = 'icons/mob/path'
		"head" = 'icons/mob/path',
		"back" = 'icons/mob/path',
		"mask" = 'icons/mob/path',
		"ears" = 'icons/mob/path',
		"eyes" = 'icons/mob/path',
		"feet" = 'icons/mob/path',
		"gloves" = 'icons/mob/path'
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

/datum/species/New()
	unarmed = new unarmed_type()

	if(!has_organ[O_HEART])
		flags[NO_BLOOD] = TRUE // this status also uncaps vital body parts damage, since such species otherwise will be very hard to kill.

/datum/species/proc/create_organs(mob/living/carbon/human/H) //Handles creation of mob organs.

	for(var/type in has_bodypart)
		var/path = has_bodypart[type]
		new path(null, H)

	for(var/type in has_organ)
		var/path = has_organ[type]
		new path(null, H)

	if(flags[IS_SYNTHETIC])
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(BP.status & (ORGAN_CUT_AWAY | ORGAN_DESTROYED))
				continue
			BP.status |= ORGAN_ROBOT
		for(var/obj/item/organ/internal/IO in H.organs)
			IO.mechanize()

/datum/species/proc/handle_post_spawn(mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	return

/datum/species/proc/on_gain(mob/living/carbon/human/H)
	return

/datum/species/proc/on_loose(mob/living/carbon/human/H)
	return

/datum/species/proc/regen(mob/living/carbon/human/H, light_amount) // Perhaps others will regenerate in different ways?
	return

/datum/species/proc/call_digest_proc(mob/living/M, datum/reagent/R) // Humans don't have a seperate proc, but need to return TRUE so general proc is called.
	return TRUE

/datum/species/proc/on_emp_act(mob/living/M, emp_severity)
	return

/datum/species/proc/handle_death(mob/living/carbon/human/H) //Handles any species-specific death events (such nymph spawns).
	if(flags[IS_SYNTHETIC])
 //H.make_jittery(200) //S-s-s-s-sytem f-f-ai-i-i-i-i-lure-ure-ure-ure
		H.h_style = ""
		spawn(100)
			//H.is_jittery = 0
			//H.jitteriness = 0
			H.update_hair()
	return

/datum/species/proc/on_life(mob/living/carbon/human/H)
	return

/datum/species/proc/before_job_equip(mob/living/carbon/human/H, datum/job/J) // Do we really need this proc? Perhaps.
	return

/datum/species/proc/after_job_equip(mob/living/carbon/human/H, datum/job/J)
	var/obj/item/weapon/storage/box/SK
	if(J.title in list("Shaft Miner", "Chief Engineer", "Station Engineer", "Atmospheric Technician"))
		SK = new /obj/item/weapon/storage/box/engineer(H)
	else
		SK = new /obj/item/weapon/storage/box/survival(H)

	if(H.backbag == 1)
		H.equip_to_slot_or_del(SK, slot_r_hand)
	else
		H.equip_to_slot_or_del(SK, slot_in_backpack)

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
	)

	//If you wanted to add a species-level ability:
	/*abilities = list(/client/proc/test_ability)*/

/datum/species/unathi
	name = UNATHI
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = "Sinta'unathi"
	tail = "sogtail"
	unarmed_type = /datum/unarmed_attack/claws
	dietflags = DIET_CARN
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
	,NO_MINORCUTS = TRUE
	)

	flesh_color = "#34AF10"
	base_color = "#066000"

/datum/species/unathi/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_unathi_digest(M)

/datum/species/unathi/after_job_equip(mob/living/carbon/human/H, datum/job/J)
	..()
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes, 1)

/datum/species/tajaran
	name = TAJARAN
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	language = "Siik'maas"
	additional_languages = list("Siik'tajr")
	tail = "tajtail"
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
	,HAS_HAIR = TRUE
	)

	flesh_color = "#AFA59E"
	base_color = "#333333"

/datum/species/tajaran/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_tajaran_digest(M)

/datum/species/tajaran/after_job_equip(mob/living/carbon/human/H, datum/job/J)
	..()
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes, 1)

/datum/species/skrell
	name = SKRELL
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = "Skrellian"
	primitive = /mob/living/carbon/monkey/skrell
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = DIET_HERB
	taste_sensitivity = TASTE_SENSITIVITY_DULL

	siemens_coefficient = 1.3 // Because they are wet and slimy.

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_SKIN_COLOR = TRUE
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
	blood_color = /datum/dirt_cover/purple_blood
	flesh_color = "#8CD7A3"

/datum/species/skrell/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_skrell_digest(M)

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
		NO_SCAN = TRUE
	)

	blood_color = /datum/dirt_cover/blue_blood
	flesh_color = "#808D11"

	sprite_sheets = list(
		"suit" = 'icons/mob/species/vox/suit.dmi',
		"head" = 'icons/mob/species/vox/head.dmi',
		"mask" = 'icons/mob/species/vox/masks.dmi',
		"feet" = 'icons/mob/species/vox/shoes.dmi',
		"gloves" = 'icons/mob/species/vox/gloves.dmi'
		)

/datum/species/vox/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_vox_digest(M)

/datum/species/vox/after_job_equip(mob/living/carbon/human/H, datum/job/J)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox(src), slot_wear_mask)
	if(!H.r_hand)
		H.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(src), slot_r_hand)
		H.internal = H.r_hand
	else if(!H.l_hand)
		H.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(src), slot_l_hand)
		H.internal = H.l_hand
	H.internals.icon_state = "internal1"

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

	eyes = "blank_eyes"
	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = list(
	 NO_SCAN = TRUE
	,NO_BLOOD = TRUE
	,HAS_TAIL = TRUE
	,NO_PAIN = TRUE
	,NO_FAT = TRUE
	)

	blood_color = /datum/dirt_cover/blue_blood
	flesh_color = "#808D11"
	tail = "armalis_tail"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

	sprite_sheets = list(
		"suit" = 'icons/mob/species/armalis/suit.dmi',
		"gloves" = 'icons/mob/species/armalis/gloves.dmi',
		"feet" = 'icons/mob/species/armalis/feet.dmi',
		"head" = 'icons/mob/species/armalis/head.dmi',
		"held" = 'icons/mob/species/armalis/held.dmi'
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

	restricted_inventory_slots = list(slot_wear_mask, slot_glasses, slot_gloves, slot_shoes) // These are trees. Not people. Deal with the fact that they don't have these.

	body_temperature = T0C + 15		//make the plant people have a bit lower body temperature, why not
	butcher_drops = list(/obj/item/stack/sheet/wood = 5)

	flags = list(
	 IS_WHITELISTED = TRUE
	,NO_BREATHE = TRUE
	,REQUIRE_LIGHT = TRUE
	,NO_SCAN = TRUE
	,IS_PLANT = TRUE
	,RAD_ABSORB = TRUE
	,NO_BLOOD = TRUE
	,NO_PAIN = TRUE
	,NO_FINGERPRINT = TRUE
	,NO_FAT = TRUE
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

	blood_color = /datum/dirt_cover/green_blood
	flesh_color = "#907E4A"

	has_gendered_icons = FALSE

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

/datum/species/diona/after_job_equip(mob/living/carbon/human/H, datum/job/J)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/diona_survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/diona_survival(H), slot_in_backpack)

/datum/species/diona/handle_death(mob/living/carbon/human/H)

	var/mob/living/carbon/monkey/diona/S = new(get_turf(H))

	if(H.mind)
		H.mind.transfer_to(S)

	for(var/mob/living/carbon/monkey/diona/D in H.contents)
		if(D.client)
			D.loc = H.loc
		else
			qdel(D)

	H.visible_message("\red[H] splits apart with a wet slithering noise!")

/datum/species/machine
	name = IPC
	icobase = 'icons/mob/human_races/r_machine.dmi'
	deform = 'icons/mob/human_races/r_machine.dmi'
	language = "Trinary"
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = 0		//IPCs can't eat, so no diet
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE

	eyes = "blank_eyes"

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500		//gives them about 25 seconds in space before taking damage
	heat_level_2 = 1000
	heat_level_3 = 2000

	synth_temp_gain = 10 //this should cause IPCs to stabilize at ~80 C in a 20 C environment.

	brute_mod = 1.5
	burn_mod = 1
	siemens_coefficient = 1.3 // ROBUTT.

	butcher_drops = list(/obj/item/stack/sheet/plasteel = 3)

	flags = list(
	 IS_WHITELISTED = TRUE
	,NO_BREATHE = TRUE
	,NO_SCAN = TRUE
	,NO_BLOOD = TRUE
	,NO_PAIN = TRUE
	,IS_SYNTHETIC = TRUE
	,VIRUS_IMMUNE = TRUE
	,BIOHAZZARD_IMMUNE = TRUE
	,NO_FINGERPRINT = TRUE
	,NO_MINORCUTS = TRUE
	,RAD_IMMUNE = TRUE
	,NO_FAT = TRUE
	)

	has_bodypart = list(
		 BP_CHEST  = /obj/item/organ/external/chest
		,BP_GROIN  = /obj/item/organ/external/groin
		,BP_HEAD   = /obj/item/organ/external/head/ipc
		,BP_L_ARM  = /obj/item/organ/external/l_arm
		,BP_R_ARM  = /obj/item/organ/external/r_arm
		,BP_L_LEG  = /obj/item/organ/external/l_leg
		,BP_R_LEG  = /obj/item/organ/external/r_leg
		)

	has_organ = list(
		 O_HEART   = /obj/item/organ/internal/heart/ipc
		,O_BRAIN   = /obj/item/organ/internal/brain/ipc
		,O_EYES    = /obj/item/organ/internal/eyes/ipc
		,O_LUNGS   = /obj/item/organ/internal/lungs/ipc
		,O_LIVER   = /obj/item/organ/internal/liver/ipc
		,O_KIDNEYS = /obj/item/organ/internal/kidneys/ipc
		)

	blood_color = /datum/dirt_cover/oil
	flesh_color = "#575757"

/datum/species/machine/after_job_equip(mob/living/carbon/human/H, datum/job/J)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/ipc_survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/ipc_survival(H), slot_in_backpack)

/datum/species/abductor
	name = ABDUCTOR
	darksight = 3
	dietflags = DIET_OMNI

	butcher_drops = list()

	icobase = 'icons/mob/human_races/r_abductor.dmi'
	deform = 'icons/mob/human_races/r_abductor.dmi'

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_SCAN = TRUE
	,VIRUS_IMMUNE = TRUE
	)

	blood_color = /datum/dirt_cover/gray_blood

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
	dietflags = 0

	siemens_coefficient = 0

	butcher_drops = list()

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	,BIOHAZZARD_IMMUNE = TRUE
	,NO_FINGERPRINT = TRUE
	)

/datum/species/skeleton/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/skeleton/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_skeleton_digest(M)

//Species unarmed attacks

/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// Extra empty hand attack damage.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = 0
	var/edge = 0

/datum/unarmed_attack/proc/damage_flags()
	return (sharp ? DAM_SHARP : 0) | (edge ? DAM_EDGE : 0)

/datum/unarmed_attack/punch
	attack_verb = list("punch")

/datum/unarmed_attack/diona
	attack_verb = list("lash", "bludgeon")
	damage = 5

/datum/unarmed_attack/claws
	attack_verb = list("scratch", "claw")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	damage = 5
	sharp = 1
	edge = 1

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

	butcher_drops = list()

	warning_low_pressure = 50
	hazard_low_pressure = -1

	siemens_coefficient = 0 // Spooky shadows don't need to be hurt by your pesky electricity.

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	blood_color = /datum/dirt_cover/black_blood
	darksight = 8

	butcher_drops = list() // They are just shadows. Why should they drop anything?

	restricted_inventory_slots = list(slot_belt, slot_wear_id, slot_l_ear, slot_r_ear, slot_back, slot_l_store, slot_r_store)

	has_organ = list(O_HEART = /obj/item/organ/internal/heart) // A huge buff to be honest.

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_EMBED = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_FINGERPRINT = TRUE
	,NO_MINORCUTS
	)

	burn_mod = 2
	brain_mod = 0

	has_gendered_icons = FALSE


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

	butcher_drops = list(/obj/item/weapon/ore/diamond = 1, /obj/item/weapon/ore/slag = 3)

	total_health = 200
	oxy_mod = 0
	tox_mod = 0
	brain_mod = 0
	speed_mod = 2

	blood_color = /datum/dirt_cover/adamant_blood
	flesh_color = "#137E8F"

	flags = list(
		NO_BLOOD = TRUE,
		NO_BREATHE = TRUE,
		NO_SCAN = TRUE,
		NO_PAIN = TRUE,
		NO_EMBED = TRUE,
		RAD_IMMUNE = TRUE,
		VIRUS_IMMUNE = TRUE,
		BIOHAZZARD_IMMUNE = TRUE,
		NO_FINGERPRINT = TRUE,
		NO_MINORCUTS = TRUE
		)

	has_organ = list(
		O_BRAIN = /obj/item/organ/internal/brain
		)

	has_gendered_icons = FALSE

/datum/species/golem/on_gain(mob/living/carbon/human/H)
	H.status_flags &= ~(CANSTUN | CANWEAKEN | CANPARALYSE)
	H.dna.mutantrace = "adamantine"
	H.real_name = text("Adamantine Golem ([rand(1, 1000)])")

	for(var/x in list(H.w_uniform, H.head, H.wear_suit, H.shoes, H.wear_mask, H.gloves))
		if(x)
			H.remove_from_mob(x)

	H.equip_to_slot_or_del(new /obj/item/clothing/under/golem, slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/golem, slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/golem, slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/golem, slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/golem, slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/golem, slot_gloves)

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

	flags = list(
	NO_BREATHE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,VIRUS_IMMUNE = TRUE
	)

	brute_mod = 2
	burn_mod = 1
	oxy_mod = 0
	tox_mod = 0
	speed_mod = -0.2

	var/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')

/datum/species/zombie/handle_post_spawn(mob/living/carbon/human/H)
	return ..()

/datum/species/zombie/on_gain(mob/living/carbon/human/H)
	H.status_flags &= ~(CANSTUN  | CANPARALYSE) //CANWEAKEN

	H.drop_l_hand()
	H.drop_r_hand()

	H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand, slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand/right, slot_r_hand)

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

	tail = "zombie_tajtail"

	flesh_color = "#AFA59E"
	base_color = "#000000"

	flags = list(
	NO_BREATHE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,VIRUS_IMMUNE = TRUE
	,HAS_TAIL = TRUE
	)

/datum/species/zombie/skrell
	name = ZOMBIE_SKRELL

	icobase = 'icons/mob/human_races/r_zombie_skrell.dmi'
	deform = 'icons/mob/human_races/r_zombie_skrell.dmi'

	eyes = "skrell_eyes"
	blood_color = /datum/dirt_cover/purple_blood
	flesh_color = "#8CD7A3"
	base_color = "#000000"

/datum/species/zombie/unathi
	name = ZOMBIE_UNATHI

	icobase = 'icons/mob/human_races/r_zombie_lizard.dmi'
	deform = 'icons/mob/human_races/r_zombie_lizard.dmi'

	brute_mod = 1.80
	burn_mod = 0.90
	speed_mod = -0.2

	tail = "zombie_sogtail"

	flesh_color = "#34AF10"
	base_color = "#000000"

	flags = list(
	NO_BREATHE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,VIRUS_IMMUNE = TRUE
	,HAS_TAIL = TRUE
	)

/datum/species/tycheon // Do keep in mind that they use nutrition as static electricity, which they can waste.
	name = "Tycheon"
	icobase = 'icons/mob/human_races/r_tycheon.dmi'
	deform = 'icons/mob/human_races/r_tycheon.dmi'
	damage_mask = FALSE
	eyes = "core"                              // Glowing core.
	brute_mod = 3.0
	burn_mod = 3.0
	speed_mod =  -1.0
	siemens_coefficient = 0

	language = "The Gaping Maw"
	force_racial_language = TRUE

	butcher_drops = list()
	taste_sensitivity = 0

	dietflags = 0
	darksight = 8

	flags = list(NO_BLOOD = TRUE,
	             NO_BREATHE = TRUE,
	             NO_SCAN = TRUE,
	             HAS_SKIN_COLOR = TRUE,
	             RAD_IMMUNE = TRUE,
	             VIRUS_IMMUNE = TRUE,
	             BIOHAZZARD_IMMUNE = TRUE,
	             IS_FLYING = TRUE,
	             IS_IMMATERIAL = TRUE,
	             STATICALLY_CHARGED = TRUE,
	             NO_FAT = TRUE,
	             EMP_HEAL = TRUE)
	abilities = list()

	ignore_gene_icons = list("All")
	blood_color = /datum/dirt_cover/tycheon_blood
	flesh_color = "#1F1F1F"
	base_color = "#BB1111"

	body_temperature = 300 // Which is slightly lower than the normal human being. Slight deviations from Tycheon's bodytemperature may result in... Bleh.
	cold_level_1 = 273
	cold_level_2 = 263
	cold_level_3 = 253
	// Default seems to be 293.3.
	heat_level_1 = 313
	heat_level_2 = 323
	heat_level_3 = 333

	warning_low_pressure = 90
	hazard_low_pressure = 70

	has_bodypart = list(
		 BP_CHEST  = /obj/item/organ/external/chest/tycheon
		,BP_L_ARM  = /obj/item/organ/external/l_arm/tycheon
		,BP_R_ARM  = /obj/item/organ/external/r_arm/tycheon
		,BP_L_LEG  = /obj/item/organ/external/l_leg/tycheon
		,BP_R_LEG  = /obj/item/organ/external/r_leg/tycheon
		)
	has_organ = list(
		O_BRAIN   = /obj/item/organ/internal/brain/tycheon
		)
	restricted_inventory_slots = list(slot_back, slot_wear_mask, slot_handcuffed, slot_l_hand, slot_r_hand, slot_belt, slot_l_ear, slot_r_ear, slot_glasses, slot_glasses,
	                                  slot_shoes, slot_w_uniform, slot_l_store, slot_r_store, slot_s_store, slot_in_backpack, slot_legcuffed, slot_legs, slot_tie, slot_head) // Still allows them to wear rigs, and ids.
	has_gendered_icons = FALSE

/datum/species/tycheon/call_digest_proc(mob/living/M, datum/reagent/R)
	R.on_tycheon_digest(M)
	return FALSE

/datum/species/tycheon/on_emp_act(mob/living/carbon/human/H, emp_severity)
	var/list/list_of_metal = list()
	for(var/obj/item/stack/sheet/metal/M in view(1, H))
		list_of_metal += M
	if(!list_of_metal.len)
		return
	if(emp_severity == 1.0)
		if(!H.regenerating_bodypart)
			H.regenerating_bodypart = H.find_damaged_bodypart()
			if(H.regenerating_bodypart)
				var/obj/item/stack/sheet/metal/M = pick(list_of_metal)
				if(M)
					new /obj/effect/effect/sparks(M.loc)
					addtimer(CALLBACK(H.regenerating_bodypart, /obj/item/organ/external.proc/rejuvenate), 15 SECONDS)
					addtimer(CALLBACK(H, /mob/living/carbon/human.proc/update_body), 15 SECONDS)
					M.use(1)
					if(M.get_amount() == 0)
						list_of_metal -= M
		var/obj/item/stack/sheet/metal/M = pick(list_of_metal)
		if(M)
			new /obj/effect/effect/sparks(M.loc)
			H.adjustBruteLoss(-5)
			H.adjustFireLoss(-5)
			H.adjustOxyLoss(-5) // If it ever arises I guess.
			M.use(1)
			if(M.get_amount() == 0)
				list_of_metal -= M
	else if(emp_severity == 2.0)
		var/obj/item/stack/sheet/metal/M = pick(list_of_metal)
		if(M)
			new /obj/effect/effect/sparks(M.loc)
			H.adjustBruteLoss(-1)
			H.adjustFireLoss(-1)
			M.use(1)
			if(M.get_amount() == 0)
				list_of_metal -= M

/datum/species/tycheon/handle_death(mob/living/carbon/human/H)
	new /obj/item/weapon/reagent_containers/food/snacks/tycheon_core(H.loc)
	H.gib()

/mob/living/carbon/human/proc/metal_bend()
	set name = "Bend Metal"
	set desc = "Using metal around you to do wonders."
	set category = "Tycheon"
	if(metal_bending)
		metal_bending = FALSE
		return
	metal_bending = TRUE
	var/list/list_of_metal = list()
	for(var/obj/item/stack/sheet/metal/M in view(1, src))
		list_of_metal += M
	for(var/obj/item/stack/sheet/metal/M in list_of_metal)
		metal_retracting:
			while(M.get_amount() >= 1)
				if(!metal_bending)
					return
				if(!in_range(src, M)) // Nobody would've thought, but do_after() for any reason doesn't work here.
					break metal_retracting
				if(do_after(src, 5, TRUE, M, FALSE, TRUE))
					var/obj/item/effect/kinetic_blast/K = new(get_turf(M))
					K.name = "circling metal"
					var/obj/item/effect/kinetic_blast/K2 = new(loc)
					K2.name = "circling metal"
					switch(a_intent)
						if(I_DISARM)
							if(nutrition > 215)
								electrocuting:
									for(var/mob/living/L in view(1, src))
										if(nutrition <= 215)
											break electrocuting
										L.electrocute_act(1, src, 1.0)
										nutrition--
							else
								nutrition += 15
								if(nutrition >= 500)
									metal_bending = FALSE
									return
						if(I_GRAB)
							nutrition += 15
							if(nutrition >= 500)
								metal_bending = FALSE
								return
						if(I_HURT)
							if(nutrition > 215)
								nutrition -= 15
								empulse(src, 0, 1)
							else
								nutrition += 15
								if(nutrition >= 500)
									metal_bending = FALSE
									return
					M.use(1)
	metal_bending = FALSE

/mob/living/carbon/human/proc/toggle_sphere()
	set name = "Toggle Iron Sphere"
	set desc = "Requires metal and charge, creates an iron sphere to protect you."
	set category = "Tycheon"
	if(metal_bending)
		metal_bending = FALSE
		return
	metal_bending = TRUE
	if(istype(wear_suit, /obj/item/clothing/suit/space/rig/tycheon))
		drop_from_inventory(wear_suit, loc)
		metal_bending = FALSE
		return
	else if(!wear_suit && !head) // They use nutrition as their static charge, which is needed for telekinetic actions.
		if(nutrition < 250)
			to_chat(src, "<span class='warning'>Not enough static charge.</span>")
			metal_bending = FALSE
			return
		var/list/list_of_metal = list()
		for(var/obj/item/stack/sheet/metal/M in view(1, src))
			list_of_metal += M
		var/metal_harvested = 0
		metal_finding:
			for(var/obj/item/stack/sheet/metal/M in list_of_metal)
				metal_retracting:
					while(M.get_amount() >= 1)
						if(!metal_bending)
							return
						if(!in_range(src, M))
							break metal_retracting
						if(nutrition < 205)
							to_chat(src, "<span class='warning'>Not enough static charge.</span>")
							metal_bending = FALSE
							return
						if(do_after(src, 5, TRUE, M, FALSE, TRUE))
							nutrition -= 5
							var/obj/item/effect/kinetic_blast/K = new(M.loc)
							K.name = "circling metal"
							var/obj/item/effect/kinetic_blast/K2 = new(loc)
							K2.name = "circling metal"
							M.use(1)
							metal_harvested++
							if(metal_harvested >= 10)
								break metal_finding
						else // No refunds!
							metal_bending = FALSE
							return
		if(metal_harvested >= 10)
			var/obj/item/clothing/suit/space/rig/tycheon/TR = new /obj/item/clothing/suit/space/rig/tycheon(src)
			TR.refit_for_species(TYCHEON)
			equip_to_slot_or_del(TR, slot_wear_suit)
	metal_bending = FALSE

/obj/item/clothing/suit/space/rig/tycheon
	name = "iron sphere"
	icon_state = "sphere"
	item_state = "sphere"
	icon = 'icons/mob/species/tycheon/suit.dmi'
	slowdown = 3
	flags = HEADCOVERSEYES|BLOCKHAIR|HEADCOVERSMOUTH|THICKMATERIAL|PHORONGUARD|DROPDEL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HEAD|FACE|EYES
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HEAD|FACE|EYES
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HEAD|FACE|EYES
	max_heat_protection_temperature = 313 // See the tycheon species.
	min_cold_protection_temperature = 273
	armor = list(melee = 75, bullet = 10, laser = 10,energy = 100, bomb = 75, bio = 100, rad = 100)

/obj/item/clothing/suit/space/rig/tycheon/equipped(mob/user)
	if(ishuman(user))
		user.pass_flags &= ~(PASSMOB | PASSGRILLE | PASSCRAWL)

/obj/item/clothing/suit/space/rig/tycheon/dropped(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/effect/kinetic_blast/K = new(H.loc)
		K.name = "circling metal"
		new /obj/item/stack/sheet/metal(H.loc, 10, TRUE)
		H.pass_flags |= PASSMOB | PASSGRILLE | PASSCRAWL
		H.update_body()
	..()

/datum/species/tycheon/on_gain(mob/living/carbon/human/H)
	H.status_flags &= ~(CANSTUN | CANWEAKEN | CANPARALYSE)
	H.pass_flags |= PASSTABLE | PASSMOB | PASSGRILLE | PASSBLOB | PASSCRAWL
	H.flags |= NOSLIP
	H.mutations.Add(TK)
	H.mutations.Add(REMOTE_TALK)
	H.update_mutations()
	H.ventcrawler = TRUE
	H.verbs += /mob/living/carbon/human/proc/toggle_sphere
	H.verbs += /mob/living/carbon/human/proc/metal_bend
	H.verbs += /mob/living/carbon/human/proc/toggle_telepathy_hear
	H.verbs += /mob/living/carbon/human/proc/force_telepathy_say
	H.toggle_sphere_icon = new /obj/screen/tycheon_ability/toggle_sphere(null, H)
	H.toggle_sphere_icon.screen_loc = "EAST-2:-8,SOUTH+1:-5"
	H.metal_bend_icon = new /obj/screen/tycheon_ability/bend_metal(null, H)
	H.metal_bend_icon.screen_loc = "EAST-2:-8,SOUTH+1:7"
	if(H.hud_used)
		H.hud_used.adding += H.toggle_sphere_icon
		H.hud_used.adding += H.metal_bend_icon
	if(H.client)
		H.client.screen += H.toggle_sphere_icon
		H.client.screen += H.metal_bend_icon
	return ..()

/datum/species/tycheon/on_loose(mob/living/carbon/human/H)
	H.status_flags |= MOB_STATUS_FLAGS_DEFAULT
	H.pass_flags &= ~(PASSTABLE | PASSMOB | PASSGRILLE | PASSBLOB | PASSCRAWL)
	H.flags &= ~NOSLIP
	H.mutations.Remove(TK)
	H.mutations.Remove(REMOTE_TALK)
	H.update_mutations()
	H.ventcrawler = FALSE
	H.verbs -= /mob/living/carbon/human/proc/toggle_sphere
	H.verbs -= /mob/living/carbon/human/proc/metal_bend
	H.verbs -= /mob/living/carbon/human/proc/toggle_telepathy_hear
	H.verbs -= /mob/living/carbon/human/proc/force_telepathy_say
	if(H.hud_used)
		if(H.toggle_sphere_icon)
			H.hud_used.adding -= H.toggle_sphere_icon
		if(H.metal_bend_icon)
			H.hud_used.adding -= H.metal_bend_icon
	if(H.client)
		if(H.toggle_sphere_icon)
			H.client.screen -= H.toggle_sphere_icon
		if(H.metal_bend_icon)
			H.client.screen -= H.metal_bend_icon
	QDEL_NULL(H.toggle_sphere_icon)
	QDEL_NULL(H.toggle_sphere_icon)
	return ..()

/mob/proc/telepathy_hear(verb, message, source) // Makes all those nosy telepathics hear what we hear. Also, please do see game\sound.dm, I have a little bootleg hidden there for you ;).
	for(var/mob/M in remote_hearers)
		var/dist = get_dist(src, M)
		if(source)
			dist = get_dist(src, source)
		world.log << "[dist]"
		if(!M.do_telepathy(dist))
			continue
		var/star_chance = 0 // A chance to censore some symbols.
		if(dist > MAX_TELEPATHY_RANGE)
			star_chance += dist
		if(M.remote_listen_count > 3)
			star_chance += M.remote_listen_count * 5
		if(star_chance)
			stars(message, star_chance)
		if(prob(MAX_TELEPATHY_RANGE - dist)) // The further they are, the lesser the chance to understand something.
			to_chat(src, "<span class='warning'>You feel as if somebody is eavesdropping on you.</span>")
		to_chat(M, "<span class='bold'>[src]</span> [verb]: [message]")

/mob/living/carbon/human/proc/toggle_telepathy_hear(mob/M in view()) // Makes us hear what they hear.
	set name = "Toggle Telepathy Hear"
	set desc = "Hear anything this mob hears."
	set category = "Tycheon"
	if(src in M.remote_hearers)
		M.remote_hearers -= src
		to_chat(src, "<span class='notice'>You stop telepathically eavesdropping on [M]")
		remote_listen_count--
	else
		if(remote_listen_count > 3)
			if(alert("Listening to more than three people may distort your perception, continue?", "Yes", "No") != "Yes")
				return
		M.remote_hearers += src
		to_chat(src, "<span class='notice'>You start telepathically eavesdropping on [M]")
		remote_listen_count++

/mob/living/carbon/human/proc/force_telepathy_say(mob/M in view()) // Makes them hear what we want.
	set name = "Project Mind"
	set desc = "Make them hear what you desire."
	set category = "Tycheon"
	var/say = input ("What do you wish to say")
	if(!say)
		return
	else
		say = sanitize(say)
	if(REMOTE_TALK in M.mutations)
		to_chat(M, "<span class='notice'>You hear <span class='bold'>[real_name]'s voice</span>: [say]")
	else
		to_chat(M, "<span class='notice>You hear a voice that seems to echo around the room: </span>[say]")
	to_chat(src, "<span class='notice'>You project your mind into <span class='bold'>[M.real_name]</span>: [say]")
	for(var/mob/dead/observer/G in dead_mob_list)
		to_chat(G, "<span class='italics'>Telepathic message from <span class='bold italics'>[src]</span> <span class='italics'>to</span> <span class = 'bold italics'>[M]</span>: [say]")
	log_say("Telepathic message from [key_name(src)] to [key_name(M)]: [say]")
