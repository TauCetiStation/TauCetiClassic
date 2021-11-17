/obj/effect/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	health = 30
	fire_resist = 2
	var/mob/camera/blob/overmind = null
	var/resource_delay = 0

/obj/effect/blob/resource/update_icon()
	if(health <= 0)
		qdel(src)
		return
	return

/obj/effect/blob/resource/run_action()
	if(QDELETED(overmind))
		overmind = null
		return
	if(resource_delay > world.time)
		return

	resource_delay = world.time + 40 // 4 seconds
	PulseAnimation()

	if(overmind)
		overmind.add_points(1)

