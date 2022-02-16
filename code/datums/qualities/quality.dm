/datum/quality
	var/desc

	var/restriction

// Whether it is even possible for this player to get this quality (job bans, xeno whitelist)
/datum/quality/proc/availability_check(client/C)
	return TRUE

// Whether the spawned-in human can get this quality. For example a player can choose a job that doesn't fit this quality.
// Latespawn arg is true for players spawning after roundstart.
/datum/quality/proc/restriction_check(mob/living/carbon/human/H, latespawn)
	return TRUE

// Latespawn arg is true for players spawning after roundstart.
/datum/quality/proc/add_effect(mob/living/carbon/human/H, latespawn)
	return

/datum/quality/proc/job_checks(client/C, list/jobs)
	. = FALSE
	for(var/job in jobs)
		if(jobban_isbanned(C.mob, job))
			continue
		var/datum/job/J = SSjob.GetJob(job)
		if(!J.player_old_enough(C))
			continue

		return TRUE

/datum/quality/proc/species_checks(client/C, list/species)
	if(!config.usealienwhitelist)
		return TRUE

	. = FALSE
	for(var/specie in species)
		if(is_alien_whitelisted(C.mob, specie))
			return TRUE
