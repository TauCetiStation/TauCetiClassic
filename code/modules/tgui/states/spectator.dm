/**
 * tgui state: spectator_state
 *
 * Checks that the user is an observer/ghost or is in the lobby.
 */

var/global/datum/tgui_state/spectator_state/spectator_state = new

/datum/tgui_state/spectator_state/can_use_topic(src_object, mob/user)
	if(isobserver(user) || isnewplayer(user))
		return UI_INTERACTIVE
	return UI_CLOSE
