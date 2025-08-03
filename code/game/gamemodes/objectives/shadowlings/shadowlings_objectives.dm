/datum/objective/enthrall
	explanation_text = "Перейдите в свою истинную форму, используя способность Восхождение. Она может быть использована только при наличии 50% экипажа в виде коллективных рабов. После трансформации, разблокируется способность Коллективный разум."
/datum/objective/enthrall/check_completion()
	var/datum/faction/shadowlings/S = faction
	return istype(S) && S.shadowling_ascended
