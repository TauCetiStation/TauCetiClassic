//TOOLS RANDOM
/obj/random/misc/all
	name = "Random Item"
	desc = "This is a random item."
	icon = 'icons/obj/items.dmi'
	icon_state = "gift"
	spawn_nothing_percentage = 85
/obj/random/misc/all/item_to_spawn()
		return pick(/obj/random/meds/medical_supply,\
					/obj/random/tools/tech_supply/guaranteed,\
					/obj/random/tools/tech_supply/guaranteed,\
					/obj/random/tools/tech_supply/guaranteed,\
					/obj/random/foods/food_without_garbage,\
					/obj/random/foods/food_without_garbage,\
					/obj/random/foods/food_without_garbage,\
					/obj/preset/storage/weapons/random)