/datum/catastrophe_event/doom
	name = "Doom"

	one_time_event = TRUE

	weight = 100

	event_type = "harmful"
	steps = 3

	var/should_spawn_portals = FALSE
	var/portal_timer
	var/portal_delay

/datum/catastrophe_event/doom/on_step()
	switch(step)
		if(1)
			announce(CYRILLIC_EVENT_DOOM_1)

			addtimer(CALLBACK(src, .proc/spawn_first_portal), 1 MINUTE)
		if(2)
			announce(CYRILLIC_EVENT_DOOM_3)
			portal_delay = 20
			portal_timer = 20
		if(3)
			var/turf/T = find_random_floor(findEventArea())
			if(!T)
				return
			var/area/A = get_area(T)

			announce(CYRILLIC_EVENT_DOOM_4)

			new /obj/effect/cellular_biomass_controller/meat(T)
			message_admins("Meatblob was created in [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")

/datum/catastrophe_event/doom/process_event()
	..()

	if(should_spawn_portals)
		portal_timer -= 1
		if(portal_timer <= 0)
			portal_timer = rand(portal_delay, portal_delay * 1.5)
			if(prob(10))
				portal_timer = portal_timer * 10 // sometimes there are big intervals

			var/obj/effect/doom_portal/P = spawn_portal(findEventArea())
			P.monster_ammount = rand(2, 5)

/datum/catastrophe_event/doom/proc/spawn_first_portal()
	announce(CYRILLIC_EVENT_DOOM_2)

	should_spawn_portals = TRUE
	portal_timer = 100
	portal_delay = 100

	var/obj/effect/doom_portal/P = spawn_portal(/area/rnd/telesci)
	P.cooldown = 60 // first one has a big cooldown

/datum/catastrophe_event/doom/proc/spawn_portal(area/A)
	var/turf/random_turf = find_random_floor(A, check_mob = TRUE)
	var/obj/effect/doom_portal/P = new /obj/effect/doom_portal(random_turf)

	message_admins("Monster portal was created in [random_turf.x],[random_turf.y],[random_turf.z] [ADMIN_JMP(random_turf)]")

	return P

/obj/effect/doom_portal
	name = "portal"
	desc = "Is this good?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "bhole3"
	unacidable = TRUE
	density = FALSE
	anchored = TRUE

	color = "#ff2222"
	light_color = "#ff0000"
	light_power = 1
	light_range = 2

	var/list/monster_types = list(/mob/living/simple_animal/hostile/cellular/meat/creep_standing, /mob/living/simple_animal/hostile/cellular/meat/maniac, /mob/living/simple_animal/hostile/cellular/meat/changeling, /mob/living/simple_animal/hostile/cellular/meat/flesh)

	var/monster_ammount = 10
	var/cooldown = 3

/obj/effect/doom_portal/atom_init()
	. = ..()

	var/matrix/Mx = matrix()
	Mx.Scale(2)
	transform = Mx

	playsound(src, 'sound/effects/phasein.ogg', 50, 1)
	START_PROCESSING(SSobj, src)

/obj/effect/doom_portal/Destroy()
	playsound(src, 'sound/effects/phasein.ogg', 50, 1)
	return ..()

/obj/effect/doom_portal/process()
	if(monster_ammount <= 0)
		qdel(src)

	if(cooldown > 0)
		cooldown -= 1

	if(!cooldown && prob(80))
		monster_ammount -= 1
		var/monster = pick(monster_types)
		new monster(loc)
