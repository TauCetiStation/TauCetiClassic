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

	blend_mode       = BLEND_MULTIPLY

	var/needs_update = FALSE

/atom/movable/lighting_overlay/New(var/atom/loc, var/no_update = FALSE)
	. = ..()
	verbs.Cut()

	var/turf/T         = loc // If this runtimes atleast we'll know what's creating overlays in things that aren't turfs.
	T.lighting_overlay = src
	T.luminosity       = FALSE

	if(no_update)
		return

	update_overlay()

/atom/movable/lighting_overlay/Destroy()
	var/turf/T   = loc
	if(istype(T))
		T.lighting_overlay = null
		T.luminosity = TRUE

	SSlighting.changed_overlays -= src;

	return ..()

/atom/movable/lighting_overlay/singularity_act()
	return

/atom/movable/lighting_overlay/proc/update_overlay()
	var/turf/T = loc
	if(!istype(T)) // Erm...
		if(loc)
			warning("A lighting overlay realised its loc was NOT a turf (actual loc: [loc], [loc.type]) in update_overlay() and got pooled!")

		else
			warning("A lighting overlay realised it was in nullspace in update_overlay() and got pooled!")

		qdel(src)

	var/list/L = src.color:Copy() // For some dumb reason BYOND won't allow me to use [] on a colour matrix directly.
	var/anylums = 0

	for(var/A in T.corners)
		if(!A)
			continue

		var/datum/lighting_corner/C = A
		var/i = 0

		// Huge switch to determine i based on D.
		switch(turn(C.masters[T], 180))
			if(NORTHEAST)
				i = AR

			if(SOUTHEAST)
				i = GR

			if(SOUTHWEST)
				i = RR

			if(NORTHWEST)
				i = BR

		var/mx = max(C.lum_r, C.lum_g, C.lum_b) // Scale it so 1 is the strongest lum, if it is above 1.
		anylums += mx
		. = 1 // factor
		if(mx > 1)
			. = 1 / mx

		L[i + 0]   = C.lum_r * .
		L[i + 1]   = C.lum_g * .
		L[i + 2]   = C.lum_b * .

	src.color  = L
	luminosity = (anylums > 0)
