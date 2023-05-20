/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	light_color = "#77beda"
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/beer = 6,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/ale = 6,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 4,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 4,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 4,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 4,
		/obj/item/weapon/reagent_containers/food/drinks/cans/tonic = 8,
		/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 8,
		/obj/item/weapon/reagent_containers/food/drinks/cans/sodawater = 15,
		/obj/item/weapon/reagent_containers/food/drinks/flask/barflask = 2,
		/obj/item/weapon/reagent_containers/food/drinks/flask/vacuumflask = 2,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 30,
		/obj/item/weapon/reagent_containers/food/drinks/ice = 9,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/melonliquor = 2,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao = 2,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe = 2,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/grenadine = 5,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/champagne = 5,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/tea = 10,
	)
	syndie = list (
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/beepskysmash = 1,
	)
	vend_delay = 15
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	req_access = list(25)
	refill_canister = /obj/item/weapon/vending_refill/boozeomat
	private = TRUE

/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	light_color = "#b88b2e"
	vend_delay = 34
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 25,
		/obj/item/weapon/reagent_containers/food/drinks/tea = 25,
		/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 25,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/ice = 10,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 15,
		/obj/item/weapon/reagent_containers/food/drinks/tea = 15,
		/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 15,
	)
	refill_canister = /obj/item/weapon/vending_refill/coffee
	private = FALSE

/obj/machinery/vending/snack
	name = "Getmore Chocolate Corp"
	subname = "Red"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snackred"
	light_color = "#d00023"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/candybar = 6,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 6,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/hell_ramen = 6,
		/obj/item/weapon/storage/food/small/chips = 6,
		/obj/item/weapon/storage/food/normal/chips = 6,
		/obj/item/weapon/storage/food/normal/sosjerky = 6,
		/obj/item/weapon/storage/food/normal/no_raisin = 6,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 6,
		/obj/item/weapon/storage/food/normal/honkers = 6,
	)
	contraband = list(
		/obj/item/weapon/storage/food/normal/syndi_cakes = 6,
		/obj/item/weapon/storage/food/big/chips = 6,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/candy/candybar = 5,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 25,
		/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/hell_ramen = 25,
		/obj/item/weapon/storage/food/small/chips = 10,
		/obj/item/weapon/storage/food/normal/chips = 20,
		/obj/item/weapon/storage/food/big/chips = 50,
		/obj/item/weapon/storage/food/normal/sosjerky = 14,
		/obj/item/weapon/storage/food/normal/no_raisin = 15,
		/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 20,
		/obj/item/weapon/storage/food/normal/honkers = 15,
	)
	refill_canister = /obj/item/weapon/vending_refill/snack
	private = FALSE

/obj/random/vending/snack
	name = "random snack vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "snackrandom"

/obj/random/vending/snack/item_to_spawn()
	return pick(typesof(/obj/machinery/vending/snack))

/obj/machinery/vending/snack/blue
	subname = "Blue"
	icon_state = "snackblue"
	light_color = "#5efb00"

/obj/machinery/vending/snack/orange
	subname = "Orange"
	icon_state = "snackorange"
	light_color = "#ff8b02"

/obj/machinery/vending/snack/green
	subname = "Green"
	icon_state = "snackgreen"
	light_color = "#10ff1f"

/obj/machinery/vending/snack/teal
	subname = "Teal"
	icon_state = "snackteal"
	light_color = "#ffc400"

/obj/machinery/vending/chinese
	name = "Mr. Chang"
	desc = "A self-serving Chinese food machine, for all your Chinese food needs."
	product_slogans = "Taste 5000 years of culture!"
	icon_state = "chang"
	light_color = "#d00023"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein = 6,
		/obj/item/weapon/reagent_containers/food/snacks/chinese/tao = 6,
		/obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball = 6,
		/obj/item/weapon/reagent_containers/food/snacks/chinese/newdles = 6,
		/obj/item/weapon/reagent_containers/food/snacks/chinese/rice = 6,
		/obj/item/weapon/kitchen/utensil/fork/sticks = 18,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein = 25,
		/obj/item/weapon/reagent_containers/food/snacks/chinese/tao = 25,
		/obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball = 25,
		/obj/item/weapon/reagent_containers/food/snacks/chinese/newdles = 25,
		/obj/item/weapon/reagent_containers/food/snacks/chinese/rice = 25,
		/obj/item/weapon/kitchen/utensil/fork/sticks = 1,
	)
	refill_canister = /obj/item/weapon/vending_refill/chinese
	private = FALSE

/obj/machinery/vending/cola
	name = "Robust Softdrinks"
	subname = "Blue"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "colablue"
	light_color = "#315ab4"
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 10,
		/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 10,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko = 5,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 3,
		/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 3,
		/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 3,
		/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 3,
		/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 2,
		/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 3,
		/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 3,
		/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 3,
	)
	refill_canister = /obj/item/weapon/vending_refill/cola
	private = FALSE

/obj/random/vending/cola
	name = "random cola vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "colarandom"

/obj/random/vending/cola/item_to_spawn()
	return pick(typesof(/obj/machinery/vending/cola))

/obj/machinery/vending/cola/black
	subname = "Black"
	icon_state = "colablack"
	light_color = "#dddddd"

/obj/machinery/vending/cola/red
	subname = "Red"
	desc = "It vends cola, in space."
	icon_state = "colared"
	product_slogans = "Cola in space!"
	light_color = "#bf0a38"

/obj/machinery/vending/cola/spaceup
	subname = "Lime, Space-up"
	desc = "Indulge in an explosion of flavor."
	icon_state = "spaceup"
	product_slogans = "Space-up! Like a hull breach in your mouth."
	light_color = "#18d32f"

/obj/machinery/vending/cola/starkist
	subname = "Orange, Starkist"
	desc = "The taste of a star in liquid form."
	icon_state = "starkist"
	product_slogans = "Drink the stars! Star-kist!"
	light_color = "#d1751a"

/obj/machinery/vending/cola/soda
	subname = "Red, Soda"
	icon_state = "soda"
	light_color = "#c8c8be"

/obj/machinery/vending/cola/gib
	subname = "Red, Dr. Gibb"
	desc = "Canned explosion of different flavors in this very vendor!"
	icon_state = "gib"
	product_slogans = "You will lose your guts because of our drinks!; Explosion - in a can!"
	light_color = "#d23c3c"

/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "An old sweet water vending machine, how did this end up here?"
	icon_state = "sovietsoda"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda = 30,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola = 20,
	)
	syndie = list(
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/kvass = 10,
	)
	private = TRUE

/obj/machinery/vending/junkfood
	name = "McNuffin's Fast Food"
	desc = "Fastest food on the station, unhealthiest yet."
	product_slogans = "I'm lovin it!;You deserve a break today!;Nobody can do it like McNuffin's can" //mcdonald's slogans adapted
	product_ads = "One Two Three Four... Big Bite burger!;I'm lovin it!;Two meaty cutlets, special sauce, cheese -- everything on a bland bun. Right, it's a Big Bite!"
	icon_state = "junkfood"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeyburger = 6,
		/obj/item/weapon/reagent_containers/food/snacks/cheeseburger = 4,
		/obj/item/weapon/reagent_containers/food/snacks/fries/cardboard = 6,
		/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/cardboard = 4,
		/obj/item/weapon/reagent_containers/food/snacks/hotdog = 5,
		/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 5,
		/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 5,
		/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 5,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeyburger = 10,
		/obj/item/weapon/reagent_containers/food/snacks/cheeseburger = 15,
		/obj/item/weapon/reagent_containers/food/snacks/fries/cardboard = 6,
		/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/cardboard = 9,
		/obj/item/weapon/reagent_containers/food/snacks/hotdog = 9,
		/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 3,
		/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 3,
		/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 3,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/snacks/fishfingers = 2,
	)
	refill_canister = /obj/item/weapon/vending_refill/junkfood
	private = FALSE

/obj/machinery/vending/donut
	name = "Monkin' Donuts"
	desc = "A donut vendor provided by Robust Industries, LLC."
	product_slogans = "Test your robustness!;Replenish your robustness!"
	product_ads = "Homer Simpson approves!;Each of us is a little cop!;Hope you're hunger!;Over 1 million donuts sold!;Try our new Robust Coffee!"
	icon_state = "donuts"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 5,
		/obj/item/weapon/reagent_containers/food/snacks/donut/classic = 5,
		/obj/item/weapon/reagent_containers/food/snacks/donut/choco = 5,
		/obj/item/weapon/reagent_containers/food/snacks/donut/banana = 5,
		/obj/item/weapon/reagent_containers/food/snacks/donut/berry = 5,
		/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly = 5,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 3,
		/obj/item/weapon/reagent_containers/food/snacks/donut/classic = 3,
		/obj/item/weapon/reagent_containers/food/snacks/donut/choco = 3,
		/obj/item/weapon/reagent_containers/food/snacks/donut/banana = 3,
		/obj/item/weapon/reagent_containers/food/snacks/donut/berry = 3,
		/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly = 3,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/food/snacks/donut/syndie = 5,
	)
	premium = list(
		/obj/item/weapon/storage/fancy/donut_box = 3,
	)
	refill_canister = /obj/item/weapon/vending_refill/donut
	private = FALSE

/obj/machinery/vending/sustenance
	name = "Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	product_slogans = "Enjoy your meal.;Enough calories to support strenuous labor."
	product_ads = "Sufficiently healthy.;Efficiently produced tofu!;Mmm! So good!;Have a meal.;You need food to live!;Have some more candy corn!;Try our new ice cups!"
	icon_state = "sustenance"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 20,
		/obj/item/weapon/reagent_containers/food/drinks/ice = 12,
		/obj/item/weapon/reagent_containers/food/snacks/candy_corn = 6,
		/obj/item/weapon/reagent_containers/food/snacks/cracker = 20,
		/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 12,
	)
	contraband = list(
		/obj/item/weapon/kitchenknife = 6,
	)
	private = TRUE
