/obj/structure/closet/secure_closet/freezer
	icon_state = "fridge"
	icon_closed = "fridge"
	icon_opened = "fridge_open"
	overlay_locked = "fridge_locked"
	overlay_unlocked = "fridge_unlocked"
	overlay_welded = "fridge_welded"

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "Kitchen Cabinet"
	req_access = list(access_kitchen)

/obj/structure/closet/secure_closet/freezer/kitchen/PopulateContents()
	for (var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/condiment/flour(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/monkey(src)
	new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)


/obj/structure/closet/secure_closet/freezer/kitchen/kitchenbig

/obj/structure/closet/secure_closet/freezer/kitchen/kitchenbig/PopulateContents()
	for (var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/drinks/milk(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/food/drinks/soymilk(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/storage/fancy/egg_box(src)
	for (var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/condiment/flour(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/monkey(src)
	new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)



/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/freezer/meat
	name = "Meat Fridge"


/obj/structure/closet/secure_closet/freezer/meat/PopulateContents()
	for (var/i in 1 to 4)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/monkey(src)


/obj/structure/closet/secure_closet/freezer/fridge
	name = "Refrigerator"

/obj/structure/closet/secure_closet/freezer/fridge/PopulateContents()
	for (var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/drinks/milk(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/food/drinks/soymilk(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/money
	name = "Freezer"
	req_access = list(access_heads_vault)

/obj/structure/closet/secure_closet/freezer/money/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/weapon/spacecash/c1000(src)
	for (var/i in 1 to 5)
		new /obj/item/weapon/spacecash/c500(src)
	for (var/i in 1 to 6)
		new /obj/item/weapon/spacecash/c200(src)

/obj/structure/closet/secure_closet/freezer/empty
	name = "Refrigerator"
	req_access = list()

/obj/structure/closet/secure_closet/freezer/milkshake
	name = "Refrigerator"

/obj/structure/closet/secure_closet/freezer/milkshake/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/drinks/milk(src)
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/berries(src)
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod(src)

/obj/structure/closet/secure_closet/freezer/icecream
	name = "Ingredients"

/obj/structure/closet/secure_closet/freezer/icecream/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)
	for(var/i in 1 to 4)
		new /obj/item/weapon/reagent_containers/food/condiment/flour(src)
	//popcorn why not
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/snacks/grown/corn(src)
