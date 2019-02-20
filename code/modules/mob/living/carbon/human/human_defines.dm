/mob/living/carbon/human
	//Hair colour and style
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0
	var/h_style = "Bald"

	var/dyed_r_hair = 0
	var/dyed_g_hair = 0
	var/dyed_b_hair = 0
	var/hair_painted = FALSE

	//Facial hair colour and style
	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0
	var/f_style = "Shaved"

	var/dyed_r_facial = 0
	var/dyed_g_facial = 0
	var/dyed_b_facial = 0
	var/facial_painted = FALSE

	//Eye colour
	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0

	var/s_tone = 0	//Skin tone

	//Skin colour
	var/r_skin = 0
	var/g_skin = 0
	var/b_skin = 0

	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = 30		//Player's age (pure fluff)
	var/b_type = "A+"	//Player's bloodtype

	var/underwear = 1	//Which underwear the player wants
	var/undershirt = 0	//Which undershirt the player wants.
	var/socks = 0	//Which socks the player wants.
	var/backbag = 2		//Which backpack type the player has chosen. Nothing, Satchel or Backpack.

	// General information
	var/home_system = ""
	var/citizenship = ""
	var/personal_faction = ""
	var/religion = ""

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

	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = null

	var/voice = ""	//Instead of new say code calling GetVoice() over and over and over, we're just going to ask this variable, which gets updated in Life()

	var/speech_problem_flag = 0

	var/miming = null //Toggle for the mime's abilities.
	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/failed_last_breath = 0 //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.

	var/last_dam = -1	//Used for determining if we need to process all bodyparts or just some or even none.
	var/list/bad_bodyparts = list()// bodyparts we check until they are good.

	var/xylophone = 0 //For the spoooooooky xylophone cooldown

	var/mob/remoteview_target = null
	var/datum/dirt_cover/hand_dirt_color

	// Organs regenerating variables.
	var/regenerating_organ_time = 0
	var/obj/item/organ/external/regenerating_bodypart // A bodypart that is currently regenerating, so we don't have a random one picked each time.

	//Golem stuff
	var/my_master = 0
	var/my_golems = list()

	var/lastScream = 0 // Prevent scream spam in some situations
	var/name_override //For temporary visible name changes

	var/full_prosthetic    // We are a robutt.
	var/robolimb_count = 0 // Number of robot limbs.
	var/sightglassesmod = null
	var/datum/personal_crafting/handcrafting

	var/busy_left_hand = FALSE // See ambidextrous quirk and is_busy() override.
	var/busy_right_hand = FALSE
