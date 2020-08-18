/obj/structure/stool/bed/chair/schair/wagon
	name = "Shuttle Chair"
	desc = "You sit in this. Either by will or force."
	icon = 'code/modules/locations/shuttles/bench.dmi'
	icon_state = "chair"

/obj/structure/stool/bed/chair/schair/wagon/bench
	name = "Bench"
	desc = "You sit in this. Either by will or force."
	icon = 'code/modules/locations/shuttles/bench.dmi'
	icon_state = "bench_1"

/obj/structure/stool/bed/chair/schair/wagon/bench/atom_init()
	. = ..()
	if(src.dir == NORTH)
		src.layer = OBJ_LAYER
		var/image/behind = image(src.icon, "[src.icon_state]_behind")
		behind.layer = FLY_LAYER
		add_overlay(behind)

/obj/structure/stool/bed/chair/schair/wagon/bench/atom_init_late()
	return

/obj/structure/stool/bed/chair/schair/wagon/bench/rotate()
	return
