/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor."
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	light_color = "#34ff7b"
	icon_deny = "nutri-deny"
	products = list(
		/obj/item/nutrient/ez = 20,
		/obj/item/nutrient/l4z = 10,
		/obj/item/nutrient/rh = 5,
		/obj/item/weapon/pestspray = 5,
		/obj/item/weapon/reagent_containers/syringe = 5,
		/obj/item/weapon/storage/bag/plants = 3,
	)
	premium = list(
		/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5,
	)
	refill_canister = /obj/item/weapon/vending_refill/hydronutrients

/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	light_color = "#34ff7b"
	products = list(
		/obj/item/seeds/ambrosiavulgarisseed = 1,
		/obj/item/seeds/appleseed = 1,
		/obj/item/seeds/bananaseed = 1,
		/obj/item/seeds/berryseed = 1,
		/obj/item/seeds/cabbageseed = 1,
		/obj/item/seeds/carrotseed = 1,
		/obj/item/seeds/cherryseed = 1,
		/obj/item/seeds/chantermycelium = 1,
		/obj/item/seeds/chiliseed = 1,
		/obj/item/seeds/cocoapodseed = 1,
		/obj/item/seeds/cornseed = 1,
		/obj/item/seeds/replicapod = 1,
		/obj/item/seeds/eggplantseed = 1,
		/obj/item/seeds/grapeseed = 1,
		/obj/item/seeds/grassseed = 1,
		/obj/item/seeds/lemonseed = 1,
		/obj/item/seeds/limeseed = 1,
		/obj/item/seeds/orangeseed = 1,
		/obj/item/seeds/plastiseed = 1,
		/obj/item/seeds/potatoseed = 1,
		/obj/item/seeds/poppyseed = 1,
		/obj/item/seeds/pumpkinseed = 1,
		/obj/item/seeds/riceseed= 1,
		/obj/item/seeds/soyaseed = 1,
		/obj/item/seeds/sunflowerseed = 1,
		/obj/item/seeds/tomatoseed = 1,
		/obj/item/seeds/towermycelium = 1,
		/obj/item/seeds/watermelonseed = 1,
		/obj/item/seeds/wheatseed = 1,
		/obj/item/seeds/whitebeetseed = 1,
		/obj/item/seeds/blackpepper = 3,
		/obj/item/seeds/sugarcaneseed = 1,
	)
	contraband = list(
		/obj/item/seeds/amanitamycelium = 2,
		/obj/item/seeds/glowshroom = 2,
		/obj/item/seeds/libertymycelium = 2,
		/obj/item/seeds/mtearseed = 2,
		/obj/item/seeds/nettleseed = 2,
		/obj/item/seeds/reishimycelium = 2,
		/obj/item/seeds/reishimycelium = 2,
		/obj/item/seeds/shandseed = 2,
	)
	premium = list(
		/obj/item/toy/waterflower = 1,
	)
	refill_canister = /obj/item/weapon/vending_refill/hydroseeds
