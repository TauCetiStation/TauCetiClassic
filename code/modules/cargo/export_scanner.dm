/obj/item/device/export_scanner
	name = "export scanner"
	desc = "A device used to check objects price and sell them. Use it to switch modes."
	icon_state = "export_scanner"
	item_state = "radio"
	flags = NOBLUDGEON
	w_class = SIZE_TINY
	siemens_coefficient = 1
	var/export_mode = FALSE

/obj/item/device/export_scanner/attack_self(mob/user)
	if(export_mode)
		export_mode = FALSE
		to_chat(user, "<span class='warning'>Export Scanner mode changed to CHECK PRICE.</span>")
	else
		export_mode = TRUE
		to_chat(user, "<span class='warning'>Export Scanner mode changed to SELL OBJECT.</span>")

/obj/item/device/export_scanner/attack(mob/living/M, mob/user, def_zone)
	if(!isliving(M) || user.is_busy())
		return
	var/price = 0

	var/list/contents = M.GetAllContents()

	for(var/i in reverseRange(contents))
		var/atom/movable/thing = i
		price += thing.get_price()

	if(export_mode) // were selling the atom
		if(istype(get_area(user), /area/shuttle/trader)) // is on shuttle?
			try_selling(M, user, price)
		else
			to_chat(user, "<span class='warning'>You need to be on the traders shuttle to sell items.</span>")
	else // were checking the atom price
		if(price)
			to_chat(user, "<span class='notice'>Scanned [M], value: <b>[price]</b> \
				credits[M.contents.len ? " (contents included)" : ""].</span>")
		else
			to_chat(user, "<span class='warning'>Scanned [M], no export value. \
				</span>")

/obj/item/device/export_scanner/afterattack(atom/movable/target, mob/user, proximity, params)
	if(!istype(target) || !proximity || user.is_busy())
		return
	var/price = 0

	var/list/contents = target.GetAllContents()

	for(var/i in reverseRange(contents))
		var/atom/movable/thing = i
		price += thing.get_price()

	if(export_mode) // were selling the atom
		if(istype(get_area(user), /area/shuttle/trader)) // is on shuttle?
			try_selling(target, user, price)
		else
			to_chat(user, "<span class='warning'>You need to be on the traders shuttle to sell items.</span>")
	else // were checking the atom price
		if(price)
			to_chat(user, "<span class='notice'>Scanned [target], value: <b>[price]</b> \
				credits[target.contents.len ? " (contents included)" : ""].</span>")
		else
			to_chat(user, "<span class='warning'>Scanned [target], no export value. \
				</span>")

/obj/item/device/export_scanner/proc/try_selling(atom/movable/AM, mob/user, price)
	var/extract_time = 30
	if(ismob(AM))
		extract_time = 50
	if(AM.anchored && !istype(AM, /obj/mecha) )
		to_chat(user, "<span class='warning'>Cant sell [AM], its bolted down...</span>")
		return FALSE
	if(!isturf(AM.loc))
		to_chat(user, "<span class='warning'>Unpack it on the floor first!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You start trying to sell the [AM]...</span>")
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.w_class <= SIZE_TINY)
			extract_time = 10
		else
			extract_time = w_class * 5 // 3 = 1.5 seconds, 4 = 2 seconds, 5 = 2.5 seconds.
	if(!do_after(user, extract_time, target = AM))
		return FALSE
	if(AM.anchored)
		to_chat(user, "<span class='warning'>Cant sell [AM], its bolted down...</span>")
		return FALSE
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
		H.emote("scream")

	qdel(AM)
	qdel(holder_obj)
	qdel(BPs)
	new /obj/effect/temp_visual/sparkles(loc)
	global.donkandco_balance_sold += price
	to_chat(user, "<span class='notice'>You succesfully sold the [AM] for <b>[price]</b> credits! Our balance is now [global.donkandco_balance_sold] credits total.</span>")
	return TRUE
