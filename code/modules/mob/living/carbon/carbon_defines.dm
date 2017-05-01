/mob/living/carbon
	icon = 'icons/mob/human.dmi'
	icon_state = "blank"

	gender = MALE

	var/list/hud_list[9]
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/tmp/species_creation_id = null
	var/heart_beat = 0
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.

	var/list/stomach_contents = list()
	var/brain_op_stage = 0.0
	var/list/datum/disease2/disease/virus2 = list()
	var/antibodies = 0
	var/last_eating = 0 	//Not sure what this does... I found it hidden in food.dm

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick
	// total amount of wounds on mob, used to spread out healing and the like over all wounds
	var/number_wounds = 0
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.
	//Surgery info
	var/datum/surgery_status/op_stage = new/datum/surgery_status
	//Active emote/pose
	var/pose = null

	var/pulling_punches // Are you trying not to hurt your opponent?
	var/stance_damage = 0 // Whether this mob's ability to stand has been affected

	var/oxygen_alert = 0
	var/phoron_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/temperature_alert = 0
	var/co2overloadtime = null
	var/temperature_resistance = T0C+75

	var/voice = ""	//Instead of new say code calling GetVoice() over and over and over, we're just going to ask this variable, which gets updated in Life()
	var/speech_problem_flag = 0
	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/failed_last_breath = 0 //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.
	var/last_dam = -1	//Used for determining if we need to process all organs or just some or even none.
	var/list/bad_bodyparts = list()// bodyparts we check until they are good.
	var/b_type = "A+" // Player's bloodtype

	var/mob/remoteview_target = null
	var/hand_blood_color

	var/lastScream = 0 // Prevent scream spam in some situations
	var/name_override //For temporary visible name changes

	// Equipment slots
	var/obj/item/head
	var/obj/item/clothing/mask/wear_mask = null
	var/obj/item/weapon/back = null
	var/obj/item/wear_suit = null
	var/obj/item/w_uniform = null
	var/obj/item/shoes
	var/obj/item/belt = null
	var/obj/item/gloves = null
	var/obj/item/glasses = null
	var/obj/item/l_ear = null
	var/obj/item/r_ear = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living

	// Ian
	var/obj/item/neck
	var/obj/item/mouth

	var/stamina = 100 //Ian uses this for now.

	//Hair colour and style
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0
	var/h_style = "Bald"

	//Facial hair colour and style
	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0
	var/f_style = "Shaved"

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

	var/underwear = 1	//Which underwear the player wants
	var/undershirt = 0	//Which undershirt the player wants.
	var/socks = 0	//Which socks the player wants.

	var/list/bodypart_hands = list() // any bodypart with can_grasp=TRUE added in this list ...
	var/list/bodypart_legs = list() // ... and with can_stand=TRUE.

	var/neurotoxin_on_click = 0 // TODO deal with that
	var/neurotoxin_delay = 15
	var/neurotoxin_next_shot = 0
	var/last_neurotoxin = 0
