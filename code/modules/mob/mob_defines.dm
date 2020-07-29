/mob
	density = 1
	layer = 4.0
	animate_movement = 2
//	flags = NOREACT
	var/datum/mind/mind

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	var/old_x = 0
	var/old_y = 0

	//Not in use yet
	var/obj/effect/organstructure/organStructure = null

	var/obj/screen/hands = null
	var/obj/screen/pullin = null
	var/obj/screen/internals = null
	var/obj/screen/i_select = null
	var/obj/screen/m_select = null
	var/obj/screen/healths = null
	var/obj/screen/throw_icon = null
	var/obj/screen/pressure = null
	var/obj/screen/pain = null
	var/obj/screen/gun/item/item_use_icon = null
	var/obj/screen/gun/move/gun_move_icon = null
	var/obj/screen/gun/run/gun_run_icon = null
	var/obj/screen/gun/mode/gun_setting_icon = null

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/obj/screen/zone_sel/zone_sel = null
	var/obj/screen/leap/leap_icon = null
	var/obj/screen/neurotoxin_icon = null
	var/obj/screen/healthdoll = null
	var/obj/screen/nutrition_icon = null

	var/obj/screen/xenomorph_plasma_display = null
	var/obj/screen/nightvisionicon = null

	var/me_verb_allowed = TRUE //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/speech_allowed = 1 //Meme Stuff
	var/damageoverlaytemp = 0
	var/computer_id = null
	var/lastattacker = null
	var/lastattacked = null
	var/attack_log = list( )
	var/already_placed = 0.0
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/memory = ""
	var/poll_answer = 0.0
	var/sdisabilities = 0	//Carbon
	var/disabilities = 0	//Carbon
	var/atom/movable/pulling = null
	var/next_move = null
	var/other = 0.0
	var/notransform = null	//Carbon
	var/hand = 0            //active hand; 0 is right hand, 1 is left hand //todo: we need defines for this...
	var/eye_blind = null	//Carbon
	var/eye_blurry = null	//Carbon
	var/ear_deaf = null		//Carbon
	var/ear_damage = null	//Carbon
	var/stuttering = null	//Carbon
	var/slurring = null		//Carbon
	var/real_name = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/blinded = null
	var/druggy = 0			//Carbon
	var/confused = 0		//Carbon
	var/antitoxs = null
	var/phoron = null
	var/resting = 0			//Carbon
	var/lying = 0
	var/lying_prev = 0
	var/lying_current = 0
	var/crawling = 0 //For crawling
	var/canmove = 1
	var/lastpuke = 0
	var/unacidable = 0
	var/small = 0
	var/list/pinned = list()            // List of things pinning this creature to walls (see living_defense.dm)
	var/list/embedded = list()          // Embedded items, since simple mobs don't have organs.
	var/list/languages = list()         // For speaking/listening.
	var/list/abilities = list()         // For species-derived or admin-given powers.
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
	var/charges = 0.0
	var/nutrition = 400.0//Carbon
	var/dna_inject_count = 0

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/paralysis = 0.0
	var/stunned = 0.0
	var/weakened = 0.0
	var/losebreath = 0.0//Carbon
	var/intent = null//Living
	var/a_intent = INTENT_HELP //Living
	var/m_int = null//Living
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
	var/list/requests = list(  )

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/coughedtime = null

	var/music_lastplayed = "null"

	var/job = null//Living

	var/const/blindness = 1//Carbon
	var/const/deafness = 2//Carbon
	var/const/muteness = 4//Carbon


	var/datum/dna/dna = null//Carbon
	var/radiation = 0.0//Carbon

	var/list/mutations = list() //Carbon -- Doohl
	//see: setup.dm for list of mutations

	var/voice_name = "unidentifiable voice"

	var/faction = "neutral" //Used for checking whether hostile simple animals will attack you, possibly more stuff later
	var/captured = 0 //Functionally, should give the same effect as being buckled into a chair when true.

//Generic list for proc holders. Only way I can see to enable certain verbs/procs. Should be modified if needed.
	var/proc_holder_list[] = list()//Right now unused.
	//Also unlike the spell list, this would only store the object in contents, not an object in itself.

	/* Add this line to whatever stat module you need in order to use the proc holder list.
	Unlike the object spell system, it's also possible to attach verb procs from these objects to right-click menus.
	This requires creating a verb for the object proc holder.

	if (proc_holder_list.len)//Generic list for proc_holder objects.
		for(var/obj/effect/proc_holder/P in proc_holder_list)
			statpanel("[P.panel]","",P)
	*/

//The last mob/living/carbon to push/drag/grab this mob (mostly used by slimes friend recognition)
	var/mob/living/carbon/LAssailant = null

//Wizard mode, but can be used in other modes thanks to the brand new "Give Spell" badmin button
	var/list/obj/effect/proc_holder/spell/spell_list = list()

//Changlings, but can be used in other modes
//	var/obj/effect/proc_holder/changpower/list/power_list = list()

//List of active diseases

	var/list/viruses = list() // replaces var/datum/disease/virus

//Monkey/infected mode
	var/list/resistances = list()
	var/datum/disease/virus = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/update_icon = 0 //Set to 1 to trigger regenerate_icons() at the next life() call

	var/status_flags = MOB_STATUS_FLAGS_DEFAULT // bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null

	var/digitalcamo = 0 // Can they be tracked by the AI?
	var/image/digitaldisguise = null  //what does the AI see instead of them?

	var/has_unlimited_silicon_privilege = 0 // Can they interact with station electronics

	var/list/radar_blips = list() // list of screen objects, radar blips
	var/radar_open = 0 	// nonzero is radar is open


	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	var/atom/movable/remote_control //Calls relay_move() to whatever this is set to when the mob tries to move

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak
	var/robot_talk_understand = 0
	var/alien_talk_understand = 0

	var/has_limbs = 1 //Whether this mob have any limbs he can move with
	var/stance_damage = 1 //Whether this mob's ability to stand has been affected

	var/immune_to_ssd = 0

	var/turf/listed_turf = null  //the current turf being examined in the stat panel
	var/list/shouldnt_see = list()	//list of objects that this mob shouldn't see in the stat panel. this silliness is needed because of AI alt+click and cult blood runes

	var/list/active_genes=list()

	var/fake_death = 0 //New changeling statis
	var/busy_with_action = FALSE // do_after() and do_mob() sets this to TRUE while in progress, use is_busy() before anything if you want to prevent user to do multiple actions.

	var/list/weather_immunities = list()

	var/list/progressbars = null //for stacking do_after bars
