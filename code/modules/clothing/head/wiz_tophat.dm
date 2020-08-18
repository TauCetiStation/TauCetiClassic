var/global/obj/machinery/vending/tophat_vend/tophat_vend
var/global/obj/effect/overlay/tophat_portal/tophat_portal
var/global/list/tophats_list = list()

/obj/machinery/vending/tophat_vend
	name = "Tophat-Vend"
	desc = "A marvel, on the brink of technobabble and pixie fiction."
	icon_state = "MagiVend"
	light_color = "#97429a"
	products = list(/mob/living/carbon/monkey = 42,
	                /mob/living/carbon/monkey/tajara = 2,
	                /mob/living/carbon/monkey/skrell = 2,
	                /mob/living/carbon/monkey/unathi = 2,
	                /mob/living/carbon/monkey/diona = 2
	)
	prices = list()
	contraband = list(/obj/item/device/assembly/mousetrap = 10)
	premium = list()
	product_slogans = "Do a funky monkey!;Monkey them up!;Get monkeying!"
	product_ads = "Sometimes I dream about cheese.;When will this all end, will you stil be with me?"
	vend_reply = "Ooh-ooh-aah-aah"
	product_slogans = "Amicitiae nostrae memoriam spero sempiternam fore;Aequam memento rebus in arduis servare mentem;Vitanda est improba siren desidia;Serva me, servabo te;Faber est suae quisque fortunae"
	vend_reply = "Have fun! No returns!"

/obj/machinery/vending/tophat_vend/atom_init()
	. = ..()
	if(global.tophat_vend)
		return INITIALIZE_HINT_QDEL
	global.tophat_vend = src

/obj/machinery/vending/tophat_vend/Destroy()
	if(global.tophat_vend == src)
		global.tophat_vend = null
	return ..()

/obj/machinery/vending/tophat_vend/proc/get_mousetrap()
	var/obj/item/device/assembly/mousetrap/MS = null
	for(var/datum/data/vending_product/R in shuffle(src.hidden_records))
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue

		MS = new dump_path(null)
		if(!istype(MS))
			continue
		R.amount--
		break
	return MS

/obj/machinery/vending/tophat_vend/proc/get_bunnymonkey()
	var/mob/living/carbon/monkey/M = null
	for(var/datum/data/vending_product/R in shuffle(src.product_records))
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue

		M = new dump_path(null)
		if(!istype(M))
			continue

		R.amount--
		M.a_intent = INTENT_HARM
		M.equip_to_slot(new /obj/item/clothing/head/rabbitears(M), SLOT_HEAD)
		break
	return M



/obj/effect/overlay/tophat_portal
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by unknown forces."

	anchored = TRUE

	var/diving_in = FALSE

/obj/effect/overlay/tophat_portal/atom_init()
	. = ..()
	if(global.tophat_portal)
		return INITIALIZE_HINT_QDEL
	global.tophat_portal = src

/obj/effect/overlay/tophat_portal/Destroy()
	if(global.tophat_portal == src)
		global.tophat_portal = null
	return ..()

/obj/effect/overlay/tophat_portal/proc/go_into(atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		to_chat(M, "<span class='warning'>You feel dizzy, as you exit through [src]!</span>")

	var/list/pos_turfs = get_area_turfs(/area/custom/tophat)
	if(pos_turfs.len && loc != null)
		AM.forceMove(loc)
		AM.throw_at(pick(pos_turfs), 4, 2)

/obj/effect/overlay/tophat_portal/proc/tp_to_tophat(atom/movable/AM)
	if(!global.tophats_list.len)
		return
	if(diving_in)
		return
	if(!loc)
		return
	if(AM.flags & ABSTRACT)
		return
	if(istype(AM, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = AM
		AM = G.affecting
		if(ismob(G.loc))
			var/mob/M = G.loc
			M.drop_from_inventory(G)

	. = TRUE
	if(ismob(AM.loc))
		var/mob/M = AM.loc
		. = M.drop_from_inventory(AM)
	else if(istype(AM.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = AM.loc
		. = S.remove_from_storage(AM)
	if(!.)
		return

	diving_in = TRUE

	var/obj/item/clothing/head/wizard/tophat/TP = pick(global.tophats_list)
	if(TP && TP.loc)
		AM.forceMove(loc)

		var/matrix/saved_transform = matrix(AM.transform)
		var/saved_alpha = AM.alpha
		var/saved_pixel_y = AM.pixel_y

		var/matrix/M = matrix()
		M.Scale(0.5)
		animate(AM, pixel_y=AM.pixel_y + 32, transform=M, time=5)
		sleep(5)

		AM.visible_message("<span class='warning'>[AM] dissapears into [src]!</span>")

		var/atom/move_AM_to = TP.jump_out()
		AM.forceMove(move_AM_to)
		AM.visible_message("<span class='warning'>[AM] flies out of [TP]!</span>")

		var/list/pos_turfs = get_area_turfs(get_area(TP))
		if(pos_turfs && pos_turfs.len)
			AM.throw_at(pick(pos_turfs), 4, 2)

		animate(AM, pixel_y=saved_pixel_y, transform=saved_transform, time=3, alpha=saved_alpha)
		sleep(3)
	diving_in = FALSE

/obj/effect/overlay/tophat_portal/attackby(obj/item/I, mob/user)
	tp_to_tophat(I)
	return TRUE

/obj/effect/overlay/tophat_portal/Crossed(atom/movable/AM)
	. = ..()
	if(AM.throwing)
		tp_to_tophat(AM)

/obj/effect/overlay/tophat_portal/MouseDrop_T(atom/movable/AM, mob/user)
	if(!istype(AM))
		return
	if(!isturf(AM.loc) && AM.loc != user)
		return
	if(AM.anchored)
		return
	if(!tophats_list.len)
		return
	if(user.incapacitated())
		return
	if(!user.mind || user.mind.special_role != "Wizard")
		if(AM == user)
			to_chat(user, "<span class='notice'>You begin your maddening descent into [src]...</span>")
			if(do_after(user, 2 MINUTES, target=src))
				tp_to_tophat(user)
		return

	tp_to_tophat(AM)

/obj/effect/overlay/tophat_portal/examine(mob/living/user)
	..()
	if(user.client && global.tophats_list.len && in_range(user, src))
		user.visible_message("<span class='notice'>[user] peaks through [src].</span>", "<span class='notice'>You peak through [src].</span>")
		var/obj/item/clothing/head/wizard/tophat/TP = pick(global.tophats_list)

		if(TP)
			user.force_remote_viewing = TRUE
			user.reset_view(TP)

			for(var/i in 1 to 30)
				if(do_after(user, 1 SECONDS, needhand = FALSE, target = src, progress = FALSE))
					user.reset_view(TP)
				else
					break

			user.reset_view(null)
			user.force_remote_viewing = FALSE

/obj/effect/overlay/tophat_portal/get_listeners()
	. = list()
	for(var/obj/item/clothing/head/wizard/tophat/TP in global.tophats_list)
		. += hearers(7, TP)

/obj/effect/overlay/tophat_portal/get_listening_objs()
	. = list()
	for(var/obj/item/clothing/head/wizard/tophat/TP in global.tophats_list)
		for(var/obj/O in hear(7, TP))
			. += O



/obj/item/clothing/head/wizard/tophat
	name = "top hat"
	desc = "You feel as if a bunch of rabbits could fit in it. Or perhaps monkeys."
	icon_state = "tophat"
	item_state = "that"
	siemens_coefficient = 0.9
	body_parts_covered = 0

	var/next_trick = 0
	var/trick_delay = 1 SECOND

	var/diving_in = FALSE

	var/jump_out_to_types = list(
								/mob,
								/obj/item/weapon/storage,
								/obj/structure/closet,
								/turf
							 )

/obj/item/clothing/head/wizard/tophat/atom_init()
	. = ..()
	global.tophats_list += src

	if(isturf(loc))
		var/matrix/M = matrix()
		M.Turn(180)
		animate(src, transform=M, time=3)

/obj/item/clothing/head/wizard/tophat/Destroy()
	global.tophats_list -= src

	var/turf/src_turf = get_turf(src)

	var/list/pos_turfs = get_area_turfs(get_area(src))
	if(pos_turfs && pos_turfs.len && src_turf)
		visible_message("<span class='danger'>[src] rips and tears, as EVERYTHING flies out of it...</span>")

		var/list/to_exit = get_area_turfs(/area/custom/tophat)

		for(var/turf/T in to_exit)
			for(var/atom/movable/AM in T)
				if(!istype(AM, /obj/effect/overlay/tophat_portal))
					AM.anchored = FALSE
					AM.forceMove(src_turf)
					AM.throw_at(pick(pos_turfs), 4, 2)

	return ..()

/obj/item/clothing/head/wizard/tophat/proc/try_get_monkey(mob/living/target)
	var/obj/machinery/vending/tophat_vend/TP = global.tophat_vend
	if(TP)
		var/mob/living/carbon/monkey/M = TP.get_bunnymonkey()
		if(M)
			return M.get_scooped(target)
		else
			to_chat(target, "<span class='warning'>You pull at nothing, and don't pull out anything...</span>")
	return FALSE

// Returns TRUE on succesful mousetrapping.
/obj/item/clothing/head/wizard/tophat/proc/try_mousetrap(mob/living/target)
	var/obj/machinery/vending/tophat_vend/TP = global.tophat_vend
	if(TP)
		var/obj/item/device/assembly/mousetrap/MT = TP.get_mousetrap()
		if(MT)
			MT.armed = TRUE
			MT.triggered(target, target.hand ? BP_L_ARM : BP_R_ARM)
			target.visible_message("<span class='warning'>[target] accidentally sets off [src], breaking their fingers.</span>",
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			MT.forceMove(target.loc)
			return TRUE
	return FALSE

/obj/item/clothing/head/wizard/tophat/pickup(mob/living/user)
	..()
	var/matrix/M = matrix()
	animate(src, transform=M, time=3)

/obj/item/clothing/head/wizard/tophat/dropped()
	..()
	var/matrix/M = matrix()
	M.Turn(180)
	animate(src, transform=M, time=3)

/obj/item/clothing/head/wizard/tophat/proc/jump_out(rec_level = 3)
	/*
	This proc performs a magic trick of hat jumping out of inventories, closets, etc.
	Return the object a person teleporting to the hat should teleport to.

	rec_level = 3 means we can jump out of a storage in a mob in a closet.
	*/

	if(rec_level > 0 && is_type_in_list(loc.loc, jump_out_to_types))
		if(ismob(loc))
			var/mob/M_loc = loc
			if(M_loc.get_active_hand() == src || M_loc.get_inactive_hand() == src)
				visible_message("<span class='warning'>[src] jumps out of [M_loc]'s hands!</span>")
			else
				visible_message("<span class='warning'>[src] jumps out of [M_loc]!</span>")

			M_loc.drop_from_inventory(src, M_loc.loc)

			return jump_out(rec_level = rec_level - 1)

		else if(istype(loc, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = loc
			if(S.remove_from_storage(src, S.loc))
				visible_message("<span class='warning'>[src] jumps out of [S]!</span>")

				if(ismob(loc))
					return jump_out(rec_level = rec_level) // So we don't have problems getting out of mobs...

				return jump_out(rec_level = rec_level - 1)

		else if(istype(loc, /obj/structure/closet))
			var/obj/structure/closet/CL = loc
			if(!CL.opened && CL.open())
				visible_message("<span class='warning'>[src] jumps out of [CL]!</span>")

				return jump_out(rec_level = rec_level - 1)

	return get_turf(src)

/obj/item/clothing/head/wizard/tophat/proc/drop_into(atom/movable/AM, mob/user)
	if(diving_in)
		return
	if(!global.tophat_portal || !global.tophat_portal.loc)
		return
	if(AM.flags & ABSTRACT)
		return
	if(istype(AM, /obj/item/weapon/grab))
		return

	. = TRUE
	if(AM.loc == user)
		. = user.drop_from_inventory(AM)
	else if(istype(AM.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = AM.loc
		. = S.remove_from_storage(AM)
	if(!.)
		return

	diving_in = TRUE

	AM.forceMove(get_turf(src))

	var/matrix/saved_transform = matrix(user.transform)
	var/saved_alpha = user.alpha
	if(AM == user)
		var/matrix/M = matrix()
		var/angle = pick(90, -90)
		M.Turn(angle)
		animate(user, pixel_y=user.pixel_y + 5, transform=M, time=5)
		sleep(5)
		M.Turn(angle)
		M.Scale(0.5)
		animate(user, pixel_y=user.pixel_y - 5, transform=M, time=5, alpha=100)
		sleep(5)

	user.visible_message("<span class='warning'>[AM] dissapears into [src]!</span>")
	global.tophat_portal.go_into(AM)

	if(AM == user)
		animate(user, transform=saved_transform, time=3, alpha=saved_alpha)
		sleep(3)
	diving_in = FALSE

/obj/item/clothing/head/wizard/tophat/MouseDrop_T(atom/movable/AM, mob/user)
	if(!istype(AM))
		return
	if(AM == src)
		return
	if(!isturf(AM.loc) && AM.loc != user)
		return
	if(AM.anchored)
		return
	if(user.incapacitated())
		return
	if(!user.mind || user.mind.special_role != "Wizard")
		return
	if(!global.tophat_portal)
		to_chat(user, "<span class='warning'>Are you crazy? This hat could never fit [AM] in...</span>")
		return

	if(istype(AM, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = AM
		AM = G.affecting

	var/put_in_delay = 0
	if(user == AM)
		put_in_delay += 5 // Most of the delay will come in dive_into proc.
	else if(istype(AM, /obj/item))
		var/obj/item/I = AM
		put_in_delay += I.w_class * 2 SECONDS
	else if(istype(AM, /obj/structure) || istype(AM, /obj/machinery))
		put_in_delay += 8 SECONDS
	else if(isliving(AM))
		var/mob/living/L = AM
		switch(L.stat)
			if(CONSCIOUS)
				put_in_delay += 20 SECONDS
			if(UNCONSCIOUS)
				put_in_delay += 20 SECONDS
			if(DEAD)
				put_in_delay += 5 SECONDS
		for(var/obj/item/weapon/grab/G in L.grabbed_by)
			if(G.assailant == user)
				put_in_delay -= G.state * 1 SECOND
				break
		if(L.incapacitated()) // If they are DEAD or UNCONSCIOUS, this will proc too.
			put_in_delay *= 0.5
	else if(istype(AM, /mob/dead))
		put_in_delay += 1 SECOND // If we see a ghost, let 'em get in...

	if(put_in_delay == 0)
		to_chat(user, "<span class='warning'>You can't put [AM] into [src]!</span>")
		return

	if(user == AM)
		user.visible_message("<span class='warning'>[user] prepares to dive into [src]!</span>",
							 "<span class='warning'>You prepare to dive into [src]!</span>")
	else
		user.visible_message("<span class='warning'>[user] is trying to stuff [AM] into [src]!</span>",
							 "<span class='warning'>You are trying to stuff [AM] into [src]!</span>")
	if(do_after(user, put_in_delay, target=AM))
		if(!isturf(loc))
			if(ismob(loc))
				var/mob/M = loc
				M.drop_from_inventory(src)
			if(istype(loc, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/S = loc
				S.remove_from_storage(src)
			forceMove(get_turf(src))
		if(AM in user)
			user.drop_from_inventory(AM)
		drop_into(AM, user)

/obj/item/clothing/head/wizard/tophat/attackby(obj/item/I, mob/user, params)
	if(I.w_class <= w_class)
		if(!global.tophat_portal)
			to_chat(user, "<span class='warning'>Are you crazy? This hat could never fit [I] in...</span>")
			return
		drop_into(I, user)
		return TRUE
	if(user.mind && user.mind.special_role == "Wizard")
		drop_into(I, user)
		return TRUE
	return ..()

/obj/item/clothing/head/wizard/tophat/attack_hand(mob/living/user)
	if(user.get_active_hand() == src || user.get_inactive_hand() == src)
		if(next_trick > world.time)
			to_chat(user, "<span class='notice'>There's nothing in the hat.</span>")
			return
		next_trick = world.time + trick_delay
		if(user.mind && user.mind.special_role == "Wizard")
			if(try_get_monkey(user))
				user.visible_message("<span class='notice'>[user] takes something big out of [src]!</span>",
									 "<span class='notice'>You take something unproportionally big out of [src].</span>")
		else
			if(try_mousetrap(user))
				user.visible_message("<span class='warning'>[user] stumbles on a mousetrap, as he reaches into [src]!</span>",
									 "<span class='warning'>As you reach into [src], you stumble on a mousetrap!</span>")
	else
		..()

/obj/item/clothing/head/wizard/tophat/onStripPanelUnEquip(mob/living/who, strip_gloves = FALSE)
	return !try_mousetrap(who)

/obj/item/clothing/head/wizard/tophat/get_listeners()
	. = list()
	if(global.tophat_portal)
		. += hearers(7, global.tophat_portal)

/obj/item/clothing/head/wizard/tophat/get_listening_objs()
	. = list()
	if(global.tophat_portal)
		for(var/obj/O in hear(7, global.tophat_portal))
			. += O
