 ////////////
 //SHUTTLES//
 ////////////

//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	name = "Shuttle"
	cases = list("шаттл", "шаттла", "шаттлу", "шаттл", "шаттлом", "шаттле")
	icon_state = "shuttle"
	requires_power = 0
	valid_territory = 0
	dynamic_lighting = TRUE

/area/shuttle/atom_init()
	if(!canSmoothWithAreas)
		canSmoothWithAreas = type
	. = ..()

//Velocity Officer Shuttle
/area/shuttle/officer
	name = "Officer Shuttle"
	cases = list("шаттл офицеров", "шаттла офицеров", "шаттлу офицеров", "шаттл офицеров", "шаттлом офицеров", "шаттле офицеров")

/area/shuttle/officer/velocity
	name = "NTS Velocity"
	cases = list("НТС Велосити", "НТС Велосити", "НТС Велосити", "НТС Велосити", "НТС Велосити", "НТС Велосити")
	icon_state = "shuttle2"

/area/shuttle/officer/transit
	icon_state = "shuttle"

/area/shuttle/officer/station
	name = "NSS Exodus"
	cases = list("КСН Исход", "КСН Исхода", "КСН Исходу", "КСН Исход", "КСН Исходом", "КСН Исходе")
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/officer/centcom
	name = "Centcomm"
	cases = list("ЦентКом", "ЦентКома", "ЦентКому", "ЦентКом", "ЦентКомом", "ЦентКоме")
	icon_state = "shuttle"

//Station Supply Shuttle
/area/shuttle/supply/station
	name = "supply shuttle"
	cases = list("грузовой шаттл", "грузового шаттла", "грузовому шаттлу", "грузовой шаттл", "грузовым шаттлом", "грузовом шаттле")
	icon_state = "shuttle3"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/supply/velocity
	name = "supply shuttle"
	cases = list("грузовой шаттл", "грузового шаттла", "грузовому шаттлу", "грузовой шаттл", "грузовым шаттлом", "грузовом шаттле")
	icon_state = "shuttle3"

//Arrival Velocity Shuttle
/area/shuttle/arrival
	name = "Arrival Shuttle"
	cases = list("трансферный шаттл", "трансферного шаттла", "трансферному шаттла", "трансферный шаттл", "трансферным шаттлом", "трансферном шаттле")

/area/shuttle/arrival/velocity
	name = "NTS Velocity"
	cases = list("НТС Велосити", "НТС Велосити", "НТС Велосити", "НТС Велосити", "НТС Велосити", "НТС Велосити")
	icon_state = "shuttle2"
	looped_ambience = 'sound/ambience/loop_velocity.ogg'

/area/shuttle/arrival/velocity/Entered(mob/M)
	..()
	if(istype(M) && M.client)
		M.client.guard.time_velocity_shuttle = world.timeofday

/area/shuttle/arrival/transit
	name = "Space"
	cases = list("космос", "космоса", "космосу", "космос", "космосом", "космосе")
	icon_state = "shuttle"
	parallax_movedir = EAST

/area/shuttle/arrival/station
	name = "NSS Exodus"
	cases = list("КСН Исход", "КСН Исхода", "КСН Исходу", "КСН Исход", "КСН Исходом", "КСН Исходе")
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Emergency Nanotrasen Shuttle
/area/shuttle/escape
	name = "Emergency Shuttle"
	cases = list("шаттл эвакуации", "шаттла эвакуации", "шаттлу эвакуации", "шаттл эвакуации", "шаттлом эвакуации", "шаттле эвакуации")

/area/shuttle/escape/station
	name = "Emergency Shuttle Station"
	icon_state = "shuttle2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/escape/centcom
	name = "Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/escape/transit // the area to pass through for 3 minute transit
	name = "Emergency Shuttle Transit"
	icon_state = "shuttle"
	parallax_movedir = NORTH

//Escape Pod One
/area/shuttle/escape_pod1
	name = "Escape Pod One"
	cases = list("спасательная капсула №1", "спасательной капсулы №1", "спасательной капсуле №1", "спасательную капсулу №1", "спасательной капсулой №1", "спасательной капсуле №1")

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

//Escape Pod Two
/area/shuttle/escape_pod2
	name = "Escape Pod Two"
	cases = list("спасательная капсула №2", "спасательной капсулы №2", "спасательной капсуле №2", "спасательную капсулу №2", "спасательной капсулой №2", "спасательной капсуле №2")

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

//Escape Pod Three
/area/shuttle/escape_pod3
	name = "Escape Pod Three"
	cases = list("спасательная капсула №3", "спасательной капсулы №3", "спасательной капсуле №3", "спасательную капсулу №3", "спасательной капсулой №3", "спасательной капсуле №3")

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

//Escape Pod Four
/area/shuttle/escape_pod4
	name = "Escape Pod Four"
	cases = list("спасательная капсула №4", "спасательной капсулы №4", "спасательной капсуле №4", "спасательную капсулу №4", "спасательной капсулой №4", "спасательной капсуле №4")

/area/shuttle/escape_pod4/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod4/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod4/transit
	icon_state = "shuttle"
	parallax_movedir = WEST

//Escape Pod Five
/area/shuttle/escape_pod5
	name = "Escape Pod Five"
	cases = list("спасательная капсула №5", "спасательной капсулы №5", "спасательной капсуле №5", "спасательную капсулу №5", "спасательной капсулой №5", "спасательной капсуле №5")

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"
	parallax_movedir = NORTH

//Escape Pod Six
/area/shuttle/escape_pod6
	name = "Escape Pod Six"
	cases = list("спасательная капсула №6", "спасательной капсулы №6", "спасательной капсуле №6", "спасательную капсулу №6", "спасательной капсулой №6", "спасательной капсуле №6")

/area/shuttle/escape_pod6/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod6/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod6/transit
	icon_state = "shuttle"
	parallax_movedir = NORTH

//Mining-Research Shuttle
/area/shuttle/mining
	name = "Mining-Research Shuttle"
	cases = list("шахтёрский-исследовательский шаттл", "шахтёрского-исследовательского шаттла", "шахтёрскому-исследовательскому шаттлу", "шахтёрский-исследовательский шаттл", "шахтёрским-исследовательским шаттлом", "шахтёрском-исследовательском шаттле")

/area/shuttle/mining/station
	icon_state = "shuttle2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/mining/outpost
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/mining/research
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/mining/transit
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Centcom Transport Shuttle
/area/shuttle/transport1/centcom
	icon_state = "shuttle"
	name = "Transport Shuttle Centcom"
	cases = list("транспортный шаттл", "транспортного шаттла", "транспортному шаттлу", "транспортный шаттл", "транспортным шаттлом", "транспортном шаттле")

/area/shuttle/transport1/station
	icon_state = "shuttle"
	name = "Transport Shuttle"
	cases = list("транспортный шаттл", "транспортного шаттла", "транспортному шаттлу", "транспортный шаттл", "транспортным шаттлом", "транспортном шаттле")
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Alien pod
/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "Alien Shuttle Base"
	requires_power = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "Alien Shuttle Mine"
	requires_power = 1

//Special Ops Shuttle
/area/shuttle/specops/centcom
	name = "Special Ops Shuttle"
	cases = list("шаттл специального назначения", "шаттла специального назначения", "шаттлу специального назначения", "шаттл специального назначения", "шаттлом специального назначения", "шаттле специального назначения")
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "Special Ops Shuttle"
	cases = list("шаттл специального назначения", "шаттла специального назначения", "шаттлу специального назначения", "шаттл специального назначения", "шаттлом специального назначения", "шаттле специального назначения")
	icon_state = "shuttlered2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Syndicate Elite Shuttle
/area/shuttle/syndicate_elite/mothership
	name = "Syndicate Elite Shuttle"
	cases = list("элитный шаттл Синдиката", "элитного шаттла Синдиката", "элитному шаттлу Синдиката", "элитный шаттл Синдиката", "элитным шаттлом Синдиката", "элитном шаттле Синдиката")
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "Syndicate Elite Shuttle"
	cases = list("элитный шаттл Синдиката", "элитного шаттла Синдиката", "элитному шаттлу Синдиката", "элитный шаттл Синдиката", "элитным шаттлом Синдиката", "элитном шаттле Синдиката")
	icon_state = "shuttlered2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Administration Centcom Shuttle
/area/shuttle/administration/centcom
	name = "Administration Shuttle Centcom"
	cases = list("административный шаттл", "административного шаттла", "административному шаттлу", "административный шаттл", "административным шаттлом", "административном шаттле")
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "Administration Shuttle"
	cases = list("административный шаттл", "административного шаттла", "административному шаттлу", "административный шаттл", "административным шаттлом", "административном шаттле")
	icon_state = "shuttlered2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Vox shuttle
/area/shuttle/vox/arkship
	name = "Vox Skipjack"
	cases = list("шаттл Скипджек", "шаттла Скипджек", "шаттлу Скипджек", "шаттл Скипджек", "шаттлом Скипджек", "шаттле Скипджек")
	icon_state = "yellow"

/area/shuttle/vox/arkship_hold
	name = "Vox Skipjack Hold"
	cases = list("шаттл Skipjack", "шаттла Skipjack", "шаттлу Skipjack", "шаттл Skipjack", "шаттлом Skipjack", "шаттле Skipjack")
	icon_state = "yellow"

/area/shuttle/vox/transit
	name = "hyperspace"
	cases = list("гиперпространство", "гиперпространства", "гиперпространству", "гиперпространство", "гиперпространством", "гиперпространстве")
	icon_state = "shuttle"
	parallax_movedir = NORTH

/area/shuttle/vox/southwest_solars
	name = "Aft port solars"
	cases = list("кормовые солнечные панели по левому борту", "кормовых солнечных панелей по левому борту", "кормовым солнечным панелям по левому борту", "кормовые солнечные панели по левому борту", "кормовыми солнечными панелями по левому борту", "кормовых солнечных панелях по левому борту")
	icon_state = "southwest"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/vox/northwest_solars
	name = "Fore port solars"
	cases = list("носовые солнечные панели по левому борту", "носовых солнечных панелей по левому борту", "носовым солнечным панелям по левому борту", "носовые солнечные панели по левому борту", "носовыми солнечными панелями по левому борту", "носовых солнечных панелях по левому борту")
	icon_state = "northwest"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/vox/northeast_solars
	name = "Fore starboard solars"
	cases = list("носовые солнечные панели по правому борту", "носовых солнечных панелей по правому борту", "носовым солнечным панелям по правому борту", "носовые солнечные панели по правому борту", "носовыми солнечными панелями по правому борту", "носовых солнечных панелях по правому борту")
	icon_state = "northeast"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/vox/southeast_solars
	name = "Aft starboard solars"
	cases = list("кормовые солнечные панели по правому борту", "кормовых солнечных панелей по правому борту", "кормовым солнечным панелям по правому борту", "кормовые солнечные панели по правому борту", "кормовыми солнечными панелями по правому борту", "кормовых солнечных панелях по правому борту")
	icon_state = "southeast"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/vox/mining
	name = "Nearby mining asteroid"
	cases = list("вблизи шахтёрского астероида", "вблизи шахтёрского астероида", "вблизи шахтёрского астероида", "вблизи шахтёрского астероида", "вблизи шахтёрского астероида", "вблизи шахтёрского астероида")
	icon_state = "north"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Syndicate Shuttle
/area/shuttle/syndicate
	name = "Syndicate Station"
	cases = list("станция Синдиката", "станции Синдиката", "станции Синдиката", "станцию Синдиката", "станцией Синдиката", "станции Синдиката")
	icon_state = "yellow"
	ambience = 'sound/ambience/syndicate_station.ogg'

/area/shuttle/syndicate/start
	name = "Syndicate Forward Operating Base"
	cases = list("передовая оперативная база Синдиката", "передовой оперативной базы Синдиката", "передовой оперативной базе Синдиката", "передовую оперативную базу Синдиката", "передовой оперативной базой Синдиката", "передовой оперативной базе Синдиката")
	icon_state = "yellow"

/area/shuttle/syndicate/southwest
	name = "south-west of station"
	cases = list("юго-запад от станции", "юго-запада от станции", "юго-западу от станции", "юго-запад от станции", "юго-западом от станции", "юго-западе от станции")
	icon_state = "southwest"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/northwest
	name = "north-west of station"
	cases = list("северо-запад от станции", "северо-запада от станции", "северо-западу от станции", "северо-запад от станции", "северо-западом от станции", "северо-западе от станции")
	icon_state = "northwest"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/northeast
	name = "north-east of station"
	cases = list("северо-восток от станции", "северо-востока от станции", "северо-востоку от станции", "северо-восток от станции", "северо-востоком от станции", "северо-востоке от станции")
	icon_state = "northeast"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/southeast
	name = "south-east of station"
	cases = list("юго-восток от станции", "юго-востока от станции", "юго-востоку от станции", "юго-восток от станции", "юго-востоком от станции", "юго-востоке от станции")
	icon_state = "southeast"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/north
	name = "north of station"
	cases = list("север станции", "севера станции", "северу станции", "север станции", "севером станции", "севере станции")
	icon_state = "north"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/south
	name = "south of station"
	cases = list("юг станции", "юга станции", "югу станции", "юг станции", "югом станции", "юге станции")
	icon_state = "south"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/mining
	name = "north east of the mining asteroid"
	cases = list("северо-восток от шахтерского астероида", "северо-востока от шахтерского астероида", "северо-востоку от шахтерского астероида", "северо-восток от шахтерского астероида", "северо-востоком от шахтерского астероида", "северо-востоке от шахтерского астероида")
	icon_state = "north"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/transit
	name = "hyperspace"
	cases = list("гиперпространство", "гиперпространства", "гиперпространству", "гиперпространство", "гиперпространством", "гиперпространстве")
	icon_state = "shuttle"
	parallax_movedir = NORTH

//Shuttle lists, group by areas
// CENTCOM
var/global/list/centcom_shuttle_areas = list (
	/area/shuttle/escape/centcom,
	/area/shuttle/escape_pod1/centcom,
	/area/shuttle/escape_pod2/centcom,
	/area/shuttle/escape_pod3/centcom,
	/area/shuttle/escape_pod4/centcom,
	/area/shuttle/transport1/centcom,
	/area/shuttle/administration/centcom,
	/area/shuttle/specops/centcom,
	/area/shuttle/officer/centcom
)

// DOCKED TO STATION
var/global/list/station_shuttle_areas = list (
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod4/station,
	/area/shuttle/transport1/station,
	/area/shuttle/administration/station,
	/area/shuttle/specops/station,
	/area/shuttle/officer/station,
	/area/shuttle/supply/station,
	/area/shuttle/arrival/station,
	/area/shuttle/mining/station
)
