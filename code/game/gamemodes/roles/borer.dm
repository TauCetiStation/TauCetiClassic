/datum/role/borer
	name = BORER
	id = BORER
	disallow_job = TRUE

	logo_state = "borer-logo"

/datum/role/borer/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "Use your Infest power to crawl into the ear of a host and fuse with their brain.")
	to_chat(antag.current, "You can only take control temporarily, and at risk of hurting your host, so be clever and careful; your host is encouraged to help you however they can.")
	to_chat(antag.current, "Talk to your fellow borers with ;")

/datum/role/borer/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/borer_survive)
	AppendObjective(/datum/objective/borer_reproduce)
	AppendObjective(/datum/objective/escape)
	return TRUE
