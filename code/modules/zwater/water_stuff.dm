var/global/list/water_images = list() // Shared overlays for all water turfs (to sync animation)

/obj/effect/decal/cleanable/water/proc/get_water_icon(img_state)
	if(!water_images[img_state])
		water_images[img_state] = image('icons/effects/effects.dmi',img_state)
	return water_images[img_state]
