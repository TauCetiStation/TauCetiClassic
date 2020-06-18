/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Crayon Box
 *		Glowsticks Box
 *		Cigarette Box
 */

/obj/item/weapon/storage/fancy
	icon = 'icons/obj/food.dmi'
	icon_state = "donutbox6"
	name = "donut box"
	desc = "Very tasty donuts. Security staff will rate them."
	var/icon_type = "donut"

/obj/item/weapon/storage/fancy/update_icon(itemremoved = 0)
	var/total_contents = src.contents.len - itemremoved
	src.icon_state = "[src.icon_type]box[total_contents]"
	return

/obj/item/weapon/storage/fancy/examine(mob/user)
	..()
	if(src in view(1, user))
		if(contents.len <= 0)
			to_chat(user, "There are no [src.icon_type]s left in the box.")
		else if(contents.len == 1)
			to_chat(user, "There is one [src.icon_type] left in the box.")
		else
			to_chat(user, "There are [src.contents.len] [src.icon_type]s in the box.")


/*
 * Donut Box
 */

/obj/item/weapon/storage/fancy/donut_box
	icon = 'icons/obj/food.dmi'
	icon_state = "donutbox6"
	icon_type = "donut"
	name = "donut box"
	storage_slots = 6
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/donut)


/obj/item/weapon/storage/fancy/donut_box/atom_init()
	. = ..()
	for (var/i in 1 to storage_slots)
		new /obj/item/weapon/reagent_containers/food/snacks/donut/normal(src)

/*
 * Egg Box
 */

/obj/item/weapon/storage/fancy/egg_box
	icon = 'icons/obj/food.dmi'
	icon_state = "eggbox"
	icon_type = "egg"
	name = "egg box"
	storage_slots = 12
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/egg)

/obj/item/weapon/storage/fancy/egg_box/atom_init()
	. = ..()
	for (var/i in 1 to storage_slots)
		new /obj/item/weapon/reagent_containers/food/snacks/egg(src)

/*
 * Candle Box
 */

/obj/item/weapon/storage/fancy/candle_box
	name = "white candle pack"
	desc = "A pack of white candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox"
	icon_type = "candle"
	item_state = "candlebox"
	storage_slots = 5
	throwforce = 2
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_BELT
	var/candle_type = "white"

/obj/item/weapon/storage/fancy/candle_box/atom_init()
	. = ..()
	if(candle_type == "white")
		for (var/i in 1 to storage_slots)
			new /obj/item/candle(src)
	if(candle_type == "red")
		for (var/i in 1 to storage_slots)
			new /obj/item/candle/red(src)
	update_icon()

/obj/item/weapon/storage/fancy/candle_box/update_icon()
	var/list/candle_overlays = list()
	var/candle_position = 0
	for(var/obj/item/candle/C in contents)
		candle_position ++
		var/candle_color = "red_"
		if(C.name == "white candle")
			candle_color = "white_"
		if(C.name == "black candle")
			candle_color = "black_"
		candle_overlays += image('icons/obj/candle.dmi', "[candle_color][candle_position]")
	cut_overlays()
	add_overlay(candle_overlays)
	return

/obj/item/weapon/storage/fancy/candle_box/red
	name = "red candle pack"
	desc = "A pack of red candles."
	candle_type = "red"

/obj/item/weapon/storage/fancy/black_candle_box
	name = "black candle pack"
	desc = "A pack of black candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "black_candlebox5"
	icon_type = "black_candle"
	item_state = "black_candlebox5"
	storage_slots = 5
	throwforce = 2
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_BELT
	var/cooldown = 0
	var/teleporter_delay = 0

/obj/item/weapon/storage/fancy/black_candle_box/atom_init()
	. = ..()
	for (var/i in 1 to storage_slots)
		new /obj/item/candle/ghost(src)
	START_PROCESSING(SSobj, src)

/obj/item/weapon/storage/fancy/black_candle_box/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/storage/fancy/black_candle_box/process()
	if(cooldown > 0)
		cooldown--
	else
		cooldown = 300

		if(contents.len >= storage_slots)
			return

		for(var/mob/living/M in viewers(7, loc))
			return

		for(var/obj/item/candle/ghost/CG in range(1, get_turf(src)))
			loc.visible_message("<span class='warning'>[src] is nomming on [CG]... This looks oddly creepy.</span>")
			CG.forceMove(src)
			update_icon()
			break

		teleporter_delay--
		if(teleporter_delay <= 0)
			for(var/obj/item/candle/ghost/target in ghost_candles)
				if(istype(target.loc, /turf))
					loc.visible_message("<span class='warning'>You hear a loud pop, as [src] poofs out of existence.</span>")
					playsound(src, 'sound/effects/bubble_pop.ogg', VOL_EFFECTS_MASTER)
					forceMove(get_turf(target))
					visible_message("<span class='warning'>You hear a loud pop, as [src] poofs into existence.</span>")
					playsound(src, 'sound/effects/bubble_pop.ogg', VOL_EFFECTS_MASTER)
					for(var/mob/living/A in viewers(3, loc))
						A.confused += 10
						A.make_jittery(150)
					break
			teleporter_delay += rand(5,10) // teleporter_delay-- is ran only once half a minute. This seems reasonable.

/obj/item/weapon/storage/fancy/black_candle_box/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")

	else
		return ..()

/*
 * Crayon Box
 */

/obj/item/weapon/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox_preview"
	w_class = ITEM_SIZE_SMALL
	storage_slots = 6
	icon_type = "crayon"
	can_hold = list(
		/obj/item/toy/crayon
	)

/obj/item/weapon/storage/fancy/crayons/atom_init()
	. = ..()
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	update_icon()

/obj/item/weapon/storage/fancy/crayons/update_icon()
	cut_overlays() //resets list
	add_overlay(image('icons/obj/crayons.dmi',"crayonbox"))
	for(var/obj/item/toy/crayon/crayon in contents)
		add_overlay(image('icons/obj/crayons.dmi',crayon.colourName))

/obj/item/weapon/storage/fancy/crayons/update_icon()
	var/list/crayon_overlays = list()
	var/crayon_position = 0
	for(var/obj/item/toy/crayon/C in contents)
		var/mutable_appearance/I = mutable_appearance('icons/obj/crayons.dmi', "[C.colourName]")
		I.pixel_x += crayon_position * 2
		crayon_position++
		crayon_overlays += I
	cut_overlays()
	add_overlay(crayon_overlays)
	return

/obj/item/weapon/storage/fancy/crayons/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon/chalk) || istype(I, /obj/item/toy/crayon/spraycan))
		to_chat(user, "\The [I] is too bulky to be contained in [src].")
		return
	return ..()

/*
 * Glowsticks Box
 */

/obj/item/weapon/storage/fancy/glowsticks
	name = "box of glowsticks"
	desc = "A box of glowsticks (Do not eat)."
	icon = 'icons/obj/glowsticks.dmi'
	icon_state = "sticksbox"
	w_class = ITEM_SIZE_SMALL
	storage_slots = 5
	icon_type = "glowstick"
	can_hold = list(
		/obj/item/weapon/reagent_containers/food/snacks/glowstick
	)

/obj/item/weapon/storage/fancy/glowsticks/atom_init()
	. = ..()
	add_stick()
	update_icon()

/obj/item/weapon/storage/fancy/glowsticks/proc/add_stick()
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/green(src)
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/red(src)
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/blue(src)
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/yellow(src)
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/regular/orange(src)

/obj/item/weapon/storage/fancy/glowsticks/update_icon()
	cut_overlays() //resets list
	add_overlay(image('icons/obj/glowsticks.dmi',"sticksbox"))
	for(var/obj/item/weapon/reagent_containers/food/snacks/glowstick/glowstick in contents)
		add_overlay(image('icons/obj/glowsticks.dmi',glowstick.colourName))

/obj/item/weapon/storage/fancy/glowsticks/adv
	name = "box of advanced glowsticks"

/obj/item/weapon/storage/fancy/glowsticks/adv/add_stick()
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/power/green(src)
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/power/red(src)
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/power/blue(src)
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/power/yellow(src)
	new /obj/item/weapon/reagent_containers/food/snacks/glowstick/power/orange(src)

////////////
//CIG PACK//
////////////
/obj/item/weapon/storage/fancy/cigarettes
	name = "cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	w_class = ITEM_SIZE_TINY
	throwforce = 2
	slot_flags = SLOT_FLAGS_BELT
	storage_slots = 6
	can_hold = list(/obj/item/clothing/mask/cigarette, /obj/item/weapon/lighter)
	icon_type = "cigarette"

/obj/item/weapon/storage/fancy/cigarettes/atom_init()
	. = ..()
	flags |= NOREACT
	for(var/i = 1 to storage_slots)
		new /obj/item/clothing/mask/cigarette(src)
	create_reagents(15 * storage_slots)//so people can inject cigarettes without opening a packet, now with being able to inject the whole one

/obj/item/weapon/storage/fancy/cigarettes/update_icon()
	icon_state = "[initial(icon_state)][contents.len]"
	return

/obj/item/weapon/storage/fancy/cigarettes/remove_from_storage(obj/item/W, atom/new_location, NoUpdate = FALSE)
	if(istype(W, /obj/item/clothing/mask/cigarette))
		if(reagents)
			reagents.trans_to(W, (reagents.total_volume/contents.len))
	..()

/obj/item/weapon/storage/fancy/cigarettes/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	if(!istype(M))
		return

	if(M == user && def_zone == O_MOUTH && contents.len > 0 && !user.wear_mask)
		var/has_cigarette = 0
		for(var/obj/item/I in contents)
			if(istype(I, /obj/item/clothing/mask/cigarette))
				var/obj/item/clothing/mask/cigarette/C = I
				has_cigarette = 1
				contents.Remove(C)
				user.equip_to_slot_if_possible(C, SLOT_WEAR_MASK)
				to_chat(user, "<span class='notice'>You take a cigarette out of the pack.</span>")
				update_icon()
				break
		if(!has_cigarette)
			to_chat(user, "<span class='notice'>You tried to get any cigarette, but they ran out.</span>")
	else
		..()

/obj/item/weapon/storage/fancy/cigarettes/dromedaryco
	name = "DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "Dpacket"
	item_state = "Dpacket"

/obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate
	name = "unknown"
	desc = "An obscure brand of cigarettes."
	icon_state = "syndie"

/obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate/atom_init()
	. = ..()
	for (var/i in 1 to storage_slots)
		reagents.add_reagent("tricordrazine",15)
	name = "cigarette packet"

/obj/item/weapon/storage/fancy/cigarettes/menthol
	name = "Uplit Cigs"
	desc = "A packet of six menthol cigarettes."
	icon_state = "ucig"

/*
 * Vial Box
 */

/obj/item/weapon/storage/fancy/vials
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox6"
	icon_type = "vial"
	name = "vial storage box"
	storage_slots = 6
	can_hold = list(/obj/item/weapon/reagent_containers/glass/beaker/vial)


/obj/item/weapon/storage/fancy/vials/atom_init()
	. = ..()
	for (var/i in 1 to storage_slots)
		new /obj/item/weapon/reagent_containers/glass/beaker/vial(src)

/obj/item/weapon/storage/lockbox/vials
	name = "secure vial storage box"
	desc = "A locked box for keeping things away from children."
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox0"
	item_state = "syringe_kit"
	max_w_class = ITEM_SIZE_NORMAL
	can_hold = list(/obj/item/weapon/reagent_containers/glass/beaker/vial)
	storage_slots = 6
	req_access = list(access_virology)

/obj/item/weapon/storage/lockbox/vials/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/storage/lockbox/vials/update_icon(itemremoved = 0)
	var/total_contents = src.contents.len - itemremoved
	src.icon_state = "vialbox[total_contents]"
	src.cut_overlays()
	if (!broken)
		add_overlay(image(icon, src, "led[locked]"))
		if(locked)
			add_overlay(image(icon, src, "cover"))
	else
		add_overlay(image(icon, src, "ledb"))
	return

/obj/item/weapon/storage/lockbox/vials/attackby(obj/item/I, mob/user, params)
	. = ..()
	update_icon()
