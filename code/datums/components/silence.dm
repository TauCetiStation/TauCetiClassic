// A component you put on things you want to generate silence of sound suppresion around things.
/datum/component/silence
	var/obj/effect/overlay/radius_obj
	var/coeff = 0.0
	var/vis_radius
	var/list/old_locs = list()
	var/enabled = FALSE

/datum/component/silence/Initialize(_dist, _coeff)
	var/atom/movable/AM = parent
	if (isnull(AM.loc))
		return COMPONENT_NOT_ATTACHED
	var/bound_size = world.icon_size + world.icon_size * 2 * _dist
	var/bound_disp = world.icon_size * -1 * _dist
	coeff = _coeff

	radius_obj = new(get_turf(AM))
	radius_obj.appearance_flags &= ~TILE_BOUND
	radius_obj.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	radius_obj.bound_x = bound_disp
	radius_obj.bound_y = bound_disp
	radius_obj.bound_width = bound_size
	radius_obj.bound_height = bound_size
	radius_obj.AddComponent(/datum/component/bounded, AM, 0, 0, null, FALSE, FALSE)
	AM.AddComponent(/datum/component/vis_radius, _dist, "radius", COLOR_BLACK)

	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_LOC_MOVED), .proc/update_sound_suppression)
	RegisterSignal(parent, COMSIG_START_SUPPRESSING, .proc/enable_suppresion)
	RegisterSignal(parent, COMSIG_STOP_SUPPRESSING, .proc/disable_suppression)

/datum/component/silence/Destroy()
	. = ..()
	if (isnull(parent))
		return
	disable_suppression()
	qdel(radius_obj.GetComponent(/datum/component/vis_radius))
	QDEL_NULL(radius_obj)

/datum/component/silence/proc/enable_suppresion()
	SIGNAL_HANDLER
	if (!enabled)
		enabled = TRUE
		update_sound_suppression()

/datum/component/silence/proc/disable_suppression()
	SIGNAL_HANDLER
	if (enabled)
		enabled = FALSE
		for (var/turf/T in old_locs)
			T.sound_coefficient += coeff
		old_locs = list()

/datum/component/silence/proc/update_sound_suppression()
	SIGNAL_HANDLER
	if (!enabled)
		return
	var/list/entered_locs = radius_obj.locs - old_locs
	var/list/left_locs = old_locs - radius_obj.locs

	for (var/turf/T in left_locs)
		T.sound_coefficient += coeff

	for (var/turf/T in entered_locs)
		T.sound_coefficient -= coeff

	old_locs = radius_obj.locs
