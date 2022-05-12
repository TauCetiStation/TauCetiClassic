/datum/faction/props
	name = F_PROPS
	ID = F_PROPS

	roletype = /datum/role/prop

	logo_state = "change-logoa"

	var/points = 0

/datum/faction/props/GetFactionHeader()
	var/icon/logo_left = get_logo_icon("change-logoa")
	var/icon/logo_right = get_logo_icon("change-logob")
	var/header = {"[bicon(logo_left, css = "style='position:relative; top:10px;'")] <FONT size = 2><B>[capitalize(name)]</B></FONT> [bicon(logo_right, css = "style='position:relative; top:10px;'")]"}
	return header

/datum/faction/props/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/prop/points)

/datum/faction/props/GetScoreboard()
	. = ..()
	. += "Очки: [round(points)]"

/datum/faction/props/AdminPanelEntry()
	. = ..()
	. += "<br>Очки: [points]"

/datum/faction/props/process()
	. = ..()
	for(var/datum/role/R in members)
		if(R.antag.current)
			points += 1
