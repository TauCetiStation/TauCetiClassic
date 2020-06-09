/obj/random/pouch
	name = "random pouch"
	icon = 'icons/obj/pouches.dmi'
	icon_state = "large_generic"

/obj/random/pouch/item_to_spawn()
	return pickweight(list(
	/obj/item/weapon/storage/pouch/small_generic = 10,
	/obj/item/weapon/storage/pouch/medium_generic = 5,
	/obj/item/weapon/storage/pouch/large_generic = 1,
	/obj/item/weapon/storage/pouch/medical_supply = 3,
	/obj/item/weapon/storage/pouch/engineering_supply = 3,
	/obj/item/weapon/storage/pouch/engineering_tools = 5,
	/obj/item/weapon/storage/pouch/flare = 7,
	/obj/item/weapon/storage/pouch/ammo = 3,
	/obj/item/weapon/storage/pouch/pistol_holster = 3,
	/obj/item/weapon/storage/pouch/baton_holster = 3
	))

/obj/random/pouch/low_chance
	name = "low chance random pouch"
	icon_state = "small_generic"
	spawn_nothing_percentage = 80
