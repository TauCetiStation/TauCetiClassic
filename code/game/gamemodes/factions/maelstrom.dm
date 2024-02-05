#define F_MAELSTROMCULT "Maelstrom"

/datum/faction/maelstrom
	name = F_MAELSTROMCULT
	ID = F_MAELSTROMCULT
	logo_state = "maelstrom-logo"
	required_pref = ROLE_CULTIST

	initroletype = /datum/role/cyberpsycho

	min_roles = 3
	max_roles = 4

/datum/faction/maelstrom/HandleRecruitedMind(datum/mind/M, laterole)
	. = ..()
	if(.)
		M.current.Paralyse(5)

/datum/faction/maelstrom/forgeObjectives()
	if(!..())
		return FALSE
	///datum/objective/target/assassinate/brutally
	///datum/objective/cult/job_convert
	return TRUE

/*
/datum/faction/maelstrom/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player as anything in global.human_list)
		if(!player.client)
			continue
		if(player.mind.GetRole(CYBERPSYCHO))
			continue
		ucs += player.mind
	return ucs
*/
