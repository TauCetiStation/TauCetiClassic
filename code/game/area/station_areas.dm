/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/

/*-----------------------------------------------------------------------------*/

//EXODUS

ADD_TO_GLOBAL_LIST(/area/station, the_station_areas)

//Engineering

/area/station/engineering
	icon_state = "engine"
	looped_ambience = 'sound/ambience/loop_engine.ogg'
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/engineering/engine
	name = "Engineering"
	icon_state = "engine_smes"
	ambience = list('sound/ambience/engine_1.ogg', 'sound/ambience/engine_2.ogg', 'sound/ambience/engine_3.ogg', 'sound/ambience/engine_4.ogg')

/area/station/engineering/singularity
	name = "Singularity Area"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/station/engineering/break_room
	name = "Engineering Break Room"
	sound_environment = SOUND_AREA_DEFAULT

/area/station/engineering/chiefs_office
	name = "Chief Engineer's office"
	icon_state = "engine_control"
	sound_environment = SOUND_AREA_DEFAULT

/area/station/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	ambience = list('sound/ambience/atmos_1.ogg', 'sound/ambience/atmos_2.ogg')

/area/station/engineering/drone_fabrication
	name = "Drone Fabrication"

//Maintenance
/area/station/maintenance
	looped_ambience = 'sound/ambience/loop_maintenance.ogg'
	valid_territory = 0
	sound_environment = SOUND_AREA_MAINTENANCE
	ambience = list('sound/ambience/maintambience.ogg', 'sound/ambience/ambimaint3.ogg', 'sound/ambience/ambimaint5.ogg')

/area/station/maintenance/eva
	name = "EVA Maintenance"
	icon_state = "fpmaint"

/area/station/maintenance/escape
	name = "Escape Shuttle Maintenance"
	icon_state = "fmaint"

/area/station/maintenance/dormitory
	name = "Dormitory Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/chapel
	name = "Chapel Maintenance"
	icon_state = "fsmaint"

/area/station/maintenance/medbay
	name = "Medbay Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/science
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/station/maintenance/bridge
	name = "Bridge Maintenance"
	icon_state = "maintcentral"

/area/station/maintenance/cargo
	name = "Cargo Maintenance"
	icon_state = "pmaint"

/area/station/maintenance/engineering
	name = "Engineering Maintenance"
	icon_state = "amaint"

/area/station/maintenance/incinerator
	name = "Incinerator"
	icon_state = "disposal"

/area/station/maintenance/atmos
	name = "Atmospherics Maintenance"
	icon_state = "amaint"

/area/station/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"
	sound_environment = SOUND_AREA_SMALL_METALLIC

//Construction

/area/station/construction
	name = "Construction Area"
	icon_state = "yellow"

/area/station/construction/assembly_line //Derelict Assembly Line
	name = "Assembly Line"
	icon_state = "ass_line"
	power_equip = 0
	power_light = 0
	power_environ = 0

//Solars

/area/station/solar
	requires_power = 0
	dynamic_lighting = TRUE
	valid_territory = 0
	looped_ambience = 'sound/ambience/loop_space.ogg'
	sound_environment = SOUND_AREA_SMALL_METALLIC
	outdoors = TRUE

/area/station/solar/auxport
	name = "Fore Port Solar Array"
	icon_state = "panelsA"

/area/station/solar/auxstarboard
	name = "Fore Starboard Solar Array"
	icon_state = "panelsA"

/area/station/solar/starboard
	name = "Aft Starboard Solar Array"
	icon_state = "panelsS"

/area/station/solar/port
	name = "Aft Port Solar Array"
	icon_state = "panelsP"

/area/station/maintenance/auxsolarport
	name = "Fore Port Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/station/maintenance/starboardsolar
	name = "Aft Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/station/maintenance/portsolar
	name = "Aft Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/station/maintenance/auxsolarstarboard
	name = "Fore Starboard Solar Maintenance"
	icon_state = "SolarcontrolA"

//Hallway
/area/station/hallway
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/hallway/primary/fore
	name = "Fore Primary Hallway"
	icon_state = "hallF"

/area/station/hallway/primary/starboard
	name = "Starboard Primary Hallway"
	icon_state = "hallS"

/area/station/hallway/primary/aft
	name = "Aft Primary Hallway"
	icon_state = "hallA"

/area/station/hallway/primary/port
	name = "Port Primary Hallway"
	icon_state = "hallP"

/area/station/hallway/primary/central
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/station/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"

/area/station/hallway/secondary/arrival
	name = "Arrival Shuttle Hallway"
	icon_state = "arrival"

/area/station/hallway/secondary/entry
	name = "Entry Shuttles Hallway"
	icon_state = "entry"

/area/station/hallway/secondary/mine_sci_shuttle
	name = "Asteroid Shuttle Hallway"
	icon_state = "mine_sci_shuttle"

/area/station/hallway/secondary/Podbay
	name = "Pod bay"
	icon_state = "escape"

//Command

/area/station/bridge
	name = "Bridge"
	icon_state = "bridge"
	ambience = list('sound/ambience/bridge_1.ogg')

/area/station/bridge/meeting_room
	name = "Heads of Staff Meeting Room"

/area/station/bridge/captain_quarters
	name = "Captain's Office"
	icon_state = "captain"

/area/station/bridge/hop_office
	name = "Head of Personnel's Office"
	icon_state = "head_quarters"

/area/station/bridge/teleporter
	name = "Teleporter"
	icon_state = "teleporter"

/area/station/bridge/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	ambience = null
	looped_ambience = 'sound/ambience/loop_aisatelite.ogg'
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/bridge/comms
	name = "Communications Relay"
	icon_state = "tcomsatcham"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/bridge/server
	name = "Messaging Server Room"
	icon_state = "server"
	is_force_ambience = TRUE
	ambience = list('sound/ambience/tcomms_1.ogg', 'sound/ambience/tcomms_2.ogg')
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/bridge/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"
	is_force_ambience = TRUE
	ambience = list('sound/ambience/vault_1.ogg')
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/bridge/cmf_room
	name = "CMF altering room"
	icon_state = "cmf"
	is_force_ambience = TRUE
	ambience = list('sound/ambience/bridge_1.ogg')
	sound_environment = SOUND_AREA_SMALL_METALLIC

//Civilian

/area/station/civilian/dormitories
	name = "Dormitories"
	icon_state = "Sleep"

/area/station/civilian/toilet
	name = "Dormitory Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/civilian/dormitories/security
	name = "Security Wing Dormitories"

/area/station/civilian/dormitories/male
	name = "Male Dorm"

/area/station/civilian/dormitories/female
	name = "Female Dorm"

/area/station/civilian/locker
	name = "Locker Room"
	icon_state = "locker"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/civilian/locker/locker_toilet
	name = "Locker Toilets"
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/civilian/fitness
	name = "Fitness Room"
	icon_state = "fitness"

/area/station/civilian/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/station/civilian/gym
	name = "Gym"
	icon_state = "fitness"

/area/station/civilian/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/station/civilian/kitchen/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_COOKING_AREA, GENERIC_TRAIT)

/area/station/civilian/cold_room
	name = "Cold Room"
	icon_state = "coldroom"
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/civilian/barbershop
	name = "Barbershop"
	icon_state = "barbershop"

/area/station/civilian/bar
	name = "Bar"
	icon_state = "bar"

/area/station/civilian/playroom
	name = "Play Room"
	icon_state = "fitness"

/area/station/civilian/theatre
	name = "Theatre"
	icon_state = "Theatre"

/area/station/civilian/library
	name = "Library"
	icon_state = "library"

/area/station/civilian/chapel
	name = "Chapel"
	icon_state = "chapel"
	ambience = list('sound/ambience/chapel_1.ogg', 'sound/ambience/chapel_2.ogg', 'sound/ambience/chapel_3.ogg', 'sound/ambience/chapel_4.ogg')
	sound_environment = SOUND_ENVIRONMENT_ARENA

/area/station/civilian/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"
	sound_environment = SOUND_AREA_DEFAULT

/area/station/civilian/chapel/altar
	name = "Altar"
	icon_state = "altar"
	sound_environment = SOUND_AREA_DEFAULT

/area/station/civilian/chapel/crematorium
	name = "Crematorium"
	icon_state = "crematorium"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/civilian/chapel/mass_driver
	name = "Chapel Mass Driver"
	icon_state = "massdriver"

/area/station/civilian/garden
	name = "Garden"
	icon_state = "garden"
	looped_ambience = 'sound/ambience/loop_garden.ogg'
	sound_environment = SOUND_ENVIRONMENT_ALLEY

/area/station/civilian/janitor
	name = "Custodial Closet"
	icon_state = "janitor"

/area/station/civilian/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

//Holodeck
/area/station/civilian/holodeck
	name = "Holodeck"
	icon_state = "Holodeck"
	dynamic_lighting = FALSE

/area/station/civilian/holodeck/alphadeck
	name = "Holodeck Alpha"

/area/station/civilian/holodeck/source_plating
	name = "Holodeck - Off"
	icon_state = "Holodeck"

/area/station/civilian/holodeck/source_emptycourt
	name = "Holodeck - Empty Court"

/area/station/civilian/holodeck/source_basketball
	name = "Holodeck - Basketball Court"

/area/station/civilian/holodeck/source_boxingcourt
	name = "Holodeck - Boxing Court"

/area/station/civilian/holodeck/source_thunderdomecourt
	name = "Holodeck - Thunderdome Court"

/area/station/civilian/holodeck/source_burntest
	name = "Holodeck - Burn test"

/area/station/civilian/holodeck/source_courtroom
	name = "Holodeck - Courtroom"
	icon_state = "Holodeck"

/area/station/civilian/holodeck/source_beach
	name = "Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.

/area/station/civilian/holodeck/source_school
	name = "Holodeck - Anime School"

/area/station/civilian/holodeck/source_spacechess
	name = "Holodeck - Space Chess"

/area/station/civilian/holodeck/source_firingrange
	name = "Holodeck - Firing Range"

/area/station/civilian/holodeck/source_wildlife
	name = "Holodeck - Wildlife Simulation"

/area/station/civilian/holodeck/source_meetinghall
	name = "Holodeck - Meeting Hall"

/area/station/civilian/holodeck/source_theatre
	name = "Holodeck - Theatre"

/area/station/civilian/holodeck/source_picnicarea
	name = "Holodeck - Picnic Area"

/area/station/civilian/holodeck/source_snowfield
	name = "Holodeck - Snow Field"

/area/station/civilian/holodeck/source_desert
	name = "Holodeck - Desert"

/area/station/civilian/holodeck/source_space
	name = "Holodeck - Space"

//Gateway

/area/station/gateway
	name = "Gateway"
	icon_state = "teleporter"

//MedBay

/area/station/medical
	name = "Medbay"
	icon_state = "medbay"
	ambience = list('sound/ambience/medbay_1.ogg', 'sound/ambience/medbay_2.ogg', 'sound/ambience/medbay_3.ogg', 'sound/ambience/medbay_4.ogg', 'sound/ambience/medbay_5.ogg')

//Medbay is a large area, these additional areas help level out APC load.
/area/station/medical/hallway
	icon_state = "medbay2"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/medical/reception
	name = "Medbay Reception"
	icon_state = "medbay"

/area/station/medical/storage
	name = "Medbay Storage"
	icon_state = "medbay3"

/area/station/medical/medbreak
	name = "Medbay Breaktime Room"
	icon_state = "medbay3"

/area/station/medical/psych
	name = "Psych Room"
	icon_state = "medbay3"

/area/station/medical/patients_rooms
	name = "Patient's Rooms"
	icon_state = "patients"

/area/station/medical/patient_a
	name = "Patient Room One"
	icon_state = "patients"

/area/station/medical/patient_b
	name = "Patient Room Two"
	icon_state = "patients"

/area/station/medical/cmo
	name = "Chief Medical Officer's office"
	icon_state = "CMO"

/area/station/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/station/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	ambience = list('sound/ambience/morgue_1.ogg', 'sound/ambience/morgue_2.ogg', 'sound/ambience/morgue_3.ogg')
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"
	ambience = list('sound/ambience/chemistry_1.ogg', 'sound/ambience/chemistry_2.ogg')

/area/station/medical/surgery
	name = "Operating Theatre 1"
	icon_state = "surgery"
	ambience = list('sound/ambience/surgery_1.ogg', 'sound/ambience/surgery_2.ogg')

/area/station/medical/surgery2
	name = "Operating Theatre 2"
	icon_state = "surgery"

/area/station/medical/surgeryobs
	name = "Operation Observation Room"
	icon_state = "surgery"

/area/station/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/station/medical/genetics
	name = "Genetics Lab"
	icon_state = "genetics"

/area/station/medical/genetics_cloning
	name = "Cloning Lab"
	icon_state = "cloning"

/area/station/medical/sleeper
	name = "Emergency Treatment Centre"
	icon_state = "exam_room"

//Security

/area/station/security/main
	name = "Security Office"
	icon_state = "security"

/area/station/security/lobby
	name = "Security lobby"
	icon_state = "security"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/security/brig
	name = "Brig"
	icon_state = "brig"

/area/station/security/brig/solitary_confinement
	name = "Solitary Confinement"

/area/station/security/interrogation
	name = "Interrogation"
	icon_state = "interrogation"
	looped_ambience = 'sound/ambience/loop_interrogation.ogg'

/area/station/security/execution
	name = "Execution"
	icon_state = "execution_room"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"
	ambience = list('sound/ambience/prison_1.ogg')

/area/station/security/prison/toilet
	name = "Prison Toilet"

/area/station/security/warden
	name = "Warden"
	icon_state = "warden"

/area/station/security/armoury
	name = "Armory"
	icon_state = "armory"
	looped_ambience = 'sound/ambience/loop_armory.ogg'

/area/station/security/hos
	name = "Head of Security's Office"
	icon_state = "sec_hos"

/area/station/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	ambience = list('sound/ambience/detective_1.ogg')

/area/station/security/forensic_office
	name = "Forensic's Office"
	icon_state = "detective"
	ambience = list('sound/ambience/detective_1.ogg')

/area/station/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/station/security/processing
	name = "Labor Shuttle Dock"
	icon_state = "sec_processing"

/area/station/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "security"

/area/station/security/vacantoffice
	name = "Coworking"
	icon_state = "security"
	ambience = list('sound/ambience/vacant_1.ogg')

/area/station/security/iaa_office
	name = "Internal Affairs"
	icon_state = "law"

/area/station/security/blueshield
	name = "Blueshield Office"
	icon_state = "law"

/area/station/security/blueshield/shuttle
	name = "Blueshield Shuttle"

/area/station/security/lawyer_office
	name = "Lawyer Office"
	icon_state = "law"

//Cargo bay
/area/station/cargo
	name = "Quartermasters"
	icon_state = "quart"

/area/station/cargo/office
	name = "Cargo Office"
	icon_state = "quartoffice"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/cargo/storage
	name = "Cargo Bay"
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/cargo/qm
	name = "Quartermaster's Office"
	icon_state = "quart"

/area/station/cargo/recycler
	name = "Recycler"
	icon_state = "recycler"

/area/station/cargo/recycleroffice
	name = "Recycleroffice"
	icon_state = "recycleroffice"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/cargo/miningbreaktime
	name = "Cargo Breaktime Room"
	icon_state = "miningbreaktime"

/area/station/cargo/miningoffice
	name = "Mining office"
	icon_state = "miningoffice"

//rnd (Research and Development)

/area/station/rnd
	ambience = list('sound/ambience/rnd_1.ogg', 'sound/ambience/rnd_2.ogg')

/area/station/rnd/lab
	name = "Research and Development"
	icon_state = "scilab"

/area/station/rnd/hallway
	name = "Research Division"
	icon_state = "research"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/rnd/xenobiology
	name = "Xenobiology Lab"
	icon_state = "scixeno"

/area/station/rnd/storage
	name = "Toxins Storage"
	icon_state = "toxstorage"
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/rnd/test_area
	name = "Toxins Test Site"
	icon_state = "toxtest"

/area/station/rnd/mixing
	name = "Toxins Mixing Room"
	icon_state = "toxmix"

/area/station/rnd/misc_lab
	name = "Miscellaneous Research"
	icon_state = "scimisc"

/area/station/rnd/telesci
	name = "Telescience Lab"
	icon_state = "scitele"

/area/station/rnd/tox_launch
	name = "Toxins Launch Roon"
	icon_state = "toxlaunch"

/area/station/rnd/scibreak
	name = "Science Breaktime Room"
	icon_state = "scirest"

/area/station/rnd/hor
	name = "Research Director's Office"
	icon_state = "head_quarters"

/area/station/rnd/server
	name = "Server Room"
	icon_state = "server"
	is_force_ambience = TRUE
	ambience = list('sound/ambience/tcomms_1.ogg', 'sound/ambience/tcomms_2.ogg')
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/rnd/chargebay
	name = "Mech Bay"
	icon_state = "mechbay"

/area/station/rnd/robotics
	name = "Robotics Lab"
	icon_state = "scirobo"
	ambience = list('sound/ambience/robotics_1.ogg', 'sound/ambience/robotics_2.ogg')

/area/station/rnd/brainstorm_center
	name = "Brainstorm Center"
	icon_state = "bs"

//Storage

/area/station/ai_monitored/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/station/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "storage"

/area/station/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/station/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/storage/emergency3
	name = "Central Emergency Storage"
	icon_state = "emergencystorage"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/station/storage/tech/north
	name = "North Technical Storage"
	sound_environment = SOUND_AREA_SMALL_METALLIC

//AI

/area/station/aisat
	name = "AI Satellite Exterior"
	icon_state = "storage"
	looped_ambience = 'sound/ambience/loop_aisatelite.ogg'
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/ai_monitored/storage_secure
	name = "Secure Storage"
	icon_state = "storage"
	looped_ambience = 'sound/ambience/loop_aisatelite.ogg'
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/aisat/ai_chamber
	name = "AI Chamber"
	icon_state = "ai_chamber"
	ambience = 'sound/ambience/aicore.ogg'

/area/station/aisat/antechamber
	name = "AI Satellite"
	icon_state = "ai"

/area/station/aisat/antechamber_interior
	name = "AI Satellite Antechamber"
	icon_state = "ai"

/area/station/aisat/teleport
	name = "AI Satellite Teleporter Room"
	icon_state = "teleporter"
	sound_environment = SOUND_AREA_SMALL_METALLIC

// Telecommunications Satellite

/area/station/tcommsat
	is_force_ambience = TRUE
	ambience = list('sound/ambience/tcomms_1.ogg', 'sound/ambience/tcomms_2.ogg')
	looped_ambience = 'sound/ambience/loop_aisatelite.ogg'
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/tcommsat/chamber
	name = "Telecoms Central Compartment"
	icon_state = "tcomsatcham"
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/tcommsat/computer
	name = "Telecoms Control Room"
	icon_state = "tcomsatcomp"
	sound_environment = SOUND_AREA_DEFAULT
