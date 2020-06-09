#define MOVE_TO_POS_DELAY 3

// Is called on carry_obj Ctrl+Shift click. Does a waddle.
#define DANCE_MOVE_CARRYWADDLE "carrywaddle"
// Is called on Ctrl+Shift click on fellow carrier. Rotates everybody's positions. TO-DO: Make the rotation direction depend on clicker's direction?
#define DANCE_MOVE_ROTATE      "rotate"
// Is called on Ctrl click on fellow carrier. Swaps user with the carrier they clicked on.
#define DANCE_MOVE_SWAP        "swap"

// This proc is needed to update layers, offsets and etc when a buckled mob is being carried with us.
// TO-DO: Replace with getters setters for: layer, pixel_x, pixel_y
/atom/movable/proc/update_buckle_mob(mob/living/L)
	return

// This datum contains all info, and checks needed by multi_carry "dance move" integration.
/datum/dance_move
	var/name = null

/datum/dance_move/proc/can_perform(mob/user, atom/target, datum/component/multi_carry/carry)
	return FALSE



/datum/dance_move/coffin/proc/check_shoes(mob/living/carbon/human/carrier)
	if(!istype(carrier))
		return FALSE
	return istype(carrier.shoes, /obj/item/clothing/shoes/jolly_gravedigger)

/datum/dance_move/coffin/carrywaddle
	name = DANCE_MOVE_CARRYWADDLE

/datum/dance_move/coffin/carrywaddle/can_perform(mob/user, atom/target, datum/component/multi_carry/carry)
	return check_shoes(user)

/datum/dance_move/coffin/rotate
	name = DANCE_MOVE_ROTATE

/datum/dance_move/coffin/rotate/can_perform(mob/user, atom/target, datum/component/multi_carry/carry)
	for(var/c in carry.carriers)
		if(!check_shoes(c))
			return FALSE
	return TRUE

/datum/dance_move/coffin/swap
	name = DANCE_MOVE_SWAP

/datum/dance_move/coffin/swap/can_perform(mob/user, atom/target, datum/component/multi_carry/carry)
	return check_shoes(user) && check_shoes(target)



// The datum to contain any information about carry positions for
// /datum/component/multi_carry
/datum/carry_positions
	// Assoc list of form: dir = list(list(px,py,addlayer), list(px,py,layer), ...)
	var/pos_count
	// If set to true will never rotate dirs.
	var/one_dir = FALSE
	var/list/positions_by_dir

/datum/carry_positions/proc/get_pos(dir, i)
	return positions_by_dir["[dir]"][i]

/datum/carry_positions/coffin_four_man
	pos_count = 4
	one_dir = TRUE
	// NORTH: 1 2
	//        4 3
	// SOUTH: 3 4
	//        2 1
	// WEST:  2 3
	//        1 4
	// EAST:  4 1
	//        3 2

/datum/carry_positions/coffin_four_man/New()
	positions_by_dir = list()

	/*
	commented here in case coffins become multidirectional.

	positions_by_dir["[NORTH]"] = list(
		list(-10, 14, 0.0),
		list(10, 14, 0.0),
		list(-10, -10, 0.1),
		list(10, -10, 0.1)
	)
	positions_by_dir["[SOUTH]"] = list(
		list(10, -10, 0.0),
		list(-10, -10, 0.0),
		list(10, 14, 0.1),
		list(-10, 140, 0.1)
	)
	positions_by_dir["[WEST]"] = list(
		list(-14, -5, 0.0),
		list(-14, 9, 0.0),
		list(14, -5, 0.1),
		list(14, 9, 0.1)
	)
	positions_by_dir["[EAST]"] = list(
		list(14, 9, 0.0),
		list(14, -5, 0.0),
		list(-14, 9, 0.1),
		list(-14, -5, 0.1)
	)
	*/
	for(var/dir_ in cardinal)
		// Carefully crafted precision MAGIC NUMBERS to aid in B E A U T Y.
		// FLY_LAYER + 0.5 is to make sure they are above coffin_side, and the mob in coffin
		positions_by_dir["[dir_]"] = list(
			list("px"=13, "py"=-6, "layer"=FLY_LAYER + 0.5),
			list("px"=-12, "py"=-6, "layer"=FLY_LAYER + 0.5),
			list("px"=-14, "py"=6, "layer"=MOB_LAYER),
			list("px"=15, "py"=6, "layer"=MOB_LAYER),
		)

#define MULTI_CARRY_TIP "Is carriable."

/datum/mechanic_tip/multi_carry
	tip_name = MULTI_CARRY_TIP

/datum/mechanic_tip/multi_carry/New(datum/component/multi_carry/MC)
	var/positions_desc = ""
	var/dances_desc = ""

	var/datum/carry_positions/CP = MC.positions
	positions_desc = "Carry requires [CP.pos_count] people to pull on [MC.carry_obj] simultaneously. "

	if(MC.dance_moves)
		dances_desc = "There are several \"moves\" that can be performed, if appropriate conditions are met."

	description = "This object appears to be carriable. [positions_desc][dances_desc]"



// A component you put on things you want to be bounded to other things.
// Warning! Can only be bounded to one thing at once.
/datum/component/multi_carry
	// This var is used to determine whether carry_obj is currently carried.
	var/carried = FALSE
	// The object that is multi-carried.
	var/atom/movable/carry_obj
	// List of being that carry carry_obj.
	var/list/carriers
	// Assoc list of carrier_ref = list("px"=..., "py"=..., "pz"=..., "layer"=...)
	// Contains data about carry_obj, carriers, carry_obj.buckled
	var/list/carrier_default_pos

	// Whether this entire "structure" is moving due to carrier.
	var/moving = FALSE
	// This var is used to prevent unnecessary position updates.
	var/prev_dir = NORTH
	// When the next move can occur.
	var/next_move = 0
	// So the carry_obj won't waddle 1 * N(carriers am)
	var/next_waddle = 0

	// The pixel_z carry_obj will get, when it starts being carried.
	var/carry_pixel_z = 0
	// Whether a buckled mob's dir should stay the same when carried.
	// The layer carry_obj will get, when it starts being carried. Commented out due to lack of need.
	// var/carry_layer = FLY_LAYER
	// The positions in which carriers should stand, when carrying carry_obj.
	var/datum/carry_positions/positions
	// A list of dance moves permitted by carry_obj
	var/list/datum/dance_move/dance_moves

/datum/component/multi_carry/Initialize(_carry_pixel_z, positions_type, list/dance_move_types)
	carry_obj = parent
	carry_pixel_z = _carry_pixel_z
	positions = new positions_type

	for(var/dance_type in dance_move_types)
		var/datum/dance_move/DM = new dance_type
		LAZYSET(dance_moves, DM.name, DM)

	RegisterSignal(carry_obj, list(COMSIG_ATOM_START_PULL), .proc/carrier_join)
	RegisterSignal(carry_obj, list(COMSIG_ATOM_STOP_PULL), .proc/carrier_leave)

	var/datum/mechanic_tip/clickplace/carry_tip = new(src)
	parent.AddComponent(/datum/component/mechanic_desc, list(carry_tip))

/datum/component/multi_carry/Destroy()
	if(carried)
		stop_carry()
	carry_obj = null
	QDEL_NULL(positions)
	QDEL_LIST_ASSOC_VAL(dance_moves)

	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(MULTI_CARRY_TIP))
	return ..()

// Whether the carry structure can indeed move.
/datum/component/multi_carry/proc/can_carry_move()
	return next_move <= world.time

// This proc is used to register all required signals on carrier.
/datum/component/multi_carry/proc/register_carrier(mob/carrier)
	RegisterSignal(carrier, list(COMSIG_LIVING_MOVE_PULLED), .proc/on_pull)
	RegisterSignal(carrier, list(COMSIG_CLIENTMOB_MOVE), .proc/carrier_move)
	RegisterSignal(carrier, list(COMSIG_CLIENTMOB_POSTMOVE), .proc/carrier_postmove)
	RegisterSignal(carrier, list(COMSIG_MOVABLE_MOVED), .proc/check_proximity)
	RegisterSignal(carrier, list(COMSIG_ATOM_CANPASS), .proc/check_canpass)
	// Prevents funny bugs from occuring.
	RegisterSignal(carrier, list(COMSIG_MOVABLE_TRY_GRAB), .proc/on_grabbed)
	RegisterSignal(carrier, list(COMSIG_MOVABLE_WADDLE), .proc/carrier_waddle)
	RegisterSignal(carrier, list(COMSIG_LIVING_CLICK_CTRL), .proc/on_ctrl_click)
	RegisterSignal(carrier, list(COMSIG_LIVING_CLICK_CTRL_SHIFT), .proc/on_ctrl_shift_click)

// This proc is used to unregister all signals from carrier.
/datum/component/multi_carry/proc/unregister_carrier(mob/carrier)
	UnregisterSignal(carrier, list(
		COMSIG_LIVING_MOVE_PULLED,
		COMSIG_CLIENTMOB_MOVE,
		COMSIG_CLIENTMOB_POSTMOVE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_CANPASS,
		COMSIG_MOVABLE_TRY_GRAB,
		COMSIG_MOVABLE_WADDLE,
		COMSIG_LIVING_CLICK_CTRL,
		COMSIG_LIVING_CLICK_CTRL_SHIFT,
	))

// This proc prevents move_pulling - cause that would break the carry apart.
/datum/component/multi_carry/proc/on_pull(datum/source, atom/movable/target)
	if(carried)
		return COMPONENT_PREVENT_MOVE_PULLED
	return NONE

// Animates movement for carrier to pos.
/datum/component/multi_carry/proc/move_to_pos(mob/carrier, list/pos)
	carrier.face_pixeldiff(carrier.pixel_x, carrier.pixel_y, pos["px"], pos["py"])

	animate(carrier, pixel_x=pos["px"], pixel_y=pos["py"], layer=pos["layer"], time=MOVE_TO_POS_DELAY)
	sleep(MOVE_TO_POS_DELAY)

	SEND_SIGNAL(carrier, COMSIG_MOVABLE_PIXELMOVE)

// This proc is used to change the positions of carriers when carry_obj is rotated.
/datum/component/multi_carry/proc/rotate_dir(dir_)
	if(!can_carry_move())
		return
	next_move = world.time + MOVE_TO_POS_DELAY

	var/i = 1
	for(var/mob/carrier in carriers)
		var/list/pos = positions.get_pos(carry_obj.dir, i)
		i++

		INVOKE_ASYNC(src, .proc/move_to_pos, carrier, pos)

// This proc is used to swap positions of two carriers.
/datum/component/multi_carry/proc/swap_positions(mob/carrier1, mob/carrier2)
	if(!can_carry_move())
		return
	var/pos1 = carriers.Find(carrier1)
	var/pos2 = carriers.Find(carrier2)

	carriers[pos1] = carrier2
	carriers[pos2] = carrier1

	INVOKE_ASYNC(src, .proc/move_to_pos, carrier1, positions.get_pos(prev_dir, pos2))
	INVOKE_ASYNC(src, .proc/move_to_pos, carrier2, positions.get_pos(prev_dir, pos1))

// This proc is used to swap positions of all carriers by a full rotation.
/datum/component/multi_carry/proc/rotate_positions(clockwise=TRUE)
	if(!can_carry_move())
		return

	var/list/new_carriers = list()
	if(clockwise)
		new_carriers += carriers[carriers.len]
		for(var/i in 1 to carriers.len - 1)
			new_carriers += carriers[i]
	else
		// "multi_carry" implies that there are at least 2 carriers.
		for(var/i in 2 to carriers.len)
			new_carriers += carriers[i]
		new_carriers += carriers[1]

	carriers = new_carriers
	rotate_dir(prev_dir)

// All checks before start_carry()
/datum/component/multi_carry/proc/can_carry()
	var/lying_am = 0

	for(var/mob/walker in carriers)
		if(!walker.canmove)
			return FALSE
		if(!isturf(walker.loc))
			return FALSE
		if(!in_range(walker, carry_obj))
			return FALSE
		if(walker.lying)
			lying_am++

	if(lying_am > 0 && lying_am != carriers.len)
		return FALSE
	return TRUE

/datum/component/multi_carry/proc/carrier_join(datum/source, mob/carrier)
	if(carried)
		return

	LAZYADD(carriers, carrier)

	if(carriers.len == positions.pos_count)
		if(can_carry())
			start_carry()
		else
			for(var/mob/walker in carriers)
				walker.stop_pulling(carry_obj)

/datum/component/multi_carry/proc/start_carry()
	var/i = 1
	prev_dir = carry_obj.dir
	for(var/mob/carrier in carriers)
		var/list/pos = positions.get_pos(carry_obj.dir, i)
		i++

		LAZYSET(carrier_default_pos, carrier, list(
			"px"=carrier.pixel_x,
			"py"=carrier.pixel_y,
			"layer"=carrier.layer
		))
		carrier.pixel_x = pos["px"]
		carrier.pixel_y = pos["py"]
		carrier.layer = pos["layer"]
		carrier.loc = carry_obj.loc

		register_carrier(carrier)

	LAZYSET(carrier_default_pos, carry_obj, list(
		"pz"=carry_obj.pixel_z,
		"layer"=carry_obj.layer
	))
	carry_obj.pixel_z = carry_obj.pixel_z + carry_pixel_z
	carry_obj.layer = FLY_LAYER
	if(carry_obj.buckled_mob)
		on_buckle(carry_obj, carry_obj.buckled_mob)

	RegisterSignal(carry_obj, list(COMSIG_ATOM_CANPASS), .proc/check_canpass)
	RegisterSignal(carry_obj, list(COMSIG_MOVABLE_MOVED), .proc/check_carriers)
	RegisterSignal(carry_obj, list(COMSIG_MOVABLE_BUCKLE), .proc/on_buckle)
	RegisterSignal(carry_obj, list(COMSIG_MOVABLE_UNBUCKLE), .proc/on_unbuckle)

	carried = TRUE

/datum/component/multi_carry/proc/carrier_leave(datum/source, mob/carrier)
	if(carried)
		stop_carry()
		return

	LAZYREMOVE(carriers, carrier)

/datum/component/multi_carry/proc/stop_carry()
	if(!carried)
		return
	carried = FALSE

	for(var/mob/carrier in carriers)
		var/list/pos = carrier_default_pos[carrier]
		carrier.pixel_x = pos["px"]
		carrier.pixel_y = pos["py"]
		carrier.layer = pos["layer"]
		LAZYREMOVE(carrier_default_pos, carrier)

		step(carrier, pick(alldirs))

		unregister_carrier(carrier)
		carrier.stop_pulling()

	UnregisterSignal(carry_obj, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_CANPASS,
		COMSIG_MOVABLE_BUCKLE,
		COMSIG_MOVABLE_UNBUCKLE
	))

	var/list/pos_obj = carrier_default_pos[carry_obj]
	carry_obj.pixel_z = pos_obj["pz"]
	carry_obj.layer = pos_obj["layer"]
	LAZYREMOVE(carrier_default_pos, carry_obj)
	if(carry_obj.buckled_mob)
		on_unbuckle(carry_obj, carry_obj.buckled_mob)

	carriers = null

/datum/component/multi_carry/proc/follow_carrier(atom/movable/walker, atom/NewLoc, direction)
	INVOKE_ASYNC(GLOBAL_PROC, .proc/_step, walker, direction)

/datum/component/multi_carry/proc/carrier_move(datum/source, atom/NewLoc, direction)
	if(next_move > world.time)
		return COMPONENT_CLIENTMOB_BLOCK_MOVE

	var/mob/carrier = source

	moving = TRUE
	// carrier_move is called via CLIENTMOB_MOVE, which very much implies a client.
	next_move = carrier.client.move_delay

	var/lying_am = 0
	for(var/mob/walker in carriers)
		if(!walker.canmove) // Buckled or something stupid like that.
			stop_carry()
			return NONE
		if(walker.lying)
			lying_am++

	// If any one is lying, but not all are lying, then we're unstable, and fall.
	if(lying_am > 0 && lying_am != carriers.len)
		stop_carry()
		return NONE

	follow_carrier(carry_obj, NewLoc, direction)
	for(var/mob/walker in carriers)
		if(walker == carrier)
			continue
		follow_carrier(walker, NewLoc, direction)
	return NONE

/datum/component/multi_carry/proc/carrier_postmove(datum/source, atom/NewLoc, direction)
	if(!moving)
		return
	moving = FALSE
	check_carriers()

/datum/component/multi_carry/proc/carrier_waddle(datum/source, waddle_strength, pz_raise)
	if(next_waddle > world.time)
		return
	next_waddle = world.time + 2

	if(carry_obj.can_waddle())
		carry_obj.waddle(pick(-waddle_strength, 0, waddle_strength), pz_raise)
		var/mob/M = carry_obj.buckled_mob
		if(M && M.can_waddle())
			M.waddle(pick(-waddle_strength, 0, waddle_strength), pz_raise)
			M.dir = pick(WEST, EAST)

/datum/component/multi_carry/proc/check_proximity(datum/source)
	var/mob/carrier = source
	if(!moving && carry_obj.loc != carrier.loc)
		stop_carry()
		return FALSE
	return TRUE

/datum/component/multi_carry/proc/check_carriers()
	if(carry_obj.dir != prev_dir && !positions.one_dir)
		prev_dir = carry_obj.dir
		INVOKE_ASYNC(src, .proc/rotate_dir, prev_dir)

	for(var/mob/carrier in carriers)
		if(!check_proximity(carrier))
			return

/datum/component/multi_carry/proc/check_canpass(datum/source, atom/movable/mover, atom/target, height, air_group)
	if(!moving)
		return NONE

	if(mover == carry_obj)
		return COMPONENT_CANPASS
	if(mover in carriers)
		return COMPONENT_CANPASS
	return NONE

/datum/component/multi_carry/proc/on_grabbed(datum/source, mob/grabber, force_state, show_warnings)
	stop_carry()
	return COMPONENT_PREVENT_GRAB

/datum/component/multi_carry/proc/on_buckle(datum/source, mob/buckled)
	LAZYSET(carrier_default_pos, buckled, list(
		"pz"=buckled.pixel_z,
		"layer"=buckled.layer
	))
	buckled.pixel_z = carry_pixel_z
	buckled.layer = FLY_LAYER + 0.1
	carry_obj.update_buckle_mob(buckled)

/datum/component/multi_carry/proc/on_unbuckle(datum/source, mob/buckled)
	var/list/pos = carrier_default_pos[buckled]
	buckled.pixel_z = pos["pz"]
	buckled.layer = pos["layer"]
	LAZYREMOVE(carrier_default_pos, buckled)
	carry_obj.update_buckle_mob(buckled)

// Return TRUE to permit carrywaddle/rotatepositions/swappositions.
/datum/component/multi_carry/proc/can_dance(mob/dancer, atom/target, movename)
	if(!dance_moves)
		return FALSE

	var/datum/dance_move/DM = dance_moves[movename]
	if(!DM)
		return FALSE
	return DM.can_perform(dancer, target, src)

/datum/component/multi_carry/proc/on_ctrl_click(datum/source, atom/target)
	if(target == carry_obj)
		return NONE

	if(target != source && (target in carriers))
		if(!can_dance(source, target, DANCE_MOVE_SWAP))
			return COMPONENT_CANCEL_CLICK

		var/mob/M = source
		M.SetNextMove(CLICK_CD_RAPID)
		swap_positions(source, target)
		return COMPONENT_CANCEL_CLICK
	// So carrier doesn't get an idea that they can pull something else.
	return COMPONENT_CANCEL_CLICK

/datum/component/multi_carry/proc/on_ctrl_shift_click(datum/source, atom/target)
	if(target == carry_obj)
		if(!can_dance(source, target, DANCE_MOVE_CARRYWADDLE))
			return NONE

		var/mob/M = source
		M.SetNextMove(CLICK_CD_RAPID)
		carrier_waddle(source, 28, 4)
		return COMPONENT_CANCEL_CLICK

	if(target in carriers)
		if(!can_dance(source, target, DANCE_MOVE_ROTATE))
			return NONE

		var/mob/M = source
		M.SetNextMove(CLICK_CD_RAPID)
		rotate_positions(clockwise=!M.hand)
		return COMPONENT_CANCEL_CLICK
	return NONE

#undef MOVE_TO_POS_DELAY

#undef DANCE_MOVE_CARRYWADDLE
#undef DANCE_MOVE_ROTATE
#undef DANCE_MOVE_SWAP

#undef MULTI_CARRY_TIP
