/obj/structure/closet/secure_closet/cargotech
	name = "Cargo Technician's Locker"
	req_access = list(access_cargo)
	icon_state = "securecargo1"
	icon_closed = "securecargo"
	icon_locked = "securecargo1"
	icon_opened = "securecargoopen"
	icon_broken = "securecargobroken"
	icon_off = "securecargooff"

/obj/structure/closet/secure_closet/cargotech/PopulateContents()
	new /obj/item/clothing/under/rank/cargotech(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/brown(src)
	new /obj/item/clothing/head/soft(src)
//	new /obj/item/weapon/cartridge/quartermaster(src)
	#ifdef NEWYEARCONTENT
	new /obj/item/clothing/suit/wintercoat/cargo(src)
	new /obj/item/clothing/suit/wintercoat/cargo(src)
	new /obj/item/clothing/shoes/winterboots(src)
	new /obj/item/clothing/shoes/winterboots(src)
	new /obj/item/clothing/head/santa(src)
	#endif

/obj/structure/closet/secure_closet/recycler
	name = "Recycler's Locker"
	req_access = list(access_recycler)
	icon_state = "securecargo1"
	icon_closed = "securecargo"
	icon_locked = "securecargo1"
	icon_opened = "securecargoopen"
	icon_broken = "securecargobroken"
	icon_off = "securecargooff"

/obj/structure/closet/secure_closet/recycler/PopulateContents()
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/storage/bag/trash/miners(src)
	new /obj/item/clothing/under/rank/recycler(src)
	new /obj/item/clothing/under/rank/recyclercasual(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/head/helmet/space/globose/recycler(src)
	new /obj/item/clothing/suit/space/globose/recycler(src)
	new /obj/item/clothing/head/soft/trash(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/suit/recyclervest(src)
