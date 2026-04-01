/mob/living/carbon/human

	/* prefs copypaste */

	//Hair colour and style
	var/r_hair = /datum/preferences::r_hair
	var/g_hair = /datum/preferences::g_hair
	var/b_hair = /datum/preferences::b_hair
	var/h_style = /datum/preferences::h_style

	var/dyed_r_hair = 0
	var/dyed_g_hair = 0
	var/dyed_b_hair = 0
	var/hair_painted = FALSE

	var/r_grad = /datum/preferences::r_grad
	var/g_grad = /datum/preferences::g_grad
	var/b_grad = /datum/preferences::b_grad
	var/grad_style = /datum/preferences::grad_style

	//Facial hair colour and style
	var/r_facial = /datum/preferences::r_facial
	var/g_facial = /datum/preferences::g_facial
	var/b_facial = /datum/preferences::b_facial
	var/f_style = /datum/preferences::f_style

	var/dyed_r_facial = 0
	var/dyed_g_facial = 0
	var/dyed_b_facial = 0
	var/facial_painted = FALSE

	//Eye colour
	var/r_eyes = /datum/preferences::r_eyes
	var/g_eyes = /datum/preferences::g_eyes
	var/b_eyes = /datum/preferences::b_eyes

	var/s_tone = /datum/preferences::s_tone

	//Skin colour
	var/r_skin = /datum/preferences::r_skin
	var/g_skin = /datum/preferences::g_skin
	var/b_skin = /datum/preferences::b_skin

	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = /datum/preferences::age //Player's age (pure fluff)
	var/height = /datum/preferences::height //Player's height

	var/underwear = /datum/preferences::underwear   //Which underwear the player wants
	var/undershirt = /datum/preferences::undershirt  //Which undershirt the player wants.
	var/undershirt_print = /datum/preferences::undershirt_print
	var/socks = /datum/preferences::socks       //Which socks the player wants.
	var/backbag = /datum/preferences::backbag     //Which backpack type the player has chosen. Nothing, Satchel or Backpack.
	var/use_skirt = /datum/preferences::use_skirt
	// General information
	var/roundstart_insurance = /datum/preferences::insurance
	var/home_system = /datum/preferences::home_system
	var/citizenship = /datum/preferences::citizenship
	var/personal_faction = /datum/preferences::faction
	var/religion = /datum/preferences::religion
	var/vox_rank = /datum/preferences::vox_rank
	var/r_belly = /datum/preferences::r_belly
	var/g_belly = /datum/preferences::g_belly
	var/b_belly = /datum/preferences::b_belly

	//Equipment slots
	var/obj/item/wear_suit = null
	var/obj/item/w_uniform = null
	var/obj/item/belt = null
	var/obj/item/gloves = null
	var/obj/item/glasses = null
	var/obj/item/l_ear = null
	var/obj/item/r_ear = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/voice = ""	//Instead of new say code calling GetVoice() over and over and over, we're just going to ask this variable, which gets updated in Life()

	var/speech_problem_flag = 0

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/failed_last_breath = 0 //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.

	var/last_dam = -1	//Used for determining if we need to process all bodyparts or just some or even none.
	var/list/bad_bodyparts = list()// bodyparts we check until they are good.

	var/xylophone = 0 //For the spoooooooky xylophone cooldown

	var/mob/remoteview_target = null
	var/datum/dirt_cover/hand_dirt_datum

	// Organs regenerating variables.
	var/regenerating_organ_time = 0
	var/obj/item/organ/external/regenerating_bodypart // A bodypart that is currently regenerating, so we don't have a random one picked each time.

	//Golem stuff
	var/mob/living/carbon/human/my_master = null
	var/mob/living/carbon/human/my_golem = null

	// Prevent sound emotes spam in some situations
	var/next_high_priority_sound = 0 // Usually these sounds require high attention, such as the sound of agony. These sounds can only be overlaid by sounds with the same priority.
	var/next_medium_priority_sound = 0 // Usually these sounds are not so important, but they can't be overlapped by low priority sounds(with auto = FALSE).
	var/next_low_priority_sound = 0 // There are only those sounds that can be triggered by the user manually(with auto = FALSE). These sounds can be overlapped with sound of any priority.
	var/last_pain_emote_sound = 0 // don't cry in pain too often
	var/time_of_last_damage = 0 // don't cry from the pain that just came

	var/name_override //For temporary visible name changes

	var/full_prosthetic    // We are a robutt.
	var/robolimb_count = 0 // Number of robot limbs.
	var/sightglassesmod = null
	var/datum/personal_crafting/handcrafting

	var/shoving_fingers = FALSE // For force_vomit mechanic.

	var/busy_left_hand = FALSE // See ambidextrous quirk and is_busy() override.
	var/busy_right_hand = FALSE

	// Mood affecting how we see the world.
	var/list/moody_color

	// Clothes count. Used in mood.
	var/wet_clothes = 0
	var/dirty_clothes = 0

	// Reagent allergies.
	var/list/allergies
	var/next_allergy_message = 0

	var/wing_accessory_name = "none"
