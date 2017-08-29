/*CONTENTS
Buildable pipes
Buildable meters
*/

/obj/item/pipe
	name = "pipe"
	desc = "A pipe."

	force = 7
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = ITEM_SIZE_NORMAL
	level = 2

	var/pipe_type = 0
	var/pipename
	var/connect_types = CONNECT_TYPE_REGULAR

/obj/item/pipe/New(loc, pipe_type, dir, obj/machinery/atmospherics/make_from)
	..()
	if (make_from)

		src.set_dir(make_from.dir)
		src.pipename = make_from.name
		color = make_from.pipe_color

		var/is_bent
		if (make_from.initialize_directions in list(NORTH|SOUTH, WEST|EAST))
			is_bent = FALSE
		else
			is_bent = TRUE

		if (istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction))
			src.pipe_type = PIPE_JUNCTION
			connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_HE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
			src.pipe_type = PIPE_HE_STRAIGHT + is_bent
			connect_types = CONNECT_TYPE_HE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/supply))
			src.pipe_type = PIPE_SUPPLY_STRAIGHT + is_bent
			connect_types = CONNECT_TYPE_SUPPLY
			src.color = PIPE_COLOR_BLUE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/scrubbers))
			src.pipe_type = PIPE_SCRUBBERS_STRAIGHT + is_bent
			connect_types = CONNECT_TYPE_SCRUBBER
			src.color = PIPE_COLOR_RED
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/fuel) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/fuel))
			src.pipe_type = PIPE_FUEL_STRAIGHT + is_bent
			src.color = PIPE_COLOR_ORANGE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/visible/universal) || istype(make_from, /obj/machinery/atmospherics/pipe/simple/hidden/universal))
			src.pipe_type = PIPE_UNIVERSAL
			connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SUPPLY|CONNECT_TYPE_SCRUBBER
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple))
			src.pipe_type = PIPE_SIMPLE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/portables_connector))
			src.pipe_type = PIPE_CONNECTOR
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold/hidden/supply))
			src.pipe_type = PIPE_SUPPLY_MANIFOLD
			connect_types = CONNECT_TYPE_SUPPLY
			src.color = PIPE_COLOR_BLUE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers))
			src.pipe_type = PIPE_SCRUBBERS_MANIFOLD
			connect_types = CONNECT_TYPE_SCRUBBER
			src.color = PIPE_COLOR_RED
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold))
			src.pipe_type = PIPE_MANIFOLD
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold/visible/fuel) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold/hidden/fuel))
			src.pipe_type = PIPE_FUEL_MANIFOLD
			src.color = PIPE_COLOR_ORANGE
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_pump))
			src.pipe_type = PIPE_UVENT
		else if(istype(make_from, /obj/machinery/atmospherics/valve/shutoff))
			src.pipe_type = PIPE_SVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/valve/digital))
			src.pipe_type = PIPE_DVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/valve))
			src.pipe_type = PIPE_MVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/pump/high_power))
			src.pipe_type = PIPE_VOLUME_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/binary/pump))
			src.pipe_type = PIPE_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/filter/m_filter))
			src.pipe_type = PIPE_GAS_FILTER_M
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer/t_mixer))
			src.pipe_type = PIPE_GAS_MIXER_T
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer/m_mixer))
			src.pipe_type = PIPE_GAS_MIXER_M
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/filter))
			src.pipe_type = PIPE_GAS_FILTER
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer))
			src.pipe_type = PIPE_GAS_MIXER
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_scrubber))
			src.pipe_type = PIPE_SCRUBBER
		else if(istype(make_from, /obj/machinery/atmospherics/binary/passive_gate))
			src.pipe_type = PIPE_PASSIVE_GATE
		else if(istype(make_from, /obj/machinery/atmospherics/unary/heat_exchanger))
			src.pipe_type = PIPE_HEAT_EXCHANGE
		else if(istype(make_from, /obj/machinery/atmospherics/tvalve/mirrored))
			src.pipe_type = PIPE_MTVALVEM
		else if(istype(make_from, /obj/machinery/atmospherics/tvalve))
			src.pipe_type = PIPE_MTVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/hidden/supply))
			src.pipe_type = PIPE_SUPPLY_MANIFOLD4W
			connect_types = CONNECT_TYPE_SUPPLY
			src.color = PIPE_COLOR_BLUE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers))
			src.pipe_type = PIPE_SCRUBBERS_MANIFOLD4W
			connect_types = CONNECT_TYPE_SCRUBBER
			src.color = PIPE_COLOR_RED
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/visible/fuel) || istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w/hidden/fuel))
			src.pipe_type = PIPE_FUEL_MANIFOLD4W
			src.color = PIPE_COLOR_ORANGE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold4w))
			src.pipe_type = PIPE_MANIFOLD4W
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap/visible/supply) || istype(make_from, /obj/machinery/atmospherics/pipe/cap/hidden/supply))
			src.pipe_type = PIPE_SUPPLY_CAP
			connect_types = CONNECT_TYPE_SUPPLY
			src.color = PIPE_COLOR_BLUE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap/visible/scrubbers) || istype(make_from, /obj/machinery/atmospherics/pipe/cap/hidden/scrubbers))
			src.pipe_type = PIPE_SCRUBBERS_CAP
			connect_types = CONNECT_TYPE_SCRUBBER
			src.color = PIPE_COLOR_RED
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap/visible/fuel) || istype(make_from, /obj/machinery/atmospherics/pipe/cap/hidden/fuel))
			src.pipe_type = PIPE_FUEL_CAP
			src.color = PIPE_COLOR_ORANGE
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/cap))
			src.pipe_type = PIPE_CAP
		else if(istype(make_from, /obj/machinery/atmospherics/omni/mixer))
			src.pipe_type = PIPE_OMNI_MIXER
		else if(istype(make_from, /obj/machinery/atmospherics/omni/filter))
			src.pipe_type = PIPE_OMNI_FILTER
	else
		src.pipe_type = pipe_type
		src.set_dir(dir)
		if (pipe_type == PIPE_SUPPLY_STRAIGHT || pipe_type == PIPE_SUPPLY_BENT || pipe_type == PIPE_SUPPLY_MANIFOLD || pipe_type == PIPE_SUPPLY_MANIFOLD4W || pipe_type == PIPE_SUPPLY_CAP)
			connect_types = CONNECT_TYPE_SUPPLY
			src.color = PIPE_COLOR_BLUE
		else if (pipe_type == PIPE_SCRUBBERS_STRAIGHT || pipe_type == PIPE_SCRUBBERS_BENT || pipe_type == PIPE_SCRUBBERS_MANIFOLD || pipe_type == PIPE_SCRUBBERS_MANIFOLD4W || pipe_type == PIPE_SCRUBBERS_CAP)
			connect_types = CONNECT_TYPE_SCRUBBER
			src.color = PIPE_COLOR_RED
		else if (pipe_type == PIPE_FUEL_STRAIGHT || pipe_type == PIPE_FUEL_BENT || pipe_type == PIPE_FUEL_MANIFOLD || pipe_type == PIPE_FUEL_MANIFOLD4W || pipe_type == PIPE_FUEL_CAP)
			src.color = PIPE_COLOR_ORANGE
		else if (pipe_type == PIPE_HE_STRAIGHT || pipe_type == PIPE_HE_BENT)
			connect_types = CONNECT_TYPE_HE
		else if (pipe_type == PIPE_JUNCTION)
			connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_HE
		else if (pipe_type == PIPE_UNIVERSAL)
			connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SUPPLY|CONNECT_TYPE_SCRUBBER

	update()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type

/obj/item/pipe/proc/update()
	var/list/nlist = list(
		"pipe",
		"bent pipe",
		"h/e pipe",
		"bent h/e pipe",
		"connector",
		"manifold",
		"junction",
		"uvent",
		"manual valve",
		"digital valve",
		"pump",
		"scrubber",
		"unused",
		"gas filter",
		"gas mixer",
		"pressure regulator",
		"high power pump",
		"heat exchanger",
		"t-valve",
		"4-way manifold",
		"pipe cap",
///// Z-Level stuff (list index hardcoded stuff - remove those, and everything will be broken, requires to rewrite or smth).
		"pipe up",
		"pipe down",
///// Z-Level stuff
		"gas filter m",
		"gas mixer t",
		"gas mixer m",
		"omni mixer",
		"omni filter",
///// Supply and scrubbers pipes
		"universal pipe adapter",
		"supply pipe",
		"bent supply pipe",
		"scrubbers pipe",
		"bent scrubbers pipe",
		"supply manifold",
		"scrubbers manifold",
		"supply 4-way manifold",
		"scrubbers 4-way manifold",
		"supply pipe up",
		"scrubbers pipe up",
		"supply pipe down",
		"scrubbers pipe down",
		"supply pipe cap",
		"scrubbers pipe cap",
		"t-valve m",
		"shutoff valve",
///// Fuel pipes
		"fuel pipe",
		"bent fuel pipe",
		"fuel manifold",
		"fuel 4-way manifold",
		"fuel pipe up",
		"fuel down",
		"fuel pipe cap",
	)
	name = nlist[pipe_type + 1] + " fitting"
	var/list/islist = list(
		"simple",
		"simple",
		"he",
		"he",
		"connector",
		"manifold",
		"junction",
		"uvent",
		"mvalve",
		"dvalve",
		"pump",
		"scrubber",
		"unused",
		"filter",
		"mixer",
		"passivegate",
		"volumepump",
		"heunary",
		"mtvalve",
		"manifold4w",
		"cap",
///// Z-Level stuff
		"cap",
		"cap",
///// Z-Level stuff
		"m_filter",
		"t_mixer",
		"m_mixer",
		"omni_mixer",
		"omni_filter",
///// Supply and scrubbers pipes
		"universal",
		"simple",
		"simple",
		"simple",
		"simple",
		"manifold",
		"manifold",
		"manifold4w",
		"manifold4w",
		"cap",
		"cap",
		"cap",
		"cap",
		"cap",
		"cap",
		"mtvalvem",
		"svalve",
///// Fuel pipes
		"simple",
		"simple",
		"manifold",
		"manifold4w",
		"cap",
		"cap",
		"cap",
	)
	icon_state = islist[pipe_type + 1]

//called when a turf is attacked with a pipe item

//called when a turf is attacked with a pipe item
/obj/item/pipe/afterattack(turf/simulated/floor/target, mob/user, proximity)
	if(!proximity)
		return

	if(istype(target))
		user.drop_from_inventory(src, target)
	else
		return ..()

// rotate the pipe item clockwise

/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() )
		return

	set_dir(turn(dir, -90))

	if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_UNIVERSAL, PIPE_HE_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE, PIPE_SVALVE, PIPE_FUEL_STRAIGHT))
		if(dir == SOUTH)
			set_dir(NORTH)
		else if(dir == WEST)
			set_dir(EAST)
	else if (pipe_type in list (PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W, PIPE_FUEL_MANIFOLD4W))
		set_dir(SOUTH)

/obj/item/pipe/Move()
	..()
	if ((pipe_type in list (PIPE_SIMPLE_BENT, PIPE_SUPPLY_BENT, PIPE_SCRUBBERS_BENT, PIPE_HE_BENT, PIPE_FUEL_BENT)) && (dir in cardinal))
		set_dir(dir|turn(dir, 90))
	else if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_UNIVERSAL, PIPE_HE_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE, PIPE_SVALVE, PIPE_FUEL_STRAIGHT))
		if(dir == SOUTH)
			set_dir(NORTH)
		else if(dir == WEST)
			set_dir(EAST)

// returns all pipe's endpoints

/obj/item/pipe/proc/get_pipe_dir()
	if (!dir)
		return 0

	var/flip = turn(dir, 180)
	var/cw = turn(dir, -90)
	var/acw = turn(dir, 90)

	switch(pipe_type)
		if(	PIPE_SIMPLE_STRAIGHT,
			PIPE_HE_STRAIGHT,
			PIPE_JUNCTION,
			PIPE_PUMP,
			PIPE_VOLUME_PUMP,
			PIPE_PASSIVE_GATE,
			PIPE_MVALVE,
			PIPE_DVALVE,
			PIPE_SVALVE,
			PIPE_SUPPLY_STRAIGHT,
			PIPE_SCRUBBERS_STRAIGHT,
			PIPE_UNIVERSAL,
			PIPE_FUEL_STRAIGHT,
		)
			return dir|flip
		if(PIPE_SIMPLE_BENT, PIPE_HE_BENT, PIPE_SUPPLY_BENT, PIPE_SCRUBBERS_BENT, PIPE_FUEL_BENT)
			return dir //dir|acw
		if(PIPE_CONNECTOR, PIPE_UVENT, PIPE_SCRUBBER, PIPE_HEAT_EXCHANGE)
			return dir
		if(PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W, PIPE_OMNI_MIXER, PIPE_OMNI_FILTER, PIPE_FUEL_MANIFOLD4W)
			return dir|flip|cw|acw
		if(PIPE_MANIFOLD, PIPE_SUPPLY_MANIFOLD, PIPE_SCRUBBERS_MANIFOLD, PIPE_FUEL_MANIFOLD)
			return flip|cw|acw
		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER, PIPE_MTVALVE)
			return dir|flip|cw
		if(PIPE_GAS_FILTER_M, PIPE_GAS_MIXER_M, PIPE_MTVALVEM)
			return dir|flip|acw
		if(PIPE_GAS_MIXER_T)
			return dir|cw|acw
		if(PIPE_CAP, PIPE_SUPPLY_CAP, PIPE_SCRUBBERS_CAP, PIPE_FUEL_CAP)
			return dir
	return 0

/obj/item/pipe/proc/get_pdir() // endpoints for regular pipes

	var/flip = turn(dir, 180)

	if (!(pipe_type in list(PIPE_HE_STRAIGHT, PIPE_HE_BENT, PIPE_JUNCTION)))
		return get_pipe_dir()
	switch(pipe_type)
		if(PIPE_HE_STRAIGHT,PIPE_HE_BENT)
			return 0
		if(PIPE_JUNCTION)
			return flip
	return 0

/obj/item/pipe/proc/get_hdir() // endpoints for h/e pipes

	switch(pipe_type)
		if(PIPE_HE_STRAIGHT)
			return get_pipe_dir()
		if(PIPE_HE_BENT)
			return get_pipe_dir()
		if(PIPE_JUNCTION)
			return dir
		else
			return 0

/obj/item/pipe/attack_self(mob/user)
	return rotate()

/obj/item/pipe/attackby(obj/item/weapon/W, mob/user)
	..()
	//*
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!isturf(loc))
		return TRUE
	if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_SUPPLY_STRAIGHT, PIPE_SCRUBBERS_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_MVALVE, PIPE_DVALVE, PIPE_SVALVE, PIPE_FUEL_STRAIGHT))
		if(dir == SOUTH)
			set_dir(NORTH)
		else if(dir == WEST)
			set_dir(EAST)
	else if (pipe_type in list(PIPE_MANIFOLD4W, PIPE_SUPPLY_MANIFOLD4W, PIPE_SCRUBBERS_MANIFOLD4W, PIPE_OMNI_MIXER, PIPE_OMNI_FILTER, PIPE_FUEL_MANIFOLD4W))
		set_dir(SOUTH)

	var/pipe_dir = get_pipe_dir()

	for(var/obj/machinery/atmospherics/M in loc)
		if((M.initialize_directions & pipe_dir) && M.check_connect_types_construction(M, src))	// matches at least one direction on either type of pipe & same connection type
			to_chat(user, "<span class='warning'>There is already a pipe of the same type at this location.</span>")
			return TRUE
	// no conflicts found

	var/pipefailtext = "<span class='warning'>There's nothing to connect this pipe section to!</span>" //(with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"

	//TODO: Move all of this stuff into the various pipe constructors.
	switch(pipe_type)
		if(PIPE_SIMPLE_STRAIGHT, PIPE_SIMPLE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/P = new(loc)
			P.pipe_color = color
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()

			if (QDELETED(P))
				to_chat(usr, pipefailtext)
				return TRUE

			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_SUPPLY_STRAIGHT, PIPE_SUPPLY_BENT)
			var/obj/machinery/atmospherics/pipe/simple/hidden/supply/P = new(loc)
			P.color = color
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()

			if (QDELETED(P))
				to_chat(usr, pipefailtext)
				return TRUE

			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_SCRUBBERS_STRAIGHT, PIPE_SCRUBBERS_BENT)
			var/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers/P = new(loc)
			P.color = color
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()

			if (QDELETED(P))
				to_chat(usr, pipefailtext)
				return TRUE

			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_FUEL_STRAIGHT, PIPE_FUEL_BENT)
			var/obj/machinery/atmospherics/pipe/simple/hidden/fuel/P = new(loc)
			P.color = color
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()

			if (QDELETED(P))
				to_chat(usr, pipefailtext)
				return TRUE

			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_UNIVERSAL)
			var/obj/machinery/atmospherics/pipe/simple/hidden/universal/P = new(loc)
			P.color = color
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()

			if (QDELETED(P))
				to_chat(usr, pipefailtext)
				return TRUE

			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_HE_STRAIGHT, PIPE_HE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/P = new (loc)
			P.set_dir(dir)
			P.initialize_directions = pipe_dir //this var it's used to know if the pipe is bent or not
			P.initialize_directions_he = pipe_dir
			P.atmos_init()

			if (QDELETED(P))
				to_chat(usr, pipefailtext)
				return TRUE

			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_CONNECTOR)		// connector
			var/obj/machinery/atmospherics/portables_connector/C = new(loc)
			C.set_dir(dir)
			C.initialize_directions = pipe_dir

			if (pipename)
				C.name = pipename

			var/turf/T = C.loc
			C.level = !T.is_plating() ? 2 : 1
			C.atmos_init()
			C.build_network()

			if (C.node)
				C.node.atmos_init()
				C.node.build_network()


		if(PIPE_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/M = new(loc)
			M.pipe_color = color
			M.set_dir(dir)
			M.initialize_directions = pipe_dir

			var/turf/T = M.loc
			M.level = !T.is_plating() ? 2 : 1
			M.atmos_init()

			if (QDELETED(M))
				to_chat(usr, pipefailtext)
				return TRUE

			M.build_network()

			if (M.node1)
				M.node1.atmos_init()
				M.node1.build_network()
			if (M.node2)
				M.node2.atmos_init()
				M.node2.build_network()
			if (M.node3)
				M.node3.atmos_init()
				M.node3.build_network()

		if(PIPE_SUPPLY_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/hidden/supply/M = new(loc)
			M.color = color
			M.set_dir(dir)
			M.initialize_directions = pipe_dir

			var/turf/T = M.loc
			M.level = !T.is_plating() ? 2 : 1
			M.atmos_init()

			if (!M)
				to_chat(usr, "There's nothing to connect this manifold to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)")
				return TRUE

			M.build_network()

			if (M.node1)
				M.node1.atmos_init()
				M.node1.build_network()
			if (M.node2)
				M.node2.atmos_init()
				M.node2.build_network()
			if (M.node3)
				M.node3.atmos_init()
				M.node3.build_network()

		if(PIPE_SCRUBBERS_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers/M = new(loc)
			M.color = color
			M.set_dir(dir)
			M.initialize_directions = pipe_dir

			var/turf/T = M.loc
			M.level = !T.is_plating() ? 2 : 1
			M.atmos_init()

			if (!M)
				to_chat(usr, "There's nothing to connect this manifold to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)")
				return TRUE

			M.build_network()

			if (M.node1)
				M.node1.atmos_init()
				M.node1.build_network()
			if (M.node2)
				M.node2.atmos_init()
				M.node2.build_network()
			if (M.node3)
				M.node3.atmos_init()
				M.node3.build_network()

		if(PIPE_FUEL_MANIFOLD)		//manifold
			var/obj/machinery/atmospherics/pipe/manifold/hidden/fuel/M = new(loc)
			M.color = color
			M.set_dir(dir)
			M.initialize_directions = pipe_dir

			var/turf/T = M.loc
			M.level = !T.is_plating() ? 2 : 1
			M.atmos_init()

			if (!M)
				to_chat(usr, "There's nothing to connect this manifold to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)")
				return TRUE

			M.build_network()

			if (M.node1)
				M.node1.atmos_init()
				M.node1.build_network()
			if (M.node2)
				M.node2.atmos_init()
				M.node2.build_network()
			if (M.node3)
				M.node3.atmos_init()
				M.node3.build_network()

		if(PIPE_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/M = new(loc)
			M.pipe_color = color
			M.set_dir(dir)
			M.initialize_directions = pipe_dir

			var/turf/T = M.loc
			M.level = !T.is_plating() ? 2 : 1
			M.atmos_init()

			if (QDELETED(M))
				to_chat(usr, pipefailtext)
				return TRUE

			M.build_network()

			if (M.node1)
				M.node1.atmos_init()
				M.node1.build_network()
			if (M.node2)
				M.node2.atmos_init()
				M.node2.build_network()
			if (M.node3)
				M.node3.atmos_init()
				M.node3.build_network()
			if (M.node4)
				M.node4.atmos_init()
				M.node4.build_network()

		if(PIPE_SUPPLY_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply/M = new(loc)
			M.color = color
			M.set_dir(dir)
			M.initialize_directions = pipe_dir
			M.connect_types = src.connect_types

			var/turf/T = M.loc
			M.level = !T.is_plating() ? 2 : 1
			M.atmos_init()

			if (!M)
				to_chat(usr, "There's nothing to connect this manifold to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)")
				return TRUE

			M.build_network()

			if (M.node1)
				M.node1.atmos_init()
				M.node1.build_network()
			if (M.node2)
				M.node2.atmos_init()
				M.node2.build_network()
			if (M.node3)
				M.node3.atmos_init()
				M.node3.build_network()
			if (M.node4)
				M.node4.atmos_init()
				M.node4.build_network()

		if(PIPE_SCRUBBERS_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers/M = new(loc)
			M.color = color
			M.set_dir(dir)
			M.initialize_directions = pipe_dir
			M.connect_types = src.connect_types

			var/turf/T = M.loc
			M.level = !T.is_plating() ? 2 : 1
			M.atmos_init()

			if (!M)
				to_chat(usr, "There's nothing to connect this manifold to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)")
				return TRUE

			M.build_network()

			if (M.node1)
				M.node1.atmos_init()
				M.node1.build_network()
			if (M.node2)
				M.node2.atmos_init()
				M.node2.build_network()
			if (M.node3)
				M.node3.atmos_init()
				M.node3.build_network()
			if (M.node4)
				M.node4.atmos_init()
				M.node4.build_network()

		if(PIPE_FUEL_MANIFOLD4W)		//4-way manifold
			var/obj/machinery/atmospherics/pipe/manifold4w/hidden/fuel/M = new(loc)
			M.color = color
			M.set_dir(dir)
			M.initialize_directions = pipe_dir
			M.connect_types = src.connect_types

			var/turf/T = M.loc
			M.level = !T.is_plating() ? 2 : 1
			M.atmos_init()

			if (!M)
				to_chat(usr, "There's nothing to connect this manifold to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)")
				return TRUE

			M.build_network()

			if (M.node1)
				M.node1.atmos_init()
				M.node1.build_network()
			if (M.node2)
				M.node2.atmos_init()
				M.node2.build_network()
			if (M.node3)
				M.node3.atmos_init()
				M.node3.build_network()
			if (M.node4)
				M.node4.atmos_init()
				M.node4.build_network()

		if(PIPE_JUNCTION)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/P = new (loc)
			P.set_dir(src.dir)
			P.initialize_directions = src.get_pdir()
			P.initialize_directions_he = src.get_hdir()
			P.atmos_init()

			if (QDELETED(P))
				to_chat(usr, pipefailtext)//"There's nothing to connect this pipe to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"
				return TRUE

			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_UVENT)		//unary vent
			var/obj/machinery/atmospherics/unary/vent_pump/V = new(loc)
			V.set_dir(dir)
			V.initialize_directions = pipe_dir

			if (pipename)
				V.name = pipename

			var/turf/T = V.loc
			V.level = !T.is_plating() ? 2 : 1
			V.atmos_init()
			V.build_network()

			if (V.node)
				V.node.atmos_init()
				V.node.build_network()


		if(PIPE_MVALVE)		//manual valve
			var/obj/machinery/atmospherics/valve/V = new(loc)
			V.set_dir(dir)
			V.initialize_directions = pipe_dir

			if (pipename)
				V.name = pipename

			var/turf/T = V.loc
			V.level = !T.is_plating() ? 2 : 1
			V.atmos_init()
			V.build_network()

			if (V.node1)
//				log_error("[V.node1.name] is connected to valve, forcing it to update its nodes.")
				V.node1.atmos_init()
				V.node1.build_network()
			if (V.node2)
//				log_error("[V.node2.name] is connected to valve, forcing it to update its nodes.")
				V.node2.atmos_init()
				V.node2.build_network()

		if(PIPE_DVALVE)		//digital valve
			var/obj/machinery/atmospherics/valve/digital/D = new(loc)
			D.set_dir(dir)
			D.initialize_directions = pipe_dir

			if (pipename)
				D.name = pipename

			var/turf/T = D.loc
			D.level = !T.is_plating() ? 2 : 1
			D.atmos_init()
			D.build_network()

			if (D.node1)
				D.node1.atmos_init()
				D.node1.build_network()
			if (D.node2)
				D.node2.atmos_init()
				D.node2.build_network()

		if(PIPE_SVALVE)		//shutoff valve
			var/obj/machinery/atmospherics/valve/shutoff/S = new(loc)
			S.set_dir(dir)
			S.initialize_directions = pipe_dir

			if (pipename)
				S.name = pipename

			var/turf/T = S.loc
			S.level = !T.is_plating() ? 2 : 1
			S.atmos_init()
			S.build_network()

			if (S.node1)
				S.node1.atmos_init()
				S.node1.build_network()
			if (S.node2)
				S.node2.atmos_init()
				S.node2.build_network()


		if(PIPE_PUMP)		//gas pump
			var/obj/machinery/atmospherics/binary/pump/P = new(loc)
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			if (pipename)
				P.name = pipename

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_GAS_FILTER)		//gas filter
			var/obj/machinery/atmospherics/trinary/filter/P = new(loc)
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			if (pipename)
				P.name = pipename

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()
			if (P.node3)
				P.node3.atmos_init()
				P.node3.build_network()

		if(PIPE_GAS_MIXER)		//gas mixer
			var/obj/machinery/atmospherics/trinary/mixer/P = new(loc)
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			if (pipename)
				P.name = pipename

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()
			if (P.node3)
				P.node3.atmos_init()
				P.node3.build_network()

		if(PIPE_GAS_FILTER_M)		//gas filter mirrored
			var/obj/machinery/atmospherics/trinary/filter/m_filter/P = new(loc)
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			if (pipename)
				P.name = pipename

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()
			if (P.node3)
				P.node3.atmos_init()
				P.node3.build_network()

		if(PIPE_GAS_MIXER_T)		//gas mixer-t
			var/obj/machinery/atmospherics/trinary/mixer/t_mixer/P = new(loc)
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			if (pipename)
				P.name = pipename

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()
			if (P.node3)
				P.node3.atmos_init()
				P.node3.build_network()

		if(PIPE_GAS_MIXER_M)		//gas mixer mirrored
			var/obj/machinery/atmospherics/trinary/mixer/m_mixer/P = new(loc)
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			if (pipename)
				P.name = pipename

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()
			if (P.node3)
				P.node3.atmos_init()
				P.node3.build_network()

		if(PIPE_SCRUBBER)		//scrubber
			var/obj/machinery/atmospherics/unary/vent_scrubber/S = new(loc)
			S.set_dir(dir)
			S.initialize_directions = pipe_dir

			if (pipename)
				S.name = pipename

			var/turf/T = S.loc
			S.level = !T.is_plating() ? 2 : 1
			S.atmos_init()
			S.build_network()

			if (S.node)
				S.node.atmos_init()
				S.node.build_network()

		if(PIPE_MTVALVE)		//manual t-valve
			var/obj/machinery/atmospherics/tvalve/V = new(loc)
			V.set_dir(dir)
			V.initialize_directions = pipe_dir

			if (pipename)
				V.name = pipename

			var/turf/T = V.loc
			V.level = !T.is_plating() ? 2 : 1
			V.atmos_init()
			V.build_network()

			if (V.node1)
				V.node1.atmos_init()
				V.node1.build_network()
			if (V.node2)
				V.node2.atmos_init()
				V.node2.build_network()
			if (V.node3)
				V.node3.atmos_init()
				V.node3.build_network()

		if(PIPE_MTVALVEM)		//manual t-valve
			var/obj/machinery/atmospherics/tvalve/mirrored/V = new(loc)
			V.set_dir(dir)
			V.initialize_directions = pipe_dir

			if (pipename)
				V.name = pipename

			var/turf/T = V.loc
			V.level = !T.is_plating() ? 2 : 1
			V.atmos_init()
			V.build_network()

			if (V.node1)
				V.node1.atmos_init()
				V.node1.build_network()
			if (V.node2)
				V.node2.atmos_init()
				V.node2.build_network()
			if (V.node3)
				V.node3.atmos_init()
				V.node3.build_network()

		if(PIPE_CAP)
			var/obj/machinery/atmospherics/pipe/cap/C = new(loc)
			C.set_dir(dir)
			C.initialize_directions = pipe_dir
			C.atmos_init()
			C.build_network()

			if(C.node)
				C.node.atmos_init()
				C.node.build_network()

		if(PIPE_SUPPLY_CAP)
			var/obj/machinery/atmospherics/pipe/cap/hidden/supply/C = new(loc)
			C.set_dir(dir)
			C.initialize_directions = pipe_dir
			C.atmos_init()
			C.build_network()

			if(C.node)
				C.node.atmos_init()
				C.node.build_network()

		if(PIPE_SCRUBBERS_CAP)
			var/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers/C = new(loc)
			C.set_dir(dir)
			C.initialize_directions = pipe_dir
			C.atmos_init()
			C.build_network()

			if(C.node)
				C.node.atmos_init()
				C.node.build_network()

		if(PIPE_FUEL_CAP)
			var/obj/machinery/atmospherics/pipe/cap/hidden/fuel/C = new(loc)
			C.set_dir(dir)
			C.initialize_directions = pipe_dir
			C.atmos_init()
			C.build_network()

			if(C.node)
				C.node.atmos_init()
				C.node.build_network()

		if(PIPE_PASSIVE_GATE)		//passive gate
			var/obj/machinery/atmospherics/binary/passive_gate/P = new(loc)
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			if (pipename)
				P.name = pipename

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_VOLUME_PUMP)		//volume pump
			var/obj/machinery/atmospherics/binary/pump/high_power/P = new(loc)
			P.set_dir(dir)
			P.initialize_directions = pipe_dir

			if (pipename)
				P.name = pipename

			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()

			if (P.node1)
				P.node1.atmos_init()
				P.node1.build_network()
			if (P.node2)
				P.node2.atmos_init()
				P.node2.build_network()

		if(PIPE_HEAT_EXCHANGE)		// heat exchanger
			var/obj/machinery/atmospherics/unary/heat_exchanger/C = new(loc )
			C.set_dir(dir)
			C.initialize_directions = pipe_dir

			if (pipename)
				C.name = pipename

			var/turf/T = C.loc
			C.level = !T.is_plating() ? 2 : 1
			C.atmos_init()
			C.build_network()

			if (C.node)
				C.node.atmos_init()
				C.node.build_network()

		if(PIPE_OMNI_MIXER)
			var/obj/machinery/atmospherics/omni/mixer/P = new(loc)
			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()
		if(PIPE_OMNI_FILTER)
			var/obj/machinery/atmospherics/omni/filter/P = new(loc)
			var/turf/T = P.loc
			P.level = !T.is_plating() ? 2 : 1
			P.atmos_init()
			P.build_network()

	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user.visible_message(
		"[user] fastens the [src].",
		"<span class='notice'>You have fastened the [src].</span>",
		"You hear ratchet.")
	qdel(src)	// remove the pipe item

	return
	 //TODO: DEFERRED

// ensure that setterm() is called for a newly connected pipeline



/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes."
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = 4

/obj/item/pipe_meter/attackby(obj/item/weapon/W, mob/user)
	..()

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!locate(/obj/machinery/atmospherics/pipe, src.loc))
		to_chat(user, "<span class='warning'>You need to fasten it to a pipe</span>")
		return TRUE

	new/obj/machinery/meter( src.loc )
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You have fastened the meter to the pipe</span>")
	qdel(src)
