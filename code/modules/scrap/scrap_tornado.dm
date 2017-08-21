/obj/singularity/scrap_ball
	name = "energy ball"
	desc = "Sand tornado."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "singularity_s3"
	color = "yellow"
	current_size = STAGE_TWO
//	layer = LIGHTING_LAYER + 1
//	plane = LIGHTING_PLANE + 1
	pixel_x = -32
	pixel_y = -32
	move_self = 1
	grav_pull = 6
	contained = 0
	density = 1
	alpha = 200
	var/failed = 0
	var/pulled = 0
	var/list/orbiting_scrap = list()

/obj/singularity/scrap_ball/Destroy()
	for(var/atom/movable/shot in orbiting_scrap)
		shot.stop_orbit()
		shot.throw_at(locate(loc.x + rand(40) - 20, loc.y + rand(40) - 20, loc.z), 81, pick(1,3,80,80))
		orbiting_scrap -= shot
	orbiting_scrap.Cut()
	return ..()

/obj/singularity/scrap_ball/process()
	step(src, pick(alldirs - last_failed_movement))
	eat()
	return

/obj/singularity/scrap_ball/consume(atom/A)
	if (!loc)
		return
	if(istype(A, /obj) || istype(A, /mob))
		var/atom/movable/to_add = A
		if(to_add.anchored)
			return
		if(orbiting_scrap.Find(to_add))
			return
		orbiting_scrap += to_add
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
