/obj/machinery/vending/battle_royale
	name = "Battle Royale Show Ticket System"
	desc = "desc"
	product_slogans = "Battle Royale Show: best show in all world!"
	//product_ads = ""
	products = list(
		/obj/item/weapon/br_ticket/observer = 100,
		/obj/item/weapon/br_ticket/budget = 10,
		/obj/item/weapon/br_ticket/participant = 100,
		/obj/item/weapon/br_ticket/vip = 10,
		/obj/item/weapon/br_ticket/donator = 1,
		)
	prices = list(
		/obj/item/weapon/br_ticket/observer = 1000,
		/obj/item/weapon/br_ticket/budget = 500,
		/obj/item/weapon/br_ticket/participant = 1500,
		/obj/item/weapon/br_ticket/vip = 5000,
		/obj/item/weapon/br_ticket/donator = 50000,
		)

///obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user)