/datum/role/zombie
	name = ZOMBIE
	id = ZOMBIE

	antag_hud_type = ANTAG_HUD_ZOMB
	antag_hud_name = "hudzombie"

	logo_state = "zombie-logo"

/datum/role/zombie/AssignToRole(datum/mind/M, override = FALSE, msg_admins = TRUE, laterole = TRUE)
	if(!..())
		return FALSE
	ADD_TRAIT(M.current, TRAIT_ZOMBIETIDE_MEMBER, GAMEMODE_TRAIT)
	return TRUE

/datum/role/zombie/RemoveFromRole(datum/mind/M, msg_admins)
	. = ..()
	REMOVE_TRAIT(M.current, TRAIT_ZOMBIETIDE_MEMBER, GAMEMODE_TRAIT)

/datum/role/zombie/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "You are reanimated, mindless, decaying corpses with a hunger for human brains. Avoid plants.")
