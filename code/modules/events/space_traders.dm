/datum/event/space_traders/start()
	var/datum/faction/space_traders/F = create_uniq_faction(/datum/faction/space_traders)
	create_spawner(/datum/spawner/space_trader/dealer)
	create_spawner(/datum/spawner/space_trader/guard)
	create_spawner(/datum/spawner/space_trader/porter)
	create_products()

	F.AppendObjective(/datum/objective/traders_escape)

	var/area/A = locate(/area/shuttle/trader/space) in all_areas
	A.parallax_movedir = EAST

	var/obj/machinery/computer/trader_shuttle/console = locate() in global.machines
	console.lastmove = world.time

	var/datum/announcement/centcomm/space_traders/announcement = new
	announcement.play()

/datum/event/space_traders/proc/create_products()
	return

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
