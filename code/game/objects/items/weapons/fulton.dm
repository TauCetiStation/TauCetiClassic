/obj/item/weapon/extraction_pack
	name = "fulton recovery marker"
	desc = "A marker that can be used to extract a target to a Aurora. Anything not bolted down can be moved. Anything living will be dropped off into a holding cell"
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	var/turf/extraction_point
	var/del_target = FALSE // the thing flies away, but does not arrive
	var/list/extraction_appends = list("AAAAAAAAAAAAAAAAAUGH", "AAAAAAAAAAAHHHHHHHHHH")

/obj/item/weapon/extraction_pack/proc/can_use_to(atom/movable/target)
	if(istype(target, /obj/effect/extraction_holder)) // This is stupid...
		return FALSE
	return TRUE

/obj/item/weapon/extraction_pack/proc/try_use_fulton(atom/movable/AM, mob/user)
	var/extract_time = 70
	if(!isturf(extraction_point) && !del_target)
		to_chat(user, "<span class='notice'>Error... Extraction point not found.</span>")
		return FALSE
	if(ismob(AM))
		extract_time = 100
	if((AM.anchored && !istype(AM, /obj/mecha)) || !isturf(AM.loc))
		return FALSE
	to_chat(user, "<span class='notice'>You start attaching the pack to [AM]...</span>")
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.w_class <= SIZE_TINY)
			extract_time = 50
		else
			extract_time = w_class * 20 // 3 = 6 seconds, 4 = 8 seconds, 5 = 10 seconds.
	if(!do_after(user, extract_time, target = AM))
		return FALSE
	if(AM.anchored)
		return FALSE
	to_chat(user, "<span class='notice'>You attach the pack to [AM] and activate it.</span>")
	var/image/balloon
	if(isliving(AM))
		var/mob/living/M = AM
		M.Stun(16)
		M.Weaken(16) // Keep them from moving during the duration of the extraction.
		if(M && M.buckled)
			M.buckled.unbuckle_mob()
	else
		AM.anchored = TRUE
		AM.density = FALSE
	var/obj/effect/extraction_holder/holder_obj = new(AM.loc)
	holder_obj.appearance = AM.appearance
	AM.forceMove(holder_obj)
	balloon = image('icons/obj/fulton.dmi', "extraction_balloon")
	balloon.pixel_y = 10
	balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	holder_obj.add_overlay(balloon)
	playsound(holder_obj, 'sound/effects/fulext_deploy.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
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
	if(!AM)
		return FALSE

	playsound(holder_obj, 'sound/effects/fultext_launch.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
	new /obj/effect/temp_visual/sparkles(loc)

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		H.say(pick(extraction_appends))
		H.emote("scream")

	if(del_target)
		qdel(AM)
		qdel(holder_obj)
		qdel(BPs)
		return FALSE

	holder_obj.forceMove(extraction_point)
	new /obj/effect/temp_visual/sparkles(loc)

	qdel(BPs)
	qdel(BPe)

	animate(holder_obj, pixel_z = 15, time = 10)
	sleep(10)
	animate(holder_obj, pixel_z = 10, time = 10)
	sleep(10)
	holder_obj.cut_overlay(balloon)
	if(!AM)
		return FALSE
	AM.anchored = FALSE // An item has to be unanchored to be extracted in the first place.
	AM.density = initial(AM.density)
	animate(holder_obj, pixel_z = 0, time = 5)
	sleep(5)
	AM.forceMove(holder_obj.loc)
	qdel(holder_obj)
	return TRUE

/obj/item/weapon/extraction_pack/afterattack(atom/target, mob/user, proximity, params)
	if(user.is_busy() || !proximity || !ismovable(target))
		return
	if(!can_use_to(target))
		return
	try_use_fulton(target, user)

/obj/effect/extraction_holder
	name = "extraction holder"
	desc = "you shouldnt see this"
	var/atom/movable/stored_obj

// used for accept telecrystal for costly items
/obj/item/weapon/extraction_pack/dealer
	name = "station bounced radio"
	desc = null

	icon = 'icons/obj/radio.dmi'
	icon_state = "walkietalkie"

	w_class = SIZE_TINY

	del_target = TRUE

/obj/item/weapon/extraction_pack/dealer/atom_init(mapload, ...)
	. = ..()
	hidden_uplink = new(src)
	hidden_uplink.uplink_type = "dealer"

/obj/item/weapon/extraction_pack/dealer/attack_self(mob/user)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/weapon/extraction_pack/dealer/can_use_to(atom/movable/target)
	if(!..())
		return FALSE
	if(ismob(target) || istype(target, /obj/structure/closet))
		return FALSE
	return TRUE

/obj/item/weapon/extraction_pack/dealer/try_use_fulton(atom/movable/target, mob/user)
	if(!isgundealer(user))
		return FALSE
	if(isitem(target))
		for(var/item in global.lowrisk_objectives_cache)
			if(item != target.type)
				continue
			to_chat(user, "<span class='warning'>Этот предмет нужен одной из банд, мы не можем его принять.</span>")
			return FALSE
	RegisterSignal(target, COMSIG_PARENT_QDELETING, CALLBACK(src, PROC_REF(give_telecrystal), target.type, user))
	if(!..())
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
		return FALSE
	return TRUE

/obj/item/weapon/extraction_pack/dealer/proc/give_telecrystal(atom/movable/target_type, mob/user)
	sleep(10 SECONDS) // signals are called async
	var/datum/role/traitor/dealer/is_traitor = isgundealer(user)
	if(!is_traitor)
		return
	var/datum/component/gamemode/syndicate/S = is_traitor.GetComponent(/datum/component/gamemode/syndicate)
	if(!S)
		return

	var/obj/item/device/uplink/hidden/guplink = find_syndicate_uplink(user)
	if(!guplink)
		to_chat(user, "<span class='warning'>Датчики показывают, что ВАШ аплинк находится НЕ У ВАС. Телекристаллы не будут отосланы.</span>")
		return
	if(initial(target_type.price) < 1000)
		to_chat(user, "<span class='warning'>Эта безделушка нам не нужна. Телекристаллы не будут отосланы.</span>")
		return
	var/telecrystals = min(30, round(initial(target_type.price) / 1000))
	var/sended_crystals_ru = pluralize_russian(telecrystals, "Был выслан [telecrystals] телекристалл", "Было выслано [telecrystals] телекристалла", "Было выслано [telecrystals] телекристаллов")
	to_chat(user, "<span class='warning'>Посылка была принята. [sended_crystals_ru].</span>")

	guplink.uses += telecrystals
	S.total_TC += telecrystals

/obj/item/weapon/extraction_pack/pirates
	del_target = TRUE

/obj/item/weapon/extraction_pack/pirates/examine(mob/user)
	..()
	if(src in view(1, user))
		var/datum/faction/responders/pirates/P = find_faction_by_type(/datum/faction/responders/pirates)
		if(!P)
			return
		to_chat(user, "Plundered treasure: [P.booty] doubloons!")

/obj/item/weapon/extraction_pack/pirates/can_use_to(atom/movable/target)
	if(!..())
		return FALSE
	if(ismob(target) || istype(target, /obj/structure/closet))
		return FALSE
	return TRUE

/obj/item/weapon/extraction_pack/pirates/try_use_fulton(atom/movable/target, mob/user)
	RegisterSignal(target, COMSIG_PARENT_QDELETING, CALLBACK(src, PROC_REF(sell), target.type, user))
	if(!..())
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
		return FALSE
	return TRUE

/obj/item/weapon/extraction_pack/pirates/proc/sell(atom/movable/target_type, mob/user)
	sleep(10 SECONDS) // signals are called async
	var/datum/faction/responders/pirates/P = find_faction_by_type(/datum/faction/responders/pirates)
	if(!P)
		return

	var/obj/O = target_type
	if(!initial(O.price))
		return

	P.booty += initial(O.price)
	to_chat(user, "Plundered [initial(O.price)] doubloons!")
