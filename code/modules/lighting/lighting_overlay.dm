/atom/movable/lighting_overlay
	name             = ""

	icon             = 'icons/effects/icon.dmi'
	color            = LIGHTING_BASE_MATRIX

	mouse_opacity    = 0
	layer            = LIGHTING_LAYER
	plane            = LIGHTING_PLANE
	invisibility     = INVISIBILITY_LIGHTING

	simulated = 0
	anchored = 1
	flags = NOREACT

	var/needs_update = FALSE

/atom/movable/lighting_overlay/atom_init(mapload, no_update = FALSE)
	. = ..()
	verbs.Cut()

	var/turf/T         = loc // If this runtimes atleast we'll know what's creating overlays in things that aren't turfs.
	T.lighting_overlay = src
	T.luminosity       = FALSE

	for(var/turf/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
		S.update_starlight()

	if(no_update)
		return

	update_overlay()

/atom/movable/lighting_overlay/Destroy()
	var/turf/T = loc
	if(istype(T))
		T.lighting_overlay = null
		T.luminosity = TRUE

	SSlighting.changed_overlays -= src;

	return ..()

/atom/movable/lighting_overlay/proc/update_overlay()
	var/turf/T = loc
	if(!istype(T)) // Erm...
		if(loc)
			warning("A lighting overlay realised its loc was NOT a turf (actual loc: [loc], [loc.type]) in update_overlay() and got pooled!")

		else
			warning("A lighting overlay realised it was in nullspace in update_overlay() and got pooled!")

		qdel(src)

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	// See LIGHTING_CORNER_DIAGONAL in lighting_corner.dm for why these values are what they are.
	// No I seriously cannot think of a more efficient method, fuck off Comic.
	var/datum/lighting_corner/cr = T.corners[3]
	var/datum/lighting_corner/cg = T.corners[2]
	var/datum/lighting_corner/cb = T.corners[4]
	var/datum/lighting_corner/ca = T.corners[1]

	var/max = max(cr.cache_mx, cg.cache_mx, cb.cache_mx, ca.cache_mx)

	color  = list(
		cr.cache_r, cr.cache_g, cr.cache_b, 0,
		cg.cache_r, cg.cache_g, cg.cache_b, 0,
		cb.cache_r, cb.cache_g, cb.cache_b, 0,
		ca.cache_r, ca.cache_g, ca.cache_b, 0,
		0, 0, 0, 1
	)
	luminosity = max > LIGHTING_SOFT_THRESHOLD

/atom/movable/lighting_overlay/singularity_act()
	return
