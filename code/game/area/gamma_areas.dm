 ///////////
 ///GAMMA///
 ///////////

// Respectful request when adding new zones, add RU cases. Since zones are starting to be actively used in translation.

/area/station/engineering/monitoring
	name = "Engineering Monitoring Room"
	cases = list("диспетчерская инженерного отдела", "диспетчерской инженерного отдела", "диспетчерской инженерного отдела", "диспетчерскую инженерного отдела", "диспетчерской инженерного отдела", "диспетчерской инженерного отдела")

/area/station/engineering/rust
	name = "Tokamak Core"
	icon_state = "engine_smes"
	ambience = list('sound/ambience/engine_1.ogg', 'sound/ambience/engine_2.ogg', 'sound/ambience/engine_3.ogg', 'sound/ambience/engine_4.ogg')

/area/station/engineering/equip
	name = "Engineering Equipment Storage"
	cases = list("склад инженерного отдела", "склада инженерного отдела", "складу инженерного отдела", "склад инженерного отдела", "складом инженерного отдела", "складе инженерного отдела")

/area/station/hallway/primary/bridgehall
	name = "Bridge Primary Hallway"
	icon_state = "hallC"

/area/station/civilian/dormitories/dormone
	name = "First Dorm Room"
	cases = list("каюта №1", "каюты №1", "каюте №1", "каюту №1", "каютой №1", "каюте №1")

/area/station/civilian/dormitories/dormtwo
	name = "Second Dorm Room"
	cases = list("каюта №2", "каюты №2", "каюте №2", "каюту №2", "каютой №2", "каюте №2")

/area/station/civilian/dormitories/dormthree
	name = "Third Dorm Room"
	cases = list("каюта №3", "каюты №3", "каюте №3", "каюту №3", "каютой №3", "каюте №3")

/area/station/civilian/dormitories/dormfour
	name = "Fourth Dorm Room"
	cases = list("каюта №4", "каюты №4", "каюте №4", "каюту №4", "каютой №4", "каюте №4")

/area/station/civilian/dormitories/dormfive
	name = "Fifth Dorm Room"
	cases = list("каюта №5", "каюты №5", "каюте №5", "каюту №5", "каютой №5", "каюте №5")

/area/station/civilian/dormitories/theater
	name = "Theater"
	cases = list("театр", "театра", "театру", "театр", "театром", "театре")
	icon_state = "bar"

/area/station/security/secconfhall
	name = "Security Conference Hall"
	cases = list("комната совещаний отдела службы безопасности", "комнаты совещаний отдела службы безопасности", "комнате совещаний отдела службы безопасности", "комнату совещаний отдела службы безопасности", "комнатой совещаний отдела службы безопасности", "комнате совещаний отдела службы безопасности")
	icon_state = "security"

/area/station/rnd/sppodconstr
	name = "Space Pod Construction Site"
	cases = list("строй. площадка космических подов", "строй. площадки космических подов", "строй. площадке космических подов", "строй. площадку космических подов", "строй. площадкой космических подов", "строй. площадке космических подов")
	icon_state = "mechbay"
	power_equip = 0
	power_light = 0
	power_environ = 0

/area/station/medical/hallway/outbranch
	icon_state = "medbay3"

/area/station/medical/surgery3
	name = "Operating Theatre 3"
	cases = list("операционная №3", "операционной №3", "операционной №3", "операционную №3", "операционной №3", "операционной №3")
	icon_state = "surgery"
	ambience = list('sound/ambience/surgery_1.ogg', 'sound/ambience/surgery_2.ogg')

/area/station/medical/surgerystorage
	name = "Operating Storage"
	cases = list("материальная комната оперблока", "материальной комнаты оперблока", "материальной комнате оперблока", "материальную комнату оперблкоа", "материальной комнатой оперблока", "материальной комнате оперблока")
	icon_state = "surgery2"

/area/station/maintenance/brigright
	name = "Starboard Security Maintenance"
	cases = list("восточные техтоннели брига", "восточных техтоннелей брига", "восточным техтоннелям брига", "восточные техтоннели брига", "восточными техтоннелями брига", "восточных техтоннелях брига")
	icon_state = "fmaint"

/area/station/maintenance/brig
	name = "Port Brig Maintenance"
	cases = list("западные техтоннели брига", "западных техтоннелей брига", "западным техтоннелям брига", "западные техтоннели брига", "западными техтоннелями брига", "западных техтоннелях брига")
	icon_state = "fmaint"

/area/station/maintenance/outerlabs
	name = "REDACTED"
	cases = list("неизвестная локация", "неизвестной локации", "неизвестной локации", "неизвестная локация", "неизвестной локацией", "неизвестной локации")
	icon_state = "fmaint"
	power_equip = 0
	power_light = 0
	power_environ = 0

/area/station/civilian/market
	name = "Marketplace"
	cases = list("рынок", "рынка", "рынку", "рынок", "рынком", "рынке")
	icon_state = "locker"
	power_equip = 0
	power_light = 0
	power_environ = 0

/area/station/security/secdorm
	name = "Security Dormitory"
	cases = list("казарма отдела службы безопасности", "казармы отдела службы безопасности", "казарме отдела службы безопасности", "казарму отдела службы безопасности", "казармой отдела службы безопасности", "казарме отдела службы безопасности")
	icon_state = "brig"

/area/station/security/seclunch
	name = "Security Lunch Room"
	cases = list("комната отдыха отдела службы безопасности", "комнаты отдыха отдела службы безопасности", "комнате отдыха отдела службы безопасности", "комнату отдыха отдела службы безопасности", "комнатой отдыха отдела службы безопасности", "комнате отдыха отдела службы безопасности")
	icon_state = "brig"

/area/station/rnd/hallway/florahall
	name = "Flora Reserach"
	cases = list("ксенобиология", "ксенобиологии", "ксенобиологии", "ксенобиология", "ксенобиологией", "ксенобиологии")
	icon_state = "research"

/area/station/security/tribunal
	name = "Courtroom"
	cases = list("зал суда", "зала суда", "залу суда", "зал суда", "залом суда", "зале суда")
	icon_state = "security"
	ambience = list('sound/ambience/vacant_1.ogg')
