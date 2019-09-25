var/global/obj/machinery/vending/tophat_vend/tophat_vend
var/global/obj/effect/tophat_portal/tophat_portal
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
	if(tophat_vend)
		return INITIALIZE_HINT_QDEL
	tophat_vend = src


/obj/machinery/vending/tophat_vend/Destroy()
	if(tophat_vend == src)
		tophat_vend = null
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
		M.a_intent = I_HURT
		M.equip_to_slot(new /obj/item/clothing/head/rabbitears(M), SLOT_HEAD)
		break
	return M



/obj/effect/tophat_portal
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by unknown forces."

	var/diving_in = FALSE

/obj/effect/tophat_portal/atom_init()
	. = ..()
	if(tophat_portal)
		return INITIALIZE_HINT_QDEL
	tophat_portal = src

/obj/effect/tophat_portal/Destroy()
	if(tophat_portal == src)
		tophat_portal = null
	return ..()

/obj/effect/tophat_portal/proc/go_into(atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		to_chat(M, "<span class='warning'>You feel dizzy, as you exit through [src]!</span>")

	var/list/pos_turfs = get_area_turfs(/area/tophat)
	if(pos_turfs.len)
		AM.forceMove(get_turf(src))
		AM.throw_at(pick(pos_turfs), 4, 2)

/obj/effect/tophat_portal/proc/tp_to_tophat(atom/movable/AM)
	if(diving_in)
		return
	diving_in = TRUE

	var/obj/item/clothing/head/wizard/tophat/TP = pick(tophats_list)
	if(TP)
		AM.forceMove(get_turf(src))
		var/matrix/saved_transform = matrix(AM.transform)
		var/saved_alpha = AM.alpha
		var/saved_pixel_y = AM.pixel_y

		var/matrix/M = matrix()
		M.Scale(0.5)
		animate(AM, pixel_y=AM.pixel_y + 32, transform=M, time=5)
		sleep(5)

		AM.visible_message("<span class='warning'>[AM] dissapears into [src]!</span>")

		if(!isturf(TP.loc))
			if(ismob(TP.loc))
				var/mob/M_loc = TP.loc
				M_loc.drop_from_inventory(TP)
			TP.visible_message("<span class='warning'>[TP] jumps out of [loc]!</span>")
			TP.forceMove(get_turf(TP))

		AM.forceMove(get_turf(TP))
		var/list/pos_turfs = get_area_turfs(get_area(TP))
		if(pos_turfs.len)
			AM.throw_at(pick(pos_turfs), 4, 2)

		animate(AM, pixel_y=saved_pixel_y, transform=saved_transform, time=3, alpha=saved_alpha)
		sleep(3)
	diving_in = FALSE

/obj/effect/tophat_portal/attackby(obj/item/I, mob/user)
	if(!user.mind || user.mind.special_role != "Wizard")
		return

	user.drop_from_inventory(I)
	tp_to_tophat(I)

/obj/effect/tophat_portal/MouseDrop_T(atom/movable/AM, mob/user)
	if(!istype(AM))
		return
	if(!isturf(AM.loc) && AM.loc != user)
		return
	if(AM.anchored)
		return
	if(tophats_list.len == 0)
		return
	if(!user.mind || user.mind.special_role != "Wizard")
		if(AM == user)
			to_chat(user, "<span class='notice'>You begin your maddening descent into [src]...</span>")
			if(do_after(user, 2 MINUTES, target=src))
				tp_to_tophat(user)
		return

	if(AM in user)
		user.drop_from_inventory(AM)
	tp_to_tophat(AM)



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

/obj/item/clothing/head/wizard/tophat/atom_init()
	. = ..()
	tophats_list += src

	var/matrix/M = matrix()
	M.Turn(180)
	animate(src, transform=M, time=3)

/obj/item/clothing/head/wizard/tophat/Destroy()
	tophats_list -= src

	var/turf/src_turf = get_turf(src)

	var/list/pos_turfs = get_area_turfs(get_area(src))
	if(pos_turfs.len && src_turf)
		visible_message("<span class='danger'>[src] rips and tears, as EVERYTHING flies out of it...</span>")

		var/list/to_exit = get_area_turfs(/area/tophat)

		for(var/turf/T in to_exit)
			for(var/atom/movable/AM in T)
				if(!istype(AM, /obj/effect/tophat_portal))
					AM.anchored = FALSE
					AM.forceMove(src_turf)
					AM.throw_at(pick(pos_turfs), 4, 2)

	return ..()

/obj/item/clothing/head/wizard/tophat/proc/try_get_monkey(mob/living/target)
	var/obj/machinery/vending/tophat_vend/TP = tophat_vend
	if(TP)
		var/mob/living/carbon/monkey/M = TP.get_bunnymonkey()
		if(M)
			return M.get_scooped(target)
		else
			to_chat(target, "<span class='warning'>You pull at nothing, and don't pull out anything...</span>")
	return FALSE

// Returns TRUE on succesful mousetrapping.
/obj/item/clothing/head/wizard/tophat/proc/try_mousetrap(mob/living/target)
	var/obj/machinery/vending/tophat_vend/TP = tophat_vend
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

/obj/item/clothing/head/wizard/tophat/pickup()
	..()
	var/matrix/M = matrix()
	animate(src, transform=M, time=3)

/obj/item/clothing/head/wizard/tophat/dropped()
	..()
	var/matrix/M = matrix()
	M.Turn(180)
	animate(src, transform=M, time=3)

/obj/item/clothing/head/wizard/tophat/proc/drop_into(atom/movable/AM, mob/user)
	if(diving_in)
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
	tophat_portal.go_into(AM)

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
	if(!user.mind || user.mind.special_role != "Wizard")
		return
	if(!tophat_portal)
		to_chat(user, "<span class='warning'>Are you crazy? This hat could never fit [AM] in...</span>")
		return

	var/put_in_delay = 0
	if(user == AM)
		put_in_delay += 5 // Most of the delay will come in dive_into proc.
	else if(istype(AM, /obj/item))
		var/obj/item/I = AM
		put_in_delay += I.w_class * 2 SECONDS
	else if(istype(AM, /obj/structure) || istype(AM, /obj/machinery))
		put_in_delay += 8 SECONDS
	else if(istype(AM, /mob/living))
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

/obj/item/clothing/head/wizard/tophat/attackby(obj/item/I, mob/living/user)
	if(I.w_class <= w_class)
		if(!tophat_portal)
			to_chat(user, "<span class='warning'>Are you crazy? This hat could never fit [I] in...</span>")
			return
		user.drop_from_inventory(I)
		drop_into(I, user)
		return
	if(user.mind && user.mind.special_role == "Wizard")
		user.drop_from_inventory(I)
		drop_into(I, user)
		return
	..()

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

/obj/item/clothing/head/wizard/tophat/on_stripPanelUnEquip(mob/living/who, strip_gloves = FALSE)
	return !try_mousetrap(who)
