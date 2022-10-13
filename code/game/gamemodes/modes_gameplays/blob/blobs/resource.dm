/obj/effect/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	max_integrity = 30
	fire_resist = 2
	var/mob/camera/blob/overmind = null
	var/resource_delay = 0

/obj/effect/blob/resource/run_action()
	if(QDELETED(overmind))
		overmind = null
		return
	if(resource_delay > world.time)
		return

	resource_delay = world.time + 40 // 4 seconds
	PulseAnimation()

	overmind.add_points(1)

