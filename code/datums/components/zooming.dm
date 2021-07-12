/datum/component/zooming
	var/zoom_range = 12
	var/can_move = FALSE

	var/zoom = FALSE
	var/mob/zoomer

/datum/component/zooming/Initialize(zoom_range = src.zoom_range, can_move = src.can_move)
	src.zoom_range = zoom_range
	src.can_move = can_move

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/toggle_zoom)

/datum/component/zooming/proc/toggle_zoom(datum/source, mob/user)
	if(user.incapacitated() || !ishuman(user))
		to_chat(user, "You are unable to focus down the scope of \the [parent].")
		return

	if(!zoom && user.get_active_hand() != parent)
		to_chat(user, "You are too distracted to look down the scope, perhaps if it was in your active hand this might work better")
		return

	if(user.client.view == world.view)
		set_zoom(user)
	else
		reset_zoom()
	to_chat(user, "<span class='[zoom ? "notice" : "rose"]'>Zoom mode [zoom ? "en" : "dis"]abled.</span>")
	return COMPONENT_NO_INTERACT

/datum/component/zooming/proc/set_zoom(mob/user)
	zoomer = user
	zoomer.hud_used?.show_hud(HUD_STYLE_REDUCED)
	zoomer.client.change_view(zoom_range)
	zoom = TRUE
	if(!can_move)
		RegisterSignal(zoomer, list(COMSIG_MOVABLE_MOVED), .proc/reset_zoom)
	RegisterSignal(zoomer, list(COMSIG_MOB_DIED, COMSIG_MOB_SWAP_HANDS, COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), .proc/reset_zoom)
	RegisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), .proc/reset_zoom)

/datum/component/zooming/proc/reset_zoom()
	zoomer.client?.change_view(world.view)
	zoomer.hud_used?.show_hud(HUD_STYLE_STANDARD)
	zoom = FALSE
	if(!can_move)
		UnregisterSignal(zoomer, list(COMSIG_MOVABLE_MOVED), .proc/reset_zoom)
	UnregisterSignal(zoomer, list(COMSIG_MOB_DIED, COMSIG_MOB_SWAP_HANDS, COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), .proc/reset_zoom)
	UnregisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), .proc/reset_zoom)
	zoomer = null
