/**
 * tgui state: always_state
 *
 * Always grants the user UI_INTERACTIVE. Period.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

var/global/datum/tgui_state/always_state/always_state = new

/datum/tgui_state/always_state/can_use_topic(src_object, mob/user)
	return UI_INTERACTIVE
