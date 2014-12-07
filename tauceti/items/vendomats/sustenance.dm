//Тюремный вендомат с ТГ
/obj/machinery/vending/sustenance
	name = "\improper Sustenance Vendor"
	icon = 'tauceti/items/vendomats/vendings.dmi'
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	product_slogans = "Enjoy your meal.;Enough calories to support strenuous labor."
	product_ads = "Sufficiently healthy.;Efficiently produced tofu!;Mmm! So good!;Have a meal.;You need food to live!;Have some more candy corn!;Try our new ice cups!"
	icon_state = "sustenance"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/tofu = 20,
					/obj/item/weapon/reagent_containers/food/drinks/ice = 12,
					/obj/item/weapon/reagent_containers/food/snacks/candy_corn = 6,
					/obj/item/weapon/reagent_containers/food/snacks/cracker = 20,
					/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 12)
	contraband = list(/obj/item/weapon/kitchen/utensil/knife = 6)