/mob/living/carbon/brain
	default_emotes = list(
		/datum/emote/list,
		/datum/emote/pray,
		/datum/emote/robot/beep,
		/datum/emote/robot/ping,
		/datum/emote/robot/buzz,
	)

/mob/living/carbon/brain/emote(act, intentional = FALSE)
	// No MMI, no emotes
	if(!container || !isMMI(container))
		to_chat(src, "<span class='notice'>You can not emote in such state.</span>")
		return

	return ..()
