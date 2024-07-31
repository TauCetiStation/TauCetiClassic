/obj/effect/landmark/space_traders/product
	name = "Space Traders Product"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"

/obj/effect/landmark/space_traders/dealer
	name = "Space Trader Dealer"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Quartermaster"

/obj/effect/landmark/space_traders/guard
	name = "Space Trader Dealer"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Blueshield Officer"

/obj/effect/landmark/space_traders/porter
	name = "Space Trader Dealer"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Trader Porter"

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
	var/area/A = locate(/area/shuttle/trader/space) in all_areas
	A.parallax_movedir = EAST

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
			for(var/i in 1 to rand(3, 4))
				product = pick_item()
				new product(C)

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
		prob(5); /obj/mecha/combat/honker/clown,
		prob(1); /obj/mecha/combat/marauder/mauler,
		prob(4); /obj/mecha/combat/gygax/dark,
		prob(5); /obj/mecha/working/ripley/deathripley)
