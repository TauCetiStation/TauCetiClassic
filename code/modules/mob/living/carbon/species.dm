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
	var/mutantrace                    // Safeguard due to old code.
	var/list/butcher_drops = list(/obj/item/weapon/reagent_containers/food/snacks/meat/human = 5)

	var/list/unarmed_attacks = list()          // For empty hand harm-intent attack
	var/list/unarmed_attack_types = list(/datum/unarmed_attack)

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
	for(var/type in unarmed_attack_types)
		unarmed_attacks += new type()

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

/datum/species/proc/regen(mob/living/carbon/human/H, light_amount, External) // Perhaps others will regenerate in different ways?
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
	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/kick, /datum/unarmed_attack/bite)
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
	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/punch/claws, /datum/unarmed_attack/kick, /datum/unarmed_attack/bite/unathi)
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
	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/punch/claws, /datum/unarmed_attack/kick, /datum/unarmed_attack/bite)
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
	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/kick, /datum/unarmed_attack/bite)
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
	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/punch/claws, /datum/unarmed_attack/kick, /datum/unarmed_attack/bite) //I dont think it will hurt to give vox claws too.
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
	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/punch/claws/armalis, /datum/unarmed_attack/kick, /datum/unarmed_attack/bite)
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
	unarmed_attack_types = list(/datum/unarmed_attack/punch/diona, /datum/unarmed_attack/kick)
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
	)

	blood_color = /datum/dirt_cover/green_blood
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

	blood_color = "#004400"
	flesh_color = "#907E4A"

	has_gendered_icons = FALSE

/datum/species/diona/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/diona/regen(mob/living/carbon/human/H, light_amount, External)
	if(light_amount >=5) // If you can regen organs - do so.
		for(var/obj/item/organ/internal/O in H.organs)
			if(O.damage)
				O.damage -= light_amount/10
				H.nutrition -= light_amount
				return
			continue
	if(H.nutrition > 350 && light_amount >= 4) // If you don't need to regen organs, regen bodyparts.
		External = H.find_damaged_bodypart(External)
		if(External)
			H.nutrition -= 1
			H.apply_damages(0,0,1,1,0,0)
			H.regen_bodyparts(External, TRUE)
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
	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/punch/ipc, /datum/unarmed_attack/kick)
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
	)

	blood_color = /datum/dirt_cover/oil
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

	blood_color = "#1F181F"
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

	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/kick)

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

	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/kick)

/datum/species/skeleton/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/skeleton/call_digest_proc(mob/living/M, datum/reagent/R)
	return R.on_skeleton_digest(M)

/datum/species/shadowling
	name = SHADOWLING
	icobase = 'icons/mob/human_races/r_shadowling.dmi'
	deform = 'icons/mob/human_races/r_shadowling.dmi'
	language = "Sol Common"
	unarmed_attack_types = list(/datum/unarmed_attack/punch/claws, /datum/unarmed_attack/hypnosis)
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
		NO_FINGERPRINT = TRUE
		)

	has_organ = list(
		O_BRAIN = /obj/item/organ/internal/brain
		)

	has_gendered_icons = FALSE

	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/kick)

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
	speed_mod = -0.2

	unarmed_attack_types = list(/datum/unarmed_attack/punch, /datum/unarmed_attack/kick, /datum/unarmed_attack/bite)// This could be made into something interesting.

	var/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')

/datum/species/zombie/handle_post_spawn(mob/living/carbon/human/H)
	return ..()

/datum/species/zombie/on_gain(mob/living/carbon/human/H)
	H.status_flags &= ~(CANSTUN  | CANPARALYSE) //CANWEAKEN

	H.drop_l_hand()
	H.drop_r_hand()

	H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand, slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand/right, slot_r_hand)

	for(var/obj/item/organ/external/organ in H.bodyparts)
		organ.status |= ORGAN_ZOMBIE

	return ..()

/datum/species/zombie/on_loose(mob/living/carbon/human/H)
	H.status_flags |= MOB_STATUS_FLAGS_DEFAULT

	if(istype(H.l_hand, /obj/item/weapon/melee/zombie_hand))
		qdel(H.l_hand)

	if(istype(H.r_hand, /obj/item/weapon/melee/zombie_hand))
		qdel(H.r_hand)

	for(var/obj/item/organ/external/organ in H.bodyparts)
		organ.status &= ~ORGAN_ZOMBIE

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
	speed_mod = 0.5

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

//Species unarmed attacks

/datum/unarmed_attack
	var/name = ""

	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// Extra empty hand attack damage.
	var/dam_type = BRUTE                // Empty hand damage type. W-o-a-h.
	var/attack_sound = "punch"
	var/weaken_chance = 0
	var/override_in_hand_attack = TRUE     // If TRUE, this attack will override, even if user has something in his hand.

	var/body_zone_required = null    // If this is specified, check whether this body zone is not broken.
	var/restrained_zone_check = null // Check this zone when we check in RestrainedClickOn()
	var/require_zone_naked = FALSE   // If TRUE, check if above body zone is covered with clothing. If it is, don't do the attack.

	var/list/hit_scope = list()      // I mean, it's much harder to bite a leg, than to bite a hand.
	var/none_scope_miss_chance = 0   // A chance to hit another bodypart, if target is not in hit_scope.
	var/miss_chance = 0              // Some attacks have additional miss chance.

	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = FALSE
	var/edge = FALSE

	var/overlay_icon

/datum/unarmed_attack/proc/damage_flags()
	return (sharp ? DAM_SHARP : 0) | (edge ? DAM_EDGE : 0)

/datum/unarmed_attack/proc/on_harm_intent(mob/living/victim, mob/living/carbon/human/predator, weaken_chance_multi = 1.0)
	predator.attack_log += text("\[[time_stamp()]\] <font color='red'>[pick(attack_verb)]ed [victim] ([victim.ckey])</font>")
	victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [pick(attack_verb)]ed by [predator.name] ([predator.ckey])</font>")
	msg_admin_attack("[key_name(predator)] [pick(attack_verb)]ed [key_name(victim)]")

	var/obj/item/organ/external/BP = zone_parsing(predator.zone_sel.selecting, victim)
	var/armor_block = victim.run_armor_check(BP, "melee")

	if(!check_requirements(victim, predator, BP)) // for example our mouth is covered yet we try to bite.
		return FALSE

	var/damage = rand(0, 5)//BS12 EDIT
	if(!damage || prob(miss_chance))
		playsound(victim.loc, miss_sound, 25, 1, -1)
		victim.visible_message("<span class='warning bold'>[predator] tried to [pick(attack_verb)] [victim]!</span>")
		return FALSE

	if(HULK in predator.mutations)
		damage += 5

	playsound(victim.loc, attack_sound, 25, 1, -1)

	victim.visible_message(get_message(victim, predator))

	//Rearranged, so weaken chance depends on the chance given by the attack.
	if(damage >= 5 && prob(weaken_chance * weaken_chance_multi))
		victim.visible_message("<span class='warning bold'>[predator] has weakened [victim]!</span>")
		victim.apply_effect(2, WEAKEN, armor_block)

	damage += src.damage
	victim.apply_damage(damage, dam_type, BP, armor_block, damage_flags())
	after_attack_effects(victim, predator, BP, damage)
	return TRUE

/datum/unarmed_attack/proc/zone_parsing(zone, mob/living/victim)
	if(!(zone in hit_scope) && prob(none_scope_miss_chance))
		zone = pick(hit_scope)

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		return H.bodyparts_by_name[ran_zone(zone)]
	return BP_CHEST

/datum/unarmed_attack/proc/get_message(mob/living/victim, mob/living/carbon/human/predator)
	return "<span class='warning bold'>[predator] [pick(attack_verb)]ed [victim]!</span>"

/datum/unarmed_attack/proc/check_requirements(mob/victim, mob/living/carbon/human/predator, obj/item/organ/external/BP)
	if(!body_zone_required)
		return TRUE

	var/obj/item/organ/external/BP_pred
	var/check_this_zone

	if(body_zone_required == ARMS)
		if(predator.hand)
			BP_pred = predator.get_bodypart(BP_L_ARM)
			check_this_zone = BP.body_part
		else
			BP_pred = predator.get_bodypart(BP_R_ARM)
	else if(body_zone_required == LEGS)
		if(predator.hand)
			BP_pred = predator.get_bodypart(BP_L_LEG)
		else
			BP_pred = predator.get_bodypart(BP_R_LEG)
	else
		BP_pred = predator.get_bodypart(body_zone_required)

	if(body_zone_required == O_MOUTH) // Mouth has no organ, and no bodypart. A sad reality of bootlegs.
		check_this_zone = FACE
	else if(body_zone_required == O_EYES) // I don't know, perhaps we will have a specie that will freeze with it's eyes.
		check_this_zone = EYES
	else
		check_this_zone = BP_pred.body_part

	// Bodypart usability check.
	if(!BP_pred || !BP_pred.is_usable())
		return FALSE

	// Bodypart cloth coverage check.
	var/list/body_parts = list(predator.head, predator.wear_mask, predator.wear_suit, predator.w_uniform, predator.gloves, predator.shoes)
	if(require_zone_naked)
		for(var/slot in body_parts)
			if(istype(slot, /obj/item/clothing))
				var/obj/item/clothing/C = slot
				if(C.body_parts_covered & check_this_zone)
					if(C.flags & THICKMATERIAL)
						to_chat(predator, "<span class='warning'>[C] is blocking the attempts to [pick(attack_verb)]!</span>")
						return FALSE
					if(C.slowdown >= 1)
						to_chat(predator, "<span class='warning'>With [C] on me, I am too slow to perform [pick(attack_verb)]!</span>")
						return FALSE
	return TRUE

/datum/unarmed_attack/proc/after_attack_effects(mob/victim, mob/living/carbon/human/predator, obj/item/organ/external/BP, damage)

/datum/unarmed_attack/punch
	name = "punch"
	overlay_icon = "punch"
	attack_verb = list("punch")
	weaken_chance = 50
	damage = 1

	override_in_hand_attack = FALSE

	body_zone_required = ARMS
	restrained_zone_check = ARMS

/datum/unarmed_attack/punch/diona
	name = "lash"
	overlay_icon = "lash"
	attack_verb = list("lash", "bludgeon")
	weaken_chance = 75
	damage = 5

/datum/unarmed_attack/punch/ipc
	name = "electrify"
	overlay_icon = "shock"
	attack_verb = list("stir", "jolt")
	weaken_chance = 100
	dam_type = BURN

/datum/unarmed_attack/punch/ipc/check_requirements(mob/victim, mob/living/carbon/human/predator, obj/item/organ/external/BP)
	. = ..()
	if(predator.nutrition <= 0)
		to_chat(predator, "<span class='warning'>You do not have enough charge to perform [pick(attack_verb)]!</span>")
		return FALSE

/datum/unarmed_attack/punch/ipc/after_attack_effects(mob/living/victim, mob/living/carbon/human/predator, obj/item/organ/external/BP, damage)
	if(iscarbon(victim))
		var/mob/living/carbon/C = victim
		C.electrocute_act(damage, src, predator.species.siemens_coefficient, BP.body_zone)
	// Yes, we remove nutriments, even if we did not actually ELECTRIFY the mob. I mean we did do burn damage.
	predator.nutrition = max(predator.nutrition -= damage * 30, 0) // * 20 is RANDOMLY CHOSEN. Yes it is a magic number, but we need to consume huge amounts of energy for... BALANCE(TM)

/datum/unarmed_attack/punch/claws
	name = "scratch"
	overlay_icon = "scratch"
	attack_verb = list("scratch", "claw")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'

	damage = 5
	sharp = TRUE
	edge = TRUE

	require_zone_naked = TRUE

/datum/unarmed_attack/punch/claws/armalis
	attack_verb = list("slash", "claw")
	damage = 10	//they're huge! they should do a little more damage, i'd even go for 15-20 maybe...

/datum/unarmed_attack/kick
	name = "kick"
	overlay_icon = "kick"
	attack_verb = list("kick")
	attack_sound = 'sound/weapons/genhit.ogg'
	weaken_chance = 75

	hit_scope = list(BP_L_LEG, BP_R_LEG, BP_GROIN)
	none_scope_miss_chance = 75
	miss_chance = 15
	//var/push_chance = 10 // A chance to push the opponent one tile. See lower.

	body_zone_required = LEGS
	restrained_zone_check = LEGS

/* Uncomment this when it will be done.
/datum/unarmed_attack/kick/on_disarm_intent(mob/living/victim, mob/living/carbon/human/predator)
	if(prob(push_chance))
		step(victim, predator.dir) */

/datum/unarmed_attack/kick/zone_parsing(zone, mob/living/victim, mob/living/carbon/human/predator)
	if(victim.weakened ||victim.lying || victim.crawling)
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			return H.bodyparts_by_name[ran_zone(zone)]
		return BP_CHEST
	return ..()

/datum/unarmed_attack/kick/get_message(mob/living/victim, mob/living/carbon/human/predator)
	if(victim.weakened || victim.lying || victim.crawling)
		return "<span class='warning bold'>[predator] stomped on [victim]!</span>"
	else
		return ..()

/datum/unarmed_attack/kick/check_requirements(mob/living/victim, mob/living/carbon/human/predator, obj/item/organ/external/BP)
	. = ..()
	if(predator.legcuffed)
		to_chat(predator, "<span class='warning'>You can not [pick(attack_verb)] with [predator.legcuffed] on you!</span>")
		return FALSE

/datum/unarmed_attack/kick/after_attack_effects(mob/living/victim, mob/living/carbon/human/predator, obj/item/organ/external/BP)
	if(victim.weakened || victim.lying || victim.crawling)
		victim.adjustHalLoss(damage)
		victim.updatehealth()
	else if(!(predator.zone_sel.selecting in hit_scope) && prob(miss_chance)) // A chance that we will slip and fall.
		to_chat(predator, "<span class='warning'>You aimed so high, that you slipped up and fell!</span>")
		predator.slip(null, 3, 2)

/datum/unarmed_attack/bite
	name = "bite"
	overlay_icon = "bite"
	attack_verb = list("chew", "chaw")
	attack_sound = 'sound/items/eatfood.ogg'
	miss_sound = 'sound/items/eatfood.ogg'
	weaken_chance = 0

	hit_scope = list(BP_L_ARM, BP_R_ARM, BP_HEAD)
	none_scope_miss_chance = 75
	miss_chance = 25

	body_zone_required = O_MOUTH
	require_zone_naked = TRUE

	sharp = TRUE

/datum/unarmed_attack/bite/check_requirements(mob/victim, mob/living/carbon/human/predator, obj/item/organ/external/BP)
	. = ..()
	if(ishuman(victim))
		if(BP.status & ORGAN_ROBOT)
			to_chat(predator, "<span class='warning'>You can not bite a robotic limb!</span>")
			var/obj/item/organ/external/head/head_ = predator.get_bodypart(BP_HEAD)
			if(head_)
				predator.apply_damage(2, BRUTE, head_)
			else
				predator.adjustBruteLoss(2)
			return FALSE

/datum/unarmed_attack/bite/unathi

/datum/unarmed_attack/bite/unathi/after_attack_effects(mob/victim, mob/living/carbon/human/predator, obj/item/organ/external/BP, damage)
	if(iscarbon(victim))
		var/mob/living/carbon/C = victim
		C.spread_disease_to(predator, "Contact")
		predator.spread_disease_to(C, "Contact")

		if(ishuman(victim))
			var/mob/living/carbon/human/H  = C

			var/armor = H.getarmor(BP.body_zone, "melee")
			var/bioarmor = H.getarmor(BP.body_zone, "bio")

			if(prob(max(100 - max(armor, bioarmor / 2), 0)))
				for(var/datum/wound/W in BP.wounds)
					if (W.infection_check())
						W.germ_level++

/datum/unarmed_attack/hypnosis
	name = "bite"
	overlay_icon = "hypnotize" // Placeholder, but it does give the message.
	attack_verb = list("charm", "drug")
	attack_sound = null
	miss_sound = null

	weaken_chance = 0
	miss_chance = 0

/datum/unarmed_attack/hypnosis/after_attack_effects(mob/living/victim, mob/living/carbon/human/predator, obj/item/organ/external/BP, damage)
	victim.adjustBrainLoss(damage)
	victim.hallucination = min(victim.hallucination + 10, 50)
	var/list/creepyasssounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',
                                    'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',
                                    'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',
                                    'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',
                                    'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
	victim << pick(creepyasssounds)