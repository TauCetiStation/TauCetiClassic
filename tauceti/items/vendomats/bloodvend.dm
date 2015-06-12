//from old nanotrasen
/obj/machinery/vending/blood
	name = "Blood'O'Matic"
	desc = "Human blood dispenser. With internal freezer. Brought to you by EmpireV corp."
	icon = 'tauceti/items/vendomats/vendings.dmi'
	icon_state = "blood2"
	light_color = "#ffc0c0"
	icon_deny = "blood2deny"
	product_ads = "Go and grab some blood!;I'm hope you are not bloody vampire.;Only from nice virgins!;Natural liquids!;This stuff saves lives."
	//req_access_txt = "5"
	products = list(/obj/item/weapon/reagent_containers/blood/APlus = 7, /obj/item/weapon/reagent_containers/blood/AMinus = 4,
					/obj/item/weapon/reagent_containers/blood/BPlus = 4, /obj/item/weapon/reagent_containers/blood/BMinus = 2,
					/obj/item/weapon/reagent_containers/blood/OPlus = 7, /obj/item/weapon/reagent_containers/blood/OMinus = 4)
	contraband = list(/obj/item/weapon/reagent_containers/pill/stox = 10, /obj/item/weapon/reagent_containers/blood/empty = 10)