// DTO aka Data Transfer Object, this means that you dont create any logic for these types
/datum/stat
	// Hello. Nothing to see here.

// Deprecated
/datum/stat/antagonists_completion
	var/faction
	var/role
	var/html

/datum/stat/centcomm_communication
	var/__type
	var/title
	var/author
	var/time
	var/content

/datum/stat/achievement
	var/key
	var/name
	var/title
	var/desc

/datum/stat/score
	var/crewscore      = 0 // this is the overall var/score for the whole round
	var/rating         = "Nothing of Value" // crewscore but string
	var/stuffshipped   = 0 // how many useful items have cargo shipped out?
	var/stuffharvested = 0 // how many harvests have hydroponics done?
	var/oremined       = 0 // obvious
	var/researchdone   = 0
	var/eventsendured  = 0 // how many random events did the station survive?
	var/powerloss      = 0 // how many APCs have poor charge?
	var/mess           = 0 // how much poo, puke, gibs, etc went uncleaned
	var/meals          = 0
	var/disease        = 0 // how many rampant, uncured diseases are on board the station
	var/deadcommand    = 0 // used during rev, how many command staff perished
	var/arrested       = 0 // how many traitors/revs/whatever are alive in the brig
	var/traitorswon    = 0 // how many traitors were successful?
	var/roleswon       = 0 // how many roles were successful?
	var/allarrested    = 0 // did the crew catch all the enemies alive?
	var/opkilled       = 0 // used during nuke mode, how many operatives died?
	var/disc           = 0 // is the disc safe and secure?
	var/nuked          = 0 // was the station blown into little bits?
	var/destranomaly   = 0 // anomaly of cult
	var/rec_antags     = 0 // How many antags did we reconvert

	//crew
	var/crew_escaped   = 0      // how many people got out alive?
	var/crew_dead      = 0      // dead bodies on the station, oh no
	var/crew_total     = 0      // how many people was registred as crew
	var/crew_survived  = 0      // how many people was registred as crew
	var/captain        = list() // who was captain of the shift (or captains?...)

	// these ones are mainly for the stat panel
	var/powerbonus    = 0 // if all APCs on the station are running optimally, big bonus
	var/messbonus     = 0 // if there are no messes on the station anywhere, huge bonus
	var/deadaipenalty = 0 // is the AI dead? if so, big penalty
	var/foodeaten     = 0 // nom nom nom
	var/clownabuse    = 0 // how many times a clown was punched, struck or otherwise maligned
	var/richestname   = 0 // this is all stuff to show who was the richest alive on the shuttle
	var/richestjob    = 0 // kinda pointless if you dont have a money system i guess
	var/richestcash   = 0
	var/richestkey    = 0
	var/dmgestname    = 0 // who had the most damage on the shuttle (but was still alive)
	var/dmgestjob     = 0
	var/dmgestdamage  = 0
	var/dmgestkey     = 0

/datum/stat/death_stat
	var/death_x
	var/death_y
	var/death_z
	var/time_of_death
	var/special_role
	var/assigned_role
	var/key
	var/mind_name
	var/real_name
	var/name
	var/from_suicide
	var/last_attacker_name
	var/last_attacker_key
	var/list/damage = list(
		"BRUTE" = 0,
		"FIRE" = 0,
		"TOXIN" = 0,
		"OXY" = 0,
		"CLONE" = 0,
		"BRAIN" = 0,
	)

/datum/stat/explosion_stat
	var/epicenter_x = 0
	var/epicenter_y = 0
	var/epicenter_z = 0
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 0
	var/flash_range = 0

/datum/stat/manifest_entry
	var/key
	var/name
	var/assignment
	var/special_role
	var/list/antag_roles = null // not a list

/datum/stat/antag_objective
	var/mind_name
	var/key
	var/special_role
	var/objective_type
	var/objective_desc
	var/objective_succeeded
	var/target_name
	var/target_role
