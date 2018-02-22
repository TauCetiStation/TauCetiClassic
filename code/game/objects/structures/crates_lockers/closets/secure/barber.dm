/obj/structure/closet/secure_closet/barber
	name = "Barber's locker"
	req_access = list(access_barber)
	icon_state = "barbersecure1"
	icon_closed = "barbersecure"
	icon_locked = "barbersecure1"
	icon_opened = "barbersecureopen"
	icon_broken = "barbersecurebroken"
	icon_off = "barbersecureoff"

/obj/structure/closet/secure_closet/hydroponics/PopulateContents()
	new /obj/item/clothing/suit/wcoat(src)
	new /obj/item/weapon/storage/bag/plants(src)
	new /obj/item/clothing/under/det(src)
	new /obj/item/clothing/under/det/black(src)
	new /obj/item/clothing/under/det/slob(src)
	new /obj/item/clothing/under/det/max_payne(src)
	new /obj/item/weapon/storage/box/hairsprays
	new /obj/item/weapon/hair_growth_accelerator(src)
	new /obj/item/weapon/scissors(src)
	new /obj/item/weapon/razor(src)
	new /obj/item/weapon/reagent_containers/spray/cleaner(src)
	new /obj/item/weapon/reagent_containers/glass/rag(src)
	#ifdef NEWYEARCONTENT
	new /obj/item/clothing/suit/wintercoat(src)
	new /obj/item/clothing/head/santa(src)
	#endif
