/obj/structure/spawner
	icon = 'icons/mob/spawner.dmi'
	desc = " Hole in the ground"
	freeze_movement = TRUE
	can_be_pulled = FALSE
	anchored = TRUE
	density = FALSE
	layer = 1
	pixel_x = -16
	pixel_y = -16
	var/SP
	var/type_mob
	var/max_mob = 3
	var/mob/living/simple_animal/hostile/asteroid/MM
	var/obj/structure/spawner_area/My_area
	var/death_icon
	var/is_alive = 1

	var/list/spawner_mod = list()
	var/list/mob/living/simple_animal/hostile/asteroid/mobs = list()
	var/list/loot_ore = list(
							/obj/item/weapon/ore/uranium,
							/obj/item/weapon/ore/phoron,
							/obj/item/weapon/ore/silver,
							/obj/item/weapon/ore/gold,
							/obj/item/weapon/ore/diamond,
							/obj/item/weapon/ore/osmium,
							/obj/item/weapon/ore/hydrogen,
							/obj/item/weapon/ore/slag
							)

//По задумке , при ините логова , все процессы останавливаются ,чтобы нежрать ресурсы сервера. Под гнездом , спавнится арея /obj/structure/spawner_area,котороая при наступании включает логово.
/obj/structure/spawner/atom_init()
	. = ..()
	spawner_mod = pick_modifiers()
	SP = src
	My_area = new/obj/structure/spawner_area(get_turf(src))
	My_area.My_spawner = SP
	STOP_PROCESSING(SSobj, src)

/obj/structure/spawner/process()
	if(is_alive ==0)
		Death()
		icon_state = death_icon
/*	var/turf/T = get_turf(src)
	if(locate(/obj/machinery/mining/drill) in T.contents)
		var/obj/machinery/mining/drill/D
		debug = 1
		if(D.active == 1)
			debug = 2
			is_alive = 0
*/
/obj/structure/spawner/proc/Triggered()
//	if(mobs.len < max_mob)
	if(is_alive == 0)
		return
	var/mob/living/simple_animal/hostile/asteroid/M = new type_mob(get_turf(src))
	mobs += M
	for(var/MM in spawner_mod)
		M.AddComponent(MM,1)

/obj/structure/spawner/proc/Death()
	qdel(My_area)
	for(var/L in loot_ore)
		var/R = rand(0,35)
		for(var/I in R)
			new I(get_turf(src))

/obj/structure/spawner_area
	freeze_movement = TRUE
	can_be_pulled = FALSE
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/width = 6
	var/height = 6
	var/obj/structure/spawner/My_spawner

/obj/structure/spawner_area/atom_init()
	. = ..()
	x -=3
	y -=3
	bound_width  = height * world.icon_size
	bound_height = width * world.icon_size

/obj/structure/spawner_area/proc/try_trigger_spawner(atom/movable/AM)
	if(iscarbon(AM) || issilicon(AM) || istype(AM, /obj/mecha))
		START_PROCESSING(SSobj,My_spawner)
		My_spawner.Triggered()

/obj/structure/spawner_area/Crossed(atom/movable/AM)
	try_trigger_spawner(AM)

/obj/structure/spawner_area/Bumped(atom/movable/AM)
	try_trigger_spawner(AM)

/obj/structure/spawner_area/bullet_act(obj/item/projectile/Proj)
	try_trigger_spawner(Proj)

/obj/structure/spawner/goliath
	name = "goliath nest"
	icon_state = "goliath"
	death_icon = "goliath_death"
	type_mob = /mob/living/simple_animal/hostile/asteroid/goliath

/obj/structure/spawner/basilisk
	name = "basilisk nest"
	icon_state = "basilisk"
	death_icon = "basilisk_death"
	type_mob = /mob/living/simple_animal/hostile/asteroid/basilisk

/obj/structure/spawner/hivelord
	name = "hivelord nest"
	icon_state = "hivelord"
	death_icon = "hivelord_death"
	type_mob = /mob/living/simple_animal/hostile/asteroid/hivelord