//TRAIN STATION 13

//TREES AND VARIOUS TRASH SHALL SPAWN RANDOMLY ALONG THE TRACK WITH LARGE ENOUGH INTERVALS NOT TO OVERLAP - MORE TREES, LESS JUNK, RARE STREETLIGHTS
//NEEDS DESPAWNER ON THE END OF CONVEYOR FOR GENERAL OPTIMIZATION AND DIVERSE ENVIRONMENT
//ANCHORED VARIABLE NEEDS TO CHANGE TO FALSE, IF THE CONVEYORS ARE ACTIVE

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

/obj/machinery/conveyor_switch
	var/list/trainspawners

/obj/machinery/conveyor_switch/atom_init_late()
	..()
	trainspawners = list()
	for(var/obj/effect/trainspawner/TR in global.trainspawners)
		if(TR.id == id)
			trainspawners += TR


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

/obj/effect/trainspawner/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/trainspawner/process()
	if(!operating)
		return
	if(next_spawn > world.time)
		return
	next_spawn = world.time + rand(min_delay, max_delay)

	var/list/current_spawn_list = spawn_lists[current_spawn_list_type]
	var/spawn_type = pickweight(current_spawn_list)
	new spawn_type(loc)

/obj/effect/traindespawner
	name = "despawner mark"
	icon = 'icons/hud/screen1.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = TURF_LAYER
	plane = GAME_PLANE
	unacidable = TRUE
	invisibility = INVISIBILITY_ABSTRACT

	var/list/despawn_list = list(
		// /obj/bench,
		// /obj/trash,
		/obj/item/trash/raisins,
		/obj/item/trash/chips,
	)

/obj/effect/traindespawner/atom_init()
	. = ..()
	despawn_list = typecacheof(despawn_list, FALSE)

/obj/effect/traindespawner/Crossed(atom/movable/AM)
	. = ..()
	if(is_type_in_typecache(AM, despawn_list))
		qdel(AM)