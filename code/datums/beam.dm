//Beam Datum and effect
/datum/beam
	var/atom/origin = null
	var/atom/target = null
	var/list/elements = list()
	var/icon/base_icon = null
	var/icon
	var/icon_state = "" //icon state of the main segments of the beam
	var/max_distance = 0
	var/sleep_time = 3
	var/finished = 0
	var/turf/target_oldloc = null
	var/turf/origin_oldloc = null
	var/static_beam = 0
	var/beam_type = /obj/effect/ebeam //must be subtype
	var/plane = null
	var/timing_id = null
	var/recalculating = FALSE

	var/obj/effect/ebeam/visuals //what we add to the ebeam's visual contents. never gets deleted on redrawing.

	var/origin_additional_pixel_x = 0
	var/origin_additional_pixel_y = 0

	var/loose = FALSE

/datum/beam/New(beam_origin,beam_target,beam_icon='icons/effects/beam.dmi',beam_icon_state="b_beam",time=50,maxdistance=10,btype = /obj/effect/ebeam, beam_sleep_time=3, beam_plane, origin_additional_pixel_x = 0, origin_additional_pixel_y = 0, loose = FALSE)
	origin = beam_origin
	origin_oldloc =	get_turf(origin)
	target = beam_target
	target_oldloc = get_turf(target)
	sleep_time = beam_sleep_time
	if(origin_oldloc == origin && target_oldloc == target)
		static_beam = 1
	max_distance = maxdistance
	base_icon = new(beam_icon,beam_icon_state)
	icon = beam_icon
	icon_state = beam_icon_state
	beam_type = btype
	if(!isnull(beam_plane))
		plane = beam_plane
	if(time < INFINITY)
		addtimer(CALLBACK(src,PROC_REF(End)), time)

	src.origin_additional_pixel_x = origin_additional_pixel_x
	src.origin_additional_pixel_y = origin_additional_pixel_y

	src.loose = loose

	if(ismovable(origin) && ismovable(target))
		RegisterSignal(origin, list(COMSIG_MOVABLE_MOVED), PROC_REF(recalculate))

/datum/beam/proc/Start()
	visuals = new beam_type()
	visuals.icon = icon
	visuals.icon_state = icon_state
	Draw()
	recalculate_in(sleep_time)

/datum/beam/proc/recalculate()
	if(recalculating)
		recalculate_in(sleep_time)
		return
	recalculating = TRUE
	timing_id = null
	if(origin && target && get_dist(origin,target)<max_distance && origin.z == target.z)
		var/turf/origin_turf = get_turf(origin)
		var/turf/target_turf = get_turf(target)
		if(!static_beam && (origin_turf != origin_oldloc || target_turf != target_oldloc))
			var/redraw = TRUE
			if((origin_oldloc.x - target_oldloc.x == origin_turf.x - target_turf.x) && (origin_oldloc.y - target_oldloc.y == origin_turf.y - target_turf.y))
				redraw = FALSE

				var/shiftX = origin_turf.x - origin_oldloc.x
				var/shiftY = origin_turf.y - origin_oldloc.y

				for(var/obj/effect/ebeam/B in elements)
					B.x += shiftX
					B.y += shiftY

			origin_oldloc = origin_turf //so we don't keep checking against their initial positions, leading to endless Reset()+Draw() calls
			target_oldloc = target_turf

			if(redraw)
				Reset()
				Draw()

		after_calculate()
		recalculating = FALSE
	else
		End()

/datum/beam/proc/afterDraw()
	return

/datum/beam/proc/recalculate_in(time)
	if(timing_id)
		deltimer(timing_id)
	timing_id = addtimer(CALLBACK(src, PROC_REF(recalculate)), time, TIMER_STOPPABLE)

/datum/beam/proc/after_calculate()
	if((sleep_time == null) || finished)	//Does not automatically recalculate.
		return
	if(isnull(timing_id))
		timing_id = addtimer(CALLBACK(src, PROC_REF(recalculate)), sleep_time, TIMER_STOPPABLE)

/datum/beam/proc/End(destroy_self = TRUE)
	finished = TRUE
	if(!isnull(timing_id))
		deltimer(timing_id)
	if(!QDELETED(src) && destroy_self)
		qdel(src)

/datum/beam/proc/Reset()
	for(var/obj/effect/ebeam/B in elements)
		qdel(B)
	elements.Cut()

/datum/beam/Destroy()
	Reset()
	qdel(visuals)

	UnregisterSignal(origin, list(COMSIG_MOVABLE_MOVED))
	target = null
	origin = null
	return ..()

/datum/beam/proc/get_bezier_point(Ax, Ay, Px, Py, Bx, By, f)
	var/f2 = 1 - f

	var/pointX = round(f2**2 * Ax + 2 * f2 * f * Px + f**2 * Bx)
	var/pointY = round(f2**2 * Ay + 2 * f2 * f * Py + f**2 * By)

	return list(pointX, pointY)

/datum/beam/proc/get_points(Ax, Ay, Bx, By)
	if(!loose)
		return list(list(Ax, Ay), list(Bx, By))

	var/length = round(sqrt((Bx-Ax)**2+(By-Ay)**2))

	var/segments = min(8, round(length / 8))

	var/Px = Ax + round((Bx - Ax) / 2)
	var/Py = Ay + round((By - Ay) / 2 - min(16, (length * 1.5 - length) / 2))
	var/list/points = list()
	for(var/i in 0 to segments)
		points += list(get_bezier_point(Ax, Ay, Px, Py, Bx, By, i / segments))

	return points

/datum/beam/proc/Draw()
	var/Ax = 32 * origin.x + origin.pixel_x + origin_additional_pixel_x
	var/Ay = 32 * origin.y + origin.pixel_y + origin_additional_pixel_y

	var/Bx = 32 * target.x + target.pixel_x
	var/By = 32 * target.y + target.pixel_y

	var/list/points = get_points(Ax, Ay, Bx, By)
	for(var/i in 1 to points.len - 1)
		var/list/pointA = points[i]
		var/list/pointB = points[i + 1]
		DrawSegment(pointA[1], pointA[2], pointB[1], pointB[2])

/datum/beam/proc/DrawSegment(Ax, Ay, Bx, By)

	//Translation vector for origin and target
	var/DX = Bx - Ax
	var/DY = By - Ay
	var/Angle = round(arctan(DY, DX))
	var/matrix/rot_matrix = matrix()
	rot_matrix.Turn(Angle)
	var/N = 0
	var/length = CEILING(sqrt((DX)**2+(DY)**2), 1) //hypotenuse of the triangle formed by target and origin's displacement

	var/offsetX = Ax - origin.x * 32
	var/offsetY = Ay - origin.y * 32

	for(N in 0 to length-1 step 32)//-1 as we want < not <=, but we want the speed of X in Y to Z and step X
		if(QDELETED(src) || finished)
			break
		var/obj/effect/ebeam/X = new beam_type(origin_oldloc)
		X.owner = src
		if(plane)
			X.plane = plane
		elements += X

		//Assign our single visual ebeam to each ebeam's vis_contents
		//ends are cropped by a transparent box icon of length-N pixel size laid over the visuals obj
		if(N+32>length) //went past the target, needs to be cut short
			var/icon/II = new(icon, icon_state) //the way to keep this the same as the vis_contents is unreasonable right now, maybe in the far future.
			II.DrawBox(null,1,length-N,32,32)//anyway we cut the icon on the ebeam to end at the target instead of overshooting
			X.icon = II
		else
			X.vis_contents += visuals
		X.transform = rot_matrix

		//Calculate pixel offsets (If necessary)
		var/Pixel_x
		var/Pixel_y
		if(DX == 0)
			Pixel_x = offsetX
		else
			Pixel_x = round(sin(Angle)+32*sin(Angle)*(N+16)/32) + offsetX
		if(DY == 0)
			Pixel_y = offsetY
		else
			Pixel_y = round(cos(Angle)+32*cos(Angle)*(N+16)/32) + offsetY

		//Position the effect so the beam is one continous line
		var/a
		if(abs(Pixel_x)>32)
			a = Pixel_x > 0 ? round(Pixel_x/32) : CEILING(Pixel_x/32, 1)
			X.x += a
			Pixel_x %= 32
		if(abs(Pixel_y)>32)
			a = Pixel_y > 0 ? round(Pixel_y/32) : CEILING(Pixel_y/32, 1)
			X.y += a
			Pixel_y %= 32

		X.pixel_x = Pixel_x
		X.pixel_y = Pixel_y
		CHECK_TICK
	afterDraw()

/obj/effect/ebeam
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	var/datum/beam/owner

/obj/effect/ebeam/Destroy()
	owner = null
	return ..()

/obj/effect/ebeam/singularity_pull()
	return

/obj/effect/ebeam/singularity_act()
	return

/atom/proc/Beam(atom/BeamTarget,icon_state="b_beam",icon='icons/effects/beam.dmi',time=50, maxdistance=10,beam_type=/obj/effect/ebeam,beam_sleep_time = 3,beam_plane, origin_additional_pixel_x = 0, origin_additional_pixel_y = 0, loose = FALSE)
	var/datum/beam/newbeam = new(src,BeamTarget,icon,icon_state,time,maxdistance,beam_type,beam_sleep_time,beam_plane, origin_additional_pixel_x, origin_additional_pixel_y, loose)
	INVOKE_ASYNC(newbeam, TYPE_PROC_REF(/datum/beam, Start))
	return newbeam
