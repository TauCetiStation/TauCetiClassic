/datum/role/replicator
	name = REPLICATOR
	id = REPLICATOR

	disallow_job = TRUE

	required_pref = ROLE_REPLICATOR

	logo_state = "replicators"

	antag_hud_type = ANTAG_HUD_ALIEN
	antag_hud_name = "hudalien"

	var/next_music_start = 0

/datum/role/replicator/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>You are a replicator. A part of a Swarm. You must consume materials and create infrastructure required for a Bluespace Catapult, which will utilize a
	rift so that you will spread on through the galaxy. Multiply and prosper!</b></span>"})

/datum/role/replicator/printplayerwithicon(datum/mind/M)
	. = ..()
	if(M.current && M.current.ckey)
		. += " <i>(Materials Contribution: [global.replicators_faction.swarms_goodwill[M.current.ckey]])</i>"
