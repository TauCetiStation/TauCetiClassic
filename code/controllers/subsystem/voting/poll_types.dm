/*********************
	Restart
**********************/
/datum/poll/restart
	name = "Restart"
	question = "Restart Round"
	color = "red"
	choice_types = list(
		/datum/vote_choice/restart,
		/datum/vote_choice/continue_round
		)
	only_admin = FALSE
	multiple_votes = FALSE
	can_revote = TRUE
	can_unvote = FALSE
	see_votes = FALSE
	detailed_result = FALSE

	cooldown = 60 MINUTES
	minimum_win_percentage = 0.75

	description = "You will have more voting power if you are head of staff or antag, less if you are observing or dead."

/datum/poll/restart/get_force_blocking_reason()
	. = ..()
	if(!world.has_round_started())
		return "Round has not started"
	if(world.has_round_finished())
		return "Round has finished"

/datum/poll/restart/get_blocking_reason()
	. = ..()
	if(.)
		return
	for(var/client/C in admins)
		if((C.holder.rights & R_ADMIN) && !C.holder.fakekey && !C.is_afk())
			return "Admins Online"

/datum/poll/restart/get_vote_power(client/C)
	return get_vote_power_by_role(C)

/datum/vote_choice/restart
	text = "Restart Round"

/datum/vote_choice/continue_round
	text = "Continue Round"

/datum/vote_choice/restart/on_win()
	var/active_admins = FALSE
	for(var/client/C in admins)
		if(!C.is_afk() && (R_SERVER & C.holder.rights))
			active_admins = TRUE
			break
	if(!active_admins)
		to_chat(world, "<span class='boldannounce'>World restarting due to vote...</span>")
		sleep(50)
		world.Reboot(end_state = "restart vote")
	else
		to_chat(world, "<span class='boldannounce'>Notice: Restart vote will not restart the server automatically because there are active admins on.</span>")
		message_admins("A restart vote has passed, but there are active admins on with +server, so it has been canceled. If you wish, you may restart the server.")


/*********************
	Crew Transfer
**********************/
/datum/poll/crew_transfer
	name = "Crew Transfer"
	question = "Do you want to initiate crew transfer and call the shuttle?"
	choice_types = list(
		/datum/vote_choice/crew_transfer,
		/datum/vote_choice/no_crew_transfer
		)
	only_admin = FALSE
	can_revote = TRUE
	can_unvote = TRUE
	see_votes = FALSE
	detailed_result = FALSE

	minimum_win_percentage = 0.501

	cooldown = 30 MINUTES
	next_vote = 90 MINUTES //Minimum round length before it can be called for the first time

	description = "You will have more voting power if you are head of staff or antag, less if you are observing or dead."

/datum/poll/crew_transfer/get_force_blocking_reason()
	. = ..()
	if(.)
		return
	if(!world.has_round_started())
		return "Round has not started"
	if(world.has_round_finished())
		return "Round has finished"

/datum/poll/crew_transfer/get_blocking_reason()
	. = ..()
	if(.)
		return
	if(SSshuttle.online || SSshuttle.location != 0)
		return "Shuttle is online"
	if(security_level >= SEC_LEVEL_RED)
		return "Security Level is RED or higher"

/datum/poll/crew_transfer/get_vote_power(client/C)
	return get_vote_power_by_role(C)

/datum/vote_choice/crew_transfer
	text = "End Shift"

/datum/vote_choice/no_crew_transfer
	text = "Continue Playing"

/datum/vote_choice/crew_transfer/on_win()
	if(!SSshuttle.online && SSshuttle.location == 0)
		SSshuttle.shuttlealert(1)
		SSshuttle.incall()
		SSshuttle.announce_crew_called.play()
		message_admins("A crew transfer vote has passed, calling the shuttle.")
		log_admin("A crew transfer vote has passed, calling the shuttle.")


/*********************
	GameMode
**********************/
/datum/poll/gamemode
	name = "GameMode"
	question = "Choose GameMode"
	choice_types = list()
	minimum_voters = 0
	only_admin = FALSE

	multiple_votes = FALSE
	can_revote = TRUE
	can_unvote = TRUE
	see_votes = FALSE

	var/pregame = FALSE

/datum/poll/gamemode/get_force_blocking_reason()
	. = ..()
	if(.)
		return
	if(!world.is_round_preparing())
		return "Pregame only"

/datum/poll/gamemode/get_blocking_reason()
	. = ..()
	if(.)
		return

/datum/poll/gamemode/init_choices()
	for(var/M in config.votable_modes)
		var/datum/vote_choice/gamemode/vc = new
		vc.text = M
		vc.new_gamemode = M
		choices.Add(vc)
		// Gamemodes preview in gamemodesets
		if(config.is_modeset(M))
			var/list/submodes = list()
			for(var/datum/game_mode/D in config.get_runnable_modes(M, FALSE))
				submodes.Add(D.name)
			if(length(submodes) > 0)
				description += "<b>[M]</b>: "
				description += submodes.Join(", ")
				description += "<br>"

/datum/poll/gamemode/process()
	if(pregame && SSticker.current_state > GAME_STATE_PREGAME)
		pregame = FALSE
		SSvote.stop_vote()
		to_chat(world, "<b>Voting aborted due to game start.</b>")
	return

/datum/poll/gamemode/on_start()
	if(SSticker.current_state == GAME_STATE_PREGAME)
		pregame = TRUE
		if(SSticker.timeLeft < config.vote_period + 15 SECONDS)
			SSticker.timeLeft = config.vote_period + 15 SECONDS
			to_chat(world, "<b>Game start has been delayed due to voting.</b>")

/datum/poll/gamemode/on_end()
	..()
	pregame = FALSE

/datum/vote_choice/gamemode
	text = "GameMode Name"
	var/new_gamemode = "extended"

/datum/vote_choice/gamemode/on_win()
	if(master_mode != new_gamemode)
		master_mode = new_gamemode
		world.save_mode(new_gamemode)


/*********************
	Custom
**********************/
/datum/poll/custom
	name = "Custom"
	question = "Why is there no text here?"
	choice_types = list()

	only_admin = TRUE
	multiple_votes = TRUE
	can_revote = TRUE
	can_unvote = FALSE
	see_votes = TRUE

/datum/poll/custom/init_choices()
	multiple_votes = FALSE
	can_revote = TRUE
	can_unvote = FALSE
	see_votes = TRUE

	question = input("What's your vote question?", "Custom vote", "Custom vote question")

	var/choice_text = ""
	var/ch_num = 1
	do
		choice_text = input("Vote choice [ch_num]. Type nothing to stop.", "Custom vote", "")
		ch_num += 1
		if(choice_text != "")
			var/datum/vote_choice/custom/C = new
			C.text = choice_text
			choices.Add(C)
	while(choice_text != "" && ch_num < 10)

	if(alert("Should the voters be able to vote multiple options?", "Custom vote", "Yes", "No") == "Yes")
		multiple_votes = TRUE

	if(alert("Should the voters be able to change their choice?", "Custom vote", "Yes", "No") == "No")
		can_revote = FALSE

	if(alert("Should the voters be able to remove their votes?", "Custom vote", "Yes", "No") == "Yes")
		can_unvote = TRUE

	if(alert("Should the voters see another voters votes?", "Custom vote", "Yes", "No") == "No")
		see_votes = FALSE

	if(alert("Are you sure you want to continue?", "Custom vote", "Yes", "No") == "No")
		choices.Cut()

/datum/vote_choice/custom
	text = "Vote choice"
