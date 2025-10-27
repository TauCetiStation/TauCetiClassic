/datum/game_mode/junkyard
	name = "Junkyard"
	config_name = "junkyard"
	minimum_player_count = 15
	minimum_players_bundles = 30
	probability = 20

/datum/game_mode/junkyard/Setup()
	. = ..()

	if(!.)
		return FALSE

	SSjunkyard.populate_junkyard()
	for(var/obj/machinery/gateway/center/G in gateways_list)
		if(G.name == "Junkyard Gateway")
			G.toggleon()

	if(!SSjunkyard.junkyard_initialised)
		return FALSE
