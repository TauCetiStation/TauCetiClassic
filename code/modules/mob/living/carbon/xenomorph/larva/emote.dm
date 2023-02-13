/mob/living/carbon/xenomorph/larva
	default_emotes = list(
		/datum/emote/list,
		/datum/emote/pray,
		/datum/emote/twitch,
		/datum/emote/drool,
		/datum/emote/nod,
		/datum/emote/shake,
		/datum/emote/dance,
	)

/mob/living/carbon/xenomorph/larva/load_default_emotes()
	default_emotes += subtypesof(/datum/emote/larva)
	return ..()
