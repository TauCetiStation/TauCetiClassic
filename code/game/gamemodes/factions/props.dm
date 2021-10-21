/datum/faction/props
	name = F_PROPS
	ID = F_PROPS

	roletype = /datum/role/prop

	logo_state = "change-logoa"

/datum/faction/props/GetFactionHeader()
	var/icon/logo_left = get_logo_icon("change-logoa")
	var/icon/logo_right = get_logo_icon("change-logob")
	var/header = {"[bicon(logo_left, css = "style='position:relative; top:10px;'")] <FONT size = 2><B>[capitalize(name)]</B></FONT> [bicon(logo_right, css = "style='position:relative; top:10px;'")]"}
	return header
