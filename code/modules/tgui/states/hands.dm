/**
 * tgui state: hands_state
 *
 * Checks that the src_object is in the user's hands.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

var/global/datum/tgui_state/hands_state/hands_state = new

/datum/tgui_state/hands_state/can_use_topic(src_object, mob/user)
	. = user.shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		return min(., user.hands_can_use_topic(src_object))

/mob/proc/hands_can_use_topic(src_object)
	return UI_CLOSE

/mob/living/hands_can_use_topic(src_object)
	if(get_active_hand() == src_object || get_inactive_hand() == src_object)
		return UI_INTERACTIVE
	return UI_CLOSE

/mob/living/silicon/robot/hands_can_use_topic(src_object)
	if(activated(src_object))
		return UI_INTERACTIVE
	return UI_CLOSE
