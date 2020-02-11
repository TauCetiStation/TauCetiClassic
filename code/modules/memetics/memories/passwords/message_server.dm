/datum/meme/memory/password/PDA
	name = "PDA servers password"
	desc = "A password I can use to log into the PDA servers."

	stack_id = "PDA_password"

	gain_txt = "You now know the password to PDA servers."
	lose_txt = "You forget the password to PDA servers."

	flags = list(
				MEME_SPREAD_VERBALLY = TRUE,
				MEME_SPREAD_READING = TRUE,
			)

	destroy_on_no_hosts = TRUE

/datum/meme/memory/password/PDA/get_forgetting_txt()
	var/obj/machinery/message_server/server = locate() in message_servers
	return "Uh... Was it " + server.GenerateKey() + "?"
