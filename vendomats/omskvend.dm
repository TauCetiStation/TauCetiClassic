/obj/machinery/vending/omskvend
	name = "Omsk-o-mat"
	desc = "Drug dispenser."
	icon = 'tauceti/vendomats/vendings.dmi'
	icon_state = "omskvend"
	product_ads = "NORKOMAN SUKA SHTOLE?;STOP NARTCOTICS!; so i heard u liek mudkipz; METRO ZATOPEELO"
	products = list(/obj/item/device/healthanalyzer = 5)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4)

/obj/item/weapon/reagent_containers/pill/LSD
	name = "LSD"
	desc = "Ahaha oh wow."
	icon_state = "pill9"
	New()
		..()
		reagents.add_reagent("mindbreaker", 0)

/obj/item/weapon/reagent_containers/glass/beaker/LSD
	name = "LSD IV"
	desc = "Ahaha oh wow."
	New()
		..()
		reagents.add_reagent("mindbreaker", 0)
		update_icon()