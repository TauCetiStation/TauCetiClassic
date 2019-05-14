/datum/game_mode/catastrophe
	name = "catastrophe"
	config_tag = "catastrophe"
	required_players = 0

	votable = FALSE

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 20

	var/datum/catastrophe_director/director = null

/datum/game_mode/catastrophe/announce()
	to_chat(world, "<B>The current game mode is - Catastrophe!</B>")
	to_chat(world, "<B>Prepare to suffer!</B>")

/datum/game_mode/catastrophe/pre_setup()
	var/rand_director = pick(subtypesof(/datum/catastrophe_director))
	director = new rand_director
	message_admins("GAMEMODE DIRECTOR IS [director.name] [ADMIN_VV(director)]")

	director.pre_setup()

	return TRUE

/datum/game_mode/catastrophe/post_setup()
	director.post_setup()

	if(SSshuttle)
		SSshuttle.always_fake_recall = TRUE
	return ..()

/datum/game_mode/catastrophe/process()
	..()
	director.process_director()
