#define SCREEN_DAMAGE_LAYER FULLSCREEN_LAYER + 0.1
#define SCREEN_BLIND_LAYER SCREEN_DAMAGE_LAYER + 0.1
#define SCREEN_CRIT_LAYER SCREEN_BLIND_LAYER + 0.1

/mob
	var/list/screens = list()

/mob/proc/overlay_fullscreen(category, type, severity)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if (!screen || screen.type != type)
		// needs to be recreated
		clear_fullscreen(category, FALSE)
		screens[category] = screen = new type()
	else if ((!severity || severity == screen.severity) && (!client || screen.screen_loc != "CENTER-7,CENTER-7" || screen.view == client.view))
		// doesn't need to be updated
		return screen

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity
	screen.invisibility = initial(screen.invisibility)

	if(client)
		screen.update_for_view(client.view)
		client.screen += screen
		screen.add_screen_part(client)
		screen.screen_part?.update_for_view(client.view)
	return screen

/mob/proc/clear_fullscreen(category, animated = 10)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if(!screen)
		return
	screens -= category
	if(animated)
		animate(screen, alpha = 0, time = animated)
		addtimer(CALLBACK(src, PROC_REF(clear_fullscreen_after_animate), screen), animated, TIMER_CLIENT_TIME)
	else
		if(client)
			client.screen -= screen
			screen.remove_screen_part(client)
		qdel(screen)

/mob/proc/clear_fullscreen_after_animate(atom/movable/screen/fullscreen/screen)
	if(client)
		client.screen -= screen
		screen.remove_screen_part(client)
	qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/mob/proc/reload_fullscreen()
	if(!client)
		return
	var/atom/movable/screen/fullscreen/screen
	for(var/category in screens)
		screen = screens[category]
		screen.update_for_view(client.view)
		client.screen |= screen
		screen.add_screen_part(client, TRUE)
		screen.screen_part?.update_for_view(client.view)


/atom/movable/screen/fullscreen
	icon = 'icons/hud/screen1_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/view = 7
	var/severity = 0
	var/atom/movable/screen/fullscreen/screen_part

/atom/movable/screen/fullscreen/Destroy()
	QDEL_NULL(screen_part)
	severity = 0
	return ..()

/atom/movable/screen/fullscreen/proc/update_for_view(client_view)
	if (screen_loc == "CENTER-7,CENTER-7" && view != client_view)
		var/list/actualview = getviewsize(client_view)
		view = client_view
		transform = matrix(actualview[1]/FULLSCREEN_OVERLAY_RESOLUTION_X, 0, 0, 0, actualview[2]/FULLSCREEN_OVERLAY_RESOLUTION_Y, 0)

/atom/movable/screen/fullscreen/proc/add_screen_part(client/C, reload)
	return

/atom/movable/screen/fullscreen/proc/remove_screen_part(client/C)
	return

/atom/movable/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = SCREEN_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = SCREEN_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/crit
	icon_state = "passage"
	layer = SCREEN_CRIT_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = SCREEN_BLIND_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON

/atom/movable/screen/fullscreen/blind/add_screen_part(client/C, reload)
	if(!screen_part)
		screen_part = new /atom/movable/screen/fullscreen/blind/ring
	if(!reload)
		C.screen += screen_part
	else
		C.screen |= screen_part

/atom/movable/screen/fullscreen/blind/remove_screen_part(client/C)
	C.screen -= screen_part

/atom/movable/screen/fullscreen/blind/ring
	icon_state = "blackimageoverlay_ring"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/fullscreen/blind/Click(location, control, params)
	if(usr.client.void)
		usr.client.void.Click(location, control, params)

/atom/movable/screen/fullscreen/impaired
	icon_state = "impairedoverlay"

/atom/movable/screen/fullscreen/blurry
	icon = 'icons/hud/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blurry"

/atom/movable/screen/fullscreen/flash
	icon = 'icons/hud/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"

/atom/movable/screen/fullscreen/flash/noise
	icon = 'icons/hud/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/atom/movable/screen/fullscreen/high
	icon = 'icons/hud/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"


/atom/movable/screen/fullscreen/darkness
	icon = 'icons/hud/screen1_full.dmi'
	screen_loc = "CENTER-7,CENTER-7"
	icon_state = "white"
	color = "#000000"
	plane = LIGHTING_PLANE
	blend_mode = BLEND_ADD
	appearance_flags = RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR

/atom/movable/screen/fullscreen/environment_lighting_color
	icon = 'icons/hud/screen1_full.dmi'
	screen_loc = "CENTER-7,CENTER-7"
	icon_state = "white"
	plane = ENVIRONMENT_LIGHTING_PLANE
	blend_mode = BLEND_MULTIPLY
	appearance_flags = RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR

	var/obj/effect/level_color_holder/current_holder

// changes z-level color masks when moving between levels
/atom/movable/screen/fullscreen/environment_lighting_color/proc/attach_to_level(new_z)
	SIGNAL_HANDLER

	if(!SSmapping.initialized)
		return

	var/datum/space_level/L = SSmapping.get_level(new_z)
	var/obj/effect/level_color_holder/new_holder = L.color_holder

	if(!current_holder)
		end_transition(new_holder)
		return

	if(current_holder == new_holder)
		return

	var/obj/effect/level_color_holder/old_holder = current_holder
	vis_contents.Cut()
	current_holder = null

	// same color - we don't need animation
	if(old_holder.color == new_holder.color)
		end_transition(new_holder)
		return

	// should be possible to do it with just animation and without callback, but it's already too complicated
	// ...
	// also this looks bad when there is already animation on the holder (aurora), 
	// maybe i should just remove it completely or do some opacity transaction between two holders
	animate(src, time = 0, color = old_holder.color)
	animate(time = 1 SECONDS, color = new_holder.color)
	addtimer(CALLBACK(src, PROC_REF(end_transition), new_holder), 1 SECONDS)

/atom/movable/screen/fullscreen/environment_lighting_color/proc/end_transition(obj/effect/level_color_holder/new_holder)
	if(!current_holder)
		color = null
		vis_contents += new_holder
		current_holder = new_holder

#undef FULLSCREEN_LAYER
#undef SCREEN_BLIND_LAYER
#undef SCREEN_DAMAGE_LAYER
#undef SCREEN_CRIT_LAYER
