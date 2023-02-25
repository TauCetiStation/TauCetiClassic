/datum/role/loyalist
	name = LOYALIST
	id = LOYALIST
	required_pref = ROLE_LOYALIST
	logo_state = "loyal-logo"

	antag_hud_type = ANTAG_HUD_LOYAL
	antag_hud_name = "hudloyalist"

/datum/role/loyalist/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<span class='warning'><FONT size = 3>Now you are Loyalist! All crew members with a loyalty implant are your comrades. Follow orders from NanoTrasen!</FONT></span>")

/datum/role/loyalist/forgeObjectives()
	if(!..())
		return FALSE
	var/datum/objective/survive/S = AppendObjective(/datum/objective/survive)
	S.explanation_text = "Stay alive until the end. You are important part of the Chain of Command!"
	return TRUE
