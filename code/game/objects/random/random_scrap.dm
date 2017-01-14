//RANDOM SCRAP PILE GENERATOR
/obj/random/scrap/dense_even
	name = "Random dense even trash"
	desc = "This is a random trash."
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
/obj/random/scrap/dense_even/item_to_spawn()
		return pick(\
						/obj/structure/scrap/large,\
						/obj/structure/scrap/medical/large,\
						/obj/structure/scrap/vehicle/large,\
						/obj/structure/scrap/food/large,\
						/obj/structure/scrap/guns/large,\
						/obj/structure/scrap/science/large\
					)

/obj/random/scrap/dense_weighted
	name = "Random dense weighted trash"
	desc = "This is a random trash."
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
/obj/random/scrap/dense_weighted/item_to_spawn()
		return pick(\
						prob(35);/obj/structure/scrap/poor/large,\
						prob(6);/obj/structure/scrap/large,\
						prob(4);/obj/structure/scrap/medical/large,\
						prob(4);/obj/structure/scrap/science/large,\
						prob(6);/obj/structure/scrap/vehicle/large,\
						prob(12);/obj/structure/scrap/food/large,\
						prob(1);/obj/structure/scrap/guns/large\
					)

/obj/random/scrap/sparse_even
	name = "Random sparse even trash"
	desc = "This is a random trash."
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
/obj/random/scrap/sparse_even/item_to_spawn()
		return pick(\
						/obj/structure/scrap,\
						/obj/structure/scrap/medical,\
						/obj/structure/scrap/vehicle,\
						/obj/structure/scrap/food,\
						/obj/structure/scrap/science,\
						/obj/structure/scrap/guns\
					)

/obj/random/scrap/sparse_weighted
	name = "Random sparse weighted trash"
	desc = "This is a random trash."
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
/obj/random/scrap/sparse_weighted/item_to_spawn()
		return pick(\
						prob(35);/obj/structure/scrap/poor,\
						prob(6);/obj/structure/scrap,\
						prob(4);/obj/structure/scrap/medical,\
						prob(4);/obj/structure/scrap/science,\
						prob(6);/obj/structure/scrap/vehicle,\
						prob(12);/obj/structure/scrap/food,\
						prob(1);/obj/structure/scrap/guns\
					)

/obj/random/scrap/moderate_weighted
	name = "Random moderate weighted trash"
	desc = "This is a random tool."
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
/obj/random/scrap/moderate_weighted/item_to_spawn()
		return pick(\
						prob(2);/obj/random/scrap/sparse_weighted,\
						prob(1);/obj/random/scrap/dense_weighted\
					)
