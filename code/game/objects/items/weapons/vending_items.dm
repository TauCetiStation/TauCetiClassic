/obj/item/weapon/vending_refill
	name = "Resupply canister"
	var/machine_name = "Generic"

	icon = 'icons/obj/vending.dmi'
	icon_state = "refill_unk"
	item_state = "restock_unit"
	flags = CONDUCT
	force = 7.0
	throwforce = 15.0
	throw_speed = 1
	throw_range = 7
	w_class = ITEM_SIZE_LARGE

	var/charges = 0		//how many restocking "charges" the refill has

/obj/item/weapon/vending_refill/atom_init()
	. = ..()
	name = "[machine_name] restocking unit"

/obj/item/weapon/vending_refill/examine(mob/user)
	..()
	if(src in view(1, user))
		if(charges)
			to_chat(user, "It can restock [charges] item\s.")
		else
			to_chat(user, "It's empty!")

//NOTE I decided to go for about 1/3 of a machine's capacity

/obj/item/weapon/vending_refill/boozeomat
	machine_name = "Booze-O-Mat"
	icon_state = "refill_booze"
	charges = 50//of 138

/obj/item/weapon/vending_refill/coffee
	machine_name = "hot drinks"
	icon_state = "refill_joe"
	charges = 30//of 85

/obj/item/weapon/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"
	icon_state = "refill_snack"
	charges = 15//of 48

/obj/item/weapon/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"
	charges = 20//of 65

/obj/item/weapon/vending_refill/cigarette
	machine_name = "cigarette"
	icon_state = "refill_smoke"
	charges = 10// of 30
/*
/obj/item/weapon/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"
	charges = 28// of 58
*/

/obj/item/weapon/vending_refill/clothing
	machine_name = "ClothesMate"
	icon_state = "refill_clothes"
	charges = 16// of 48

/obj/item/weapon/vending_refill/barbervend
	machine_name = "BarberVend"
	charges =  25// of 73

/obj/item/weapon/vending_refill/hydroseeds
	machine_name = "MegaSeed Servitor"
	charges =  30// of 90

/obj/item/weapon/vending_refill/hydronutrients
	machine_name = "NutriMax"
	charges =  38// of 115

/obj/item/weapon/vending_refill/medical
	machine_name = "NanoMed Plus"
	charges =  17// of 51

/obj/item/weapon/vending_refill/chinese
	machine_name = "Mr. Chang"
	icon_state = "refill_snack"
	charges =  16// of 48

/obj/item/weapon/vending_refill/tool
	machine_name = "YouTool"
	charges =  15// of 43

/obj/item/weapon/vending_refill/engivend
	machine_name = "Engi-Vend"
	charges =  15// of 46

/obj/item/weapon/vending_refill/blood
	machine_name = "Blood'O'Matic"
	charges =  10// of 28

/obj/item/weapon/vending_refill/junkfood
	machine_name = "McNuffin's Fast Food"
	icon_state = "refill_snack"
	charges =  14// of 40

/obj/item/weapon/vending_refill/assist
	machine_name = "Vendomat"
	charges =  6// of 17

/obj/item/weapon/vending_refill/dinnerware
	machine_name = "Dinnerware"
	charges =  12// of 35