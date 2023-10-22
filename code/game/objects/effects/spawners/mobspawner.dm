/obj/effect/spawner/mob_spawn
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "xeno_spawn"
	layer = OBJ_LAYER
	var/mob_type = /mob/living/simple_animal


/obj/effect/spawner/mob_spawn/proc/creatMob()
	new mob_type (src.loc)
	qdel(src)

/obj/effect/spawner/mob_spawn/alien
	mob_type = /mob/living/simple_animal/hostile/xenomorph //hunter

/obj/effect/spawner/mob_spawn/alien/drone
	mob_type = /mob/living/simple_animal/hostile/xenomorph/drone

/obj/effect/spawner/mob_spawn/alien/sentinel
	mob_type = /mob/living/simple_animal/hostile/xenomorph/sentinel

/obj/effect/spawner/mob_spawn/alien/queen
	mob_type = /mob/living/simple_animal/hostile/xenomorph/queen

/obj/effect/spawner/mob_spawn/drone
	mob_type = /mob/living/simple_animal/hostile/retaliate/malf_drone/dangerous
	icon_state = "drone_spawn"
