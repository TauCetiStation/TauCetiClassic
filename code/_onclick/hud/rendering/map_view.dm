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
	for(var/atom/movable/screen/AM in client.screen)
		if(assigned_map == AM.assigned_map)
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
