// Port from /tg/
// element to make turf transparent

/datum/element/turf_transparency
	element_flags = ELEMENT_DETACH

///This proc sets up the signals to handle updating viscontents when turfs above/below update. Handle plane and layer here too so that they don't cover other obs/turfs in Dream Maker
/datum/element/turf_z_transparency/Attach(datum/target, show_bottom_level = TRUE)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	
	var/turf/our_turf = target

	if(!show_bottom_level(our_turf)) // If we can't show what's below, fallback to plating
		our_turf.ChangeTurf(/turf/simulated/floor/plating)
		return FALSE

///Called when there is no real turf below this turf
// We have no multi-z now, so we will make it every time ~ Pervert
/datum/element/turf_z_transparency/proc/show_bottom_level(turf/our_turf)
	var/turf/path = /turf/space
	var/mutable_appearance/underlay_appearance = mutable_appearance(initial(path.icon), initial(path.icon_state), layer = TURF_LAYER-0.02, plane = PLANE_SPACE)
	underlay_appearance.appearance_flags = RESET_ALPHA | RESET_COLOR
	our_turf.underlays += underlay_appearance
	return TRUE
