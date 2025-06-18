/obj/structure/stool/bed/bench
	name = "Bench"
	cases = list("лавка", "лавки", "лавке", "лавку", "лавкой", "лавке")
	desc = "Вы сидите на этом. Либо по своей воле, либо по принуждению."
	icon = 'icons/locations/shuttles/bench.dmi'
	icon_state = "bench_1"
	buckle_lying = FALSE

/obj/structure/stool/bed/bench/atom_init()
	. = ..()
	if(dir == NORTH)
		layer = OBJ_LAYER
		var/image/behind = image(icon, "[icon_state]_behind")
		behind.layer = FLY_LAYER
		add_overlay(behind)

/obj/structure/stool/bed/chair/schair/wagon
	name = "Shuttle Chair"
	cases = list("кресло шаттла", "кресла шаттла", "креслу шаттла", "кресло шаттла", "креслом шаттла", "кресле шаттла")
	desc = "Вы сидите на этом. Либо по своей воле, либо добровольно-принудительно."
	icon = 'icons/locations/shuttles/bench.dmi'

/obj/structure/stool/bed/chair/schair/wagon/blue
	icon_state = "chair_blue"

/obj/structure/stool/bed/chair/schair/wagon/red
	icon_state = "chair_red"

/obj/structure/stool/bed/chair/schair/wagon/yellow
	icon_state = "chair_yellow"

/obj/structure/stool/bed/chair/schair/wagon/green
	icon_state = "chair_green"
