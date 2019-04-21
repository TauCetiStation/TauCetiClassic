// Space Cash. Now it isn't that useless.
/datum/export/stack/cash
	cost = 1 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit chip"
	export_types = list(/obj/item/weapon/spacecash)

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
