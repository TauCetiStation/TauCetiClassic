// illusion of nar-sie
/atom/movable/narsie
	name = "Nar-sie's Avatar"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	pixel_x = -46
	pixel_y = -43
	plane = SINGULARITY_PLANE
	layer = SINGULARITY_LAYER
	density = TRUE

/obj/singularity/narsie
	name = "Nar-Sie"
	icon = 'icons/obj/narsie.dmi'
	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256
	light_range = 1
	light_color = "#3e0000"
	current_size = 12
	move_self = TRUE //Do we move on our own?
	grav_pull = 10
	consume_range = 12 //How many tiles out do we eat
	contained = 0 //Are we going to move around?
	dissipate = 0 //Do we lose energy over time?

	var/datum/religion/my_religion

/obj/singularity/narsie/atom_init(mapload, datum/religion/religion = global.cult_religion)
	. = ..()
	my_religion = religion
	INVOKE_ASYNC(src, PROC_REF(begin_the_end))

	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			to_chat(M, "<font size='15' color='red'><b>Н́̿̚Ӓ́̈́Р̔̚͘-̽̔͆С̈́͛͛И̓͊̕ В͒̚͝О̓͒̓С̓̾͑С̔̓͝Т̈́͘̚А͒͑͘Л͐͌̾</b></font>")
			M.playsound_local(null, pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg'), VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)
			if(!iscultist(M))
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "narsie", /datum/mood_event/narsie)
			else
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "narsie", /datum/mood_event/narsie_cultists)

	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Нар-Cи восстал в [A.name]. По всей станции скоро появятся его порталы, нажав на которые, вы сможете стать конструктом.", source = src, action = NOTIFY_ORBIT, header = "Nar'Sie")

	playsound_frequency_admin = -1

/obj/singularity/narsie/Destroy()
	for(var/mob/M in player_list)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "narsie")
	return ..()

/obj/singularity/narsie/proc/begin_the_end()
	narsie_spawn_animation()

	// Force event
	new /datum/event/anomaly/cult_portal/massive(new /datum/event_meta(EVENT_LEVEL_MAJOR, "Massive Cult Portals"))
	log_debug("Force starting event for nar-sie 'Massive Cult Portals'.")

	addtimer(CALLBACK(SSshuttle, TYPE_PROC_REF(/datum/controller/subsystem/shuttle, incall), 0.3), 70)

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
				to_chat(M, "<span class='warning'>Вы чувствуете, как ваш рассудок мгновенно рассеивается, когда вы посмотрели на [name]...</span>")
				M.apply_effect(3, STUN)

/obj/singularity/narsie/consume(atom/A)
	var/mob/living/C = locate() in A
	if(istype(C))
		if(iscultist(C))
			return
		C.forceMove(get_turf(C))
		C.gib()
		return

	if(isliving(A))
		var/mob/living/L = A
		if(iscultist(L))
			return
		L.gib()
		return

	if(!my_religion)
		return

	var/list/religions_structures = list()
	religions_structures += my_religion.wall_types
	religions_structures += my_religion.floor_types
	religions_structures += my_religion.door_types

	for(var/type in religions_structures)
		if(istype(A, type))
			return

	if(istype(A, /obj/structure/object_wall))
		return

	if(istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/mineral_door))
		new /obj/structure/mineral_door/cult(get_turf(A))
		qdel(A)
		return

	if(isfloorturf(A))
		var/turf/T = A
		if(prob(50))
			T.ChangeTurf(pick(my_religion.floor_types))
		if(prob(5))
			var/obj = pick(subtypesof(/obj/structure/cult/anomaly))
			new obj(T)
		var/area/area = get_area(A)
		area.religion = global.cult_religion
		return
	if(iswallturf(A))
		var/turf/T = A
		if(prob(20))
			T.ChangeTurf(pick(my_religion.wall_types))
		return

/obj/singularity/narsie/move()
	if(!move_self)
		return

	var/movement_dir = pick(alldirs - last_failed_movement)

	if(target)
		movement_dir = get_dir(src,target) //moves to a singulo beacon, if there is one

	forceMove(get_step(src, movement_dir))

/obj/singularity/narsie/ex_act() //No throwing bombs at it either. --NEO
	return

/obj/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	if(!alive_mob_list.len || !player_list.len)
		return
	var/list/noncultists = list()
	for(var/mob/living/food in player_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if(!pos)
			continue
		if(pos.z != z)
			continue

		if(!iscultist(food))
			noncultists += food

		if(noncultists.len) //crew get higher priority
			acquire(pick(noncultists))
			return

	//no living players, follow a clientless instead.
	for(var/mob/mob as anything in alive_mob_list)
		if(mob.faction == "cult")
			continue
		var/turf/pos = get_turf(mob)
		if(!pos)
			continue
		if(pos.z != z)
			continue
		noncultists += mob
	if(noncultists.len)
		acquire(pick(noncultists))
		return

	//no living humans, follow a ghost instead.
	for(var/mob/dead/observer/ghost as anything in observer_list)
		if(!ghost.client)
			continue
		var/turf/pos = get_turf(ghost)
		if(pos.z != z)
			continue
		noncultists += ghost
	if(noncultists.len)
		acquire(pick(noncultists))
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
	move_self = FALSE
	flick("narsie_spawn_anim",src)
	sleep(11)
	move_self = TRUE
	icon = initial(icon)
