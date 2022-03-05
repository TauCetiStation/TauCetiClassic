/datum/role/changeling/traitor
	name = TRAITORCHAN
	id = TRAITORCHAN
	required_pref = ROLE_CHANGELING
	skillset_type = /datum/skillset/max
	change_to_maximum_skills = FALSE

/datum/role/changeling/traitor/New()
	..()
	AddComponent(/datum/component/gamemode/syndicate, 20)
