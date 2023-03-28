#define INFESTATION_LOCATIONS list( \
	"кухня"                 = /area/station/civilian/kitchen, \
	"атмосферный отдел"     = /area/station/engineering/atmos, \
	"мусоросжигатель"       = /area/station/maintenance/incinerator, \
	"церковь"               = /area/station/civilian/chapel, \
	"библиотека"            = /area/station/civilian/library, \
	"гидропоника"           = /area/station/civilian/hydroponics, \
	"центральное хранилище" = /area/station/bridge/nuke_storage, \
	"строительная площадка" = /area/station/construction, \
	"техническое хранилище"	= /area/station/storage/tech \
	)

/datum/event/infestation
	announceWhen = 10
	endWhen = 11
	announcement = new /datum/announcement/centcomm/infestation
	var/location
	var/locstring
	var/vermstring = "клоунов"

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
	var/turf/simulated/floor/T = pick(turfs)
	new/obj/effect/tear/honk(T)
	var/num = 12
	while(turfs.len > 0 && num > 0)
		num--
		new /mob/living/simple_animal/hostile/retaliate/clown/goblin(T)

#undef INFESTATION_LOCATIONS

/mob/living/simple_animal/hostile/retaliate/clown/goblin
	name = "clown goblin"
	desc = "A tiny walking mask and clown shoes. You want to honk his nose!"
	icon_state = "cluwnegoblin"
	icon_living = "cluwnegoblin"
	icon_dead = null
	response_help = "honks the"
	speak = list("Honk!")
	speak_emote = list("sqeaks")
	emote_see = list("honks")
	maxHealth = 100
	health = 100
	speed = -1
	turns_per_move = 1

/mob/living/simple_animal/hostile/retaliate/clown/goblin/Move()
	..()
	if(stance != HOSTILE_STANCE_ATTACK)
		return
	for(var/obj/O in get_step(src, dir))
		if(!O.Adjacent(src))
			continue
		O.attack_animal(src)
		if(istype(O, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/A = O
			A.open(TRUE)


/mob/living/simple_animal/hostile/retaliate/clown/goblin/death()
	..()
	new/obj/item/clothing/mask/gas/clown_hat(loc)
	new/obj/item/clothing/shoes/clown_shoes(loc)
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/clown/goblin/bullet_act(obj/item/projectile/P, def_zone)
	Retaliate()
	return ..()

/obj/effect/tear/honk
	name="Honkmensional Tear"
	desc="A tear in the dimensional fabric of sanity."
	icon='icons/effects/tear.dmi'
	icon_state="newtear"

/obj/effect/tear/honk/New()
	pixel_x = -86
	pixel_y = -64
	VARSET_IN(src, icon_state, "tear", 2 SECONDS)
	QDEL_IN(src, 15 SECONDS)
