/mob/living/silicon/spawn_gibs()
	new /obj/effect/gibspawner/robot(get_turf(loc), src)

/mob/living/silicon/dust()
	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/effect/decal/remains/robot(loc)
	dust_process()
