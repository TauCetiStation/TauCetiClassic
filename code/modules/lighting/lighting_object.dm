/atom/movable/lighting_object
	name          = ""

	anchored      = TRUE

	icon             = 'icons/effects/lighting_object.dmi'
	icon_state       = "transparent"
	color            = LIGHTING_BASE_MATRIX
	plane            = LIGHTING_PLANE
	mouse_opacity    = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = parent_type::appearance_flags | NO_CLIENT_COLOR

	simulated = FALSE
	flags = NOREACT
	flags_2 = PROHIBIT_FOR_DEMO_2 // can corrupt the demo

	var/needs_update = FALSE
	var/turf/myturf

/atom/movable/lighting_object/atom_init(mapload)
	. = ..()
	verbs.Cut()

	myturf = loc
	if (myturf.lighting_object)
		qdel(myturf.lighting_object, force = TRUE)
	myturf.lighting_object = src

	// just in case if something spawns us before initialization
	// any lighting source will add us to the queue anyway
	// saves us init time on objects that don't have any lighting sources around
	if(!SSlighting.initialized)
		icon_state = "dark"
		color = null
		return .

	needs_update = TRUE
	SSlighting.objects_queue += src

/atom/movable/lighting_object/Destroy(force)
	if (force)
		SSlighting.objects_queue -= src
		if (loc != myturf)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			stack_trace("A lighting object was qdeleted with a different loc then it is suppose to have ([COORD(oldturf)] -> [COORD(newturf)])")
		if (isturf(myturf))
			myturf.lighting_object = null
			myturf.luminosity = 1
		myturf = null

		return ..()

	else
		return QDEL_HINT_LETMELIVE

/atom/movable/lighting_object/proc/update()
	if (loc != myturf)
		if (loc)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			warning("A lighting object realised it's loc had changed in update() ([myturf]\[[myturf ? myturf.type : "null"]][COORD(oldturf)] -> [loc]\[[ loc ? loc.type : "null"]][COORD(newturf)])!")

		qdel(src, TRUE)
		return

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	// See lighting_corner.dm for why these values are what they are.
	var/datum/lighting_corner/corner_red = myturf.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/corner_green = myturf.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/corner_blue = myturf.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/corner_alpha = myturf.lighting_corner_NE || dummy_lighting_corner

	var/max = max(corner_red.cache_mx, corner_green.cache_mx, corner_blue.cache_mx, corner_alpha.cache_mx)

	var/rr = corner_red.cache_r
	var/rg = corner_red.cache_g
	var/rb = corner_red.cache_b

	var/gr = corner_green.cache_r
	var/gg = corner_green.cache_g
	var/gb = corner_green.cache_b

	var/br = corner_blue.cache_r
	var/bg = corner_blue.cache_g
	var/bb = corner_blue.cache_b

	var/ar = corner_alpha.cache_r
	var/ag = corner_alpha.cache_g
	var/ab = corner_alpha.cache_b

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	if((rr & gr & br & ar) && (rg + gg + bg + ag + rb + gb + bb + ab == 8))
	//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		icon_state = "transparent"
		color = null
	else if(!set_luminosity)
		icon_state = "dark"
		color = null
	else
		icon_state = "corners" // here we use prepared mask with r/g/b/a channels for each corner
		color = list(
			rr, rg, rb, 00,
			gr, gg, gb, 00,
			br, bg, bb, 00,
			ar, ag, ab, 00,
			00, 00, 00, 01
		)

	luminosity = set_luminosity

	SEND_SIGNAL(src, COMSIG_LIGHT_UPDATE_OBJECT, myturf)

// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_object/ex_act(severity)
	return 0

/atom/movable/lighting_object/singularity_act()
	return

/atom/movable/lighting_object/singularity_pull()
	return

/atom/movable/lighting_object/blob_act()
	return

// Override here to prevent things accidentally moving around overlays.
/atom/movable/lighting_object/Move()
	return

/atom/movable/lighting_object/forceMove(atom/destination, keep_pulling)
	return

/atom/movable/lighting_object/shake_act(severity, recursive = TRUE)
	return
