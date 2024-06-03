/datum/pref/player
	domain = PREF_DOMAIN_PLAYER

	// just so we can filter and not confuse players with preferences that they can't use
	// note that this does not validate if player has permissions to change preference
	var/admins_only = FALSE
	var/supporters_only = FALSE
