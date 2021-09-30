/**********************Mine areas**************************/

/area/asteroid
	name = "Asteroid"
	icon_state = "unexplored"

	outdoors = TRUE

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/asteroid/mine/explored
	name = "Mine"
	icon_state = "explored"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg',
		'sound/music/dwarf_fortress.ogg'
	)


/area/asteroid/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	map_generator = /datum/map_generator/cave_generator
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg',
		'sound/music/dwarf_fortress.ogg'
	)

/area/asteroid/mine/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

	outdoors = FALSE

/area/asteroid/mine/abandoned
	name = "Abandoned Mining Station"
	looped_ambience = 'sound/ambience/loop_space.ogg'

	outdoors = FALSE

/area/asteroid/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

	outdoors = FALSE

/area/asteroid/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

	outdoors = FALSE

/area/asteroid/mine/maintenance
	name = "Mining Station Communications"

	outdoors = FALSE

/area/asteroid/mine/west_outpost
	name = "West Mining Outpost"

	outdoors = FALSE

/area/asteroid/mine/dwarf
	name = "Dwarf"
	icon_state = "dwarf"

	outdoors = FALSE
