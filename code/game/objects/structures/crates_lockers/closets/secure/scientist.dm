/obj/structure/closet/secure_closet/scientist
	name = "Scientist's Locker"
	req_access = list(access_tox_storage)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_broken = "secureresbroken"
	icon_off = "secureresoff"

/obj/structure/closet/secure_closet/scientist/PopulateContents()
	new /obj/item/clothing/under/rank/scientist(src)
	//new /obj/item/clothing/suit/labcoat/science(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
//	new /obj/item/weapon/cartridge/signal/science(src)
	new /obj/item/device/radio/headset/headset_sci(src)
	new /obj/item/weapon/tank/air(src)
	new /obj/item/clothing/mask/gas/coloured(src)

/obj/structure/closet/secure_closet/RD
	name = "Research Director's Locker"
	req_access = list(access_rd)
	icon_state = "rdsecure1"
	icon_closed = "rdsecure"
	icon_locked = "rdsecure1"
	icon_opened = "rdsecureopen"
	icon_broken = "rdsecurebroken"
	icon_off = "rdsecureoff"

/obj/structure/closet/secure_closet/RD/PopulateContents()

	new /obj/item/clothing/suit/bio_suit/new_hazmat/scientist(src)
	new /obj/item/clothing/head/bio_hood/new_hazmat/scientist(src)
	new /obj/item/clothing/under/rank/research_director(src)
	new /obj/item/clothing/under/rank/research_director/rdalt(src)
	new /obj/item/clothing/under/rank/research_director/dress_rd(src)
	new /obj/item/clothing/suit/storage/labcoat/rd(src)
	new /obj/item/weapon/cartridge/rd(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/leather(src)
	new /obj/item/clothing/gloves/latex(src)
	new /obj/item/device/radio/headset/heads/rd(src)
	new /obj/item/weapon/tank/air(src)
	new /obj/item/clothing/mask/gas/coloured(src)
	new /obj/item/device/flash(src)
	new /obj/item/device/remote_device/research_director(src)
	new /obj/item/airbag(src)