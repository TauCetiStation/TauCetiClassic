 /**
  * tgui state: mentor_state
  *
  * Checks that the user is an mentor.
 **/

var/global/datum/tgui_state/mentor_state/mentor_state = new

/datum/tgui_state/mentor_state/can_use_topic(src_object, mob/user)
	if(has_mentor_powers(user.client))
		return UI_INTERACTIVE
	return UI_CLOSE
