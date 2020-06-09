//TOOLS RANDOM
/obj/random/misc/all
	name = "Random Item"
	desc = "This is a random item."
	icon = 'icons/obj/items.dmi'
	icon_state = "gift"
	spawn_nothing_percentage = 80
/obj/random/misc/all/item_to_spawn()
		return pick(\
						prob(10);/obj/random/meds/medical_supply,\
						prob(10);/obj/random/misc/pack,\
						prob(30);/obj/random/tools/tech_supply/guaranteed,\
						prob(50);/obj/random/foods/food_without_garbage,\
						prob(10);/obj/random/science/science_supply,\
						prob(5);/obj/random/cloth/random_cloth,\
						prob(2);/obj/preset/storage/weapons/random,\
						prob(1);/obj/random/syndie/fullhouse\
					)
