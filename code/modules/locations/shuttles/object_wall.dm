//костыль, в будущем что-то сделать с этим
/obj/structure/object_wall
	layer = 2
	name = "shuttle wall"
	desc = "Огромный кусок металла и электроники, использованный для постройки шаттла."
	density = TRUE
	anchored = TRUE
	can_block_air = TRUE
	opacity = 1
	icon = 'icons/locations/shuttles/shuttle.dmi'

/obj/structure/object_wall/atom_init()
	. = ..()
	update_nearby_tiles()

/obj/structure/object_wall/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/object_wall/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/object_wall/mining
	icon = 'icons/locations/shuttles/shuttle_mining.dmi'

/obj/structure/object_wall/standart
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall1"

/obj/structure/object_wall/pod
	icon = 'icons/locations/shuttles/pod.dmi'

/obj/structure/object_wall/wagon
	icon = 'icons/locations/shuttles/wagon.dmi'
	icon_state = "3,1"

/obj/structure/object_wall/erokez
	icon = 'icons/locations/shuttles/erokez.dmi'
	icon_state = "18,2"

/obj/structure/object_wall/cargo
	icon = 'icons/locations/shuttles/cargo.dmi'
	icon_state = "0,5"

/obj/structure/object_wall/evac
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	icon_state = "9,1"

/obj/structure/object_wall/vox
	name = "skipjack wall"
	desc = "Стены шаттла, покрытые граффити."
	icon = 'icons/locations/shuttles/vox_shuttle.dmi'
	icon_state = "14,11"

/obj/structure/object_wall/vox/internal
	desc = "Внутренняя стена шаттла. Чище, чем внешние стены, но не намного."
	icon = 'icons/locations/shuttles/vox_shuttle_inner.dmi'
	icon_state = "3,0"
