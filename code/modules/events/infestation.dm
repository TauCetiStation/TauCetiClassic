#define INFESTATION_LOCATIONS list( \
	"the kitchen"           = /area/station/civilian/kitchen, \
	"atmospherics"          = /area/station/engineering/atmos, \
	"the incinerator"       = /area/station/maintenance/incinerator, \
	"the chapel"            = /area/station/civilian/chapel, \
	"the library"           = /area/station/civilian/library, \
	"hydroponics"           = /area/station/civilian/hydroponics, \
	"the vault"             = /area/station/bridge/nuke_storage, \
	"the construction area" = /area/station/construction, \
	"technical storage"     = /area/station/storage/tech \
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
			vermstring = "mice"
		if(VERM_LIZARDS)
			spawn_types = list(/mob/living/simple_animal/lizard)
			max_number = 6
			vermstring = "lizards"
		if(VERM_SPIDERS)
			spawn_types = list(/mob/living/simple_animal/friendly/spiderling)
			max_number = 3
			vermstring = "spiders"

	spawn(0)
		var/num = rand(2,max_number)
		while(turfs.len > 0 && num > 0)
			var/turf/simulated/floor/T = pick(turfs)
			turfs.Remove(T)
			num--

			if(vermin == VERM_SPIDERS)
				var/mob/living/simple_animal/friendly/spiderling/S = new(T)
				S.amount_grown = -1
			else
				var/spawn_type = pick(spawn_types)
				new spawn_type(T)

/mob/living/simple_animal/friendly/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon = 'icons/effects/effects.dmi'
	icon_dead = "greenshatter"
	icon_state = "spiderling"
	ventcrawler = 2
	faction = "spiders" //another spiders will ignore spiderlings
	pass_flags = PASSTABLE | PASSMOB
	anchored = FALSE
	small = TRUE
	layer = BELOW_CONTAINERS_LAYER
	health = 2
	maxHealth = 2
	turns_per_move = 3
	speed = 5
	melee_damage = 1
	turns_per_move = 8
	see_in_dark = 6
	density = FALSE

	var/amount_grown = -1
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	min_oxy = 2 //spider requires atleast 1kPA oxygen to live
	minbodytemp = 223		//no life below -50 Degrees Celcius
	maxbodytemp = 323	//no life above 50 Degrees Celcius

/mob/living/simple_animal/friendly/spiderling/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	//50% chance to grow up
	if(prob(50))
		amount_grown = 1

/mob/living/simple_animal/friendly/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		loc = user.loc
	else
		..()

/mob/living/simple_animal/friendly/spiderling/proc/die()
	visible_message("<span class='alert'>[src] dies!</span>")
	qdel(src)
	if(health <= 0)
		die()

/mob/living/simple_animal/friendly/spiderling/Life()
	if(travelling_in_vent)
		if(istype(src.loc, /turf))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			var/datum/pipeline/entry_vent_parent = entry_vent.PARENT1
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
			/*if(prob(50))
				visible_message("<B>[src] scrambles into the ventillation ducts!</B>")*/

			spawn(rand(20,60))
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)

					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return

					if(prob(50))
						visible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>",2)
					sleep(travel_time)

					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return
					loc = exit_vent.loc
					entry_vent = null
					var/area/new_area = get_area(loc)
					if(new_area)
						new_area.Entered(src)
	//=================

	else if(prob(25))
		var/list/nearby = oview(5, src)
		if(nearby.len)
			var/target_atom = pick(nearby)
			walk_to(src, target_atom, 5)
			if(prob(25))
				visible_message("<span class='notice'>\the [src] skitters[pick(" away"," around","")].</span>")
	else if(prob(5))
		//ventcrawl!
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				walk_to(src, entry_vent, 5)
				break

	if(prob(1))
		visible_message("<span class='notice'>\the [src] chitters.</span>")
	if(isturf(loc) && amount_grown > 0)
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			var/spawn_type = pick(typesof(/mob/living/simple_animal/hostile/giant_spider))
			new spawn_type(src.loc)
			qdel(src)
	if(health <= 0) 
		var/spawn_type = /obj/effect/decal/cleanable/spiderling_remains //changing body of animal to cleanable object
		new spawn_type(src.loc)
		qdel(src)

#undef INFESTATION_LOCATIONS

#undef VERM_MICE
#undef VERM_LIZARDS
#undef VERM_SPIDERS
