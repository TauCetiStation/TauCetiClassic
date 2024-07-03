//Dead mobs can exist whenever. This is needful

INITIALIZE_IMMEDIATE(/mob/dead)

/mob/dead
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	var/spawning = FALSE // Referenced when you want to delete the new_player later on in the code.
	var/datum/spawners_menu/spawners_menu
	var/datum/spawner/registred_spawner

/mob/dead/Logout()
	..()
	if(registred_spawner)
		var/datum/spawner/S = registred_spawner
		S.cancel_registration(src)

/mob/dead/Destroy()
	QDEL_NULL(spawners_menu)

	return ..()

/**
  * Doesn't call parent, see [/atom/proc/atom_init]
  */
/mob/dead/atom_init()
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	mob_list += src
	prepare_huds()

	return INITIALIZE_HINT_NORMAL

/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return

/mob/dead/incapacitated(restrained_type = ARMS)
	return !IsAdminGhost(src)

/mob/dead/me_emote(message, message_type = SHOWMSG_VISUAL, intentional=FALSE)
	to_chat(src, "<span class='notice'>You can not emote.</span>")

/mob/dead/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << browse(null, "window=preferences_window")
	if(client)
		client.clear_character_previews()

/mob/dead/proc/has_admin_rights()
	return (client && client.holder && (client.holder.rights & R_ADMIN))

/mob/dead/proc/is_species_whitelisted(datum/species/S)
	if(!S)
		return TRUE
	return is_alien_whitelisted(src, S.name) || !config.usealienwhitelist || !S.flags[IS_WHITELISTED]

/mob/dead/proc/create_character_without_mind()
	spawning = 1
	close_spawn_windows()

	var/mob/living/carbon/human/new_character

	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]
	if(chosen_species)
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		if(is_species_whitelisted(chosen_species) || has_admin_rights())
			new_character = new(loc, client.prefs.species)

	if(!new_character)
		new_character = new(loc)

	new_character.lastarea = get_area(loc)
	if(client.prefs.language)
		new_character.add_language(client.prefs.language, LANGUAGE_NATIVE)


	playsound_stop(CHANNEL_MUSIC) // MAD JAMS cant last forever yo

	new_character.real_name = random_name(new_character.gender)
	new_character.dna.ready_dna(new_character)
	new_character.dna.UpdateSE()
	new_character.dna.original_character_name = new_character.real_name
	new_character.nutrition = rand(NUTRITION_LEVEL_HUNGRY, NUTRITION_LEVEL_WELL_FED)
	var/old_base_metabolism = new_character.get_metabolism_factor()
	new_character.metabolism_factor.Set(old_base_metabolism * rand(9, 11) * 0.1)

	if(key)
		new_character.key = key		//Manually transfer the key to log them in

	return new_character

/mob/dead/proc/create_character()
	var/mob/living/carbon/human/new_character

	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]
	if(chosen_species)
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		if(is_species_whitelisted(chosen_species) || has_admin_rights())
			new_character = new(loc, client.prefs.species)

	if(!new_character)
		new_character = new(loc)

	new_character.lastarea = get_area(loc)
	if(client.prefs.language)
		new_character.add_language(client.prefs.language, LANGUAGE_NATIVE)

	if(SSticker.random_players)
		new_character.gender = pick(MALE, FEMALE)
		client.prefs.real_name = random_name(new_character.gender)
		client.prefs.randomize_appearance_for(new_character)
	else
		client.prefs.copy_to(new_character)

	playsound_stop(CHANNEL_MUSIC) // MAD JAMS cant last forever yo

	if(mind)
		mind.active = 0					//we wish to transfer the key manually
		mind.original = new_character
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active

	new_character.name = real_name
	new_character.dna.ready_dna(new_character)
	new_character.dna.UpdateSE()
	new_character.dna.original_character_name = new_character.real_name
	new_character.nutrition = rand(NUTRITION_LEVEL_HUNGRY, NUTRITION_LEVEL_WELL_FED)
	var/old_base_metabolism = new_character.get_metabolism_factor()
	new_character.metabolism_factor.Set(old_base_metabolism * rand(9, 11) * 0.1)

	if(key)
		new_character.key = key		//Manually transfer the key to log them in

	return new_character

/mob/dead/proc/job_giving(rank)
	var/mob/living/carbon/human/character = create_character_without_mind()
	var/datum/job/job = SSjob.GetJob(rank)
	character.mind.assigned_job = job
	character.mind.assigned_role = rank
	character.mind.role_alt_title = SSjob.GetPlayerAltTitle(character, rank)
	job.current_positions++
	SSjob.EquipRank(character, rank, joined_late = TRUE)
	return character

/mob/dead/proc/latespawn_job_giving(rank)
	SSjob.AssignRole(src, rank, latejoin = TRUE)
	var/mob/living/carbon/human/character = create_character()
	SSjob.EquipRank(character, rank, joined_late = TRUE)
	return character

/mob/dead/proc/create_and_setup_latespawn_character(rank)
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished...</span>")
		return null
	spawning = 1
	close_spawn_windows()
	var/mob/living/carbon/human/character = latespawn_job_giving(rank)
	return character

/mob/dead/proc/add_character_to_players(mob/living/carbon/human/character)
	SSticker.mode.latespawn(character)
	if(character.mind.assigned_role != "Cyborg")
		data_core.manifest_inject(character)
		SSticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
	else
		character.Robotize()
	joined_player_list += character.ckey
	if(character.client)
		character.client.prefs.guard.time_velocity_spawn = world.timeofday
