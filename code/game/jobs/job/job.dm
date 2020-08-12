/datum/job
	//The name of the job, used for preferences, bans and more. Make sure you know what you're doing before changing this.
	var/title = "NOPE"

	var/list/access = list()

	//Bitflags for the job  (Ha-ha we no longer use bitflags this is useless)
	var/flag = 0 // Deprecated (is here only for savefile compatibility)
	var/department_flag = 0 // Deprecated (is here only for savefile compatibility)

	//Players will be allowed to spawn in as jobs that are set to "Station"
	var/faction = "None"

	//How many players can be this job
	var/total_positions = 0

	//How many players can spawn in as this job
	var/spawn_positions = 0

	//How many players have this job
	var/current_positions = 0

	//Supervisors, who this person answers to directly
	var/supervisors = ""

	//Sellection screen color
	var/selection_color = "#ffffff"

	//the type of the ID the player will have
	var/idtype = /obj/item/weapon/card/id

	//List of alternate titles, if any. outfits as assoc values.
	var/list/alt_titles

	//If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/req_admin_notify

	//If you have use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age = 0

	var/outfit = null

	//If you have use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_ingame_minutes ingame minutes old. (meaning they must play a game.)
	var/minimal_player_ingame_minutes = 0

	//Should we spawn and give him his selected loadout items
	var/give_loadout_items = TRUE

	var/salary = 0
	//salary ratio - for global salary changes
	var/salary_ratio = 1

	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	/// Species that can not be this job.
	var/list/restricted_species = list()
	/// Species flags that can not do this job.
	var/list/restricted_species_flags = list()

/datum/job/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/job/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE, alt_title)
	if(!H)
		return FALSE

	var/outfit_type = get_outfit(H, alt_title)
	if(outfit_type)
		H.equipOutfit(outfit_type, visualsOnly)

	post_equip(H, visualsOnly)
	return TRUE

/datum/job/proc/get_outfit(mob/living/carbon/human/H, alt_title)
	if(H.mind)
		if(alt_titles && H.mind.role_alt_title)
			return alt_titles[H.mind.role_alt_title] || outfit
	if(alt_title && alt_titles)
		return alt_titles[alt_title] || outfit
	return outfit

/datum/job/proc/get_access()
	return access.Copy()

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(config.use_ingame_minutes_restriction_for_jobs)
		if(available_in_real_minutes(C) == 0)
			return 1	//Available in 0 minutes = available right now = player is old enough to play.
	else
		if(available_in_days(C) == 0)
			return 1	//Available in 0 days = available right now = player is old enough to play.
	return 0

/datum/job/proc/is_species_permitted(species)
	if(!config.use_alien_job_restriction)
		return TRUE
	if(species in restricted_species)
		return FALSE

	var/datum/species/S = all_species[species]
	if(S && special_species_check(S))
		for(var/flag in restricted_species_flags)
			if(S.flags[flag] == restricted_species_flags[flag])
				return FALSE

		return TRUE

	return FALSE

/// Return TRUE to allow the species S to be this job.
/datum/job/proc/special_species_check(datum/species/S)
	return TRUE

/datum/job/proc/available_in_days(client/C)
	if(!C)
		return 0
	if(!config.use_age_restriction_for_jobs)
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	if(!isnum(minimal_player_age))
		return 0

	return max(0, minimal_player_age - C.player_age)

/datum/job/proc/available_in_real_minutes(client/C)
	if(!C)
		return 0
	if(C.holder || C.deadmin_holder)
		return 0
	if(!config.use_age_restriction_for_jobs)
		return 0
	if(!isnum(C.player_ingame_age))
		return 0
	if(!isnum(minimal_player_ingame_minutes))
		return 0

	return max(0, minimal_player_ingame_minutes - C.player_ingame_age)

//Not sure where to put this proc, lets leave it here for now.
/proc/role_available_in_minutes(mob/M, role)
	if(!M || !istype(M) || !M.ckey)
		return 0
	var/client/C = M.client
	if(!C)
		return 0
	if(C.holder || C.deadmin_holder)
		return 0
	if(!config.use_age_restriction_for_jobs)
		return 0
	if(!config.use_ingame_minutes_restriction_for_jobs)
		return 0
	if(!isnum(C.player_ingame_age))
		return 0
	if(!(role in roles_ingame_minute_unlock))
		return 0

	return max(0, roles_ingame_minute_unlock[role] - C.player_ingame_age)

/datum/job/proc/is_position_available()
	return (current_positions < total_positions) || (total_positions == -1)

/datum/job/proc/map_check()
	return TRUE
