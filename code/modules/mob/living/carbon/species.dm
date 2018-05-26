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

	var/primitive                     // Lesser form, if any (ie. monkey for humans)
	var/tail                          // Name of tail image in species effects icon file.
	var/language                      // Default racial language, if any.
	var/force_racial_language = FALSE // If TRUE, racial language will be forced by default when speaking.
	var/attack_verb = "punch"         // Empty hand hurt intent verb.
	var/punch_damage = 0              // Extra empty hand attack damage.
	var/mutantrace                    // Safeguard due to old code.
	var/list/butcher_drops = list(/obj/item/weapon/reagent_containers/food/snacks/meat/human = 5)

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

/datum/species/proc/regen(mob/living/carbon/human/H) // Perhaps others will regenerate in different ways?
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
	)

	flesh_color = "#34AF10"
	base_color = "#066000"

/datum/species/tajaran
	name = TAJARAN
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	language = "Siik'maas"
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

/datum/species/skrell
	name = SKRELL
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = "Skrellian"
	primitive = /mob/living/carbon/monkey/skrell
	unarmed_type = /datum/unarmed_attack/punch
	dietflags = DIET_HERB
	metabolism_mod = SKRELL_METABOLISM_FACTOR
	taste_sensitivity = TASTE_SENSITIVITY_DULL

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

	hazard_low_pressure = DIONA_HAZARD_LOW_PRESSURE

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	burn_mod = 1.3
	speed_mod = 7

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
	)

	blood_color = /datum/dirt_cover/gray_blood

/datum/species/abductor/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/skeleton
	name = SKELETON

	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'
	damage_mask = FALSE
	dietflags = 0

	butcher_drops = list()

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_SCAN = TRUE
	,VIRUS_IMMUNE = TRUE
	)

/datum/species/skeleton/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

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

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	blood_color = /datum/dirt_cover/black_blood
	darksight = 8

	butcher_drops = list() // They are just shadows. Why should they drop anything?

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_EMBED = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	)

	burn_mod = 2

	has_gendered_icons = FALSE


/datum/species/shadowling/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/golem
	name = GOLEM

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'
	dietflags = 0 //this is ROCK

	total_health = 200
	oxy_mod = 0
	tox_mod = 0
	brain_mod = 0
	speed_mod = 2

	blood_color = /datum/dirt_cover/adamant_blood
	flesh_color = "#137E8F"

	butcher_drops = list(/obj/item/weapon/ore/diamond = 1, /obj/item/weapon/ore/slag = 3)

	flags = list(
		NO_BLOOD = TRUE,
		NO_BREATHE = TRUE,
		NO_SCAN = TRUE,
		NO_PAIN = TRUE,
		NO_EMBED = TRUE,
		RAD_IMMUNE = TRUE,
		VIRUS_IMMUNE = TRUE,
		BIOHAZZARD_IMMUNE = TRUE,
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
