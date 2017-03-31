/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species
	var/name                     // Species name.

	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.
	var/damage_mask = TRUE
	var/eyes = "eyes_s"                                  // Icon for eyes.

	var/backward_form            // Mostly used in genetic (human <-> monkey), if null - gibs user when transformation happens.
	var/tail                     // Name of tail image in species effects icon file.
	var/language                 // Default racial language, if any.
	var/unarmed                  //For empty hand harm-intent attack
	var/unarmed_type = /datum/unarmed_attack
	var/secondary_langs = list() // The names of secondary languages that are available to this species.
	var/attack_verb = "punch"    // Empty hand hurt intent verb.
	var/punch_damage = 0		 // Extra empty hand attack damage.
	var/mutantrace               // Safeguard due to old code.

	var/breath_type = "oxygen"   // Non-oxygen gas breathed, if any.
	var/poison_type = "phoron"   // Poisonous air.
	var/exhale_type = "C02"      // Exhaled gas type.

	var/cold_level_1 = 260  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 1000 // Heat damage level 3 above this point.

	var/body_temperature = 310.15	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/synth_temp_gain = 0			//IS_SYNTHETIC species will gain this much temperature every second
	var/reagent_tag                 //Used for metabolizing reagents.

	var/darksight = 2
	var/nighteyes = 0
	var/sightglassesmod = 0
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/brute_mod = null    // Physical damage reduction/malus.
	var/burn_mod = null     // Burn damage reduction/malus.
	var/speed_mod = 0		//How fast or slow specific specie.

	var/list/flags = list()       // Various specific features.

	var/list/abilities = list()	// For species-derived or admin-given powers

	var/blood_color = "#A10808" //Red.
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

/datum/species/New()
	unarmed = new unarmed_type()

/datum/species/proc/create_organs(mob/living/carbon/C) //Handles creation of mob bodyparts and organs.
	//This is a basic humanoid limb setup.
	switch(name)
		if(S_HUMAN,S_UNATHI,S_TAJARAN,S_SKRELL,S_DIONA,S_VOX,S_VOX_ARMALIS,S_IPC,S_ABDUCTOR,S_SHADOWLING)
			C.make_blood()
			C.bodyparts = list()
			C.bodyparts_by_name[BP_CHEST] = new/obj/item/bodypart/chest(null)
			C.bodyparts_by_name[BP_GROIN] = new/obj/item/bodypart/groin(null, C.bodyparts_by_name[BP_CHEST])
			C.bodyparts_by_name[BP_HEAD] = new/obj/item/bodypart/head(null, C.bodyparts_by_name[BP_CHEST])
			C.bodyparts_by_name[BP_L_ARM] = new/obj/item/bodypart/l_arm(null, C.bodyparts_by_name[BP_CHEST])
			C.bodyparts_by_name[BP_R_ARM] = new/obj/item/bodypart/r_arm(null, C.bodyparts_by_name[BP_CHEST])
			C.bodyparts_by_name[BP_R_LEG] = new/obj/item/bodypart/r_leg(null, C.bodyparts_by_name[BP_GROIN])
			C.bodyparts_by_name[BP_L_LEG] = new/obj/item/bodypart/l_leg(null, C.bodyparts_by_name[BP_GROIN])

			C.organs = list()
			C.organs_by_name[BP_HEART] = new/obj/item/organ/heart(null, C)
			C.organs_by_name[BP_LUNGS] = new/obj/item/organ/lungs(null, C)
			C.organs_by_name[BP_LIVER] = new/obj/item/organ/liver(null, C)
			C.organs_by_name[BP_KIDNEYS] = new/obj/item/organ/kidney(null, C)
			C.organs_by_name[BP_BRAIN] = new/obj/item/organ/brain(null, C)
			C.organs_by_name[BP_EYES] = new/obj/item/organ/eyes(null, C)

			for(var/name in C.bodyparts_by_name)
				C.bodyparts += C.bodyparts_by_name[name]

			for(var/obj/item/bodypart/BP in C.bodyparts)
				BP.owner = C

			if(flags[IS_SYNTHETIC])
				for(var/obj/item/bodypart/BP in C.bodyparts)
					if(BP.status & ORGAN_CUT_AWAY || BP.status & ORGAN_DESTROYED)
						continue
					BP.status |= ORGAN_ROBOT
				for(var/obj/item/organ/IO in C.organs)
					IO.mechanize()

/datum/species/proc/handle_post_spawn(mob/living/carbon/C) //Handles anything not already covered by basic species assignment.
	return

/datum/species/proc/handle_death(mob/living/carbon/C) //Handles any species-specific death events (such nymph spawns).
	if(flags[IS_SYNTHETIC])
 //H.make_jittery(200) //S-s-s-s-sytem f-f-ai-i-i-i-i-lure-ure-ure-ure
		C.h_style = ""
		spawn(100)
			//H.is_jittery = 0
			//H.jitteriness = 0
			C.update_hair()

/datum/species/monkey
	name = S_MONKEY
	backward_form = /mob/living/carbon/human
	unarmed_type = /datum/unarmed_attack/punch

/datum/species/monkey/human
	name = S_HUMAN
	language = "Sol Common"
	backward_form = /mob/living/carbon/monkey
	unarmed_type = /datum/unarmed_attack/punch

	flags = list(
	 HAS_SKIN_TONE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_HAIR = TRUE
	)

	//If you wanted to add a species-level ability:
	/*abilities = list(/client/proc/test_ability)*/

/datum/species/stok
	name = S_MONKEY_U
	backward_form = /mob/living/carbon/human/unathi

/datum/species/stok/unathi
	name = S_UNATHI
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = "Sinta'unathi"
	tail = "sogtail"
	unarmed_type = /datum/unarmed_attack/claws
	backward_form = /mob/living/carbon/monkey/unathi
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

	reagent_tag = IS_UNATHI
	base_color = "#066000"

/datum/species/farwa
	name = S_MONKEY_T
	backward_form = /mob/living/carbon/human/tajaran

/datum/species/farwa/tajaran
	name = S_TAJARAN
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	language = "Siik'maas"
	secondary_langs = list("Siik'tajr")
	tail = "tajtail"
	unarmed_type = /datum/unarmed_attack/claws
	darksight = 8
	nighteyes = 1

	cold_level_1 = 200 //Default 260
	cold_level_2 = 140 //Default 200
	cold_level_3 = 80 //Default 120

	heat_level_1 = 330 //Default 360
	heat_level_2 = 380 //Default 400
	heat_level_3 = 800 //Default 1000

	backward_form = /mob/living/carbon/monkey/tajara

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

/datum/species/neaera
	name = S_MONKEY_S
	backward_form = /mob/living/carbon/human/skrell

/datum/species/neaera/skrell
	name = S_SKRELL
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = "Skrellian"
	backward_form = /mob/living/carbon/monkey/skrell
	unarmed_type = /datum/unarmed_attack/punch

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_SKIN_COLOR = TRUE
	)

	eyes = "skrell_eyes_s"

	flesh_color = "#8CD7A3"

	reagent_tag = IS_SKRELL

/datum/species/vox
	name = S_VOX
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	language = "Vox-pidgin"
	unarmed_type = /datum/unarmed_attack/claws	//I dont think it will hurt to give vox claws too.

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"

	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = list(
	 NO_SCAN = TRUE
	,NO_BLOOD = TRUE
	)

	blood_color = "#2299FC"
	flesh_color = "#808D11"
	reagent_tag = IS_VOX

	sprite_sheets = list(
		"suit" = 'icons/mob/species/vox/suit.dmi',
		"head" = 'icons/mob/species/vox/head.dmi',
		"mask" = 'icons/mob/species/vox/masks.dmi',
		"feet" = 'icons/mob/species/vox/shoes.dmi',
		"gloves" = 'icons/mob/species/vox/gloves.dmi'
		)

/datum/species/vox/handle_post_spawn(mob/living/carbon/C)
	C.verbs += /mob/living/carbon/human/proc/leap
	..()

/datum/species/vox/armalis/handle_post_spawn(mob/living/carbon/C)
	C.verbs += /mob/living/carbon/human/proc/gut
	..()

/datum/species/vox/armalis
	name = S_VOX_ARMALIS
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	deform = 'icons/mob/human_races/r_armalis.dmi'
	damage_mask = FALSE
	language = "Vox-pidgin"
	unarmed_type = /datum/unarmed_attack/claws/armalis

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
	,NO_EMBED = TRUE
	)

	blood_color = "#2299FC"
	flesh_color = "#808D11"
	reagent_tag = IS_VOX
	tail = "armalis_tail"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

	sprite_sheets = list(
		"suit" = 'icons/mob/species/armalis/suit.dmi',
		"gloves" = 'icons/mob/species/armalis/gloves.dmi',
		"feet" = 'icons/mob/species/armalis/feet.dmi',
		"head" = 'icons/mob/species/armalis/head.dmi',
		"held" = 'icons/mob/species/armalis/held.dmi'
		)

/datum/species/nymph
	name = S_MONKEY_D
	backward_form = /mob/living/carbon/human/diona

/datum/species/nymph/diona
	name = S_DIONA
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	language = "Rootspeak"
	unarmed_type = /datum/unarmed_attack/diona
	backward_form = /mob/living/carbon/monkey/diona

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	speed_mod = 7

	body_temperature = T0C + 15		//make the plant people have a bit lower body temperature, why not

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

	blood_color = "#004400"
	flesh_color = "#907E4A"

	reagent_tag = IS_DIONA

/datum/species/diona/handle_post_spawn(mob/living/carbon/C)
	C.gender = NEUTER

	return ..()

/datum/species/diona/handle_death(mob/living/carbon/C)

	var/mob/living/carbon/monkey/diona/S = new(get_turf(C))

	if(C.mind)
		C.mind.transfer_to(S)

	for(var/mob/living/carbon/monkey/diona/D in C.contents)
		if(D.client)
			D.loc = C.loc
		else
			qdel(D)

	C.visible_message("\red[C] splits apart with a wet slithering noise!")

/datum/species/machine
	name = S_IPC
	icobase = 'icons/mob/human_races/r_machine.dmi'
	deform = 'icons/mob/human_races/r_machine.dmi'
	language = "Tradeband"
	unarmed_type = /datum/unarmed_attack/punch

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

	blood_color = "#1F181F"
	flesh_color = "#575757"

/datum/species/abductor
	name = S_ABDUCTOR
	darksight = 3

	icobase = 'icons/mob/human_races/r_abductor.dmi'
	deform = 'icons/mob/human_races/r_abductor.dmi'

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_SCAN = TRUE
	,VIRUS_IMMUNE = TRUE
	)

	blood_color = "#BCBCBC"

/datum/species/abductor/handle_post_spawn(mob/living/carbon/C)
	C.gender = NEUTER

	return ..()

/datum/species/skeleton
	name = S_SKELETON

	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'
	damage_mask = FALSE

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_SCAN = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_EMBED = TRUE
	)

/datum/species/skeleton/handle_post_spawn(mob/living/carbon/C)
	C.gender = NEUTER

	return ..()

/datum/species/shadowling
	name = S_SHADOWLING
	icobase = 'icons/mob/human_races/r_shadowling.dmi'
	deform = 'icons/mob/human_races/r_def_shadowling.dmi'
	language = "Sol Common"
	unarmed_type = /datum/unarmed_attack/claws

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	blood_color = "#000000"
	darksight = 8

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	,NO_EMBED = TRUE
	)
	burn_mod = 2 //2x burn damage lel


/datum/species/shadowling/handle_post_spawn(mob/living/carbon/C)
	C.gender = NEUTER
	return ..()


// Species unarmed attacks
/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// Extra empty hand attack damage.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = 0
	var/edge = 0

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

/datum/species/slime
	name = S_SLIME

	flags = list(
	 NO_EMBED = TRUE
	)

/datum/species/alien
	flags = list(
	 NO_EMBED = TRUE
	)

/datum/species/alien/facehugger
	name = S_XENO_FACE

/datum/species/alien/larva
	name = S_XENO_LARVA
	backward_form = /mob/living/carbon/alien/facehugger

/datum/species/alien/adult
	name = S_XENO_ADULT
	unarmed_type = /datum/unarmed_attack/claws
	backward_form = /mob/living/carbon/alien/larva

/datum/species/alien/adult/queen
	name = S_XENO_QUEEN
	backward_form = /mob/living/carbon/alien/humanoid/drone

/datum/species/dog
	name = S_DOG
