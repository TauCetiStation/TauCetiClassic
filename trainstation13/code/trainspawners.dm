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
	set name = "TS13 Decorations - Toggle Spawners on/off"

	global.globally_operating = !global.globally_operating
	to_chat(src, "Toggled spawners to [global.globally_operating ? "ON" :  "OFF"]")

	for(var/obj/effect/trainspawner/T as anything in global.trainspawners)
		T.globally_operating = global.globally_operating
//	for(var/obj/effect/traindespawner/T as anything in global.traindespawners)//Toggles despawner if needed
//		T.globally_operating = global.globally_operating

/client/proc/change_global_spawn_list_type()
	set category = "Event"
	set name = "TS13 Decorations - Change Spawn List Type"

	var/prev_spawn_list_type = global.spawn_list_type
	global.spawn_list_type = global.spawn_list_type == "normal" ? "station" : "normal"
	to_chat(src, "Changed Spawn List Type from [prev_spawn_list_type] to [global.spawn_list_type]")

	for(var/obj/effect/trainspawner/T as anything in global.trainspawners)
		T.current_spawn_list_type = global.spawn_list_type

var/global/list/trainspawners = list()
ADD_TO_GLOBAL_LIST(/obj/effect/trainspawner, trainspawners)

/obj/effect/trainspawner //Middle conveyor relative to the train!
	name = "middle spawner mark"
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
			"null" = 20,
			/obj/machinery/floodlight = 10,
			/obj/structure/flora/tree/pine/train = 20,
			/obj/structure/flora/tree/dead/train = 90,
			/obj/structure/flora/ausbushes/fullgrass/train = 20,
			/obj/structure/flora/ausbushes/sparsegrass/train = 20,
			/obj/structure/flora/ausbushes/lavendergrass/train = 20,
			/obj/structure/flora/ausbushes/palebush/train = 5,
			/obj/structure/flora/ausbushes/grassybush/train = 5,
			/obj/structure/flora/ausbushes/stalkybush/train = 10,
			/obj/structure/flora/ausbushes/reedbush/train = 10,
			/obj/structure/flora/mine_rocks/train = 10,
			/obj/structure/bear_piano = 1,
			/obj/structure/bear_harmonica = 1,
			/obj/structure/bear_vodka = 1,
			/obj/item/stack/rods = 2,
			/obj/item/weapon/grown/log = 2,
			/obj/item/weapon/cigbutt = 5,
			/obj/item/weapon/cigbutt/cigarbutt = 1,
			/obj/item/trash/semki = 2,
			/obj/item/trash/popcorn = 2,
			/obj/item/trash/sosjerky = 2,
			/obj/item/trash/candy = 2,
			/obj/item/trash/raisins = 2,
			/obj/item/trash/chips = 2,
			/obj/item/trash/pistachios = 2,
			/obj/structure/atomobile/derelict = 1,
			/obj/structure/scrap/medical/train = 1,
			/obj/structure/scrap/medical/large/train = 1,
			/obj/structure/scrap/vehicle/train = 1,
			/obj/structure/scrap/vehicle/large/train = 1,
			/obj/structure/scrap/food/train = 1,
			/obj/structure/scrap/food/large/train = 1,
			/obj/structure/scrap/poor/train = 1,
			/obj/structure/scrap/poor/large/train = 1,
		),
		"station" = list(
			// benches and stuff
			"null" = 50,
			/obj/structure/bench = 50,
			/obj/structure/closet/crate/bin = 50,
		),
	)

	var/min_delay = 2 SECONDS
	var/max_delay = 16 SECONDS

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

/obj/effect/trainspawner/close //Closest conveyor relative to the train!
	name = "close spawner mark"
	spawn_lists = list(
		"normal" = list(
			"null" = 90,
			/obj/structure/flora/ausbushes/fullgrass/train = 20,
			/obj/structure/flora/ausbushes/sparsegrass/train = 20,
			/obj/structure/flora/ausbushes/lavendergrass/train = 20,
			/obj/structure/flora/ausbushes/palebush/train = 2,
			/obj/structure/flora/ausbushes/grassybush/train = 2,
			/obj/structure/flora/ausbushes/stalkybush/train = 10,
			/obj/structure/flora/ausbushes/reedbush/train = 10,
			/obj/item/weapon/cigbutt = 30,
			/obj/item/weapon/cigbutt/cigarbutt = 2,
			/obj/item/trash/semki = 5,
			/obj/item/trash/popcorn =5,
			/obj/item/trash/sosjerky = 5,
			/obj/item/trash/candy = 5,
			/obj/item/trash/raisins = 5,
			/obj/item/trash/chips = 5,
			/obj/item/trash/pistachios = 10,
			/obj/structure/scrap/medical/train = 1,
			/obj/structure/scrap/medical/large/train = 1,
			/obj/structure/scrap/vehicle/train = 1,
			/obj/structure/scrap/vehicle/large/train = 1,
			/obj/structure/scrap/food/train = 1,
			/obj/structure/scrap/food/large/train = 1,
			/obj/structure/scrap/poor/train = 1,
			/obj/structure/scrap/poor/large/train = 1,
		),
		"station" = list(
			"null" = 80,
			/obj/item/weapon/cigbutt = 20,
			/obj/item/weapon/cigbutt/cigarbutt = 1,
			/obj/item/trash/semki = 2,
			/obj/item/trash/popcorn =2,
			/obj/item/trash/sosjerky = 2,
			/obj/item/trash/candy = 2,
			/obj/item/trash/raisins = 2,
			/obj/item/trash/chips = 2,
			/obj/item/trash/pistachios = 2,
		),
	)

/obj/effect/trainspawner/far //Furthest conveyor relative to the train!
	name = "far spawner mark"
	spawn_lists = list(
		"normal" = list(
			"null" = 10,
			/obj/structure/flora/tree/pine/train = 10,
			/obj/structure/flora/tree/dead/train = 90,
			/obj/structure/flora/ausbushes/fullgrass/train = 30,
			/obj/structure/flora/ausbushes/sparsegrass/train = 30,
			/obj/structure/flora/ausbushes/lavendergrass/train = 30,
			/obj/structure/flora/ausbushes/palebush/train = 10,
			/obj/structure/flora/ausbushes/grassybush/train = 10,
			/obj/structure/flora/ausbushes/stalkybush/train = 30,
			/obj/structure/flora/ausbushes/reedbush/train = 20,
			/obj/structure/flora/mine_rocks/train = 10,
			/obj/item/stack/rods = 2,
			/obj/item/weapon/grown/log = 2,
			/obj/item/trash/semki = 1,
			/obj/item/trash/popcorn = 1,
			/obj/item/trash/sosjerky = 1,
			/obj/item/trash/candy = 1,
			/obj/item/trash/raisins = 1,
			/obj/item/trash/chips = 1,
			/obj/item/trash/pistachios = 1,
			/obj/structure/scrap/medical/train = 1,
			/obj/structure/scrap/medical/large/train = 1,
			/obj/structure/scrap/vehicle/train = 1,
			/obj/structure/scrap/vehicle/large/train = 1,
			/obj/structure/scrap/food/train = 1,
			/obj/structure/scrap/food/large/train = 1,
			/obj/structure/scrap/poor/train = 1,
			/obj/structure/scrap/poor/large/train = 1,
		),
		"station" = list(
			"null" = 100,
		),
	)

//DESPAWNER

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
		/obj/item/trash/raisins,
		/obj/item/trash/chips,
		/obj/machinery/floodlight,
		/obj/machinery/trainsignal,
		/obj/item/weapon/stock_parts/cell/high,
		/obj/structure/bench,
		/obj/structure/flora/tree/pine/train,
		/obj/structure/flora/tree/dead/train,
		/obj/structure/flora/ausbushes/fullgrass/train,
		/obj/structure/flora/ausbushes/sparsegrass/train,
		/obj/structure/flora/ausbushes/lavendergrass/train,
		/obj/structure/flora/ausbushes/palebush/train,
		/obj/structure/flora/ausbushes/grassybush/train,
		/obj/structure/flora/ausbushes/stalkybush/train,
		/obj/structure/flora/ausbushes/reedbush/train,
		/obj/structure/flora/mine_rocks/train,
		/obj/structure/bear_piano,
		/obj/structure/bear_harmonica,
		/obj/structure/bear_vodka,
		/obj/item/weapon/cigbutt,
		/obj/item/weapon/cigbutt/cigarbutt,
		/obj/item/trash/semki,
		/obj/item/trash/popcorn,
		/obj/item/trash/sosjerky,
		/obj/item/trash/candy,
		/obj/item/trash/raisins,
		/obj/item/trash/chips,
		/obj/item/trash/pistachios,
		/obj/structure/atomobile/derelict,
		/obj/structure/scrap/medical/train,
		/obj/structure/scrap/medical/large/train,
		/obj/structure/scrap/vehicle/train,
		/obj/structure/scrap/vehicle/large/train,
		/obj/structure/scrap/food/train,
		/obj/structure/scrap/food/large/train,
		/obj/structure/scrap/poor/train,
		/obj/structure/scrap/poor/large/train,
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

//GARBAGE

/obj/structure/scrap/medical/train
	anchored = FALSE

/obj/structure/scrap/medical/large/train
	anchored = FALSE

/obj/structure/scrap/vehicle/train
	anchored = FALSE

/obj/structure/scrap/vehicle/large/train
	anchored = FALSE

/obj/structure/scrap/food/train
	anchored = FALSE

/obj/structure/scrap/food/large/train
	anchored = FALSE

/obj/structure/scrap/poor/train
	anchored = FALSE

/obj/structure/scrap/poor/large/train
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
	icon = 'trainstation13/icons/television.dmi'
	icon_state = "bear_harmonica"
	anchored = FALSE

/obj/structure/bear_vodka
	name = "bear"
	desc = "This alien space bear had just enough to dance happily. You see nothing out of the ordinary?"
	icon = 'trainstation13/icons/television.dmi'
	icon_state = "bear_vodka"
	anchored = FALSE