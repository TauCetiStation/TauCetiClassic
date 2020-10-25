/**
 * tgui state: observer_state
 *
 * Checks that the user is an observer/ghost.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

var/global/datum/tgui_state/observer_state/observer_state = new

/datum/tgui_state/observer_state/can_use_topic(src_object, mob/user)
	if(isobserver(user))
		return UI_INTERACTIVE
	return UI_CLOSE

