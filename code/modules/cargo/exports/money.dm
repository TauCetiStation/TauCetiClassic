// Space Cash. Now it isn't that useless.
/datum/export/money/cash_c1
	cost = 0.5 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit chip"
	export_types = list(/obj/item/weapon/spacecash/c1)

/datum/export/money/cash_c10
	cost = 5 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit chip"
	export_types = list(/obj/item/weapon/spacecash/c10)

/datum/export/money/cash_c20
	cost = 10 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit chip"
	export_types = list(/obj/item/weapon/spacecash/c20)

/datum/export/money/cash_c50
	cost = 25 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit chip"
	export_types = list(/obj/item/weapon/spacecash/c50)

/datum/export/money/cash_c100
	cost = 50 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit chip"
	export_types = list(/obj/item/weapon/spacecash/c100)

/datum/export/money/cash_c200
	cost = 100 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit chip"
	export_types = list(/obj/item/weapon/spacecash/c200)

/datum/export/money/cash_c500
	cost = 250 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit chip"
	export_types = list(/obj/item/weapon/spacecash/c500)

/datum/export/money/cash_c1000
	cost = 500 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit chip"
	export_types = list(/obj/item/weapon/spacecash/c1000)

/datum/export/stack/cash/get_amount(obj/O)
	var/obj/item/weapon/spacecash/C = O
	return ..() * C.worth


// Coins. At least the coins that do not contain any materials.
// Material-containing coins cost just as much as their materials do, see materials.dm for exact rates.
/datum/export/coin
	cost = 1 // Multiplied by coin's value
	unit_name = "credit coin"
	message = "worth of rare coins"
	export_types = list(/obj/item/weapon/coin)

/datum/export/coin/get_cost(obj/O, contr = 0, emag = 0)
	var/price = 0
	switch(O.name)
		if(COIN_IRON)
			price = 50
		if(COIN_SILVER)
			price = 100
		if(COIN_GOLD)
			price = 150
		if(COIN_URANIUM)
			price = 180
		if(COIN_PHORON)
			price = 220
		if(COIN_PLATINUM, COIN_MYTHRIL)
			price = 300
		if(COIN_DIAMOND)
			price = 350
		if(COIN_BANANIUM)
			price = 450
		else
			price = 1
	return ..() * price
