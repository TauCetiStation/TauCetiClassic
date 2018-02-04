/datum/game_mode/var/list/memes = list()

/datum/game_mode/meme
	name = "Memetic Anomaly"
	config_tag = "meme"
	role_type = ROLE_MEME
	required_players = 6
	required_players_secret = 15
	restricted_jobs = list("AI", "Cyborg")
	recommended_enemies = 3 // need at least a meme and a host
	votable = 0 // temporarily disable this mode for voting



	var/var/list/datum/mind/first_hosts = list()
	var/var/list/assigned_hosts = list()
	var/list/possible_hosts = list()

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

/datum/game_mode/meme/announce()
	to_chat(world, "<B>The current game mode is - Meme!</B>")
	to_chat(world, "<B>An unknown creature has infested the mind of a crew member. Find and destroy it by any means necessary.</B>")

/datum/game_mode/meme/can_start()
	if(!..())
		return 0

	// for every 10 players, get 1 meme, and for each meme, get a host
	// also make sure that there's at least one meme and one host
	//recommended_enemies = max(src.num_players() / 20 * 2, 2)

	if(antag_candidates.len < 1)
		//log_admin("MODE FAILURE: MEME. NOT ENOUGH MEME CANDIDATES.") // We need no spam anymore, it works for a long time.
		return 0 // not enough candidates for meme

	/*if(possible_memes.len < 2)
		log_admin("MODE FAILURE: MEME. NOT ENOUGH MEME CANDIDATES.")
		return 0 not enough candidates for meme*/

	//testing("[player_list.len] cur players")

	//var/meme_limit = Clamp((num_players()/20), 1, 3)
	var/meme_limit = Clamp((player_list.len/13), 1, 3)
	//testing("Current meme limit is [meme_limit]")
	var/i = 0

	while(antag_candidates.len > meme_limit)
		i++
		var/datum/mind/meme = pick(antag_candidates)
		antag_candidates.Remove(meme)
	if(i)
		log_misc("Deleted [i] possible memes from list")
	else
		log_misc("Everything was O.K. No meme candidates over limit. Limit was [meme_limit] and possible meme candidates is [antag_candidates.len]")

	// for each 2 possible memes, add one meme and one host
	/*for(var/mob/dead/new_player/player in player_list)
	var/list/possible_targets = list()
		for(var/datum/mind/possible_target in ticker.minds)
			if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD))
				possible_targets += possible_target*/

	if(antag_candidates.len < 1)
		log_admin("Something went wrong after calculations for possible memes.")
		testing("Something went wrong after calculations for possible memes.")
		return 0 // not enough candidates for meme

	while(antag_candidates.len >= 1)
		//for(var/mob/dead/new_player/player in player_list)
		var/datum/mind/meme = pick(antag_candidates)
		antag_candidates.Remove(meme)

		//var/datum/mind/first_host = pick(possible_memes)
		//possible_memes.Remove(first_host)

		modePlayer += meme
		//modePlayer += first_host
		memes += meme
		//first_hosts += first_host

		// so that we can later know which host belongs to which meme
		//assigned_hosts[meme.key] = first_host

		meme.assigned_role = "MODE" //So they aren't chosen for other jobs.
		meme.special_role = "Meme"

	return 1

/datum/game_mode/meme/pre_setup()
	return 1


/datum/game_mode/meme/post_setup()
	var/list/possible_hosts = list()
	var/datum/mind/target = null
	for(var/datum/mind/possible_host in ticker.minds)
		if(possible_host.assigned_role != "MODE" && ishuman(possible_host.current) && (possible_host.current.stat != DEAD))
			possible_hosts += possible_host
	if(!(possible_hosts.len))
		log_admin("Something went wrong, no possible hosts!")
		testing("Something went wrong, no possible hosts!")
		return

	// create a meme and enter it
	for(var/datum/mind/meme in memes)
		var/mob/living/parasite/meme/M = new
		var/mob/original = meme.current
		M.meme_death = pick ("stoxin", "bdam", "holywater", "mindbreaker", "beer", "burns")
		meme.transfer_to(M)
		M.clearHUD()

		if(possible_hosts.len > 0)
			target = pick(possible_hosts)

		M.enter_host(target.current)
		possible_hosts -= target

		/**
		// this is a redundant check, but I don't think the above works..
		// if picking hosts works with this method, remove the method above
		if(!first_host)
			first_host = pick(first_hosts)
			first_hosts.Remove(first_host)*/

		forge_meme_objectives(meme)

		qdel(original)

	log_admin("Created [memes.len] memes.")

	return ..()


/datum/game_mode/proc/forge_meme_objectives(datum/mind/meme, datum/mind/first_host)
	if (config.objectives_disabled)
		return

	// meme always needs to attune X hosts
	var/datum/objective/meme_attune/attune_objective = new
	attune_objective.owner = meme
	attune_objective.gen_amount_goal(3,6)
	meme.objectives += attune_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = meme
	kill_objective.find_target()
	meme.objectives += kill_objective

	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = meme
	meme.objectives += survive_objective

	// generate some random objectives, use standard traitor objectives
//	var/job = first_host.assigned_role

/*	for(var/datum/objective/o in SelectObjectives(job, meme))
		o.owner = meme
		meme.objectives += o */
	greet_meme(meme)
	return

/datum/game_mode/proc/greet_meme(datum/mind/meme, you_are=1)
	if (you_are)
		var/meme_death_explained = "sleep toxin"
		var/mob/living/parasite/meme/M = meme.current
		if (M.meme_death == "stoxin")
			meme_death_explained = "sleep toxin"
		if (M.meme_death == "bdam")
			meme_death_explained = "brain"
		if (M.meme_death == "holywater")
			meme_death_explained = "holy water"
		if (M.meme_death == "mindbreaker")
			meme_death_explained = "mind breaking drug"
		if (M.meme_death == "beer")
			meme_death_explained = "firewater"
		if (M.meme_death == "burns")
			meme_death_explained = "fire"
		to_chat(meme.current, "<B>You are a <span class = 'red'>meme</span>!</B>")
		to_chat(meme.current, "<B>Your death is in <span class = 'red'>[meme_death_explained]</span>!</B>")
		meme.store_memory("<B>Your death is in [meme_death_explained]!</B>", 0, 0)

	var/obj_count = 1
	for(var/datum/objective/objective in meme.objectives)
		to_chat(meme.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return

/datum/game_mode/meme/check_finished()
	var/memes_alive = 0
	for(var/datum/mind/meme in memes)
		if(!istype(meme.current,/mob/living))
			continue
		if(meme.current.stat==2)
			continue
		memes_alive++

	if (memes_alive)
		return ..()
	else
		return 1

/datum/game_mode/proc/auto_declare_completion_meme()
	var/text = ""
	for(var/datum/mind/meme in memes)
		var/memewin = 1
		var/attuned = 0
		if((meme.current) && istype(meme.current,/mob/living/parasite/meme))
			text += "The meme was <B>[meme.current.key]</B>.<BR>"
			text += "The last host was <B>[meme.current:host.key]</B>.<BR>"
			text += "<B>Hosts attuned:</B> [attuned]<BR>"

			var/count = 1
			for(var/datum/objective/objective in meme.objectives)
				if(objective.check_completion())
					text += "<B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font><BR>"
					feedback_add_details("meme_objective","[objective.type]|SUCCESS")
				else
					text += "<B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Failed.</font><BR>"
					feedback_add_details("meme_objective","[objective.type]|FAIL")
					memewin = 0
				count++

		else
			memewin = 0

		if(memewin)
			text += "<B>The meme was successful!<B>"
			feedback_add_details("meme_success","SUCCESS")
			score["roleswon"]++
		else
			text += "<B>The meme has failed!<B>"
			feedback_add_details("meme_success","FAIL")
		text += "<BR><HR>"
	return text
