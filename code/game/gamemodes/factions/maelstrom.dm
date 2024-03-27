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
	AppendObjective(/datum/objective/target/assassinate/brutally)
	AppendObjective(/datum/objective/cult/job_convert)
	return TRUE
