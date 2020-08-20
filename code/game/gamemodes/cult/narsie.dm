/obj/singularity/narsie //Moving narsie to a child object of the singularity so it can be made to function differently. --NEO
	name = "Nar-sie's Avatar"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	pixel_x = -89
	pixel_y = -85
	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO
	contained = 0 //Are we going to move around?
	dissipate = 0 //Do we lose energy over time?
	move_self = 1 //Do we move on our own?
	grav_pull = 5 //How many tiles out do we pull?
	consume_range = 6 //How many tiles out do we eat
	//var/uneatable = list(/turf/space, /obj/effect/overlay, /mob/living/simple_animal/construct)


/proc/notify_ghosts(message, ghost_sound = null) //Easy notification of ghosts.
	for(var/mob/dead/observer/O in player_list)
		if(O.client)
			to_chat(O, "<span class='ghostalert'>[message]</span>")
			if(ghost_sound)
				O.playsound_local(null, ghost_sound, VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)

/* Old TG code that didn't work

/obj/effect/effect/sleep_smoke
	name = "smoke"
	icon_state = "smoke"
	opacity = 1
	anchored = 0.0
	mouse_opacity = 0
	var/amount = 6.0
	//Remove this bit to use the old smoke
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	color = "#9c3636"

/obj/effect/effect/sleep_smoke/atom_init()
	. = ..()
	spawn (200+rand(10,30))
		qdel(src)
	return

/obj/effect/effect/sleep_smoke/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	for(var/mob/living/carbon/M in get_turf(src))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
//		if (M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal))  // I'll work on it later
		else
			M.drop_item()
			M:sleeping += 5
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/obj/effect/effect/sleep_smoke/Crossed(mob/living/carbon/M as mob )
	..()
	if(istype(M, /mob/living/carbon))
		if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
//		if (M.wear_suit, /obj/item/clothing/suit/wizrobe && (M.hat, /obj/item/clothing/head/wizard) && (M.shoes, /obj/item/clothing/shoes/sandal)) // Work on it later
			return
		else
			M.drop_item()
			M:sleeping += 5
			if (M.coughedtime != 1)
				M.coughedtime = 1
				M.emote("cough")
				spawn(20)
					if(M && M.loc)
						M.coughedtime = 0
	return

/datum/effect/effect/system/sleep_smoke_spread
	var/total_smoke = 0 // To stop it being spammed and lagging!
	var/direction

/datum/effect/effect/system/sleep_smoke_spread/set_up(n = 5, c = 0, loca, direct)
	if(n > 20)
		n = 20
	number = n
	cardinals = c
	if(istype(loca, /turf))
		location = loca
	else
		location = get_turf(loca)
	if(direct)
		direction = direct


/datum/effect/effect/proc/fadeOut2(atom/A, frames = 16)
	if(A.alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = A.alpha / frames
	for(var/i = 0, i < frames, i++)
		A.alpha -= step
		sleep(world.tick_lag)
	return

/datum/effect/effect/system/sleep_smoke_spread/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		if(src.total_smoke > 20)
			return
		spawn(0)
			if(holder)
				src.location = get_turf(holder)
			var/obj/effect/effect/sleep_smoke/smoke = new /obj/effect/effect/sleep_smoke(src.location)
			src.total_smoke++
			var/direction = src.direction
			if(!direction)
				if(src.cardinals)
					direction = pick(cardinal)
				else
					direction = pick(alldirs)
			for(i=0, i<pick(0,1,1,1,2,2,2,3), i++)
				sleep(10)
				step(smoke,direction)
			spawn(150+rand(10,30))
				if(smoke)
					fadeOut2(smoke)
					qdel(smoke)
				src.total_smoke--

//////////////////////END?////////////////////////////////////////////

*/

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
	to_chat(world, "<font size='15' color='red'><b>NAR-SIE HAS RISEN</b></font>")
	world << pick(sound('sound/hallucinations/im_here1.ogg'), sound('sound/hallucinations/im_here2.ogg'))

	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Nar-Sie has risen in \the [A.name]. Reach out to the Geometer to be given a new shell for your soul.")
	narsie_spawn_animation()
	invisibility = 60

	addtimer(CALLBACK(SSshuttle, /datum/controller/subsystem/shuttle.proc/incall, 0.5), 70)

/obj/singularity/narsie/large/attack_ghost(mob/living/user)
	if(!(src in view()))
		to_chat(user, "Your soul is too far away.")
		return
	new /obj/effect/effect/smoke(user.loc)
	var/mob/living/simple_animal/construct/harvester/G = new /mob/living/simple_animal/construct/harvester(user.loc)
	G.real_name = pick("harvester([rand(1, 10)])", "reaper([rand(1, 10)])")
	G.loc = src.loc
	G.key = user.key
	to_chat(G, "<span class='warning'>You are a Harvester. You are not strong, but your powers of domination will assist you in your role: \
		Bring those who still cling to this world of illusion back to the Geometer so they may know Truth</span>")


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
	//if(is_type_in_list(A, uneatable))
	//	return 0
	if(istype(A, /mob/living))
		var/mob/living/L = A
		if(istype(L, /mob/living/simple_animal/construct))
			return
		L.gib()
		return

	var/mob/living/C = locate(/mob/living) in A
	if(istype(C))
		if(istype(C, /mob/living/simple_animal/construct))
			return
		C.loc = get_turf(C)
		C.gib()
		return

	if(isturf(A))
		var/turf/T = A
		if(istype(T, /turf/simulated/floor/engine/cult))
			return
		if(istype(T, /turf/simulated/wall/cult))
			return
		if(istype(T, /obj/structure/object_wall))
			return
		if(istype(T, /turf/simulated/floor))
			if(prob(20))
				T.ChangeTurf(/turf/simulated/floor/engine/cult)
		if(istype(T, /turf/simulated/wall))
			if(prob(20))
				T.ChangeTurf(/turf/simulated/wall/cult)
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
	var/list/cultists = list()
	var/list/noncultists = list()
	for(var/mob/living/carbon/food in alive_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if(pos.z != src.z)
			continue
		if(istype(food, /mob/living/carbon/brain)) continue

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
