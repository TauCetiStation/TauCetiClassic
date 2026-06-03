/**
 * tgui state: standing_state
 *
 * Checks that the user isn't incapacitated and is standing upright
 */

var/global/datum/tgui_state/not_incapacitated_state/standing/standing_state = new

/datum/tgui_state/not_incapacitated_state/standing

/datum/tgui_state/not_incapacitated_state/standing/can_use_topic(src_object, mob/user)
	if (!isliving(user))
		return ..()
	var/mob/living/living_user = user
	if (living_user.crawling)
		return UI_DISABLED
	return ..()
