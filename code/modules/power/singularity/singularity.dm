/obj/singularity
	name = "gravitational singularity"
	desc = "A gravitational singularity."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"
	anchored = 1
	density = 1
	layer = SINGULARITY_LAYER
	appearance_flags = 0
	//light_range = 6
	unacidable = 1 //Don't comment this out.
	var/current_size = 1
	var/allowed_size = 1
	var/contained = 1 //Are we going to move around?
	var/energy = 100 //How strong are we?
	var/dissipate = 1 //Do we lose energy over time?
	var/dissipate_delay = 10
	var/dissipate_track = 0
	var/dissipate_strength = 1 //How much energy do we lose?
	var/move_self = 1 //Do we move on our own?
	var/grav_pull = 4 //How many tiles out do we pull?
	var/consume_range = 0 //How many tiles out do we eat
	var/event_chance = 15 //Prob for event each tick
	var/target = null //its target. moves towards the target if it has one
	var/last_failed_movement = 0//Will not move in the same dir if it couldnt before, will help with the getting stuck on fields thing
	var/last_warning

/obj/singularity/atom_init(mapload, starting_energy = 50, temp = 0)
	//CARN: admin-alert for chuckle-fuckery.
	admin_investigate_setup()

	energy = starting_energy
	if(temp)
		QDEL_IN(src, temp)
	..()
	START_PROCESSING(SSobj, src)
	poi_list += src
	return INITIALIZE_HINT_LATELOAD

/obj/singularity/atom_init_late()
	for(var/obj/machinery/singularity_beacon/singubeacon in machines)
		if(singubeacon.active)
			target = singubeacon
			break

/obj/singularity/Destroy()
	STOP_PROCESSING(SSobj, src)
	poi_list -= src
	return ..()

/obj/singularity/attack_hand(mob/user)
	consume(user)
	return 1

/obj/singularity/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if(current_size >= STAGE_FIVE || check_turfs_in(Dir))
		last_failed_movement = 0//Reset this because we moved
		return ..()
	else
		last_failed_movement = Dir
		return FALSE

/obj/singularity/blob_act(severity)
	return

/obj/singularity/ex_act(severity)
	switch(severity)
		if(1.0)
			if(current_size <= 3)
				log_investigate("has been destroyed by a heavy explosion.",INVESTIGATE_SINGULO)
				qdel(src)
				return
			else
				energy -= round(((energy+1)/2),1)
		if(2.0)
			energy -= round(((energy+1)/3),1)
		if(3.0)
			energy -= round(((energy+1)/4),1)
	return

/obj/singularity/Bump(atom/A)
	consume(A)
	return

/obj/singularity/Bumped(atom/A)
	consume(A)
	return

/obj/singularity/process()
	if(current_size >= STAGE_TWO)
		move()
		pulse()
		if(prob(event_chance))//Chance for it to run a special event TODO:Come up with one or two more that fit
			event()

	eat()
	dissipate()
	check_energy()

	return

/obj/singularity/attack_ai() //to prevent ais from gibbing themselves when they click on one.
	return

/obj/singularity/proc/admin_investigate_setup()
	last_warning = world.time
	var/count = locate(/obj/machinery/containment_field) in orange(30, src)
	if(!count)
		message_admins("A singulo has been created without containment fields active ([x],[y],[z]) [ADMIN_JMP(src)]")
	log_investigate("was created. [count?"":"<font color='red'>No containment fields were active</font>"]",INVESTIGATE_SINGULO)

/obj/singularity/proc/dissipate()
	if(!dissipate)
		return
	if(dissipate_track >= dissipate_delay)
		src.energy -= dissipate_strength
		dissipate_track = 0
	else
		dissipate_track++

/obj/singularity/proc/expand(force_size = 0)
	var/temp_allowed_size = src.allowed_size
	if(force_size)
		temp_allowed_size = force_size
	switch(temp_allowed_size)
		if(STAGE_ONE)
			current_size = STAGE_ONE
			icon = 'icons/obj/singularity.dmi'
			icon_state = "singularity_s1"
			pixel_x = 0
			pixel_y = 0
			grav_pull = 4
			consume_range = 0
			dissipate_delay = 10
			dissipate_track = 0
			dissipate_strength = 1
		if(STAGE_TWO)//1 to 3 does not check for the turfs if you put the gens right next to a 1x1 then its going to eat them
			current_size = STAGE_TWO
			icon = 'icons/effects/96x96.dmi'
			icon_state = "singularity_s3"
			pixel_x = -32
			pixel_y = -32
			grav_pull = 6
			consume_range = 1
			dissipate_delay = 5
			dissipate_track = 0
			dissipate_strength = 5
		if(STAGE_THREE)
			if((check_turfs_in(1,2))&&(check_turfs_in(2,2))&&(check_turfs_in(4,2))&&(check_turfs_in(8,2)))
				current_size = STAGE_THREE
				icon = 'icons/effects/160x160.dmi'
				icon_state = "singularity_s5"
				pixel_x = -64
				pixel_y = -64
				grav_pull = 8
				consume_range = 2
				dissipate_delay = 4
				dissipate_track = 0
				dissipate_strength = 20
		if(STAGE_FOUR)
			if((check_turfs_in(1,3))&&(check_turfs_in(2,3))&&(check_turfs_in(4,3))&&(check_turfs_in(8,3)))
				current_size = STAGE_FOUR
				icon = 'icons/effects/224x224.dmi'
				icon_state = "singularity_s7"
				pixel_x = -96
				pixel_y = -96
				grav_pull = 10
				consume_range = 3
				dissipate_delay = 10
				dissipate_track = 0
				dissipate_strength = 10
		if(STAGE_FIVE)//this one also lacks a check for gens because it eats everything
			current_size = STAGE_FIVE
			icon = 'icons/effects/288x288.dmi'
			icon_state = "singularity_s9"
			pixel_x = -128
			pixel_y = -128
			grav_pull = 10
			consume_range = 4
			dissipate = 0 //It cant go smaller due to e loss
	if(current_size == allowed_size)
		log_investigate("<font color='red'>grew to size [current_size]</font>",INVESTIGATE_SINGULO)
		return 1
	else if(current_size < (--temp_allowed_size))
		expand(temp_allowed_size)
	else
		return 0

/obj/singularity/get_current_temperature()
	// var/total_potential_energy = energy * energy / dissipate_strength
	return WATTS_2_CELSIUM * energy * energy / dissipate_strength

/obj/singularity/proc/check_energy()
	if(energy <= 0)
		qdel(src)
		return 0
	switch(energy)//Some of these numbers might need to be changed up later -Mport
		if(1 to 199)
			allowed_size = STAGE_ONE
		if(200 to 499)
			allowed_size = STAGE_TWO
		if(500 to 999)
			allowed_size = STAGE_THREE
		if(1000 to 1999)
			allowed_size = STAGE_FOUR
		if(2000 to INFINITY)
			allowed_size = STAGE_FIVE
	if(current_size != allowed_size)
		expand()
	return 1

/obj/singularity/proc/eat()
	set background = BACKGROUND_ENABLED
	for(var/tile in spiral_range_turfs(grav_pull, src, 1))
		var/turf/T = tile
		if(!T)
			continue
		if(get_dist(T, src) > consume_range)
			T.singularity_pull(src, current_size)
		else
			consume(T)
		for(var/thing in T)
			var/atom/movable/X = thing
			if(get_dist(X, src) > consume_range)
				X.singularity_pull(src, current_size)
			else
				consume(X)
			CHECK_TICK
	return

/obj/singularity/Process_Spacemove() //The singularity stops drifting for no man!
	return 1

/obj/singularity/proc/consume(atom/A)
	var/gain = A.singularity_act(current_size)
	src.energy += gain
	return

/obj/singularity/proc/move(force_move = 0)
	if(!move_self)
		return 0

	var/movement_dir = pick(alldirs - last_failed_movement)

	if(force_move)
		movement_dir = force_move

	if(target && prob(60))
		movement_dir = get_dir(src,target) //moves to a singulo beacon, if there is one

	step(src, movement_dir)

/obj/singularity/proc/check_turfs_in(direction = 0, step = 0)
	if(!direction)
		return 0
	var/steps = 0
	if(!step)
		switch(current_size)
			if(STAGE_ONE)
				steps = 1
			if(STAGE_TWO)
				steps = 3//Yes this is right
			if(STAGE_THREE)
				steps = 3
			if(STAGE_FOUR)
				steps = 4
			if(STAGE_FIVE)
				steps = 5
	else
		steps = step
	var/list/turfs = list()
	var/turf/T = src.loc
	for(var/i = 1 to steps)
		T = get_step(T,direction)
	if(!isturf(T))
		return 0
	turfs.Add(T)
	var/dir2 = 0
	var/dir3 = 0
	switch(direction)
		if(NORTH||SOUTH)
			dir2 = 4
			dir3 = 8
		if(EAST||WEST)
			dir2 = 1
			dir3 = 2
	var/turf/T2 = T
	for(var/j = 1 to steps-1)
		T2 = get_step(T2,dir2)
		if(!isturf(T2))
			return 0
		turfs.Add(T2)
	for(var/k = 1 to steps-1)
		T = get_step(T,dir3)
		if(!isturf(T))
			return 0
		turfs.Add(T)
	for(var/turf/T3 in turfs)
		if(isnull(T3))
			continue
		if(!can_move(T3))
			return 0
	return 1

/obj/singularity/proc/can_move(turf/T)
	if(!T)
		return 0
	if((locate(/obj/machinery/containment_field) in T)||(locate(/obj/machinery/shieldwall) in T))
		return 0
	else if(locate(/obj/machinery/field_generator) in T)
		var/obj/machinery/field_generator/G = locate(/obj/machinery/field_generator) in T
		if(G && G.active)
			return 0
	else if(locate(/obj/machinery/shieldwallgen) in T)
		var/obj/machinery/shieldwallgen/S = locate(/obj/machinery/shieldwallgen) in T
		if(S && S.active)
			return 0
	return 1

/obj/singularity/proc/event()
	var/numb = pick(1,2,3,4,5,6)
	switch(numb)
		if(1)//EMP
			emp_area()
		if(2,3)//Stun mobs who lack optic scanners
			mezzer()
		else
			return 0
	return 1

/obj/singularity/proc/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(istype(M, /mob/living/carbon/brain)) //Ignore brains
			continue

		if(M.stat == CONSCIOUS)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.glasses,/obj/item/clothing/glasses/meson))
					to_chat(H, "<span class='notice'>You look directly into The [src.name], good thing you had your protective eyewear on!</span>")
					return
		to_chat(M, "<span class='red'>You look directly into The [src.name] and feel weak.</span>")
		M.apply_effect(3, STUN)
		M.visible_message("<span class='danger'>[M] stares blankly at The [src]!</span>")
	return

/obj/singularity/proc/emp_area()
	empulse(src, 8, 10)
	return

/obj/singularity/proc/pulse()
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		if(get_dist(R, src) <= 15) // Better than using orange() every process
			R.receive_pulse(energy)
	return

/obj/singularity/singularity_act()
	var/gain = (energy/2)
	var/dist = max((current_size - 2),1)
	explosion(src.loc,(dist),(dist*2),(dist*4))
	qdel(src)
	return(gain)
