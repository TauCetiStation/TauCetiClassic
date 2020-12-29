/obj/singularity/narsie //Moving narsie to a child object of the singularity so it can be made to function differently. --NEO
	name = "Nar-sie's Avatar"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	pixel_x = -46
	pixel_y = -43
	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO
	contained = 0 //Are we going to move around?
	dissipate = 0 //Do we lose energy over time?
	move_self = 1 //Do we move on our own?
	grav_pull = 5 //How many tiles out do we pull?
	consume_range = 6 //How many tiles out do we eat

/proc/notify_ghosts(message, ghost_sound = null) //Easy notification of ghosts.
	for(var/mob/dead/observer/O in player_list)
		if(O.client)
			to_chat(O, "<span class='ghostalert'>[message]</span>")
			if(ghost_sound)
				O.playsound_local(null, ghost_sound, VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)

/obj/singularity/narsie/large
	name = "Nar-Sie"
	icon = 'icons/obj/narsie.dmi'
	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256
	light_range = 1
	light_color = "#3e0000"
	current_size = 12
	move_self = 1 //Do we move on our own?
	grav_pull = 10
	consume_range = 12 //How many tiles out do we eat

/obj/singularity/narsie/large/atom_init()
	. = ..()
	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			to_chat(M, "<font size='15' color='red'><b>НАР-СИ ВОССТАЛ</b></font>")
			M.playsound_local(null, pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg'), VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, ignore_environment = TRUE)

	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Нар-си восстал в [A.name]. По всей станции скоро появятся его порталы, нажмите на него, чтобы получить свою оболочку.")
	narsie_spawn_animation()
	invisibility = 60

	// Force event
	var/datum/event_container/portals_event = new /datum/event_container/major
	for(var/datum/event_meta/E in portals_event.available_events)
		if(ispath(E.event_type, /datum/event/anomaly/cult_portal/massive))
			log_debug("Force starting event '[E.name]' of severity [severity_to_string[E.severity]].")
			new E.event_type(E)

	addtimer(CALLBACK(SSshuttle, /datum/controller/subsystem/shuttle.proc/incall, 0.5), 70)

/obj/singularity/narsie/process()
	eat()
	if(!target || prob(5))
		pickcultist()
	move()
	if(prob(25))
		mezzer()


/obj/singularity/narsie/Bump()
	return

/obj/singularity/narsie/Bumped()
	return

/obj/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(!iscultist(M))
				to_chat(M, "<span class='warning'>You feel your sanity crumble away in an instant as you gaze upon [src.name]...</span>")
				M.apply_effect(3, STUN)


/obj/singularity/narsie/consume(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(iscultist(L))
			return
		L.gib()
		return

	var/mob/living/C = locate(/mob/living) in A
	if(istype(C))
		if(iscultist(C))
			return
		C.loc = get_turf(C)
		C.gib()
		return

	if(isturf(A))
		var/turf/T = A
		if(istype(T, /turf/simulated/floor/engine/cult))
			return
		if(istype(T, /turf/simulated/floor/engine/cult/lava))
			return
		if(istype(T, /turf/simulated/wall/cult))
			return
		if(istype(T, /obj/structure/object_wall))
			return
		if(istype(T, /turf/simulated/floor))
			if(prob(50))
				T.ChangeTurf(pick(/turf/simulated/floor/engine/cult, /turf/simulated/floor/engine/cult/lava))
			if(prob(5))
				var/obj = pick(/obj/effect/spacewhole, /obj/effect/timewhole, /obj/effect/orb, /obj/structure/cult/shell)
				new obj(T)
		if(istype(T, /turf/simulated/wall))
			if(prob(20))
				T.ChangeTurf(pick(/turf/simulated/wall/cult, /turf/simulated/wall/cult/runed, /turf/simulated/wall/cult/runed/anim))
	return

/obj/singularity/narsie/move()
	if(!move_self)
		return 0

	var/movement_dir = pick(alldirs - last_failed_movement)

	if(target)
		movement_dir = get_dir(src,target) //moves to a singulo beacon, if there is one

	spawn(0)
		loc = get_step(src, movement_dir)
	spawn(1)
		loc = get_step(src, movement_dir)
	return 1

/obj/singularity/narsie/ex_act() //No throwing bombs at it either. --NEO
	return


/obj/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	if(!alive_mob_list.len)
		return
	var/list/cultists = list()
	var/list/noncultists = list()
	for(var/mob/living/carbon/food in alive_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if(!pos)
			break
		if(pos.z != src.z)
			continue
		if(istype(food, /mob/living/carbon/brain))
			continue

		if(iscultist(food))
			cultists += food
		else
			noncultists += food

		if(cultists.len) //cultists get higher priority
			acquire(pick(cultists))
			return

		if(noncultists.len)
			acquire(pick(noncultists))
			return

	//no living humans, follow a ghost instead.
	for(var/mob/dead/observer/ghost in observer_list)
		if(!ghost.client)
			continue
		var/turf/pos = get_turf(ghost)
		if(pos.z != src.z)
			continue
		cultists += ghost
	if(cultists.len)
		acquire(pick(cultists))
		return


/obj/singularity/narsie/proc/acquire(mob/food)
	to_chat(target, "<span class='notice'>NAR-SIE HAS LOST INTEREST IN YOU</span>")
	target = food
	if(ishuman(target))
		to_chat(target, "<span class ='userdanger'>NAR-SIE HUNGERS FOR YOUR SOUL</span>")
	else
		to_chat(target, "<span class ='userdanger'>NAR-SIE HAS CHOSEN YOU TO LEAD HIM TO HIS NEXT MEAL</span>")


/obj/singularity/narsie/proc/narsie_spawn_animation()
	icon = 'icons/effects/narsie_spawn_anim.dmi'
	dir = SOUTH
	move_self = 0
	flick("narsie_spawn_anim",src)
	sleep(11)
	move_self = 1
	icon = initial(icon)

//Wizard narsie
/obj/singularity/narsie/wizard
	grav_pull = 0

/obj/singularity/narsie/wizard/eat()
	for(var/atom/A in orange(consume_range,src))
		if(isturf(A) || istype(A, /atom/movable))
			consume(A)
	return
