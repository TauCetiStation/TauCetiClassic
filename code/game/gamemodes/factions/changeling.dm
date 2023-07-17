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
	limit_roles(num_players)
	return TRUE

/datum/faction/changeling/proc/limit_roles(num_players)
	max_roles = 1 + round(num_players / 10)
	return max_roles

/datum/faction/changeling/GetFactionHeader()
	var/icon/logo_left = get_logo_icon("change-logoa")
	var/icon/logo_right = get_logo_icon("change-logob")
	var/header = {"[bicon(logo_left, css = "style='position:relative; top:10px;'")] <FONT size = 2><B>[capitalize(name)]</B></FONT> [bicon(logo_right, css = "style='position:relative; top:10px;'")]"}
	return header

/datum/faction/changeling/imposter
	name = "Changeling Imposters"
	roletype = /datum/role/changeling/imposter
	initroletype = /datum/role/changeling/imposter

// Station has other antags
/datum/faction/changeling/imposter/limit_roles(num_players)
	max_roles = ..()
	max_roles /= 2
	log_debug("IMPOSTERS: Changeling faction limit roles: [max_roles]")
	return max_roles
