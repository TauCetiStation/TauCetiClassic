/datum/outfit/tele_derelict
	name = "Derelict survivor"
	uniform = /obj/item/clothing/under/rank/security
	shoes = /obj/item/clothing/shoes/boots/combat
	l_pocket = /obj/item/device/flash
	id = /obj/item/weapon/card/id/tele_derelict/officer
	back = /obj/item/weapon/storage/backpack
	survival_box = TRUE

	//lets be merciful
	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi, /obj/item/weapon/reagent_containers/food/snacks/beans, /obj/item/device/flashlight/flare, /obj/item/stack/medical/bruise_pack, /obj/item/stack/medical/suture)
	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)
