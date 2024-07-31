/obj/random/trader_product
	name = "Random Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/item_to_spawn()
	return pick(\
	prob(20);/obj/random/trader_product/civ,\
	prob(20);/obj/random/trader_product/med,\
	prob(20);/obj/random/trader_product/eng,\
	prob(20);/obj/random/trader_product/rnd,\
	prob(10);/obj/random/trader_product/sec,\
	prob(10);/obj/random/trader_product/contraband\
	)

/obj/random/trader_product/civ
	name = "Random Civilian Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/civ/item_to_spawn()
	return pick(\
	prob(5);/obj/item/clothing/glasses/gar/super,\
	prob(5);/obj/item/device/violin,\
	prob(3);/obj/item/device/guitar/electric,\
	prob(3);/obj/item/device/guitar,\
	prob(1);/obj/item/weapon/survivalcapsule/elite,\
	prob(5);/obj/item/weapon/coin/diamond,\
	prob(1);/obj/item/device/lens/nude,\
	prob(1);/obj/item/clothing/mask/balaclava/richard,\
	prob(1);/obj/item/clothing/mask/balaclava/don_juan,\
	prob(1);/obj/item/clothing/mask/balaclava/rasmus,\
	prob(5);/obj/item/clothing/mask/cigarette/cigar/cohiba,\
	prob(1);/obj/item/stack/sheet/animalhide/xeno,\
	prob(1);/obj/item/weapon/storage/box/space_suit/clown,\
	prob(5);/obj/item/weapon/gun/energy/laser/cutter,\
	prob(5);/obj/item/clothing/mask/facehugger_toy,\
	prob(5);/obj/item/clothing/mask/gas/fawkes,\
	prob(5);/obj/item/weapon/tank/emergency_oxygen/double,\
	prob(5);/obj/item/toy/sound_button/syndi,\
	prob(5);/obj/item/toy/dualsword,\
	prob(5);/obj/random/randomtoy,\
	prob(5);/obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk,\
	prob(5);/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom,\
	prob(3);/obj/item/clothing/accessory/armor,\
	prob(5);/obj/item/clothing/gloves/pipboy/pimpboy3billion,\
	prob(5);/obj/item/weapon/patcher,\
	prob(5);/obj/item/weapon/sledgehammer,\
	prob(8);/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian,\
	prob(8);/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,\
	prob(5);/obj/item/weapon/storage/pouch/large_generic,\
	prob(1);/obj/item/weapon/tank/jetpack/oxygen/harness,\
	prob(5);/obj/item/device/flash,\
	prob(3);/obj/item/device/remote_device/no_access,\
	prob(2);/obj/item/seeds/bluespacetomatoseed,\
	prob(2);/obj/item/seeds/meatwheat,\
	prob(2);/obj/item/seeds/replicapod/real_deal,\
	prob(2);/obj/item/seeds/thaadra,\
	prob(2);/obj/item/seeds/telriis,\
	prob(2);/obj/item/seeds/vale,\
	prob(2);/obj/item/seeds/jurlmah,\
	prob(2);/obj/item/seeds/gelthi,\
	prob(1);/obj/item/weapon/bikehorn/gold,\
	prob(4);/obj/item/weapon/book/skillbook/exosuits,\
	prob(4);/obj/item/weapon/book/skillbook/robust,\
	prob(3);/obj/item/weapon/reagent_containers/glass/bottle/mutagen,\
	prob(1);/obj/item/weapon/claymore/light\
	)

/obj/random/trader_product/med
	name = "Random Medical Trader Product"
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/med/item_to_spawn()
	return pick(\
	prob(1);/obj/item/asteroid/hivelord_core,\
	prob(5);/obj/item/weapon/reagent_containers/hypospray/autoinjector/bonepen,\
	prob(1);/obj/item/weapon/gun/syringe/rapidsyringe,\
	prob(1);/obj/item/weapon/defibrillator/compact/combat/loaded,\
	prob(1);/obj/item/weapon/storage/belt/medical/surg/full,\
	prob(3);/obj/item/weapon/storage/pill_bottle/bicaridine,\
	prob(3);/obj/item/weapon/storage/pill_bottle/dexalin_plus,\
	prob(3);/obj/item/weapon/storage/pill_bottle/dermaline,\
	prob(3);/obj/item/weapon/storage/pill_bottle/dylovene,\
	prob(3);/obj/item/weapon/storage/pill_bottle/spaceacillin,\
	prob(3);/obj/item/weapon/storage/pill_bottle/tramadol,\
	prob(3);/obj/item/weapon/reagent_containers/glass/bottle/peridaxon,\
	prob(1);/obj/item/weapon/reagent_containers/glass/bottle/kyphotorin,\
	prob(5);/obj/item/weapon/medical/teleporter,\
	prob(3);/obj/item/weapon/scalpel/manager,\
	prob(5);/obj/item/weapon/virusdish/random,\
	prob(2);/obj/item/robot_parts/l_arm,\
	prob(2);/obj/item/robot_parts/r_arm,\
	prob(2);/obj/item/robot_parts/l_leg,\
	prob(2);/obj/item/robot_parts/r_leg,\
	prob(5);/obj/item/roller/roller_holder_surg,\
	prob(3);/obj/item/weapon/book/skillbook/surgery,\
	prob(3);/obj/item/weapon/book/skillbook/medical,\
	prob(3);/obj/item/weapon/book/skillbook/chemistry,\
	prob(2);/obj/item/weapon/dnainjector/clumsymut,\
	prob(2);/obj/item/weapon/dnainjector/hulkmut,\
	prob(2);/obj/item/weapon/dnainjector/regenerate\
	)

/obj/random/trader_product/eng
	name = "Random Engineering Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/eng/item_to_spawn()
	return pick(\
	prob(1);/obj/item/weapon/storage/part_replacer,\
	prob(5);/obj/item/stack/sheet/metal/fifty,\
	prob(5);/obj/item/stack/sheet/glass/fifty,\
	prob(5);/obj/item/weapon/rcd/ert,\
	prob(5);/obj/item/weapon/rcd_ammo/bluespace,\
	prob(5);/obj/item/clothing/accessory/storage/brown_vest,\
	prob(5);/obj/item/clothing/glasses/meson/gar,\
	prob(5);/obj/item/clothing/glasses/welding/superior,\
	prob(5);/obj/item/clothing/gloves/insulated,\
	prob(5);/obj/item/weapon/storage/toolbox/syndicate,\
	prob(1);/obj/item/weapon/storage/pneumatic,\
	prob(5);/obj/item/weapon/grenade/chem_grenade/metalfoam,\
	prob(5);/obj/item/weapon/multi/hand_drill,\
	prob(5);/obj/item/weapon/multi/jaws_of_life,\
	prob(5);/obj/item/weapon/weldingtool/experimental,\
	prob(5);/obj/item/device/lightreplacer,\
	prob(5);/obj/item/weapon/book/skillbook/engineering,\
	prob(1);/obj/item/weapon/circuitboard/camera_advanced\
	)

/obj/random/trader_product/rnd
	name = "Random Science Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/rnd/item_to_spawn()
	return pick(\
	prob(1);/obj/item/weapon/disk/research_points,\
	prob(5);/obj/item/bluespace_crystal,\
	prob(3);/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,\
	prob(3);/obj/item/mecha_parts/mecha_equipment/rcd,\
	prob(3);/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,\
	prob(3);/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,\
	prob(1);/obj/item/mecha_parts/part/honker_torso,\
	prob(3);/obj/item/stack/sheet/mineral/clown,\
	prob(1);/obj/item/device/assembly/signaler/anomaly,\
	prob(2);/obj/item/rig_module/simple_ai/advanced,\
	prob(2);/obj/item/rig_module/nuclear_generator,\
	prob(2);/obj/item/rig_module/emp_shield/adv,\
	prob(2);/obj/item/rig_module/chem_dispenser/medical/ert,\
	prob(2);/obj/item/rig_module/med_teleport,\
	prob(2);/obj/item/rig_module/selfrepair/adv,\
	prob(2);/obj/item/rig_module/mounted,\
	prob(5);/obj/item/borg/upgrade/security,\
	prob(5);/obj/item/borg/upgrade/vtec,\
	prob(5);/obj/item/weapon/stock_parts/cell/bluespace,\
	prob(3);/obj/item/weapon/storage/bag/trash/bluespace,\
	prob(3);/obj/item/weapon/storage/backpack/holding,\
	prob(1);/obj/item/device/aicard,\
	prob(1);/obj/item/device/mmi/posibrain,\
	prob(1);/obj/item/stack/sheet/mineral/silver/twenty,\
	prob(1);/obj/item/stack/sheet/mineral/gold/twenty,\
	prob(1);/obj/item/stack/sheet/mineral/phoron/twenty,\
	prob(1);/obj/item/stack/sheet/mineral/uranium/twenty,\
	prob(1);/obj/item/stack/sheet/mineral/diamond/twenty,\
	prob(5);/obj/item/weapon/book/skillbook/science\
	)

/obj/random/trader_product/sec
	name = "Random Security Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/sec/item_to_spawn()
	return pick(\
	prob(5);/obj/item/weapon/gun/energy/gun/adv,\
	prob(5);/obj/item/weapon/gun/projectile/automatic/l13,\
	prob(5);/obj/item/clothing/suit/armor/vest/fullbody,\
	prob(5);/obj/item/weapon/melee/baton/double,\
	prob(5);/obj/item/clothing/gloves/combat,\
	prob(5);/obj/item/ammo_box/eight_shells/dart,\
	prob(5);/obj/item/ammo_box/eight_shells/stunshot,\
	prob(5);/obj/item/clothing/glasses/sunglasses/hud/sechud/gar,\
	prob(1);/obj/item/clothing/glasses/sunglasses/hud/sechud/gar/super,\
	prob(3);/obj/item/clothing/glasses/night,\
	prob(5);/obj/item/weapon/gun/projectile/automatic/pistol/glock/spec,\
	prob(5);/obj/item/ammo_box/magazine/glock/extended/rubber,\
	prob(5);/obj/item/weapon/melee/telebaton,\
	prob(5);/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat,\
	prob(5);/obj/item/weapon/storage/pouch/ammo,\
	prob(1);/obj/item/weapon/changeling_test/prepared,\
	prob(3);/obj/item/weapon/shield/riot/tele,\
	prob(1);/obj/item/weapon/shield/energy,\
	prob(5);/obj/item/weapon/gun/energy/lasercannon\
	)

/obj/random/trader_product/contraband
	name = "Random Contraband Trader Product"
	desc = "This is random contraband trader product."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "syndieshirt"

/obj/random/trader_product/contraband/item_to_spawn()
	return pick(\
	prob(5);/obj/item/stack/telecrystal/three,\
	prob(5);/obj/item/weapon/legcuffs/bola/tactical,\
	prob(5);/obj/item/weapon/syndcodebook,\
	prob(5);/obj/item/weapon/switchblade,\
	prob(3);/obj/item/weapon/melee/energy/sword,\
	prob(5);/obj/item/weapon/grenade/spawnergrenade/manhacks,\
	prob(5);/obj/item/weapon/plastique,\
	prob(3);/obj/item/weapon/storage/pill_bottle/happy,\
	prob(3);/obj/item/weapon/storage/pill_bottle/zoom,\
	prob(3);/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate,\
	prob(5);/obj/item/weapon/storage/box/syndie_kit/chameleon,\
	prob(5);/obj/item/seeds/kudzuseed,\
	prob(3);/obj/item/weapon/storage/box/syndie_kit/posters,\
	prob(3);/obj/item/clothing/mask/gas/swat,\
	prob(5);/obj/item/borg/upgrade/syndicate,\
	prob(3);/obj/item/weapon/grenade/syndieminibomb,\
	prob(3);/obj/item/weapon/grenade/chem_grenade/acid,\
	prob(3);/obj/item/weapon/grenade/clusterbuster/soap,\
	prob(5);/obj/item/weapon/implanter/freedom,\
	prob(5);/obj/item/weapon/melee/powerfist,\
	prob(5);/obj/item/device/camera_bug,\
	prob(5);/obj/item/device/chameleon,\
	prob(5);/obj/item/device/debugger,\
	prob(5);/obj/item/device/encryptionkey/syndicate,\
	prob(5);/obj/item/device/powersink,\
	prob(5);/obj/item/weapon/card/id/syndicate,\
	prob(5);/obj/item/weapon/card/emag,\
	prob(5);/obj/item/weapon/cartridge/syndicate,\
	prob(1);/obj/item/weapon/reagent_containers/glass/bottle/bonebreaker,\
	prob(1);/obj/item/weapon/reagent_containers/glass/bottle/cyanide,\
	prob(1);/obj/item/weapon/reagent_containers/glass/bottle/carpotoxin,\
	prob(1);/obj/item/weapon/reagent_containers/glass/bottle/zombiepowder,\
	prob(1);/obj/item/weapon/reagent_containers/glass/bottle/chefspecial,\
	prob(5);/obj/item/weapon/circuitboard/aiupload\
	)
