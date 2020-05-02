/**********************Mine areas**************************/

/area/asteroid
	name = "Asteroid"
	icon_state = "unexplored"

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"
	requires_power = 0

/area/asteroid/mine/explored
	name = "Mine"
	icon_state = "explored"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	power_equip = 0
	power_light = 0
	power_environ = 0
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
	power_equip = 0
	power_light = 0
	power_environ = 0
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

/area/asteroid/mine/abandoned
	name = "Abandoned Mining Station"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	icon_state = "mining_abandoned"

/area/asteroid/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

/area/asteroid/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/asteroid/mine/maintenance
	name = "Mining Station Communications"
	icon_state = "mining_telecom"

/area/asteroid/mine/west_outpost
	name = "West Mining Outpost"
	icon_state = "mining_outpost"

/area/asteroid/mine/west_outpost_external
	name = "West Mining Outpost External"
	icon_state = "mining_outpost_external"

/area/asteroid/mine/dwarf
	name = "Dwarf"
	icon_state = "dwarf"

/area/asteroid/mine/southwest
	name = "South-west mining"
	icon_state = "mining_southwest"

/area/asteroid/mine/east
	name = "East mining"
	icon_state = "mining_east"

/area/asteroid/mine/mine_science
	name = "Mine science"
	icon_state = "mining_science"
