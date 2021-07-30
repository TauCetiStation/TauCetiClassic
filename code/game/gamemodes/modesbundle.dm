/datum/modesbundle
	var/name
	var/votable = TRUE
	var/hidden = TRUE // for mode annouce
	var/list/possible_gamemodes = list()

/datum/modesbundle/proc/get_gamemodes_name()
	var/list/L = list()
	for(var/type in possible_gamemodes)
		var/datum/game_mode/M = new type()
		if(M.potential_runnable())
			L += M.name
		qdel(M)
	if(!L.len) // if no mode can start, then the modes that will always start
		var/datum/modesbundle/run_anyway/super_bundle = new
		L = super_bundle.get_gamemodes_name()
	return L

/*
	All gamemodes,
	/datum/game_mode/abduction,
	/datum/game_mode/blob,
	/datum/game_mode/changeling,
	/datum/game_mode/cult,
	/datum/game_mode/extended,
	/datum/game_mode/heist,
	/datum/game_mode/infestation,
	/datum/game_mode/malfunction,
	/datum/game_mode/nuclear,
	/datum/game_mode/revolution,
	/datum/game_mode/shadowling,
	/datum/game_mode/traitorchan,
	/datum/game_mode/traitor,
	/datum/game_mode/wizard,
	/---------------MIXS----------------\,
	/datum/game_mode/mix/changabduct,
	/datum/game_mode/mix/borerxenochang,
	/datum/game_mode/mix/cultrev,
	/datum/game_mode/mix/cultwiz,
	/datum/game_mode/mix/nukeheist,
	/datum/game_mode/mix/wizabduct,
	/datum/game_mode/mix/wiztraitor,
*/

/datum/modesbundle/teambased
	name = "Team Based"
	possible_gamemodes = list(
		/datum/game_mode/abduction,
		/datum/game_mode/blob,
		/datum/game_mode/cult,
		/datum/game_mode/infestation,
		/datum/game_mode/nuclear,
		/datum/game_mode/revolution,
		/datum/game_mode/shadowling,
	)

/datum/modesbundle/mix
	name = "Mix"
	votable = TRUE

/datum/modesbundle/mix/New()
	for(var/type in subtypesof(/datum/game_mode/mix) + /datum/game_mode/extended)
		var/datum/game_mode/M = type
		if(initial(M.name))
			possible_gamemodes += type

/datum/modesbundle/extended
	name = "Extended"
	hidden = FALSE
	possible_gamemodes = list(/datum/game_mode/extended)

/datum/modesbundle/all
	name = "Random"
	votable = FALSE
	var/list/black_types

/datum/modesbundle/all/New()
	for(var/type in subtypesof(/datum/game_mode))
		if(black_types)
			if(type in black_types)
				continue
		var/datum/game_mode/M = type
		if(initial(M.name))
			possible_gamemodes += type

/datum/modesbundle/all/secret
	name = "Secret"
	votable = TRUE

/datum/modesbundle/all/secret/New()
	black_types = subtypesof(/datum/game_mode/mix)
	..()

/datum/modesbundle/run_anyway
	name = "Modes that will ALWAYS start"
	votable = FALSE
	hidden = FALSE
	possible_gamemodes = list(/datum/game_mode/extended)

/datum/modesbundle/run_anyway/get_gamemodes_name()
	var/list/L = list()
	for(var/type in possible_gamemodes)
		var/datum/game_mode/M = type
		L += initial(M.name)
	return L
