/**
 * Render relay object assigned to a plane master to be able to relay it's render onto other planes that are not it's own
 */

INITIALIZE_IMMEDIATE(/atom/movable/screen/render_plane_relay)
/atom/movable/screen/render_plane_relay
	screen_loc = "CENTER"
	layer = -1
	plane = 0
	appearance_flags = PASS_MOUSE | NO_CLIENT_COLOR | KEEP_TOGETHER

/atom/movable/screen/render_plane_relay/atom_init(mapload, atom/movable/screen/plane_master/source_plane, render_plane)
	. = ..()

	name = source_plane.render_target

	render_source = source_plane.render_target

	assigned_map = source_plane.assigned_map // for cleaning external maps
	screen_loc = source_plane.screen_loc

	plane = render_plane
	layer = (source_plane.plane + abs(LOWEST_EVER_PLANE)) * 0.5 //layer must be positive but can be a decimal
	blend_mode = source_plane.blend_mode

	source_plane.blend_mode = BLEND_DEFAULT

	mouse_opacity = source_plane.mouse_opacity

