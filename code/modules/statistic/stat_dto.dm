// DTO aka Data Transfer Object, this means that you dont create any logic for these types
/datum/stat
	// Hello. Nothing to see here.

// Documentation rules:
//  * First write the type of data
//  * Then write the format of data in square brackets or data pool in square brackets or comments
//  * At the end, write any comment about the variable
/datum/stat/communication_log
	// string, byond_type
	var/__type
	// string, anything
	var/title
	// string, anything
	var/author
	// string, [hh:mm]
	var/time
	// string, anything
	var/content

/datum/stat/achievement
	// string, anything
	var/key
	// string, anything
	var/name
	// string, anything
	var/title
	// string, anything
	var/desc

/datum/stat/score
	// int, [0...]
	var/crewscore      = 0 // this is the overall var/score for the whole round
	// string, pool in ./code/game/gamemodes/scoreboard.dm near switch(SSStatistics.score.crewscore)
	var/rating         = "Nothing of Value" // crewscore but string
	// int, [0...]
	var/stuffshipped   = 0 // how many useful items have cargo shipped out?
	// int, [0...]
	var/stuffharvested = 0 // how many harvests have hydroponics done?
	// int, [0...]
	var/oremined       = 0 // obvious
	// int, [0...]
	var/researchdone   = 0
	// int, [0...]
	var/eventsendured  = 0 // how many random events did the station survive?
	// int, [0...]
	var/powerloss      = 0 // how many APCs have poor charge?
	// int, [0...]
	var/mess           = 0 // how much poo, puke, gibs, etc went uncleaned
	// int, [0...]
	var/meals          = 0
	// int, [0...]
	var/disease        = 0 // how many rampant, uncured diseases are on board the station
	// int, [0...]
	var/deadcommand    = 0 // used during rev, how many command staff perished
	// int, [0...]
	var/arrested       = 0 // how many traitors/revs/whatever are alive in the brig
	// int, [0...]
	var/traitorswon    = 0 // how many traitors were successful?
	// int, [0...]
	var/roleswon       = 0 // how many roles were successful?
	// boolean, [0, 1]
	var/allarrested    = 0 // did the crew catch all the enemies alive?
	// int, [0...]
	var/opkilled       = 0 // used during nuke mode, how many operatives died?
	// boolean, [0, 1]
	var/disc           = 0 // is the disc safe and secure?
	// boolean, [0, 1]
	var/nuked          = 0 // was the station blown into little bits?
	// int, [0...]
	var/destranomaly   = 0 // anomaly of cult
	// int, [0...]
	var/rec_antags     = 0 // How many antags did we reconvert

	//crew
	// int, [0...]
	var/crew_escaped   = 0      // how many people got out alive?
	// int, [0...]
	var/crew_dead      = 0      // dead bodies on the station, oh no
	// int, [0...]
	var/crew_total     = 0      // how many people was registred as crew
	// int, [0...]
	var/crew_survived  = 0      // how many people was registred as crew
	// array of string, anything
	var/captain        = list() // who was captain of the shift (or captains?...)

	// these ones are mainly for the stat panel
	// int, [0...]
	var/powerbonus    = 0 // if all APCs on the station are running optimally, big bonus
	// int, [0...]
	var/messbonus     = 0 // if there are no messes on the station anywhere, huge bonus
	// int, [0...]
	var/deadaipenalty = 0 // is the AI dead? if so, big penalty
	// int, [0...]
	var/foodeaten     = 0 // nom nom nom
	// int, [0...]
	var/clownabuse    = 0 // how many times a clown was punched, struck or otherwise maligned
	// string, anything
	var/richestname   = "" // this is all stuff to show who was the richest alive on the shuttle
	// string, anything
	var/richestjob    = ""
	// int, [0...]
	var/richestcash   = 0
	// string, anything
	var/richestkey    = ""
	// string, anything
	var/dmgestname    = "" // who had the most damage on the shuttle (but was still alive)
	// string, anything
	var/dmgestjob     = ""
	// int, [0...]
	var/dmgestdamage  = 0
	// string, anything
	var/dmgestkey     = ""

/datum/stat/death_stat
	// int, [0...]
	var/death_x
	// int, [0...]
	var/death_y
	// int, [0...]
	var/death_z
	// string, [hh:mm]
	var/time_of_death
	// string, anything, name of antagonists' role
	var/special_role
	// string, anything
	var/assigned_role
	// string, anything
	var/mind_name
	// string, anything
	var/real_name
	// string, anything
	var/name
	// string, byond_type
	var/mob_type
	// boolean, [0, 1]
	var/from_suicide
	// string, anything
	var/last_attacker_name
	// string, anything
	var/last_phrase
	// string, anything
	var/last_examined_name
	// object, where DAMAGE TYPE: int, [0...]
	var/list/damage = list(
		"BRUTE" = 0,
		"FIRE" = 0,
		"TOXIN" = 0,
		"OXY" = 0,
		"CLONE" = 0,
		"BRAIN" = 0,
	)

/datum/stat/explosion_stat
	// int, [0...]
	var/epicenter_x = 0
	// int, [0...]
	var/epicenter_y = 0
	// int, [0...]
	var/epicenter_z = 0
	// int, [-infinity...]
	var/devastation_range = 0
	// int, [-infinity...]
	var/heavy_impact_range = 0
	// int, [-infinity...]
	var/light_impact_range = 0
	// int, [-infinity...]
	var/flash_range = 0
	// int, [-infinity...]
	var/flame_range = 0
	// string, [hh:mm]
	var/occurred_time

/datum/stat/manifest_entry
	// string, anything
	var/name
	// string, anything
	var/assigned_role
	// string, anything, name of antagonists' role
	var/special_role
	// string, species name from code\modules\mob\living\carbon\species.dm
	var/species
	// int, anything
	var/age
	// string, by byond
	var/gender
	// string, anything
	var/flavor
	// array of strings, where strings are antagonists' roles
	var/list/antag_roles = null

/datum/stat/leave_stat
	// string, anything
	var/name
	// string, anything
	var/assigned_role
	// string, anything, name of antagonists' role
	var/special_role
	// array of strings, where strings are antagonists' roles
	var/list/antag_roles = null

	// string, ["Ghosted", "Ghosted in Cryopod", "Disconnected", "Cryopod"]
	var/leave_type
	// string, [hh:mm]
	var/start_time
	// string, [hh:mm]
	var/leave_time

/datum/stat/emp_stat
	// int, [0...]
	var/epicenter_x = 0
	// int, [0...]
	var/epicenter_y = 0
	// int, [0...]
	var/epicenter_z = 0
	// int, [-infinity...]
	var/devastation_range = 0
	// int, [-infinity...]
	var/heavy_range = 0
	// int, [-infinity...]
	var/light_range = 0
	// string, [hh:mm]
	var/occurred_time

/datum/stat/rating
	// map of [string, float] where float is [0..5]
	var/list/ratings = list()

/datum/stat/vote
	// string from /datum/poll name
	var/name
	// int, [0...]
	var/total_votes
	// int, [0...]
	var/total_voters
	// string rfom /datum/vote_choice
	var/winner
	// map of [string, int] where int is [0...]
	var/list/results = list()
