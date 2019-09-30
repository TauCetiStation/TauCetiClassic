var/list/extraction_appends = list("AAAAAAAAAAAAAAAAAUGH", "AAAAAAAAAAAHHHHHHHHHH")

/obj/item/weapon/extraction_pack
	name = "fulton recovery marker"
	desc = "A marker that can be used to extract a target to a Aurora. Anything not bolted down can be moved. Anything living will be dropped off into a holding cell"
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	var/turf/extraction_point

/obj/item/weapon/extraction_pack/afterattack(atom/movable/A, mob/user, proximity)
	var/extract_time = 70
	if(user.is_busy())
		return
	if(!proximity)
		return
	if(!istype(A))
		return
	else if(istype(A, /obj/effect/extraction_holder)) // This is stupid...
		return
	else
		if(!isturf(extraction_point))
			to_chat(user, "<span class='notice'>Error... Extraction point not found.</span>")
			return

		if(ismob(A))
			extract_time = 100
		if(A.loc == user || A == user) // No extracting stuff you're holding in your hands/yourself.
			return
		if(A.anchored)
			return
		to_chat(user, "<span class='notice'>You start attaching the pack to [A]...</span>")
		if(istype(A, /obj/item))
			var/obj/item/I = A
			if(I.w_class <= ITEM_SIZE_SMALL)
				extract_time = 50
			else
				extract_time = w_class * 20 // 3 = 6 seconds, 4 = 8 seconds, 5 = 10 seconds.
		if(do_after(user, extract_time, target=A))
			if(A.anchored)
				return
			to_chat(user, "<span class='notice'>You attach the pack to [A] and activate it.</span>")
			var/image/balloon
			if(istype(A, /mob/living))
				var/mob/living/M = A
				M.Weaken(16) // Keep them from moving during the duration of the extraction.
				if(M && M.buckled)
					M.buckled.unbuckle_mob()
			else
				A.anchored = 1
				A.density = 0
			var/obj/effect/extraction_holder/holder_obj = new(A.loc)
			holder_obj.appearance = A.appearance
			A.forceMove(holder_obj)
			balloon = image(icon,"extraction_balloon")
			balloon.pixel_y = 10
			balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.overlays += balloon
			playsound(holder_obj, 'sound/effects/fulext_deploy.ogg', VOL_EFFECTS_MASTER, null, null, -3)
			animate(holder_obj, pixel_z = 10, time = 20)
			sleep(20)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			var/obj/effect/BPs = new /obj/effect(get_turf(A))
			BPs.icon = 'code/modules/anomaly/anomalies.dmi'
			BPs.icon_state = "bluespace"
			BPs.mouse_opacity = 0
			var/obj/effect/BPe = new /obj/effect(extraction_point)
			BPe.icon = 'code/modules/anomaly/anomalies.dmi'
			BPe.icon_state = "bluespace"
			BPe.mouse_opacity = 0
			sleep(10)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			if(!A)
				return
			playsound(holder_obj, 'sound/effects/fultext_launch.ogg', VOL_EFFECTS_MASTER, null, null, -3)
			//animate(holder_obj, pixel_z = 1000, time = 30)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, holder_obj.loc)
			s.start()
			if(istype(A, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = A
				H.say(pick(extraction_appends))
				playsound(H, pick(SOUNDIN_MALE_HEAVY_PAIN), VOL_EFFECTS_MASTER, null, FALSE)
				H.SetParalysis(0) // wakey wakey
				H.drowsyness = 0
				H.sleeping = 0
			//sleep(30)
			holder_obj.loc = extraction_point
			s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, holder_obj.loc)
			s.start()
			animate(holder_obj, pixel_z = 10, time = 50)
			sleep(50)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			holder_obj.overlays -= balloon
			if(!A)
				return
			A.anchored = 0 // An item has to be unanchored to be extracted in the first place.
			A.density = initial(A.density)
			animate(holder_obj, pixel_z = 0, time = 5)
			sleep(5)
			A.forceMove(holder_obj.loc)
			qdel(holder_obj)
			qdel(BPs)
			qdel(BPe)

/obj/effect/extraction_holder
	name = "extraction holder"
	desc = "you shouldnt see this"
	var/atom/movable/stored_obj
