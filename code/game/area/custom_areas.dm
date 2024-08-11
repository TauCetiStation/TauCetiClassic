 //////////
 //CUSTOM//
 //////////

 // Respectful request when adding new zones, add RU cases. Since zones are starting to be actively used in translation.

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

/area/velocity/checkpoint
	name = "Velocity Checkpoint"
	cases = list("КПП Велосити", "КПП Велосити", "КПП Велосити", "КПП Велосити", "КПП Велосити", "КПП Велосити")

/area/velocity/waitingroom
	name = "Velocity Waiting Hall"
	cases = list("зал ожидания Велосити", "зала ожидания Велосити", "залу ожидания Велосити", "зал ожидания Велосити", "залом ожидания Велосити", "зале ожидания Велосити")

/area/velocity/dormitories
	name = "Velocity Dormitories"
	cases = list("дормиторий Велосити", "дормитория Велосити", "дормиторию Велосити", "дормиторий Велосити", "дормиторием Велосити", "дормитории Велосити")

/area/velocity/locker
	name = "Velocity Locker Room"
	cases = list("раздевалка Велосити", "раздевалки Велосити", "раздевалке Велосити", "раздевалку Велосити", "раздевалкой Велосити", "раздевалке Велосити")

/area/velocity/exit
	name = "Escape Velocity Hallway"
	cases = list("коридор отбытия Велосити", "коридора отбытия Велосити", "коридору отбытия Велосити", "коридор отбытия Велосити", "коридором отбытия Велосити", "коридоре отбытия Велосити")

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
	icon_state = "syndie-elite"

/area/custom/syndicate_mothership/armory
	name = "Syndicate Armory"
	cases = list("оружейная Синдиката", "оружейной Синдиката", "оружейной Синдиката", "оружейную Синдиката", "оружейной Синдиката", "оружейной Синдиката")
	icon_state = "syndie-armory"

/area/custom/syndicate_mothership/droppod_garage
	name = "Mech garage"
	cases = list("гараж с мехами", "гаража с мехами", "гаражу с мехами", "гараж с мехами", "гаражом с мехами", "гараже с мехами")

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
	cases = list("корабль похитителей", "корабля похитителей", "кораблю похитителей", "корабль похитителей", "кораблём похитителей", "корабле похитителей")
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
	cases = list("рай", "рая", "раю", "рай", "раем", "рае")
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
	cases = list("космическое Додзё", "космического Додзё", "космическому Додзё", "космическое Додзё", "космическим Додзё", "космическом Додзё")
	icon_state = "red"
	requires_power = 0
	dynamic_lighting = TRUE

/area/custom/arena
	name = "Deathmatch Arena"
	cases = list("арена смертельной битвы", "арены смертельной битвы", "арене смертельной битвы", "арену смертельной битвы", "ареной смертельной битвы", "арене смертельной битвы")
	icon_state = "red"
	requires_power = 0
	dynamic_lighting = FALSE
