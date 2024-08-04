/obj/effect/landmark/space_traders/product
	name = "Space Traders Product"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"

/obj/effect/landmark/space_traders/dealer
	name = "Space Trader Dealer"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Quartermaster"

/obj/effect/landmark/space_traders/guard
	name = "Space Trader Guard"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Blueshield Officer"

/obj/effect/landmark/space_traders/porter
	name = "Space Trader Porter"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Trader Porter"

/datum/announcement/centcomm/space_traders
	name = "Event: Space Traders"
	subtitle = "Космоторговцы."
	message = "Мы получили и одобрили запрос на стыковку от группы космоторговцев. " + \
			"У них кончаются припасы и есть товары для продажи. Ожидайте гостей."

/datum/faction/space_traders
	name = F_SPACE_TRADERS
	ID = F_SPACE_TRADERS

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

	var/obj/machinery/computer/trader_shuttle/console = locate() in A
	console.lastmove = world.time

	var/datum/announcement/centcomm/space_traders/announcement = new
	announcement.play()

/datum/faction/space_traders/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/make_money/faction/traders)
	AppendObjective(/datum/objective/trader_purchase)
	AppendObjective(/datum/objective/traders_escape)
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
			high_tier_spawned = TRUE
			if(prob(30))
				product = pick_mech()
			else
				new /obj/structure/rack(T)
				product = pick_high_tier()

			var/O = new product(T)
			if(istype(O, /obj/mecha))
				var/obj/mecha/M = O
				M.operation_req_access = list()

/datum/faction/space_traders/proc/pick_high_tier()
	return pick(
		/obj/item/weapon/gun/medbeam,
		/obj/item/weapon/gun/projectile/revolver/rocketlauncher/commando,
		/obj/item/weapon/gun/energy/gun/portal/loaded,
		/obj/item/weapon/gun/projectile/automatic/m41a)

/datum/faction/space_traders/proc/pick_mech()
	return pickweight(list(
		/obj/mecha/combat/honker/clown = 5,
		/obj/mecha/combat/marauder/mauler = 1,
		/obj/mecha/combat/gygax/dark = 3,
		/obj/mecha/working/ripley/deathripley = 5))
