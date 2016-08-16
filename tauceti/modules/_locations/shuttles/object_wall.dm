//костыль, в будущем что-то сделать с этим
/obj/structure/object_wall
	name = "shuttle wall"
	desc = "A huge chunk of metal and electronics used to construct shuttle."
	density = 1
	anchored = 1
	opacity = 1
	icon = 'tauceti/modules/_locations/shuttles/shuttle.dmi'

	New(location)
		..()
		update_nearby_tiles(need_rebuild=1)

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group) return 0
		if(istype(mover, /obj/effect/beam))
			return !opacity
		return !density

	Destroy()
		update_nearby_tiles()
		..()

	proc/update_nearby_tiles(need_rebuild) //Copypasta from airlock code
		if(!SSair)
			return 0
		//air_master.AddTurfToUpdate(get_turf(src))
		SSair.mark_for_update(get_turf(src))
		return 1

/obj/structure/object_wall/mining
	icon = 'tauceti/modules/_locations/shuttles/shuttle_mining.dmi'

/obj/structure/object_wall/standart
	icon = 'tauceti/modules/_locations/shuttles/shuttle.dmi'

/obj/structure/object_wall/pod
	icon = 'tauceti/modules/_locations/shuttles/pod.dmi'

/obj/structure/object_wall/wagon
	icon = 'tauceti/modules/_locations/shuttles/wagon.dmi'
	icon_state = "3,1"

/obj/structure/object_wall/erokez
	icon = 'tauceti/modules/_locations/shuttles/erokez.dmi'
	icon_state = "18,2"