//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

var/global/list/all_supply_groups = list("Operations","Weapons / Ammo","Security Stuff","Hospitality","Engineering","Medical / Science","Hydroponics","Mining","Supply","Miscellaneous")

/datum/supply_pack
	var/name = "Crate"
	var/group = "Operations"
	var/hidden = FALSE
	var/contraband = FALSE
	var/access = access_cargo
	var/list/contains = null
	var/crate_name = "crate"
	var/crate_type = /obj/structure/closet/crate/secure/woodseccrate/cargo_general
	var/general_crate = FALSE // all contents will go into a large crate
	var/dangerous = FALSE // Should we message admins?
	var/special = FALSE //Event/Station Goals/Admin enabled packs
	var/special_enabled = FALSE
	var/sheet_amount = 0

	// Is calculated dynamically based on: crate type, contents, overprice and additional_costs.
	var/cost = 0

	// Multiplier to calculated cost. Represents how much worse we want cargo to feel when importing packs compared to when exporting them.
	var/overprice = CARGO_DEFAULT_OVERPRICE
	// Additional costs to make the market imbalanced and create interesting choices for the Cargonians. "Represents" the "cost" of transporting/packaging/bundling items in the pack for those more lore-minded.
	var/additional_costs = 0.0

/datum/supply_pack/New()
	all_supply_pack += src
	calculate_cost()

/datum/supply_pack/proc/calculate_cost()
	var/static/list/crate_type2cost = list(
		/obj/structure/closet/crate = CARGO_CRATE_COST,
		/obj/structure/closet/crate/large = CARGO_CRATE_COST / 5,
	)

	var/supply_min_cost = 5
	if(!general_crate)
		supply_min_cost += CARGO_CRATE_COST
	if(crate_type2cost[crate_type])
		supply_min_cost = crate_type2cost[crate_type]

	var/contents_cost = 0.0
	for(var/item_type in contains)
		for(var/datum/export/E in global.exports_list)
			if(E.applies_to_type(item_type))
				var/amount = 1
				if(sheet_amount > 0 && (ispath(item_type, /obj/item/stack/sheet) || ispath(item_type, /obj/item/stack/tile)))
					amount = sheet_amount
				contents_cost += E.get_type_cost(item_type, amount)

	cost = max(5, round(supply_min_cost + contents_cost * overprice + additional_costs))

/datum/supply_pack/proc/generate(turf/T)
	var/obj/structure/closet/crate/C = new crate_type(T)
	C.name = crate_name
	if(istype(C, /obj/structure/closet/crate/secure) && access)
		C.req_access = list(access)

	fill(C)

	return C

/datum/supply_pack/proc/fill(obj/structure/closet/crate/C)
	for(var/item in contains)
		var/n_item = new item(C)
		if(sheet_amount > 0 && (istype(n_item, /obj/item/stack/sheet) || istype(n_item, /obj/item/stack/tile)))
			var/obj/item/stack/sheet/n_sheet = n_item
			n_sheet.set_amount(sheet_amount)

//----------------------------------------------
//-----------------OPERATIONS-------------------
//----------------------------------------------

/datum/supply_pack/mule
	name = "MULEbot Crate"
	contains = list(/obj/machinery/bot/mulebot)
	general_crate = FALSE
	crate_type = /obj/structure/largecrate/mule
	crate_name = "MULEbot Crate"
	group = "Operations"

/datum/supply_pack/artscrafts
	name = "Arts and Crafts supplies"
	contains = list(/obj/item/weapon/storage/fancy/crayons,
					/obj/item/device/camera,
					/obj/item/weapon/storage/box/box_lenses,
					/obj/item/weapon/storage/photo_album,
					/obj/item/weapon/reagent_containers/glass/paint/red,
					/obj/item/weapon/reagent_containers/glass/paint/green,
					/obj/item/weapon/reagent_containers/glass/paint/blue,
					/obj/item/weapon/reagent_containers/glass/paint/yellow,
					/obj/item/weapon/reagent_containers/glass/paint/violet,
					/obj/item/weapon/reagent_containers/glass/paint/black,
					/obj/item/weapon/reagent_containers/glass/paint/white,
					/obj/item/weapon/reagent_containers/glass/paint/remover,
					/obj/item/toy/crayon/spraycan)
	additional_costs = 50
	general_crate = TRUE
	group = "Operations"

/datum/supply_pack/price_scanner
	name = "Export scanner"
	contains = list(/obj/item/device/export_scanner,
	/obj/item/device/export_scanner,
	/obj/item/device/export_scanner)
	crate_name = "Export scanners crate"
	general_crate = TRUE
	group = "Operations"

//----------------------------------------------
//-----------------GUNS && AMMO-----------------
//----------------------------------------------

/datum/supply_pack/specialops
	name = "Special Ops supplies"
	contains = list(/obj/item/weapon/storage/box/emps,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/storage/box/syndie_kit/chameleon,
					/obj/item/weapon/storage/toolbox/syndicate,
					/obj/item/weapon/storage/box/syndie_kit/posters)
	additional_costs = 500
	crate_name = "Special Ops crate"
	group = "Weapons / Ammo"
	hidden = TRUE
	general_crate = FALSE

/datum/supply_pack/energy/ion_rifle
	name = "Ion rifle"
	contains = list(/obj/item/weapon/gun/energy/ionrifle)
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/energy/energy_gun
	name = "Energy gun"
	contains = list(/obj/item/weapon/gun/energy/gun)
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/energy
	name = "Laser rifle"
	contains = list(/obj/item/weapon/gun/energy/laser)
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/energy/sniperrifle
	name = "Sniper rifle"
	contains = list(/obj/item/weapon/gun/energy/sniperrifle)
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/smg
	name = ".38 SMG"
	contains = list(/obj/item/weapon/gun/projectile/automatic/l13)
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/smg_magazines
	name = ".38 magazines"
	contains = list(/obj/item/ammo_box/magazine/l13/lethal,
					/obj/item/ammo_box/magazine/l13/lethal,
					/obj/item/ammo_box/magazine/l13/lethal)
	additional_costs = 250
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/smg_magazine_rubber
	name = ".38 magazines (rubber)"
	contains = list(/obj/item/ammo_box/magazine/l13,
					/obj/item/ammo_box/magazine/l13,
					/obj/item/ammo_box/magazine/l13)
	additional_costs = 100
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/pistol
	name = "9mm pistol"
	contains = list(/obj/item/weapon/gun/projectile/automatic/pistol/glock)
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/pistol_magazines
	name = "9mm magazines"
	contains = list(/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock)
	additional_costs = 150
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/pistol_magazines_rubber
	name = "9mm magazines (rubber)"
	contains = list(/obj/item/ammo_box/magazine/glock/rubber,
					/obj/item/ammo_box/magazine/glock/rubber,
					/obj/item/ammo_box/magazine/glock/rubber,
					/obj/item/ammo_box/magazine/glock/rubber,
					/obj/item/ammo_box/magazine/glock/rubber,
					/obj/item/ammo_box/magazine/glock/rubber)
	additional_costs = 25
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic
	name = "Shotgun"
	contains = list(
					/obj/item/weapon/gun/projectile/shotgun)
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/shotgunammo_nonlethal
	name = "Shotgun shells (non-lethal)"
	contains = list(/obj/item/ammo_box/eight_shells/beanbag,
					/obj/item/ammo_box/eight_shells/beanbag,
					/obj/item/ammo_box/eight_shells/beanbag,
					/obj/item/ammo_box/eight_shells/stunshot,
					/obj/item/ammo_box/eight_shells/stunshot,
					/obj/item/ammo_box/eight_shells/stunshot)
	additional_costs = 150
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/shotgunammo_slug
	name = "Shotgun shells (slug)"
	contains = list(/obj/item/ammo_box/eight_shells,
					/obj/item/ammo_box/eight_shells,
					/obj/item/ammo_box/eight_shells)
	additional_costs = 150
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/shotgunammo_buckshot
	name = "Shotgun shells (buckshot)"
	contains = list(/obj/item/ammo_box/eight_shells/buckshot,
					/obj/item/ammo_box/eight_shells/buckshot,
					/obj/item/ammo_box/eight_shells/buckshot)
	additional_costs = 150
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/shotgunammo_incendiary
	name = "Shotgun shells (incendiary)"
	contains = list(/obj/item/ammo_box/eight_shells/incendiary,
					/obj/item/ammo_box/eight_shells/incendiary,
					/obj/item/ammo_box/eight_shells/incendiary,)
	additional_costs = 150
	hidden = TRUE
	general_crate = TRUE
	group = "Weapons / Ammo"

/datum/supply_pack/ballistic/m79
	name = "M79 grenade launcher"
	contains = list(/obj/item/weapon/gun/projectile/grenade_launcher/m79)
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/ballistic/r4046
	name = "40x46mm rubber grenades"
	contains = list(/obj/item/weapon/storage/box/r4046/rubber)
	additional_costs = 100
	group = "Weapons / Ammo"
	general_crate = TRUE

/datum/supply_pack/shockmines
	name = "Shock Mines"
	contains = list(/obj/item/weapon/storage/box/mines/shock)
	group = "Weapons / Ammo"
	additional_costs = 200
	general_crate = TRUE

//----------------------------------------------
//-----------------SECURITY STUFF---------------
//----------------------------------------------

/datum/supply_pack/armor
	name = "Security armor"
	contains = list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/suit/storage/flak)
	group = "Security Stuff"
	general_crate = TRUE

/datum/supply_pack/bulletproof_armor
	name = "Bulletproof armor"
	contains = list(/obj/item/clothing/head/helmet/bulletproof,
					/obj/item/clothing/suit/storage/flak/bulletproof)
	group = "Security Stuff"
	general_crate = TRUE

/datum/supply_pack/laser_armor
	name = "Ablative armor"
	contains = list(/obj/item/clothing/head/helmet/laserproof,
					/obj/item/clothing/suit/armor/laserproof)
	group = "Security Stuff"
	general_crate = TRUE

/datum/supply_pack/riot_gear
	name = "Riot gear crate"
	contains = list(/obj/item/weapon/melee/baton,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/weapon/shield/riot)
	group = "Security Stuff"
	general_crate = TRUE

/datum/supply_pack/mind_shields
	name = "Mind shields implants"
	contains = list (/obj/item/weapon/storage/lockbox/mind_shields)
	additional_costs = 100
	group = "Security Stuff"
	general_crate = TRUE

/datum/supply_pack/loyalty
	name = "Loyalty implants"
	contains = list (/obj/item/weapon/storage/lockbox/loyalty)
	additional_costs = 200
	group = "Security Stuff"
	general_crate = TRUE

/datum/supply_pack/investigation
	name = "Investigation gear"
	contains = list(/obj/item/weapon/autopsy_scanner,
					/obj/item/weapon/scalpel,
					/obj/item/device/detective_scanner,
					/obj/item/device/taperecorder,
					/obj/item/weapon/storage/box/evidence
					)
	additional_costs = 100
	general_crate = TRUE
	group = "Security Stuff"

/datum/supply_pack/securitybarriers
	name = "Security barriers crate"
	contains = list(/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier)
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "Security barrier crate"
	general_crate = FALSE
	group = "Security Stuff"

/datum/supply_pack/securitywallshield
	name = "Wall shield Generators"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	additional_costs = 260
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "wall shield generators crate"
	general_crate = FALSE
	group = "Security Stuff"


//----------------------------------------------
//-----------------HOSPITALITY------------------
//----------------------------------------------

/datum/supply_pack/vending_bar
	name = "Bartending supply crate"
	contains = list(/obj/item/weapon/vending_refill/boozeomat,
					/obj/item/weapon/vending_refill/boozeomat,
					/obj/item/weapon/vending_refill/boozeomat)
	additional_costs = 5800
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_coffee
	name = "Hotdrinks supply crate"
	contains = list(/obj/item/weapon/vending_refill/coffee,
					/obj/item/weapon/vending_refill/coffee,
					/obj/item/weapon/vending_refill/coffee)
	additional_costs = 1630
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_snack
	name = "Snack supply crate"
	contains = list(/obj/item/weapon/vending_refill/snack,
					/obj/item/weapon/vending_refill/snack,
					/obj/item/weapon/vending_refill/snack)
	additional_costs = 1690
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_cola
	name = "Softdrinks supply crate"
	contains = list(/obj/item/weapon/vending_refill/cola,
					/obj/item/weapon/vending_refill/cola,
					/obj/item/weapon/vending_refill/cola)
	additional_costs = 730
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_cigarette
	name = "Cigarette supply crate"
	contains = list(/obj/item/weapon/vending_refill/cigarette,
					/obj/item/weapon/vending_refill/cigarette,
					/obj/item/weapon/vending_refill/cigarette)
	additional_costs = 1170
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_barber
	name = "Barbershop supply crate"
	contains = list(/obj/item/weapon/vending_refill/barbervend,
					/obj/item/weapon/vending_refill/barbervend,
					/obj/item/weapon/vending_refill/barbervend)
	additional_costs = 4500
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_clothing
	name = "ClothesMate supply crate"
	contains = list(/obj/item/weapon/vending_refill/clothing,
					/obj/item/weapon/vending_refill/clothing,
					/obj/item/weapon/vending_refill/clothing)
	additional_costs = 8900
	group = "Hospitality"

/datum/supply_pack/vending_hydroseeds
	name = "MegaSeed supply crate"
	contains = list(/obj/item/weapon/vending_refill/hydroseeds,
					/obj/item/weapon/vending_refill/hydroseeds,
					/obj/item/weapon/vending_refill/hydroseeds)
	additional_costs = 4200
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_hydronutrients
	name = "NutriMax supply crate"
	contains = list(/obj/item/weapon/vending_refill/hydronutrients,
					/obj/item/weapon/vending_refill/hydronutrients,
					/obj/item/weapon/vending_refill/hydronutrients)
	additional_costs = 5700
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_medical
	name = "NanoMed Plus supply crate"
	contains = list(/obj/item/weapon/vending_refill/medical,
					/obj/item/weapon/vending_refill/medical,
					/obj/item/weapon/vending_refill/medical)
	additional_costs = 3100
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_chinese
	name = "Mr. Chang supply crate"
	contains = list(/obj/item/weapon/vending_refill/chinese,
					/obj/item/weapon/vending_refill/chinese,
					/obj/item/weapon/vending_refill/chinese)
	additional_costs = 1270
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_tool
	name = "YouTool supply crate"
	contains = list(/obj/item/weapon/vending_refill/tool,
					/obj/item/weapon/vending_refill/tool,
					/obj/item/weapon/vending_refill/tool)
	additional_costs = 2100
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_engivend
	name = "Engi-Vend supply crate"
	contains = list(/obj/item/weapon/vending_refill/engivend,
					/obj/item/weapon/vending_refill/engivend,
					/obj/item/weapon/vending_refill/engivend)
	additional_costs = 2500
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_blood
	name = "Blood'O'Matic supply crate"
	contains = list(/obj/item/weapon/vending_refill/blood,
					/obj/item/weapon/vending_refill/blood,
					/obj/item/weapon/vending_refill/blood)
	additional_costs = 6900
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_junkfood
	name = "Fast Food supply crate"
	contains = list(/obj/item/weapon/vending_refill/junkfood,
					/obj/item/weapon/vending_refill/junkfood,
					/obj/item/weapon/vending_refill/junkfood)
	additional_costs = 780
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_donut
	name = "Monkin' Donuts supply crate"
	contains = list(/obj/item/weapon/vending_refill/donut,
					/obj/item/weapon/vending_refill/donut,
					/obj/item/weapon/vending_refill/donut)
	additional_costs = 590
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/vending_assist
	name = "Vendomat supply crate"
	contains = list(/obj/item/weapon/vending_refill/assist,
					/obj/item/weapon/vending_refill/assist,
					/obj/item/weapon/vending_refill/assist)
	additional_costs = 700
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/kvasstank
	name = "Kvass tank crate"
	contains = list(/obj/structure/reagent_dispensers/kvasstank)
	crate_type = /obj/structure/largecrate
	general_crate = FALSE
	crate_name = "Kvass tank crate"
	group = "Hospitality"

/datum/supply_pack/vending_dinnerware
	name = "Dinnerware supply crate"
	contains = list(/obj/item/weapon/vending_refill/dinnerware,
					/obj/item/weapon/vending_refill/dinnerware,
					/obj/item/weapon/vending_refill/dinnerware)
	additional_costs = 3800
	group = "Hospitality"
	general_crate = TRUE

/datum/supply_pack/party
	name = "Party equipment"
	contains = list(/obj/item/weapon/storage/box/drinkingglasses,
					/obj/item/weapon/reagent_containers/food/drinks/shaker,
					/obj/item/weapon/reagent_containers/food/drinks/flask/barflask,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/patron,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
					/obj/item/weapon/lipstick/random,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/ale,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/ale,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/beer)
	additional_costs = 250
	general_crate = FALSE
	group = "Hospitality"

//----------------------------------------------
//-----------------ENGINEERING------------------
//----------------------------------------------

/datum/supply_pack/space_gear
	name = "Space gear"
	contains = list(/obj/item/clothing/suit/space/cheap,
					/obj/item/clothing/head/helmet/space/cheap,
					/obj/item/clothing/shoes/magboots,
					/obj/item/clothing/mask/gas/coloured,
					/obj/item/weapon/tank/air)
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/sleeping_agent
	name = "Canister: \[N2O\]"
	contains = list(/obj/machinery/portable_atmospherics/canister/sleeping_agent)
	additional_costs = 100
	crate_type = /obj/structure/largecrate
	general_crate = FALSE
	crate_name = "N2O crate"
	group = "Engineering"

/datum/supply_pack/oxygen
	name = "Canister: \[O2\]"
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	additional_costs = 100
	crate_type = /obj/structure/largecrate
	general_crate = FALSE
	crate_name = "O2 crate"
	group = "Engineering"

/datum/supply_pack/nitrogen
	name = "Canister: \[N2\]"
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	additional_costs = 100
	crate_type = /obj/structure/largecrate
	general_crate = FALSE
	crate_name = "N2 crate"
	group = "Engineering"

/datum/supply_pack/air
	name = "Canister \[Air\]"
	contains = list(/obj/machinery/portable_atmospherics/canister/air)
	additional_costs = 100
	crate_type = /obj/structure/largecrate
	general_crate = FALSE
	crate_name = "Air crate"
	group = "Engineering"

/datum/supply_pack/inflatable
	name = "Inflatable barriers"
	contains = list(/obj/item/weapon/storage/briefcase/inflatable,)
	additional_costs = 50
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/metal50
	name = "50 metal sheets"
	contains = list(/obj/item/stack/sheet/metal)
	sheet_amount = 50
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/glass50
	name = "50 glass sheets"
	contains = list(/obj/item/stack/sheet/glass)
	sheet_amount = 50
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/wood50
	name = "50 wooden planks"
	contains = list(/obj/item/stack/sheet/wood)
	sheet_amount = 50
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/carpets
	name = "Random carpets"
	contains = list(/obj/item/stack/tile/carpet, /obj/item/stack/tile/carpet/black, /obj/item/stack/tile/carpet/purple, /obj/item/stack/tile/carpet/orange, /obj/item/stack/tile/carpet/green,
					/obj/item/stack/tile/carpet/blue, /obj/item/stack/tile/carpet/blue2, /obj/item/stack/tile/carpet/red, /obj/item/stack/tile/carpet/cyan
	)
	sheet_amount = 50
	group = "Engineering"
	general_crate = TRUE
	var/num_contained = 2 // 4 random carpets per crate

/datum/supply_pack/carpets/fill(obj/structure/closet/crate/C)
	var/list/L = contains.Copy()
	var/item
	if(num_contained <= L.len)
		for(var/i in 1 to num_contained)
			item = pick_n_take(L)
			var/n_item = new item(C)
			if(istype(n_item, /obj/item/stack/tile))
				var/obj/item/stack/sheet/n_sheet = n_item
				n_sheet.set_amount(sheet_amount)
	else
		for(var/i in 1 to num_contained)
			item = pick(L)
			var/n_item = new item(C)
			if(istype(n_item, /obj/item/stack/tile))
				var/obj/item/stack/sheet/n_sheet = n_item
				n_sheet.set_amount(sheet_amount)

/datum/supply_pack/insulated_gloves
	name = "Insulated gloves"
	contains = list(/obj/item/clothing/gloves/insulated,
					/obj/item/clothing/gloves/insulated,
					/obj/item/clothing/gloves/insulated)
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/cells
	name = "Power cells"
	contains = list(/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high)
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/fueltank
	name = "Fuel tank crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	crate_type = /obj/structure/largecrate
	crate_name = "fuel tank crate"
	general_crate = FALSE
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/aqueous_foam_tank
	name = "AFFF crate"
	contains = list(/obj/structure/reagent_dispensers/aqueous_foam_tank)
	crate_type = /obj/structure/largecrate
	crate_name = "AFFF crate"
	general_crate = FALSE
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/solar
	name = "Solar Pack crate"
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly, // 21 Solar Assemblies. 1 Extra for the controller,
					/obj/item/weapon/circuitboard/solar_control,
					/obj/item/weapon/tracker_electronics,
					/obj/item/weapon/paper/solar)
	crate_type = /obj/structure/closet/crate/engi
	crate_name = "Solar pack crate"
	group = "Engineering"
	general_crate = FALSE

/datum/supply_pack/engine
	name = "Emitter crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	crate_type = /obj/structure/closet/crate/secure/large
	crate_name = "Emitter crate"
	general_crate = FALSE
	group = "Engineering"

/datum/supply_pack/engine/field_gen
	name = "Field Generator crate"
	contains = list(/obj/machinery/field_generator,
					/obj/machinery/field_generator)
	crate_type = /obj/structure/closet/crate/secure/large
	crate_name = "Field Generator crate"
	general_crate = FALSE

/datum/supply_pack/engine/sing_gen
	name = "Singularity Generator crate"
	contains = list(/obj/machinery/the_singularitygen)
	crate_type = /obj/structure/closet/crate/secure/large
	general_crate = FALSE
	crate_name = "Singularity Generator crate"

/datum/supply_pack/engine/tesla_gen
	name = "Energy Ball Generator crate"
	contains = list(/obj/machinery/the_singularitygen/tesla)
	crate_type = /obj/structure/closet/crate/secure/large
	general_crate = FALSE
	crate_name = "Energy Ball Generator crate"

/datum/supply_pack/engine/collector
	name = "Collector crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	crate_type = /obj/structure/closet/crate/secure/large
	general_crate = FALSE
	crate_name = "Collector crate"

/datum/supply_pack/engine/ground_rod
	name = "Grounding Rod crate"
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	crate_type = /obj/structure/closet/crate/secure/large
	general_crate = FALSE
	crate_name = "Grounding Rod crate"

/datum/supply_pack/engine/tesla_coil
	name = "Tesla Coil crate"
	contains = list(/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil)
	crate_type = /obj/structure/closet/crate/secure/large
	general_crate = FALSE
	crate_name = "Tesla Coil crate"

/datum/supply_pack/engine/PA
	name = "Particle Accelerator crate"
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	crate_type = /obj/structure/closet/crate/secure/large
	general_crate = FALSE
	crate_name = "Particle Accelerator crate"

/datum/supply_pack/shield_gen
	contains = list(/obj/item/weapon/circuitboard/shield_gen)
	name = "Bubble shield generator circuitry"
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/shield_gen_ex
	contains = list(/obj/item/weapon/circuitboard/shield_gen_ex)
	name = "Hull shield generator circuitry"
	additional_costs = 250
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/shield_cap
	contains = list(/obj/item/weapon/circuitboard/shield_cap)
	name = "Bubble shield capacitor circuitry"
	additional_costs = 250
	group = "Engineering"
	general_crate = TRUE

/datum/supply_pack/smbig
	name = "Supermatter Core"
	contains = list(/obj/machinery/power/supermatter)
	crate_type = /obj/structure/closet/crate/secure/woodseccrate
	crate_name = "Supermatter crate (CAUTION)"
	group = "Engineering"
	general_crate = FALSE
	access = access_ce

/datum/supply_pack/teg
	contains = list(/obj/machinery/power/generator)
	name = "Mark I Thermoelectric Generator"
	crate_type = /obj/structure/closet/crate/secure/large
	crate_name = "Mk1 TEG crate"
	group = "Engineering"
	general_crate = FALSE

/datum/supply_pack/circulator
	contains = list(/obj/machinery/atmospherics/components/binary/circulator,
					/obj/machinery/atmospherics/components/binary/circulator)
	name = "Binary atmospheric circulator"
	crate_type = /obj/structure/closet/crate/secure/large
	crate_name = "Atmospheric circulator crate"
	group = "Engineering"
	additional_costs = 300
	general_crate = FALSE

/datum/supply_pack/air_dispenser
	contains = list(/obj/machinery/pipedispenser/orderable)
	name = "Pipe Dispenser"
	crate_type = /obj/structure/closet/crate/secure/large
	crate_name = "Pipe Dispenser Crate"
	group = "Engineering"
	general_crate = FALSE

/datum/supply_pack/disposals_dispenser
	contains = list(/obj/machinery/pipedispenser/disposal/orderable)
	name = "Disposals Pipe Dispenser"
	crate_type = /obj/structure/closet/crate/secure/large
	crate_name = "Disposal Dispenser Crate"
	group = "Engineering"
	general_crate = FALSE

/datum/supply_pack/anti_singulo
	name = "Singularity Buster Rockets crate"
	contains  = list(/obj/item/ammo_casing/caseless/rocket/anti_singulo,
					/obj/item/ammo_casing/caseless/rocket/anti_singulo,
					/obj/item/ammo_casing/caseless/rocket/anti_singulo,
					/obj/item/ammo_casing/caseless/rocket/anti_singulo)
	additional_costs = 150
	group = "Engineering"
	general_crate = TRUE

//----------------------------------------------
//------------MEDICAL / SCIENCE-----------------
//----------------------------------------------

/datum/supply_pack/bonebreaker
	name = "BB EX-01 crate"
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/bonebreaker)
	cost = 1000
	crate_name = "BB EX-01 crate"
	group = "Medical / Science"
	hidden = TRUE
	general_crate = FALSE

/datum/supply_pack/medical
	name = "First-aids crate"
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/adv)
	additional_costs = 150
	group = "Medical / Science"
	general_crate = TRUE

/datum/supply_pack/med_injectors
	name = "Space First-Aid kit"
	contains = list(/obj/item/weapon/storage/firstaid/small_firstaid_kit/space)
	additional_costs = 100
	group = "Medical / Science"
	general_crate = TRUE

/datum/supply_pack/civ_medkit
	name = "Civilian medkits"
	contains = list(/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian)
	additional_costs = 100
	group = "Medical / Science"
	general_crate = TRUE

/datum/supply_pack/virus
	name = "Virus sample"
	contains = list(/obj/item/weapon/virusdish/random,
					/obj/item/weapon/virusdish/random,
					/obj/item/weapon/virusdish/random,
					/obj/item/weapon/virusdish/random)
	additional_costs = 300
	group = "Medical / Science"
	general_crate = TRUE

/datum/supply_pack/coolanttank
	name = "Coolant tank crate"
	contains = list(/obj/structure/reagent_dispensers/coolanttank)
	additional_costs = 300
	general_crate = FALSE
	crate_type = /obj/structure/largecrate
	crate_name = "Coolant tank crate"
	group = "Medical / Science"
	general_crate = TRUE

/datum/supply_pack/surgery
	name = "Surgery tools"
	contains = list(/obj/item/weapon/storage/visuals/surgery/full)
	additional_costs = 100
	group = "Medical / Science"
	general_crate = TRUE

/datum/supply_pack/bloodpacks
	name = "Blood Pack Variety Crate"
	contains = list(/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/APlus,
					/obj/item/weapon/reagent_containers/blood/AMinus,
					/obj/item/weapon/reagent_containers/blood/BPlus,
					/obj/item/weapon/reagent_containers/blood/BMinus,
					/obj/item/weapon/reagent_containers/blood/OPlus,
					/obj/item/weapon/reagent_containers/blood/OMinus)
	additional_costs = 1000
	crate_type = /obj/structure/closet/crate/freezer
	crate_name = "blood freezer"
	general_crate = FALSE
	group = "Medical / Science"

/datum/supply_pack/body_bags
	name = "Stasis Bags"
	contains = list(/obj/item/bodybag/cryobag,
					/obj/item/bodybag/cryobag,
					/obj/item/bodybag/cryobag,
					/obj/item/bodybag/cryobag,
					/obj/item/bodybag/cryobag,
					/obj/item/bodybag/cryobag,
					/obj/item/bodybag/cryobag,
					/obj/item/bodybag/cryobag,
					/obj/item/bodybag/cryobag)
	crate_name = "stasis bags crate"
	group = "Medical / Science"
	general_crate = TRUE

/datum/supply_pack/artifical_ventilation_machine
	name = "Artifical Ventilation Machine"
	contains = list(/obj/machinery/life_assist/artificial_ventilation)
	general_crate = FALSE
	crate_type = /obj/structure/largecrate
	crate_name = "AVM Crate"
	group = "Medical / Science"

/datum/supply_pack/cardiopulmonary_bypass_machine
	name = "Cardiopulmonary Bypass Machine"
	contains = list(/obj/machinery/life_assist/cardiopulmonary_bypass)
	general_crate = FALSE
	crate_type = /obj/structure/largecrate
	crate_name = "CBM crate"
	group = "Medical / Science"

//----------------------------------------------
//-----------------HYDROPONICS------------------
//----------------------------------------------

/datum/supply_pack/monkey
	name = "Monkey crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes)
	group = "Hydroponics"
	general_crate = TRUE

/datum/supply_pack/farwa
	name = "Farwa crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/farwacubes)
	group = "Hydroponics"
	general_crate = TRUE

/datum/supply_pack/skrell
	name = "Neaera crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/neaeracubes)
	group = "Hydroponics"
	general_crate = TRUE

/datum/supply_pack/stok
	name = "Stok crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/stokcubes)
	group = "Hydroponics"
	general_crate = TRUE

//farm animals - useless and annoying, but potentially a good source of food
/datum/supply_pack/cow
	name = "Cow crate"
	crate_type = /obj/structure/closet/critter/cow
	crate_name = "Cow crate"
	access = access_hydroponics
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/goat
	name = "Goat crate"
	crate_type = /obj/structure/closet/critter/goat
	crate_name = "Goat crate"
	access = access_hydroponics
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/chicken
	name = "Chicken crate"
	crate_type = /obj/structure/closet/critter/chick
	crate_name = "Chicken crate"
	access = access_hydroponics
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/corgi
	name = "Corgi crate"
	crate_type = /obj/structure/closet/critter/corgi
	crate_name = "Corgi crate"
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/shiba
	name = "Shiba crate"
	crate_type = /obj/structure/closet/critter/shiba
	crate_name = "Shiba crate"
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/cat
	name = "Cat crate"
	crate_type = /obj/structure/closet/critter/cat
	crate_name = "Cat crate"
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/pug
	name = "Pug crate"
	crate_type = /obj/structure/closet/critter/pug
	crate_name = "Pug crate"
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/pig
	name = "Pig crate"
	crate_type = /obj/structure/closet/critter/pig
	crate_name = "Pig crate"
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/turkey
	name = "Turkey crate"
	crate_type = /obj/structure/closet/critter/turkey
	crate_name = "Turkey crate"
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/goose
	name = "Goose crate"
	crate_type = /obj/structure/closet/critter/goose
	crate_name = "Goose crate"
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/seal
	name = "Seal crate"
	crate_type = /obj/structure/closet/critter/seal
	crate_name = "Seal crate"
	group = "Hydroponics"
	general_crate = FALSE
	additional_costs = 100

/datum/supply_pack/walrus
	name = "Walrus crate"
	crate_type = /obj/structure/closet/critter/walrus
	crate_name = "Walrus crate"
	group = "Hydroponics"
	additional_costs = 100
	general_crate = FALSE

/datum/supply_pack/larva
	name = "Sugar larva crate"
	crate_type = /obj/structure/closet/critter/larva
	crate_name = "Sugar larva crate"
	group = "Hydroponics"
	additional_costs = 100
	general_crate = FALSE

/datum/supply_pack/weedcontrol
	name = "Weed control"
	contains = list(/obj/item/weapon/scythe,
					/obj/item/clothing/mask/gas/coloured,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed)
	group = "Hydroponics"
	general_crate = FALSE

/datum/supply_pack/bee_keeper
	name = "Beekeeping crate"
	contains = list(/obj/item/beezeez,
					/obj/item/weapon/bee_net,
					/obj/item/apiary,
					/obj/item/queen_bee)
	contraband = TRUE
	general_crate = FALSE
	additional_costs = 150
	crate_type = /obj/structure/closet/crate/hydroponics
	crate_name = "Beekeeping crate"
	access = access_hydroponics
	group = "Hydroponics"

//----------------------------------------------
//--------------------MINING--------------------
//----------------------------------------------

/datum/supply_pack/mining
	name = "Mining explosives kit"
	contains = list(/obj/item/weapon/mining_charge,
					/obj/item/weapon/mining_charge,
					/obj/item/weapon/mining_charge)
	group = "Mining"
	general_crate = TRUE

/datum/supply_pack/mining_supply
	name = "Mining supplies"
	contains = list(/obj/item/weapon/mining_scanner/improved,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,
					/obj/item/weapon/storage/box/autoinjector/stimpack,
					/obj/item/weapon/pickaxe/drill/jackhammer)
	group = "Mining"
	general_crate = TRUE

/datum/supply_pack/kinetic
	name = "Proto-kinetic accelerator"
	contains = list(/obj/item/weapon/gun/energy/kinetic_accelerator)
	group = "Mining"
	general_crate = TRUE

/datum/supply_pack/plasma_cutter
	name = "Plasma cutter"
	contains = list(/obj/item/projectile/beam/plasma_cutter)
	group = "Mining"
	general_crate = TRUE

//----------------------------------------------
//--------------------SUPPLY--------------------
//----------------------------------------------

/datum/supply_pack/food
	name = "Kitchen supply crate"
	contains = list(/obj/item/weapon/reagent_containers/food/condiment/flour,
					/obj/item/weapon/reagent_containers/food/condiment/flour,
					/obj/item/weapon/reagent_containers/food/condiment/flour,
					/obj/item/weapon/reagent_containers/food/condiment/flour,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/storage/fancy/egg_box,
					/obj/item/weapon/reagent_containers/food/snacks/tofu,
					/obj/item/weapon/reagent_containers/food/snacks/tofu,
					/obj/item/weapon/reagent_containers/food/snacks/meat,
					/obj/item/weapon/reagent_containers/food/snacks/meat,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	additional_costs = 150
	crate_type = /obj/structure/closet/crate/freezer
	crate_name = "Food crate"
	general_crate = FALSE
	group = "Supply"

/datum/supply_pack/vest
	name = "Vests"
	contains = list(/obj/item/clothing/accessory/storage/brown_vest,
					/obj/item/clothing/accessory/storage/brown_vest,
					/obj/item/clothing/accessory/storage/black_vest)
	group = "Supply"
	general_crate = TRUE

/datum/supply_pack/misc/posters
	name = "Corporate Posters"
	contains = list(/obj/item/weapon/poster/legit,
					/obj/item/weapon/poster/legit,
					/obj/item/weapon/poster/legit,
					/obj/item/weapon/poster/legit,
					/obj/item/weapon/poster/legit)
	group = "Supply"
	general_crate = TRUE
	additional_costs = 30

/datum/supply_pack/janitor
	name = "Janitorial supplies"
	contains = list(
					/obj/item/weapon/mop/advanced,
					/obj/item/weapon/holosign_creator,
					/obj/item/weapon/reagent_containers/watertank_backpack/janitor,
					/obj/item/weapon/storage/bag/trash,
					/obj/item/weapon/reagent_containers/spray/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner)
	group = "Supply"
	general_crate = TRUE

/datum/supply_pack/barber
	name = "Barber supplies"
	contains = list(/obj/item/weapon/storage/box/hairdyes,
	/obj/item/weapon/reagent_containers/spray/hair_color_spray,
	/obj/item/weapon/reagent_containers/glass/bottle/hair_growth_accelerator,
	/obj/item/weapon/scissors,
	/obj/item/weapon/razor)
	additional_costs = 50
	general_crate = TRUE
	group = "Supply"

/datum/supply_pack/clown
	name = "Clown supplies"
	contains = list(/obj/item/weapon/bikehorn,
					/obj/item/weapon/reagent_containers/food/snacks/pie,
					/obj/item/toy/crayon/rainbow)
	additional_costs = 50
	general_crate = TRUE
	group = "Supply"
//----------------------------------------------
//--------------MISCELLANEOUS-------------------
//----------------------------------------------

/datum/supply_pack/wizard
	name = "Wizard costume"
	contains = list(/obj/item/weapon/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	additional_costs = 50
	general_crate = TRUE
	group = "Miscellaneous"

/datum/supply_pack/conveyor
	name = "Conveyor Assembly Crate"
	contains = list(/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_switch_construct,
					/obj/item/weapon/paper/conveyor)
	general_crate = FALSE
	additional_costs = 150
	crate_name = "conveyor assembly crate"
	group = "Miscellaneous"

/datum/supply_pack/formal_wear
	contains = list(/obj/item/clothing/head/bowler,
					/obj/item/clothing/head/that,
					/obj/item/clothing/suit/storage/lawyer/bluejacket,
					/obj/item/clothing/suit/storage/lawyer/purpjacket,
					/obj/item/clothing/under/suit_jacket,
					/obj/item/clothing/under/suit_jacket/female,
					/obj/item/clothing/under/suit_jacket/really_black,
					/obj/item/clothing/under/suit_jacket/red,
					/obj/item/clothing/under/lawyer/bluesuit,
					/obj/item/clothing/under/lawyer/purpsuit,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/shoes/leather,
					/obj/item/clothing/accessory/tie/waistcoat,
					/obj/item/clothing/under/suit_jacket/charcoal,
					/obj/item/clothing/under/suit_jacket/navy,
					/obj/item/clothing/under/suit_jacket/burgundy,
					/obj/item/clothing/under/suit_jacket/checkered,
					/obj/item/clothing/under/suit_jacket/tan)
	name = "Formalwear closet"
	general_crate = FALSE
	additional_costs = 100
	crate_type = /obj/structure/closet
	crate_name = "Formalwear for the best occasions."
	group = "Miscellaneous"

/datum/supply_pack/laser_tag
	name = "Laser Tag Crate"
	contains = list(/obj/item/weapon/gun/energy/laser/selfcharging/lasertag/redtag,
					/obj/item/weapon/gun/energy/laser/selfcharging/lasertag/redtag,
					/obj/item/weapon/gun/energy/laser/selfcharging/lasertag/redtag,
					/obj/item/clothing/suit/lasertag/redtag,
					/obj/item/clothing/suit/lasertag/redtag,
					/obj/item/clothing/suit/lasertag/redtag,
					/obj/item/weapon/gun/energy/laser/selfcharging/lasertag/bluetag,
					/obj/item/weapon/gun/energy/laser/selfcharging/lasertag/bluetag,
					/obj/item/weapon/gun/energy/laser/selfcharging/lasertag/bluetag,
					/obj/item/clothing/suit/lasertag/bluetag,
					/obj/item/clothing/suit/lasertag/bluetag,
					/obj/item/clothing/suit/lasertag/bluetag)
	general_crate = FALSE
	additional_costs = 150
	group = "Miscellaneous"

//----------------------------------------------
//-----------------RANDOMISED-------------------
//----------------------------------------------

/datum/supply_pack/randomised
	name = "Collectable Hats Crate!"
	var/num_contained = 4 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/HoS,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	additional_costs = 250
	general_crate = TRUE
	crate_name = "Collectable hats crate! Brought to you by Bass.inc!"
	group = "Miscellaneous"

/datum/supply_pack/randomised/fill(obj/structure/closet/crate/C)
	var/list/L = contains.Copy()
	var/item
	if(num_contained <= L.len)
		for(var/i in 1 to num_contained)
			item = pick_n_take(L)
			new item(C)
	else
		for(var/i in 1 to num_contained)
			item = pick(L)
			new item(C)

/datum/supply_pack/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/seeds/bloodtomatoseed,
					/obj/item/weapon/storage/pill_bottle/zoom,
					/obj/item/weapon/storage/pill_bottle/happy,
					/obj/item/weapon/poster/contraband,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine)
	name = "Contraband crate"
	// Selling back contraband is quite hard. An illiquid asset.
	overprice = 1.5
	general_crate = FALSE
	additional_costs = 200
	crate_type = /obj/structure/closet/crate
	crate_name = "Unlabeled crate"
	contraband = TRUE
	group = "Operations"

/datum/supply_pack/randomised/toys
	num_contained = 5
	contains = list(/obj/item/toy/spinningtoy,
	                /obj/item/toy/sword,
					/obj/item/toy/dualsword,
	                /obj/item/toy/owl,
	                /obj/item/toy/griffin,
	                /obj/item/toy/nuke,
	                /obj/item/toy/minimeteor,
	                /obj/item/toy/carpplushie,
	                /obj/item/toy/crossbow,
	                /obj/item/toy/katana)
	name = "Toys"
	general_crate = TRUE
	additional_costs = 100
	group = "Miscellaneous"

/datum/supply_pack/randomised/pizza
	num_contained = 5
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable)
	additional_costs = 150
	general_crate = TRUE
	name = "Surprise pack of five pizzas"
	crate_type = /obj/structure/closet/crate/freezer
	crate_name = "Pizza crate"
	group = "Hospitality"

/datum/supply_pack/randomised/costume
	num_contained = 2
	contains = list(/obj/item/clothing/suit/pirate,
					/obj/item/clothing/suit/judgerobe,
					/obj/item/clothing/accessory/tie/waistcoat,
					/obj/item/clothing/suit/hastur,
					/obj/item/clothing/suit/holidaypriest,
					/obj/item/clothing/suit/hooded/skhima,
					/obj/item/clothing/suit/hooded/nun,
					/obj/item/clothing/suit/imperium_monk,
					/obj/item/clothing/suit/ianshirt,
					/obj/item/clothing/under/gimmick/rank/captain/suit,
					/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit,
					/obj/item/clothing/under/lawyer/purpsuit,
					/obj/item/clothing/under/rank/mailman,
					/obj/item/clothing/under/dress/dress_saloon,
					/obj/item/clothing/suit/suspenders,
					/obj/item/clothing/suit/storage/labcoat/mad,
					/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
					/obj/item/clothing/under/schoolgirl,
					/obj/item/clothing/under/owl,
					/obj/item/clothing/under/waiter,
					/obj/item/clothing/under/gladiator,
					/obj/item/clothing/under/soviet,
					/obj/item/clothing/under/scratch,
					/obj/item/clothing/under/wedding/bride_white,
					/obj/item/clothing/suit/chef,
					/obj/item/clothing/suit/apron/overalls,
					/obj/item/clothing/under/redcoat,
					/obj/item/clothing/under/kilt)
	name = "Costumes"
	general_crate = FALSE
	additional_costs = 125
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "Actor Costumes"
	access = access_theatre
	group = "Miscellaneous"


/datum/supply_pack/willpower
	name = "Volitional Neuroinhibitor Implanter"
	contains = list(/obj/item/weapon/implanter/willpower)
	additional_costs = 10000
	general_crate = TRUE
	group = "Miscellaneous"

//----------------------------------------------
//-----------------XENO THREAT-------------------
//----------------------------------------------
/datum/supply_pack/xeno_laser
	name = "Xeno liquidator"
	contains = list(/obj/item/clothing/suit/space/globose/recycler,
					/obj/item/clothing/head/helmet/space/globose/recycler,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/shield/buckler,
					/obj/item/clothing/mask/breath,
					/obj/item/weapon/tank/oxygen,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/space)
	additional_costs = 1800
	crate_name = "Xeno liquidator crate"
	group = "xeno"	//there is no such category, so these crates will not be visible in the console
	general_crate = FALSE
	hidden = TRUE

/datum/supply_pack/xeno_incendiary
	name = "Xeno arsonist"
	contains = list(/obj/item/clothing/head/helmet/space/rig/security,
					/obj/item/clothing/suit/space/rig/security,
					/obj/item/weapon/gun/projectile/shotgun/combat,
					/obj/item/ammo_box/eight_shells/incendiary,
					/obj/item/weapon/shield/riot,
					/obj/item/clothing/ears/earmuffs,
					/obj/item/clothing/mask/breath,
					/obj/item/weapon/tank/oxygen,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat)
	additional_costs = 1800
	general_crate = FALSE
	crate_name = "Xeno arsonist crate"
	group = "xeno"
	hidden = TRUE

//----------------------------------------------
//-----------------BLOB THREAT-------------------
//----------------------------------------------
/datum/supply_pack/blob_equipment
	name = "Anti-blob equipment: Personal set"
	contains = list(/obj/item/clothing/suit/space/rig/atmos,
					/obj/item/clothing/head/helmet/space/rig/atmos,
					/obj/item/clothing/shoes/magboots,
					/obj/item/clothing/mask/breath,
					/obj/item/weapon/tank/oxygen,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/projectile/automatic/pistol/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/weapon/gun/energy/gun/nuclear,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/space)
	additional_costs = 9300
	general_crate = FALSE
	crate_name = "Anti-blob equipment: Personal set"
	group = "blob"	//there is no such category, so these crates will not be visible in the console
	hidden = TRUE

/datum/supply_pack/blob_equipment/group
	name = "Anti-blob equipment: Group supply"
	contains = list(/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/machinery/recharger,
					/obj/machinery/recharger,
					/obj/machinery/recharger,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,
					/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,
					/obj/item/weapon/gun/projectile/automatic/pistol/glock,
					/obj/item/weapon/gun/projectile/automatic/pistol/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/ammo_box/magazine/glock,
					/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/gun/energy/laser/cutter,
					/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	crate_type = /obj/structure/closet/crate/secure/large
	general_crate = FALSE
	access = access_mint
	additional_costs = 9300
	crate_name = "Anti-blob equipment: Group supply"

//----------------------------------------------
//-------------SMARTLIGHT PROGRAMMS-------------
//----------------------------------------------

/datum/supply_pack/smartlight_standart
	name = "Smartlight programms set: Standart"
	contains = list(
		/obj/item/weapon/disk/smartlight_programm/soft,
		/obj/item/weapon/disk/smartlight_programm/hard,
		/obj/item/weapon/disk/smartlight_programm/k3000,
		/obj/item/weapon/disk/smartlight_programm/k4000,
		/obj/item/weapon/disk/smartlight_programm/k5000,
		/obj/item/weapon/disk/smartlight_programm/k6000,
	)
	additional_costs = 250
	general_crate = TRUE
	group = "Operations"

/datum/supply_pack/smartlight_neon
	name = "Smartlight programms set: Neon"
	contains = list(
		/obj/item/weapon/disk/smartlight_programm/neon,
		/obj/item/weapon/disk/smartlight_programm/neon_dark,
	)
	additional_costs = 500
	general_crate = TRUE
	group = "Operations"

/datum/supply_pack/smartlight_blue
	name = "Smartlight programms set: Blue"
	contains = list(
		/obj/item/weapon/disk/smartlight_programm/blue_night,
		/obj/item/weapon/disk/smartlight_programm/soft_blue,
	)
	additional_costs = 500
	general_crate = TRUE
	group = "Operations"

/datum/supply_pack/smartlight_shadows
	name = "Smartlight programms set: Shadows"
	contains = list(
		/obj/item/weapon/disk/smartlight_programm/shadows_soft,
		/obj/item/weapon/disk/smartlight_programm/shadows_hard,
	)
	additional_costs = 500
	general_crate = TRUE
	group = "Operations"
