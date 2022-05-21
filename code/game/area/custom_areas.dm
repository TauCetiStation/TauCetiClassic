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

/area/custom/arena
	name = "Deathmatch Arena"
	icon_state = "red"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/custom/hub
	name = "Hub"
	icon_state = "red"

/area/custom/human_hub
	name = "HumanHub"
	icon_state = "bluenew"

/area/custom/wizard_hub
	name = "WizardHub"
	icon_state = "showroom"

/area/custom/krigan_hub
	name = "KriganHub"
	icon_state = "cult-heaven"



// ЭРАФИЯ ЗОНЫ ХАБОРВ

/area/custom/peasant_hub
	name = "Peasant_hub"
	icon_state = "blue-red-d"

/area/custom/miner_hub
	name = "Miner_hub"
	icon_state = "blue-red-d"

/area/custom/helper_hub
	name = "Helper_hub"
	icon_state = "blue-red-d"

/area/custom/plague_doctor_hub
	name = "Doctor_hub"
	icon_state = "blue-red-d"

/area/custom/headman_hub
	name = "Headman_hub"
	icon_state = "blue-red-d"

/area/custom/innkeeper_hub
	name = "Innkeeper_hub"
	icon_state = "blue-red-d"

/area/custom/knight_hub
	name = "Knight_hub"
	icon_state = "blue-red-d"

/area/custom/monk_hub
	name = "Monk_hub"
	icon_state = "blue-red-d"

/area/custom/smith_hub
	name = "Smith_hub"
	icon_state = "blue-red-d"

/area/custom/human_hero
	name = "HumanHero_hub"
	icon_state = "blue-red-d"


/area/custom/start_homm
	name = "Start"
	icon_state = "blue-red-d"

// ЭРАФИЯ СТАРТОВЫЕ ЗОНЫ

/area/custom/start_homm/peasant
	name = "PeasantStart"

/area/custom/start_homm/smith
	name = "SmithStart"

/area/custom/start_homm/miner
	name = "MinerStart"

/area/custom/start_homm/helper
	name = "HelperStart"

/area/custom/start_homm/doctor
	name = "DoctorStart"

/area/custom/start_homm/headman
	name = "HeadmanStart"

/area/custom/start_homm/innkeeper
	name = "InnkeeperStart"

/area/custom/start_homm/knight
	name = "KnightStart"

/area/custom/start_homm/monk
	name = "MonkStart"

/area/custom/start_homm/human_hero
	name = "HumanHeroStart"

//НЕЙТРАЛЫ ЗОНЫ ХАБОВ

/area/custom/lepr
	name = "Leprecon_Hub"
	icon_state = "green"

//НЕЙТРАЛЫ СТАРТОВЫЕ ЗОНЫ

/area/custom/start_homm/lepr
	name = "LepreconStart"

/area/custom/valhalla
	name = "Valhalla"
	icon_state = "valhalla"