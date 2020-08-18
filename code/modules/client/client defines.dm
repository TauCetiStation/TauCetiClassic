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
	var/buildmode		= 0
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
	var/time_died_as_mouse = null //when the client last died as a mouse
	var/time_joined_as_spacebum = null
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
	var/next_allowed_topic_time = 10
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1

	var/received_irc_pm = -99999
	var/irc_admin			//IRC admin that spoke with them last.
	var/mute_irc = 0


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
	var/static/obj/screen/click_catcher/void

		// MEDIAAAAAAAA
	// Set on login.
	var/datum/media_manager/media = null

	var/datum/guard/guard = null

	var/datum/tooltip/tooltips

	var/list/datum/browser/browsers


	// Their chat window, sort of important.
	// See /goon/code/datums/browserOutput.dm
	var/datum/chatOutput/chatOutput

	var/list/char_render_holders			//Should only be a key-value list of north/south/east/west = obj/screen.
