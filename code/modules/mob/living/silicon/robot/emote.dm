/mob/living/silicon/robot
	default_emotes = list(
		/datum/emote/list,
		/datum/emote/pray,
		/datum/emote/nod,
		/datum/emote/shake,
		/datum/emote/twitch,
	)

/mob/living/silicon/robot/load_default_emotes()
	default_emotes += subtypesof(/datum/emote/robot)
	return ..()
