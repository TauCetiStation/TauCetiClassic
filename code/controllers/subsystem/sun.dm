SUBSYSTEM_DEF(sun)
	name = "Sun"

	init_order = SS_INIT_SUN
	wait       = SS_WAIT_SUN

	flags = SS_POST_FIRE_TIMING | SS_NO_INIT | SS_NO_TICK_CHECK

	var/angle
	var/dx
	var/dy
	var/rate
	var/list/solars	= list()
	var/nexttime = 3600		// Replacement for var/counter to force the sun to move every X IC minutes
	var/lastAngleUpdate

/datum/controller/subsystem/sun/PreInit()
	angle = rand (0,360)			// the station position to the sun is randomised at round start
	rate = rand(500,2000)/1000			// 50% - 200% of standard rotation
	if(prob(50))					// same chance to rotate clockwise than counter-clockwise
		rate = -rate

/datum/controller/subsystem/sun/stat_entry(msg)
	..("P:[solars.len]")

/datum/controller/subsystem/sun/fire()
	angle = ((rate*world.time/100)%360 + 360)%360

	/*
		Yields a 45 - 75 IC minute rotational period
		Rotation rate can vary from 4.8 deg/min to 8 deg/min (288 to 480 deg/hr)
	*/
	if(lastAngleUpdate != angle)
		for(var/obj/machinery/power/tracker/T in solars)
			if(!T.powernet)
				solars -= T
				continue
			T.set_angle(angle)
	lastAngleUpdate=angle

	nexttime = nexttime + 600	// 600 world.time ticks = 1 minute

	// now calculate and cache the (dx,dy) increments for line drawing
	var/s = sin(angle)
	var/c = cos(angle)

	if(c == 0)
		dx = 0
		dy = s

	else if( abs(s) < abs(c))
		dx = s / abs(c)
		dy = c / abs(c)
	else
		dx = s/abs(s)
		dy = c / abs(s)

	for(var/obj/machinery/power/solar/S in solars)
		if(!S.powernet)
			solars -= S
			continue
		if(S.control)
			occlusion(S)

// for a solar panel, trace towards sun to see if we're in shadow
/datum/controller/subsystem/sun/proc/occlusion(obj/machinery/power/solar/S)
	var/ax = S.x		// start at the solar panel
	var/ay = S.y

	for(var/i = 1 to 20)		// 20 steps is enough
		ax += dx	// do step
		ay += dy

		var/turf/T = locate( round(ax,0.5),round(ay,0.5),S.z)
		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)		// not obscured if we reach the edge
			break

		if(T.density)			// if we hit a solid turf, panel is obscured
			S.obscured = 1
			return

	S.obscured = 0		// if hit the edge or stepped 20 times, not obscured
	S.update_solar_exposure()
