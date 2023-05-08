/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.click_intercept) // comes after object.Click to allow buildmode gui objects to be clicked
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	var/list/modifiers = params2list(params)

	if(client.cob.in_building_mode)
		cob_click(client, modifiers)
		return

	if(modifiers[SHIFT_CLICK] && modifiers[MIDDLE_CLICK])
		MiddleShiftClickOn(A)
		return
	if(modifiers[SHIFT_CLICK] && modifiers[CTRL_CLICK])
		CtrlShiftClickOn(A)
		return
	if(modifiers[MIDDLE_CLICK])
		MiddleClickOn(A)
		return
	if(modifiers[SHIFT_CLICK])
		ShiftClickOn(A)
		return
	if(modifiers[ALT_CLICK]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers[CTRL_CLICK])
		CtrlClickOn(A)
		return

	if(incapacitated(NONE) || lockcharge)
		return

	if(next_move >= world.time)
		return

	face_atom(A) // change direction to face what you clicked on

	if(aiCamera.in_camera_mode)
		aiCamera.camera_mode_off()
		if(is_component_functioning("camera"))
			aiCamera.captureimage(A, usr)
		else
			to_chat(src, "<span class='userdanger'>Your camera isn't functional.</span>")
		return

	/*
	cyborg restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
		return
	*/

	var/obj/item/W = get_active_hand()

	// Cyborgs have no range-checking unless there is item use
	if(!W)
		A.add_hiddenprint(src)
		A.attack_robot(src)
		return

	// buckled cannot prevent machine interlinking but stops arm movement
	if(buckled)
		return

	if(SEND_SIGNAL(W, COMSIG_HAND_IS))
		SEND_SIGNAL(W, COMSIG_HAND_ATTACK, A, src, params)
		return

	if(W == A)
		return W.attack_self(src)

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
	if(A == loc || (A.loc == loc) || (A.loc == src))
		// No adjacency checks
		W.melee_attack_chain(A, src, params)
		return

	if(!isturf(loc))
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc && isturf(A.loc.loc))
	if(isturf(A) || isturf(A.loc))
		if(A.Adjacent(src)) // see adjacent.dm
			W.melee_attack_chain(A, src, params)
			return
		W.afterattack(A, src, 0, params)

//Middle Shift click for point to
/mob/living/silicon/robot/MiddleShiftClickOn(atom/A)
	A.BorgMiddleShiftClick(src)

//Middle click cycles through selected modules.
/mob/living/silicon/robot/MiddleClickOn(atom/A)
	cycle_modules()
	return

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/robot/CtrlShiftClickOn(atom/A)
	A.BorgCtrlShiftClick(src)

/mob/living/silicon/robot/ShiftClickOn(atom/A)
	A.BorgShiftClick(src)

/mob/living/silicon/robot/CtrlClickOn(atom/A)
	A.BorgCtrlClick(src)

/mob/living/silicon/robot/AltClickOn(atom/A)
	A.BorgAltClick(src)

/atom/proc/BorgMiddleShiftClick(mob/living/silicon/robot/user)
	user.pointed(src)

/atom/proc/BorgCtrlShiftClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlShiftClick(user)

/obj/machinery/door/airlock/BorgCtrlShiftClick()
	AICtrlShiftClick()

/atom/proc/BorgShiftClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	ShiftClick(user)

/obj/machinery/door/airlock/BorgShiftClick()  // Opens and closes doors! Forwards to AI code.
	AIShiftClick()


/atom/proc/BorgCtrlClick(mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlClick(user)

/obj/machinery/door/airlock/BorgCtrlClick() // Bolts doors. Forwards to AI code.
	AICtrlClick()

/obj/machinery/power/apc/BorgCtrlClick() // turns off/on APCs. Forwards to AI code.
	AICtrlClick()

/obj/machinery/turretid/BorgCtrlClick() //turret control on/off. Forwards to AI code.
	AICtrlClick()

/atom/proc/BorgAltClick(mob/living/silicon/robot/user)
	AltClick(user)
	return

/obj/machinery/door/airlock/BorgAltClick() // Eletrifies doors. Forwards to AI code.
	AIAltClick()

/obj/machinery/turretid/BorgAltClick() //turret lethal on/off. Forwards to AI code.
	AIAltClick()

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	A.attack_robot(src)

/mob/living/silicon/robot/RangedAttack(atom/A)
	A.attack_robot(src)

/atom/proc/attack_robot(mob/user)
	attack_ai(user)
	return
