/mob/living/carbon/monkey
	default_emotes = list(
		/datum/emote/list,
		/datum/emote/pray,
		/datum/emote/whimper,
		/datum/emote/roar,
		/datum/emote/gasp,
		/datum/emote/shiver,
		/datum/emote/drool,
		/datum/emote/choke,
		/datum/emote/moan,
		/datum/emote/nod,
		/datum/emote/twitch,
		/datum/emote/dance,
		/datum/emote/shake,
		/datum/emote/collapse,
		/datum/emote/deathgasp,
		/datum/emote/cough,
	)

/mob/living/carbon/monkey/diona/load_default_emotes()
	default_emotes += subtypesof(/datum/emote/nymph)
	return ..()
