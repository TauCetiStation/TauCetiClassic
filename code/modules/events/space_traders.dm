/datum/event/space_traders/start()
	var/datum/faction/space_traders/F = create_uniq_faction(/datum/faction/space_traders)
	create_spawner(/datum/spawner/space_trader/dealer)
	create_spawner(/datum/spawner/space_trader/guard)
	create_spawner(/datum/spawner/space_trader/porter)
	create_products()

	F.AppendObjective(/datum/objective/trader_purchase)
	F.AppendObjective(/datum/objective/traders_escape)

	var/area/A = locate(/area/shuttle/trader/space) in all_areas
	A.parallax_movedir = EAST

	var/obj/machinery/computer/trader_shuttle/console = locate() in global.machines
	console.lastmove = world.time

	var/datum/announcement/centcomm/space_traders/announcement = new
	announcement.play()

/datum/event/space_traders/proc/create_products()
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

/datum/event/space_traders/proc/pick_high_tier()
	return pick(
		/obj/item/weapon/gun/medbeam,
		/obj/item/weapon/gun/projectile/revolver/rocketlauncher/commando,
		/obj/item/weapon/gun/energy/gun/portal/loaded,
		/obj/item/weapon/gun/projectile/automatic/m41a)

/datum/event/space_traders/proc/pick_mech()
	return pickweight(list(
		/obj/mecha/combat/honker/clown = 5,
		/obj/mecha/combat/marauder/mauler = 1,
		/obj/mecha/combat/gygax/dark = 3,
		/obj/mecha/working/ripley/deathripley = 5))
