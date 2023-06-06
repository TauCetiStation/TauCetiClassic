//TRAIN STATION 13

//Code by Luduk/LudwigVonChesterfield.
//This module is responsible for spawning and cleaning up the decorations moving past the train.

/obj/machinery/conveyor_switch
	var/list/trainspawners

/obj/machinery/conveyor_switch/atom_init_late()
	..()
	trainspawners = list()
	for(var/obj/effect/trainspawner/TR in global.trainspawners)
		if(TR.id == id)
			trainspawners += TR

var/global/globally_operating = TRUE
var/global/spawn_list_type = "normal"

/client/proc/toggle_train_spawners_and_despawners()
	set category = "Event"
	set name = "Toggle Spawners and Despawners"

	global.globally_operating = !global.globally_operating
	to_chat(src, "Toggled spawners and despawners to [global.globally_operating ? "ON" :  "OFF"]")

	for(var/obj/effect/trainspawner/T as anything in global.trainspawners)
		T.globally_operating = global.globally_operating
	for(var/obj/effect/traindespawner/T as anything in global.traindespawners)
		T.globally_operating = global.globally_operating

/client/proc/change_global_spawn_list_type()
	set category = "Event"
	set name = "Change Spawn List Type"

	var/prev_spawn_list_type = global.spawn_list_type
	global.spawn_list_type = global.spawn_list_type == "normal" ? "normal" : "station"
	to_chat(src, "Changed Spawn List Type from [prev_spawn_list_type] to [global.spawn_list_type]")

	for(var/obj/effect/trainspawner/T as anything in global.trainspawners)
		T.current_spawn_list_type = global.spawn_list_type

var/global/list/trainspawners = list()
ADD_TO_GLOBAL_LIST(/obj/effect/trainspawner, trainspawners)

/obj/effect/trainspawner
	name = "spawner mark"
	icon = 'icons/hud/screen1.dmi'
	icon_state = "x2"
	anchored = TRUE
	layer = TURF_LAYER
	plane = GAME_PLANE
	unacidable = TRUE
	invisibility = INVISIBILITY_ABSTRACT

	// Which conveyor id this trainspawner is linked to.
	var/id

	var/globally_operating = TRUE

	var/operating = FALSE

	var/current_spawn_list_type = "normal"

	var/list/spawn_lists = list(
		"normal" = list(
			// trees grass and stuff, example below
			// /obj/tree = 100,
			// /obj/grass = 90,
			// /mob/bear = 10,
			// /mob/easteregg = 1,
			/obj/item/trash/raisins = 1,
		),
		"station" = list(
			// benches and stuff
			// /obj/bench = 100,
			// /obj/trash = 10,
			// /mob/easteregg = 1,
			/obj/item/trash/chips = 1,
		),
	)

	var/min_delay = 5 SECONDS
	var/max_delay = 10 SECONDS

	var/next_spawn = 0

/obj/effect/trainspawner/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

	globally_operating = global.globally_operating
	current_spawn_list_type = global.spawn_list_type

/obj/effect/trainspawner/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/trainspawner/process()
	if(!globally_operating)
		return
	if(!operating)
		return
	if(next_spawn > world.time)
		return
	next_spawn = world.time + rand(min_delay, max_delay)

	var/list/current_spawn_list = spawn_lists[current_spawn_list_type]
	var/spawn_type = pickweight(current_spawn_list)
	if(spawn_type == "null")
		return
	new spawn_type(loc)

var/global/list/traindespawners = list()
ADD_TO_GLOBAL_LIST(/obj/effect/traindespawner, traindespawners)

/obj/effect/traindespawner
	name = "despawner mark"
	icon = 'icons/hud/screen1.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = TURF_LAYER
	plane = GAME_PLANE
	unacidable = TRUE
	invisibility = INVISIBILITY_ABSTRACT

	var/globally_operating = TRUE

	var/list/despawn_list = list(
		// /obj/bench,
		// /obj/trash,
		/obj/item/trash/raisins,
		/obj/item/trash/chips,
	)

/obj/effect/traindespawner/atom_init()
	. = ..()
	despawn_list = typecacheof(despawn_list, FALSE)

	globally_operating = global.globally_operating

/obj/effect/traindespawner/Crossed(atom/movable/AM)
	. = ..()
	if(!globally_operating)
		return

	if(is_type_in_typecache(AM, despawn_list))
		qdel(AM)

//UNIQUE SPAWNED OBJECTS BELOW

//FLORA

/obj/structure/flora/tree/pine/train
	anchored = FALSE

/obj/structure/flora/tree/dead/train
	anchored = FALSE

/obj/structure/flora/ausbushes/fullgrass/train
	anchored = FALSE

/obj/structure/flora/ausbushes/sparsegrass/train
	anchored = FALSE

/obj/structure/flora/ausbushes/lavendergrass/train
	anchored = FALSE

/obj/structure/flora/ausbushes/palebush/train
	anchored = FALSE

/obj/structure/flora/ausbushes/grassybush/train
	anchored = FALSE

/obj/structure/flora/ausbushes/stalkybush/train
	anchored = FALSE

/obj/structure/flora/ausbushes/reedbush/train
	anchored = FALSE

/obj/structure/flora/mine_rocks/train
	anchored = FALSE

//EASTER EGGS

/obj/structure/bear_piano
	name = "bear"
	desc = "Looks like this is not your common black bear, it's an alien space bear playing a piano. You see nothing out of the ordinary?"
	icon = 'trainstation13/icons/64x32.dmi'
	icon_state = "bear_piano"
	anchored = FALSE

/obj/structure/bear_harmonica
	name = "bear"
	desc = "And I'm playing the accordion. And all people gaze at me. It's a pity, that the Birthday is just once a year..."
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "bear_harmonica"
	anchored = FALSE

/obj/structure/bear_vodka
	name = "bear"
	desc = "This alien space bear had just enough to dance happily. You see nothing out of the ordinary?"
	icon = 'trainstation13/icons/trainstructures.dmi'
	icon_state = "bear_vodka"
	anchored = FALSE