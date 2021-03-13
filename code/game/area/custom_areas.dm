 //////////
 //CUSTOM//
 //////////

//VELOCITY
/area/velocity
	name = "Velocity Dock 42"
	icon_state = "centcom"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

//Alien base
/area/custom/alien
	name = "Alien base"
	icon_state = "yellow"
	requires_power = 0

//SYNDICATES
/area/custom/syndicate_mothership
	name = "Syndicate Mothership"
	icon_state = "syndie-ship"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/custom/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"

/area/custom/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"

/area/custom/syndicate_mothership/armory
	name = "Syndicate Armory"
	icon_state = "syndie-armory"

/area/custom/syndicate_mothership/droppod_garage
	name = "Drop pod garage"

//EXTRA
/area/custom/planet/clown
	name = "Clown Planet"
	icon_state = "honk"
	requires_power = 0

/area/custom/beach
	name = "Keelin's private beach"
	icon_state = "null"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = 0

//ENEMY
/area/custom/abductor_ship
	name = "Abductor Ship"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/custom/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/custom/tophat
	name = "Tophat"
	icon_state = "tophat-room"

/area/custom/cult
	name = "Cult Heaven"
	icon_state = "cult-heaven"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	is_force_ambience = TRUE
	looped_ambience = 'sound/ambience/ambiruin7_looped.ogg'
	ambience = list(
		'sound/ambience/ambiruin1.ogg',
		'sound/ambience/ambiruin2.ogg',
		'sound/ambience/ambiruin3.ogg',
		'sound/ambience/ambiruin4.ogg',
		'sound/ambience/ambiruin5.ogg',
		'sound/ambience/ambiruin6.ogg',
	)

/area/custom/ninjaspawn
	name = "Space Dojo"
	icon_state = "red"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
