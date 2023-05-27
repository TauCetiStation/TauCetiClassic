/datum/role/death_commando
	name = DEATHSQUADIE
	id = DEATHSQUADIE
	disallow_job = TRUE

	logo_state = "death-logo"
	antag_hud_type = ANTAG_HUD_DEATHCOM
	antag_hud_name = "huddeathsquad"
	skillset_type = /datum/skillset/max

/datum/role/death_commando/AssignToRole(datum/mind/M, override = FALSE, msg_admins = TRUE, laterole = TRUE)
	if(!..())
		return FALSE
	ADD_TRAIT(M.current, TRAIT_DEATHSQUAD_MEMBER, GAMEMODE_TRAIT)
	ADD_TRAIT(M.current, TRAIT_DEATHSQUAD_OP, GAMEMODE_TRAIT)
	return TRUE

/datum/role/death_commando/RemoveFromRole(datum/mind/M, msg_admins)
	. = ..()
	REMOVE_TRAIT(M.current, TRAIT_DEATHSQUAD_MEMBER, GAMEMODE_TRAIT)
	REMOVE_TRAIT(M.current, TRAIT_DEATHSQUAD_OP, GAMEMODE_TRAIT)

/datum/role/emergency_responder
	name = RESPONDER
	id = RESPONDER
	disallow_job = TRUE

	logo_state = "ert-logo"
	antag_hud_type = ANTAG_HUD_ERT
	antag_hud_name = "hudoperative"
	skillset_type = /datum/skillset/max

/datum/role/emergency_responder/AssignToRole(datum/mind/M, override = FALSE, msg_admins = TRUE, laterole = TRUE)
	if(!..())
		return FALSE
	ADD_TRAIT(M.current, TRAIT_STRIKE_TEAMMATE, GAMEMODE_TRAIT)
	ADD_TRAIT(M.current, TRAIT_STRIKE_TEAM_MEMBER, GAMEMODE_TRAIT)
	return TRUE

/datum/role/emergency_responder/RemoveFromRole(datum/mind/M, msg_admins)
	. = ..()
	REMOVE_TRAIT(M.current, TRAIT_STRIKE_TEAMMATE, GAMEMODE_TRAIT)
	REMOVE_TRAIT(M.current, TRAIT_STRIKE_TEAM_MEMBER, GAMEMODE_TRAIT)

/datum/role/syndicate_elite_commando
	name = SYNDIESQUADIE
	id = SYNDIESQUADIE
	disallow_job = TRUE

	logo_state = "elite-logo"
	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "hudsyndicate"
	skillset_type = /datum/skillset/max

/datum/role/syndicate_elite_commando/AssignToRole(datum/mind/M, override = FALSE, msg_admins = TRUE, laterole = TRUE)
	if(!..())
		return FALSE
	ADD_TRAIT(M.current, TRAIT_ELITE_SQUAD_MEMBER, GAMEMODE_TRAIT)
	ADD_TRAIT(M.current, TRAIT_ELITE_SQUAD_OP, GAMEMODE_TRAIT)
	return TRUE

/datum/role/syndicate_elite_commando/RemoveFromRole(datum/mind/M, msg_admins)
	. = ..()
	REMOVE_TRAIT(M.current, TRAIT_ELITE_SQUAD_MEMBER, GAMEMODE_TRAIT)
	REMOVE_TRAIT(M.current, TRAIT_ELITE_SQUAD_OP, GAMEMODE_TRAIT)
