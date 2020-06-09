/obj/structure/closet/secure_closet/freezer

/obj/structure/closet/secure_closet/freezer/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "Kitchen Cabinet"
	req_access = list(access_kitchen)

/obj/structure/closet/secure_closet/freezer/kitchen/PopulateContents()
	for (var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/condiment/flour(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/monkey(src)
	new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)

/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/freezer/meat
	name = "Meat Fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridgeoff"

/obj/structure/closet/secure_closet/freezer/meat/PopulateContents()
	for (var/i in 1 to 4)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/monkey(src)

/obj/structure/closet/secure_closet/freezer/fridge
	name = "Refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridgeoff"

/obj/structure/closet/secure_closet/freezer/fridge/PopulateContents()
	for (var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/drinks/milk(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/food/drinks/soymilk(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/money
	name = "Freezer"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridgeoff"
	req_access = list(access_heads_vault)

/obj/structure/closet/secure_closet/freezer/money/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/weapon/spacecash/c1000(src)
	for (var/i in 1 to 5)
		new /obj/item/weapon/spacecash/c500(src)
	for (var/i in 1 to 6)
		new /obj/item/weapon/spacecash/c200(src)
