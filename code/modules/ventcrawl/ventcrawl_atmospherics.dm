/obj/machinery/atmospherics/var/image/pipe_image

/obj/machinery/atmospherics/Destroy()
	for(var/mob/living/M in src) //ventcrawling is serious business
		M.remove_ventcrawl()
		M.forceMove(get_turf(src))

	if(pipe_image)
		for(var/mob/living/M in player_list)
			if(M.client)
				M.client.images -= pipe_image
				M.pipes_shown -= pipe_image
		pipe_image = null

	return ..()

/obj/machinery/atmospherics/ex_act(severity)
	for(var/atom/movable/A in src) //ventcrawling is serious business
		A.ex_act(severity)
	. = ..()

/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	if(user.loc != src || !user.canmove || !(direction & initialize_directions)) //can't go in a way we aren't connecting to
		return
	ventcrawl_to(user, findConnecting(direction), direction)

/obj/machinery/atmospherics/proc/ventcrawl_to(mob/living/user, obj/machinery/atmospherics/target_move, direction)
	if(target_move)
		if(is_type_in_list(target_move, ventcrawl_machinery) && target_move.can_crawl_through())
			user.remove_ventcrawl()
			user.forceMove(target_move.loc) //handles entering and so on
			user.visible_message("You hear something squeezing through the ducts.", "You climb out the ventilation system.")
		else if(target_move.can_crawl_through())
			var/list/pipenetdiff = returnPipenets() ^ target_move.returnPipenets()
			if(pipenetdiff.len)
				user.remove_ventcrawl()
				user.add_ventcrawl(target_move)
			user.forceMove(target_move)
			user.client.eye = target_move //if we don't do this, Byond only updates the eye every tick - required for smooth movement
			if(world.time > user.next_play_vent)
				user.next_play_vent = world.time + 30
				playsound(src, 'sound/machines/ventcrawl.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	else
		if((direction & initialize_directions) || is_type_in_list(src, ventcrawl_machinery) && src.can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
			user.remove_ventcrawl()
			user.forceMove(src.loc)
			user.visible_message("You hear something squeezing through the pipes.", "You climb out the ventilation system.")
	user.canmove = FALSE
	spawn(1)
		user.canmove = TRUE

/obj/machinery/atmospherics/proc/can_crawl_through()
	return TRUE

/obj/machinery/atmospherics/components/binary/can_crawl_through()
	return use_power

/obj/machinery/atmospherics/components/binary/dp_vent_pump/can_crawl_through()
	return TRUE

/obj/machinery/atmospherics/components/binary/passive_gate/can_crawl_through()
	return unlocked

/obj/machinery/atmospherics/components/omni/can_crawl_through()
	return use_power

/obj/machinery/atmospherics/components/trinary/can_crawl_through()
	return use_power

/obj/machinery/atmospherics/components/binary/valve/can_crawl_through()
	return open

/obj/machinery/atmospherics/components/unary/vent_pump/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/components/unary/vent_scrubber/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/components/binary/valve/can_crawl_through()
	return open

/obj/machinery/atmospherics/proc/findConnecting(direction)
	for(var/obj/machinery/atmospherics/target in get_step(src, direction))
		if(target.initialize_directions & get_dir(target, src))
			if(isConnectable(target) && target.isConnectable(src))
				return target

/obj/machinery/atmospherics/proc/isConnectable(obj/machinery/atmospherics/target)
	return nodes.Find(target)
