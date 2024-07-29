/obj/effect/landmark/space_traders/product
	name = "Space Traders Product"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"

/obj/effect/landmark/space_traders/spawner
	name = "Space Trader"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Quartermaster"

/datum/faction/space_traders
	name = F_SPACE_TRADERS
	ID = F_SPACE_TRADERS

	initroletype = /datum/role/abductor/scientist
	logo_state = "space_traders"
	max_roles = 3

/datum/faction/space_traders/New()
	..()
	create_spawner(/datum/spawner/space_trader/dealer)
	create_spawner(/datum/spawner/space_trader/guard)
	create_spawner(/datum/spawner/space_trader/porter)
	create_products()

/datum/faction/space_traders/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/make_money/faction/traders)
	return TRUE

/datum/faction/space_traders/proc/create_products()
	var/list/high_tier_spawned = list()

	for(var/obj/L in landmarks_list["Space Traders Product"])
		var/turf/T = get_turf(L)
		var/product

		if(high_tier_spawned.len < 2 && prob(30))
			if(prob(5))
				do product = pick_mech()
				while(product in high_tier_spawned)
			else
				new /obj/structure/rack(T)
				do product = pick_high_tier()
				while(product in high_tier_spawned)
			high_tier_spawned += product
			new product(T)
		else
			var/obj/structure/closet/crate/C = new(T)
			for(var/i in 1 to rand(3, 5))
				product = pick_item()
				new product(C)


/datum/faction/space_traders/proc/pick_item()
	if(prob(90))
		return pick(
		prob(10); /obj/item/clothing/glasses/gar/super,	// civ
		prob(10); /obj/item/device/violin,
		prob(10); /obj/item/weapon/survivalcapsule/elite,
		prob(10); /obj/item/weapon/coin/diamond,
		prob(10); /obj/item/device/lens/nude,
		prob(10); /obj/item/clothing/mask/balaclava/richard,
		prob(10); /obj/item/clothing/mask/cigarette/cigar/cohiba,
		prob(10); /obj/item/stack/sheet/animalhide/xeno,
		prob(10); /obj/item/weapon/storage/box/space_suit/clown,
		prob(10); /obj/item/weapon/book/skillbook/robust,
		prob(10); /obj/item/weapon/gun/energy/laser/cutter,
		prob(10); /obj/item/clothing/mask/facehugger_toy,
		prob(10); /obj/item/clothing/mask/gas/fawkes,
		prob(10); /obj/item/weapon/tank/emergency_oxygen/double,
		prob(10); /obj/item/toy/sound_button/syndi,
		prob(10); /obj/item/toy/balloon/arrest,
		prob(10); /obj/item/toy/dualsword,
		prob(10); /obj/random/randomtoy,
		prob(10); /obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk,
		prob(10); /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom,
		prob(10); /obj/item/asteroid/hivelord_core,		// med
		prob(10); /obj/item/weapon/reagent_containers/hypospray/autoinjector/bonepen,
		prob(10); /obj/item/weapon/gun/syringe/rapidsyringe,
		prob(10); /obj/item/weapon/defibrillator/compact/combat/loaded,
		prob(10); /obj/item/weapon/storage/belt/medical/surg/full,
		prob(10); /obj/item/weapon/storage/part_replacer,	// eng
		prob(10); /obj/item/stack/sheet/metal/fifty,
		prob(10); /obj/item/stack/sheet/glass/fifty,
		prob(10); /obj/item/weapon/rcd/ert,
		prob(10); /obj/item/weapon/rcd_ammo/bluespace,
		prob(10); /obj/item/clothing/accessory/storage/brown_vest,
		prob(10); /obj/item/weapon/disk/research_points,	// rnd
		prob(10); /obj/item/bluespace_crystal,
		prob(10); /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
		prob(10); /obj/item/mecha_parts/mecha_equipment/rcd,
		prob(10); /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,
		prob(10); /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		prob(10); /obj/item/mecha_parts/part/honker_torso,
		prob(10); /obj/item/stack/sheet/mineral/clown,
		prob(10); /obj/item/device/assembly/signaler/anomaly,
		prob(10); /obj/item/weapon/gun/energy/gun/adv,		// sec
		prob(10); /obj/item/weapon/gun/projectile/automatic/l13,
		prob(10); /obj/item/clothing/suit/armor/vest/fullbody,
		prob(10); /obj/item/weapon/melee/baton/double,
		prob(10); /obj/item/clothing/gloves/combat,
		prob(10); /obj/item/clothing/accessory/storage/black_vest,
		prob(10); /obj/item/ammo_box/eight_shells/dart,
		prob(10); /obj/item/clothing/glasses/sunglasses/hud/sechud/gar/super,
		prob(10); /obj/item/clothing/glasses/night,
		prob(10); /obj/item/weapon/gun/projectile/automatic/pistol/glock/spec)
	else
		return pick(
		prob(10); /obj/item/stack/telecrystal/five,
		prob(10); /obj/item/weapon/legcuffs/bola/tactical,
		prob(10); /obj/item/weapon/syndcodebook,
		prob(10); /obj/item/weapon/switchblade,
		prob(10); /obj/item/weapon/melee/energy/sword,
		prob(10); /obj/item/weapon/grenade/spawnergrenade/manhacks,
		prob(10); /obj/item/weapon/plastique,
		prob(10); /obj/item/weapon/storage/pill_bottle/happy,
		prob(10); /obj/item/weapon/storage/pill_bottle/zoom,
		prob(10); /obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate,
		prob(10); /obj/item/weapon/storage/box/syndie_kit/chameleon,
		prob(10); /obj/item/seeds/kudzuseed,
		prob(10); /obj/item/weapon/storage/box/syndie_kit/posters,
		prob(10); /obj/item/clothing/mask/gas/swat)

/datum/faction/space_traders/proc/pick_high_tier()
	return pick(
		prob(10); /obj/item/weapon/gun/medbeam,
		prob(10); /obj/item/weapon/reagent_containers/glass/bottle/kyphotorin,
		prob(10); /obj/item/weapon/gun/projectile/revolver/rocketlauncher/commando,
		prob(10); /obj/item/weapon/gun/energy/gun/portal/loaded,
		prob(10); /obj/item/weapon/reagent_containers/hypospray/combat,
		prob(10); /obj/item/weapon/storage/box/syndie_kit/drone,
		prob(10); /obj/item/weapon/gun/projectile/automatic/m41a,)

/datum/faction/space_traders/proc/pick_mech()
	return pick(
		prob(5); /obj/mecha/combat/gygax/security,
		prob(5); /obj/mecha/combat/honker/clown,
		prob(1); /obj/mecha/combat/marauder/mauler,
		prob(4); /obj/mecha/combat/gygax/dark,
		prob(5); /obj/mecha/working/ripley/deathripley)
