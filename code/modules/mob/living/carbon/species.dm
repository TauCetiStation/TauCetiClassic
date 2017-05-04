/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

var/list/male_scream_sound = list('sound/misc/malescream1.ogg', 'sound/misc/malescream2.ogg', 'sound/misc/malescream3.ogg', 'sound/misc/malescream4.ogg', 'sound/misc/malescream5.ogg')
var/list/female_scream_sound = list('sound/misc/femalescream1.ogg', 'sound/misc/femalescream2.ogg', 'sound/misc/femalescream3.ogg', 'sound/misc/femalescream4.ogg', 'sound/misc/femalescream5.ogg')

/datum/species
	var/name                     // Species name.

	// Icon/appearance vars.
	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.

	// Damage overlay and masks.
	var/damage_overlays = 'icons/mob/human_races/masks/human_damage_overlays.dmi'
	var/blood_overlays = 'icons/mob/human_races/masks/human_blood_overlays.dmi'
	var/stump_overlays = "_human"

	var/has_screamSound = FALSE

	var/eyes_icon = "eyes"                                  // Icon for eyes.

	var/show_ssd = "fast asleep"

	var/backward_form            // Mostly used in genetic (human <-> monkey), if null - gibs user when transformation happens.
	var/tail                     // Name of tail image in species effects icon file.
	var/ears                     // Name of ears image in species effects icon file.
	var/language                 // Default racial language, if any.

	// Combat vars.
	var/total_health = 100                   // Point at which the mob will enter crit.
	var/list/unarmed_types = list(           // Possible unarmed attacks that the mob will use in combat,
		/datum/unarmed_attack,
		/datum/unarmed_attack/bite
		)
	var/list/unarmed_attacks = null          // For empty hand harm-intent attack

	// Death vars.
	var/knockout_message = "has been knocked unconscious!"

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

	var/blood_volume = 560 // Initial blood volume.
	var/blood_color = "#A10808" //Red.
	var/flesh_color = "#FFC896" //Pink.
	var/base_color      //Used when setting species.

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		slot_wear_suit = 'icons/mob/path',
		slot_belt = 'icon_mob/path'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/

	var/has_a_intent = TRUE  // Set to draw intent box.
	var/has_m_intent = TRUE  // Set to draw move intent box.
	var/has_hands = TRUE     // Set to draw hands.
	var/has_drop = TRUE      // Set to draw drop button.
	var/has_throw = TRUE     // Set to draw throw button.
	var/has_resist = TRUE    // Set to draw resist button.
	var/has_internals = TRUE // Set to draw the internals toggle button.
	var/has_gun_aim_control = TRUE // Set to draw gun setting button.

	var/num_of_hands = 2
	var/num_of_legs = 2

	var/list/sprite_sheets = list()

	//This is default bodyparts & organs set which is mostly used upon mob creation.
	var/list/has_bodypart = list( // Keep in mind that this list also acts as priority for creating bodyparts/organs inside spawned mob.
		BP_CHEST = /obj/item/bodypart/chest // If chest is a main bodypart, it must be on top of the list, since everything else depends on it.
		,BP_GROIN = /obj/item/bodypart/groin
		,BP_HEAD  = /obj/item/bodypart/head
		,BP_L_ARM = /obj/item/bodypart/arm
		,BP_R_ARM = /obj/item/bodypart/arm/right
		,BP_L_LEG = /obj/item/bodypart/leg
		,BP_R_LEG = /obj/item/bodypart/leg/right
		)

	var/list/has_organ = list(
		BP_HEART   = /obj/item/organ/heart
		,BP_BRAIN   = /obj/item/organ/brain
		,BP_EYES    = /obj/item/organ/eyes
		,BP_LUNGS   = /obj/item/organ/lungs
		,BP_LIVER   = /obj/item/organ/liver
		,BP_KIDNEYS = /obj/item/organ/kidneys
		,BP_APPENDIX = /obj/item/organ/appendix
		)

	var/breathing_sound = 'sound/voice/monkey.ogg'

/datum/species/New()
	unarmed_attacks = list()

	for(var/u_type in unarmed_types)
		unarmed_attacks += new u_type()

/datum/species/proc/create_organs(mob/living/carbon/C, list/organ_data, force_rebuild) //Handles creation of mob bodyparts and organs.
	//This is a basic humanoid limb setup.
	C.make_blood()

	if(force_rebuild)
		for(var/obj/item/bodypart/BP in C.bodyparts)
			qdel(BP)
		for(var/obj/item/organ/IO in C.organs)
			qdel(IO)

	if(!organ_data || !organ_data.len)
		for(var/type in has_bodypart)
			var/path = has_bodypart[type]
			new path(null, C)
	else
		for(var/type in has_bodypart)
			var/status = organ_data[type]
			if(status)
				if(status == "amputated")
					var/obj/item/bodypart/path = has_bodypart[type]
					var/obj/item/bodypart/stump/stump = new (null, C, path)
					stump.status |= ORGAN_CUT_AWAY
					continue

			var/path = has_bodypart[type]
			new path(null, C)

	for(var/type in has_organ)
		var/path = has_organ[type]
		new path(null, C)

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
	backward_form = S_HUMAN
	unarmed_types = list(/datum/unarmed_attack/bite, /datum/unarmed_attack/claws)
	icobase = 'icons/mob/human_races/monkeys/r_monkey.dmi'
	deform = 'icons/mob/human_races/monkeys/r_monkey.dmi'
	damage_overlays = 'icons/mob/human_races/masks/monkey_damage_overlays.dmi'
	blood_overlays = 'icons/mob/human_races/masks/monkey_blood_overlays.dmi'
	stump_overlays = "_monkey"

	show_ssd = null

	tail = "chimptail"

	flags = list(
		HAS_TAIL = TRUE
		)

	has_bodypart = list(
		BP_CHEST  = /obj/item/bodypart/chest/monkey // <-
		,BP_GROIN = /obj/item/bodypart/groin
		,BP_HEAD  = /obj/item/bodypart/head
		,BP_L_ARM = /obj/item/bodypart/arm
		,BP_R_ARM = /obj/item/bodypart/arm/right
		,BP_L_LEG = /obj/item/bodypart/leg
		,BP_R_LEG = /obj/item/bodypart/leg/right
		)

	has_organ = list(
		BP_HEART    = /obj/item/organ/heart
		,BP_BRAIN   = /obj/item/organ/brain/monkey // <-
		,BP_EYES    = /obj/item/organ/eyes
		,BP_LUNGS   = /obj/item/organ/lungs
		,BP_LIVER   = /obj/item/organ/liver
		,BP_KIDNEYS = /obj/item/organ/kidneys
		)

/datum/species/human
	name = S_HUMAN
	language = "Sol Common"
	backward_form = S_MONKEY
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite)

	has_screamSound = TRUE

	flags = list(
	 HAS_SKIN_TONE = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_HAIR = TRUE
	,HAS_GENDERED_ICONS = TRUE
	)

	//If you wanted to add a species-level ability:
	/*abilities = list(/client/proc/test_ability)*/

/datum/species/monkey/stok
	name = S_MONKEY_U
	backward_form = S_UNATHI

	icobase = 'icons/mob/human_races/monkeys/r_stok.dmi'
	deform = 'icons/mob/human_races/monkeys/r_stok.dmi'

	tail = "stoktail"

/datum/species/unathi
	name = S_UNATHI
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = "Sinta'unathi"
	tail = "sogtail"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws, /datum/unarmed_attack/bite/sharp)
	backward_form = S_MONKEY_U
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
	,HAS_SKIN_COLOR = TRUE
	,HAS_GENDERED_ICONS = TRUE
	,HAS_TAIL = TRUE
	)

	flesh_color = "#34AF10"

	reagent_tag = IS_UNATHI
	base_color = "#066000"

	breathing_sound = 'sound/voice/lizard.ogg'

/datum/species/monkey/farwa
	name = S_MONKEY_T
	backward_form = S_TAJARAN

	icobase = 'icons/mob/human_races/monkeys/r_farwa.dmi'
	deform = 'icons/mob/human_races/monkeys/r_farwa.dmi'

	tail = "farwatail"

/datum/species/tajaran
	name = S_TAJARAN
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	language = "Siik'maas"
	secondary_langs = list("Siik'tajr")
	tail = "tajtail"
	ears = "tajears"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws, /datum/unarmed_attack/bite/sharp)
	darksight = 8
	nighteyes = 1

	cold_level_1 = 200 //Default 260
	cold_level_2 = 140 //Default 200
	cold_level_3 = 80 //Default 120

	heat_level_1 = 330 //Default 360
	heat_level_2 = 380 //Default 400
	heat_level_3 = 800 //Default 1000

	backward_form = S_MONKEY_T

	brute_mod = 1.20
	burn_mod = 1.20
	speed_mod = -0.7

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_SKIN_COLOR = TRUE
	,HAS_HAIR = TRUE
	,HAS_GENDERED_ICONS = TRUE
	,HAS_TAIL = TRUE
	,HAS_EARS = TRUE
	)

	flesh_color = "#AFA59E"
	base_color = "#333333"

/datum/species/monkey/neaera
	name = S_MONKEY_S
	backward_form = S_SKRELL

	icobase = 'icons/mob/human_races/monkeys/r_neaera.dmi'
	deform = 'icons/mob/human_races/monkeys/r_neaera.dmi'

	tail = null

/datum/species/skrell
	name = S_SKRELL
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = "Skrellian"
	backward_form = S_MONKEY_S
	unarmed_types = list(/datum/unarmed_attack/punch)

	flags = list(
	 IS_WHITELISTED = TRUE
	,HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_SKIN_COLOR = TRUE
	)

	eyes_icon = "skrell_eyes"

	flesh_color = "#8CD7A3"

	reagent_tag = IS_SKRELL

/datum/species/monkey/nymph
	name = S_MONKEY_D
	icobase = null
	deform = null

	tail = null

	//backward_form = S_DIONA
	unarmed_types = list(/datum/unarmed_attack/bite)

	has_bodypart = list(
		BP_CHEST = /obj/item/bodypart/chest/nymph
		)

	has_organ = list(
		BP_BRAIN = /obj/item/organ/brain/monkey/nymph
		)

	//abilities = list(
	//	 /mob/living/carbon/alien/diona/proc/merge
	//	,/mob/living/carbon/alien/diona/proc/fertilize_plant
	//	,/mob/living/carbon/alien/diona/proc/eat_weeds
	//	,/mob/living/carbon/alien/diona/proc/evolve
	//	,/mob/living/carbon/alien/diona/proc/steal_blood)

/datum/species/diona
	name = S_DIONA
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	language = "Rootspeak"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/diona)
	//backward_form = S_MONKEY_D

	show_ssd = "completely quiescent"

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
	,NO_SLIP = TRUE
	)

	blood_color = "#004400"
	flesh_color = "#907E4A"

	reagent_tag = IS_DIONA

/datum/species/diona/handle_post_spawn(mob/living/carbon/C)
	C.gender = NEUTER

	return ..()

/datum/species/diona/handle_death(mob/living/carbon/C)

	var/mob/living/carbon/alien/diona/S = new(get_turf(C))

	if(C.mind)
		C.mind.transfer_to(S)

	for(var/mob/living/carbon/alien/diona/D in C.contents)
		if(D.client)
			D.loc = C.loc
		else
			qdel(D)

	C.visible_message("\red[C] splits apart with a wet slithering noise!")

/datum/species/vox
	name = S_VOX
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	language = "Vox-pidgin"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick,  /datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/strong)

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes_icon = "vox_eyes"

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
		slot_wear_suit = 'icons/mob/species/vox/suit.dmi',
		slot_head = 'icons/mob/species/vox/head.dmi',
		slot_wear_mask = 'icons/mob/species/vox/masks.dmi',
		slot_shoes = 'icons/mob/species/vox/shoes.dmi',
		slot_gloves = 'icons/mob/species/vox/gloves.dmi'
		)

/datum/species/vox/handle_post_spawn(mob/living/carbon/C)
	C.verbs += /mob/living/carbon/human/proc/leap
	..()

/datum/species/vox/armalis/handle_post_spawn(mob/living/carbon/C)
	C.verbs += /mob/living/carbon/human/proc/gut
	..()

/datum/species/armalis
	name = S_VOX_ARMALIS
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	deform = 'icons/mob/human_races/r_armalis.dmi'
	damage_overlays = null
	stump_overlays = null
	language = "Vox-pidgin"

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

	eyes_icon = null
	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = list(
	 NO_SCAN = TRUE
	,NO_BLOOD = TRUE
	,NO_PAIN = TRUE
	,NO_EMBED = TRUE
	,HAS_TAIL = TRUE
	)

	blood_color = "#2299FC"
	flesh_color = "#808D11"
	reagent_tag = IS_VOX
	tail = "armalis_tail"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

	sprite_sheets = list(
		slot_wear_suit = 'icons/mob/species/armalis/suit.dmi',
		slot_gloves = 'icons/mob/species/armalis/gloves.dmi',
		slot_shoes = 'icons/mob/species/armalis/feet.dmi',
		slot_head = 'icons/mob/species/armalis/head.dmi',
		slot_r_hand = 'icons/mob/species/armalis/held.dmi',
		slot_l_hand = 'icons/mob/species/armalis/held.dmi'
		)

/datum/species/machine
	name = S_IPC
	//icobase = 'icons/mob/human_races/r_machine.dmi'
	//deform = 'icons/mob/human_races/r_machine.dmi'
	language = "Tradeband"
	unarmed_types = list(/datum/unarmed_attack/punch)

	eyes_icon = null

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

	has_bodypart = list(
		BP_CHEST = /obj/item/bodypart/chest
		,BP_GROIN = /obj/item/bodypart/groin
		,BP_HEAD  = /obj/item/bodypart/head
		,BP_L_ARM = /obj/item/bodypart/arm
		,BP_R_ARM = /obj/item/bodypart/arm/right
		,BP_L_LEG = /obj/item/bodypart/leg
		,BP_R_LEG = /obj/item/bodypart/leg/right
		)

	has_organ = list(
		BP_BRAIN = /obj/item/organ/brain/mmi_holder
		,BP_CELL = /obj/item/organ/cell
		,BP_OPTICS    = /obj/item/organ/eyes/optics
		)

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
	damage_overlays = null
	stump_overlays = null

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
	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/sharp)

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
	,NO_SLIP = TRUE
	)
	burn_mod = 2 //2x burn damage lel


/datum/species/shadowling/handle_post_spawn(mob/living/carbon/C)
	C.gender = NEUTER
	return ..()

/datum/species/slime
	name = S_SLIME

	icobase = null
	deform = null

	damage_overlays = null
	blood_overlays = null
	stump_overlays = null


	flags = list(
	 NO_EMBED = TRUE
	)

	has_hands = FALSE
	has_drop = FALSE
	has_throw = FALSE
	has_internals = FALSE
	has_gun_aim_control = FALSE

	num_of_hands = 0
	num_of_legs = 0

	has_bodypart = list(
		BP_CHEST = /obj/item/bodypart/chest/unbreakable/slime
		)

	has_organ = list(
		BP_BRAIN = /obj/item/organ/brain/core
		)

/datum/species/shapeshifter/promethean
	name = S_PROMETHEAN

	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_slime.dmi'

	stump_overlays = null
	eyes_icon = null

	unarmed_types = list(/datum/unarmed_attack/slime_glomp)

	show_ssd = "totally quiescent"

	has_bodypart = list(
		BP_CHEST = /obj/item/bodypart/chest/unbreakable/promethean
		,BP_GROIN = /obj/item/bodypart/groin/unbreakable/promethean
		,BP_HEAD = /obj/item/bodypart/head/unbreakable/promethean
		,BP_L_ARM = /obj/item/bodypart/arm/unbreakable/promethean
		,BP_R_ARM = /obj/item/bodypart/arm/right/unbreakable/promethean
		,BP_L_LEG = /obj/item/bodypart/leg/unbreakable/promethean
		,BP_R_LEG = /obj/item/bodypart/leg/right/unbreakable/promethean
		)

	has_organ = list(
		BP_BRAIN = /obj/item/organ/brain/core/promethean
		)

/datum/species/golem
	name = S_GOLEM

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'

	flags = list(
		 NO_PAIN = TRUE
		,NO_SCAN = TRUE
		)

/*
	Aliens aka xenomorphs
*/
/datum/species/xenos
	damage_overlays = null
	blood_overlays = null
	stump_overlays = null

	flags = list(
	 NO_EMBED = TRUE
	,NO_SLIP = TRUE
	,DROPLIMB_WHEN_DEAD = TRUE
	)

	has_gun_aim_control = FALSE

	has_bodypart = list()
	has_organ = list()

/datum/species/xenos/facehugger
	name = S_XENO_FACE

	icobase = null
	deform = null

	has_a_intent = FALSE
	has_m_intent = FALSE
	has_hands = FALSE
	has_throw = FALSE
	has_resist = FALSE
	has_internals = FALSE

	num_of_hands = 0
	num_of_legs = 0

	has_bodypart = list(
		BP_CHEST = /obj/item/bodypart/chest/unbreakable/facehugger
		)

	has_organ = list(
		BP_BRAIN = /obj/item/organ/brain/xeno/child
		)

/datum/species/xenos/larva
	name = S_XENO_LARVA

	icobase = null
	deform = null

	has_a_intent = FALSE
	has_m_intent = FALSE
	has_hands = FALSE
	has_drop = FALSE
	has_throw = FALSE
	has_resist = FALSE
	has_internals = FALSE

	num_of_hands = 0
	num_of_legs = 0

	has_bodypart = list(
		BP_CHEST = /obj/item/bodypart/chest/unbreakable/larva
		)

	has_organ = list(
		BP_BRAIN = /obj/item/organ/brain/xeno/child
		)

/datum/species/xenos/adult
	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/strong)

	has_internals = FALSE

	flags = list(
		HAS_TAIL = TRUE
		)

	has_bodypart = list(
		 BP_CHEST = /obj/item/bodypart/chest/unbreakable
		,BP_GROIN = /obj/item/bodypart/groin/unbreakable
		,BP_HEAD = /obj/item/bodypart/head/unbreakable
		,BP_L_ARM = /obj/item/bodypart/arm/unbreakable
		,BP_R_ARM = /obj/item/bodypart/arm/right/unbreakable
		,BP_L_LEG = /obj/item/bodypart/leg/unbreakable
		,BP_R_LEG = /obj/item/bodypart/leg/right/unbreakable
		)

	has_organ = list(
		 BP_HEART = /obj/item/organ/heart
		,BP_BRAIN = /obj/item/organ/brain/xeno
		,BP_LUNGS = /obj/item/organ/lungs/xeno
		,BP_TONGUE = /obj/item/organ/tongue/xeno
		,BP_HIVE = /obj/item/organ/xenos/hivenode
		)

	//abilities = list()

/datum/species/xenos/adult/drone
	name = S_XENO_DRONE
	tail = "xenos_drone_tail"

	icobase = 'icons/mob/human_races/xenos/r_xenos_drone.dmi'
	deform  = 'icons/mob/human_races/xenos/r_xenos_drone.dmi'

/datum/species/xenos/adult/drone/New()
	..()

	has_organ[BP_PLASMA] = /obj/item/organ/xenos/plasmavessel
	has_organ[BP_RESIN] = /obj/item/organ/xenos/resinspinner
	has_organ[BP_ACID] = /obj/item/organ/xenos/acidgland

	//abilities += list(
	//	/datum/species/xenos/adult/drone/proc/evolve
	//	)

/datum/species/xenos/adult/hunter
	name = S_XENO_HUNTER
	tail = "xenos_hunter_tail"

	icobase = 'icons/mob/human_races/xenos/r_xenos_hunter.dmi'
	deform  = 'icons/mob/human_races/xenos/r_xenos_hunter.dmi'

/datum/species/xenos/adult/hunter/New()
	..()

	has_organ[BP_BRAIN] = /obj/item/organ/brain/xeno/hunter
	has_organ[BP_PLASMA] = /obj/item/organ/xenos/plasmavessel/hunter

/datum/species/xenos/adult/sentinel
	name = S_XENO_SENTINEL
	tail = "xenos_sentinel_tail"

	icobase = 'icons/mob/human_races/xenos/r_xenos_sentinel.dmi'
	deform  = 'icons/mob/human_races/xenos/r_xenos_sentinel.dmi'

/datum/species/xenos/adult/sentinel/New()
	..()

	has_organ[BP_PLASMA] = /obj/item/organ/xenos/plasmavessel/sentinel
	has_organ[BP_NEURO] = /obj/item/organ/xenos/neurotoxin
	has_organ[BP_ACID] = /obj/item/organ/xenos/acidgland

/datum/species/xenos/adult/queen
	name = S_XENO_QUEEN
	tail = "xenos_queen_tail"

	icobase = 'icons/mob/human_races/xenos/r_xenos_queen.dmi'
	deform  = 'icons/mob/human_races/xenos/r_xenos_queen.dmi'

/datum/species/xenos/adult/queen/New()
	..()

	has_organ[BP_EGG] = /obj/item/organ/xenos/eggsac
	has_organ[BP_PLASMA] = /obj/item/organ/xenos/plasmavessel/queen
	has_organ[BP_RESIN] = /obj/item/organ/xenos/resinspinner
	has_organ[BP_NEURO] = /obj/item/organ/xenos/neurotoxin
	has_organ[BP_ACID] = /obj/item/organ/xenos/acidgland

/datum/species/dog
	name = S_DOG

	icobase = null
	deform = null

	damage_overlays = null
	blood_overlays = null
	stump_overlays = null

	has_hands = FALSE
	has_throw = FALSE

	num_of_hands = 1
	num_of_legs = 4

	has_bodypart = list(
		 BP_CHEST = /obj/item/bodypart/chest/unbreakable/dog
		,BP_GROIN = /obj/item/bodypart/groin/unbreakable
		,BP_HEAD = /obj/item/bodypart/head/unbreakable/dog
		,BP_L_ARM = /obj/item/bodypart/leg/unbreakable/front
		,BP_R_ARM = /obj/item/bodypart/leg/right/unbreakable/front
		,BP_L_LEG = /obj/item/bodypart/leg/unbreakable
		,BP_R_LEG = /obj/item/bodypart/leg/right/unbreakable
		)

/datum/species/dog/New()
	..()

	has_organ[BP_BRAIN] = /obj/item/organ/brain/dog

// Called when using the shredding behavior.
/datum/species/proc/can_shred(mob/living/carbon/C, ignore_intent)

	if(!ignore_intent && C.a_intent != I_HURT)
		return 0

	for(var/datum/unarmed_attack/attack in unarmed_attacks)
		if(!attack.is_usable(C))
			continue
		if(attack.shredding)
			return 1

	return 0

/datum/species/proc/get_knockout_message(mob/living/carbon/C)
	return ((C && C.species.flags[IS_SYNTHETIC]) ? "encounters a hardware fault and suddenly reboots!" : knockout_message)

/datum/species/proc/get_ssd(var/mob/living/carbon/C)
	return ((C && C.isSynthetic()) ? "flashing a 'system offline' glyph on their monitor" : show_ssd)

/datum/species/proc/hug(mob/living/carbon/C, mob/living/target)

	var/t_him = "them"
	switch(target.gender)
		if(MALE)
			t_him = "him"
		if(FEMALE)
			t_him = "her"

	C.visible_message("<span class='notice'>[C] hugs [target] to make [t_him] feel better!</span>",
		               "<span class='notice'>You hug [target] to make [t_him] feel better!</span>")

//datum/species/shapeshifter/promethean/hug(mob/living/carbon/C, mob/living/target)
//	var/datum/gender/G = gender_datums[target.gender]
//	C.visible_message("<span class='notice'>\The [C] glomps [target] to make [G.him] feel better!</span>",
//		                   "<span class='notice'>You glomps [target] to make [G.him] feel better!</span>")
//	C.apply_stored_shock_to(target)

/datum/species/xenos/hug(mob/living/carbon/C, mob/living/target)
	C.visible_message("<span class='notice'>[C] caresses [target] with its scythe-like arm.</span>",
		               "<span class='notice'>You caress [target] with your scythe-like arm.</span>")
