/obj/structure/closet/secure_closet/hydroponics
	name = "Botanist's locker"
	req_access = list(access_hydroponics)
	icon_state = "hydrosecure1"
	icon_closed = "hydrosecure"
	icon_locked = "hydrosecure1"
	icon_opened = "hydrosecureopen"
	icon_broken = "hydrosecurebroken"
	icon_off = "hydrosecureoff"

/obj/structure/closet/secure_closet/hydroponics/PopulateContents()
	switch(rand(1,2))
		if(1)
			new /obj/item/clothing/suit/apron(src)
		if(2)
			new /obj/item/clothing/suit/apron/overalls(src)

	new /obj/item/weapon/storage/bag/plants(src)
	new /obj/item/clothing/under/rank/hydroponics(src)
	new /obj/item/clothing/under/rank/hydroponics_fem(src)
	new /obj/item/device/plant_analyzer(src)
	//new /obj/item/clothing/head/greenbandana(src)
	new /obj/item/clothing/mask/bandana(src)
	new /obj/item/weapon/minihoe(src)
	new /obj/item/weapon/hatchet(src)
//	new /obj/item/weapon/bee_net(src) //No more bees, March 2014
	new /obj/item/clothing/gloves/botanic_leather(src)
	#ifdef NEWYEARCONTENT
	new /obj/item/clothing/suit/wintercoat/hydro(src)
	new /obj/item/clothing/head/santa(src)
	#endif
