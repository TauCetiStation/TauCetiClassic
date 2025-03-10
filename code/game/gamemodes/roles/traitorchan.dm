/datum/role/changeling/traitor
	name = TRAITORCHAN
	id = TRAITORCHAN
	required_pref = ROLE_CHANGELING
	skillset_type = /datum/skillset/max
	moveset_type = /datum/combat_moveset/traitorchan
	change_to_maximum_skills = FALSE

/datum/role/changeling/traitor/New()
	..()
	AddComponent(/datum/component/gamemode/syndicate, 20, "traitor")

/datum/role/changeling/traitor/OnPostSetup(laterole)
	. = ..()
	for(var/datum/objective/O in objectives.GetObjectives())
		O.give_required_equipment()
