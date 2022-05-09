/datum/emote/slime/face
	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

	var/_mood

/datum/emote/slime/face/do_emote(mob/living/carbon/slime/user, emote_key, intentional)
	user.mood = _mood
	user.regenerate_icons()

/datum/emote/slime/face/noface
	key = "noface"
	_mood = null

/datum/emote/slime/face/smile
	key = "smile"
	_mood = "mischevous"

/datum/emote/slime/face/colon_three
	key = ":3"
	_mood = ":33"

/datum/emote/slime/face/pout
	key = "pout"
	_mood = "pout"

/datum/emote/slime/face/frown
	key = "frown"
	_mood = "sad"

/datum/emote/slime/face/scowl
	key = "scowl"
	_mood = "angry"
