/*
 * A quality is a special opportunity given to a player for one round.
 *
 * The purpose of a quality is to provide novelty, challenge, and replayability.
 *
 * Qualities must not impact the gameplay too greatly, due to the nature of their acquisition.
 * Qualities that DO impact gameplay in a big way should be ignoreable in some way, for example by being job-restricted.
 * Qualities that provide a challenge must adequately explain to the player what the challenge at hand is.
 */
/datum/quality
	// The name of a quality given to the admin.
	var/name
	// The description of the quality given to a player.
	var/desc
	// The requirement, as described to the player.
	var/requirement
	// The maximum amount of players that can even receive this quality.
	var/max_amount = -1

	// The amount of players that already have this quality.
	var/amount = 0

	/*
		List of pools this quality belongs to.
		Should AT LEAST be something from [QUALITY_POOL_POSITIVEISH, QUALITY_POOL_QUIRKIEISH, QUALITY_POOL_NEGATIVEISH]
	*/
	var/list/pools

	// A chance that this quality does not announce itself.
	// CURRENTLY UNUSED. WHENEVER A QUALITY THAT BECOMES MORE INTERESTING WHEN IT IS HIDDEN APPEARS
	// SET THIS TO SOMETHING LIKE 20% SO THAT THE HIDDEN QUALITY CAN MASK ITSELF BEHIND ANY OTHER
	var/hidden_chance = 0

	// List of jobs, or sub-jobs required to be given this quality. Please note that `requirement` variable is not set automatically!
	var/list/jobs_required
	// List of xeno species required to be able to get this quality. Please note that `requirement` variable is not set automatically!
	var/list/species_required

// Whether it is even possible for this player to get this quality (job bans, xeno whitelist)
/datum/quality/proc/satisfies_availability(client/C)
	if(jobs_required && !can_be_jobs(C, jobs_required))
		return FALSE

	if(species_required && !can_be_species(C, species_required))
		return FALSE

	return TRUE

// Whether the spawned-in human can get this quality. For example a player can choose a job that doesn't fit this quality.
// Latespawn arg is true for players spawning after roundstart.
/datum/quality/proc/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	if(jobs_required && !is_jobs(H, jobs_required))
		return FALSE

	if(species_required && !is_species(H, species_required))
		return FALSE

	return TRUE

// Latespawn arg is true for players spawning after roundstart.
/datum/quality/proc/add_effect(mob/living/carbon/human/H, latespawn)
	return

/datum/quality/proc/is_jobs(mob/living/carbon/human/H, list/jobs)
	return (H.mind.assigned_role in jobs) || (H.mind.role_alt_title in jobs)

/datum/quality/proc/is_species(mob/living/carbon/human/H, list/species)
	return H.get_species() in species

/datum/quality/proc/can_be_jobs(client/C, list/jobs)
	for(var/job in jobs)
		if(jobban_isbanned(C.mob, job))
			continue
		var/datum/job/J = SSjob.GetJob(job)
		if(!J)
			J = SSjob.GetJobByAltTitle(job)
		if(!J.player_old_enough(C))
			continue
		if(!J.map_check())
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
