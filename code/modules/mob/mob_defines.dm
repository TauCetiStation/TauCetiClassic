/mob
	density = TRUE
	layer = 4.0
	animate_movement = 2
	w_class = SIZE_LARGE
//	flags = NOREACT
	var/datum/mind/mind
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

	var/stat = CONSCIOUS //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	var/old_x = 0
	var/old_y = 0

	//Not in use yet

	var/atom/movable/screen/module_icon = null
	var/atom/movable/screen/pullin = null
	var/atom/movable/screen/healths = null
	var/atom/movable/screen/throw_icon = null
	var/atom/movable/screen/complex/gun/gun_setting_icon = null

	var/atom/movable/screen/r_hand_hud_object = null
	var/atom/movable/screen/l_hand_hud_object = null

	var/atom/movable/screen/move_intent = null
	var/atom/movable/screen/complex/act_intent/action_intent = null
	var/atom/movable/screen/staminadisplay = null

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/atom/movable/screen/zone_sel/zone_sel = null
	var/atom/movable/screen/leap/leap_icon = null
	var/atom/movable/screen/neurotoxin_icon = null
	var/atom/movable/screen/healthdoll = null
	var/atom/movable/screen/nutrition_icon = null

	var/atom/movable/screen/pwr_display = null
	var/atom/movable/screen/nightvisionicon = null

	var/atom/movable/screen/holomap/holomap_obj

	var/me_verb_allowed = TRUE //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/computer_id = null
	var/lastattacker_name = ""
	var/lastattacker_key = ""
	var/last_examined = ""
	var/last_z
	var/attack_log = list( )
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/sdisabilities = 0	//Carbon
	var/disabilities = 0	//Carbon
	var/atom/movable/pulling = null
	var/next_move = null
	var/notransform = null	//Carbon
	var/hand = 0            //active hand; 0 is right hand, 1 is left hand //todo: we need defines for this...
	var/eye_blind = null	//Carbon
	var/eye_blurry = null	//Carbon
	var/ear_deaf = null		//Carbon
	var/ear_damage = null	//Carbon
	var/stuttering = 0	//Carbon
	var/slurring = null		//Carbon
	var/real_name = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/blinded = null
	var/daltonism = FALSE
	var/druggy = 0			//Carbon

	// Confused rework. Randomises inputs once every randomiseinputs_cooldown ticks.
	var/confused = 0		//Carbon
	var/list/input_offsets
	var/next_randomise_inputs = 0
	var/randomise_inputs_cooldown = 30 SECONDS

	var/lying = 0
	var/lying_prev = 0
	var/was_lying = FALSE //For user of clown pda slippery
	var/lying_current = 0
	var/crawling = 0 //For crawling
	var/canmove = 1
	var/lastpuke = 0
	var/unacidable = 0
	var/list/embedded = list()          // Embedded items, since simple mobs don't have organs.
	var/list/languages = list()         // For speaking/listening.
	var/list/speak_emote = list("says") // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/emote_type = 1		// Define emote default type, 1 for seen emotes, 2 for heard emotes
	var/floating = 0
    // What is the maximum size ratio that we can pull. The more it is the stronger the mob.
	var/pull_size_ratio = 2.0
	var/name_archive //For admin things like possession

	var/timeofdeath = 0.0//Living

	var/bodytemperature = BODYTEMP_NORMAL	//98.7 F
	var/drowsyness = 0.0//Carbon
	var/dizziness = 0//Carbon
	var/is_dizzy = 0
	var/is_jittery = 0
	var/jitteriness = 0//Carbon
	var/nutrition = NUTRITION_LEVEL_NORMAL//Carbon
	var/dna_inject_count = 0

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/paralysis = FALSE
	var/stunned = FALSE
	var/weakened = FALSE
	var/losebreath = 0.0//Carbon
	var/a_intent = INTENT_HELP //Living
	var/m_intent = "run"//Living
	var/lastKnownIP = null
	var/atom/movable/buckled = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/weapon/back = null//Human/Monkey
	var/obj/item/weapon/tank/internal = null//Human/Monkey
	var/obj/item/weapon/storage/s_active = null//Carbon
	var/obj/item/clothing/mask/wear_mask = null//Carbon

	var/datum/hud/hud_type = /datum/hud
	var/datum/hud/hud_used = null

	var/list/grabbed_by = list(  )

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/coughedtime = null

	var/job = null//Living

	var/datum/dna/dna = null//Carbon
	var/radiation = 0.0//Carbon

	var/list/mutations = list() //Carbon -- Doohl
	//see: setup.dm for list of mutations

	var/voice_name = "unidentifiable voice"

	var/faction = "neutral" //Used for checking whether hostile simple animals will attack you, possibly more stuff later

	// Determines how mood affects actionspeed.
	// If ever used by anything else but mood, please
	// port /datum/actionspeed_modifier system from /tg.
	// The value is multiplicative.
	var/mood_multiplicative_actionspeed_modifier = 0.0
	// Determines how mood affects movespeed.
	// used only in humans, because mood only is.
	// If ever used by anything else but mood, please
	// port /datum/movespeed_modifier system from /tg.
	// The value is additive.
	var/mood_additive_speed_modifier = 0.0

//The last mob/living/carbon to push/drag/grab this mob (mostly used by slimes friend recognition)
	var/mob/living/carbon/LAssailant = null

//Wizard mode, but can be used in other modes thanks to the brand new "Give Spell" badmin button
	var/list/obj/effect/proc_holder/spell/spell_list = list()

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/update_icon = 0 //Set to 1 to trigger regenerate_icons() at the next life() call

	var/status_flags = MOB_STATUS_FLAGS_DEFAULT // bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null

	var/has_unlimited_silicon_privilege = 0 // Can they interact with station electronics

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	var/atom/movable/remote_control //Calls relay_move() to whatever this is set to when the mob tries to move

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak
	var/robot_talk_understand = 0
	var/alien_talk_understand = 0

	var/stance_damage = 1 //Whether this mob's ability to stand has been affected

	var/immune_to_ssd = 0

	var/turf/listed_turf = null  //the current turf being examined in the stat panel
	var/list/shouldnt_see = list()	//list of objects that this mob shouldn't see in the stat panel. this silliness is needed because of AI alt+click and cult blood runes

	var/list/active_genes=list()

	var/fake_death = 0 //New changeling statis
	var/busy_with_action = FALSE // do_after() and do_mob() sets this to TRUE while in progress, use is_busy() before anything if you want to prevent user to do multiple actions.

	var/list/weather_immunities = list()

	var/list/progressbars = null //for stacking do_after bars

	// This is a ref to the religion that the mob is involved in.
	// Mobs without mind can be member of a religion
	var/datum/religion/my_religion

	// datum/atom_hud
	hud_possible = list(ANTAG_HUD, HOLY_HUD)
	// Mob typing indication
	var/typing = FALSE
	var/obj/effect/overlay/typing_indicator/typing_indicator
	var/typing_indicator_type = "default"

	// Language that a mob is forced to speak instead of the Common one.
	var/common_language
	// Language that a mob is forced to speak and cannot choose any other one.
	var/forced_language
	// Language that is used by default whenever there's no language chosen.
	var/default_language

	// Some sounds that this mob can't emit, only approximate.
	var/list/sound_approximations
	// Case sensitive sound approximations.
	var/list/sensitive_sound_approximations

	// Reason of logout
	var/logout_reason

	/// List of action hud items the user has
	var/list/datum/action/actions = list()

	// Used for statistics of death
	var/last_phrase

	var/can_point = TRUE
	var/show_examine_log = TRUE

	var/neuter_gender_voice = MALE // for male/female emote sounds but with neuter gender
