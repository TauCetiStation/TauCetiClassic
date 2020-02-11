/datum/meme/memory/password/case
	name = "briefcase password"
	desc = "A password to some secure briefcase."

	stack_id = "briefcase_password"

	gain_txt = "You now know the password to the secure briefcase."
	lose_txt = "You forget the password to the secure briefcase."

	flags = list(
				MEME_SPREAD_VERBALLY = TRUE,
				MEME_SPREAD_READING = TRUE,
			)

	destroy_on_no_hosts = TRUE

	forgetting_txts = list("Uh, what was it?", "What was the darn password...", "Maybe it's 55555?")
