/obj/random/trader_product
	name = "Random Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/item_to_spawn()
	return pick(\
	prob(6);/obj/random/trader_product/civ,\
	prob(5);/obj/random/trader_product/med,\
	prob(5);/obj/random/trader_product/eng,\
	prob(5);/obj/random/trader_product/rnd,\
	prob(3);/obj/random/trader_product/sec,\
	prob(1);/obj/random/trader_product/contraband\
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
	prob(5);/obj/item/weapon/survivalcapsule/elite,\
	prob(5);/obj/item/weapon/coin/diamond,\
	prob(5);/obj/item/device/lens/nude,\
	prob(1);/obj/item/clothing/mask/balaclava/richard,\
	prob(1);/obj/item/clothing/mask/balaclava/don_juan,\
	prob(1);/obj/item/clothing/mask/balaclava/rasmus,\
	prob(5);/obj/item/clothing/mask/cigarette/cigar/cohiba,\
	prob(5);/obj/item/stack/sheet/animalhide/xeno,\
	prob(5);/obj/item/weapon/storage/box/space_suit/clown,\
	prob(5);/obj/item/weapon/gun/energy/laser/cutter,\
	prob(5);/obj/item/clothing/mask/facehugger_toy,\
	prob(5);/obj/item/clothing/mask/gas/fawkes,\
	prob(5);/obj/item/weapon/tank/emergency_oxygen/double,\
	prob(5);/obj/item/toy/sound_button/syndi,\
	prob(5);/obj/item/toy/dualsword,\
	prob(5);/obj/random/randomtoy\
	prob(5);/obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk,\
	prob(5);/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);\
	)

/obj/random/trader_product/med
	name = "Random Medical Trader Product"
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/med/item_to_spawn()
	return pick(\
	prob(5);/obj/item/asteroid/hivelord_core,\
	prob(5);/obj/item/weapon/reagent_containers/hypospray/autoinjector/bonepen,\
	prob(5);/obj/item/weapon/gun/syringe/rapidsyringe,\
	prob(5);/obj/item/weapon/defibrillator/compact/combat/loaded,\
	prob(5);/obj/item/weapon/storage/belt/medical/surg/full,\
	prob(5);,\
	prob(5);,\
	prob(5);\
	)

/obj/random/trader_product/eng
	name = "Random Engineering Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/eng/item_to_spawn()
	return pick(\
	prob(5);/obj/item/weapon/storage/part_replacer,\
	prob(5);/obj/item/stack/sheet/metal/fifty,\
	prob(5);/obj/item/stack/sheet/glass/fifty,\
	prob(5);/obj/item/weapon/rcd/ert,\
	prob(5);/obj/item/weapon/rcd_ammo/bluespace,\
	prob(5);/obj/item/clothing/accessory/storage/brown_vest,\
	prob(5);,\
	prob(5);\
	)

/obj/random/trader_product/rnd
	name = "Random Science Trader Product"
	desc = "This is random trader product."
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash10"

/obj/random/trader_product/rnd/item_to_spawn()
	return pick(\
	prob(5);/obj/item/weapon/disk/research_points,\
	prob(5);/obj/item/bluespace_crystal,\
	prob(5);/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,\
	prob(5);/obj/item/mecha_parts/mecha_equipment/rcd,\
	prob(5);/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,\
	prob(5);/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,\
	prob(5);/obj/item/mecha_parts/part/honker_torso,\
	prob(5);/obj/item/stack/sheet/mineral/clown,\
	prob(5);/obj/item/device/assembly/signaler/anomaly,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);\
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
	prob(5);/obj/item/clothing/glasses/sunglasses/hud/sechud/gar/super,\
	prob(5);/obj/item/clothing/glasses/night,\
	prob(5);/obj/item/weapon/gun/projectile/automatic/pistol/glock/spec,\
	prob(5);/obj/item/ammo_box/magazine/glock/extended/rubber,\
	prob(5);,\
	prob(5);\
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
	prob(5);/obj/item/weapon/melee/energy/sword,\
	prob(5);/obj/item/weapon/grenade/spawnergrenade/manhacks,\
	prob(5);/obj/item/weapon/plastique,\
	prob(5);/obj/item/weapon/storage/pill_bottle/happy,\
	prob(5);/obj/item/weapon/storage/pill_bottle/zoom,\
	prob(5);/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate,\
	prob(5);/obj/item/weapon/storage/box/syndie_kit/chameleon,\
	prob(5);/obj/item/seeds/kudzuseed,\
	prob(5);/obj/item/weapon/storage/box/syndie_kit/posters,\
	prob(5);/obj/item/clothing/mask/gas/swat,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);,\
	prob(5);\
	)
