/datum/faction/wizards
	name = WIZFEDERATION
	ID = WIZFEDERATION
	logo_state = "wizard-logo"
	required_pref = ROLE_WIZARD

	initroletype = /datum/role/wizard
	roletype = /datum/role/wizard_apprentice

	max_roles = 1

/datum/faction/wizards/can_setup(num_players)
	return (..() && wizardstart.len != 0)

/datum/faction/wizards/OnPostSetup()
	for(var/datum/role/R in members)
		R.antag.current.forceMove(pick(wizardstart))
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
	else
		stage = FACTION_DEFEATED
		return TRUE
