/mob/living/silicon/spawn_gibs()
	robogibs(loc)

/mob/living/silicon/dust()
	dust_process()
	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/effect/decal/remains/robot(loc)
