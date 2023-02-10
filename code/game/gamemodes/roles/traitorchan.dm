/datum/role/changeling/traitor
	name = TRAITORCHAN
	id = TRAITORCHAN
	required_pref = ROLE_CHANGELING

/datum/role/changeling/traitor/New()
	..()
	AddComponent(/datum/component/gamemode/syndicate, 20)
