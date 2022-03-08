/datum/quality
	var/desc

	var/requirement

	var/hidden_chance = 0

	var/list/jobs_required
	var/list/species_required
	var/list/roles_required

// Whether it is even possible for this player to get this quality (job bans, xeno whitelist)
/datum/quality/proc/satisfies_availability(client/C)
	if(jobs_required && can_be_jobs(C, jobs_required))
		return TRUE

	if(species_required && can_be_species(C, species_required))
		return TRUE

	if(roles_required && can_be_roles(C, roles_required))
		return TRUE

	return FALSE

// Whether the spawned-in human can get this quality. For example a player can choose a job that doesn't fit this quality.
// Latespawn arg is true for players spawning after roundstart.
/datum/quality/proc/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	if(jobs_required && is_jobs(H, jobs_required))
		return TRUE

	if(species_required && is_species(H, species_required))
		return TRUE

	if(roles_required && is_role(H, roles_required))
		return TRUE

	return FALSE

// Latespawn arg is true for players spawning after roundstart.
/datum/quality/proc/add_effect(mob/living/carbon/human/H, latespawn)
	return

/datum/quality/proc/is_jobs(mob/living/carbon/human/H, list/jobs)
	return (H.mind.assigned_role in jobs) || (H.mind.role_alt_title in jobs)

/datum/quality/proc/is_species(mob/living/carbon/human/H, list/species)
	return H.get_species() in species

/datum/quality/proc/is_role(mob/living/carbon/human/H, list/roles)
	for(var/role in roles)
		if(isrole(role, H))
			return TRUE
	return FALSE

/datum/quality/proc/can_be_jobs(client/C, list/jobs)
	for(var/job in jobs)
		if(jobban_isbanned(C.mob, job))
			continue
		var/datum/job/J = SSjob.GetJob(job)
		if(!J)
			J = SSjob.GetJobByAltTitle(job)
		if(!J.player_old_enough(C))
			continue

		return TRUE

	return FALSE

/datum/quality/proc/can_be_species(client/C, list/species)
	if(!config.usealienwhitelist)
		return TRUE

	for(var/specie in species)
		if(is_alien_whitelisted(C.mob, specie))
			return TRUE

	return FALSE

/datum/quality/proc/can_be_roles(client/C, list/roles)
	for(var/role in roles)
		if(!jobban_isbanned(C.mob, role) && !jobban_isbanned(C.mob, "Syndicate") && !role_available_in_minutes(C.mob, role))
			return TRUE
	return FALSE
