 //////////
 //CUSTOM//
 //////////

//VELOCITY
/area/velocity
	name = "Velocity Dock 42"
	cases = list("Велосити док 42", "Велосити док 42", "Велосити док 42", "Велосити док 42", "Велосити док 42", "Велосити док 42")
	icon_state = "velocity"
	requires_power = 0
	dynamic_lighting = TRUE
	ambience = null
	looped_ambience = 'sound/ambience/loop_velocity.ogg'

/area/velocity/monorailwagon
	name = "Velocity Monorail Wagon"
	cases = list("монорельсовый вагон Велосити", "монорельсового вагона Велосити", "монорельсовому вагону Велосити", "монорельсовый вагон Велосити", "монорельсовым вагоном Велосити", "монорельсовом вагоне Велосити")
	icon_state = "velocity_wagon"
	ambience = 'sound/ambience/monorail_arrival.ogg'

//Alien base
/area/custom/alien
	name = "Alien base"
	cases = list("база чужих", "базы чужих", "базу чужих", "базу чужих", "базой чужих", "базе чужих")
	icon_state = "yellow"
	requires_power = 0

//SYNDICATES
/area/custom/syndicate_mothership
	name = "Syndicate Mothership"
	cases = list("материнский корабль Синдиката", "материнского корабля Синдиката", "материнскому кораблю Синдиката", "материнский корабль Синдиката", "материнским кораблём Синдиката", "материнском корабле Синдиката")
	icon_state = "syndie-ship"
	requires_power = 0
	dynamic_lighting = TRUE
	looped_ambience = 'sound/ambience/loop_nuke_ops.ogg'

/area/custom/syndicate_mothership/control
	name = "Syndicate Control Room"
	cases = list("комната управления Синдиката", "комнаты управления Синдиката", "комнате управления Синдиката", "комнату управления Синдиката", "комнатой управления Синдиката", "комнате управления Синдиката")
	icon_state = "syndie-control"

/area/custom/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	cases = list("элитный отряд Синдиката", "элитного отряда Синдиката", "элитному отряду Синдиката", "элитный отряд Синдиката", "элитным отрядом Синдиката", "элитном отряде Синдиката")
	icon_state = "syndie-elite"

/area/custom/syndicate_mothership/armory
	name = "Syndicate Armory"
	cases = list("оружейная Синдиката", "оружейной Синдиката", "оружейной Синдиката", "оружейную Синдиката", "оружейной Синдиката", "оружейной Синдиката")
	icon_state = "syndie-armory"

/area/custom/syndicate_mothership/droppod_garage
	name = "Drop pod garage"
	cases = list("гараж с десантными капсулами", "гаража с десантными капсулами", "гаражу с десантными капсулами", "гараж с десантными капсулами", "гаражом с десантными капсулами", "гараже с десантными капсулами")

//EXTRA
/area/custom/planet/clown
	name = "Clown Planet"
	cases = list("планета Клоунов", "планеты Клоунов", "планете Клоунов", "планету Клоунов", "планетой Клоунов", "планете Клоунов")
	icon_state = "honk"
	requires_power = 0

/area/custom/beach
	name = "Keelin's private beach"
	cases = list("Килинский частный пляж", "Килинского частного пляжа", "Килинскому частному пляжу", "Килинский частный пляж", "Килинским частным пляжем", "Килинском частном пляже")
	icon_state = "null"
	dynamic_lighting = FALSE
	requires_power = 0

//ENEMY
/area/custom/abductor_ship
	name = "Abductor Ship"
	cases = list("корабль Абдукторов", "корабля Абдукторов", "кораблю Абдукторов", "корабль Абдукторов", "кораблём Абдукторов", "корабле Абдукторов")
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = FALSE

/area/custom/wizard_station
	name = "Wizard's Den"
	cases = list("логово мага", "логова мага", "логову мага", "логово мага", "логовом мага", "логове мага")
	icon_state = "yellow"
	requires_power = 0

/area/custom/tophat
	name = "Tophat"
	cases = list("шляпа", "шляпы", "шляпе", "шляпу", "шляпой", "шляпе")
	icon_state = "tophat-room"

/area/custom/cult
	name = "Cult Heaven"
	cases = list("небеса культа", "небес культа", "небесам культа", "небеса культа", "небесами культа", "небесах культа")
	icon_state = "cult-heaven"
	requires_power = FALSE
	dynamic_lighting = TRUE
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
	cases = list("космический Додзё", "космического Додзё", "космическому Додзё", "космический Додзё", "космическим Додзё", "космическом Додзё")
	icon_state = "red"
	requires_power = 0
	dynamic_lighting = TRUE

/area/custom/arena
	name = "Deathmatch Arena"
	cases = list("арена смертельной битвы", "арены смертельной битвы", "арене смертельной битвы", "арену смертельной битвы", "ареной смертельной битвы", "арене смертельной битвы")
	icon_state = "red"
	requires_power = 0
	dynamic_lighting = FALSE
