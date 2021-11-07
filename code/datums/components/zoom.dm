/datum/component/zoom
	var/zoom_view_range
	var/verbose
	var/zoomed = FALSE

/datum/component/zoom/Initialize(_zoom_view_range, list/toggle_zoom_on, list/unzoom_on, _verbose = TRUE)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	
	zoom_view_range = _zoom_view_range
	verbose = _verbose

	RegisterSignal(parent, toggle_zoom_on, .proc/toggle_signal)
	RegisterSignal(parent, list(COMSIG_ZOOM_TOGGLE), .proc/toggle_signal)
	RegisterSignal(parent, unzoom_on, .proc/unzoom_signal)

/datum/component/zoom/proc/toggle_signal(_, mob/user)
	SIGNAL_HANDLER
	toggle_zoom(user)

/datum/component/zoom/proc/unzoom_signal(_, mob/user)
	SIGNAL_HANDLER
	disable_zoom(user)

/datum/component/zoom/proc/can_zoom(mob/user)
	if(user.get_active_hand() != parent)
		if(verbose)
			to_chat(user, "You are too distracted to look down the scope, perhaps if it was in your active hand this might work better")
		return FALSE
	if(!ishuman(user) || user.incapacitated())
		if(verbose)
			to_chat(user, "You are unable to focus down the scope of the rifle.")
		return FALSE
	return TRUE

/datum/component/zoom/proc/toggle_zoom(mob/user)
	if(zoomed)
		disable_zoom(user)
	else
		enable_zoom(user)
	if(verbose)
		to_chat(user, "<font color='[zoomed ? "blue" : "red"]'>Zoom mode [zoomed ? "en" : "dis"]abled.</font>")
	
/datum/component/zoom/proc/disable_zoom(mob/user)
	zoomed = FALSE
	if(usr.hud_used)
		usr.hud_used.show_hud(HUD_STYLE_STANDARD)
	usr.client.change_view(world.view)

/datum/component/zoom/proc/enable_zoom(mob/user)
	if(!can_zoom(user))
		return
	zoomed = TRUE
	if(user.hud_used)
		user.hud_used.show_hud(HUD_STYLE_REDUCED)
	user.client.change_view(zoom_view_range)
