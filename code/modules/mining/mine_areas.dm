/**********************Mine areas**************************/

/area/asteroid
	name = "Asteroid"
	icon_state = "unexplored"

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"
	requires_power = 0

/area/asteroid/mine
	icon_state = "mining"

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

/area/asteroid/mine/lobby
	name = "Mining station"

/area/asteroid/mine/storage
	name = "Mining station Storage"

/area/asteroid/mine/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

/area/asteroid/mine/abandoned
	name = "Abandoned Mining Station"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/asteroid/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

/area/asteroid/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/asteroid/mine/maintenance
	name = "Mining Station Communications"

/area/asteroid/mine/cafeteria
	name = "Mining station Cafeteria"

/area/asteroid/mine/hydroponics
	name = "Mining station Hydroponics"

/area/asteroid/mine/sleeper
	name = "Mining station Emergency Sleeper"

/area/asteroid/mine/north_outpost
	name = "North Mining Outpost"

/area/asteroid/mine/west_outpost
	name = "West Mining Outpost"

/area/asteroid/mine/dwarf
	name = "Dwarf"
	icon_state = "dwarf"
