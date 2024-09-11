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

// Respectful request when adding new zones, add RU cases. Since zones are starting to be actively used in translation.

ADD_TO_GLOBAL_LIST(/area/station, the_station_areas)

//Engineering

/area/station/engineering
	icon_state = "engine"
	looped_ambience = 'sound/ambience/loop_engine.ogg'
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/engineering/engine
	name = "Engine Room"
	cases = list("машинное отделение", "машинного отделения", "машинному отделению", "машинное отделение", "машинным отделением", "машинном отделении")
	icon_state = "engine_smes"
	ambience = list('sound/ambience/engine_1.ogg', 'sound/ambience/engine_2.ogg', 'sound/ambience/engine_3.ogg', 'sound/ambience/engine_4.ogg')

/area/station/engineering/singularity
	name = "Singularity Area"
	cases = list("зона двигателя", "зоны двигателя", "зоне двигателя", "зона двигателя", "зоной двигателя", "зоне двигателя")
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/station/engineering/break_room
	name = "Engineering Break Room"
	cases = list("комната отдыха инженерного отдела", "комнаты отдыха инженерного отдела", "комнате отдыха инженерного отдела", "комната отдыха инженерного отдела", "комнатой отдыха инженерного отдела", "комнате отдыха инженерного отдела")
	sound_environment = SOUND_AREA_DEFAULT

/area/station/engineering/chiefs_office
	name = "Chief Engineer's office"
	cases = list("кабинет старшего инженера", "кабинета старшего инженера", "кабинету старшего инженера", "кабинет старшего инженера", "кабинетом старшего инженера", "кабинете старшего инженера")
	icon_state = "engine_control"
	sound_environment = SOUND_AREA_DEFAULT

/area/station/engineering/atmos
	name = "Atmospherics"
	cases = list("атмосферный отдел", "атмосферного отдела", "атмосферному отделу", "атмосферный отдел", "атмосферным отделом", "атмосферном отделе")
	icon_state = "atmos"
	ambience = list('sound/ambience/atmos_1.ogg', 'sound/ambience/atmos_2.ogg')

/area/station/engineering/drone_fabrication
	name = "Drone Fabrication"
	cases = list("дронная", "дронной", "дронной", "дронную", "дронной", "дронной")

//Maintenance
/area/station/maintenance
	cases = list ("техтоннель", "техтоннеля", "техтоннелю", "техтоннель", "техтоннелем", "техтоннеле")
	looped_ambience = 'sound/ambience/loop_maintenance.ogg'
	valid_territory = 0
	sound_environment = SOUND_AREA_MAINTENANCE
	ambience = list('sound/ambience/maintambience.ogg', 'sound/ambience/ambimaint3.ogg', 'sound/ambience/ambimaint5.ogg')

/area/station/maintenance/eva
	name = "EVA Maintenance"
	cases = list ("техтоннель ВКД", "техтоннеля ВКД", "техтоннелю ВКД", "техтоннель ВКД", "техтоннелем ВКД", "техтоннеле ВКД")
	icon_state = "fpmaint"

/area/station/maintenance/escape
	name = "Escape Shuttle Maintenance"
	cases = list ("техтоннель отбытия", "техтоннеля отбытия", "техтоннелю отбытия", "техтоннель отбытия", "техтоннелем отбытия", "техтоннеле отбытия")
	icon_state = "fmaint"

/area/station/maintenance/dormitory
	name = "Dormitory Maintenance"
	cases = list ("техтоннель дормиторий", "техтоннеля дормиторий", "техтоннелю дормиторий", "техтоннель дормиторий", "техтоннелем дормиторий", "техтоннеле дормиторий")
	icon_state = "fsmaint"

/area/station/maintenance/chapel
	name = "Chapel Maintenance"
	cases = list ("техтоннель церкви", "техтоннеля церкви", "техтоннелю церкви", "техтоннель церкви", "техтоннелем церкви", "техтоннеле церкви")
	icon_state = "fsmaint"

/area/station/maintenance/medbay
	name = "Medbay Maintenance"
	cases = list ("техтоннель медблока", "техтоннеля медблока", "техтоннелю медблока", "техтоннель медблока", "техтоннелем медблока", "техтоннеле медблока")
	icon_state = "asmaint"

/area/station/maintenance/science
	name = "Science Maintenance"
	cases = list ("техтоннель ОИР", "техтоннеля ОИР", "техтоннелю ОИР", "техтоннель ОИР", "техтоннелем ОИР", "техтоннеле ОИР")
	icon_state = "asmaint"

/area/station/maintenance/bridge
	name = "Bridge Maintenance"
	cases = list ("техтоннель мостика", "техтоннеля мостика", "техтоннелю мостика", "техтоннель мостика", "техтоннелем мостика", "техтоннеле мостика")
	icon_state = "maintcentral"

/area/station/maintenance/cargo
	name = "Cargo Maintenance"
	cases = list ("техтоннель отдела снабжения", "техтоннеля отдела снабжения", "техтоннелю отдела снабжения", "техтоннель отдела снабжения", "техтоннелем отдела снабжения", "техтоннеле отдела снабжения")
	icon_state = "pmaint"

/area/station/maintenance/engineering
	name = "Engineering Maintenance"
	cases = list ("техтоннель инженерного отдела", "техтоннеля инженерного отдела", "техтоннелю инженерного отдела", "техтоннель инженерного отдела", "техтоннелем инженерного отдела", "техтоннеле инженерного отдела")
	icon_state = "amaint"

/area/station/maintenance/incinerator
	name = "Incinerator"
	cases = list("мусоросжигатель", "мусоросжигателя", "мусоросжигателю", "мусоросжигатель", "мусоросжигателем", "мусоросжигателе")
	icon_state = "disposal"

/area/station/maintenance/atmos
	name = "Atmospherics Maintenance"
	cases = list ("техтоннель атмосферного отдела", "техтоннеля атмосферного отдела", "техтоннелю атмосферного отдела", "техтоннель атмосферного отдела", "техтоннелем атмосферного отдела", "техтоннеле атмосферного отдела")
	icon_state = "amaint"

/area/station/maintenance/disposal
	name = "Waste Disposal"
	cases = list("комната утилизации отходов", "комнаты утилизации отходов", "комнате утилизации отходов", "комнату утилизации отходов", "комнатой утилизации отходов", "комнате утилизации отходов")
	icon_state = "disposal"
	sound_environment = SOUND_AREA_SMALL_METALLIC

//Construction

/area/station/construction
	name = "Construction Area"
	cases = list("строительная площадка", "строительной площадки", "строительной площадке", "строительная площадка", "строительной площадке", "строительной площадке")
	icon_state = "yellow"

/area/station/construction/assembly_line //Derelict Assembly Line
	name = "Assembly Line"
	cases = list("cборочная линия", "cборочной линии", "сборочной линии", "сборочную линию", "сборочной линией", "сборочной линии")
	icon_state = "ass_line"
	power_equip = 0
	power_light = 0
	power_environ = 0

//Solars

/area/station/solar
	cases = list("солнечные панели", "солнечных панелей", "солнечным панелям", "солнечные панели", "солнечными панелями", "солнечных панелях")
	requires_power = 0
	dynamic_lighting = TRUE
	valid_territory = 0
	looped_ambience = 'sound/ambience/loop_space.ogg'
	sound_environment = SOUND_AREA_SMALL_METALLIC
	outdoors = TRUE

/area/station/solar/auxport
	name = "Fore Port Solar Array"
	cases = list("северо-западные солнечные панели", "северо-западных солнечных панелей", "северо-западным солнечным панелям", "северо-западные солнечные панели", "северо-западными солнечными панелями", "северо-западных солнечных панелях")
	icon_state = "panelsA"

/area/station/solar/auxstarboard
	name = "Fore Starboard Solar Array"
	cases = list("северо-восточные солнечные панели", "северо-восточных солнечных панелей", "северо-восточным солнечным панелям", "северо-восточные солнечные панели", "северо-восточными солнечными панелями", "северо-восточных солнечных панелях")
	icon_state = "panelsA"

/area/station/solar/starboard
	name = "Aft Starboard Solar Array"
	cases = list("юго-восточные солнечные панели", "юго-восточных солнечных панелей", "юго-восточным солнечным панелям", "юго-восточные солнечные панели", "юго-восточными солнечными панелями", "юго-восточных солнечных панелях")
	icon_state = "panelsS"

/area/station/solar/port
	name = "Aft Port Solar Array"
	cases = list("юго-западные солнечные панели", "юго-западных солнечных панелей", "юго-западным солнечным панелям", "юго-западные солнечные панели", "юго-западными солнечными панелями", "юго-западных солнечных панелях")
	icon_state = "panelsP"

/area/station/maintenance/auxsolarport
	name = "Fore Port Solar Maintenance"
	cases = list("северо-западные техтоннели", "северо-западных техтоннелей", "северо-западным техтоннелям", "северо-западные техтоннели", "северо-западными техтоннелями", "северо-западных техтоннелях")
	icon_state = "SolarcontrolA"

/area/station/maintenance/starboardsolar
	name = "Aft Starboard Solar Maintenance"
	cases = list("юго-восточные техтоннели", "юго-восточных техтоннелей", "юго-восточным техтоннелям", "юго-восточные техтоннели", "юго-восточными техтоннелями", "юго-восточных техтоннелях")
	icon_state = "SolarcontrolS"

/area/station/maintenance/portsolar
	name = "Aft Port Solar Maintenance"
	cases = list("юго-западные солнечные техтоннели", "юго-западных техтоннелей", "юго-западным техтоннелям", "юго-западные техтоннели", "юго-западными техтоннелями", "юго-западных техтоннелях")
	icon_state = "SolarcontrolP"

/area/station/maintenance/auxsolarstarboard
	name = "Fore Starboard Solar Maintenance"
	cases = list("северо-восточные техтоннели", "северо-восточных техтоннелей", "северо-восточным техтоннелям", "северо-восточные техтоннели", "северо-восточными техтоннелями", "северо-восточных техтоннелях")
	icon_state = "SolarcontrolA"

//Hallway

/area/station/hallway
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/hallway/primary/fore
	name = "Fore Primary Hallway"
	cases = list("северный коридор", "северного коридора", "северному коридору", "северный коридор", "северным коридором", "северном коридоре")
	icon_state = "hallF"

/area/station/hallway/primary/starboard
	name = "Starboard Primary Hallway"
	cases = list("восточный коридор", "восточного коридора", "восточному коридору", "восточный коридор", "восточным коридором", "восточном коридоре")
	icon_state = "hallS"

/area/station/hallway/primary/aft
	name = "Aft Primary Hallway"
	cases = list("южный коридор", "южного коридора", "южному коридору", "южный коридор", "южным коридором", "южном коридоре")
	icon_state = "hallA"

/area/station/hallway/primary/port
	name = "Port Primary Hallway"
	cases = list("западный коридор", "западного коридора", "западному коридору", "западный коридор", "западным коридором", "западном коридоре")
	icon_state = "hallP"

/area/station/hallway/primary/central
	name = "Central Primary Hallway"
	cases = list("центральный коридор", "центрального коридора", "центральному коридору", "центральный коридор", "центральным коридором", "центральном коридоре")
	icon_state = "hallC"

/area/station/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	cases = list("коридор отбытия", "коридора отбытия", "коридору отбытия", "коридор отбытия", "коридором отбытия", "коридоре отбытия")
	icon_state = "escape"

/area/station/hallway/secondary/arrival
	name = "Arrival Shuttle Hallway"
	cases = list("коридор прибытия", "коридора прибытия", "коридору прибытия", "коридор прибытия", "коридором прибытия", "коридоре прибытия")
	icon_state = "arrival"

/area/station/hallway/secondary/entry
	name = "Entry Shuttles Hallway"
	cases = list("коридор доков", "коридора доков", "коридору доков", "коридор доков", "коридором доков", "коридоре доков")
	icon_state = "entry"

/area/station/hallway/secondary/mine_sci_shuttle
	name = "Asteroid Shuttle Hallway"
	cases = list("шахтёрский док", "шахтёрского дока", "шахтёрскому доку", "шахтёрский док", "шахтёрским доком", "шахтёрском доке")
	icon_state = "mine_sci_shuttle"

//not used
/area/station/hallway/secondary/Podbay
	name = "Pod bay"
	icon_state = "escape"

//Command

/area/station/bridge
	name = "Bridge"
	cases = list("мостик", "мостика", "мостику", "мостик", "мостиком", "мостике")
	icon_state = "bridge"
	ambience = list('sound/ambience/bridge_1.ogg')

/area/station/bridge/meeting_room
	name = "Heads of Staff Meeting Room"
	cases = list("зал собраний глав", "зала собраний глав", "залу собраний глав", "зал собраний глав", "залом собраний глав", "зале собраний глав")

/area/station/bridge/captain_quarters
	name = "Captain's Office"
	cases = list("капитанская рубка", "капитанской рубки", "капитанской рубке", "капитанская рубка", "капитанской рубкой", "капитанской рубке")
	icon_state = "captain"

/area/station/bridge/hop_office
	name = "Head of Personnel's Office"
	cases = list("кабинет отдела кадров", "кабинета отдела кадров", "кабинетом отдела кадров", "кабинет отдела кадров", "кабинетом отдела кадров", "кабинете отдела кадров")
	icon_state = "head_quarters"

/area/station/bridge/teleporter
	name = "Teleporter"
	cases = list("телепортер", "телепортера", "телепортеру", "телепортер", "телепортером", "телепортере")
	icon_state = "teleporter"

/area/station/bridge/ai_upload
	name = "AI Upload Chamber"
	cases = list("комната загрузки законов ИИ", "комнаты смены законов ИИ", "комнате смены законов ИИ", "комната смены законов ИИ", "комнатой смены законов ИИ", "комнате смены законов ИИ")
	icon_state = "ai_upload"
	ambience = null
	looped_ambience = 'sound/ambience/loop_aisatelite.ogg'
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/bridge/comms
	name = "Communications Relay"
	cases = list("коммуникационное отделанное реле", "коммуникационного отделанного реле", "коммуникационному отделанному реле", "коммуникационное отделанное реле", "коммуникационным отделанным реле", "коммуникационном отделанном реле")
	icon_state = "tcomsatcham"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/bridge/server
	name = "PDA Server Room"
	cases = list("серверная ПДА", "серверной ПДА", "серверной ПДА", "серверную ПДА", "серверной ПДА", "серверной ПДА")
	icon_state = "server"
	is_force_ambience = TRUE
	ambience = list('sound/ambience/tcomms_1.ogg', 'sound/ambience/tcomms_2.ogg')
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/bridge/nuke_storage
	name = "Vault"
	cases = list("хранилище", "хранилища", "хранилище", "хранилище", "хранилищем", "хранилище")
	icon_state = "nuke_storage"
	is_force_ambience = TRUE
	ambience = list('sound/ambience/vault_1.ogg')
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/bridge/cmf_room
	name = "CMF altering room"
	cases = list("КМФ комната", "КМФ комнаты", "КМФ комнате", "КМФ комнату", "КМФ комнатой", "КМФ комнате")
	icon_state = "cmf"
	is_force_ambience = TRUE
	ambience = list('sound/ambience/bridge_1.ogg')
	sound_environment = SOUND_AREA_SMALL_METALLIC

//Civilian

/area/station/civilian/dormitories
	name = "Dormitories"
	cases = list("дормиторий", "дормитория", "дормиторию", "дормиторий", "дормиторием", "дормитории")
	icon_state = "Sleep"

/area/station/civilian/toilet
	name = "Dormitory Toilets"
	cases = list("туалеты дормиторий", "туалетов дормитория", "туалетам дормитория", "туалеты дормиторий", "туалетами дормиториев", "туалетах дормитория")
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/civilian/dormitories/security
	name = "Security Wing Dormitories"
	cases = list("охранное крыло дормиторий", "охранного крыла дормиторий", "охранному крылу дормиторий", "охранное крыло дормиторий", "охранным крылом дормиторий", "охранном крыле дормиторий")

/area/station/civilian/dormitories/male
	name = "Male Dorm"

/area/station/civilian/dormitories/female
	name = "Female Dorm"

/area/station/civilian/locker
	name = "Locker Room"
	cases = list("раздевалка", "раздевалки", "раздевалке", "раздевалку", "раздевалкой", "раздевалке")
	icon_state = "locker"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/civilian/locker/locker_toilet
	name = "Locker Toilets"
	cases = list("раздевалка туалетов", "раздевалки туалетов", "раздевалке туалетов", "раздевалку туалетов", "раздевалкой туалетов", "раздевалке туалетов")
	icon_state = "toilet"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/civilian/fitness
	name = "Fitness Room"
	cases = list("фитнес зал", "фитнес зала", "фитнес залу", "фитнес зал", "фитнес залом", "фитнес зале")
	icon_state = "fitness"

/area/station/civilian/cafeteria
	name = "Cafeteria"
	cases = list("кафетерий", "кафетерия", "кафетерию", "кафетерий", "кафетерием", "кафетерии")
	icon_state = "cafeteria"

/area/station/civilian/gym
	name = "Gym"
	cases = list("спортзал", "спортзала", "спортзалу", "спортзал", "спортзалом", "спортзале")
	icon_state = "fitness"

/area/station/civilian/kitchen
	name = "Kitchen"
	cases = list("кухня", "кухни", "кухне", "кухню", "кухней", "кухне")
	icon_state = "kitchen"

/area/station/civilian/kitchen/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_COOKING_AREA, GENERIC_TRAIT)

/area/station/civilian/cold_room
	name = "Cold Room"
	cases = list("холодильная камера", "холодильной камеры", "холодильной камере", "холодильная камера", "холодильной камерой","холодильной камере")
	icon_state = "coldroom"
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/civilian/barbershop
	name = "Barbershop"
	cases = list("барбершоп", "барбершопа", "барбершопу", "барбершоп", "барбершопом", "барбершопе")
	icon_state = "barbershop"

/area/station/civilian/bar
	name = "Bar"
	cases = list("бар", "бара", "бару", "бар", "баром", "баре")
	icon_state = "bar"

/area/station/civilian/playroom
	name = "Play Room"
	cases = list("игровая комната", "игровой комнаты", "игровой комнате", "игровая комната", "игровой комнатой", "игровой комнате")
	icon_state = "fitness"

/area/station/civilian/theatre
	name = "Theatre"
	cases = list("театр", "театра", "театру", "театр", "театром", "театре")
	icon_state = "Theatre"

/area/station/civilian/library
	name = "Library"
	cases = list("библиотека", "библиотеки", "библиотеке", "библиотека", "библиотекой", "библиотеке")
	icon_state = "library"

/area/station/civilian/chapel
	name = "Chapel"
	cases = list("церковь", "церкви", "церкви", "церковь", "церковью", "церкви")
	icon_state = "chapel"
	ambience = list('sound/ambience/chapel_1.ogg', 'sound/ambience/chapel_2.ogg', 'sound/ambience/chapel_3.ogg', 'sound/ambience/chapel_4.ogg')
	sound_environment = SOUND_ENVIRONMENT_ARENA

/area/station/civilian/chapel/office
	name = "Chapel Office"
	cases = list("офис священника", "офиса священника", "офису священника", "офис священника", "офисом священника", "офисе священника")
	icon_state = "chapeloffice"
	sound_environment = SOUND_AREA_DEFAULT

/area/station/civilian/chapel/altar
	name = "Altar"
	cases = list("алтарь", "алтаря", "алтарю", "влтарь", "алтарём", "алтаре")
	icon_state = "altar"
	sound_environment = SOUND_AREA_DEFAULT

/area/station/civilian/chapel/crematorium
	name = "Crematorium"
	cases = list("крематорий", "крематория", "крематорию", "крематорий", "крематорием", "крематории")
	icon_state = "crematorium"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/civilian/chapel/mass_driver
	name = "Chapel Mass Driver"
	cases = list("электромагнитная катапульта церкви", "электромагнитной катапульты церкви", "электромагнитной катапульте церкви", "электромагнитная катапульта церкви", "электромагнитной катапультой церкви", "электромагнитной катапульте церкви")
	icon_state = "massdriver"

/area/station/civilian/garden
	name = "Garden"
	cases = list("сад", "сада", "саду", "сад", "садом", "саде")
	icon_state = "garden"
	looped_ambience = 'sound/ambience/loop_garden.ogg'
	sound_environment = SOUND_ENVIRONMENT_ALLEY

/area/station/civilian/janitor
	name = "Custodial Closet"
	cases = list("коморка уборщика", "коморки уборщика", "коморке уборщика", "коморка уборщика", "коморкой уборщика", "коморке уборщика")
	icon_state = "janitor"

/area/station/civilian/hydroponics
	name = "Hydroponics"
	cases = list("гидропоники", "гидропоник", "гидропоникам", "гидропоник", "гидропониками","гидропониках")
	icon_state = "hydro"

//Holodeck
/area/station/civilian/holodeck
	name = "Holodeck"
	cases = list("голодек", "голодека", "голодеку", "голодек", "голодеком", "голодеке")
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
	cases = list("врата", "врат", "вратам", "врата", "вратами", "вратах")
	icon_state = "teleporter"

//MedBay

/area/station/medical
	name = "Medbay"
	cases = list("медблок", "медблока", "медблоку", "медблок", "медблоком", "медблоке")
	icon_state = "medbay"
	ambience = list('sound/ambience/medbay_1.ogg', 'sound/ambience/medbay_2.ogg', 'sound/ambience/medbay_3.ogg', 'sound/ambience/medbay_4.ogg', 'sound/ambience/medbay_5.ogg')

//Medbay is a large area, these additional areas help level out APC load.
/area/station/medical/hallway
	icon_state = "medbay2"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/medical/reception
	name = "Medbay Reception"
	cases = list("приёмная медблока","приёмной медблока","приёмной медблока", "приёмную медблока","приёмной медблока","приёмной медблока")
	icon_state = "medbay"

/area/station/medical/storage
	name = "Medbay Storage"
	cases = list("склад медблока", "склада медблока", "складу медблока", "склад медблока", "складом медблока", "складе медблока")
	icon_state = "medbay3"

/area/station/medical/medbreak
	name = "Medbay Breaktime Room"
	cases = list("комната отдыха медблока", "комнаты отдыха медблока", "комнате отдыха медблока", "комната отдыха медблока", "комнатой отдыха медблока", "комнате отдыха медблока")
	icon_state = "medbay3"

/area/station/medical/psych
	name = "Psych Room"
	cases = list("кабинет психолога", "кабинета психолога", "кабинету психолога", "кабинет психолога", "кабинетом психолога", "кабинете психолога")
	icon_state = "medbay3"

/area/station/medical/patients_rooms
	name = "Patient's Rooms"
	cases = list("палаты пациентов", "палат пацицентов", "палатам пациентов", "палаты пациентов", "палатами пациентов", "палатах пациентов")
	icon_state = "patients"

/area/station/medical/patient_a
	name = "Patient Room One"
	cases = list("палата пациента №1", "палаты пациента №1", "палате пациента №1", "палата пациента №1", "палатой пациента №1", "палате пациента №1")
	icon_state = "patients"

/area/station/medical/patient_b
	name = "Patient Room Two"
	cases = list("палата пациента №2", "палаты пациента №2", "палате пациента №2", "палата пациента №2", "палатой пациента №2", "палате пациента №2")
	icon_state = "patients"

/area/station/medical/cmo
	name = "Chief Medical Officer's office"
	cases = list("кабинет главврача", "кабинету главврача", "кабинетом главврача", "кабинет главврача", "кабинетом главврача", "кабинете главврача")
	icon_state = "CMO"

/area/station/medical/virology
	name = "Virology"
	cases = list("вирусология", "вирусологии", "вирусологии", "вирусология", "вирусологией", "вирусологии")
	icon_state = "virology"

/area/station/medical/morgue
	name = "Morgue"
	cases = list("морг", "морга", "моргу", "морг", "моргом", "морге")
	icon_state = "morgue"
	ambience = list('sound/ambience/morgue_1.ogg', 'sound/ambience/morgue_2.ogg', 'sound/ambience/morgue_3.ogg')
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/medical/chemistry
	name = "Chemistry"
	cases = list("химия", "химии", "химии", "химия", "химией", "химии")
	icon_state = "chem"
	ambience = list('sound/ambience/chemistry_1.ogg', 'sound/ambience/chemistry_2.ogg')

/area/station/medical/surgery
	name = "Operating Theatre 1"
	cases = list("операционная №1", "операционной №1", "операционной №1", "операционная №1", "операционной №1", "операционной №1")
	icon_state = "surgery"
	ambience = list('sound/ambience/surgery_1.ogg', 'sound/ambience/surgery_2.ogg')

/area/station/medical/surgery2
	name = "Operating Theatre 2"
	cases = list("операционная №2", "операционной №2", "операционной №2", "операционная №2", "операционной №2", "операционной №2")
	icon_state = "surgery"

/area/station/medical/surgeryobs
	name = "Operation Observation Room"
	cases = list("комната наблюдения за операциями", "комнаты наблюдения за операциями", "комнате наблюдения за операциями", "комната наблюдения за операциями", "комнатой наблюдения за операцией", "комнате наблюдения за операциями")
	icon_state = "surgery"

/area/station/medical/cryo
	name = "Cryogenics"
	cases = list("криогенные камеры", "криогенных камер", "криогенным камерам", "криогенные камеры", "криогенными камерами", "криогенных камерах")
	icon_state = "cryo"

/area/station/medical/genetics
	name = "Genetics Lab"
	cases = list("генетика", "генетики", "генетике", "генетика", "генетикой", "генетике")
	icon_state = "genetics"

/area/station/medical/genetics_cloning
	name = "Cloning Lab"
	cases = list("отдел клонирования", "отдела клонирования", "отделу клонирования", "отдел клонирования", "отделом клонирования", "отделе клонирования")
	icon_state = "cloning"

/area/station/medical/sleeper
	name = "Emergency Treatment Centre"
	cases = list("центр неотложной помощи", "центра неотложной помощи", "центру неотложной помощи", "центр неотложной помощи", "центром неотложной помощи", "центре неотложной помощи")
	icon_state = "exam_room"

//Security

/area/station/security/main
	name = "Security Office"
	cases = list("офис службы безопасности", "офиса службы безопасности", "офису службы безопасности", "офис службы безопасности", "офисом службы безопасности", "офисе службы безопасности")
	icon_state = "security"

/area/station/security/lobby
	name = "Security lobby"
	cases = list("приёмная службы безопасности","приёмной службы безопасности","приёмной службы безопасности", "приёмную службы безопасности","приёмной службы безопасности","приёмной службы безопасности")
	icon_state = "security"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/security/brig
	name = "Brig"
	cases = list("бриг", "брига", "бригу", "бриг", "бригом", "бриге")
	icon_state = "brig"

/area/station/security/brig/solitary_confinement
	name = "Solitary Confinement"
	cases = list("карцер", "карцера", "карцеру", "карцер", "карцером", "карцере")

/area/station/security/interrogation
	name = "Interrogation"
	cases = list("допросная", "допросной", "допросной", "допросная", "допросной", "допросной")
	icon_state = "interrogation"
	looped_ambience = 'sound/ambience/loop_interrogation.ogg'

/area/station/security/execution
	name = "Execution"
	cases = list("комната казни", "комнаты казни", "комнате казни", "комната казни", "комнатой казни", "комнате казни")
	icon_state = "execution_room"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/security/prison
	name = "Prison Wing"
	cases = list("тюремное крыло", "тюремного крыла", "тюремному крылу", "тюремное крыло", "тюремным крылом", "тюремном крыле")
	icon_state = "sec_prison"
	ambience = list('sound/ambience/prison_1.ogg')

/area/station/security/prison/toilet
	name = "Prison Toilet"
	cases = list("тюремный туалет", "тюремного туалета", "тюремному туалету", "тюремный туалет", "тюремным туалетом", "тюремном туалете")

/area/station/security/warden
	name = "Warden"
	cases = list("кабинет смотрителя", "кабинета смотрителя", "кабинету смотрителя", "кабинет смотрителя", "кабинетом смотрителя", "кабинете смотрителя")
	icon_state = "warden"

/area/station/security/armoury
	name = "Armory"
	cases = list("оружейная", "оружейной", "оружейной", "оружейную", "оружейной", "оружейной")
	icon_state = "armory"
	looped_ambience = 'sound/ambience/loop_armory.ogg'

/area/station/security/hos
	name = "Head of Security's Office"
	cases = list("кабинет главы службы безопасности", "кабинета главы службы безопасности", "кабинету главы службы безопасности", "кабинет главы службы безопасности", "кабинетом главы службы безопасности", "кабинете главы службы безопасности")
	icon_state = "sec_hos"

/area/station/security/detectives_office
	name = "Detective's Office"
	cases = list("кабинет детектива", "кабинета детектива", "кабинету детектива", "кабинет детектива", "кабинетом детектива", "кабинете детектива")
	icon_state = "detective"
	ambience = list('sound/ambience/detective_1.ogg')

/area/station/security/forensic_office
	name = "Forensic's Office"
	cases = list("кабинет криминалистики", "кабинета криминалистики", "кабинету  криминалистики", "кабинет  криминалистики", "кабинетом  криминалистики", "кабинете  криминалистики")
	icon_state = "detective"
	ambience = list('sound/ambience/detective_1.ogg')

/area/station/security/range
	name = "Firing Range"
	cases = list("стрельбище", "стрельбища", "стрельбищу", "стрельбище", "стрельбищем", "стрельбище")
	icon_state = "firingrange"

/area/station/security/processing
	name = "Labor Shuttle Dock"
	cases = list("док трудового шаттла", "дока трудового шаттла", "доку трудового шаттла", "док трудового шаттла", "доком трудового шаттла", "доке трудового шаттла")
	icon_state = "sec_processing"

/area/station/security/checkpoint
	name = "Security Checkpoint"
	cases = list("КПП службы безопасности", "КПП службы безопасности", "КПП службы безопасности", "КПП службы безопасности", "КПП службы безопасности", "КПП службы безопасности")
	icon_state = "security"

/area/station/security/vacantoffice
	name = "Coworking"
	cases  = list("рабочий кабинет", "рабочего кабинета", "рабочему кабинету", "рабочий кабинет","рабочим кабинетом", "рабочем кабинете")
	icon_state = "security"
	ambience = list('sound/ambience/vacant_1.ogg')

/area/station/security/iaa_office
	name = "Internal Affairs"
	cases = list("кабинет АВД", "кабинета АВД", "кабинету АВД", "кабинет АВД", "кабинетом АВД", "кабинете АВД")
	icon_state = "law"

/area/station/security/blueshield
	name = "Blueshield Office"
	cases = list("кабинет СЩ", "кабинета СЩ", "кабинету СЩ", "кабинет СЩ", "кабинетом СЩ", "кабинете СЩ")
	icon_state = "law"

/area/station/security/blueshield/shuttle
	name = "Blueshield Shuttle"
	cases = list("шаттл СЩ", "шаттла СЩ", "шаттлу СЩ", "шаттл СЩ", "шаттлом СЩ", "шаттле СЩ")

/area/station/security/lawyer_office
	name = "Lawyer Office"
	cases = list("кабинет адвоката", "кабинета адвоката", "кабинету адвоката", "кабинет адвоката", "кабинетом адвоката", "кабинете адвоката")
	icon_state = "law"

//Cargo bay
/area/station/cargo
	name = "Quartermasters"
	cases = list("отдел снабжения", "отдела снабжения", "отделу снабжения", "отдел снабжения", "отделом снабжения", "отделе снабжения")
	icon_state = "quart"

/area/station/cargo/office
	name = "Cargo Office"
	icon_state = "quartoffice"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/cargo/storage
	name = "Cargo Bay"
	cases = list("склад ОС", "склада ОС", "складу ОС", "склад ОС", "складом ОС", "складе ОС")
	icon_state = "quartstorage"
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/cargo/qm
	name = "Quartermaster's Office"
	cases = list("кабинет завхоза", "кабинета завхоза", "кабинету завхоза", "кабинет завхоза", "кабинетом завхоза", "кабинете завхоза")
	icon_state = "quart"

/area/station/cargo/recycler
	name = "Recycler"
	cases = list("отдел переработки", "отдела переработки", "отделу переработки", "отдел переработки", "отделом переработки", "отделе переработки")
	icon_state = "recycler"

/area/station/cargo/recycleroffice
	name = "Recycleroffice"
	cases = list("офис переработчиков", "офиса переработчиков", "офису переработчиков", "офис переработчиков", "офисом переработчиков", "офисе переработчиков")
	icon_state = "recycleroffice"
	sound_environment = SOUND_AREA_STATION_HALLWAY

/area/station/cargo/miningbreaktime
	name = "Cargo Breaktime Room"
	cases = list("комната отдыха ОС", "комнаты отдыха ОС", "комнате отдыха ОС", "комната отдыха ОС", "комнатой отдыха ОС", "комнате отдыха ОС")
	icon_state = "miningbreaktime"

/area/station/cargo/miningoffice
	name = "Mining office"
	cases = list("офис шахтёров", "офиса шахтёров", "офису шахтёров", "офис шахтёров", "офисом шахтёров", "офисе шахтёров")
	icon_state = "miningoffice"

//rnd (Research and Development)

/area/station/rnd
	cases = list("отдел исследований и разработки", "отдела исследований и разработки", "отделу исследований и разработки", "отдел исследований и разработки", "отделом исследований и разработки", "отделе исследований и разработки")
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
	cases = list("ксенобиологии", "ксенобиологии", "ксенобиология", "ксенобиологией", "ксенобиологии")
	icon_state = "scixeno"

/area/station/rnd/storage
	name = "Toxins Storage"
	cases = list("склад газов ОИР", "склада газов ОИР", "складу газов ОИР", "склад газов ОИР", "складом газов ОИР", "складе газов ОИР")
	icon_state = "toxstorage"
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/rnd/test_area
	name = "Toxins Test Site"
	cases = list("тестовый полигон", "тестового полигона", "тестовому полигону", "тестовый полигон", "тестовым полигоном", "тестовом полигоне")
	icon_state = "toxtest"

/area/station/rnd/mixing
	name = "Toxins Mixing Room"
	cases = list("комната смешивания токсинов", "комнаты смешивания токсинов", "комнате смешивания токсинов", "комнату смешивания токсинов", "комнатой смешивания токсинов", "комнате смешивания токсинов")
	icon_state = "toxmix"

/area/station/rnd/misc_lab
	name = "Miscellaneous Research"
	cases = list("изолятор ОИР", "изолятора ОИР", "изолятору ОИР", "изолятор ОИР", "изолятором ОИР", "изоляторе ОИР")
	icon_state = "scimisc"

/area/station/rnd/telesci
	name = "Telescience Lab"
	cases = list("отдел теленауки", "отдела теленауки", "отделу теленауки", "отдел теленауки", "отделом теленауки", "отделе теленауки")
	icon_state = "scitele"

/area/station/rnd/tox_launch
	name = "Toxins Launch Roon"
	cases = list("комната запуска бомб", "комнаты запуска бомб", "комнате запуска бомб", "комната запуска бомб", "комнатой запуска бомб", "комнате запуска бомб")
	icon_state = "toxlaunch"

/area/station/rnd/scibreak
	name = "Science Breaktime Room"
	cases = list("комната отдыха ОИР", "комнаты отдыха ОИР", "комнате отдыха ОИР", "комната отдыха ОИР", "комнатой отдыха ОИР", "комнате отдыха ОИР")
	icon_state = "scirest"

/area/station/rnd/hor
	name = "Research Director's Office"
	cases = list("кабинет научрука", "кабинета научрука", "кабинету научрука", "кабинет научрука", "кабинетом научрука", "кабинете научрука")
	icon_state = "head_quarters"

/area/station/rnd/server
	name = "Server Room"
	cases = list("серверная ОИР", "серверной ОИР", "серверной ОИР", "серверная ОИР", "серверной ОИР", "серверной ОИР")
	icon_state = "server"
	is_force_ambience = TRUE
	ambience = list('sound/ambience/tcomms_1.ogg', 'sound/ambience/tcomms_2.ogg')
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/rnd/chargebay
	name = "Mech Bay"
	cases = list("склад мехов", "склада мехов", "складу мехов", "склад мехов", "складом мехов", "складе мехов")
	icon_state = "mechbay"

/area/station/rnd/robotics
	name = "Robotics Lab"
	cases = list("отдел робототехники", "отдела робототехники", "отделу робототехники", "отдел робототехники", "отделом робототехники", "отделе робототехники")
	icon_state = "scirobo"
	ambience = list('sound/ambience/robotics_1.ogg', 'sound/ambience/robotics_2.ogg')

/area/station/rnd/brainstorm_center
	name = "Brainstorm Center"
	cases = list("центр мозгового штурма", "центра мозгового штурма", "центру мозгового штурма", "центр мозгового штурма", "центром мозгового штурма", "центре мозгового штурма")
	icon_state = "bs"

//Storage

/area/station/ai_monitored/eva
	name = "EVA Storage"
	cases = list("хранилище ВКД", "хранилища ВКД", "хранилище ВКД", "хранилище ВКД", "хранилищем ВКД", "хранилище ВКД")
	icon_state = "eva"

/area/station/storage/tools
	name = "Auxiliary Tool Storage"
	cases = list("вспомогательный склад инструментов", "вспомогательного склада инструментов", "вспомогательну складу инструментов", "вспомогательный склад инструментов", "вспомогательным складом инструментов", "вспомогательном складе инструментов")
	icon_state = "storage"

/area/station/storage/primary
	name = "Primary Tool Storage"
	cases = list("основной склад инструментов", "основного склада инструментов", "основному складу инструментов", "основной склад инструментов", "основным складом инструментов", "основном складе инструментов")
	icon_state = "primarystorage"

/area/station/storage/emergency
	name = "Starboard Emergency Storage"
	cases = list("экстренное хранилище по правому борту", "экстренного хранилища по правому борту", "экстренному хранилищу по правому борту", "экстренное хранилище по правому борту", "экстренным хранилищем по правому борту", "экстренном хранилище по правому борту")
	icon_state = "emergencystorage"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/storage/emergency2
	name = "Port Emergency Storage"
	cases = list("портовое экстренное хранилище", "портового экстренного хранилища", "портовому экстренному хранилищу", "портовое экстренное хранилище", "портовым экстренным хранилищем", "портовом экстренном хранилище")
	icon_state = "emergencystorage"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/storage/emergency3
	name = "Central Emergency Storage"
	cases = list("центральное экстренное хранилище", "центрального экстренного хранилища", "центральному экстренному хранилищу", "центральное экстренное хранилище", "центральным экстренным хранилищем", "центральном экстренном хранилище")
	icon_state = "emergencystorage"
	sound_environment = SOUND_AREA_SMALL_METALLIC

/area/station/storage/tech
	name = "Technical Storage"
	cases = list("техническое хранилище", "технического хранилища", "техническому хранилищу", "техническое хранилище", "техническим хранилищем", "техническом хранилище")
	icon_state = "auxstorage"

/area/station/storage/tech/north
	name = "North Technical Storage"
	cases = list("северное техническое хранилище", "северного технического хранилища", "северному техническому хранилищу", "северное техническое хранилище", "северным техническим хранилищем", "северном техническом хранилище")
	sound_environment = SOUND_AREA_SMALL_METALLIC

//AI

/area/station/aisat
	name = "AI Satellite Exterior"
	cases = list("внешний периметр спутника ИИ", "внешнего периметра спутника ИИ", "внешнему периметру спутника ИИ", "внешний периметр спутника ИИ", "внешним периметром спутника ИИ", "внешнем периметре спутника ИИ")
	icon_state = "storage"
	looped_ambience = 'sound/ambience/loop_aisatelite.ogg'
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/ai_monitored/storage_secure
	name = "Secure Storage"
	cases = list("защищённое хранилище", "защищённого хранилища", "защищённому хранилищу", "защищённое хранилище", "защищённым хранилищем", "защищённом хранилище")
	icon_state = "storage"
	looped_ambience = 'sound/ambience/loop_aisatelite.ogg'
	sound_environment = SOUND_AREA_LARGE_METALLIC

/area/station/aisat/ai_chamber
	name = "AI Chamber"
	cases = list("ядро ИИ", "ядра ИИ", "ядру ИИ", "ядро ИИ", "ядром ИИ", "ядре ИИ")
	icon_state = "ai_chamber"
	ambience = 'sound/ambience/aicore.ogg'

/area/station/aisat/antechamber
	name = "AI Satellite"
	cases = list("спутник ИИ", "спутника ИИ", "спутнику ИИ", "спутник ИИ", "спутником ИИ", "спутнике ИИ")
	icon_state = "ai"

/area/station/aisat/antechamber_interior
	name = "AI Satellite Antechamber"
	cases = list("вестибюль спутника ИИ", "вестибюля спутника ИИ", "вестибюлю спутника ИИ", "вестибюль спутника ИИ", "вестибюлем спутника ИИ", "вестибюле спутника ИИ")
	icon_state = "ai"

/area/station/aisat/teleport
	name = "AI Satellite Teleporter Room"
	cases = list("телепортер спутника ИИ", "телепортера спутника ИИ", "телепортеру спутнику ИИ", "телепортер спутник ИИ", "телепортером спутником ИИ", "телепортере спутника ИИ")
	icon_state = "teleporter"
	sound_environment = SOUND_AREA_SMALL_METALLIC

// Telecommunications Satellite

/area/station/tcommsat
	cases = list("центр управления телекоммуникациями", "центра управления телекоммуникациями", "центру управления телекоммуникациями", "центр управления телекоммуникациями", "центром управления телекоммуникациями", "центре управления телекоммуникациями")
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

/area/station/tcommsat/cyborg
	name = "Cyborg Station"
	cases = list("зарядная станция киборгов", "зарядной станции киборгов", "зарядной станции киборгов", "зарядную станцию киборгов", "зарядной станцией киборгов", "зарядной станции киборгов")
	icon_state = "tcomsatcham"
	ambience = 'sound/ambience/cyborgstation.ogg'
	sound_environment = SOUND_AREA_SMALL_METALLIC
