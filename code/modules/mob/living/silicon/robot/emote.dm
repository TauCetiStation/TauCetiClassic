/mob/living/silicon/robot
	default_emotes = list(
		/datum/emote/pray
	)

/mob/living/silicon/robot/load_default_emotes()
	default_emotes += subtypesof(/datum/emote/robot)
	return ..()
