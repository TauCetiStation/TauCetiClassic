//костыль, в будущем что-то сделать с этим
/obj/structure/object_wall
	name = "shuttle wall"
	desc = "A huge chunk of metal and electronics used to construct shuttle."
	density = 1
	anchored = 1
	opacity = 1
	icon = 'code/modules/locations/shuttles/shuttle.dmi'

/obj/structure/object_wall/atom_init()
	. = ..()
	update_nearby_tiles(need_rebuild = 1)

/obj/structure/object_wall/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group)
		return 0
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/object_wall/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/object_wall/mining
	icon = 'code/modules/locations/shuttles/shuttle_mining.dmi'

/obj/structure/object_wall/standart
	icon = 'code/modules/locations/shuttles/shuttle.dmi'

/obj/structure/object_wall/pod
	icon = 'code/modules/locations/shuttles/pod.dmi'

/obj/structure/object_wall/wagon
	icon = 'code/modules/locations/shuttles/wagon.dmi'
	icon_state = "3,1"

/obj/structure/object_wall/erokez
	icon = 'code/modules/locations/shuttles/erokez.dmi'
	icon_state = "18,2"

/obj/structure/object_wall/cargo
	icon = 'code/modules/locations/shuttles/cargo.dmi'
	icon_state = "0,5"
