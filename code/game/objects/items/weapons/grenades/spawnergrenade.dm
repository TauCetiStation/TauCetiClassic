/obj/item/weapon/grenade/spawnergrenade
	desc = "It is set to detonate in 5 seconds. It will unleash unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4"
	var/banglet = 0
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver

/obj/item/weapon/grenade/spawnergrenade/prime()
	if(spawner_type && deliveryamt)
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

		// Spawn some enemies
		for(var/i in 1 to deliveryamt)
			var/atom/movable/x = new spawner_type
			x.loc = T
			if(prob(50))
				for(var/j in 1 to rand(1, 3))
					step(x, pick(NORTH,SOUTH,EAST,WEST))
	qdel(src)
	return

/obj/item/weapon/grenade/spawnergrenade/manhacks
	name = "manhack delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/spawnergrenade/syndiesoap
	name = "Mister Scrubby"
	spawner_type = /obj/item/weapon/soap/syndie
