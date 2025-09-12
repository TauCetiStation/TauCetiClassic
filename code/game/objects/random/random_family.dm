/obj/random/family/grandma
	name = "Random family item from grandma"
	desc = "This is a random item from grandma."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"

/obj/random/family/grandma/item_to_spawn()
		return pick(\
						/obj/random/foods/food_snack,\
						/obj/random/foods/drink_bottle,\
						/obj/random/foods/drink_can,\
						/obj/random/cloth/random_cloth_safe,\
						/obj/random/misc/book,\
					)

/obj/random/family/grandpa
	name = "Random family item from grandpa"
	desc = "This is a random item from grandpa."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"

/obj/random/family/grandpa/item_to_spawn()
		return pick(\
						prob(30);/obj/random/foods/drink_bottle,\
						prob(30);/obj/random/foods/drink_can,\
						prob(1);/obj/item/weapon/gun/projectile/revolver/doublebarrel,\
						prob(15);/obj/random/misc/smokes,\
					)

/obj/random/family/mother
	name = "Random family item from mother"
	desc = "This is a random item from mother."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"

/obj/random/family/mother/item_to_spawn()
		return pick(\
						/obj/random/foods/food_snack,\
						/obj/item/weapon/spacecash/c100,\
						/obj/random/cloth/head,\
						/obj/random/meds/medkit,\
						/obj/random/meds/medical_pills,\
						/obj/random/misc/book,\
					)

/obj/random/family/father
	name = "Random family item from father"
	desc = "This is a random item from father."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"

/obj/random/family/father/item_to_spawn()
		return pick(\
						/obj/random/foods/drink_bottle,\
						/obj/item/weapon/spacecash/c100,\
						/obj/random/cloth/glasses_safe,\
						/obj/random/cloth/tie,\
						/obj/random/tools/toolbox,\
						/obj/random/misc/cigarettes,\
						/obj/random/misc/musical,\
					)

/obj/random/family/brother
	name = "Random family item from brother"
	desc = "This is a random item from brother."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"

/obj/random/family/brother/item_to_spawn()
		return pick(\
						/obj/random/foods/drink_bottle,\
						/obj/item/weapon/spacecash/c100,\
						/obj/random/meds/pills,\
						/obj/random/misc/cigarettes,\
						/obj/random/misc/toy,\
					)

/obj/random/family/sister
	name = "Random family item from sister"
	desc = "This is a random item from sister."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"

/obj/random/family/sister/item_to_spawn()
		return pick(\
						/obj/random/foods/drink_bottle,\
						/obj/item/weapon/spacecash/c100,\
						/obj/random/meds/medical_pills,\
						/obj/random/misc/toy,\
					)

/obj/random/family/partner
	name = "Random family item from partner"
	desc = "This is a random item from partner."
	icon = 'icons/obj/food.dmi'
	icon_state = "mysterysoup"

/obj/random/family/partner/item_to_spawn()
		return pick(\
						/obj/item/weapon/storage/fancy/heart_box,\
						/obj/random/foods/candies,\
						/obj/random/foods/flowers,\
						/obj/random/cloth/random_cloth_safe,\
					)
