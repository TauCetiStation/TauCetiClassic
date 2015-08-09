var/global/list/water_images = list() // Shared overlays for all water turfs (to sync animation)
var/global/list/processing_water = list()
var/global/list/processing_drying = list() // Items that we need to dry next processor cycle.

/obj/effect/decal/cleanable/water/proc/get_water_icon(var/img_state)
	if(!water_images[img_state])
		water_images[img_state] = image('icons/effects/effects.dmi',img_state)
	return water_images[img_state]