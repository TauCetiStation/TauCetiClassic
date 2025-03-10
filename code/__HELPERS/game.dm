//supposedly the fastest way to do this according to https://gist.github.com/Giacom/be635398926bb463b42a
#define RANGE_TURFS(RADIUS, CENTER) \
  block( \
    locate(max(CENTER.x-(RADIUS),1),          max(CENTER.y-(RADIUS),1),          CENTER.z), \
    locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy), CENTER.z) \
  )

//gets an empty square with RADIUS from CENTER
#define BORDER_TURFS(RADIUS, CENTER) \
	block( \
		locate(max(CENTER.x-(RADIUS),1), min(CENTER.y+(RADIUS),world.maxy),CENTER.z), \
		locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy),CENTER.z) \
	) + \
	block( \
		locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy),CENTER.z), \
		locate(min(CENTER.x+(RADIUS),world.maxx), max(CENTER.y-(RADIUS),1),CENTER.z) \
	) + \
	block( \
		locate(max(CENTER.x-(RADIUS),1), max(CENTER.y-(RADIUS),1),CENTER.z), \
		locate(min(CENTER.x+(RADIUS),world.maxx), max(CENTER.y-(RADIUS),1),CENTER.z) \
	) + \
	block( \
		locate(max(CENTER.x-(RADIUS),1), min(CENTER.y+(RADIUS),world.maxy),CENTER.z), \
		locate(max(CENTER.x-(RADIUS),1), max(CENTER.y-(RADIUS),1),CENTER.z), \
	)

///Returns the name of the area the atom is in
/proc/get_area_name(atom/checked_atom)
	var/area/checked_area = isarea(checked_atom) ? checked_atom : get_area(checked_atom)
	if(!checked_area)
		return null
	return checked_area.name

/proc/get_area_by_name(N) //get area by its name
	for(var/area/A in all_areas)
		if(A.name == N)
			return A
	return null

/proc/get_area_by_type(type) //get area by its type
	var/area/area = areas_by_type[type]
	if(area)
		return area
	return locate(type) in all_areas

/proc/in_range(source, user)
	if(get_dist(source, user) <= 1)
		return TRUE

	return FALSE //not in range and not telekinetic

/**
 * Get a bounding box of a list of atoms.
 *
 * Arguments:
 * - atoms - List of atoms. Can accept output of view() and range() procs.
 *
 * Returns: list(x1, y1, x2, y2)
 */
/proc/get_bbox_of_atoms(list/atoms)
	var/list/list_x = list()
	var/list/list_y = list()
	for(var/_a in atoms)
		var/atom/a = _a
		list_x += a.x
		list_y += a.y
	return list(
		min(list_x),
		min(list_y),
		max(list_x),
		max(list_y))

// Like view but bypasses luminosity check

/proc/hear(range, atom/source)

	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/atoms = list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms

/proc/get_dist_euclidian(atom/Loc1,atom/Loc2)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx**2 + dy**2)

	return dist

/proc/circlerangeturfs(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center=usr,radius=3)		//Is there even a diffrence between this proc and circlerangeturfs()?

	var/turf/centerturf = get_turf(center)
	var/list/turfs = list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs



//var/debug_mob = 0

// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.

/proc/recursive_mob_check(atom/O,  list/L = list(), recursion_limit = 3, client_check = TRUE, sight_check = TRUE, include_radio = TRUE)

	//debug_mob += O.contents.len
	if(!recursion_limit)
		return L
	for(var/atom/A in O.contents)

		if(ismob(A))
			var/mob/M = A
			if(client_check && !M.client)
				L |= recursive_mob_check(A, L, recursion_limit - 1, client_check, sight_check, include_radio)
				continue
			if(sight_check && !isInSight(A, O))
				continue
			L |= M
			//world.log << "[recursion_limit] = [M] - [get_turf(M)] - [COORD(M)]"

		else if(include_radio && istype(A, /obj/item/device/radio))
			if(sight_check && !isInSight(A, O))
				continue
			L |= A

		if(isobj(A) || ismob(A))
			L |= recursive_mob_check(A, L, recursion_limit - 1, client_check, sight_check, include_radio)
	return L

// The old system would loop through lists for a total of 5000 per function call, in an empty server.
// This new system will loop at around 1000 in an empty server.

/proc/get_mobs_in_view(R, atom/source)
	// Returns a list of mobs in range of R from source. Used in radio and say code.

	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = hear(R, T)

	for(var/atom/A in range)
		if(ismob(A))
			var/mob/M = A
			if(M.client)
				hear += M
			//world.log << "Start = [M] - [get_turf(M)] - [COORD(M)]"
		else if(istype(A, /obj/item/device/radio))
			hear += A

		if(isobj(A) || ismob(A))
			hear |= recursive_mob_check(A, hear, 3, 1, 0, 1)

	return hear

// todo: https://github.com/tgstation/tgstation/pull/61422
/proc/get_hearers_in_view(R, atom/source)
	// Returns a list of hearers in view(R) from source (ignoring luminosity). Used in saycode.
	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/lum = T.luminosity
	T.luminosity = 6
	hear = get_mobs_in_view(R, T)
	T.luminosity = lum
	return hear


/proc/get_mobs_in_radio_ranges(list/obj/item/device/radio/radios)

	//set background = 1

	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/obj/item/device/radio/R in radios)
		if(R)
			//Cyborg checks. Receiving message uses a bit of cyborg's charge.
			var/obj/item/device/radio/borg/BR = R
			if(istype(BR) && BR.myborg)
				var/mob/living/silicon/robot/borg = BR.myborg
				var/datum/robot_component/CO = borg.get_component("radio")
				if(!CO)
					continue //No radio component (Shouldn't happen)
				if(!borg.is_component_functioning("radio") || !borg.cell_use_power(CO.active_usage))
					continue //No power.

			var/turf/speaker = get_turf(R)
			if(speaker)
				for(var/turf/T in hear(R.canhear_range,speaker))
					speaker_coverage[T] = T


	// Try to find all the players who can hear the message
	for(var/mob/M as anything in player_list)
		if(M)
			var/turf/ear = get_turf(M)
			if(ear)
				// Ghostship is magic: Ghosts can hear radio chatter from anywhere
				if(speaker_coverage[ear] || (isobserver(M) && (M.client) && (M.client.prefs.chat_toggles & CHAT_GHOSTRADIO)))
					. |= M		// Since we're already looping through mobs, why bother using |= ? This only slows things down.
	return .

/atom/movable/proc/get_mob()
	return

/obj/machinery/bot/mulebot/get_mob()
	if(load && isliving(load))
		return load

/obj/mecha/get_mob()
	return occupant

/mob/get_mob()
	return src

/proc/mobs_in_view(range, source)
	var/list/mobs = list()
	for(var/atom/movable/AM in view(range, source))
		var/M = AM.get_mob()
		if(M)
			mobs += M

	return mobs

/proc/inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
	var/turf/T
	if(X1==X2)
		if(Y1==Y2)
			return TRUE //Light cannot be blocked on same tile
		else
			var/s = SIGN(Y2-Y1)
			Y1+=s
			while(Y1!=Y2)
				T=locate(X1,Y1,Z)
				if(T.opacity)
					return FALSE
				Y1+=s
	else
		var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
		var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
		var/signX = SIGN(X2-X1)
		var/signY = SIGN(Y2-Y1)
		if(X1<X2)
			b+=m
		while(X1!=X2 || Y1!=Y2)
			if(round(m*X1+b-Y1))
				Y1+=signY //Line exits tile vertically
			else
				X1+=signX //Line exits tile horizontally
			T=locate(X1,Y1,Z)
			if(T.opacity)
				return FALSE
	return TRUE

/proc/isInSight(atom/A, atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return FALSE

	if(inLineOfSight(Aturf.x,Aturf.y, Bturf.x,Bturf.y,Aturf.z))
		return TRUE

	else
		return FALSE

/proc/mobs_in_area(area/the_area, client_needed=0, moblist=mob_list)
	var/list/mobs_found[0]
	var/area/our_area = get_area(the_area)
	for(var/mob/M in moblist)
		if(client_needed && !M.client)
			continue
		if(our_area != get_area(M))
			continue
		mobs_found += M
	return mobs_found

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/try_move_adjacent(atom/movable/AM)
	var/turf/T = get_turf(AM)
	for(var/direction in cardinal)
		if(AM.Move(get_step(T, direction)))
			break

/proc/get_mob_by_key(key)
	for(var/mob/M as anything in mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null

/proc/considered_alive(datum/mind/M, enforce_human = TRUE)
	if(M?.current)
		if(enforce_human)
			return M.current.stat != DEAD && !issilicon(M.current) && !isbrain(M.current)
		if(isliving(M.current))
			return M.current.stat != DEAD
	return FALSE

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))	O = new /atom/movable/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))	return
	if(!group)	group = clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

/datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(src_x, src_y, time, distance, \
							 power_x, power_y, dest_x, dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(src_x, src_y, rotation, angle, power)

	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2* power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)

/proc/MixColors(const/list/colors)
	var/list/reds = list()
	var/list/blues = list()
	var/list/greens = list()
	var/list/weights = list()

	for (var/i = 0, ++i <= colors.len)
		reds.Add(GETREDPART(colors[i]))
		blues.Add(GETBLUEPART(colors[i]))
		greens.Add(GETGREENPART(colors[i]))
		weights.Add(1)

	var/r = mixOneColor(weights, reds)
	var/g = mixOneColor(weights, greens)
	var/b = mixOneColor(weights, blues)
	return rgb(r,g,b)

/proc/noob_notify(mob/M)
	//todo: check db before
	if(!M.client)
		return
	if(M.client.holder)
		return

	var/player_assigned_role = (M.mind.assigned_role ? " ([M.mind.assigned_role])" : "")
	var/player_byond_profile = "http://www.byond.com/members/[M.ckey]"
	if(M.client.player_age == 0)
		var/adminmsg = trim_margin({"
		|New player notify
		|Player '[M.ckey]' joined to the game as [M.mind.name][player_assigned_role] [ADMIN_FLW(M)] [ADMIN_PP(M)] [ADMIN_VV(M)]
		|Byond profile: <a href='[player_byond_profile]'>open</a>
		|Guard report: <a href='?_src_=holder;guard=\ref[M]'>show</a>"})

		message_admins(adminmsg, emphasize = TRUE)

	if((isnum(M.client.player_age) && M.client.player_age < 5) || (isnum(M.client.player_ingame_age) && M.client.player_ingame_age < 600)) //less than 5 days on server OR less than 10 hours in game
		var/mentormsg = trim_margin({"
		|New player notify
		|Player '[M.key]' joined to the game as [M.mind.name][player_assigned_role] (<a href='byond://?_src_=usr;track=\ref[M]'>FLW</a>)
		|Days on server: [M.client.player_age]; Minutes played: [M.client.player_ingame_age < 120 ? "<span class='alert'>[M.client.player_ingame_age]</span>" : M.client.player_ingame_age]
		|Byond profile: <a href='[player_byond_profile]'>open</a> (can be experienced player from another server)"})

		message_mentors(mentormsg, TRUE, TRUE)

// Better get_dir proc
/proc/get_general_dir(atom/Loc1, atom/Loc2)
	var/dir = get_dir(Loc1, Loc2)
	switch(dir)
		if(NORTH, EAST, SOUTH, WEST)
			return dir

		if(NORTHEAST, SOUTHWEST)
			var/abs_x = abs(Loc2.x - Loc1.x)
			var/abs_y = abs(Loc2.y - Loc1.y)

			if(abs_y > (2*abs_x))
				return turn(dir,45)
			else if(abs_x > (2*abs_y))
				return turn(dir,-45)
			else
				return dir

		if(NORTHWEST, SOUTHEAST)
			var/abs_x = abs(Loc2.x - Loc1.x)
			var/abs_y = abs(Loc2.y - Loc1.y)

			if(abs_y > (2*abs_x))
				return turn(dir,-45)
			else if(abs_x > (2*abs_y))
				return turn(dir,45)
			else
				return dir

/proc/window_flash(client/C)
	if(ismob(C))
		var/mob/M = C
		if(M.client)
			C = M.client
	if(!C)
		return
	winset(C, "mainwindow", "flash=5")

//============VG PORTS============
/proc/recursive_type_check(atom/O, type = /atom)
	var/list/processing_list = list(O)
	var/list/processed_list = list()
	var/found_atoms = list()

	while (processing_list.len)
		var/atom/A = processing_list[1]

		if (istype(A, type))
			found_atoms |= A

		for (var/atom/B in A)
			if (!processed_list[B])
				processing_list |= B

		processing_list.Cut(1, 2)
		processed_list[A] = A

	return found_atoms

/proc/get_contents_in_object(atom/O, type_path = /atom/movable)
	if (O)
		return recursive_type_check(O, type_path) - O
	else
		return list()

//============TG PORTS============
/proc/remove_images_from_clients(image/I, list/show_to)
	for(var/client/C in show_to)
		C.images -= I

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_images_from_clients), I, show_to), duration, TIMER_CLIENT_TIME)

/proc/flick_overlay_view(image/I, atom/target, duration) //wrapper for the above, flicks to everyone who can see the target atom
	var/list/viewing = list()
	for(var/mob/M in viewers(target))
		if(M.client)
			viewing += M.client
	flick_overlay(I, viewing, duration)

//============Bay12 atmos=============
/proc/convert_k2c(temp)
	return ((temp - T0C))

/proc/convert_c2k(temp)
	return ((temp + T0C))

/proc/getCardinalAirInfo(turf/loc, list/stats=list("temperature"))
	var/list/temps[4]
	for(var/dir in cardinal)
		var/direction
		switch(dir)
			if(NORTH)
				direction = 1
			if(SOUTH)
				direction = 2
			if(EAST)
				direction = 3
			if(WEST)
				direction = 4
		var/turf/simulated/T=get_turf(get_step(loc,dir))
		var/list/rstats[stats.len]
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i in 1 to stats.len)
				if(stats[i] == "pressure")
					rstats[i] = environment.return_pressure()
				else
					rstats[i] = environment.vars[stats[i]]
		else if(istype(T, /turf/simulated))
			rstats = null // Exclude zone (wall, door, etc).
		else if(istype(T, /turf))
			// Should still work.  (/turf/return_air())
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i in 1 to stats.len)
				if(stats[i] == "pressure")
					rstats[i] = environment.return_pressure()
				else
					rstats[i] = environment.vars[stats[i]]
		temps[direction] = rstats
	return temps


// Procs for grabbing players.

// grab random ghost from candidates after poll_time
/proc/pollGhostCandidates(Question, be_special_type, Ignore_Role, poll_time = 300, check_antaghud = TRUE)
	var/list/mob/dead/observer/candidates = list()

	for(var/mob/dead/observer/O as anything in observer_list)
		if(check_antaghud && O.has_enabled_antagHUD == TRUE && config.antag_hud_restricted)
			continue
		candidates += O

	candidates = pollCandidates(Question, be_special_type, Ignore_Role, poll_time, candidates)

	return candidates

/proc/pollCandidates(Question = "Would you like to be a special role?", be_special_type, Ignore_Role, poll_time = 300, list/group = null)
	var/list/mob/candidates = list()
	var/time_passed = world.time

	if(!Ignore_Role)
		Ignore_Role = be_special_type

	for(var/mob/M in group)
		if(!M.client)
			continue
		if(jobban_isbanned(M, be_special_type) || jobban_isbanned(M, "Syndicate") || !M.client.prefs.be_role.Find(be_special_type) || role_available_in_minutes(M, be_special_type))
			continue
		if(Ignore_Role && M.client.prefs.ignore_question.Find(Ignore_Role))
			continue
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(requestCandidate), M, time_passed, candidates, Question, Ignore_Role, poll_time)
	sleep(poll_time)

	//Check all our candidates, to make sure they didn't log off during the 30 second wait period.
	for(var/mob/M in candidates)
		if(!M.client)
			candidates -= M

	listclearnulls(candidates)

	return candidates

/proc/requestCandidate(mob/M, time_passed, candidates, Question, Ignore_Role, poll_time)
	M.playsound_local(null, 'sound/misc/notice2.ogg', VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)//Alerting them to their consideration
	window_flash(M.client)
	var/ans = tgui_alert(M, Question, "Please answer in [poll_time * 0.1] seconds!", list("Yes", "No", "Not This Round"), poll_time)
	switch(ans)
		if("Yes")
			to_chat(M, "<span class='notice'>Choice registered: Yes.</span>")
			if((world.time - time_passed) > poll_time)//If more than 30 game seconds passed.
				to_chat(M, "<span class='danger'>Sorry, you were too late for the consideration!</span>")
				M.playsound_local(null, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)
				return
			candidates += M
		if("No")
			to_chat(M, "<span class='danger'>Choice registered: No.</span>")
			return
		if("Not This Round")
			to_chat(M, "<span class='danger'>Choice registered: No.</span>")
			to_chat(M, "<span class='notice'>You will no longer receive notifications for the role '[Ignore_Role]' for the rest of the round.</span>")
			M.client.prefs.ignore_question |= Ignore_Role
			return

// first answer "Yes" > transfer
/mob/proc/try_request_n_transfer(mob/M, Question = "Would you like to be a special role?", be_special_type, Ignore_Role, show_warnings = FALSE)
	if(key || mind || stat != CONSCIOUS || !M.client)
		return

	if(Ignore_Role && M.client.prefs.ignore_question.Find(Ignore_Role))
		return

	if(isobserver(M))
		var/mob/dead/observer/O = M
		if(O.has_enabled_antagHUD == TRUE && config.antag_hud_restricted)
			if(show_warnings)
				to_chat(O, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
			return

	if(jobban_isbanned(M, "Syndicate"))
		if(show_warnings)
			to_chat(M, "<span class='warning'>You are banned from antagonists!</span>")
		return

	if(jobban_isbanned(M, be_special_type) || role_available_in_minutes(M, be_special_type))
		if(show_warnings)
			to_chat(M, "<span class='warning'>You are banned from [be_special_type]!</span>")
		return

	INVOKE_ASYNC(src, PROC_REF(request_n_transfer), M, Question, be_special_type, Ignore_Role, show_warnings)

/mob/proc/request_n_transfer(mob/M, Question = "Would you like to be a special role?", be_special_type, Ignore_Role, show_warnings = FALSE)
	var/ans
	if(Ignore_Role)
		ans = tgui_alert(M, Question, "[be_special_type] Request", list("Yes", "No", "Not This Round"))
	else
		ans = tgui_alert(M, Question, "[be_special_type] Request", list("Yes", "No"))
	if(ans == "No")
		return
	if(ans == "Not This Round")
		M.client.prefs.ignore_question |= Ignore_Role
		return

	if(key || mind || stat != CONSCIOUS)
		return

	transfer_personality(M.client)

/mob/proc/transfer_personality(client/C)
	return

/atom/proc/has_valid_appearance()
	if(!check_sprite())
		return FALSE
	if(alpha != 255)
		return FALSE
	if(invisibility != INVISIBILITY_NONE)
		return FALSE
	return TRUE

/atom/proc/check_sprite()
	if(icon_state in icon_states(icon))
		return TRUE
	return FALSE

/**
 * Returns the atom sitting on the turf.
 * For example, using this on a disk, which is in a bag, on a mob, will return the mob because it's on the turf.
 * Optional arg 'type' to stop once it reaches a specific type instead of a turf.
**/
/proc/get_atom_on_turf(atom/movable/atom_on_turf, stop_type)
	var/atom/turf_to_check = atom_on_turf
	while(turf_to_check?.loc && !isturf(turf_to_check.loc))
		turf_to_check = turf_to_check.loc
		if(stop_type && istype(turf_to_check, stop_type))
			break
	return turf_to_check
