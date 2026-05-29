/**
 * Point at an atom
 *
 * Intended to enable and standardise the pointing animation for all atoms
 *
 * Not intended as a replacement for the mob verb
 */
/atom/proc/point_at(atom/pointed_atom, arrow_type = /obj/effect/decal/point, params)
	if (!isturf(loc))
		return FALSE

	var/is_inside_src = FALSE
	var/atom/L = pointed_atom.loc
	while(L && !isturf(L))
		if (L == src)
			is_inside_src = TRUE
			break
		L = L.loc

	if (is_inside_src)
		var/atom/movable/AM = src
		AM.create_point_bubble(pointed_atom)
		return TRUE

	var/turf/tile = get_turf(pointed_atom)
	if (!tile)
		return FALSE

	var/turf/our_tile = get_turf(src)
	var/obj/visual = new arrow_type(our_tile, invisibility)
	QDEL_IN(visual, 20)

	var/final_x = (tile.x - our_tile.x) * world.icon_size + pointed_atom.pixel_x
	var/final_y = (tile.y - our_tile.y) * world.icon_size + pointed_atom.pixel_y

	// If click params are available, use exact click position instead of tile center
	var/list/click_params = params2list(params)
	if(length(click_params))
		var/click_x = 16
		var/click_y = 16
		if(click_params["icon-x"])
			click_x = text2num(click_params["icon-x"])
		if(click_params["icon-y"])
			click_y = text2num(click_params["icon-y"])

		final_x = (tile.x - our_tile.x) * world.icon_size + pointed_atom.pixel_x + (click_x - 16)
		final_y = (tile.y - our_tile.y) * world.icon_size + pointed_atom.pixel_y + (click_y - 16)

	// Rotate the arrow to face the target direction
	var/matrix/rotated_matrix = new()

	// When pointing at self, arrow comes from outside toward the click point
	if(pointed_atom == src)
		var/dist = sqrt(final_x * final_x + final_y * final_y)
		if(dist > 0)
			visual.pixel_x = final_x + (final_x / dist) * world.icon_size
			visual.pixel_y = final_y + (final_y / dist) * world.icon_size
		rotated_matrix.TurnTo(0, get_pixel_angle(final_y, final_x))
	else
		rotated_matrix.TurnTo(0, get_pixel_angle(-final_y, -final_x))

	visual.transform = rotated_matrix

	animate(visual, pixel_x = final_x, pixel_y = final_y, time = 1.7, easing = EASE_OUT)

	return TRUE

/atom/movable/proc/create_point_bubble(atom/pointed_atom)
	if(active_point_bubble)
		var/datum/point_bubble/old_pb = active_point_bubble
		deltimer(old_pb.timer_id)
		cut_overlay(old_pb.appearance)
		qdel(old_pb)
		active_point_bubble = null

	var/mutable_appearance/thought_bubble = mutable_appearance('icons/effects/effects.dmi', "thought_bubble", plane = POINT_PLANE)
	thought_bubble.appearance_flags = KEEP_APART

	var/mutable_appearance/pointed_atom_appearance = new(pointed_atom.appearance)
	pointed_atom_appearance.blend_mode = BLEND_INSET_OVERLAY
	pointed_atom_appearance.plane = FLOAT_PLANE
	pointed_atom_appearance.layer = FLOAT_LAYER
	pointed_atom_appearance.pixel_x = 0
	pointed_atom_appearance.pixel_y = 0
	thought_bubble.overlays += pointed_atom_appearance

	var/mutable_appearance/point_visual = mutable_appearance('icons/hud/screen1.dmi', "arrow", plane = POINT_PLANE)
	thought_bubble.overlays += point_visual

	thought_bubble.pixel_x = 16
	thought_bubble.pixel_y = 32
	thought_bubble.alpha = 200
	thought_bubble.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	add_overlay(thought_bubble)

	var/datum/point_bubble/new_pb = new()
	new_pb.appearance = thought_bubble
	new_pb.timer_id = addtimer(CALLBACK(src, PROC_REF(clear_point_bubble), new_pb), 2.5 SECONDS, TIMER_STOPPABLE)
	active_point_bubble = new_pb

/atom/movable/proc/clear_point_bubble(datum/point_bubble/PB)
	if(active_point_bubble == PB)
		active_point_bubble = null
	cut_overlay(PB.appearance)
	qdel(PB)

/datum/point_bubble
	var/mutable_appearance/appearance
	var/timer_id

/datum/point_bubble/Destroy()
	appearance = null
	timer_id = null
	return ..()
