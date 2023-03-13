/datum/emote/slime/face
	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

	var/mood

/datum/emote/slime/face/do_emote(mob/living/carbon/slime/user, emote_key, intentional)
	user.mood = mood
	user.regenerate_icons()

/datum/emote/slime/face/noface
	key = "noface"
	mood = null

/datum/emote/slime/face/smile
	key = "smile"
	mood = "mischevous"

/datum/emote/slime/face/colon_three
	key = ":3"
	mood = ":33"

/datum/emote/slime/face/pout
	key = "pout"
	mood = "pout"

/datum/emote/slime/face/frown
	key = "frown"
	mood = "sad"

/datum/emote/slime/face/scowl
	key = "scowl"
	mood = "angry"
