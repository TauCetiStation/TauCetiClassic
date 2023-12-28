/datum/action/zoom
	name = "Toggle Zoom"
	action_type = AB_INNATE
	check_flags = AB_CHECK_INCAPACITATED | AB_CHECK_INSIDE | AB_CHECK_ACTIVE
	button_icon_state = "zoom"

/datum/action/zoom/Activate()
	SEND_SIGNAL(target, COMSIG_ZOOM_TOGGLE, owner)

/datum/component/zoom
	var/zoom_view_range
	var/can_move
	var/mob/zoomer
	var/datum/action/zoom/button

/datum/component/zoom/Initialize(_zoom_view_range, _can_move = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	zoom_view_range = _zoom_view_range
	can_move = _can_move
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED), PROC_REF(on_equip))
	RegisterSignal(parent, list(COMSIG_ITEM_DROPPED), PROC_REF(on_drop))
	RegisterSignal(parent, list(COMSIG_ZOOM_TOGGLE), PROC_REF(toggle_zoom))
	RegisterSignal(parent, list(COMSIG_ITEM_BECOME_INACTIVE, COMSIG_PARENT_QDELETING), PROC_REF(reset_zoom))
	button = new(parent)

/datum/component/zoom/Destroy()
	QDEL_NULL(button)
	return ..()

/datum/component/zoom/proc/on_equip(_, mob/living/user)
	SIGNAL_HANDLER
	reset_zoom()
	button.Grant(user)

/datum/component/zoom/proc/on_drop(_, mob/living/user)
	SIGNAL_HANDLER
	reset_zoom()
	button.Remove(user)

/datum/component/zoom/proc/can_zoom(mob/user)
	if(!zoomer && user.get_active_hand() != parent)
		to_chat(user, "You are too distracted to look down the scope, perhaps if it was in your active hand this might work better")
		return FALSE
	if(!user.IsAdvancedToolUser() || user.incapacitated())
		to_chat(user, "You are unable to focus down the scope of the rifle.")
		return FALSE
	return TRUE

/datum/component/zoom/proc/toggle_zoom(_, mob/user)
	SIGNAL_HANDLER
	if(!can_zoom(user))
		return
	if(!zoomer)
		set_zoom(user)
	else
		reset_zoom()
	to_chat(user, "<font color='[zoomer ? "notice" : "rose"]'>Zoom mode [zoomer ? "en" : "dis"]abled.</font>")

/datum/component/zoom/proc/reset_zoom()
	SIGNAL_HANDLER
	if(!zoomer)
		return
	UnregisterSignal(zoomer, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING))
	if(!can_move)
		UnregisterSignal(zoomer, list(COMSIG_MOVABLE_MOVED))
	zoomer.client?.change_view(world.view)
	zoomer.hud_used?.show_hud(HUD_STYLE_STANDARD)
	zoomer = null

/datum/component/zoom/proc/set_zoom(mob/user)
	SIGNAL_HANDLER
	zoomer = user
	zoomer.hud_used?.show_hud(HUD_STYLE_REDUCED)
	zoomer.client?.change_view(zoom_view_range)
	RegisterSignal(zoomer, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING), PROC_REF(reset_zoom))
	if(!can_move)
		RegisterSignal(zoomer, list(COMSIG_MOVABLE_MOVED), PROC_REF(reset_zoom))
