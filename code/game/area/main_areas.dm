 //////////////
 //MAIN AREAS//
 //////////////

/area/space
	name = "Space"
	icon_state = "space"
	requires_power = 1
	always_unpowered = 1
	power_light = 0
	power_equip = 0
	power_environ = 0
	valid_territory = 0
	looped_ambience = null
	is_force_ambience = TRUE
	ambience = list(
		'sound/ambience/homm1.ogg',
		'sound/ambience/homm2.ogg',
		'sound/ambience/homm3.ogg')
	outdoors = TRUE

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = 1
