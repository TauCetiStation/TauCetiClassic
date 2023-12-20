/obj/structure/stool/bed/chair/schair/wagon
	name = "Shuttle Chair"
	cases = list("кресло шаттла", "кресла шаттла", "креслу шаттла", "кресло шаттла", "креслом шаттла", "кресле шаттла")
	desc = "Вы сидите на этом. Либо по своей воле, либо добровольно-принудительно."
	icon = 'icons/locations/shuttles/bench.dmi'
	icon_state = "chair"

/obj/structure/stool/bed/chair/schair/wagon/bench
	name = "Bench"
	cases = list("лавка", "лавки", "лавке", "лавку", "лавкой", "лавке")
	desc = "Вы сидите на этом. Либо по своей воле, либо по принуждению."
	icon = 'icons/locations/shuttles/bench.dmi'
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
