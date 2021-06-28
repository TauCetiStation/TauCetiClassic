#define INFESTATION_LOCATIONS list( \
	"кухне"                 = /area/station/civilian/kitchen, \
	"атмосферном"           = /area/station/engineering/atmos, \
	"мусоросжигателье"      = /area/station/maintenance/incinerator, \
	"церкви"                = /area/station/civilian/chapel, \
	"библиотеке"            = /area/station/civilian/library, \
	"гидропонике"           = /area/station/civilian/hydroponics, \
	"бункере"               = /area/station/bridge/nuke_storage, \
	"строительной площадке" = /area/station/construction, \
	"техническом хранилище"	= /area/station/storage/tech \
	)

#define VERM_MICE 0
#define VERM_LIZARDS 1
#define VERM_SPIDERS 2

/datum/event/infestation
	announceWhen = 10
	endWhen = 11
	announcement = new /datum/announcement/centcomm/infestation
	var/location
	var/locstring
	var/vermin
	var/vermstring

/datum/event/infestation/announce()
	announcement.play(vermstring, locstring)

/datum/event/infestation/start()
	locstring = pick(INFESTATION_LOCATIONS)
	location = INFESTATION_LOCATIONS[locstring]

	var/list/turf/simulated/floor/turfs = list()

	for(var/areapath in typesof(location))
		var/area/A = locate(areapath)
		for(var/turf/simulated/floor/F in A.contents)
			var/is_available = TRUE
			for(var/atom/F_A in F)
				if(F_A.density)
					is_available = FALSE
					break
			if(is_available)
				turfs += F

	var/list/spawn_types = list()
	var/max_number
	vermin = rand(0,2)
	switch(vermin)
		if(VERM_MICE)
			spawn_types = list(/mob/living/simple_animal/mouse/gray, /mob/living/simple_animal/mouse/brown, /mob/living/simple_animal/mouse/white)
			max_number = 12
			vermstring = "мыши"
		if(VERM_LIZARDS)
			spawn_types = list(/mob/living/simple_animal/lizard)
			max_number = 6
			vermstring = "ящерицы"
		if(VERM_SPIDERS)
			spawn_types = list(/obj/effect/spider/spiderling)
			max_number = 3
			vermstring = "пауки"

	spawn(0)
		var/num = rand(2,max_number)
		while(turfs.len > 0 && num > 0)
			var/turf/simulated/floor/T = pick(turfs)
			turfs.Remove(T)
			num--

			if(vermin == VERM_SPIDERS)
				var/obj/effect/spider/spiderling/S = new(T)
				S.amount_grown = -1
			else
				var/spawn_type = pick(spawn_types)
				new spawn_type(T)

#undef INFESTATION_LOCATIONS

#undef VERM_MICE
#undef VERM_LIZARDS
#undef VERM_SPIDERS
