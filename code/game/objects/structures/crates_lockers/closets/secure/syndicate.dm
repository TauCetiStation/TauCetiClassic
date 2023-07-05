/obj/structure/closet/secure_closet/syndicate
	name = "syndicate secure closet"
	desc = "Closet for nuclear equipment."
	icon_state = "syndicatesecure1"
	icon_closed = "syndicatesecure"
	icon_locked = "syndicatesecure1"
	icon_opened = "syndicateopen"
	icon_broken = "syndicatesecurebroken"
	icon_off = "syndicatesecureoff"
	req_access = list(access_syndicate)

/obj/structure/closet/secure_closet/syndicate/PopulateContents()
	new /obj/item/weapon/reagent_containers/pill/cyanide(src)
	new /obj/item/weapon/crowbar/red(src)
	new /obj/item/ammo_box/magazine/stechkin(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/weapon/pinpointer/nukeop(src)
	new /obj/item/weapon/kitchenknife/combat(src)
	new /obj/item/clothing/accessory/storage/syndi_vest(src)

/obj/structure/closet/secure_closet/syndicate/commander
	name = "commander secure closet"
	req_access = list(access_syndicate_commander)

/obj/structure/closet/secure_closet/syndicate/commander/PopulateContents()
	new /obj/item/weapon/reagent_containers/pill/cyanide(src)
	new /obj/item/weapon/crowbar/red(src)
	new /obj/item/ammo_box/speedloader/a357(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/weapon/pinpointer/nukeop(src)
	new /obj/item/weapon/kitchenknife/combat(src)
	new /obj/item/clothing/accessory/storage/syndi_vest(src)
	new /obj/item/device/radio/uplink(src)
