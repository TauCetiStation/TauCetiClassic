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

//TELESTATION

/area/space_structures/telestation
	name = "Tele-Station"
	icon_state = "telestation"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/space_structures/telestation/service
	name = "Telestation Service"
	icon_state = "yellow"

/area/space_structures/telestation/dormitories
	name = "Telestation Dormitories"
	icon_state = "crew_quarters"

/area/space_structures/telestation/chapel
	name = "Telestation Chapel"
	icon_state = "chapel"

/area/space_structures/telestation/cafeteria
	name = "Telestation Cafeteria"
	icon_state = "cafeteria"

/area/space_structures/telestation/kitchen
	name = "Telestation Kitchen"
	icon_state = "kitchen"

/area/space_structures/telestation/engineering
	name = "Telestation Engineering"
	icon_state = "engine"

/area/space_structures/telestation/reactor
	name = "Telestation Reactor"
	icon_state = "engine"

/area/space_structures/telestation/atmospherics
	name = "Telestation Atmospherics"
	icon_state = "atmos"
/area/space_structures/telestation/infirmary
	name = "Telestation Infirmary"
	icon_state = "medbay"

/area/space_structures/telestation/morgue
	name = "Telestation Morgue"
	icon_state = "morgue"

/area/space_structures/telestation/surgery
	name = "Telestation Surgery"
	icon_state = "surgery"

/area/space_structures/telestation/security
	name = "Telestation Security"
	icon_state = "security"

/area/space_structures/telestation/armory
	name = "Telestation Armory"
	icon_state = "armory"

/area/space_structures/telestation/research
	name = "Telestation Laboratories"
	icon_state = "research"

/area/space_structures/telestation/phoron_research
	name = "Telestation Phoron Research"
	icon_state = "toxlab"

/area/space_structures/telestation/robotics
	name = "Telestation Robotics"
	icon_state = "scirobo"

/area/space_structures/telestation/bio_lab
	name = "Telestation Biolab"
	icon_state = "scixeno"

/area/space_structures/telestation/server_room
	name = "Telestation Server Room"
	icon_state = "purple"

/area/space_structures/telestation/bluespace_research
	name = "Telestation Bluespace Research"
	icon_state = "scitele"

/area/space_structures/telestation/maint_sec
	name = "Telestation Security Maintenance"
	icon_state = "dark128"

/area/space_structures/telestation/maint_sci_e
	name = "Telestation Science Maintenance (east)"
	icon_state = "dark128"

/area/space_structures/telestation/maint_sci_w
	name = "Telestation Science Maintenance (west)"
	icon_state = "dark128"

/area/space_structures/telestation/maint_eng
	name = "Telestation Engineering Maintenance"
	icon_state = "dark128"

/area/space_structures/telestation/maint_srv_s
	name = "Telestation Service Maintenance (south)"
	icon_state = "dark128"

/area/space_structures/telestation/maint_srv_n
	name = "Telestation Service Maintenance (north)"
	icon_state = "dark128"

/area/space_structures/telestation/maint_med
	name = "Telestation Medical Maintenance"
	icon_state = "dark128"

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
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/planetarium
	name = "Planetarium"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/robostatoin
	name = "Robostation"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/ghostship
	name = "Ghost Ship"
	icon_state = "yellow"
	always_unpowered = 1
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/delivery_shuttle
	name = "Delivery Shuttle"
	icon_state = "shuttle"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/cloning_lab
	name = "Cloning Facility"
	icon_state = "purple"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/listening_post
	name = "Listening Post"
	icon_state = "syndie-elite"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/space_structures/syndicate_fighter
	name = "Shiv Fighter"
	icon_state = "syndie-elite"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0

/area/space_structures/iss
	name = "Ancient Space Station"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0

/area/space_structures/nasa_satellite
	name = "NASA_satellite"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	looped_ambience = 'sound/music/space_oddity.ogg'

/area/space_structures/derelict_lab
	name = "Abandoned Lab"
	icon_state = "yellow"

/area/space_structures/tree_asteroid
	name = "Tree Asteroid"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0

/area/space_structures/resource_shuttle
	name = "Abandoned Cargo Shuttle"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0

/area/space_structures/nt_fighter_blaton
	name = "NT Fighter \"Blaton\""
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 1

/area/space_structures/nt_fighter_skeora
	name = "NT Fighter \"Skeora\""
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 1

/area/space_structures/nt_troopship
	name = "NT Troopship"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 1

/area/space_structures/secrete_lab
	name = "Secrete Lab"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0

/area/space_structures/broken_breacher
	name = "Broken Breacher"
	icon_state = "broken_breacher"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = 0

/area/space_structures/export_outpost
	name = "TO-11312 Export Outpost"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = TRUE
