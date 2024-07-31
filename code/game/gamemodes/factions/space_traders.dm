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
	var/high_tier_spawned = FALSE

	for(var/obj/L in landmarks_list["Space Traders Product"]) // 21 landmarks on shuttle
		var/turf/T = get_turf(L)
		var/product

		if(high_tier_spawned) // 1 landmark for high tier, 20 for another items
			var/obj/structure/closet/crate/C = new(T)
			for(var/i in 1 to 2) // 20 * 2 = 40 items for sale
				product = /obj/random/trader_product
				new product(C)
		else
			if(prob(30))
				product = pick_mech()
				if(istype(product, /obj/vehicle/space/spacebike))
					new /obj/item/weapon/key/spacebike(T)
			else
				new /obj/structure/rack(T)
				product = pick_high_tier()
			new product(T)
			high_tier_spawned = TRUE

/datum/faction/space_traders/proc/pick_high_tier()
	return pick(
		/obj/item/weapon/gun/medbeam,
		/obj/item/weapon/gun/projectile/revolver/rocketlauncher/commando,
		/obj/item/weapon/gun/energy/gun/portal/loaded,
		/obj/item/weapon/gun/projectile/automatic/m41a)

/datum/faction/space_traders/proc/pick_mech()
	return pick(
		prob(5); /obj/mecha/combat/honker/clown,
		prob(1); /obj/mecha/combat/marauder/mauler,
		prob(3); /obj/mecha/combat/gygax/dark,
		prob(5); /obj/mecha/working/ripley/deathripley,
		prob(3); /obj/vehicle/space/spacebike)
