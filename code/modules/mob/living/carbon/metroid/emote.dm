/mob/living/carbon/slime
	default_emotes = list(
		/datum/emote/list,
		/datum/emote/pray,
		/datum/emote/moan,
		/datum/emote/shiver,
		/datum/emote/twitch,
	)

/mob/living/carbon/slime/load_default_emotes()
	default_emotes += subtypesof(/datum/emote/slime) - /datum/emote/slime/face
	return ..()
