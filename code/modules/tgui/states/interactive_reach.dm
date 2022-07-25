/**
 * tgui state: interactive_reach
 *
 * Checks that the src_object is in some way interactable by user.
 * Be it being in hands, or being in TK range.
 *
 */

var/global/datum/tgui_state/interactive_reach_state/interactive_reach_state = new

/datum/tgui_state/interactive_reach_state/can_use_topic(src_object, mob/user)
	. = user.shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		return min(., user.interactive_reach_can_use_topic(src_object))

/mob/proc/interactive_reach_can_use_topic(src_object)
	return UI_CLOSE

/mob/living/interactive_reach_can_use_topic(src_object)
	if(can_tk(level=TK_LEVEL_TWO))
		return UI_INTERACTIVE

	return hands_can_use_topic(src_object)

/mob/living/silicon/robot/interactive_reach_can_use_topic(src_object)
	if(activated(src_object))
		return UI_INTERACTIVE
	return UI_CLOSE
