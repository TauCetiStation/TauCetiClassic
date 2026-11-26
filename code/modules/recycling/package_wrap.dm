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

/datum/package_wrap/chinese
	texture = "chinese"
	details = "chinese_bow"
	pieces_color = list("#ba301e")

/datum/package_wrap/halloween
	texture = "halloween"
	details = null
	pieces_color = list("#282c3c")
