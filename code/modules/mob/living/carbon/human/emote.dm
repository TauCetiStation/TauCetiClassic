/mob/living/carbon/human
	default_emotes = list(
		/datum/emote/list,
		/datum/emote/pray,
		/datum/emote/shiver,
		/datum/emote/whimper,
		/datum/emote/moan,
		/datum/emote/twitch,
		/datum/emote/collapse,
		/datum/emote/faint,
		/datum/emote/roar,
		/datum/emote/clickable/help,
	)

/mob/living/carbon/human/load_default_emotes()
	default_emotes += subtypesof(/datum/emote/human)
	return ..()

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  sanitize(input(usr, "This is [src]. \He is...", "Pose", null)  as text)
