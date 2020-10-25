/**
 * tgui state: deep_inventory_state
 *
 * Checks that the src_object is in the user's deep
 * (backpack, box, toolbox, etc) inventory.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

var/global/datum/tgui_state/deep_inventory_state/deep_inventory_state = new

/datum/tgui_state/deep_inventory_state/can_use_topic(src_object, mob/user)
	if(!user.contains(src_object))
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
