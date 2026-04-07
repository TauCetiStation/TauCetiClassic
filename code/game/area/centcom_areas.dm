 ///////////
 //CENTCOM//
 ///////////

// Respectful request when adding new zones, add RU cases. Since zones are starting to be actively used in translation.

//Centcom
/area/centcom
	name = "Centcom"
	cases = list("отделение ЦК", "отделения ЦК", "отделению ЦК", "отделения ЦК", "отделением ЦК", "отделении ЦК")
	icon_state = "centcom"
	requires_power = 0
	dynamic_lighting = TRUE

/area/centcom/control
	name = "Centcom Control"
	cases = list("центр управления ЦК", "центра управления ЦК", "центру управления ЦК", "центра управления ЦК", "центром управления ЦК", "центром управления ЦК")

/area/centcom/evac
	name = "Centcom Emergency Shuttle"
	cases = list("эвакуационный шаттл ЦК", "эвакуационного шаттла ЦК", "эвакуационному шаттлу ЦК", "эвакуационного шаттла ЦК", "эвакуационным шаттлом ЦК", "эвакуационном шаттле ЦК")

/area/centcom/ferry
	name = "Centcom Transport Shuttle"
	cases = list("транспортный шаттл ЦК", "транспортного шаттла ЦК", "транспортному шаттлу ЦК", "транспортного шаттла ЦК", "транспортным шаттлом ЦК", "транспортном шаттле ЦК")

/area/centcom/shuttle
	name = "Centcom Administration Shuttle"
	cases = list("административный шаттл ЦК", "административного шаттла ЦК", "административному шаттлу ЦК", "административного шаттла ЦК", "административным шаттлом ЦК", "административном шаттле ЦК")

/area/centcom/test
	name = "Centcom Testing Facility"
	cases = list("испытательное учреждение ЦК", "испытательного учреждения ЦК", "испытательному учреждению ЦК", "испытательное учреждение ЦК", "испытательным учреждением ЦК", "испытательном учреждении ЦК")

/area/centcom/living
	name = "Centcom Living Quarters"
	cases = list("жилые апартаменты ЦК", "жилых апартаментов ЦК", "жилым апартаментам ЦК", "жилые апартаменты ЦК", "жилыми апартаментами ЦК", "жилых апартаментах ЦК")

/area/centcom/specops
	name = "Centcom Special Ops"
	cases = list("штаб спец.сил ЦК", "штаба спец.сил ЦК", "штабу спец.сил ЦК", "штаб спец.сил ЦК", "штабом спец.сил ЦК", "штабе спец.сил ЦК")

/area/centcom/holding
	name = "Centcom Checkpoint"
	cases = list("КПП ЦК", "КПП ЦК", "КПП ЦК", "КПП ЦК", "КПП ЦК", "КПП ЦК")

/area/centcom/bar
	name = "Centcom Bar"
	cases = list("бар ЦК", "бара ЦК", "бару ЦК", "бар ЦК", "баром ЦК", "баре ЦК")

/area/centcom/waitingroom
	name = "Centcom Waiting Hall"
	cases = list("зал ожидания ЦК", "зала ожидания ЦК", "залу ожидания ЦК", "зал ожидания ЦК", "залом ожидания ЦК", "зале ожидания ЦК")

//PRISON
/area/centcom/prison
	name = "Solitary Confinement"
	cases = list("тюремное отделение ЦК", "тюремного отделения ЦК", "тюремному отделению ЦК", "тюремное отделение ЦК", "тюремным отделением ЦК", "тюремном отделении ЦК")
	icon_state = "brig"

//Thunderdome
/area/centcom/tdome
	name = "Thunderdome"
	cases = list("тандердом", "тандердома", "тандердому", "тандердом", "тандердомом", "тандердоме")
	icon_state = "thunder"
	requires_power = 0
	dynamic_lighting = TRUE

/area/centcom/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/centcom/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "yellow"

/area/centcom/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/centcom/tdome/tdomeobserve
	name = "Thunderdome (Observer.)"
	icon_state = "purple"

// CENTCOM AREA LIST
var/global/list/centcom_areas_typecache = typecacheof(centcom_shuttle_areas + typesof(/area/centcom))
