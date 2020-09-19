/datum/religion/cult
	deity_names_by_name = list(
		"Cult of Blood" = list("Nar-Sie", "Geometr")
	)

	bible_info_by_name = list(
		"Cult of Blood" = /datum/bible_info/cult/blood
	)
	
	pews_info_by_name = list(
		"Satanism" = "dead"
	)

	altar_info_by_name = list(
		"Satanism" = "satanaltar"
	)

	carpet_dir_by_name = list(
		"Islam" = 4
	)

/datum/religion/cult/setup_religions()
	global.cult_religion = src
