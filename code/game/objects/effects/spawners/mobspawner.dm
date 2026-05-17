// static one time use mob spawner for derelicts and other optional areas
// place it on map and it will spawn a mob if someone enters the area
// saves us resources if there is no one around
// for continuous spawns you can look for /datum/component/spawn_area

/obj/effect/spawner/mob_spawn
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "xeno_spawn"
	layer = OBJ_LAYER
	invisibility = INVISIBILITY_OBSERVER
	var/mob_type = /mob/living/simple_animal

/obj/effect/spawner/mob_spawn/atom_init(mapload, view)
	. = ..()

	var/area/A = get_area(src)
	LAZYADD(A.mob_spawners, src)

/obj/effect/spawner/mob_spawn/proc/creatMob()
	var/area/A = get_area(src)
	LAZYREMOVE(A.mob_spawners, src)

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

/obj/effect/spawner/mob_spawn/carp
	mob_type = /mob/living/simple_animal/hostile/carp
	icon_state = "carp_spawn"

/obj/effect/spawner/mob_spawn/carp/rex
	mob_type = /mob/living/simple_animal/hostile/carp/dog
	icon_state = "rex_spawn"

/obj/effect/spawner/mob_spawn/carp/polkan
	mob_type = /mob/living/simple_animal/hostile/carp/dog/polkan
	icon_state = "polkan_spawn"

/obj/effect/spawner/mob_spawn/pug_agrosphere
	mob_type = /mob/living/simple_animal/pug/pug_agrosphere
	icon_state = "pug_spawn"

/obj/effect/spawner/mob_spawn/tomato
	mob_type = /mob/living/simple_animal/hostile/tomato
	icon_state = "tomato_spawn"

/obj/effect/spawner/mob_spawn/tomato_agrosphere
	mob_type = /mob/living/simple_animal/hostile/tomato/tomato_agrosphere
	icon_state = "tomato_spawn"

/obj/effect/spawner/mob_spawn/cellular/meat/flesh
	mob_type = /mob/living/simple_animal/hostile/cellular/meat/flesh
	icon_state = "cellular_spawn"

/obj/effect/spawner/mob_spawn/cellular/meat/creep_standing
	mob_type = /mob/living/simple_animal/hostile/cellular/meat/creep_standing
	icon_state = "cellular_spawn"

/obj/effect/spawner/mob_spawn/cellular/meat/maniac
	mob_type = /mob/living/simple_animal/hostile/cellular/meat/maniac
	icon_state = "cellular_spawn"

/obj/effect/spawner/mob_spawn/crab
	mob_type = /mob/living/simple_animal/crab
	icon_state = "crab_spawn"

/obj/effect/spawner/mob_spawn/cyber_horror
	mob_type = /mob/living/simple_animal/hostile/cyber_horror
	icon_state = "cyber_horror_spawn"

/obj/effect/spawner/mob_spawn/fake_runtime
	mob_type = /mob/living/simple_animal/cat/runtime/fake
	icon_state = "fake_runtime_spawn"

/obj/effect/spawner/mob_spawn/syndicate_walrus
	mob_type = /mob/living/simple_animal/walrus/syndicate
	icon_state = "walrus_spawn"

/obj/effect/spawner/mob_spawn/hivebot
	mob_type = /mob/living/simple_animal/hostile/hivebot
	icon_state = "hivebot_spawn"

/obj/effect/spawner/mob_spawn/hivebot/range
	mob_type = /mob/living/simple_animal/hostile/hivebot

/obj/effect/spawner/mob_spawn/hivebot/strong
	mob_type = /mob/living/simple_animal/hostile/hivebot/strong

/obj/effect/spawner/mob_spawn/viscerator
	mob_type = /mob/living/simple_animal/hostile/viscerator
	icon_state = "viscerator_spawn"

/obj/effect/spawner/mob_spawn/syndicate_ranged_elite
	mob_type = /mob/living/simple_animal/hostile/syndicate/ranged/space/elite
	icon_state = "elite_range_spawn"

/obj/effect/spawner/mob_spawn/wiz_goat
	mob_type = /mob/living/simple_animal/hostile/retaliate/goat
	icon_state = "goat_spawn"

/obj/effect/spawner/mob_spawn/wiz_creature
	mob_type = /mob/living/simple_animal/hostile/retaliate/goat
	icon_state = "creature_spawn"

/obj/effect/spawner/mob_spawn/wiz_monkey
	mob_type = /mob/living/carbon/monkey
	icon_state = "monkey_spawn"

/obj/effect/spawner/mob_spawn/wiz_tribesman
	mob_type = /mob/living/simple_animal/hostile/tribesman
	icon_state = "tribesman_spawn"

/obj/effect/spawner/mob_spawn/nuke_mouse
	mob_type = /mob/living/simple_animal/mouse/nuke
	icon_state = "nuke_mouse_spawn"

/obj/effect/spawner/mob_spawn/nuke_cat
	mob_type = /mob/living/simple_animal/cat/Syndi
	icon_state = "nuke_cat_spawn"
