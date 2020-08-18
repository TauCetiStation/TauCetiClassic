//Xenobio control console
/mob/camera/Eye/remote/xenobio
	user_camera_icon = 'icons/mob/blob.dmi'
	icon_state = "marker"
	allowed_area_type = /area/station/rnd/xenobiology

/obj/machinery/computer/camera_advanced/xenobio
	name = "Slime management console"
	desc = "A computer used for remotely handling slimes."
	icon_state = "rdcomp"

	circuit = /obj/item/weapon/circuitboard/camera_advanced/xenobio
	light_color = "#a97faa"

	var/datum/action/slime_place/slime_place_action = new
	var/datum/action/slime_pick_up/slime_up_action = new
	var/datum/action/feed_slime/feed_slime_action = new
	var/datum/action/monkey_recycle/monkey_recycle_action = new
	var/datum/action/innate/slime_scan/scan_action = new
	var/datum/action/hotkey_help/hotkey_help = new

	var/obj/machinery/monkey_recycler/connected_recycler
	var/list/stored_slimes = list()
	var/max_slimes = 5
	var/monkeys = 0


/obj/machinery/computer/camera_advanced/xenobio/atom_init()
	. = ..()
	actions += slime_up_action
	actions += slime_place_action
	actions += feed_slime_action
	actions += monkey_recycle_action
	actions += scan_action
	actions += hotkey_help

	for(var/obj/machinery/monkey_recycler/recycler in oview(7,src))
		if(get_area(recycler) == get_area(loc))
			connected_recycler = recycler
			connected_recycler.connected_consoles += src
			break

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	for(var/thing in stored_slimes)
		var/mob/living/carbon/slime/S = thing
		S.forceMove(loc)
	stored_slimes.Cut()
	if(connected_recycler && (locate(src) in connected_recycler.connected_consoles))
		connected_recycler.connected_consoles -= src
	connected_recycler = null
	QDEL_NULL(slime_place_action)
	QDEL_NULL(slime_up_action)
	QDEL_NULL(feed_slime_action)
	QDEL_NULL(monkey_recycle_action)
	QDEL_NULL(scan_action)
	QDEL_NULL(hotkey_help)
	return ..()


/obj/machinery/computer/camera_advanced/xenobio/handle_atom_del(atom/A)
	if(A in stored_slimes)
		stored_slimes -= A
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/CreateEye()
	eyeobj = new /mob/camera/Eye/remote/xenobio(get_turf(src))
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/user)
	..()

	if(slime_up_action)
		slime_up_action.target = src
		slime_up_action.Grant(user)

	if(slime_place_action)
		slime_place_action.target = src
		slime_place_action.Grant(user)

	if(feed_slime_action)
		feed_slime_action.target = src
		feed_slime_action.Grant(user)

	if(monkey_recycle_action)
		monkey_recycle_action.target = src
		monkey_recycle_action.Grant(user)

	if(scan_action)
		scan_action.target = src
		scan_action.Grant(user)

	if(hotkey_help)
		hotkey_help.target = src
		hotkey_help.Grant(user)

	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL, .proc/XenoSlimeClickCtrl)
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT, .proc/XenoSlimeClickShift)
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT, .proc/XenoTurfClickShift)
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL, .proc/XenoTurfClickCtrl)
	RegisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL, .proc/XenoMonkeyClickCtrl)


/obj/machinery/computer/camera_advanced/xenobio/remove_eye_control(mob/living/user)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL)
	..()

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/O, mob/user, params)
	. = ..()
	if(ismultitool(O))
		var/obj/item/device/multitool/M = O
		if(M.buffer && istype(M.buffer,/obj/machinery/monkey_recycler))
			if(!connected_recycler)
				connected_recycler = M.buffer
				connected_recycler.connected_consoles += src
				to_chat(user, "<span class='notice'>You upload the data from the [O.name]'s buffer.</span>")
			else if(connected_recycler == M.buffer)
				to_chat(user, "<span class='warning'>This machine is already linked to this console</span>")
				return
			else
				connected_recycler.connected_consoles -= src
				connected_recycler = M.buffer
				connected_recycler.connected_consoles += src
				to_chat(user, "<span class='notice'>You upload the data from the [O.name]'s buffer.</span>")

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		monkeys++
		to_chat(user, "<span class='notice'>You feed [O] to [src]. It now has [monkeys] monkey cubes stored.</span>")
		qdel(O)
		return
	else if(istype(O, /obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/P = O
		var/loaded = FALSE
		for(var/obj/G in P.contents)
			if(istype(G, /obj/item/weapon/reagent_containers/food/snacks/monkeycube))
				loaded = TRUE
				monkeys++
				qdel(G)
		if(loaded)
			to_chat(user, "<span class='notice'>You fill [src] with the monkey cubes stored in [O]. [src] now has [monkeys] monkey cubes stored.</span>")



/proc/slime_scan(mob/living/carbon/slime/T, mob/living/user)
	var/to_render = "========================\
					\n<b>Slime scan results:</b>\
					\n<span class='notice'>[T.colour] [istype(T,/mob/living/carbon/slime/adult) ? "adult" : "baby"] slime</span>\
					\nNutrition: [T.nutrition]/[T.get_max_nutrition()]"
	if (T.nutrition < T.get_starve_nutrition())
		to_render += "\n<span class='warning'>Warning: slime is starving!</span>"
	else if (T.nutrition < T.get_hunger_nutrition())
		to_render += "\n<span class='warning'>Warning: slime is hungry</span>"
	to_render += "\nElectric charge strength: [T.powerlevel]\nHealth: [round(T.health/T.maxHealth,0.01)*100]%"
	if (T.cores > 1)
		to_render += "\nMultiple cores detected"
	to_render += "\nGrowth progress: [T.amount_grown]/[T.max_grown]"
	to_chat(user, to_render + "\n========================")

/mob/living/carbon/slime/proc/animate_teleport()
	var/atom/movable/overlay/animation = new /atom/movable/overlay(loc)
	QDEL_IN(animation, 10)		//After flick finishes, animation is invisible. One second in more than enough to finish without artifacts
	animation.icon = 'icons/mob/slimes.dmi'
	animation.master = src
	if(istype(src, /mob/living/carbon/slime/adult))
		flick("big_jaunt_out", animation)
	else
		flick("small_jaunt_out", animation)


/datum/action/slime_place
	name = "Place Slimes"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "slime_down"
	action_type = AB_INNATE

/datum/action/slime_place/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/Eye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/carbon/slime/S in X.stored_slimes)
			S.forceMove(remote_eye.loc)
			if(istype(S, /mob/living/carbon/slime/adult))
				flick("big_jaunt_in", S)
			else
				flick("small_jaunt_in", S)
			S.visible_message("<span class='notice'>[S] warps in!</span>")
			X.stored_slimes -= S
	else
		to_chat(owner, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/slime_pick_up
	name = "Pick up Slime"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "slime_up"
	action_type = AB_INNATE

/datum/action/slime_pick_up/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/Eye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/carbon/slime/S in remote_eye.loc)
			if(X.stored_slimes.len >= X.max_slimes)
				break
			if(S.stat)
				if(!X.connected_recycler)
					to_chat(owner, "<span class='warning'>There is no connected recycler. Use a multitool to link one.</span>")
					return
				else
					S.animate_teleport()
					S.visible_message("<span class='notice'>[S] vanishes!</span>")
					X.connected_recycler.grind(S,owner)
			else if(!S.ckey)
				if(S.buckled)
					S.Feedstop()
				S.animate_teleport()
				S.visible_message("<span class='notice'>[S] vanishes!</span>")
				S.forceMove(X)
				X.stored_slimes += S
	else
		to_chat(owner, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")


/datum/action/feed_slime
	name = "Feed Slimes"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "monkey_down"
	action_type = AB_INNATE

/datum/action/feed_slime/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/Eye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(cameranet.checkTurfVis(remote_eye.loc))
		if(X.monkeys >= 1)
			var/mob/living/carbon/monkey/food = new /mob/living/carbon/monkey(remote_eye.loc, TRUE, owner)
			if (!QDELETED(food))
				food.LAssailant = C
				--X.monkeys
				to_chat(owner, "<span class='notice'>[X] now has [X.monkeys] monkeys stored.</span>")
		else
			to_chat(owner, "<span class='warning'>[X] needs to have at least 1 monkey stored. Currently has [X.monkeys] monkeys stored.</span>")
	else
		to_chat(owner, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")


/datum/action/innate/slime_scan
	name = "Scan Slime"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "slime_scan"
	action_type = AB_INNATE

/datum/action/innate/slime_scan/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/Eye/remote/xenobio/remote_eye = C.remote_control

	if(cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/carbon/slime/S in remote_eye.loc)
			slime_scan(S, C)
	else
		to_chat(owner, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")


/datum/action/monkey_recycle
	name = "Recycle Monkeys"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "monkey_up"
	action_type = AB_INNATE

/datum/action/monkey_recycle/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/Eye/remote/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target
	var/obj/machinery/monkey_recycler/recycler = X.connected_recycler

	if(!recycler)
		to_chat(owner, "<span class='warning'>There is no connected monkey recycler. Use a multitool to link one.</span>")
		return
	if(cameranet.checkTurfVis(remote_eye.loc))
		for(var/mob/living/carbon/monkey/M in remote_eye.loc)
			if(M.stat)
				M.visible_message("<span class='notice'>[M] vanishes!</span>")
				X.connected_recycler.grind(M,owner)
	else
		to_chat(owner, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")


/datum/action/hotkey_help
	name = "Hotkey Help"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "hotkey_help"
	action_type = AB_INNATE


/datum/action/hotkey_help/Activate()
	if(!target || !isliving(owner))
		return
	to_chat(owner, "<b>Click shortcuts:</b>")
	to_chat(owner, "Shift-click a slime to pick it up, or the floor to drop all held slimes.")
	to_chat(owner, "Ctrl-click a slime to scan it.")
	to_chat(owner, "Ctrl-click or a dead monkey to recycle it, or the floor to place a new monkey.")

//
// Alternate clicks for slime, monkey and open turf if using a xenobio console

//Scans slime
/mob/living/carbon/slime/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_CTRL, src)
	..()


//Picks up slime
/mob/living/carbon/slime/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_SHIFT, src)
	..()

//Place slimes
/turf/simulated/floor/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_SHIFT, src)
	..()

//Place monkey
/turf/simulated/floor/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_CTRL, src)
	..()

//Pick up monkey
/mob/living/carbon/monkey/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_MONKEY_CLICK_CTRL, src)
	..()

//Scans slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickCtrl(mob/living/user, mob/living/carbon/slime/S)
	if (!cameranet.checkTurfVis(get_turf(S)))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return

	var/mob/living/C = user
	var/mob/camera/Eye/remote/xenobio/E = C.remote_control

	if (istype(get_area(S), E.allowed_area_type))
		slime_scan(S, C)

//Picks up slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickShift(mob/living/user, mob/living/carbon/slime/S)
	if(!cameranet.checkTurfVis(get_turf(S)))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return

	var/mob/living/C = user
	var/mob/camera/Eye/remote/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	if (istype(get_area(S), E.allowed_area_type))
		if(S.stat)
			if(!X.connected_recycler)
				to_chat(C, "<span class='warning'>There is no connected recycler. Use a multitool to link one.</span>")
				return
			else
				S.animate_teleport()
				S.visible_message("<span class='notice'>[S] vanishes!</span>")
				X.connected_recycler.grind(S,C)
		else if(!S.ckey)
			if(X.stored_slimes.len >= X.max_slimes)
				to_chat(C, "<span class='warning'>Slime storage is full.</span>")
				return
			if(S.buckled)
				S.Feedstop()
			S.animate_teleport()
			S.visible_message("<span class='notice'>[S] vanishes!</span>")
			S.forceMove(X)
			X.stored_slimes += S

//Place slimes
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickShift(mob/living/user, turf/simulated/floor/T)
	if(!cameranet.checkTurfVis(T))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return

	var/mob/living/C = user
	var/mob/camera/Eye/remote/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/turfarea = get_area(T)
	if (istype(turfarea, E.allowed_area_type))
		for(var/mob/living/carbon/slime/S in X.stored_slimes)
			S.forceMove(T)
			if(istype(S, /mob/living/carbon/slime/adult))
				flick("big_jaunt_in", S)
			else
				flick("small_jaunt_in", S)
			S.visible_message("<span class='notice'>[S] warps in!</span>")
			X.stored_slimes -= S

//Place monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickCtrl(mob/living/user, turf/simulated/floor/T)
	if(!cameranet.checkTurfVis(T))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return

	var/mob/living/C = user
	var/mob/camera/Eye/remote/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin

	if (istype(get_area(T), E.allowed_area_type))
		if(X.monkeys >= 1)
			var/mob/living/carbon/monkey/food = new /mob/living/carbon/monkey(T, TRUE, C)
			if (!QDELETED(food))
				food.LAssailant = C
				--X.monkeys
				to_chat(C, "<span class='notice'>[X] now has [X.monkeys] monkeys stored.</span>")
		else
			to_chat(C, "<span class='warning'>[X] needs to have at least 1 monkey stored. Currently has [X.monkeys] monkeys stored.</span>")

//Pick up monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoMonkeyClickCtrl(mob/living/user, mob/living/carbon/monkey/M)
	if(!isturf(M.loc) || !cameranet.checkTurfVis(M.loc))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return

	var/mob/living/C = user
	var/mob/camera/Eye/remote/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin

	if(!X.connected_recycler)
		to_chat(C, "<span class='warning'>There is no connected monkey recycler. Use a multitool to link one.</span>")
		return

	if (istype(get_area(M), E.allowed_area_type))
		if(!M.stat)
			return
		M.visible_message("<span class='notice'>[M] vanishes!</span>")
		X.connected_recycler.grind(M,user)
