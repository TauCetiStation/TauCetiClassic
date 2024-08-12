/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor."
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	light_color = "#34ff7b"
	icon_deny = "nutri-deny"
	products = list(
		/obj/item/nutrient/ez = 45,
		/obj/item/nutrient/l4z = 25,
		/obj/item/nutrient/rh = 15,
		/obj/item/weapon/reagent_containers/glass/bottle/mutagen = 1,
		/obj/item/weapon/pestspray = 20,
		/obj/item/weapon/reagent_containers/syringe = 5,
		/obj/item/weapon/storage/bag/plants = 5,
	)
	premium = list(
		/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/glass/bottle/mutagen = 250,
	)
	refill_canister = /obj/item/weapon/vending_refill/hydronutrients
	private = TRUE

/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	light_color = "#34ff7b"
	products = list(
		/obj/item/seeds/mtearseed = 3,
		/obj/item/seeds/shandseed = 3,
		/obj/item/seeds/ambrosiavulgarisseed = 3,
		/obj/item/seeds/appleseed = 3,
		/obj/item/seeds/bananaseed = 3,
		/obj/item/seeds/berryseed = 3,
		/obj/item/seeds/cabbageseed = 3,
		/obj/item/seeds/carrotseed = 3,
		/obj/item/seeds/cherryseed = 3,
		/obj/item/seeds/chantermycelium = 3,
		/obj/item/seeds/chiliseed = 3,
		/obj/item/seeds/cocoapodseed = 3,
		/obj/item/seeds/cornseed = 3,
		/obj/item/seeds/replicapod = 3,
		/obj/item/seeds/eggplantseed = 3,
		/obj/item/seeds/grapeseed = 3,
		/obj/item/seeds/grassseed = 3,
		/obj/item/seeds/lemonseed = 3,
		/obj/item/seeds/limeseed = 3,
		/obj/item/seeds/orangeseed = 3,
		/obj/item/seeds/plastiseed = 3,
		/obj/item/seeds/potatoseed = 3,
		/obj/item/seeds/poppyseed = 3,
		/obj/item/seeds/pumpkinseed = 3,
		/obj/item/seeds/riceseed= 3,
		/obj/item/seeds/soyaseed = 3,
		/obj/item/seeds/sunflowerseed = 3,
		/obj/item/seeds/tomatoseed = 3,
		/obj/item/seeds/towermycelium = 3,
		/obj/item/seeds/watermelonseed = 3,
		/obj/item/seeds/wheatseed = 3,
		/obj/item/seeds/whitebeetseed = 3,
		/obj/item/seeds/blackpepper = 3,
		/obj/item/seeds/sugarcaneseed = 3,
		/obj/item/seeds/chureech_nut = 3,
	)
	contraband = list(
		/obj/item/seeds/amanitamycelium = 2,
		/obj/item/seeds/glowshroom = 2,
		/obj/item/seeds/libertymycelium = 2,
		/obj/item/seeds/nettleseed = 2,
		/obj/item/seeds/reishimycelium = 2,
		/obj/item/seeds/reishimycelium = 2,
	)
	premium = list(
		/obj/item/toy/waterflower = 1,
	)
	prices = list(
		/obj/item/seeds/mtearseed = 60,
		/obj/item/seeds/shandseed = 60,
	)
	refill_canister = /obj/item/weapon/vending_refill/hydroseeds
	private = TRUE
