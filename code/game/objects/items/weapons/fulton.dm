/obj/item/weapon/extraction_pack
	name = "fulton recovery marker"
	desc = "A marker that can be used to extract a target to a Aurora. Anything not bolted down can be moved. Anything living will be dropped off into a holding cell"
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	var/turf/extraction_point
	var/del_target = TRUE // if extraction_point = null, then the thing flies away, but does not arrive
	var/list/extraction_appends = list("AAAAAAAAAAAAAAAAAUGH", "AAAAAAAAAAAHHHHHHHHHH")

/obj/item/weapon/extraction_pack/afterattack(atom/target, mob/user, proximity, params)
	var/extract_time = 70
	if(user.is_busy() || !proximity || !ismovable(target))
		return
	if(istype(target, /obj/effect/extraction_holder)) // This is stupid...
		return
	var/atom/movable/AM = target
	if(!isturf(extraction_point) && !del_target)
		to_chat(user, "<span class='notice'>Error... Extraction point not found.</span>")
		return

	if(ismob(AM))
		extract_time = 100
	if(AM.anchored || !isturf(AM.loc))
		return
	to_chat(user, "<span class='notice'>You start attaching the pack to [AM]...</span>")
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.w_class <= SIZE_TINY)
			extract_time = 50
		else
			extract_time = w_class * 20 // 3 = 6 seconds, 4 = 8 seconds, 5 = 10 seconds.
	if(!do_after(user, extract_time, target = AM))
		return
	if(AM.anchored)
		return
	to_chat(user, "<span class='notice'>You attach the pack to [AM] and activate it.</span>")
	var/image/balloon
	if(isliving(AM))
		var/mob/living/M = AM
		M.Weaken(16) // Keep them from moving during the duration of the extraction.
		if(M && M.buckled)
			M.buckled.unbuckle_mob()
	else
		AM.anchored = TRUE
		AM.density = FALSE
	var/obj/effect/extraction_holder/holder_obj = new(AM.loc)
	holder_obj.appearance = AM.appearance
	AM.forceMove(holder_obj)
	balloon = image(icon,"extraction_balloon")
	balloon.pixel_y = 10
	balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	holder_obj.add_overlay(balloon)
	playsound(holder_obj, 'sound/effects/fulext_deploy.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	animate(holder_obj, pixel_z = 10, time = 20)
	sleep(20)
	animate(holder_obj, pixel_z = 15, time = 10)
	sleep(10)

	var/obj/effect/BPs = new /obj/effect(get_turf(AM))
	BPs.icon = 'icons/effects/anomalies.dmi'
	BPs.icon_state = "bluespace"
	BPs.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/obj/effect/BPe
	if(!del_target)
		BPe = new /obj/effect(extraction_point)
		BPe.icon = 'icons/effects/anomalies.dmi'
		BPe.icon_state = "bluespace"
		BPe.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	animate(holder_obj, pixel_z = 10, time = 10)
	sleep(10)
	animate(holder_obj, pixel_z = 15, time = 10)
	sleep(10)
	animate(holder_obj, pixel_z = 10, time = 10)
	sleep(10)
	if(!target)
		return

	playsound(holder_obj, 'sound/effects/fultext_launch.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	new /obj/effect/temp_visual/sparkles(loc)

	if(ishuman(target))
		var/mob/living/carbon/human/H = AM
		H.say(pick(extraction_appends))
		H.emote("scream")

	if(del_target)
		qdel(target)
		qdel(holder_obj)
		qdel(BPs)
		return

	holder_obj.forceMove(extraction_point)
	new /obj/effect/temp_visual/sparkles(loc)

	qdel(BPs)
	qdel(BPe)

	animate(holder_obj, pixel_z = 15, time = 10)
	sleep(10)
	animate(holder_obj, pixel_z = 10, time = 10)
	sleep(10)
	holder_obj.cut_overlay(balloon)
	if(!target)
		return
	AM.anchored = FALSE // An item has to be unanchored to be extracted in the first place.
	AM.density = initial(target.density)
	animate(holder_obj, pixel_z = 0, time = 5)
	sleep(5)
	AM.forceMove(holder_obj.loc)
	qdel(holder_obj)

/obj/effect/extraction_holder
	name = "extraction holder"
	desc = "you shouldnt see this"
	var/atom/movable/stored_obj
