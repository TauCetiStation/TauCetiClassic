/datum/quality
	var/desc

	var/requirement

	var/list/jobs_required
	var/list/species_required

// Whether it is even possible for this player to get this quality (job bans, xeno whitelist)
/datum/quality/proc/availability_check(client/C)
	if(jobs_required && !pref_job_checks(C, jobs_required))
		return FALSE

	if(species_required && !pref_species_checks(C, species_required))
		return FALSE

	return TRUE

// Whether the spawned-in human can get this quality. For example a player can choose a job that doesn't fit this quality.
// Latespawn arg is true for players spawning after roundstart.
/datum/quality/proc/restriction_check(mob/living/carbon/human/H, latespawn)
	if(jobs_required && !job_checks(H, jobs_required))
		return FALSE

	if(species_required && !species_checks(H, species_required))
		return FALSE

	return TRUE

// Latespawn arg is true for players spawning after roundstart.
/datum/quality/proc/add_effect(mob/living/carbon/human/H, latespawn)
	return

/datum/quality/proc/job_checks(mob/living/carbon/human/H, list/jobs)
	return H.mind.assigned_role in jobs

/datum/quality/proc/species_checks(mob/living/carbon/human/H, list/species)
	return H.get_species() in species

/datum/quality/proc/pref_job_checks(client/C, list/jobs)
	for(var/job in jobs)
		if(jobban_isbanned(C.mob, job))
			continue
		var/datum/job/J = SSjob.GetJob(job)
		if(!J.player_old_enough(C))
			continue

		return TRUE

	return FALSE

/datum/quality/proc/pref_species_checks(client/C, list/species)
	if(!config.usealienwhitelist)
		return TRUE

	for(var/specie in species)
		if(is_alien_whitelisted(C.mob, specie))
			return TRUE

	return FALSE
