/turf/simulated/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist."
	icon_state = "box"
	canSmoothWith = null
	smooth = SMOOTH_TRUE

/turf/simulated/wall/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/has_false_walls/uranium_wall.dmi'
	mineral = "uranium"
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	canSmoothWith = list(/turf/simulated/wall/mineral/uranium, /obj/structure/falsewall/uranium)

	var/last_event = 0
	var/active = null

/turf/simulated/wall/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event + 15)
			active = 1
			for(var/mob/living/L in range(3, src))
				L.apply_effect(12, IRRADIATE, 0)
			for(var/turf/simulated/wall/mineral/uranium/T in range(3, src))
				T.radiate()
			last_event = world.time
			active = null

/turf/simulated/wall/mineral/uranium/attack_hand(mob/user)
	radiate()
	..()

/turf/simulated/wall/mineral/uranium/attackby(obj/item/weapon/W, mob/user)
	radiate()
	..()

/turf/simulated/wall/mineral/uranium/Bumped(AM)
	radiate()
	..()

/turf/simulated/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon = 'icons/turf/walls/has_false_walls/gold_wall.dmi'
	mineral = "gold"
	sheet_type = /obj/item/stack/sheet/mineral/gold
	canSmoothWith = list(/turf/simulated/wall/mineral/gold, /obj/structure/falsewall/gold)

/turf/simulated/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon = 'icons/turf/walls/has_false_walls/silver_wall.dmi'
	mineral = "silver"
	sheet_type = /obj/item/stack/sheet/mineral/silver
	canSmoothWith = list(/turf/simulated/wall/mineral/silver, /obj/structure/falsewall/silver)

/turf/simulated/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon = 'icons/turf/walls/has_false_walls/diamond_wall.dmi'
	mineral = "diamond"
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	canSmoothWith = list(/turf/simulated/wall/mineral/diamond, /obj/structure/falsewall/diamond)

/turf/simulated/wall/mineral/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon = 'icons/turf/walls/has_false_walls/bananium_wall.dmi'
	mineral = "bananium"
//	sheet_type = /obj/item/stack/sheet/mineral/bananium
	canSmoothWith = list(/turf/simulated/wall/mineral/bananium, /obj/structure/falsewall/bananium)

/turf/simulated/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon = 'icons/turf/walls/has_false_walls/sandstone_wall.dmi'
	mineral = "sandstone"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	canSmoothWith = list(/turf/simulated/wall/mineral/sandstone, /obj/structure/falsewall/sandstone)
