/datum/role/replicator
	name = REPLICATOR
	id = REPLICATOR

	disallow_job = TRUE

	required_pref = ROLE_REPLICATOR

	logo_state = "replicators"

	antag_hud_type = ANTAG_HUD_ALIEN
	antag_hud_name = "hudalien"

	var/presence_name = ""
	var/array_color = ""
	var/swarms_goodwill = 0

	var/next_music_start = 0

/datum/role/replicator/New(datum/mind/M, datum/faction/fac, override = FALSE)
	presence_name = greek_pronunciation[length(fac.members) + 1] + "-[rand(0, 9)] Presence"
	array_color = pick(REPLICATOR_COLORS)
	return ..()

/datum/role/replicator/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>You are a replicator. A part of a Swarm. You must consume materials and create infrastructure required for a Bluespace Catapult, which will utilize a
	rift so that you will spread on through the galaxy. Multiply and prosper!</b></span>"})
	to_chat(antag.current, "<span class='warning'>Remember. This reality is not meant for you, you are slowly <b>dying</b>. Consuming materials repairs you, allowing to stay in this fleeting world a little longer...</span>")

/datum/role/replicator/GetScoreboard()
	. = ..()
	. += "<br><b>Presence Name:</b> [presence_name]"
	. += "<br><b>Materials Contribution:</b> [swarms_goodwill]"
