/datum/faction/changeling
	name = "Changeling Hivemind"
	ID = HIVEMIND
	initial_role = CHANGELING
	late_role = CHANGELING
	required_pref = CHANGELING
	initroletype = /datum/role/changeling
	desc = "An almost parasitic, shapeshifting entity that assumes the identity of its victims. Commonly used as smart bioweapons by the syndicate,\
	or simply wandering malignant vagrants happening upon a meal of identity that can carry them to further feeding grounds."

	logo_state = "change-logoz"

	//Hivemind Bank, contains a list of DNA that changelings can share and use.
	var/list/hivemind_bank = list()

/datum/faction/changeling/can_setup(num_players)
	max_roles = 1 + round(num_players / 10)
	return TRUE

/datum/faction/changeling/GetObjectivesMenuHeader()
	var/icon/logo_left = icon('icons/misc/logos.dmi', "change-logoa")
	var/icon/logo_right = icon('icons/misc/logos.dmi', "change-logob")
	var/header = {"<img src='data:image/png;base64,[icon2base64(logo_left)]' style='position:relative; top:10px;'> <FONT size = 2><B>[capitalize(name)]</B></FONT> <img src='data:image/png;base64,[icon2base64(logo_right)]' style='position:relative; top:10px;'>"}
	return header
