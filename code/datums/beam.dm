//Beam Datum and effect
/datum/beam
	var/atom/origin = null
	var/atom/target = null
	var/list/elements = list()
	var/icon/base_icon = null
	var/icon
	var/icon_state = "" //icon state of the main segments of the beam
	var/max_distance = 0
	var/endtime = 0
	var/sleep_time = 3
	var/finished = 0
	var/target_oldloc = null
	var/origin_oldloc = null
	var/static_beam = 0
	var/beam_type = /obj/effect/ebeam //must be subtype
	var/layer = null


/datum/beam/New(beam_origin,beam_target,beam_icon='icons/effects/beam.dmi',beam_icon_state="b_beam",time=50,maxdistance=10,btype = /obj/effect/ebeam,beam_layer)
	endtime = world.time+time
	origin = beam_origin
	origin_oldloc =	get_turf(origin)
	target = beam_target
	target_oldloc = get_turf(target)
	if(origin_oldloc == origin && target_oldloc == target)
		static_beam = 1
	max_distance = maxdistance
	base_icon = new(beam_icon,beam_icon_state)
	icon = beam_icon
	icon_state = beam_icon_state
	beam_type = btype
	layer = beam_layer


/datum/beam/proc/Start()
	Draw()
	while(!finished && origin && target && world.time < endtime && get_dist(origin,target)<max_distance && origin.z == target.z)
		var/origin_turf = get_turf(origin)
		var/target_turf = get_turf(target)
		if(!static_beam && (origin_turf != origin_oldloc || target_turf != target_oldloc))
			origin_oldloc = origin_turf //so we don't keep checking against their initial positions, leading to endless Reset()+Draw() calls
			target_oldloc = target_turf
			Reset()
			Draw()
		sleep(sleep_time)

	qdel(src)


/datum/beam/proc/End()
	finished = 1


/datum/beam/proc/Reset()
	for(var/obj/effect/ebeam/B in elements)
		qdel(B)


/datum/beam/Destroy()
	Reset()
	target = null
	origin = null
	return ..()


/datum/beam/proc/Draw()
	var/Angle = round(Get_Angle(origin,target))

	var/matrix/rot_matrix = matrix()
	rot_matrix.Turn(Angle)

	//Translation vector for origin and target
	var/DX = (world.icon_size*target.x+target.pixel_x)-(world.icon_size*origin.x+origin.pixel_x)
	var/DY = (world.icon_size*target.y+target.pixel_y)-(world.icon_size*origin.y+origin.pixel_y)
	var/N = 0
	var/length = round(sqrt((DX)**2+(DY)**2)) //hypotenuse of the triangle formed by target and origin's displacement

	for(N in 0 to length-1 step world.icon_size)//-1 as we want < not <=, but we want the speed of X in Y to Z and step X
		var/obj/effect/ebeam/X = new beam_type(origin_oldloc)
		X.owner = src
		if(layer)
			X.layer = layer
		elements |= X

		//Assign icon, for main segments it's base_icon, for the end, it's icon+icon_state
		//cropped by a transparent box of length-N pixel size
		if(N+world.icon_size>length)
			var/icon/II = new(icon, icon_state)
			II.DrawBox(null,1,(length-N),world.icon_size,world.icon_size)
			X.icon = II
		else
			X.icon = base_icon
		X.transform = rot_matrix

		//Calculate pixel offsets (If necessary)
		var/Pixel_x
		var/Pixel_y
		if(DX == 0)
			Pixel_x = 0
		else
			Pixel_x = round(sin(Angle)+world.icon_size*sin(Angle)*(N+32)/world.icon_size)
		if(DY == 0)
			Pixel_y = 0
		else
			Pixel_y = round(cos(Angle)+world.icon_size*cos(Angle)*(N+32)/world.icon_size)

		//Position the effect so the beam is one continous line
		var/a
		if(abs(Pixel_x)>world.icon_size)
			a = Pixel_x > 0 ? round(Pixel_x/world.icon_size) : Ceiling(Pixel_x/world.icon_size)
			X.x += a
			Pixel_x %= world.icon_size
		if(abs(Pixel_y)>world.icon_size)
			a = Pixel_y > 0 ? round(Pixel_y/world.icon_size) : Ceiling(Pixel_y/world.icon_size)
			X.y += a
			Pixel_y %= world.icon_size

		X.pixel_x = Pixel_x
		X.pixel_y = Pixel_y
		CHECK_TICK


/obj/effect/ebeam
	mouse_opacity = 0
	anchored = 1
	var/datum/beam/owner


/obj/effect/ebeam/Destroy()
	owner = null
	return ..()


/atom/proc/Beam(atom/BeamTarget,icon_state="b_beam",icon='icons/effects/beam.dmi',time=50, maxdistance=10,beam_type=/obj/effect/ebeam,beam_layer=null)
	var/datum/beam/newbeam = new(src,BeamTarget,icon,icon_state,time,maxdistance,beam_type,beam_layer)
	spawn(0)
		newbeam.Start()
	return newbeam
