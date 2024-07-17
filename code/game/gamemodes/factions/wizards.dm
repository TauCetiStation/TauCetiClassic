/datum/faction/wizards
	name = F_WIZFEDERATION
	ID = F_WIZFEDERATION
	logo_state = "wizard-logo"
	required_pref = ROLE_WIZARD

	initroletype = /datum/role/wizard
	roletype = /datum/role/wizard_apprentice

	max_roles = 2

/datum/faction/wizards/can_setup(num_players)
	max_roles = max(1, round(num_players/20))
	return (..() && length(landmarks_list["Wizard"]))

/datum/faction/wizards/OnPostSetup()
	for(var/datum/role/R in members)
		R.antag.current.forceMove(pick_landmarked_location("Wizard"))
	return ..()

/datum/faction/wizards/check_win()
	if(config.continous_rounds)
		return FALSE

	var/wizards_alive = 0
	for(var/datum/role/R in members)
		if(!iscarbon(R.antag.current) || R.antag.current.stat == DEAD)
			continue
		wizards_alive++

	if (wizards_alive)
		return FALSE
	stage = FS_DEFEATED
	return TRUE
