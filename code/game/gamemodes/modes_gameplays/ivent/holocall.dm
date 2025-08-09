var/global/list/holocomms_global = list()

#define HOLOCOMM_NETWORK_JEDI 1
#define HOLOCOMM_NETWORK_SITH 2

/obj/item/device/holocomm
	name = "holocomm"
	desc = "Used to relay messages."
	icon_state = "holocomm-idle"
	w_class = SIZE_TINY
	item_state = "electronic"
	flags = CONDUCT | NOBLUDGEON
	var/network_number = HOLOCOMM_NETWORK_JEDI
	var/is_ringing = FALSE
	var/is_calling = FALSE
	var/is_in_call = FALSE
	var/obj/item/device/holocomm/holocomm_calling
	var/obj/effect/overlay/hologram/holocomm_overlay
	var/mob/holo_caller
	COOLDOWN_DECLARE(ringing_cooldown)

/obj/item/device/holocomm/jedi
	network_number = HOLOCOMM_NETWORK_JEDI

/obj/item/device/holocomm/sith
	network_number = HOLOCOMM_NETWORK_SITH

/obj/item/device/holocomm/atom_init()
	name = "Holocomm Number[rand(1,9)][rand(1,9)][rand(1,9)][rand(1,9)][rand(1,9)][rand(1,9)]"
	holocomms_global += src
	START_PROCESSING(SSobj, src)
	RegisterSignal(src, COMSIG_MOVABLE_HEAR, PROC_REF(catchMessage), override = TRUE)

/obj/item/device/holocomm/attack_self(mob/user)
	if(is_in_call) // drop the current call
		var/choice = input(user, "End call?", "Currently in call") as null|anything in list("Yes", "No")
		if(choice == "Yes")
			end_call()
		return

	if(is_calling) // stop calling
		var/choice = input(user, "Stop calling?", "You are currenly calling someone!") as null|anything in list("Yes", "No")
		if(choice == "Yes")
			to_chat(user, "<span class='notice'>You stopped calling.</span>")
			is_calling = FALSE
			if(holocomm_calling && holocomm_calling.is_ringing)
				holocomm_calling.is_ringing = FALSE
				holocomm_calling.icon_state = "holocomm-idle"
				holocomm_calling = null
		return

	if(is_ringing) // answer the call
		if(!holocomm_calling)
			is_ringing = FALSE
			icon_state = "holocomm-idle"
			return
		var/choice = input(user, "Accept call?", "Someone is calling!") as null|anything in list("Yes", "No")
		if(choice == "Yes")
			accept_call(user)
		else if(choice == "No")
			is_ringing = FALSE
			icon_state = "holocomm-idle"
			if(holocomm_calling)
				holocomm_calling.is_calling = FALSE
				holocomm_calling.holocomm_calling = null
				holocomm_calling = null
				to_chat(user, "<span class='notice'>You rejected the call.</span>")
		return
	var/list/holocomms_to_pick = holocomms_global.Copy()
	holocomms_to_pick -= src
	for(var/obj/item/device/holocomm/N in holocomms_to_pick)
		if(N.network_number != network_number)
			holocomms_to_pick -= N
	if(!holocomms_to_pick.len)
		to_chat(user, "<span class='warning'>There is no one to call!</span>")
		return
	var/obj/item/device/holocomm/H
	H = input(user, "Select a receiver", "Pick Holocomm") as null|anything in holocomms_to_pick
	if(!H)
		return
	try_calling(H, user)

/obj/item/device/holocomm/proc/try_calling(obj/item/device/holocomm/H, mob/user)
	if(!H || !user)
		return
	if(H.is_ringing)
		to_chat(user, "<span class='warning'>[H] is already being called!</span>")
		return
	if(H.is_calling)
		to_chat(user, "<span class='warning'>[H] is calling someone!</span>")
		return
	if(H.is_in_call)
		to_chat(user, "<span class='warning'>[H] is currently in another call!</span>")
		return
	is_calling = TRUE
	holocomm_calling = H
	H.holocomm_calling = src
	H.is_ringing = TRUE
	H.icon_state = "holocomm-ring"
	H.holo_caller = user
	to_chat(user, "<span class='notice'>You are calling [H]!</span>")

/obj/item/device/holocomm/proc/accept_call(mob/user)
	if(!holocomm_calling || !holo_caller || !holocomm_calling.is_calling)
		return
	is_ringing = FALSE
	holocomm_calling.is_calling = FALSE
	is_in_call = TRUE
	icon_state = "holocomm-call"
	holocomm_calling.is_in_call = TRUE
	holocomm_calling.icon_state = "holocomm-call"
	create_hologram(holo_caller)
	holocomm_calling.create_hologram(user)
	to_chat(user, "<span class='notice'>You accepted the incoming call.</span>")

/obj/item/device/holocomm/pickup(mob/user)
	. = ..()
	name = "Holocomm ([user.name])"
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement), override = TRUE)

/obj/item/device/holocomm/dropped(mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	. = ..()

/obj/item/device/holocomm/proc/on_movement(datum/source, atom/OldLoc, dir)
	if(holocomm_overlay && ismob(loc))
		var/turf/T = get_ranged_target_turf(get_turf(src), dir, 1)
		holocomm_overlay.forceMove(T)

/obj/item/device/holocomm/proc/catchMessage(datum/source, msg, mob/speaker)
	if(!is_in_call || !holocomm_calling || !holocomm_calling.holocomm_overlay)
		return
	if(!msg || findtext(msg,"((") || findtext(msg,"))"))
		return
	holocomm_calling.holocomm_overlay.say_something("[speaker] says: \"[msg]\"")

/obj/item/device/holocomm/proc/create_hologram(mob/user)
	flags ^= HEAR_TA_SAY
	var/turf/T = loc
	if(ismob(loc))
		var/mob/mob_loc = loc
		T = get_ranged_target_turf(T, mob_loc.dir, 1)
	var/obj/effect/overlay/hologram/hologram = new(T) // Spawn a blank effect at the location.
	holocomm_overlay = hologram
	var/olddir = user.dir
	user.dir = SOUTH
	holocomm_overlay.icon = user.icon
	holocomm_overlay.icon_state = user.icon_state
	holocomm_overlay.Impersonation = user
	holocomm_overlay.cut_overlays()
	holocomm_overlay.copy_overlays(user, TRUE)
	holocomm_overlay.makeHologram()
	user.dir = olddir
	hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
	hologram.layer = FLY_LAYER //Above all the other objects/mobs. Or the vast majority of them.
	hologram.plane = ABOVE_GAME_PLANE
	hologram.anchored = TRUE //So space wind cannot drag it.
	hologram.name = "[user.name] (Hologram)"//If someone decides to right click.
	visible_message("<span class='notice'>A holographic image of [user] flickers to life!</span>")

/obj/item/device/holocomm/process()
	if(is_ringing && COOLDOWN_FINISHED(src, ringing_cooldown))
		visible_message("<span class='warning'>[bicon(src)][src] rings! Someone is calling!</span>")
		playsound(src, 'sound/weapons/ring.ogg', VOL_EFFECTS_MASTER)
		COOLDOWN_START(src, ringing_cooldown, 5 SECONDS)
	if(!holocomm_overlay || !holocomm_overlay.Impersonation)
		return
	var/mob/copy_from = holocomm_overlay.Impersonation
	var/olddir = copy_from.dir
	copy_from.dir = SOUTH
	holocomm_overlay.cut_overlays()
	holocomm_overlay.copy_overlays(copy_from, TRUE)
	holocomm_overlay.makeHologram()
	copy_from.dir = olddir
	var/turf/T = loc
	if(ismob(loc))
		var/mob/mob_loc = loc
		T = get_ranged_target_turf(T, mob_loc.dir, 1)
	holocomm_overlay.forceMove(T)

/obj/item/device/holocomm/proc/end_call()
	flags ^= HEAR_TA_SAY
	if(holocomm_calling)
		holocomm_calling.holocomm_calling = null
		holocomm_calling.is_in_call = FALSE
		holocomm_calling.icon_state = "holocomm-idle"
		if(holocomm_calling.holocomm_overlay)
			holocomm_calling.holocomm_overlay.visible_message("<span class='warning'>A holographic image dissapears!</span>")
			qdel(holocomm_calling.holocomm_overlay)
		holocomm_calling = null
	is_in_call = FALSE
	icon_state = "holocomm-idle"
	if(holocomm_overlay)
		holocomm_overlay.visible_message("<span class='warning'>A holographic image dissapears!</span>")
		qdel(holocomm_overlay)

/obj/item/device/holocomm/Destroy()
	holocomms_global -= src
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(src, COMSIG_MOVABLE_HEAR)
	if(is_in_call)
		end_call()
	return ..()

/obj/effect/overlay/hologram
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE|KEEP_TOGETHER
	var/mob/living/Impersonation
	//var/datum/holocall/HC

/obj/effect/overlay/hologram/Destroy()
	Impersonation = null
	//if(!QDELETED(HC))
	//	HC.Disconnect(HC.calling_holopad)
	//HC = null
	return ..()

/obj/effect/overlay/hologram/Process_Spacemove(movement_dir = 0)
	return TRUE

/obj/effect/overlay/hologram/proc/say_something(msg)
	if(!msg)
		return
	// todo: bad copypaste of say code, some mobs will not hear it
	var/list/listening = viewers(src)
	for(var/mob/M as anything in observer_list)
		if (!M.client)
			continue //skip leavers
		if(M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
			listening |= M

	for(var/mob/M in listening)
		to_chat(M, "<span class='notice'>[msg]</span>")
	playsound(src, pick('sound/effects/radio1.ogg', 'sound/effects/radio2.ogg'), VOL_EFFECTS_MASTER, 50)

/obj/effect/overlay/hologram/examine(mob/user)
	if(Impersonation)
		return Impersonation.examine(user)
	return ..()

/// Makes this atom look like a "hologram"
/// So transparent, blue, with a scanline and an emissive glow
/// This is acomplished using a combination of filters and render steps/overlays
/// The degree of the opacity is optional, based off the opacity arg (0 -> 1)
/atom/proc/makeHologram(opacity = 0.5)
	// First, we'll make things blue (roughly) and sorta transparent
	add_filter("HOLO: Color and Transparent", 1, color_matrix_filter(rgb(125,180,225, opacity * 255)))
	// Now we're gonna do a scanline effect
	// Gonna take this atom and give it a render target, then use it as a source for a filter
	// (We use an atom because it seems as if setting render_target on an MA is just invalid. I hate this engine)
	var/atom/movable/scanline = new(null)
	scanline.icon = 'icons/effects/effects.dmi'
	scanline.icon_state = "scanline"
	scanline.appearance_flags |= RESET_TRANSFORM
	// * so it doesn't render
	var/static/uid_scan = 0
	scanline.render_target = "*HoloScanline [uid_scan]"
	uid_scan++
	// Now we add it as a filter, and overlay the appearance so the render source is always around
	add_filter("HOLO: Scanline", 2, alpha_mask_filter(render_source = scanline.render_target))
	add_overlay(scanline)
	qdel(scanline)
	// Annd let's make the sucker emissive, so it glows in the dark
	if(!render_target)
		var/static/uid = 0
		render_target = "HOLOGRAM [uid]"
		uid++
