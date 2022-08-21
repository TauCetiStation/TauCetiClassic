/**
 * tgui state: not_incapacitated_state
 *
 * Checks that the user isn't incapacitated
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

var/global/datum/tgui_state/not_incapacitated_state/not_incapacitated_state = new

/**
 * tgui state: not_incapacitated_turf_state
 *
 * Checks that the user isn't incapacitated and that their loc is a turf
 */

var/global/datum/tgui_state/not_incapacitated_state/not_incapacitated_turf_state = new(no_turfs = TRUE)

/datum/tgui_state/not_incapacitated_state
	var/turf_check = FALSE

/datum/tgui_state/not_incapacitated_state/New(loc, no_turfs = FALSE)
	..()
	turf_check = no_turfs

/datum/tgui_state/not_incapacitated_state/can_use_topic(src_object, mob/user)
	if(user.stat != CONSCIOUS)
		return UI_CLOSE
	if(user.incapacitated() || (turf_check && !isturf(user.loc)))
		return UI_DISABLED
	return UI_INTERACTIVE
