#define LOYALIST "Loyalist"

/datum/role/loyalist
	name = LOYALIST
	id = LOYALIST
	required_pref = ROLE_LOYALIST
	logo_state = "rev-logo"

	antag_hud_type = ANTAG_HUD_REV
	antag_hud_name = "hudrevolutionary"

/datum/role/loyalist/CanBeAssigned(datum/mind/M)
	if(!..())
		return FALSE
	/* TODO:
	if(M.current.isloyal())
		return TRUE*/
	return TRUE

/datum/role/loyalist/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<span class='warning'><FONT size = 3>Now you are Loyalist! All crew members with a loyalty implant are your comrades. Follow orders from NanoTrasen!</FONT></span>")

/datum/role/loyalist/forgeObjectives()
	if(!..())
		return FALSE
	var/datum/objective/survive/S = AppendObjective(/datum/objective/survive)
	S.explanation_text = "Stay alive until the end. You are important part of the Chain of Command!"
	return TRUE
