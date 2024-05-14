/**
 * Holder for external/popup screen maps.
 * Acts as a container for turfs and other things
 * you want to show on the map, which you usually attach to "vis_contents".
 */

/atom/movable/screen/map_view
	name = "screen"
	// Map view has to be on the lowest plane to enable proper lighting
	icon = null
	icon_state = null
	screen_loc = "1,1"
	layer = GAME_PLANE
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	// plane_masters we attach to map
	var/list/atom/movable/screen/attached_planes

	// holder for background
	var/atom/movable/screen/background/background

	// who is using map_view currently
	var/list/datum/weakref/viewers = list()

/atom/movable/screen/map_view/atom_init(mapload, map_view, background_state = "clear", add_planes)
	. = ..()

	// Initialize map objects
	assigned_map = map_view
	screen_loc = "[map_view]:[screen_loc]"

	background = new
	background.assigned_map = map_view
	background.screen_loc = "[map_view]:1,1"
	background.icon_state = background_state

	attached_planes = add_planes

/atom/movable/screen/map_view/Destroy()
	for(var/datum/weakref/client_ref in viewers)
		var/client/our_client = client_ref.resolve()
		if(!our_client)
			continue
		hide_from(our_client)

	qdel(background)
	attached_planes = null

	return ..()

/atom/movable/screen/map_view/proc/update_size(x, y)
	background.screen_loc = "[assigned_map]:1,1 to [x],[y]"

/atom/movable/screen/map_view/proc/set_background(background_state)
	background.icon_state = background_state

/atom/movable/screen/map_view/proc/show_to(client/client)
	client.screen += background
	client.screen += src

	for(var/mytype in attached_planes)
		var/atom/movable/screen/plane_master/PM = new mytype(null, assigned_map)

		PM.update_effects(client)

		client.screen += PM
		client.screen += PM.generate_relays()

/atom/movable/screen/map_view/proc/hide_from(client/client)
	client.screen -= background
	client.screen -= src
	world.log << "hide_from [client]"
	for(var/atom/movable/screen/AM in client.screen)
		if(assigned_map == AM.assigned_map)
			world.log << "hide_from [client] [AM]"
			client.screen -= AM
			qdel(AM)

/**
 * A generic background object.
 * It is also implicitly used to allocate a rectangle on the map, which will
 * be used for auto-scaling the map.
 */
/atom/movable/screen/background
	name = "background"
	icon = 'icons/hud/map_backgrounds.dmi'
	icon_state = "clear"
	layer = 999
	plane = RENDER_PLANE_ABOVE_GAME
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


//// debug
/**
 * Creates a popup window with a basic map element in it, without any
 * further initialization.
 *
 * Ratio is how many pixels by how many pixels (keep it simple).
 *
 * Returns a map name.
 */
/*/client/proc/create_map_popup(name, ratiox = 100, ratioy = 100)
	winclone(src, "popupwindow", name)
	var/list/winparams = list()
	winparams["size"] = "[ratiox]x[ratioy]"
	winparams["on-close"] = "handle-popup-close [name]"
	winset(src, "[name]", list2params(winparams))
	winshow(src, "[name]", 1)

	var/list/params = list()
	params["parent"] = "[name]"
	params["type"] = "map"
	params["size"] = "[ratiox]x[ratioy]"
	params["anchor1"] = "0,0"
	params["anchor2"] = "[ratiox],[ratioy]"
	winset(src, "[name]_map", list2params(params))

	return "[name]_map"

/client/verb/setup_map_popup(popup_name as text, width = 9, height = 9, \
		tilesize = 2, bg_icon)
	if(!popup_name)
		return
	clear_map("[popup_name]_map")
	var/x_value = world.icon_size * tilesize * width
	var/y_value = world.icon_size * tilesize * height
	var/map_name = create_map_popup(popup_name, x_value, y_value)

	var/atom/movable/screen/background/background = new
	background.assigned_map = map_name
	background.fill_rect(1, 1, width, height)
	if(bg_icon)
		background.icon_state = bg_icon
	register_map_obj(background)

	return map_name

/client/proc/close_map_popup(popup)
	winshow(src, popup, 0)
	handle_map_popup_close(popup)

/client/verb/handle_map_popup_close(window_id as text)
	set hidden = TRUE
	clear_map("[window_id]_map")*/
