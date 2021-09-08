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
	plane = ABOVE_LIGHTING_LAYER

/atom/proc/notify_ghosts(message, ghost_sound = null) //Easy notification of ghosts.
	for(var/mob/M in observer_list)
		if(!M.client)
			continue
		var/turf/T = get_turf(src)
		to_chat(M, "<span class='ghostalert'>[FOLLOW_OR_TURF_LINK(M, src, T)] [message]</span>")
		if(ghost_sound)
			M.playsound_local(null, ghost_sound, VOL_NOTIFICATIONS, vary = FALSE, frequency = null, ignore_environment = TRUE)

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
			to_chat(M, "<font size='15' color='red'><b>Н́̿̚Ӓ́̈́Р̔̚͘-̽̔͆С̈́͛͛И̓͊̕ В͒̚͝О̓͒̓С̓̾͑С̔̓͝Т̈́͘̚А͒͑͘Л͐͌̾</b></font>")
			M.playsound_local(null, pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg'), VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)

	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Нар-Cи восстал в [A.name]. По всей станции скоро появятся его порталы, нажав на которые, вы сможете стать конструктом.")
	INVOKE_ASYNC(src, .proc/begin_the_end)

/obj/singularity/narsie/large/proc/begin_the_end()
	narsie_spawn_animation()

	// Force event
	new /datum/event/anomaly/cult_portal/massive(new /datum/event_meta(EVENT_LEVEL_MAJOR, "Massive Cult Portals"))
	log_debug("Force starting event for nar-sie 'Massive Cult Portals'.")

	addtimer(CALLBACK(SSshuttle, /datum/controller/subsystem/shuttle.proc/incall, 0.3), 70)

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
				to_chat(M, "<span class='warning'>Вы чувствуете, как ваш рассудок мгновенно рассеивается, когда вы посмотрели на [src.name]...</span>")
				M.apply_effect(3, STUN)


/obj/singularity/narsie/consume(atom/A)
	var/mob/living/C = locate(/mob/living) in A
	if(istype(C))
		if(iscultist(C))
			return
		C.loc = get_turf(C)
		C.gib()
		return

	else if(isliving(A))
		var/mob/living/L = A
		if(iscultist(L))
			return
		L.gib()
		return

	else if(istype(A, /obj/structure/mineral_door/cult))
		return

	else if(istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/mineral_door))
		new /obj/structure/mineral_door/cult(get_turf(A))
		qdel(A)
		return

	else if(isturf(A))
		var/turf/T = A
		if(istype(T, /turf/simulated/floor/engine/cult))
			return
		else if(istype(T, /turf/simulated/floor/engine/cult/lava))
			return
		else if(istype(T, /turf/simulated/wall/cult))
			return
		else if(istype(T, /obj/structure/object_wall))
			return
		else if(istype(T, /turf/simulated/floor))
			if(prob(50))
				T.ChangeTurf(pick(/turf/simulated/floor/engine/cult, /turf/simulated/floor/engine/cult/lava))
			if(prob(5))
				var/obj = pick(/obj/structure/cult/anomaly/spacewhole, /obj/structure/cult/anomaly/timewhole, /obj/structure/cult/anomaly/orb, /obj/structure/cult/anomaly/shell)
				new obj(T)
			var/area/area = get_area(A)
			area.religion = global.cult_religion
		else if(istype(T, /turf/simulated/wall))
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
	to_chat(target, "<span class='userdanger'>Т͆̐͠Ы͛̚͝ М̀̿̿Н͛͊̀Е͊̈́͑ Б͑͌͛О͒̕̚Л̐̓͝Ь̀͑̿Ш͑͆̈́Е̾̓͘ Н̈́̿Е̾͆̾ И͑͐͝Н̈́͌̿Е̓͆͘Т͌̚͠Е͋͛͆Р̐̾̒Е͊͑̓С͋͠͠Е͋̈́͊Н̿͒̈́</span>")
	target = food
	if(ishuman(target))
		to_chat(target, "<span class ='userdanger'>М̿̾̈́Н͆̀͒Е̒͑͆ Н̽͒͝У̔̈́̚Ж̿͛͝Н̔̓Ӓ́͋̐ Т̐͌̔В͒́О̒͐͝Я͋͌͋ Д͊̓͠У̒̒̕Ш̈́̀͌А͊̽</span>")
	else
		to_chat(target, "<span class ='userdanger'>Т̓̓̐Ы̒͛̕ М̐̈́Е͐͛Н́̀Я̀͑̽ П͐̐Р̐̀̓И͝͝В͐͘͠Е͛̐̕Д́̈́͝Е͊̓͝Ш̈́͝͠Ь͋̒̚ К̐̾ С̔̾̀Л̈́͊Е̽̒͝Д̈́͊̕У̿̚͝Ю͆̒͘Щ̈́̈́͝Е̔̈́̐Й̾̓̈́ Ж̽̿̾Е͐̀̽Р͒͐̚Т̈́̐͌В̿̕͠Е̽̐̿</span>")


/obj/singularity/narsie/proc/narsie_spawn_animation()
	icon = 'icons/effects/narsie_spawn_anim.dmi'
	set_dir(SOUTH)
	move_self = 0
	flick("narsie_spawn_anim",src)
	sleep(11)
	move_self = 1
	icon = initial(icon)
