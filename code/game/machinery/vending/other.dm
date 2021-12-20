/obj/machinery/vending/cart
	name = "PTech"
	desc = "Cartridges for PDAs."
	product_slogans = "Carts to go!"
	icon_state = "cart"
	light_color = "#dddddd"
	icon_deny = "cart-deny"
	products = list(
		/obj/item/weapon/cartridge/medical = 10,
		/obj/item/weapon/cartridge/engineering = 10,
		/obj/item/weapon/cartridge/security = 10,
		/obj/item/weapon/cartridge/janitor = 10,
		/obj/item/weapon/cartridge/signal/science = 10,
		/obj/item/device/pda/heads = 10,
		/obj/item/weapon/cartridge/captain = 3,
		/obj/item/weapon/cartridge/quartermaster = 10,
	)

/obj/machinery/vending/cigarette
	name = "Cigarette machine" //OCD had to be uppercase to look nice with the new formating
	desc = "If you want to get cancer, might as well do it in style!"
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	product_ads = "Probably not bad for you!;Don't believe the scientists!;It's good for you!;Don't quit, buy more!;Smoke!;Nicotine heaven.;Best cigarettes since 2150.;Award-winning cigs."
	vend_delay = 34
	icon_state = "cigs"
	light_color = "#dddddd"
	products = list(
		/obj/item/weapon/storage/fancy/cigarettes = 10,
		/obj/item/weapon/storage/fancy/cigarettes/menthol = 5,
		/obj/item/weapon/storage/box/matches = 10,
		/obj/item/weapon/lighter/random = 4,
		/obj/item/clothing/mask/ecig = 4,
	)
	contraband = list(
		/obj/item/weapon/lighter/zippo = 4,
	)
	premium = list(
		/obj/item/clothing/mask/cigarette/cigar/havana = 2,
	)
	syndie = list(
		/obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate = 1,
	)
	prices = list(
		/obj/item/weapon/storage/fancy/cigarettes = 20,
		/obj/item/weapon/storage/fancy/cigarettes/menthol = 30,
		/obj/item/weapon/storage/box/matches = 10,
		/obj/item/weapon/lighter/random = 15,
		/obj/item/clothing/mask/ecig = 40,
	)
	refill_canister = /obj/item/weapon/vending_refill/cigarette

/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	light_color = "#f1f8ff"
	icon_deny = "sec-deny"
	req_access = list(1)
	products = list(
		/obj/item/weapon/handcuffs = 8,
		/obj/item/weapon/grenade/flashbang = 4,
		/obj/item/device/flash = 5,
		/obj/item/weapon/storage/box/evidence = 6,
	)
	contraband = list(
		/obj/item/clothing/glasses/sunglasses = 2,
		/obj/item/device/flashlight/seclite = 4,
	)
	syndie = list(
		/obj/item/ammo_box/a357 = 1,
		/obj/item/ammo_box/magazine/m9mm = 1,
	)

/obj/machinery/vending/weirdomat
	name = "Weird-O-Mat"
	desc = "A marvel, on the brink of technobabble and pixie fiction."
	icon_state = "MagiVend"
	light_color = "#97429a"
	products = list(
		/obj/item/weapon/occult_pinpointer = 3,
		/obj/item/device/occult_scanner = 3,
		/obj/item/clothing/mask/gas/owl_mask = 3,
		/obj/item/clothing/mask/pig = 3,
		/obj/item/clothing/mask/horsehead = 3,
		/obj/item/clothing/mask/cowmask = 3,
		/obj/item/clothing/mask/chicken = 3,
		/obj/item/weapon/kitchenknife/plastic = 3,
	)
	prices = list(
		/obj/item/weapon/occult_pinpointer = 150,
		/obj/item/device/occult_scanner = 150,
		/obj/item/clothing/mask/gas/owl_mask = 100,
		/obj/item/clothing/mask/pig = 100,
		/obj/item/clothing/mask/horsehead = 100,
		/obj/item/clothing/mask/cowmask = 100,
		/obj/item/clothing/mask/chicken = 100,
		/obj/item/weapon/kitchenknife/plastic = 100,
	)
	contraband = list(
		/obj/item/weapon/nullrod = 1,
		/obj/item/weapon/kitchenknife/ritual = 1,
	)
	premium = list(
		/obj/item/clothing/glasses/gglasses = 1,
		/obj/item/toy/figure/wizard = 1,
		/obj/item/weapon/storage/fancy/crayons = 1,
	)
	product_slogans = "Amicitiae nostrae memoriam spero sempiternam fore;Aequam memento rebus in arduis servare mentem;Vitanda est improba siren desidia;Serva me, servabo te;Faber est suae quisque fortunae"
	vend_reply = "Have fun! No returns!"
	product_ads = "Occult is magic;Knowledge is magic;All the magic!;None to spook us;The dice has been cast"

/obj/machinery/vending/weirdomat/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = src.type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/ectoplasm))
		RedeemEctoplasm(I, user)
		return
	..()

/obj/machinery/vending/weirdomat/proc/RedeemEctoplasm(obj/plasm, redeemer)
	if(plasm.in_use)
		return
	plasm.in_use = TRUE
	var/selection = input(redeemer, "Pick your eternal reward", "Ectoplasm Redemption") in list("Misfortune Set", "Spiritual Bond Set", "Contract From Below", "Cryptorecorder", "Black Candle Box", "Cancel")
	if(!selection || !Adjacent(redeemer))
		plasm.in_use = FALSE
		return
	switch(selection)
		if("Misfortune Set")
			new /obj/item/weapon/storage/pill_bottle/ghostdice(loc)
		if("Spiritual Bond Set")
			new /obj/item/weapon/game_kit/chaplain(loc)
		if("Contract From Below")
			new /obj/item/weapon/pen/ghost(loc)
		if("Cryptorecorder")
			new /obj/item/device/camera/spooky(loc)
		if("Black Candle Box")
			new /obj/item/weapon/storage/fancy/black_candle_box(loc)
		if("Cancel")
			plasm.in_use = FALSE
			return
	qdel(plasm)

/obj/machinery/vending/barbervend
	name = "Fab-O-Vend"
	desc = "It would seem it vends dyes, and other stuff to make you pretty."
	icon_state = "barbervend"
	product_slogans = "Spread the colour, like butter, onto toast... Onto their hair.; Sometimes, I dream about dyes...; Paint 'em up and call me Mr. Painter.; Look brother, I'm a vendomat, I solve practical problems."
	product_ads = "Cut 'em all!; To sheds!; Hair be gone!; Prettify!; Beautify!"
	req_access = list(69)
	refill_canister = /obj/item/weapon/vending_refill/barbervend
	products = list(
		/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/white = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/red = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/green = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blue = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/black = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/brown = 10,
		/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blond = 10,
		/obj/item/weapon/reagent_containers/spray/hair_color_spray = 3,
	)
	contraband = list(
		/obj/item/weapon/razor = 1,
	)
	premium = list(
		/obj/item/weapon/scissors  = 3,
		/obj/item/weapon/reagent_containers/glass/bottle/hair_growth_accelerator = 3,
		/obj/item/weapon/storage/box/lipstick = 3,
	)

/obj/machinery/vending/dinnerware
	name = "Dinnerware"
	desc = "A kitchen and restaurant equipment vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	products = list(
		/obj/item/weapon/storage/visuals/tray = 8,
		/obj/item/weapon/kitchen/utensil/fork = 6,
		/obj/item/weapon/kitchenknife = 3,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 8,
		/obj/item/clothing/suit/chef/classic = 2,
		/obj/item/weapon/kitchen/mould/bear = 1,
		/obj/item/weapon/kitchen/mould/worm = 1,
		/obj/item/weapon/kitchen/mould/bean = 1,
		/obj/item/weapon/kitchen/mould/ball = 1,
		/obj/item/weapon/kitchen/mould/cane = 1,
		/obj/item/weapon/kitchen/mould/cash = 1,
		/obj/item/weapon/kitchen/mould/coin = 1,
		/obj/item/weapon/kitchen/mould/loli = 1,
	)
	contraband = list(
		/obj/item/weapon/kitchen/utensil/spoon = 2,
		/obj/item/weapon/kitchen/rollingpin = 2,
		/obj/item/weapon/kitchenknife/butch = 2,
	)
	syndie = list(
		/obj/item/weapon/reagent_containers/glass/bottle/alphaamanitin/syndie = 1,
	)
	refill_canister = /obj/item/weapon/vending_refill/dinnerware

/obj/machinery/vending/blood
	name = "Blood'O'Matic"
	desc = "Human blood dispenser. With internal freezer. Brought to you by EmpireV corp."
	icon_state = "blood2"
	icon_deny = "blood2-deny"
	light_color = "#ffc0c0"
	product_ads = "Go and grab some blood!;I'm hope you are not bloody vampire.;Only from nice virgins!;Natural liquids!;This stuff saves lives."
	//req_access_txt = "5"
	products = list(
		/obj/item/weapon/reagent_containers/blood/APlus = 7,
		/obj/item/weapon/reagent_containers/blood/AMinus = 4,
		/obj/item/weapon/reagent_containers/blood/BPlus = 4,
		/obj/item/weapon/reagent_containers/blood/BMinus = 2,
		/obj/item/weapon/reagent_containers/blood/OPlus = 7,
		/obj/item/weapon/reagent_containers/blood/OMinus = 4,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/stox = 10,
		/obj/item/weapon/reagent_containers/blood/empty = 10,
	)
	refill_canister = /obj/item/weapon/vending_refill/blood

//from old nanotrasen
/obj/machinery/vending/holy
	name = "HolyVend"
	desc = "Special items to prayers, sacrifices, rites and other methods to tell your God: I remember you!"
	icon_state = "holy"
	icon_hacked = "holy-hacked"
	product_slogans = "HolyVend: Select your Religion today"
	product_ads = "Pray now!;Atheists are heretic;Everything 100% Holy;Thirsty? Wanna pray? Why without candles?"
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater = 5,
		/obj/item/weapon/storage/fancy/candle_box = 20,
		/obj/item/weapon/storage/fancy/candle_box/red = 25,
		/obj/item/clothing/accessory/metal_cross = 10,
		/obj/item/clothing/accessory/bronze_cross = 10,
		/obj/item/clothing/mask/tie/silver_cross = 5,
		/obj/item/clothing/mask/tie/golden_cross = 5,
		/obj/item/clothing/shoes/jolly_gravedigger = 4,
	)
	contraband = list(
		/obj/item/weapon/nullrod = 1,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater = 40,
		/obj/item/weapon/storage/fancy/candle_box = 20,
		/obj/item/weapon/storage/fancy/candle_box/red = 20,
		/obj/item/weapon/nullrod = 400,
		/obj/item/clothing/accessory/metal_cross = 40,
		/obj/item/clothing/accessory/bronze_cross = 80,
		/obj/item/clothing/mask/tie/silver_cross = 400,
		/obj/item/clothing/mask/tie/golden_cross = 1000,
		/obj/item/clothing/shoes/jolly_gravedigger = 200,
	)
