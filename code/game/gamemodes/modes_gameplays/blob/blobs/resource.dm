/obj/structure/blob/resource
	name = "resource blob"
	cases = list("ресурсная ячейка", "ресурсной ячейки", "ресурсной ячейке", "ресурсную ячейку", "ресурсной ячейкой", "ресурсной ячейке")
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	max_integrity = 30
	fire_resist = 2
	var/resource_delay = 0

/obj/structure/blob/resource/run_action()
	if(QDELETED(OV))
		OV = null
		return
	if(resource_delay > world.time)
		return

	resource_delay = world.time + 40 // 4 seconds
	PulseAnimation()

	OV.add_points(1)

