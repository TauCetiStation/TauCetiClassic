/datum/faction/maelstrom
	name = F_MAELSTROMCULT
	ID = F_MAELSTROMCULT
	logo_state = "maelstrom-logo"
	required_pref = ROLE_CULTIST

	initroletype = /datum/role/cyberpsycho

	min_roles = 3
	max_roles = 4

/datum/faction/maelstrom/HandleNewMind(datum/mind/M, laterole)
	. = ..()
	var/obj/effect/proc_holder/spell/targeted/communicate/pda/spell = locate(/obj/effect/proc_holder/spell/targeted/communicate/pda) in M.spell_list
	if(spell)
		M.current.RemoveSpell(spell)
	M.AddSpell(new /obj/effect/proc_holder/spell/targeted/communicate/pda)

/datum/faction/maelstrom/HandleRecruitedMind(datum/mind/M, laterole)
	. = ..()
	var/obj/effect/proc_holder/spell/targeted/communicate/pda/spell = locate(/obj/effect/proc_holder/spell/targeted/communicate/pda) in M.spell_list
	if(spell)
		M.current.RemoveSpell(spell)
	M.AddSpell(new /obj/effect/proc_holder/spell/targeted/communicate/pda)

/datum/faction/maelstrom/HandleRecruitedRole(datum/role/R)
	. = ..()
	var/obj/effect/proc_holder/spell/targeted/communicate/pda/spell = locate(/obj/effect/proc_holder/spell/targeted/communicate/pda) in R.antag.spell_list
	if(spell)
		R.antag.current.RemoveSpell(spell)
	R.antag.AddSpell(new /obj/effect/proc_holder/spell/targeted/communicate/pda)

/datum/faction/maelstrom/HandleRemovedRole(datum/role/R)
	. = ..()
	var/obj/effect/proc_holder/spell/targeted/communicate/pda/spell = locate(/obj/effect/proc_holder/spell/targeted/communicate/pda) in R.antag.spell_list
	if(spell)
		R.antag.current.RemoveSpell(spell)

/datum/faction/maelstrom/proc/is_acceptable_recruit(datum/mind/M)
	for(var/datum/objective/target/O in GetObjectives())
		if(O.target == M)
			return FALSE
	return TRUE

/datum/faction/maelstrom/HandleRecruitedMind(datum/mind/M, laterole)
	. = ..()
	if(.)
		M.current.Paralyse(5)

/datum/faction/maelstrom/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/target/assassinate/brutally)
	AppendObjective(/datum/objective/cult/job_convert)
	AnnounceObjectives()
	return TRUE
