/obj/random/trader_product
	name = "Random Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/item_to_spawn()
	return pickweight(list(
	/obj/random/trader_product/civ = 20,
	/obj/random/trader_product/med = 20,
	/obj/random/trader_product/eng = 20,
	/obj/random/trader_product/rnd = 20,
	/obj/random/trader_product/sec = 10,
	/obj/random/trader_product/contraband = 10))

/obj/random/trader_product/civ
	name = "Random Civilian Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/civ/item_to_spawn()
	return pickweight(list(
	/obj/item/clothing/glasses/gar/super = 5,
	/obj/item/device/violin = 5,
	/obj/item/device/synth = 3,
	/obj/item/device/guitar = 3,
	/obj/item/weapon/survivalcapsule/elite = 1,
	/obj/item/weapon/coin/diamond = 5,
	/obj/item/device/lens/nude = 1,
	/obj/item/clothing/mask/balaclava/richard = 1,
	/obj/item/clothing/mask/balaclava/don_juan = 1,
	/obj/item/clothing/mask/balaclava/rasmus = 1,
	/obj/item/clothing/mask/cigarette/cigar/cohiba = 5,
	/obj/item/stack/sheet/animalhide/xeno = 1,
	/obj/item/weapon/storage/box/space_suit/clown = 1,
	/obj/item/weapon/gun/energy/laser/cutter = 3,
	/obj/item/clothing/mask/facehugger_toy = 3,
	/obj/item/weapon/tank/emergency_oxygen/double = 5,
	/obj/item/toy/sound_button/syndi = 3,
	/obj/item/toy/dualsword = 5,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk = 3,
	/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom = 3,
	/obj/item/clothing/gloves/pipboy/pimpboy3billion = 5,
	/obj/item/weapon/patcher = 5,
	/obj/item/weapon/sledgehammer = 1,
	/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian = 5,
	/obj/item/weapon/storage/firstaid/small_firstaid_kit/space = 5,
	/obj/item/weapon/tank/jetpack/oxygen/harness = 1,
	/obj/item/device/remote_device/no_access = 3,
	/obj/item/seeds/bluespacetomatoseed = 1,
	/obj/item/seeds/meatwheat = 1,
	/obj/item/seeds/replicapod/real_deal = 1,
	/obj/item/seeds/thaadra = 1,
	/obj/item/seeds/telriis = 1,
	/obj/item/seeds/vale = 1,
	/obj/item/seeds/jurlmah = 1,
	/obj/item/seeds/gelthi = 1,
	/obj/item/weapon/bikehorn/gold = 1,
	/obj/item/clothing/shoes/syndigaloshes = 2,
	/obj/item/weapon/claymore/light = 1))

/obj/random/trader_product/med
	name = "Random Medical Trader Product"
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/med/item_to_spawn()
	return pickweight(list(
	/obj/item/asteroid/hivelord_core = 1,
	/obj/item/weapon/reagent_containers/hypospray/autoinjector/bonepen = 5,
	/obj/item/weapon/gun/syringe/rapidsyringe = 1,
	/obj/item/weapon/defibrillator/compact/combat/loaded = 1,
	/obj/item/weapon/storage/belt/medical/surg/full = 1,
	/obj/item/weapon/storage/pill_bottle/bicaridine = 2,
	/obj/item/weapon/storage/pill_bottle/dexalin_plus = 2,
	/obj/item/weapon/storage/pill_bottle/dermaline = 2,
	/obj/item/weapon/storage/pill_bottle/dylovene = 2,
	/obj/item/weapon/storage/pill_bottle/tramadol = 2,
	/obj/item/weapon/reagent_containers/glass/bottle/peridaxon = 3,
	/obj/item/weapon/reagent_containers/glass/bottle/kyphotorin = 1,
	/obj/item/weapon/medical/teleporter = 3,
	/obj/item/weapon/scalpel/manager = 1,
	/obj/item/roller/roller_holder_surg = 3,
	/obj/item/weapon/reagent_containers/glass/beaker/bluespace = 2,
	/obj/item/weapon/reagent_containers/hypospray/combat = 1,
	/obj/item/weapon/dnainjector/clumsymut = 2,
	/obj/item/weapon/dnainjector/hulkmut = 2,
	/obj/item/weapon/dnainjector/regenerate = 2))

/obj/random/trader_product/eng
	name = "Random Engineering Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/eng/item_to_spawn()
	return pickweight(list(
	/obj/item/weapon/storage/part_replacer = 1,
	/obj/item/stack/sheet/metal/fifty = 3,
	/obj/item/stack/sheet/glass/fifty = 3,
	/obj/item/weapon/rcd/ert = 3,
	/obj/item/weapon/rcd_ammo/huge = 3,
	/obj/item/clothing/glasses/meson/gar = 3,
	/obj/item/clothing/glasses/welding/superior = 5,
	/obj/item/clothing/gloves/insulated = 5,
	/obj/item/weapon/storage/toolbox/syndicate = 1,
	/obj/item/weapon/storage/pneumatic = 1,
	/obj/item/weapon/grenade/chem_grenade/metalfoam = 3,
	/obj/item/weapon/storage/belt/utility/advanced = 3,
	/obj/item/device/lightreplacer = 1,
	/obj/item/clothing/shoes/magboots/ert = 5,
	/obj/item/weapon/circuitboard/camera_advanced = 1))

/obj/random/trader_product/rnd
	name = "Random Science Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/rnd/item_to_spawn()
	return pickweight(list(
	/obj/item/weapon/disk/research_points = 1,
	/obj/item/bluespace_crystal = 5,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser = 1,
	/obj/item/mecha_parts/mecha_equipment/rcd = 1,
	/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 1,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg = 1,
	/obj/item/mecha_parts/part/honker_torso = 1,
	/obj/item/stack/sheet/mineral/clown = 3,
	/obj/item/device/assembly/signaler/anomaly = 1,
	/obj/item/rig_module/simple_ai/advanced = 2,
	/obj/item/rig_module/nuclear_generator = 2,
	/obj/item/rig_module/emp_shield/adv = 2,
	/obj/item/rig_module/chem_dispenser/medical/ert = 2,
	/obj/item/rig_module/med_teleport = 2,
	/obj/item/rig_module/selfrepair/adv = 2,
	/obj/item/rig_module/mounted = 2,
	/obj/item/borg/upgrade/security = 2,
	/obj/item/borg/upgrade/vtec = 2,
	/obj/item/weapon/stock_parts/cell/bluespace = 5,
	/obj/item/weapon/storage/bag/trash/bluespace = 3,
	/obj/item/weapon/storage/backpack/holding = 3,
	/obj/item/device/aicard = 1,
	/obj/item/device/mmi/posibrain = 1,
	/obj/item/stack/sheet/mineral/diamond = 1))

/obj/random/trader_product/sec
	name = "Random Security Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/sec/item_to_spawn()
	return pickweight(list(
	/obj/item/weapon/gun/energy/gun/adv = 5,
	/obj/item/weapon/gun/projectile/automatic/l13 = 5,
	/obj/item/clothing/suit/armor/vest/fullbody = 5,
	/obj/item/weapon/melee/baton/double = 5,
	/obj/item/clothing/gloves/combat = 5,
	/obj/item/ammo_box/eight_shells/dart = 5,
	/obj/item/ammo_box/eight_shells/stunshot = 5,
	/obj/item/clothing/glasses/sunglasses/hud/sechud/gar = 5,
	/obj/item/clothing/glasses/sunglasses/hud/sechud/gar/super = 1,
	/obj/item/clothing/glasses/night = 3,
	/obj/item/weapon/gun/projectile/automatic/pistol/glock/spec = 5,
	/obj/item/ammo_box/magazine/glock/extended/rubber = 5,
	/obj/item/weapon/melee/telebaton = 5,
	/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat = 3,
	/obj/item/weapon/storage/pouch/ammo = 5,
	/obj/item/weapon/changeling_test/prepared = 1,
	/obj/item/weapon/shield/riot/tele = 3,
	/obj/item/weapon/shield/energy = 1,
	/obj/item/clothing/shoes/boots/combat = 5,
	/obj/item/weapon/gun/energy/lasercannon = 5))

/obj/random/trader_product/contraband
	name = "Random Contraband Trader Product"
	desc = "This is random contraband trader product."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "syndieshirt"

/obj/random/trader_product/contraband/item_to_spawn()
	return pickweight(list(
	/obj/item/stack/telecrystal/three = 5,
	/obj/item/weapon/legcuffs/bola/tactical = 5,
	/obj/item/weapon/syndcodebook = 5,
	/obj/item/weapon/switchblade = 5,
	/obj/item/weapon/melee/energy/sword = 3,
	/obj/item/weapon/grenade/spawnergrenade/manhacks = 5,
	/obj/item/weapon/plastique = 5,
	/obj/item/weapon/storage/pill_bottle/happy = 3,
	/obj/item/weapon/storage/pill_bottle/zoom = 3,
	/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate = 3,
	/obj/item/weapon/storage/box/syndie_kit/chameleon = 5,
	/obj/item/seeds/kudzuseed = 5,
	/obj/item/weapon/storage/box/syndie_kit/posters = 3,
	/obj/item/clothing/mask/gas/swat = 3,
	/obj/item/borg/upgrade/syndicate = 5,
	/obj/item/weapon/grenade/syndieminibomb = 3,
	/obj/item/weapon/grenade/chem_grenade/acid = 3,
	/obj/item/weapon/grenade/clusterbuster/soap = 3,
	/obj/item/weapon/implanter/freedom = 5,
	/obj/item/weapon/melee/powerfist = 5,
	/obj/item/device/camera_bug = 5,
	/obj/item/device/chameleon = 5,
	/obj/item/device/debugger = 5,
	/obj/item/device/encryptionkey/syndicate = 5,
	/obj/item/device/powersink = 5,
	/obj/item/weapon/card/id/syndicate = 3,
	/obj/item/weapon/card/emag = 3,
	/obj/item/weapon/cartridge/syndicate = 5,
	/obj/item/weapon/reagent_containers/glass/bottle/bonebreaker = 1,
	/obj/item/weapon/reagent_containers/glass/bottle/cyanide = 1,
	/obj/item/weapon/reagent_containers/glass/bottle/carpotoxin = 1,
	/obj/item/weapon/reagent_containers/glass/bottle/zombiepowder = 1,
	/obj/item/weapon/reagent_containers/glass/bottle/chefspecial = 1,
	/obj/item/weapon/circuitboard/aiupload = 3))
