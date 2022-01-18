/obj/structure/spawner
	icon = 'icons/mob/spawner.dmi'
	desc = " Hole in the ground"
	freeze_movement = TRUE
	can_be_pulled = FALSE
	anchored = TRUE
	density = FALSE
	layer = 1
	pixel_x = -15
	pixel_y = -15
	var/SP
	var/type_mob
	var/max_mob = 3
	var/mob/living/simple_animal/hostile/asteroid/MM

	var/list/spawner_mod = list()
	var/list/mob/living/simple_animal/hostile/asteroid/mobs = list()

//По задумке , при ините логова , все процессы останавливаются ,чтобы нежрать ресурсы сервера. Под гнездом , спавнится арея /obj/structure/spawner_area,котороая при наступании включает логово.
/obj/structure/spawner/atom_init()
	. = ..()
	SP = src
	var/obj/structure/spawner_area/My_area = new/obj/structure/spawner_area(get_turf(src))
	My_area.My_spawner = SP
	new MM
	MM.gen_modifiers()
	spawner_mod = MM.datum_components //Модификаторы пока не работают
	STOP_PROCESSING(SSobj, src)

/obj/structure/spawner/proc/Triggered()
//	if(mobs.len < max_mob)
	var/mob/living/simple_animal/hostile/asteroid/M = new type_mob(get_turf(src))
	mobs += M
	//	for(var/MM in spawner_mod)
		//	M.AddComponent(MM,1)

/obj/structure/spawner_area
	var/width = 5
	var/height = 5 //Починить мультитайловость
	var/obj/structure/spawner/My_spawner
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT Откоментировать когда все доделается

/obj/structure/spawner_area/atom_init()
	. = ..()
	bound_width  = world.icon_size
	bound_height = width * world.icon_size

/obj/structure/spawner_area/proc/try_trigger_spawner(atom/movable/AM,/obj/structure/spawner_area/My_spawner)
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
	type_mob = /mob/living/simple_animal/hostile/asteroid/goliath

/obj/structure/spawner/basilisk
	name = "basilisk nest"
	icon_state = "basilisk"
	type_mob = /mob/living/simple_animal/hostile/asteroid/basilisk

/obj/structure/spawner/hivelord
	name = "hivelord nest"
	icon_state = "hivelord"
	type_mob = /mob/living/simple_animal/hostile/asteroid/hivelord