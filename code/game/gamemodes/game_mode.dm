//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
 * GAMEMODES (by Rastaf0)
 *
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 *
 */


/datum/game_mode
	var/name = "invalid"
	var/config_tag = null
	var/votable = 1
	var/playable_mode = 1
	var/probability = 0
	var/modeset = null        // if game_mode in modeset
	var/station_was_nuked = 0 //see nuclearbomb.dm and malfunction.dm
	var/explosion_in_progress = 0 //sit back and relax
	var/nar_sie_has_risen = 0 //check, if there is already one god in the world who was summoned (only for tomes)
	var/completion_text = ""
	var/mode_result = "undefined"
	var/list/datum/mind/modePlayer = new // list of current antags.
	var/list/restricted_jobs = list()	// Jobs it doesn't make sense to be.  I.E chaplain or AI cultist
	var/list/protected_jobs = list("Velocity Officer", "Velocity Chief", "Velocity Medical Doctor")	// Jobs that can't be traitors because

	// Specie flags that for any amount of reasons can cause this role to not be available.
	// TO-DO: use traits? ~Luduk
	var/list/restricted_species_flags = list()

	var/required_players = 0
	var/required_players_secret = 0 //Minimum number of players for that game mode to be chose in Secret
	var/required_enemies = 0
	var/recommended_enemies = 0
	var/list/datum/mind/antag_candidates = list()	// List of possible starting antags goes here
	var/list/restricted_jobs_autotraitor = list("Cyborg", "Security Officer", "Warden", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor")
	var/autotraitor_delay = 15 MINUTES // how often to try to add new traitors.
	var/role_type = null
	var/newscaster_announcements = null
	var/ert_disabled = 0
	var/const/waittime_l = 600
	var/const/waittime_h = 1800 // started at 1800
	var/check_ready = TRUE
	var/uplink_welcome = "Syndicate Uplink Console:"
	var/uplink_uses = 20
	var/uplink_items = {"Highly Visible and Dangerous Weapons;
/obj/item/weapon/gun/projectile/revolver/syndie:6:Revolver;
/obj/item/ammo_box/a357:2:Ammo-357;
/obj/item/weapon/gun/energy/crossbow:5:Energy Crossbow;
/obj/item/weapon/melee/energy/sword:4:Energy Sword;
/obj/item/weapon/storage/box/syndicate:10:Syndicate Bundle;
/obj/item/weapon/storage/box/emps:3:5 EMP Grenades;
Whitespace:Seperator;
Stealthy and Inconspicuous Weapons;
/obj/item/weapon/pen/paralysis:3:Paralysis Pen;
/obj/item/weapon/soap/syndie:1:Syndicate Soap;
/obj/item/weapon/cartridge/syndicate:3:Detomatix PDA Cartridge;
Whitespace:Seperator;
Stealth and Camouflage Items;
/obj/item/weapon/storage/box/syndie_kit/chameleon:3:Chameleon Kit;
/obj/item/clothing/shoes/syndigaloshes:2:No-Slip Syndicate Shoes;
/obj/item/weapon/card/id/syndicate:2:Agent ID card;
/obj/item/clothing/mask/gas/voice:4:Voice Changer;
/obj/item/device/chameleon:4:Chameleon-Projector;
Whitespace:Seperator;
Devices and Tools;
/obj/item/weapon/card/emag:3:Cryptographic Sequencer;
/obj/item/weapon/storage/toolbox/syndicate:1:Fully Loaded Toolbox;
/obj/item/weapon/storage/box/syndie_kit/space:3:Space Suit;
/obj/item/clothing/glasses/thermal/syndi:3:Thermal Imaging Glasses;
/obj/item/device/encryptionkey/binary:3:Binary Translator Key;
/obj/item/weapon/aiModule/freeform/syndicate:7:Hacked AI Upload Module;
/obj/item/weapon/plastique:2:C-4 (Destroys walls);
/obj/item/device/powersink:5:Powersink (DANGER!);
/obj/item/device/radio/beacon/syndicate:7:Singularity Beacon (DANGER!);
/obj/item/weapon/circuitboard/teleporter:20:Teleporter Circuit Board;
Whitespace:Seperator;
Implants;
/obj/item/weapon/storage/box/syndie_kit/imp_freedom:3:Freedom Implant;
/obj/item/weapon/storage/box/syndie_kit/imp_uplink:10:Uplink Implant (Contains 5 Telecrystals);
/obj/item/weapon/storage/box/syndie_kit/imp_explosive:6:Explosive Implant (DANGER!);
/obj/item/weapon/storage/box/syndie_kit/imp_compress:4:Compressed Matter Implant;Whitespace:Seperator;
(Pointless) Badassery;
/obj/item/toy/syndicateballoon:10:For showing that You Are The BOSS (Useless Balloon);"}

/datum/game_mode/proc/announce() //to be calles when round starts
	to_chat(world, "<B>Notice</B>: [src] did not define announce()")


// can_start()
// Checks to see if the game can be setup and ran with the current number of players or whatnot.
/datum/game_mode/proc/can_start()
	var/playerC = 0
	for(var/mob/dead/new_player/player in new_player_list)
		if(player.client && (!check_ready || player.ready))
			playerC++
	// no antag_candidates need
	if (playerC == 0 && required_players == 0)
		return TRUE
	// check for minimal player on server
	if((modeset && modeset == "secret" && playerC < required_players_secret) || playerC < required_players)
		return FALSE
	// get list of all antags possiable
	antag_candidates = get_players_for_role(role_type)
	if(antag_candidates.len < required_enemies)
		return FALSE
	// assign_outsider_antag_roles use antag_candidates list
	// fill antag_candidates before return
	return TRUE

/datum/game_mode/proc/potential_runnable()
	check_ready = FALSE
	var/ret = can_start()
	check_ready = TRUE
	return ret

/datum/game_mode/proc/assign_outsider_antag_roles()
	// already get antags in can_start
	return can_start()

// pre_setup()
// Attempts to select players for special roles the mode might have.
// mind.assigned_role already set for players
/datum/game_mode/proc/pre_setup()
	return TRUE

// post_setup()
// Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/game_mode/proc/post_setup()
	var/list/exclude_autotraitor_for = list("extended", "sandbox", "meteor", "gang", "epidemic") // config_tag var
	if(!(config_tag in exclude_autotraitor_for))
		addtimer(CALLBACK(src, .proc/traitorcheckloop), autotraitor_delay)

	spawn (ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	feedback_set_details("round_start","[time2text(world.realtime)]")
	if(SSticker && SSticker.mode)
		feedback_set_details("game_mode","[SSticker.mode]")
	feedback_set_details("server_ip","[world.internet_address]:[world.port]")
	spawn(rand(waittime_l, waittime_h))
		send_intercept()
	start_state = new /datum/station_state()
	start_state.count(1)

	if(dbcon.IsConnected())
		var/DBQuery/query_round_game_mode = dbcon.NewQuery("UPDATE erro_round SET game_mode = '[sanitize_sql(SSticker.mode)]' WHERE id = [round_id]")
		query_round_game_mode.Execute()

	return 1


///process()
///Called by the gameticker
/datum/game_mode/process()
	// For objectives such as "Make an example of...", which require mid-game checks for completion
	for(var/datum/mind/traitor_mind in traitors)
		for(var/datum/objective/objective in traitor_mind.objectives)
			objective.check_completion()
	return 0


/datum/game_mode/proc/check_finished() //to be called by ticker
	if(SSshuttle.location==2 || station_was_nuked)
		return 1
	return 0


/datum/game_mode/proc/declare_completion()
	var/clients = 0
	var/surviving_humans = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/escaped_humans = 0
	var/escaped_total = 0
	var/escaped_on_pod_1 = 0
	var/escaped_on_pod_2 = 0
	var/escaped_on_pod_3 = 0
	var/escaped_on_pod_5 = 0
	var/escaped_on_shuttle = 0

	var/list/area/escape_locations = list(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod4/centcom)

	for(var/mob/M in player_list)
		if(M.client)
			clients++
			var/area/mob_area = get_area(M)
			if(ishuman(M))
				if(!M.stat)
					surviving_humans++
					if(mob_area.type in escape_locations)
						escaped_humans++
			if(!M.stat)
				surviving_total++
				if(mob_area.type in escape_locations)
					escaped_total++

				if(mob_area.type == /area/shuttle/escape/centcom)
					escaped_on_shuttle++

				if(mob_area.type == /area/shuttle/escape_pod1/centcom)
					escaped_on_pod_1++
				if(mob_area.type == /area/shuttle/escape_pod2/centcom)
					escaped_on_pod_2++
				if(mob_area.type == /area/shuttle/escape_pod3/centcom)
					escaped_on_pod_3++
				if(mob_area.type == /area/shuttle/escape_pod4/centcom)
					escaped_on_pod_5++

			if(isobserver(M))
				ghosts++

	if(clients > 0)
		feedback_set("round_end_clients",clients)
	if(ghosts > 0)
		feedback_set("round_end_ghosts",ghosts)
	if(surviving_humans > 0)
		feedback_set("survived_human",surviving_humans)
	if(surviving_total > 0)
		feedback_set("survived_total",surviving_total)
		score["crew_survived"] = surviving_total
	if(escaped_humans > 0)
		feedback_set("escaped_human",escaped_humans)
		score["crew_escaped"] = escaped_humans
	if(escaped_total > 0)
		feedback_set("escaped_total",escaped_total)
	if(escaped_on_shuttle > 0)
		feedback_set("escaped_on_shuttle",escaped_on_shuttle)
	if(escaped_on_pod_1 > 0)
		feedback_set("escaped_on_pod_1",escaped_on_pod_1)
	if(escaped_on_pod_2 > 0)
		feedback_set("escaped_on_pod_2",escaped_on_pod_2)
	if(escaped_on_pod_3 > 0)
		feedback_set("escaped_on_pod_3",escaped_on_pod_3)
	if(escaped_on_pod_5 > 0)
		feedback_set("escaped_on_pod_5",escaped_on_pod_5)

	return 0


/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
	return 0


/datum/game_mode/proc/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested status information:</FONT><HR>"
	intercepttext += "<B> In case you have misplaced your copy, attached is a list of personnel whom reliable sources&trade; suspect may be affiliated with the Syndicate:</B><br>"


	var/list/suspects = list()
	for(var/mob/living/carbon/human/man in player_list) if(man.client && man.mind)
		// NT relation option
		var/list/invisible_roles = list("Wizard",
										"Ninja",
										"Syndicate",
										"Vox Raider",
										"Raider",
										"Abductor scientist",
										"Abductor agent",
										"Meme"
										)
		var/special_role = man.mind.special_role
		if (special_role in invisible_roles)
			continue	//NT intelligence ruled out possiblity that those are too classy to pretend to be a crew.
		for(var/spec_role in gang_name_pool)
			if (special_role == "[spec_role] Gang (A) Boss")
				continue
			if (special_role == "[spec_role] Gang (B) Boss")
				continue
		if(man.client.prefs.nanotrasen_relation == "Opposed" && prob(50) || \
		   man.client.prefs.nanotrasen_relation == "Skeptical" && prob(20))
			suspects += man
		// Antags
		else if(special_role == "traitor" && prob(40) || \
			special_role == "Changeling" && prob(50) || \
			special_role == "Cultist" && prob(30) || \
			special_role == "Head Revolutionary" && prob(30) || \
			special_role == "Shadowling" && prob(20))
			suspects += man

			// If they're a traitor or likewise, give them extra TC in exchange.
			var/obj/item/device/uplink/hidden/suplink = man.mind.find_syndicate_uplink()
			if(suplink)
				var/extra = 8
				suplink.uses += extra
				if(man.mind) man.mind.total_TC += extra
				to_chat(man, "<span class='warning'>We have received notice that enemy intelligence suspects you to be linked with us. We have thus invested significant resources to increase your uplink's capacity.</span>")
			else
				// Give them a warning!
				to_chat(man, "<span class='warning'>They are on to you!</span>")

		// Some poor people who were just in the wrong place at the wrong time..
		else if(prob(10))
			suspects += man
	for(var/mob/M in suspects)
		switch(rand(1, 100))
			if(1 to 50)
				intercepttext += "Someone with the job of <b>[M.mind.assigned_role]</b> <br>"
			else
				intercepttext += "<b>[M.name]</b>, the <b>[M.mind.assigned_role]</b> <br>"

	for (var/obj/machinery/computer/communications/comm in communications_list)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "Cent. Com. Status Summary"
			intercept.info = intercepttext
			intercept.update_icon()

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	station_announce(sound = "commandreport")

/*	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	if(security_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)*/

/datum/game_mode/proc/can_be_antag(datum/mind/player, role)
	if(restricted_jobs)
		if(player.assigned_role in restricted_jobs)
			return FALSE

	var/datum/preferences/prefs = player.current.client.prefs

	var/datum/species/S = all_species[prefs.species]

	if(!S.can_be_role(role))
		return FALSE

	for(var/specie_flag in restricted_species_flags)
		if(S.flags[specie_flag])
			return FALSE

	return TRUE

/datum/game_mode/proc/get_players_for_role(role)
	var/list/players = list()
	var/list/candidates = list()

	// Assemble a list of active players without jobbans.
	for(var/mob/dead/new_player/player in new_player_list)
		if(player.client && (!check_ready || player.ready))
			if(role in player.client.prefs.be_role)
				if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, role) && !role_available_in_minutes(player, role))
					players += player

	// Shuffle the players list so that it becomes ping-independent.
	players = shuffle(players)

	// Get a list of all the people who want to be the antagonist for this round
	for(var/mob/dead/new_player/player in players)
		if(role in player.client.prefs.be_role)
			log_debug("[player.key] had [role] enabled, so we are drafting them.")
			candidates += player.mind
			players -= player

	for(var/datum/mind/player in candidates)
		if(!can_be_antag(player, role))
			candidates -= player

	return candidates		// Returns: The number of people who had the antagonist role set to yes, regardless of recomended_enemies, if that number is greater than recommended_enemies
							//			recommended_enemies if the number of people with that role set to yes is less than recomended_enemies,
							//			Less if there are not enough valid players in the game entirely to make recommended_enemies.


/datum/game_mode/proc/latespawn(mob)

/*
/datum/game_mode/proc/check_player_role_pref(role, mob/dead/new_player/player)
	if(player.preferences.be_role & role)
		return 1
	return 0
*/

/datum/game_mode/proc/num_players()
	. = 0
	for(var/mob/dead/new_player/P in new_player_list)
		if(P.client && P.ready)
			. ++


///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/game_mode/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/game_mode/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/player in mob_list)
		if(player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/game_mode/proc/check_antagonists_topic(href, href_list[])
	return 0

/datum/game_mode/New()
	newscaster_announcements = pick(newscaster_standard_feeds)

//////////////////////////
//Reports player logouts//
//////////////////////////
/proc/display_roundstart_logout_report()
	var/msg = "<span class='notice'><b>Roundstart logout report</b>\n\n</span>"
	for(var/mob/living/L in living_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in clients)
				if(C.ckey == L.ckey)
					found = 1
					break
			if(!found)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client
			if(L.stat)
				if(L.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
					continue //Disconnected client
				if(L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in observer_list)
			if(D.mind && (D.mind.original == L || D.mind.current == L))
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>This shouldn't appear.</b></font>)\n"
						continue //Lolwhat
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Ghosted</b></font>)\n"
						continue //Ghosted while alive



	for(var/client/M in admins)
		if(M.holder)
			to_chat(M, msg)


/proc/get_nt_opposed()
	var/list/dudes = list()
	for(var/mob/living/carbon/human/man in human_list)
		if(man.client)
			if(man.client.prefs.nanotrasen_relation == "Opposed")
				dudes += man
			else if(man.client.prefs.nanotrasen_relation == "Skeptical" && prob(50))
				dudes += man
	if(dudes.len == 0) return null
	return pick(dudes)

///////////////////////////
//Misc stuff and TG ports//
///////////////////////////

/datum/game_mode/proc/printplayer(datum/mind/ply)
	var/role = "[ply.special_role]"
	var/text = "<br><b>[ply.name]</b>(<b>[ply.key]</b>) as \a <b>[role]</b> ("
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += "died"
		else
			text += "survived"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += "body destroyed"
	text += ")"

	return text

/datum/game_mode/proc/printobjectives(datum/mind/ply)
	var/text = ""
	var/count = 1
	var/result
	for(var/datum/objective/objective in ply.objectives)
		result = objective.check_completion()
		switch(result)
			if(OBJECTIVE_WIN)
				text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: green; font-weight: bold;'>Success!</span>"
			if(OBJECTIVE_LOSS)
				text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: red; font-weight: bold;'>Fail.</span>"
			if(OBJECTIVE_HALFWIN)
				text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: orange; font-weight: bold;'>Half success.</span>"

		count++
	return text

//Used for printing player with there icons in round ending staticstic
/datum/game_mode/proc/printplayerwithicon(datum/mind/ply)
	var/text = ""
	var/tempstate = end_icons.len
	if(ply.current)
		var/icon/flat = getFlatIcon(ply.current,exact=1)
		end_icons += flat
		tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <b>[ply.key]</b> was <b>[ply.name]</b> ("}
		if(ply.current.stat == DEAD)
			text += "died"
			flat.Turn(90)
			end_icons[tempstate] = flat
		else
			text += "survived"
		if(ply.current.real_name != ply.name)
			text += " as [ply.current.real_name]"
	else
		var/icon/sprotch = icon('icons/effects/blood.dmi', "gibbearcore")
		end_icons += sprotch
		tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <b>[ply.key]</b> was <b>[ply.name]</b> ("}
		text += "body destroyed"
	text += ")"
	return text

//Used for printing antag logo
/datum/game_mode/proc/printlogo(logoname, antagname)
	var/icon/logo = icon('icons/mob/mob.dmi', "[logoname]-logo")
	end_icons += logo
	var/tempstate = end_icons.len
	var/text = ""
	text += {"<img src="logo_[tempstate].png"> <b>The [antagname] were:</b> <img src="logo_[tempstate].png">"}
	return text
