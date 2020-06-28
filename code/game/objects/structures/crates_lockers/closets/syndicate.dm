/obj/structure/closet/syndicate
	name = "armoury closet"
	desc = "Why is this here?"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"


/obj/structure/closet/syndicate/personal
	desc = "It's a storage unit for operative gear."

/obj/structure/closet/syndicate/personal/PopulateContents()
	new /obj/item/clothing/glasses/night(src)
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/weapon/crowbar/red(src)
	new /obj/item/weapon/storage/belt/military(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/accessory/storage/syndi_vest(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/weapon/kitchenknife/combat(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src) // Perhaps this may encourage actually buying pistols.
	new /obj/item/weapon/storage/pouch/ammo(src)


/obj/structure/closet/syndicate/nuclear
	desc = "It's a storage unit for nuclear-operative gear."

/obj/structure/closet/syndicate/nuclear/PopulateContents()
	new /obj/item/weapon/storage/box/handcuffs(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	for (var/i in 1 to 6)
		new /obj/item/weapon/pinpointer/nukeop(src)
	new /obj/item/device/pda/syndicate(src)

/obj/structure/closet/syndicate/resources
	desc = "An old, dusty locker."

/obj/structure/closet/syndicate/resources/PopulateContents()
	var/common_min = 30 // Minimum amount of minerals in the stack for common minerals
	var/common_max = 50 // Maximum amount of HONK in the stack for HONK common minerals
	var/rare_min = 5    // Minimum HONK of HONK in the stack HONK HONK rare minerals
	var/rare_max = 20   // Maximum HONK HONK HONK in the HONK for HONK rare HONK

	var/pickednum = rand(1, 50)

	//Sad trombone
	if(pickednum == 1)
		var/obj/item/weapon/paper/P = new(src)
		P.name = "IOU"
		P.info = "Sorry man, we needed the money so we sold your stash. It's ok, we'll double our money for sure this time!"
		P.update_icon()

	//Metal (common ore)
	if(pickednum >= 2) // WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE~
		new /obj/item/stack/sheet/metal(src, rand(common_min, common_max))

		//Glass (common ore)
		if(pickednum >= 5)
			new /obj/item/stack/sheet/glass(src, rand(common_min, common_max))

			//Plasteel (common ore) Because it has a million more uses then phoron
			if(pickednum >= 10)
				new /obj/item/stack/sheet/plasteel(src, rand(common_min, common_max))

				//Phoron (rare ore)
				if(pickednum >= 15)
					new /obj/item/stack/sheet/mineral/phoron(src, rand(rare_min, rare_max))

					//Silver (rare ore)
					if(pickednum >= 20)
						new /obj/item/stack/sheet/mineral/silver(src, rand(rare_min, rare_max))

						//Gold (rare ore)
						if(pickednum >= 30)
							new /obj/item/stack/sheet/mineral/gold(src, rand(rare_min, rare_max))

							//Uranium (rare ore)
							if(pickednum >= 40)
								new /obj/item/stack/sheet/mineral/uranium(src, rand(rare_min, rare_max))

								//Diamond (rare HONK)
								if(pickednum >= 45)
									new /obj/item/stack/sheet/mineral/diamond(src, rand(rare_min, rare_max))

	//Jetpack (You hit the jackpot!)
	if(pickednum == 50)
		new /obj/item/weapon/tank/jetpack/carbondioxide(src)

/obj/structure/closet/syndicate/resources/everything
	desc = "It's an emergency storage closet for repairs."

/obj/structure/closet/syndicate/resources/everything/PopulateContents()
	var/list/resources = list(
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/sheet/mineral/silver,
		/obj/item/stack/sheet/mineral/phoron,
		/obj/item/stack/sheet/mineral/uranium,
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/sheet/mineral/clown,
		/obj/item/stack/sheet/plasteel,
		/obj/item/stack/cable_coil,
		/obj/item/stack/rods
	)

	for(var/i in 1 to 2)
		for(var/res in resources)
			var/obj/item/stack/R = new res(src)
			R.set_amount(R.max_amount)
