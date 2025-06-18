/datum/faction/ninja
	name = F_SPIDERCLAN
	ID = F_SPIDERCLAN

	initroletype = /datum/role/ninja

	min_roles = 2
	max_roles = 2

	required_pref = ROLE_NINJA

	logo_state = "ninja-logo"

/datum/faction/ninja/can_setup(num_players)
	if (!..())
		return FALSE
	return length(landmarks_list["ninja"]) > 0

/datum/faction/ninja/OnPostSetup()
	for(var/datum/role/role in members)
		var/turf/start_point = pick_landmarked_location("ninja")
		role.antag.current.forceMove(start_point)
	return ..()

/datum/faction/ninja/check_win()
	if(config.continous_rounds)
		return FALSE
	var/ninjas_alive = 0
	for(var/datum/role/ninja_role in members)
		if(!ishuman(ninja_role.antag.current))
			continue
		if(ninja_role.antag.current.stat==DEAD)
			continue
		ninjas_alive++
	if(ninjas_alive)
		return FALSE
	stage = FS_ENDGAME
	return TRUE
