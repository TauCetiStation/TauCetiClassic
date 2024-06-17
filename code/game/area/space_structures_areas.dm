 ////////////////////
 //SPACE STRUCTURES//
 ////////////////////

//DJSTATION

/area/space_structures/djstation
	name = "Ruskie DJ Station"
	icon_state = "DJ"

/area/space_structures/djstation/solars
	name = "DJ Station Solars"
	icon_state = "DJ"


//DERELICT

/area/space_structures/derelict
	name = "Derelict Station"
	icon_state = "storage"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/space_structures/derelict/hallway/primary
	name = "Derelict Primary Hallway"
	icon_state = "hallP"

/area/space_structures/derelict/hallway/secondary
	name = "Derelict Secondary Hallway"
	icon_state = "hallS"

/area/space_structures/derelict/arrival
	name = "Derelict Arrival Centre"
	icon_state = "yellow"

/area/space_structures/derelict/bridge
	name = "Derelict Control Room"
	icon_state = "bridge"

/area/space_structures/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/space_structures/derelict/bridge/ai_upload
	name = "Derelict Computer Core"
	icon_state = "ai"

/area/space_structures/derelict/solar_control
	name = "Derelict Solar Control"
	icon_state = "engine"

/area/space_structures/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/space_structures/derelict/medical/chapel
	name = "Derelict Chapel"
	icon_state = "chapel"

/area/space_structures/derelict/solar/starboard
	name = "Derelict Starboard Solar Array"
	icon_state = "panelsS"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/space_structures/derelict/solar/aft
	name = "Derelict Aft Solar Array"
	icon_state = "panelsA"

/area/space_structures/derelict/singularity_engine
	name = "Derelict Singularity Engine"
	icon_state = "engine"

//Random structures

/area/space_structures/teleporter
	name = "Derelict Teleporter"
	icon_state = "teleporter"

/area/space_structures/abandoned_ship
	name = "Abandoned Ship"
	icon_state = "yellow"

/area/space_structures/agrospheregarden
	name = "Agroshere Structure"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = TRUE

/area/space_structures/planetarium
	name = "Planetarium"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = TRUE

/area/space_structures/robostatoin
	name = "Robostation"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = TRUE

/area/space_structures/robostation2
	name = "Robostation2"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = TRUE

/area/space_structures/ghostship
	name = "Ghost Ship"
	icon_state = "yellow"
	always_unpowered = 1
	dynamic_lighting = TRUE

/area/space_structures/delivery_shuttle
	name = "Delivery Shuttle"
	icon_state = "shuttle"
	dynamic_lighting = TRUE

/area/space_structures/cloning_lab
	name = "Cloning Facility"
	icon_state = "purple"
	dynamic_lighting = TRUE

/area/space_structures/listening_post
	name = "Listening Post"
	icon_state = "syndie-elite"
	dynamic_lighting = TRUE

/area/space_structures/syndicate_fighter
	name = "Shiv Fighter"
	icon_state = "syndie-elite"
	dynamic_lighting = TRUE
	requires_power = 0

/area/space_structures/iss
	name = "Ancient Space Station"
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = 0

/area/space_structures/nasa_satellite
	name = "NASA_satellite"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = TRUE
	looped_ambience = 'sound/music/space_oddity.ogg'

/area/space_structures/derelict_lab
	name = "Abandoned Lab"
	icon_state = "yellow"

/area/space_structures/tree_asteroid
	name = "Tree Asteroid"
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = 0

/area/space_structures/resource_shuttle
	name = "Abandoned Cargo Shuttle"
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = 0

/area/space_structures/nt_fighter_blaton
	name = "NT Fighter \"Blaton\""
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = 1

/area/space_structures/nt_fighter_skeora
	name = "NT Fighter \"Skeora\""
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = 1

/area/space_structures/nt_troopship
	name = "NT Troopship"
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = 1

/area/space_structures/secrete_lab
	name = "Secrete Lab"
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = 0

/area/space_structures/broken_breacher
	name = "Broken Breacher"
	icon_state = "broken_breacher"
	dynamic_lighting = TRUE
	requires_power = 0

/area/space_structures/export_outpost
	name = "TO-11312 Export Outpost"
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = TRUE

/area/space_structures/research_ship
	name = "Research Ship"
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = TRUE

/area/space_structures/cult_ship
	name = "Spaceship"
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = TRUE

/area/space_structures/space_villa
	name = "SpaceVilla"
	icon_state = "yellow"
	dynamic_lighting = TRUE
	requires_power = TRUE

// Old Station
/area/space_structures/old_station
	name = "OldStation"
	icon_state = "yellow"
	dynamic_lighting = TRUE


/area/space_structures/old_station/Entered()
	. = ..()
	for(var/obj/effect/spawner/mob_spawn/alien/M in src)
		M.creatMob()

/area/space_structures/old_station/central
	name = "Central Station"
	icon_state = "hallC"
	sound_environment = SOUND_AREA_LARGE_METALLIC
	looped_ambience = 'sound/ambience/loop_maintenance.ogg'

/area/space_structures/old_station/central/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/space_structures/old_station/central/hydro
	name = "Hydroponic"
	icon_state = "hydro"

/area/space_structures/old_station/central/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/space_structures/old_station/central/brig
	name = "Brig"
	icon_state = "brig"

/area/space_structures/old_station/central/solars_c
	name = "Solars control room"
	icon_state = "yellow"



/area/space_structures/old_station/left
	name = "Left Station"
	power_equip = 0
	power_light = 0
	power_environ = 0
	is_force_ambience = TRUE
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg'
	)

/area/space_structures/old_station/left/med
	name = "Medbay"
	icon_state = "medbay"
	ambience = list('sound/ambience/morgue_1.ogg', 'sound/ambience/morgue_2.ogg', 'sound/ambience/morgue_3.ogg')



/area/space_structures/old_station/right
	name = "Right Station"
	icon_state = "scilab"
	sound_environment = SOUND_AREA_LARGE_METALLIC
	looped_ambience = 'sound/ambience/loop_maintenance.ogg'

/area/space_structures/old_station/right/rnd
	name = "Research and Development"
	icon_state = "research"

/area/space_structures/old_station/satellite
	name = "Satellite"
	icon_state = "storage"
	looped_ambience = 'sound/ambience/loop_aisatelite.ogg'
	power_equip = 0
	power_light = 0
	power_environ = 0

/area/space_structures/old_station/warehouse
	name = "Warehouse"
	icon_state = "purple"

/area/space_structures/old_station/armory
	name = "Armory"
	icon_state = "purple"

/area/space_structures/carp_space
	name = "dangerous space"
	icon_state = "space_carps"
	var/static/list/mob_spawn_list = list(
		/mob/living/simple_animal/hostile/carp = 5,
		/mob/living/simple_animal/hostile/carp/megacarp = 1
	)

/area/space_structures/carp_space/atom_init()
	. = ..()
	InitSpawnArea()

// Creates the spawn area component for this area.
/area/space_structures/carp_space/proc/InitSpawnArea()
	// 8 is 1 more than client's view. So mobs spawn right after the view's border
	// 16 is the entire screen diameter + 1. So mobs don't spawn on one side of the screen
	AddComponent(/datum/component/spawn_area,
		"space",
		CALLBACK(src, PROC_REF(spawnmob)),
		CALLBACK(src, PROC_REF(despawn)),
		CALLBACK(src, PROC_REF(checkspawn)),
		8,
		16,
		1 MINUTE,
		1 MINUTE,
	)

/area/space_structures/carp_space/proc/spawnmob(turf/T)
	var/to_spawn = pickweight(mob_spawn_list)
	var/atom/A = new to_spawn(T)
	if(A)
		return list(A)
	return null


/area/space_structures/carp_space/proc/despawn(atom/movable/instance)
	var/mob/M = instance
	if(M.stat == DEAD)
		return
	qdel(M)

/area/space_structures/carp_space/proc/checkspawn(turf/T)
	if(!isspaceturf(T))
		return FALSE
	return T.is_mob_placeable(null)

/area/space_structures/flagship
	name = "Destroyed Flagship"
	icon_state = "syndie-elite"
	dynamic_lighting = TRUE
	ambience = list('sound/ambience/ambiruin4.ogg', 'sound/ambience/syndicate_station.ogg')

/area/space_structures/flagship/Entered()
	. = ..()
	for(var/obj/effect/spawner/mob_spawn/M in src)
		M.creatMob()
