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
	private = TRUE

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
		/obj/item/weapon/storage/fancy/cigarettes/dromedaryco = 1,
	)
	premium = list(
		/obj/item/clothing/mask/cigarette/cigar = 2,
		/obj/item/clothing/mask/cigarette/cigar/havana = 1,
		/obj/item/clothing/mask/cigarette/cigar/cohiba = 1,
		/obj/item/clothing/mask/cigarette/pipe = 1,
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
	private = FALSE

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
		/obj/item/ammo_box/magazine/glock/extended/rubber = 5,
		/obj/item/ammo_box/magazine/glock/rubber = 10,
	)
	contraband = list(
		/obj/item/clothing/glasses/sunglasses = 2,
		/obj/item/device/flashlight/seclite = 4,
	)
	syndie = list(
		/obj/item/ammo_box/speedloader/a357 = 1,
		/obj/item/ammo_box/magazine/stechkin = 1,
	)
	prices = list(
		/obj/item/ammo_box/magazine/glock/extended/rubber = 200,
		/obj/item/ammo_box/magazine/glock/rubber = 50,
	)
	private = TRUE

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
		/obj/item/clothing/mask/balaclava/richard = 1,
		/obj/item/clothing/mask/balaclava/don_juan = 1,
		/obj/item/clothing/mask/balaclava/rasmus = 1,
	)
	product_slogans = "Amicitiae nostrae memoriam spero sempiternam fore;Aequam memento rebus in arduis servare mentem;Vitanda est improba siren desidia;Serva me, servabo te;Faber est suae quisque fortunae"
	vend_reply = "Have fun! No returns!"
	product_ads = "Occult is magic;Knowledge is magic;All the magic!;None to spook us;The dice has been cast"
	private = TRUE

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
			new /obj/item/device/camera/polar/spooky(loc)
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
	private = TRUE

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
		/obj/item/clothing/suit/chef_classic = 2,
		/obj/item/clothing/suit/chef = 1,
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
		/obj/item/clothing/under/rank/chef/sushi = 1,
		/obj/item/clothing/head/sushi_band = 1,
		/obj/item/weapon/kitchen/utensil/spoon = 2,
		/obj/item/weapon/kitchen/rollingpin = 2,
		/obj/item/weapon/kitchenknife/butch = 2,		
	)
	syndie = list(
		/obj/item/weapon/reagent_containers/glass/bottle/alphaamanitin/syndie = 1,
	)
	refill_canister = /obj/item/weapon/vending_refill/dinnerware
	private = TRUE

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
	private = TRUE

/obj/machinery/vending/syndi
	name = "KillNTVend"
	desc = "Special items for killers, mercenaries, pirrrates and other syndicate workers. Waffle.co property."
	icon_state = "syndivend"
	icon_deny = "syndivend-deny"
	req_access = list(access_syndicate)
	density = TRUE
	anchored = TRUE
	product_ads = "Kill the corporate bastards!; Kill captain and gutted his corpse!; Blow up the damn station!."
	products = list(
		/obj/item/weapon/storage/pouch/ammo = 6,
		/obj/item/clothing/accessory/holster/armpit = 6,
		/obj/item/device/hud_calibrator = 6,
		/obj/item/weapon/storage/backpack/dufflebag = 3,
		/obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate = 2,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/cyanide = 20,
	)
	syndie = list(
		/obj/item/toy/syndicateballoon = 6,
	)
	var/list/kits = list(
		"Scout kit" = /obj/item/weapon/storage/backpack/dufflebag/nuke/scout,
		"Sniper kit" = /obj/item/weapon/storage/backpack/dufflebag/nuke/sniper,
		"Assaultman kit" = /obj/item/weapon/storage/backpack/dufflebag/nuke/assaultman,
		"Bomber kit" = /obj/item/weapon/storage/backpack/dufflebag/nuke/demo,
		"Melee kit" = /obj/item/weapon/storage/backpack/dufflebag/nuke/melee,
		"Hacker kit" = /obj/item/weapon/storage/backpack/dufflebag/nuke/hacker,
		"Machinengunner kit" = /obj/item/weapon/storage/backpack/dufflebag/nuke/heavygunner,
		"Field Medic kit" = /obj/item/weapon/storage/backpack/dufflebag/nuke/medic,
		"Chemical Fighter Kit" = /obj/item/weapon/storage/backpack/dufflebag/nuke/chemwarfare,
		"Custom kit" =  /obj/item/weapon/storage/backpack/dufflebag/nuke/custom,
	)
	var/static/list/selections_kits

	var/list/armor_kits = list(
		"Hybrid suit" = /obj/item/weapon/storage/box/syndie_kit/rig,
		"Heavy hybrid suit" = /obj/item/weapon/storage/box/syndie_kit/heavy_rig,
		"Assault Armor" = /obj/item/weapon/storage/box/syndie_kit/armor,
	)

	var/static/list/selections_armor
	private = TRUE

/obj/machinery/vending/syndi/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mining_voucher/kit))
		givekit(I, user)
		return
	if(istype(I, /obj/item/weapon/mining_voucher/armour))
		givearmor(I, user)
	return ..()

/obj/machinery/vending/syndi/proc/kitpopulate_selection()
	selections_kits = list(
	"Scout kit" = image(icon = 'icons/obj/gun.dmi', icon_state = "c20r"),
	"Sniper kit" = image(icon = 'icons/obj/gun.dmi', icon_state = "heavyrifle"),
	"Assaultman kit" = image(icon = 'icons/obj/gun.dmi', icon_state = "a74"),
	"Bomber kit" = image(icon = 'icons/obj/gun.dmi', icon_state = "drozd"),
	"Melee kit" = image(icon = 'icons/obj/weapons.dmi', icon_state = "dualsaberred1"),
	"Hacker kit" = image(icon = 'icons/obj/gun.dmi', icon_state = "bulldog"),
	"Machinengunner kit" = image(icon = 'icons/obj/gun.dmi', icon_state = "l6closed100"),
	"Field Medic kit" = image(icon = 'icons/obj/gun.dmi', icon_state = "medigun_syndi"),
	"Chemical Fighter Kit" = image(icon = 'icons/obj/hydroponics/equipment.dmi', icon_state = "misternuke"),
	"Custom kit" = image(icon = 'icons/obj/radio.dmi', icon_state = "radio"),
	)

/obj/machinery/vending/syndi/proc/armourpopulate_selection()
	selections_armor = list(
		"Hybrid suit" = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "rig-syndie-combat"),
		"Heavy hybrid suit" = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "rig-heavy-combat"),
		"Assault Armor" = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "assaultarmor"),
	)

/obj/machinery/vending/syndi/proc/givekit(obj/voucher, mob/user)
	var/selection = show_radial_menu(user, src, selections_kits, require_near = TRUE, tooltips = TRUE)
	if(voucher.in_use)
		return
	if(!selections_kits)
		kitpopulate_selection()
	if(!selection || !Adjacent(user))
		return
	voucher.in_use = TRUE
	var/bought_type = kits[selection]
	var/obj/item/bought = new bought_type(loc)
	if(ishuman(user))
		var/mob/living/carbon/human/A = user
		A.put_in_any_hand_if_possible(bought)
	qdel(voucher)

	for(var/role in user.mind.antag_roles)
		var/datum/role/R = user.mind.antag_roles[role]
		var/datum/component/gamemode/syndicate/S = R.GetComponent(/datum/component/gamemode/syndicate)
		if(!S)
			continue
		if(istype(R, /datum/role/operative))
			R.faction.faction_scoreboard_data += {"[bought.name] for 1 voucher."}
		else
			S.uplink_items_bought += {"[bought.name] for 1 voucher."}

		var/datum/stat/uplink_purchase/stat = new
		stat.bundlename = bought.name
		stat.cost = 1
		S.uplink_purchases += stat

/obj/machinery/vending/syndi/proc/givearmor(obj/voucher, mob/user)
	var/selection = show_radial_menu(user, src, selections_armor, require_near = TRUE, tooltips = TRUE)
	if(voucher.in_use)
		return
	if(!selections_armor)
		armourpopulate_selection()
	if(!selection || !Adjacent(user))
		return
	voucher.in_use = TRUE
	var/bought_type = armor_kits[selection]
	var/obj/item/bought = new bought_type(loc)
	if(ishuman(user))
		var/mob/living/carbon/human/A = user
		A.put_in_any_hand_if_possible(bought)
	qdel(voucher)

	for(var/role in user.mind.antag_roles)
		var/datum/role/R = user.mind.antag_roles[role]
		var/datum/component/gamemode/syndicate/S = R.GetComponent(/datum/component/gamemode/syndicate)
		if(!S)
			continue
		if(istype(R, /datum/role/operative))
			R.faction.faction_scoreboard_data += {"[bought.name] for 1 voucher."}
		else
			S.uplink_items_bought += {"[bought.name] for 1 voucher."}

		var/datum/stat/uplink_purchase/stat = new
		stat.bundlename = bought.name
		stat.cost = 1
		S.uplink_purchases += stat

/obj/machinery/vending/syndi/ex_act()
	return

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
	private = TRUE
