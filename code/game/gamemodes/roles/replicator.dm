/datum/role/replicator
	name = REPLICATOR
	id = REPLICATOR

	disallow_job = TRUE

	required_pref = ROLE_REPLICATOR

	logo_state = "replicators"

	antag_hud_type = ANTAG_HUD_ALIEN
	antag_hud_name = "hudalien"

/datum/role/replicator/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>You are a replicator. A part of a Swarm. You must consume materials and create infrastructure required for a Bluespace Catapult, which will utilize a
	rift so that you will spread on through the galaxy. Multiply and prosper!</b></span>"})
	to_chat(antag.current, "<span class='warning'>Remember. This reality is not meant for you, you are slowly <b>dying</b>. Consuming materials repairs you, allowing to stay in this fleeting world a little longer...</span>")

/datum/role/replicator/GetScoreboard()
	. = ..()
	var/ckey = ckey(antag.key)
	var/datum/replicator_array_info/RAI = global.replicators_faction.ckey2info[ckey]
	. += "<br><b>Materials Contribution:</b> [RAI.swarms_goodwill]"
