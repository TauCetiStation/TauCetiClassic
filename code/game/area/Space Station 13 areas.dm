/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)
	music = "music/music.ogg"		(defaults to "music/music.ogg")

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/*-----------------------------------------------------------------------------*/

 /////////
 //SPACE//
 /////////

/area/space
	name = "Space"
	icon_state = "space"
	requires_power = 1
	always_unpowered = 1
	power_light = 0
	power_equip = 0
	power_environ = 0
	valid_territory = 0


//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	requires_power = 0
	valid_territory = 0

/area/shuttle/arrival
	name = "Arrival Shuttle"

/area/shuttle/arrival/pre_game
	name = "Tau Ceti Transfer Station 13"
	icon_state = "shuttle2"

/area/shuttle/arrival/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

/area/shuttle/arrival/station
	name = "NSS Exodus"
	icon_state = "shuttle"

/area/shuttle/escape
	name = "Emergency Shuttle"
	music = "music/escape.ogg"

/area/shuttle/escape/station
	name = "Emergency Shuttle Station"
	icon_state = "shuttle2"

/area/shuttle/escape/centcom
	name = "Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/escape/transit // the area to pass through for 3 minute transit
	name = "Emergency Shuttle Transit"
	icon_state = "shuttle"
	parallax_movedir = WEST

/area/shuttle/escape_pod1
	name = "Escape Pod One"
	music = "music/escape.ogg"

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

/area/shuttle/escape_pod2
	name = "Escape Pod Two"
	music = "music/escape.ogg"

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

/area/shuttle/escape_pod3
	name = "Escape Pod Three"
	music = "music/escape.ogg"

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
	name = "Escape Pod Five"
	music = "music/escape.ogg"

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"
	parallax_movedir = WEST

/area/shuttle/mining
	name = "Mining Shuttle"
	music = "music/escape.ogg"

/area/shuttle/mining/station
	icon_state = "shuttle2"

/area/shuttle/mining/outpost
	icon_state = "shuttle"

/area/shuttle/transport1/centcom
	icon_state = "shuttle"
	name = "Transport Shuttle Centcom"

/area/shuttle/transport1/station
	icon_state = "shuttle"
	name = "Transport Shuttle"

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "Alien Shuttle Base"
	requires_power = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "Alien Shuttle Mine"
	requires_power = 1

/area/shuttle/specops/centcom
	name = "Special Ops Shuttle"
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "Special Ops Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite/mothership
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/administration/centcom
	name = "Administration Shuttle Centcom"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "Administration Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/research
	name = "Research Shuttle"
	music = "music/escape.ogg"
	icon_state = "shuttle"

/area/shuttle/vox/station
	name = "Vox Skipjack"
	icon_state = "yellow"
	requires_power = 0

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = 0
	dynamic_lighting = 0
	has_gravity = 1

// === end remove

/area/alien
	name = "Alien base"
	icon_state = "yellow"
	requires_power = 0

// CENTCOM

/area/centcom
	name = "Centcom"
	icon_state = "centcom"
	requires_power = 0

/area/centcom/control
	name = "Centcom Control"

/area/centcom/evac
	name = "Centcom Emergency Shuttle"

/area/centcom/suppy
	name = "Centcom Supply Shuttle"

/area/centcom/ferry
	name = "Centcom Transport Shuttle"

/area/centcom/shuttle
	name = "Centcom Administration Shuttle"

/area/centcom/test
	name = "Centcom Testing Facility"

/area/centcom/living
	name = "Centcom Living Quarters"

/area/centcom/specops
	name = "Centcom Special Ops"

/area/centcom/creed
	name = "Creed's Office"

/area/centcom/holding
	name = "Holding Facility"

/area/centcom/arrival
	name = "Arrival Shuttle Dock"


//SYNDICATES

/area/syndicate_mothership
	name = "Syndicate Mothership"
	icon_state = "syndie-ship"
	requires_power = 0

/area/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"

/area/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"

/area/syndicate_mothership/droppod_garage
	name = "Drop pod garage"

//EXTRA

/area/asteroid					// -- TLE
	name = "Asteroid"
	icon_state = "asteroid"
	requires_power = 0

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"

/area/planet/clown
	name = "Clown Planet"
	icon_state = "honk"
	requires_power = 0

/area/tdome
	name = "Thunderdome"
	icon_state = "thunder"
	requires_power = 0

/area/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "yellow"

/area/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "Thunderdome (Observer.)"
	icon_state = "purple"


//ENEMY

//names are used
/area/syndicate_station
	name = "Syndicate Station"
	icon_state = "yellow"
	requires_power = 0

/area/syndicate_station/start
	name = "Syndicate Forward Operating Base"
	icon_state = "yellow"

/area/syndicate_station/southwest
	name = "south-west of SS13"
	icon_state = "southwest"

/area/syndicate_station/northwest
	name = "north-west of SS13"
	icon_state = "northwest"

/area/syndicate_station/northeast
	name = "north-east of SS13"
	icon_state = "northeast"

/area/syndicate_station/southeast
	name = "south-east of SS13"
	icon_state = "southeast"

/area/syndicate_station/north
	name = "north of SS13"
	icon_state = "north"

/area/syndicate_station/south
	name = "south of SS13"
	icon_state = "south"

/area/syndicate_station/mining
	name = "north east of the mining asteroid"
	icon_state = "north"

/area/syndicate_station/transit
	name = "hyperspace"
	icon_state = "shuttle"
	parallax_movedir = NORTH

/area/abductor_ship
	name = "Abductor Ship"
	icon_state = "yellow"
	requires_power = 0

/area/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	requires_power = 0

/area/vox_station/transit
	name = "hyperspace"
	icon_state = "shuttle"
	requires_power = 0
	parallax_movedir = NORTH

/area/vox_station/southwest_solars
	name = "Aft port solars"
	icon_state = "southwest"
	requires_power = 0

/area/vox_station/northwest_solars
	name = "Fore port solars"
	icon_state = "northwest"
	requires_power = 0

/area/vox_station/northeast_solars
	name = "Fore starboard solars"
	icon_state = "northeast"
	requires_power = 0

/area/vox_station/southeast_solars
	name = "Aft starboard solars"
	icon_state = "southeast"
	requires_power = 0

/area/vox_station/mining
	name = "Nearby mining asteroid"
	icon_state = "north"
	requires_power = 0


//PRISON
/area/prison/solitary
	name = "Solitary Confinement"
	icon_state = "brig"


//STATION13

/area/atmos
	name = "Atmospherics"
	icon_state = "atmos"

//Maintenance
/area/maintenance
	valid_territory = 0

/area/maintenance/fpmaint
	name = "EVA Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fsmaint
	name = "Dormitory Maintenance"
	icon_state = "fsmaint"

/area/maintenance/fsmaint2
	name = "Chapel Maintenance"
	icon_state = "fsmaint"

/area/maintenance/asmaint
	name = "Medbay Maintenance"
	icon_state = "asmaint"

/area/maintenance/asmaint2
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/maintenance/maintcentral
	name = "Bridge Maintenance"
	icon_state = "maintcentral"

/area/maintenance/port
	name = "Cargo Maintenance"
	icon_state = "pmaint"

/area/maintenance/aft
	name = "Engineering Maintenance"
	icon_state = "amaint"

/area/maintenance/incinerator
	name = "Incinerator"
	icon_state = "disposal"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

//Hallway

/area/hallway/primary/fore
	name = "Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/aft
	name = "Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/port
	name = "Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/central
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/entry
	name = "Arrival Shuttle Hallway"
	icon_state = "entry"

/area/hallway/secondary/Podbay
	name = "Pod bay"
	icon_state = "escape"

//Command

/area/bridge
	name = "Bridge"
	icon_state = "bridge"
	music = "signal"

/area/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	icon_state = "bridge"
	music = null

/area/crew_quarters/captain
	name = "Captain's Office"
	icon_state = "captain"

/area/crew_quarters/heads
	name = "Head of Personnel's Office"
	icon_state = "head_quarters"

/area/crew_quarters/hor
	name = "Research Director's Office"
	icon_state = "head_quarters"

/area/comms
	name = "Communications Relay"
	icon_state = "tcomsatcham"

/area/server
	name = "Messaging Server Room"
	icon_state = "server"

//Crew

/area/crew_quarters
	name = "Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/toilet
	name = "Dormitory Toilets"
	icon_state = "toilet"

/area/crew_quarters/security
	name = "Security Wing Dormitories"

/area/crew_quarters/male
	name = "Male Dorm"

/area/crew_quarters/female
	name = "Female Dorm"

/area/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"

/area/crew_quarters/locker/locker_toilet
	name = "Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/gym
	name = "Gym"
	icon_state = "fitness"

/area/crew_quarters/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/barbershop
	name = "Barbershop"
	icon_state = "barbershop"

/area/crew_quarters/bar
	name = "Bar"
	icon_state = "bar"

/area/crew_quarters/playroom
	name = "Play Room"
	icon_state = "fitness"

/area/crew_quarters/theatre
	name = "Theatre"
	icon_state = "Theatre"

/area/library
	name = "Library"
	icon_state = "library"


/area/chapel/main
	name = "Chapel"
	icon_state = "chapel"

/area/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"


/area/lawoffice
	name = "Internal Affairs"
	icon_state = "law"

/area/garden
	name = "Garden"
	icon_state = "garden"


/area/holodeck
	name = "Holodeck"
	icon_state = "Holodeck"
	dynamic_lighting = 0

/area/holodeck/alphadeck
	name = "Holodeck Alpha"

/area/holodeck/source_plating
	name = "Holodeck - Off"
	icon_state = "Holodeck"

/area/holodeck/source_emptycourt
	name = "Holodeck - Empty Court"

/area/holodeck/source_basketball
	name = "Holodeck - Basketball Court"

/area/holodeck/source_thunderdomecourt
	name = "Holodeck - Thunderdome Court"

/area/holodeck/source_courtroom
	name = "Holodeck - Courtroom"
	icon_state = "Holodeck"

/area/holodeck/source_beach
	name = "Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.

/area/holodeck/source_school
	name = "Holodeck - Anime School"

/area/holodeck/source_spacechess
	name = "Holodeck - Space Chess"

/area/holodeck/source_firingrange
	name = "Holodeck - Firing Range"

/area/holodeck/source_wildlife
	name = "Holodeck - Wildlife Simulation"

/area/holodeck/source_meetinghall
	name = "Holodeck - Meeting Hall"

/area/holodeck/source_theatre
	name = "Holodeck - Theatre"

/area/holodeck/source_picnicarea
	name = "Holodeck - Picnic Area"

/area/holodeck/source_snowfield
	name = "Holodeck - Snow Field"

/area/holodeck/source_desert
	name = "Holodeck - Desert"

/area/holodeck/source_space
	name = "Holodeck - Space"


//Engineering

/area/engine
	icon_state = "engine"

/area/engine/drone_fabrication
	name = "Drone Fabrication"

/area/engine/engineering
	name = "Engineering"
	icon_state = "engine_smes"

/area/engine/singularity
	name = "Singularity Area"

/area/engine/break_room
	name = "Engineering Break Room"

/area/engine/chiefs_office
	name = "Chief Engineer's office"
	icon_state = "engine_control"


//Solars

/area/solar
	requires_power = 0
	valid_territory = 0

/area/solar/auxport
	name = "Fore Port Solar Array"
	icon_state = "panelsA"

/area/solar/auxstarboard
	name = "Fore Starboard Solar Array"
	icon_state = "panelsA"

/area/solar/starboard
	name = "Aft Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/port
	name = "Aft Port Solar Array"
	icon_state = "panelsP"

/area/maintenance/auxsolarport
	name = "Fore Port Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/maintenance/starboardsolar
	name = "Aft Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/portsolar
	name = "Aft Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/auxsolarstarboard
	name = "Fore Starboard Solar Maintenance"
	icon_state = "SolarcontrolA"


/area/assembly/chargebay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/assembly/robotics
	name = "Robotics Lab"
	icon_state = "ass_line"

/area/assembly/assembly_line //Derelict Assembly Line
	name = "Assembly Line"
	icon_state = "ass_line"
	power_equip = 0
	power_light = 0
	power_environ = 0

//Teleporter

/area/teleporter
	name = "Teleporter"
	icon_state = "teleporter"
	music = "signal"

/area/gateway
	name = "Gateway"
	icon_state = "teleporter"
	music = "signal"

/area/AIsattele
	name = "AI Satellite Teleporter Room"
	icon_state = "teleporter"
	music = "signal"

//MedBay

/area/medical
	name = "Medbay"
	icon_state = "medbay"

//Medbay is a large area, these additional areas help level out APC load.
/area/medical/hallway
	icon_state = "medbay2"
	music = 'sound/ambience/signal.ogg'

/area/medical/hallway/outbranch
	icon_state = "medbay3"

/area/medical/reception
	name = "Medbay Reception"
	icon_state = "medbay"
	music = 'sound/ambience/signal.ogg'

/area/medical/psych
	name = "Psych Room"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbreak
	name = "Break Room"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/patients_rooms
	name = "Patient's Rooms"
	icon_state = "patients"

/area/medical/patient_a
	name = "Patient Room One"
	icon_state = "patients"

/area/medical/patient_b
	name = "Patient Room Two"
	icon_state = "patients"

/area/medical/cmo
	name = "Chief Medical Officer's office"
	icon_state = "CMO"

/area/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/medical/morgue
	name = "Morgue"
	icon_state = "morgue"

/area/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/medical/surgery
	name = "Operating Theatre 1"
	icon_state = "surgery"

/area/medical/surgery2
	name = "Operating Theatre 2"
	icon_state = "surgery"

/area/medical/surgerystorage
	name = "Operating Storage"
	icon_state = "surgery2"

/area/medical/surgeryobs
	name = "Operation Observation Room"
	icon_state = "surgery"

/area/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/medical/genetics_cloning
	name = "Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Emergency Treatment Centre"
	icon_state = "exam_room"

//Security

/area/security/main
	name = "Security Office"
	icon_state = "security"

/area/security/lobby
	name = "Security lobby"
	icon_state = "security"

/area/security/brig
	name = "Brig"
	icon_state = "brig"

/area/security/execution
	name = "Execution"
	icon_state = "brig"

/area/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"

/area/security/warden
	name = "Warden"
	icon_state = "Warden"

/area/security/armoury
	name = "Armory"
	icon_state = "Warden"

/area/security/hos
	name = "Head of Security's Office"
	icon_state = "sec_hos"

/area/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"

/area/security/forensic_office
	name = "Forensic's Office"
	icon_state = "detective"

/area/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/security/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"

/area/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "security"

/area/security/vacantoffice
	name = "Vacant Office"
	icon_state = "security"


/area/quartermaster
	name = "Quartermasters"
	icon_state = "quart"

/area/quartermaster/office
	name = "Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "Cargo Bay"
	icon_state = "quartstorage"

/area/quartermaster/qm
	name = "Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/recycler
	name = "Recycler"
	icon_state = "recycler"

/area/quartermaster/recycleroffice
	name = "Recycleroffice"
	icon_state = "recycleroffice"

/area/quartermaster/miningbreaktime
	name = "Breaktime room"
	icon_state = "miningbreaktime"

/area/quartermaster/miningoffice
	name = "Mining office"
	icon_state = "miningoffice"


/area/janitor
	name = "Custodial Closet"
	icon_state = "janitor"


/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"


//rnd (Research and Development

/area/rnd/lab
	name = "Research and Development"
	icon_state = "toxlab"

/area/rnd/hallway
	name = "Research Division"
	icon_state = "research"

/area/rnd/xenobiology
	name = "Xenobiology Lab"
	icon_state = "toxlab"

/area/rnd/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"

/area/rnd/test_area
	valid_territory = 0
	name = "Toxins Test Area"
	icon_state = "toxtest"

/area/rnd/mixing
	name = "Toxins Mixing Room"
	icon_state = "toxmix"

/area/rnd/misc_lab
	name = "Miscellaneous Research"
	icon_state = "toxmisc"

/area/rnd/telesci
	name = "Telescience Lab"
	icon_state = "toxmisc"

/area/rnd/scibreak
	name = "Science Break Room"
	icon_state = "toxlab"

/area/toxins/server
	name = "Server Room"
	icon_state = "server"
	music = 'sound/ambience/server.ogg'


//Storage

/area/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "storage"

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency3
	name = "Central Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"


//DJSTATION

/area/djstation
	name = "Ruskie DJ Station"
	icon_state = "DJ"

/area/djstation/solars
	name = "DJ Station Solars"
	icon_state = "DJ"


//DERELICT

/area/derelict
	name = "Derelict Station"
	icon_state = "storage"

/area/derelict/hallway/primary
	name = "Derelict Primary Hallway"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "Derelict Secondary Hallway"
	icon_state = "hallS"

/area/derelict/arrival
	name = "Derelict Arrival Centre"
	icon_state = "yellow"

/area/derelict/bridge
	name = "Derelict Control Room"
	icon_state = "bridge"

/area/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "Derelict Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "Derelict Solar Control"
	icon_state = "engine"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/chapel
	name = "Derelict Chapel"
	icon_state = "chapel"

/area/derelict/teleporter
	name = "Derelict Teleporter"
	icon_state = "teleporter"

/area/derelict/ship
	name = "Abandoned Ship"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "Derelict Aft Solar Array"
	icon_state = "aft"

/area/derelict/singularity_engine
	name = "Derelict Singularity Engine"
	icon_state = "engine"


//Construction

/area/construction
	name = "Construction Area"
	icon_state = "yellow"


//AI

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"

/area/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"

/area/turret_protected/aisat
	name = "AI Satellite"
	icon_state = "ai"

/area/aisat
	name = "AI Satellite Exterior"
	icon_state = "storage"

/area/turret_protected/aisat_interior
	name = "AI Satellite Antechamber"
	icon_state = "ai"


// Telecommunications Satellite

/area/tcommsat/chamber
	name = "Telecoms Central Compartment"
	icon_state = "tcomsatcham"

/area/tcommsat/computer
	name = "Telecoms Control Room"
	icon_state = "tcomsatcomp"


//tc areas

/area/mine/dwarf
	name = "Dwarf"
	icon_state = "dwarf"

/area/toxins/brainstorm_center
	name = "Brainstorm Center"
	icon_state = "bs"


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon_state = "away"

/area/awaymission/example
	name = "Strange Station"

/area/awaymission/wwmines
	name = "Wild West Mines"
	icon_state = "away1"
	requires_power = 0

/area/awaymission/wwgov
	name = "Wild West Mansion"
	icon_state = "away2"
	requires_power = 0

/area/awaymission/wwrefine
	name = "Wild West Refinery"
	icon_state = "away3"
	requires_power = 0

/area/awaymission/wwvault
	name = "Wild West Vault"
	icon_state = "away3"

/area/awaymission/wwvaultdoors
	name = "Wild West Vault Doors"  // this is to keep the vault area being entirely lit because of requires_power
	icon_state = "away2"
	requires_power = 0

/area/awaymission/desert
	name = "Mars"
	icon_state = "away"

/area/awaymission/junkyard
	name = "Junkyard"
	icon_state = "away"
	always_unpowered = 1

/area/awaymission/BMPship1
	name = "Aft Block"
	icon_state = "away1"

/area/awaymission/BMPship2
	name = "Midship Block"
	icon_state = "away2"

/area/awaymission/BMPship3
	name = "Fore Block"
	icon_state = "away3"

/area/awaymission/spacebattle
	name = "Space Battle"
	icon_state = "away"
	requires_power = 0

/area/awaymission/spacebattle/cruiser
	name = "Nanotrasen Cruiser"

/area/awaymission/spacebattle/syndicate1
	name = "Syndicate Assault Ship 1"

/area/awaymission/spacebattle/syndicate2
	name = "Syndicate Assault Ship 2"

/area/awaymission/spacebattle/syndicate3
	name = "Syndicate Assault Ship 3"

/area/awaymission/spacebattle/syndicate4
	name = "Syndicate War Sphere 1"

/area/awaymission/spacebattle/syndicate5
	name = "Syndicate War Sphere 2"

/area/awaymission/spacebattle/syndicate6
	name = "Syndicate War Sphere 3"

/area/awaymission/spacebattle/syndicate7
	name = "Syndicate Fighter"

/area/awaymission/spacebattle/secret
	name = "Hidden Chamber"

/area/awaymission/labs/gateway
	name = "Labs Gateway"

/area/awaymission/labs/militarydivision
	name = "Military Division"

/area/awaymission/labs/researchdivision
	name = "Labs RnD"

/area/awaymission/labs/cave
	name = "Labs cave"

/area/awaymission/labs/solars
	name = "Labs solars"

/area/awaymission/labs/command
	name = "labs command"

/area/awaymission/labs/cargo
	name = "Labs cargo"

/area/awaymission/labs/civilian
	name = "Labs civilian"

/area/awaymission/labs/security
	name = "Labs security"

/area/awaymission/labs/medical
	name = "Labs medical"

/area/awaymission/listeningpost
	name = "Listening Post"
	icon_state = "away"
	requires_power = 0


/area/awaymission/beach
	name = "Beach"
	icon_state = "null"
	dynamic_lighting = 0
	requires_power = 0
	var/sound/mysound = null
/* hello copypasta of area/beach (this idea with this area is Eeeeuuuuuwwww)
/area/awaymission/beach/New()
	..()
	var/sound/S = new/sound()
	mysound = S
	S.file = 'sound/ambience/shore.ogg'
	S.repeat = 1
	S.wait = 0
	S.channel = 123
	S.volume = 100
	S.priority = 255
	S.status = SOUND_UPDATE
	process()

/area/awaymission/beach/Entered(atom/movable/Obj,atom/OldLoc)
	if(ismob(Obj))
		if(Obj:client)
			mysound.status = SOUND_UPDATE
			Obj << mysound
	return

/area/awaymission/beach/Exited(atom/movable/Obj)
	if(ismob(Obj))
		if(Obj:client)
			mysound.status = SOUND_PAUSED | SOUND_UPDATE
			Obj << mysound

/area/awaymission/beach/process()
	var/sound/S = null
	var/sound_delay = 0
	if(prob(25))
		S = sound(file=pick('sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag3.ogg'), volume=100)
		sound_delay = rand(0, 50)

	for(var/mob/living/carbon/human/H in src)
		if(H.s_tone > -55)
			H.s_tone--
			H.update_body()
		if(H.client)
			mysound.status = SOUND_UPDATE
			H << mysound
			if(S)
				addtimer(CALLBACK(src, .proc/send_sound, H, S), sound_delay)

	addtimer(CALLBACK(src, .process), 60)

/area/proc/send_sound(mob/living/carbon/human/target, sound)
	if(!target || !sound)
		return
	target << sound
*/
/////////////////////////////////////////////////////////////////////
/*
 Lists of areas to be used with is_type_in_list.
 Used in gamemodes code at the moment. --rastaf0
*/

// CENTCOM
var/list/centcom_areas = list (
	/area/centcom,
	/area/shuttle/escape/centcom,
	/area/shuttle/escape_pod1/centcom,
	/area/shuttle/escape_pod2/centcom,
	/area/shuttle/escape_pod3/centcom,
	/area/shuttle/escape_pod5/centcom,
	/area/shuttle/transport1/centcom,
	/area/shuttle/administration/centcom,
	/area/shuttle/specops/centcom,
)

//SPACE STATION 13
var/list/the_station_areas = list (
	/area/shuttle/arrival,
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/mining/station,
	/area/shuttle/transport1/station,
	/area/shuttle/administration/station,
	/area/shuttle/specops/station,
	/area/atmos,
	/area/maintenance,
	/area/hallway,
	/area/bridge,
	/area/crew_quarters,
	/area/holodeck,
	/area/library,
	/area/chapel,
	/area/lawoffice,
	/area/engine,
	/area/solar,
	/area/assembly,
	/area/teleporter,
	/area/medical,
	/area/security,
	/area/quartermaster,
	/area/janitor,
	/area/hydroponics,
	/area/rnd,
	/area/storage,
	/area/construction,
	/area/ai_monitored/storage/eva, //do not try to simplify to "/area/ai_monitored" --rastaf0
	/area/ai_monitored/storage/secure,
	/area/turret_protected/ai_upload, //do not try to simplify to "/area/turret_protected" --rastaf0
	/area/turret_protected/ai
)



/area/beach
	name = "Keelin's private beach"
	icon_state = "null"
	dynamic_lighting = 0
	requires_power = 0
	var/sound/mysound = null
/* hello copypasta of area/away_mission/beach
/area/beach/New()
	..()
	var/sound/S = new/sound()
	mysound = S
	S.file = 'sound/ambience/shore.ogg'
	S.repeat = 1
	S.wait = 0
	S.channel = 123
	S.volume = 100
	S.priority = 255
	S.status = SOUND_UPDATE
	process()

/area/beach/Entered(atom/movable/Obj,atom/OldLoc)
	if(ismob(Obj))
		if(Obj:client)
			mysound.status = SOUND_UPDATE
			Obj << mysound
	return

/area/beach/Exited(atom/movable/Obj)
	if(ismob(Obj))
		if(Obj:client)
			mysound.status = SOUND_PAUSED | SOUND_UPDATE
			Obj << mysound

/area/beach/process()
	var/sound/S = null
	var/sound_delay = 0
	if(prob(25))
		S = sound(file=pick('sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag3.ogg'), volume=100)
		sound_delay = rand(0, 50)

	for(var/mob/living/carbon/human/H in src)
		if(H.client)
			mysound.status = SOUND_UPDATE
			H << mysound
			if(S)
				addtimer(CALLBACK(src, .proc/send_sound, H, S), sound_delay)

	addtimer(CALLBACK(src, .process), 60)
*/
