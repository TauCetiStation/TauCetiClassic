/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum

		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null
	var/datum/admins/deadmin_holder = null
	var/datum/buildmode/click_intercept = null
	var/AI_Interact		= 0

	var/jobbancache = null //Used to cache this client's jobbans to save on DB queries
	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.
	var/last_message_time = 0 //Contains time of last message typed by client, used as delay to prevent continuous message spam with macro.

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null
	var/move_delay		= 1
	var/moving			= null
	var/adminobs		= null
	var/area			= null
	var/mentorhelped = FALSE
	var/supporter = 0
	var/prefs_ready = FALSE

		///////////////
		//SOUND STUFF//
		///////////////
	var/sound_next_ambience_play = 0
	var/sound_old_looped_ambience = null

		////////////
		//SECURITY//
		////////////
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1

		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = "Requires database"	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/player_ingame_age = null
	var/player_next_age_tick = 0

	var/list/byond_registration // on demand get_byond_registration()

	preload_rsc = 0 // This is 0 so we can set it to an URL once the player logs in and have them download the resources from a different server.
	var/static/atom/movable/screen/click_catcher/void

		// MEDIAAAAAAAA
	// Set on login.
	var/datum/media_manager/media = null

	var/datum/guard/guard = null

	var/datum/tooltip/tooltips

	var/list/datum/browser/browsers

	var/list/char_render_holders			//Should only be a key-value list of north/south/east/west = atom/movable/screen.

	var/connection_time

	// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()
	/// Last asset send job id.
	var/last_asset_job = 0
	var/last_completed_asset_job = 0


	///Amount of keydowns in the last keysend checking interval
	var/client_keysend_amount = 0
	///World tick time where client_keysend_amount will reset
	var/next_keysend_reset = 0
	///World tick time where keysend_tripped will reset back to false
	var/next_keysend_trip_reset = 0
	///When set to true, user will be autokicked if they trip the keysends in a second limit again
	var/keysend_tripped = FALSE
	///custom movement keys for this client
	var/list/movement_keys = list()
	///Are we locking our movement input?
	var/movement_locked = FALSE

	/// A buffer of currently held keys.
	var/list/keys_held = list()
	/// A buffer for combinations such of modifiers + keys (ex: CtrlD, AltE, ShiftT). Format: `"key"` -> `"combo"` (ex: `"D"` -> `"CtrlD"`)
	var/list/key_combos_held = list()
	/*
	** These next two vars are to apply movement for keypresses and releases made while move delayed.
	** Because discarding that input makes the game less responsive.
	*/
	/// On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_add
	/// On next move, subtract this dir from the move that would otherwise be done
	var/next_move_dir_sub

	var/list/topiclimiter

	var/bwoink_sound = 'sound/effects/adminhelp.ogg'

	/**
	 * Assoc list with all the active maps - when a screen obj is added to
	 * a map, it's put in here as well.
	 *
	 * Format: list(<mapname> = list(/atom/movable/screen))
	 */
	var/list/screen_maps = list()

	// Last world.time that the player tried to request their resources.
	var/last_ui_resource_send = 0

	var/fullscreen = NONE

	/// Messages currently seen by this client
	var/list/seen_messages

	///Tracks say() usage for ic/dchat while slowmode is enabled
	COOLDOWN_DECLARE(say_slowmode)

	var/is_in_spawner = FALSE
