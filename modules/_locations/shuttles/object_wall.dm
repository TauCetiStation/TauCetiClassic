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

	Del()
		update_nearby_tiles()
		..()

	proc/update_nearby_tiles(need_rebuild) //Copypasta from airlock code
		if(!air_master)
			return 0
		air_master.AddTurfToUpdate(get_turf(src))
		return 1

/obj/structure/object_wall/mining
	icon = 'tauceti/modules/_locations/shuttles/shuttle_mining.dmi'

/obj/structure/object_wall/standart
	icon = 'tauceti/modules/_locations/shuttles/shuttle.dmi'