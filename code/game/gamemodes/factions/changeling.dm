/datum/faction/changeling
	name = F_HIVEMIND
	ID = F_HIVEMIND
	required_pref = ROLE_CHANGELING

	initroletype = /datum/role/changeling
	roletype = /datum/role/changeling

	min_roles = 1
	max_roles = 4

	logo_state = "change-logoa"

	//Hivemind Bank, contains a list of DNA that changelings can share and use.
	var/list/hivemind_bank = list()

/datum/faction/changeling/can_setup(num_players)
	max_roles = 1 + round(num_players / 10)
	return TRUE

/datum/faction/changeling/GetFactionHeader()
	var/icon/logo_left = get_logo_icon("change-logoa")
	var/icon/logo_right = get_logo_icon("change-logob")
	var/header = {"[bicon(logo_left, css = "style='position:relative; top:10px;'")] <FONT size = 2><B>[capitalize(name)]</B></FONT> [bicon(logo_right, css = "style='position:relative; top:10px;'")]"}
	return header
