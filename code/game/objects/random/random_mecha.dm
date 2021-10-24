
//GUNS RANDOM
/obj/random/mecha/wreckage
	name = "Random Mecha Wreckage"
	desc = "This is a random security sidearm."
	icon = 'icons/obj/gun.dmi'
	icon_state = "9mm_glock"
/obj/random/mecha/wreckage/item_to_spawn()
		return pick(\
						prob(45);/obj/effect/decal/mecha_wreckage/ripley,\
						prob(45);/obj/effect/decal/mecha_wreckage/ripley/firefighter,\
						prob(45);/obj/effect/decal/mecha_wreckage/odysseus,\
						prob(7);/obj/effect/decal/mecha_wreckage/durand,\
						prob(7);/obj/effect/decal/mecha_wreckage/gygax,\
						prob(4);/obj/effect/decal/mecha_wreckage/durand/vindicator,\
						prob(4);/obj/effect/decal/mecha_wreckage/gygax/ultra\
					)

/obj/random/mecha/working
	name = "Random Working Mecha"
	desc = "This is a random security sidearm."
	icon = 'icons/obj/gun.dmi'
	icon_state = "9mm_glock"
/obj/random/mecha/working/item_to_spawn()
		return pick(\
						prob(60);/obj/mecha/working/hoverpod,\
						prob(50);/obj/mecha/working/ripley,\
						prob(50);/obj/mecha/medical/odysseus,\
						prob(50);/obj/mecha/working/ripley/firefighter,\
						prob(25);/obj/mecha/working/ripley/mining,\
						prob(9);/obj/mecha/combat/honker,\
						prob(5);/obj/mecha/combat/gygax,\
						prob(5);/obj/mecha/combat/durand,\
						prob(5);/obj/mecha/combat/gygax/ultra,\
						prob(5);/obj/mecha/combat/durand/vindicator,\
						prob(5);/obj/mecha/combat/marauder,\
						prob(5);/obj/mecha/working/ripley/deathripley,\
						prob(4);/obj/mecha/working/ripley/deathripley/pirate,\
						prob(2);/obj/mecha/combat/gygax/dark,\
						prob(2);/obj/mecha/combat/marauder/seraph,\
						prob(2);/obj/mecha/combat/marauder/mauler,\
						prob(2);/obj/mecha/combat/marauder/loaded,\
						prob(1);/obj/mecha/combat/phazon\
					)


