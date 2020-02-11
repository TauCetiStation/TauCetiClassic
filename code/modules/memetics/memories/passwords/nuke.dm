/datum/meme/memory/password/nuke
	name = "nuke password"
	desc = "A safety key that should've prevented me from causing global mayhem, but I know it now."

	stack_id = "nuke_password"

	gain_txt = "You now know the password to the nuke."
	lose_txt = "You forget the password to the nuke."

	flags = list(
				MEME_SPREAD_VERBALLY = TRUE,
				MEME_SPREAD_READING = TRUE,
			)

	destroy_on_no_hosts = TRUE

	forgetting_txts = list("Uh, maybe not today?", "What was the darn password...", "DAMN, TELL ME THE CODE!")
