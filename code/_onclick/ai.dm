/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(client.buildmode) // handled in normal click.
		return

	if(control_disabled || stat) return
	SetNextMove(CLICK_CD_AI)

	if(ismob(A))
		ai_actual_track(A)
	else if (!istype(A, /obj/screen))
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	if(control_disabled || stat)
		return

	A.add_hiddenprint(src)

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return
	SetNextMove(CLICK_CD_AI)

	if(aiCamera.in_camera_mode)
		aiCamera.camera_mode_off()
		aiCamera.captureimage(A, usr)
		return

	/*
		AI restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
	else
	*/
	if(holohack && hcattack_ai(A))
		return

	A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/ai/RangedAttack(atom/A)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/
/mob/living/silicon/ai/ShiftClickOn(atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/ai/CtrlClickOn(atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/ai/AltClickOn(atom/A)
	if(active_module)
		if(!active_module.AIAltClickHandle(A))
			return
	A.AIAltClick(src)

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/

/atom/proc/AICtrlShiftClick()
	return

/obj/machinery/door/airlock/AICtrlShiftClick()
	if(emagged)
		return
	return

/atom/proc/AIShiftClick()
	return

/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if(density)
		Topic("aiEnable=7", list("aiEnable"="7"), 1) // 1 meaning no window (consistency!)
	else
		Topic("aiDisable=7", list("aiDisable"="7"), 1)
	return


/atom/proc/AICtrlClick()
	return

/obj/machinery/door/airlock/AICtrlClick() // Bolts doors
	if(locked)
		Topic("aiEnable=4", list("aiEnable"="4"), 1)// 1 meaning no window (consistency!)
	else
		Topic("aiDisable=4", list("aiDisable"="4"), 1)

/obj/machinery/power/apc/AICtrlClick() // turns off APCs.
	Topic("breaker=1", list("breaker"="1"), 0) // 0 meaning no window (consistency! wait...)


/atom/proc/AIAltClick()
	return

/obj/machinery/door/airlock/AIAltClick() // Eletrifies doors.
	if(!secondsElectrified)
		// permenant shock
		Topic("aiEnable=6", list("aiEnable"="6"), 1) // 1 meaning no window (consistency!)
	else
		// disable/6 is not in Topic; disable/5 disables both temporary and permenant shock
		Topic("aiDisable=5", list("aiDisable"="5"), 1)
	return

//
// Override AdjacentQuick for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(turf/T)
	return (cameranet && cameranet.checkTurfVis(T))
