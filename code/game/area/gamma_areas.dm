 ///////////
 ///GAMMA///
 ///////////

// Respectful request when adding new zones, add RU cases. Since zones are starting to be actively used in translation.

/area/station/engineering/monitoring
	name = "Engineering Monitoring Room"
	cases = list("комната наблюдения инженерного отдела", "комнаты наблюдения инженерного отдела", "комнате наблюдения инженерного отдела", "комнату наблюдения инженерного отдела", "комнатой наблюдения инженерного отдела", "комнате наблюдения инженерного отдела")

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
	cases = list("дормиторий №1", "дормитория №1", "дормиторию №1", "дормиторий №1", "дормиторием №1", "дормитории №1")

/area/station/civilian/dormitories/dormtwo
	name = "Second Dorm Room"
	cases = list("дормиторий №2", "дормитория №2", "дормиторию №2", "дормиторий №2", "дормиторием №2", "дормитории №2")

/area/station/civilian/dormitories/dormthree
	name = "Third Dorm Room"
	cases = list("дормиторий №3", "дормитория №3", "дормиторию №3", "дормиторий №3", "дормиторием №3", "дормитории №3")

/area/station/civilian/dormitories/dormfour
	name = "Fourth Dorm Room"
	cases = list("дормиторий №4", "дормитория №4", "дормиторию №4", "дормиторий №4", "дормиторием №4", "дормитории №4")

/area/station/civilian/dormitories/dormfive
	name = "Fifth Dorm Room"
	cases = list("дормиторий №5", "дормитория №5", "дормиторию №5", "дормиторий №5", "дормиторием №5", "дормитории №5")

/area/station/civilian/dormitories/theater
	name = "Theater"
	cases = list("театр", "театра", "театру", "театр", "театром", "театре")
	icon_state = "bar"

/area/station/security/secconfhall
	name = "Security Conference Hall"
	cases = list("конференц-зал службы безопасности", "конференц-зала службы безопасности", "конференц-залу службы безопасности", "конференц-зал службы безопасности", "конференц-залом службы безопасности", "конференц-зале службы безопасности")
	icon_state = "security"

/area/station/rnd/sppodconstr
	name = "Space Pod Construction Site"
	cases = list("строй. площадка космических подов", "строй. площадки космических подов", "строй. площадке космических подов", "строй. площадка космических подов", "строй. площадкой космических подов", "строй. площадке космических подов")
	icon_state = "mechbay"
	power_equip = 0
	power_light = 0
	power_environ = 0

/area/station/medical/hallway/outbranch
	icon_state = "medbay3"

/area/station/medical/surgery3
	name = "Operating Theatre 3"
	cases = list("операционная №3", "операционной №3", "операционной №3", "операционная №3", "операционной №3", "операционной №3")
	icon_state = "surgery"
	ambience = list('sound/ambience/surgery_1.ogg', 'sound/ambience/surgery_2.ogg')

/area/station/medical/surgerystorage
	name = "Operating Storage"
	cases = list("склад операционных", "склада операционных", "складу операционных", "склад операционных", "складом операционных", "складе операционных")
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
	cases = list("дормиторий брига", "дормитория брига", "дормиторию брига", "дормиторий брига", "дормиторием брига", "дормитории брига")
	icon_state = "brig"

/area/station/security/seclunch
	name = "Security Lunch Room"
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
