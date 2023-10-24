/obj/structure/closet/secure_closet/bar
	name = "Booze"
	req_access = list(access_bar)
	icon_state = "cabinetsecure"
	icon_closed = "cabinetsecure"
	icon_opened = "cabinetsecure_open"
	overlay_locked = "cabinetsecure_locked"
	overlay_unlocked = "cabinetsecure_unlocked"
	overlay_welded = "cabinetsecure_welded"

/obj/structure/closet/secure_closet/bar/PopulateContents()
	for (var/i in 1 to 10)
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/beer(src)
