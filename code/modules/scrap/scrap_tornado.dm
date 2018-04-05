/obj/singularity/scrap_ball
	name = "tornado"
	desc = "Holy shit, run!"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "tornado"
	color = "#666666"
	alpha = 200
	current_size = STAGE_TWO
//	layer = LIGHTING_LAYER + 1
//	plane = LIGHTING_PLANE + 1
	pixel_x = -64
	pixel_y = -64
	move_self = 1
	grav_pull = 6
	contained = 0
	consume_range = 3
	layer = 8
	density = 1
/obj/singularity/scrap_ball/admin_investigate_setup()
	return


/obj/singularity/scrap_ball/Destroy()
	for(var/datum/orbit/shot in orbiters)
		var/atom/movable/throwit = shot.orbiter
		throwit.stop_orbit()
		throwit.throw_at(locate(loc.x + rand(40) - 20, loc.y + rand(40) - 20, loc.z), 81, pick(1,3,80,80))
	return ..()

/obj/singularity/scrap_ball/process()
	step(src, pick(alldirs - last_failed_movement))
	for(var/datum/orbit/shot in orbiters)
		if(istype(shot.orbiter, /mob/living))
			var/mob/living/getbrute = shot.orbiter
			getbrute.adjustBruteLoss(10)
			getbrute.apply_effect(2, STUN)
	if(prob(event_chance))
		event()
	eat()
	return

/obj/singularity/scrap_ball/event()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(istype(M, /mob/living/carbon/brain)) //Ignore brains
			continue
		to_chat(M, "<span class='red'>You [pick("look in awe on", "can't withstand")] the [src.name].</span>")
		M.apply_effect(3, STUN)
	return 1


/obj/singularity/scrap_ball/consume(atom/A)
	if (!loc)
		return
	if(istype(A, /obj) || istype(A, /mob))
		var/atom/movable/to_add = A
		if(to_add.anchored || to_add.orbiting)
			return
		if(get_area(to_add) != get_area(src))
			return
		if(istype(to_add, /mob/living))
			var/mob/living/nomove = to_add
			nomove.apply_effect(5, STUN)
		var/icon/I = icon(icon,icon_state,dir)
		var/orbitsize = (I.Width() + I.Height()) * pick(0.3, 0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9)
		orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)
		to_add.orbit(src, orbitsize, TRUE, rand(8, 30), 36)
		return

/obj/singularity/scrap_ball/Bump(atom/A)
	consume(A)
	return

/obj/singularity/scrap_ball/Bumped(atom/A)
	consume(A)
