/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox"
	desc = "A display case for prized possessions."
	density = TRUE
	anchored = TRUE
	unacidable = TRUE
	resistance_flags = UNACIDABLE | CAN_BE_HIT
	armor = list(MELEE = 30, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 70, ACID = 100)
	max_integrity = 200
	integrity_failure = 0.25
	var/obj/item/showpiece = null
	var/alert = TRUE
	var/open = FALSE
	var/broken = FALSE

	var/obj/item/weapon/airlock_electronics/electronics
	///Represents a signel source of screaming when broken (TODO)
	//var/datum/alarm_handler/alarm_manager

	// Tg update_icon workaround
	var/list/managed_overlays

/obj/structure/displaycase/atom_init(mapload)
	. = ..()
	if(ispath(showpiece))
		showpiece = new showpiece(src)
	update_icon()
	//alarm_manager = new(src)

/obj/structure/displaycase/handle_atom_del(atom/A)
	if(A == electronics)
		electronics = null
	else if(A == showpiece)
		showpiece = null
		update_icon()
	return ..()

/obj/structure/displaycase/Destroy()
	QDEL_NULL(electronics)
	QDEL_NULL(showpiece)
	//QDEL_NULL(alarm_manager)
	return ..()

/obj/structure/displaycase/get_examine_string(mob/user)
	. = ..()
	if(alert)
		. += "<br><span class='notice'>Hooked up with an anti-theft system.</span>"
	if(showpiece)
		. += "<br><span class='notice'>There's \a [showpiece] inside.</span>"

/obj/structure/displaycase/proc/dump()
	if(QDELETED(showpiece))
		return
	showpiece.forceMove(loc)
	showpiece = null
	update_icon()

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glasshit.ogg', VOL_EFFECTS_MASTER, 75, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/displaycase/deconstruct(disassembled = TRUE)
	dump()
	if(flags & NODECONSTRUCT)
		return ..()
	if(broken)
		new /obj/item/stack/sheet/glass(loc, 8)
	else if(disassembled)
		new /obj/item/stack/sheet/glass(loc, 10)
	else
		new /obj/item/weapon/shard(loc)
		new /obj/item/stack/sheet/glass(loc, 8)
		trigger_alarm()
	var/obj/structure/displaycase_chassis/chassis = new (loc)
	transfer_fingerprints_to(chassis)
	var/obj/item/weapon/airlock_electronics/AE = electronics
	if(!AE)
		if(length(req_access))
			AE = new(chassis)
			AE.conf_access = req_access
		else if(length(req_one_access))
			AE = new(chassis)
			AE.conf_access = req_one_access
			AE.one_access = TRUE
		else // no electronics & no access requirements -> chassis without electronicst
			return ..()
	else
		electronics = null
		AE.forceMove(chassis)
	chassis.electronics = AE
	..()

/obj/structure/displaycase/atom_break(damage_flag)
	. = ..()
	if(broken || flags & NODECONSTRUCT)
		return

	density = FALSE
	broken = TRUE
	open = TRUE
	new /obj/item/weapon/shard(loc)
	playsound(loc, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER, 70, TRUE)
	update_icon()
	trigger_alarm()

///Anti-theft alarm triggered when broken.
/obj/structure/displaycase/proc/trigger_alarm()
	if(!alert)
		return

	var/area/alarmed = get_area(src)
	alarmed.airlocks_close(TRUE)

	// alarm_manager.send_alarm(ALARM_BURGLAR)
	// addtimer(CALLBACK(alarm_manager, TYPE_PROC_REF(/datum/alarm_handler, clear_alarm), ALARM_BURGLAR), 1 MINUTES)

	playsound(loc, 'sound/effects/alert.ogg', VOL_EFFECTS_MASTER, 50, TRUE)

/obj/structure/displaycase/update_icon()
	var/list/new_overlays = update_overlays()
	if(managed_overlays)
		cut_overlay(managed_overlays)
		managed_overlays = null
	if(length(new_overlays))
		add_overlay(new_overlays)
		managed_overlays = new_overlays

/obj/structure/displaycase/proc/update_overlays()
	. = list()
	if(showpiece)
		var/mutable_appearance/showpiece_overlay = mutable_appearance(showpiece.icon, showpiece.icon_state)
		showpiece_overlay.copy_overlays(showpiece)
		showpiece_overlay.transform *= 0.6
		. += showpiece_overlay
	if(broken)
		. += "[initial(icon_state)]_broken"
		return
	if(!open)
		. += "[initial(icon_state)]_closed"
		return

/obj/structure/displaycase/attackby(obj/item/W, mob/living/user, params)
	if(broken)
		if(istype(W, /obj/item/stack/sheet/glass))
			var/obj/item/stack/sheet/glass/G = W
			if(G.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two glass sheets to fix the case!</span>")
				return
			to_chat(user, "<span class='notice'>You start fixing [src]...</span>")
			if(do_after(user, SKILL_TASK_VERY_EASY, target = src))
				G.use(2)
				broken = FALSE
				density = initial(density)
				update_integrity(max_integrity)
				update_icon()
			return
		else if(isprying(W))
			if(showpiece)
				to_chat(user, "<span class='warning'>Remove the displayed object first!</span>")
			else
				to_chat(user, "<span class='notice'>You remove the destroyed case.</span>")
				deconstruct(TRUE)
	else
		if(W.GetID())
			if(allowed(user))
				to_chat(user, "<span class='notice'>You [open ? "close" : "open"] [src].</span>")
				toggle_lock(user)
			else
				to_chat(user, "<span class='alert'>Access denied.</span>")
			return
		else if(iswelding(W))
			if(atom_integrity < max_integrity)
				if(!W.tool_start_check(user, amount=5))
					return

				to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
				if(W.use_tool(src, user, SKILL_TASK_AVERAGE, amount = 5, volume = 50))
					update_integrity(max_integrity)
					to_chat(user, "<span class='notice'>You repair [src].</span>")
			else
				to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
			return
	if(open && !showpiece && insert_showpiece(W, user))
		return
	return ..()

/obj/structure/displaycase/proc/insert_showpiece(obj/item/wack, mob/user)
	if(user.remove_from_mob(wack, src))
		showpiece = wack
		to_chat(user, "<span class='notice'>You put [wack] on display.</span>")
		update_icon()
		return TRUE

/obj/structure/displaycase/proc/toggle_lock(mob/user)
	open = !open
	update_icon()

/obj/structure/displaycase/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_MELEE)
	if(showpiece && open)
		to_chat(user, "<span class='notice'>You deactivate the hover field built into the case.</span>")
		dump()
		add_fingerprint(user)
		return
	visible_message("<span class='userdanger'>[user] kicks the display case.</span>", viewing_distance = COMBAT_MESSAGE_RANGE)
	user.do_attack_animation(src, visual_effect_icon = ATTACK_EFFECT_KICK)
	take_damage(2, BRUTE, MELEE)

/obj/structure/displaycase_chassis
	anchored = TRUE
	density = FALSE
	name = "display case chassis"
	desc = "The wooden base of a display case."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	max_integrity = 100
	resistance_flags = CAN_BE_HIT
	var/obj/item/weapon/airlock_electronics/electronics

/obj/structure/displaycase_chassis/Destroy()
	QDEL_NULL(electronics)
	return ..()

/obj/structure/displaycase_chassis/attackby(obj/item/I, mob/user, params)
	if(iswrenching(I))
		to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
		if(I.use_tool(src, user, SKILL_TASK_EASY, volume = 50))
			playsound(loc, 'sound/items/deconstruct.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
			deconstruct(TRUE)

	else if(isprying(I) && electronics)
		to_chat(user, "<span class='notice'>You start to remove the electronics from [src]...</span>")
		if(I.use_tool(src, user, SKILL_TASK_VERY_EASY, volume = 100))
			to_chat(user, "<span class='notice'>You have removed the electronics from [src]!</span>")
			electronics.forceMove(loc)
			electronics = null

	else if(istype(I, /obj/item/weapon/airlock_electronics) && !electronics)
		var/obj/item/weapon/airlock_electronics/AE = I
		if(!AE.broken) // why are we have broken electronics as the same item?
			to_chat(user, "<span class='notice'>You start installing the electronics into [src]...</span>")
			if(I.use_tool(src, user, SKILL_TASK_EASY, volume = 50) && user.remove_from_mob(I, src))
				electronics = I
				to_chat(user, "<span class='notice'>You install the airlock electronics.</span>")

	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need ten glass sheets to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [G] to [src]...</span>")
		if(I.use_tool(src, user, SKILL_TASK_VERY_EASY, amount = 10, volume = 50))
			var/obj/structure/displaycase/noalert/display = new(loc)
			if(electronics)
				var/obj/item/weapon/airlock_electronics/AE = electronics
				electronics = null
				AE.forceMove(display)
				display.electronics = AE
				if(AE.one_access)
					display.req_one_access = AE.conf_access
				else
					display.req_access = AE.conf_access
			qdel(src)
	else
		return ..()

/obj/structure/displaycase_chassis/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	if(electronics)
		electronics.forceMove(loc)
		electronics = null
	new /obj/item/stack/sheet/wood(loc, 5)
	..()


//The lab cage and captain's display case do not spawn with electronics, which is why req_access is needed.
/obj/structure/displaycase/captain
	showpiece = /obj/item/weapon/gun/energy/laser/selfcharging/captain
	req_access = list(access_cent_specops) //this was intentional, presumably to make it slightly harder for caps to grab their gun roundstart

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."
	showpiece = /obj/item/clothing/mask/facehugger/lamarr
	req_access = list(access_rd)

/obj/item/clothing/mask/facehugger/lamarr
	name = "Lamarr"
	desc = "The worst she might do is attempt to... couple with your head."//hope we don't get sued over a harmless reference, rite?
	sterile = 1
	gender = FEMALE

/obj/item/clothing/mask/facehugger/lamarr/atom_init_late()//to prevent deleting it if aliums are disabled
	return


/obj/structure/displaycase/noalert
	alert = FALSE
