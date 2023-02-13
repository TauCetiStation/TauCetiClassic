/obj/structure/window/reinforced/shuttle
	icon = 'icons/locations/shuttles/shuttle.dmi'
	dir = SOUTHWEST
	can_merge = 0
	flags = NODECONSTRUCT | ON_BORDER

/obj/structure/window/reinforced/shuttle/mining
	name = "shuttle window"
	icon = 'icons/locations/shuttles/shuttle_mining.dmi'
	dir = SOUTHWEST
	icon_state = "1"

/obj/structure/window/reinforced/shuttle/evac
	name = "shuttle window"
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	dir = SOUTHWEST

/obj/structure/window/reinforced/shuttle/default
	name = "shuttle window"
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"
	dir = SOUTHWEST

/obj/structure/window/reinforced/shuttle/vox
	name = "shuttle window"
	icon = 'icons/locations/shuttles/vox_shuttle_inner.dmi'
	icon_state = "7,10"
	dir = SOUTHWEST

/obj/structure/window/reinforced/shuttle/update_icon()
	return

/obj/structure/shuttle/window/new_shuttle
	icon = 'icons/locations/shuttles/shuttle.dmi'
