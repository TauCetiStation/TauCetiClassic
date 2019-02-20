/obj/item/device/camera/scp105
	name = "Iris's camera"
	icon = 'code/modules/SCP/SCP_105/SCP.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "scp105b"
	pictures_max = 10
	pictures_left = 10
	icon_on = "scp105b"
	icon_off = "scp105b_off"

/obj/item/device/camera/scp105/captureimage(atom/target, mob/user, flag)  //Proc for both regular and AI-based camera to take the image
	var/mobs = ""
	var/list/mob_names = list()
	var/isAi = istype(user, /mob/living/silicon/ai)
	var/list/seen
	if(!isAi) //crappy check, but without it AI photos would be subject to line of sight from the AI Eye object. Made the best of it by moving the sec camera check inside
		if(user.client)		//To make shooting through security cameras possible
			seen = hear(world.view, user.client.eye) //To make shooting through security cameras possible
		else
			seen = hear(world.view, user)
	else
		seen = hear(world.view, target)

	var/list/turfs = list()
	for(var/turf/T in range(round(photo_size * 0.5), target))
		if(T in seen)
			if(isAi && !cameranet.checkTurfVis(T))
				continue
			else
				var/detail_list = camera_get_mobs(T)
				turfs += T
				mobs += detail_list["mob_detail"]
				mob_names += detail_list["names_detail"]

	var/icon/temp = get_base_photo_icon()
	temp.Blend("#000", ICON_OVERLAY)
	temp.Blend(camera_get_icon(turfs, target), ICON_OVERLAY)

	var/datum/picture/P = createpicture(user, temp, mobs, mob_names, flag)
	var/turf/phototurf
	if(!isturf(target))
		phototurf = target.loc
	else
		phototurf = target
	printpicture(user, P, phototurf)

/obj/item/device/camera/scp105/printpicture(mob/user, datum/picture/P, turf/target)
	var/obj/item/weapon/photo/scp105/Photo = new/obj/item/weapon/photo/scp105()
	Photo.loc = user.loc
	Photo.photoloc = target
	if(!user.get_inactive_hand())
		user.put_in_inactive_hand(Photo)
	Photo.construct(P)

/obj/effect/scp105hand
	name = "A hand"
	desc = "That's a human hand coming from an invisible portal, omg!"
	icon = 'code/modules/SCP/SCP_105/SCP.dmi'
	icon_state = "scp105hand"
	anchored = TRUE
	unacidable = TRUE

/obj/item/weapon/photo/scp105
	name = "photo"
	var/turf/photoloc
	var/mob/camera/Eye/eyeobj
	var/obj/effect/scp105hand/hand

/obj/item/weapon/photo/scp105/Destroy()
	if(eyeobj)
		QDEL_NULL(eyeobj)
	if(hand)
		QDEL_NULL(hand)
	return ..()

/obj/item/weapon/photo/scp105/attack_self(mob/user)
	if(istype(user, /mob/living/carbon/human/scp105))
		var/mob/living/carbon/human/scp105/H = user
		if(!H.lookingphoto)
			H.lookingphoto = src
			H.client.adminobs = TRUE
			hand = new(photoloc)
			hand.dir = user.dir
			eyeobj = new(photoloc)
			eyeobj.master = H
			eyeobj.name = "[H.name] (Eye)"
			H.client.eye = eyeobj
			H.reset_view(eyeobj)
		else
			H.lookingphoto.disable_cam(H)
	else
		..()

/obj/item/weapon/photo/scp105/proc/disable_cam(var/mob/living/carbon/human/scp105/H)
	if(eyeobj)
		QDEL_NULL(eyeobj)
	if(hand)
		QDEL_NULL(hand)
	H.client.adminobs = FALSE
	H.reset_view(null)
	H.lookingphoto = null

/mob/living/carbon/human/scp105
	real_name = "Iris Thompson"
	var/obj/item/weapon/photo/scp105/lookingphoto = null

/mob/living/carbon/human/scp105/atom_init(mapload)
	. = ..(mapload, HUMAN)
	gender = FEMALE
	r_hair = 211
	g_hair = 196
	b_hair = 141
	h_style = "Longer Fringe"

	equip_to_slot_or_del(new /obj/item/clothing/under/tourist(src), SLOT_W_UNIFORM)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/black(src), SLOT_SHOES)
	equip_to_slot_or_del(new /obj/item/device/camera/scp105(src), SLOT_BELT)
	update_body()
	update_hair()

/mob/living/carbon/human/scp105/Life()
	. = ..()

	if(lookingphoto)
		if((l_hand != lookingphoto && r_hand != lookingphoto) || stat>0)
			lookingphoto.disable_cam(src)
			lookingphoto = null
		else if(lookingphoto.hand)
			lookingphoto.hand.dir = dir

	if(machine && lookingphoto)
		machine.interact(src)

	if(client && client.adminobs && !client.eye)
		client.adminobs = FALSE
		reset_view(null)
		lookingphoto = null

/mob/living/carbon/human/scp105/ClickOn( atom/A, params )
	if(!lookingphoto)
		return ..(A, params)

	var/oldloc = loc
	loc = lookingphoto.photoloc

	spawn(0)
		spawn(0)
			loc = oldloc
			if(lookingphoto.hand)
				lookingphoto.hand.dir = dir
		ClickOn2(A, params)

	//INVOKE_ASYNC(src, /mob.proc/ClickOn, A, params)

	//..(A, params)
	//spawn(0)
	//	loc = oldloc

/mob/living/carbon/human/scp105/can_use_topic()
	if(stat == 0)
		return STATUS_INTERACTIVE
	else
		. = ..()


/mob/living/carbon/human/scp105/proc/ClickOn2( atom/A, params )
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)

	if(client.cob && client.cob.in_building_mode)
		cob_click(client, modifiers)
		return

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

	if(stat || paralysis || stunned || weakened)
		return

	face_atom(A) // change direction to face what you clicked on

	if(next_move > world.time) // in the year 2000...
		return

	if(istype(loc,/obj/mecha))
		if(!locate(/turf) in list(A, A.loc)) // Prevents inventory from being drilled
			return
		var/obj/mecha/M = loc
		return M.click_action(A, src)

	if(restrained())
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		throw_item(A)
		return

	if(!istype(A,/obj/item/weapon/gun) && !isturf(A) && !istype(A,/obj/screen))
		last_target_click = world.time

	var/obj/item/W = get_active_hand()

	if(W == A)
		W.attack_self(src)
		if(hand)
			update_inv_l_hand()
		else
			update_inv_r_hand()
		return

	// operate two STORAGE levels deep here (item in backpack in src; NOT item in box in backpack in src)
	var/sdepth = A.storage_depth(src)
	if(A == loc || (A in loc) || (sdepth != -1 && sdepth <= 1))

		// No adjacency needed
		if(W)

			var/resolved = A.attackby(W,src,params)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, params) // 1 indicates adjacency
		else
			UnarmedAttack(A)
		return

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	// Allows you to click on a box's contents, if that box is on the ground, but no deeper than that
	sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))

		if(A.Adjacent(src)) // see adjacent.dm
			if(W)
				// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
				var/resolved = A.attackby(W, src, params)
				if(!resolved && A && W)
					W.afterattack(A, src, 1, params) // 1: clicking something Adjacent
			else
				UnarmedAttack(A)
		else // non-adjacent click
			if(W)
				W.afterattack(A, src, 0, params) // 0: not Adjacent
			else
				RangedAttack(A, params)