 ////////////////////
 //SPACE STRUCTURES//
 ////////////////////

//DJSTATION

/area/space_structures/djstation
	name = "Unidentified Station"
	icon_state = "DJ"

/area/space_structures/djstation/solars
	name = "Unidentified Station Solars"
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
	name = "Unidentified Structure"
	icon_state = "teleporter"

/area/space_structures/abandoned_ship
	name = "Unidentified Ship"
	icon_state = "yellow"

/area/space_structures/agrospheregarden
	name = "Unidentified Structure"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/planetarium
	name = "Unidentified Structure"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/robostatoin
	name = "Unidentified Station"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/ghostship
	name = "Unidentified Ship"
	icon_state = "yellow"
	always_unpowered = 1
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/delivery_shuttle
	name = "Unidentified Shuttle"
	icon_state = "shuttle"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/cloning_lab
	name = "Unidentified Structure"
	icon_state = "purple"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/listening_post
	name = "Remote Asteroid"
	icon_state = "syndie-elite"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/syndicate_fighter
	name = "Unidentified Ship"
	icon_state = "syndie-elite"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0

/area/space_structures/iss
	name = "Unidentified Station"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0

/area/space_structures/nasa_satellite
	name = "Unidentified Satellite"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	looped_ambience = 'sound/music/space_oddity.ogg'

/area/space_structures/derelict_lab
	name = "Unidentified Station"
	icon_state = "yellow"

/area/space_structures/lost_asteroid
	name = "Remote Asteroid"
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

/area/space_structures/collector_ship
	name = "Unidentified Ship"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/mercenary_pod
	name = "Unidentified Shuttle"
	icon_state = "syndie-elite"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED