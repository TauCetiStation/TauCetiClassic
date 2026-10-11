/datum/package_wrap
	var/texture = null
	var/details = null
	var/pieces_color = null

/datum/package_wrap/cardboard
	texture = "cardboard"
	pieces_color = list("#b38050")

/datum/package_wrap/present
	texture = "present"
	details = "bow"
	pieces_color = list("#cc0000" = 1, "#009900" = 2)
