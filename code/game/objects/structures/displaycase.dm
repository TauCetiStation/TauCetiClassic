/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox"
	desc = "A display case for prized possessions."
	density = TRUE
	anchored = TRUE
	resistance_flags = ACID_PROOF | CAN_BE_HIT
	armor = list(MELEE = 30, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 70, ACID = 100)
	max_integrity = 200
	integrity_failure = 0.25
	var/obj/item/showpiece = null
	var/obj/item/showpiece_type = null //This allows for showpieces that can only hold items if they're the same istype as this.
	var/alert = TRUE
	var/open = FALSE
	var/openable = TRUE

	var/obj/item/electronics/airlock/electronics
	var/start_showpiece_type = null //add type for items on display
	///Represents a signel source of screaming when broken
	var/datum/alarm_handler/alarm_manager

	// Tg update_icon workaround
	var/list/managed_overlays

/obj/structure/displaycase/Initialize(mapload)
	. = ..()
	if(start_showpiece_type)
		showpiece = new start_showpiece_type(src)
	update_icon()
	alarm_manager = new(src)

/obj/structure/displaycase/vv_edit_var(vname, vval)
	. = ..()
	if(vname in list(NAMEOF(src, open), NAMEOF(src, showpiece), NAMEOF(src, custom_glass_overlay)))
		update_icon()

/obj/structure/displaycase/handle_atom_del(atom/A)
	if(A == electronics)
		electronics = null
	if(A == showpiece)
		showpiece = null
		update_icon()
	return ..()

/obj/structure/displaycase/Destroy()
	QDEL_NULL(electronics)
	QDEL_NULL(showpiece)
	QDEL_NULL(alarm_manager)
	return ..()

/obj/structure/displaycase/get_examine_string(mob/user)
	. = ..()
	if(alert)
		. += "<span class='notice'>Hooked up with an anti-theft system.</span>"
	if(showpiece)
		. += "<span class='notice'>There's \a [showpiece] inside.</span>"

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
	if(flags & NODECONSTRUCT)
		return ..()
	dump()
	if(!broken)
		new /obj/item/shard(loc)
		trigger_alarm()
	..()

/obj/structure/displaycase/atom_break(damage_flag)
	. = ..()
	if(broken || flags & NODECONSTRUCT)
		return
	
	density = FALSE
	broken = TRUE
	new /obj/item/shard(loc)
	playsound(loc, SFX_SHATTER, VOL_EFFECTS_MASTER, 70, TRUE)
	update_icon()
	trigger_alarm()

///Anti-theft alarm triggered when broken.
/obj/structure/displaycase/proc/trigger_alarm()
	if(!alert)
		return
	var/area/alarmed = get_area(src)
	alarmed.burglaralert(src)

	alarm_manager.send_alarm(ALARM_BURGLAR)
	addtimer(CALLBACK(alarm_manager, /datum/alarm_handler/proc/clear_alarm, ALARM_BURGLAR), 1 MINUTES)

	playsound(src, 'sound/effects/alert.ogg', 50, TRUE)

/obj/structure/displaycase/update_icon()
	var/list/new_overlays = update_overlays()
	if(managed_overlays)
		cut_overlay(managed_overlays)
		managed_overlays = null
	if(length(new_overlays))
		add_overlay(new_overlays)

/obj/structure/displaycase/proc/update_overlays()
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
			if(do_after(user, 2 SECONDS, target = src))
				G.use(2)
				broken = FALSE
				update_integrity(max_integrity)
				update_icon()
	else
		if(W.GetID() && openable)
			if(allowed(user))
				to_chat(user, "<span class='notice'>You [open ? "close" : "open"] [src].</span>")
				toggle_lock(user)
			else
				to_chat(user, "<span class='alert'>Access denied.</span>")
			return
		else if(iswelder(W))
			if(atom_integrity < max_integrity)
				if(!W.tool_start_check(user, amount=5))
					return

				to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
				if(W.use_tool(src, user, 40, amount=5, volume=50))
					atom_integrity = max_integrity
					update_icon()
					to_chat(user, "<span class='notice'>You repair [src].</span>")
			else
				to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
			return
	else if(!alert && W.tool_behaviour == TOOL_CROWBAR && openable) //Only applies to the lab cage and player made display cases
		if(broken)
			if(showpiece)
				to_chat(user, span_warning("Remove the displayed object first!"))
			else
				to_chat(user, span_notice("You remove the destroyed case."))
				qdel(src)
		else
			to_chat(user, span_notice("You start to [open ? "close":"open"] [src]..."))
			if(W.use_tool(src, user, 20))
				to_chat(user,  span_notice("You [open ? "close":"open"] [src]."))
				toggle_lock(user)
	if(open && !showpiece)
		insert_showpiece(W, user)
		return ..()

/obj/structure/displaycase/proc/insert_showpiece(obj/item/wack, mob/user)
	if(showpiece_type && !istype(wack, showpiece_type))
		to_chat(user, span_notice("This doesn't belong in this kind of display."))
		return TRUE
	if(user.transferItemToLoc(wack, src))
		showpiece = wack
		to_chat(user, span_notice("You put [wack] on display."))
		update_icon()

/obj/structure/displaycase/proc/toggle_lock(mob/user)
	open = !open
	update_icon()

/obj/structure/displaycase/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/displaycase/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if (showpiece && (broken || open))
		to_chat(user, span_notice("You deactivate the hover field built into the case."))
		log_combat(user, src, "deactivates the hover field of")
		dump()
		add_fingerprint(user)
		return
	else
	    //prevents remote "kicks" with TK
		if (!Adjacent(user))
			return
		if (!user.combat_mode)
			if(!user.is_blind())
				user.examinate(src)
			return
		user.visible_message(span_danger("[user] kicks the display case."), null, null, COMBAT_MESSAGE_RANGE)
		log_combat(user, src, "kicks")
		user.do_attack_animation(src, ATTACK_EFFECT_KICK)
		take_damage(2)

/obj/structure/displaycase_chassis
	anchored = TRUE
	density = FALSE
	name = "display case chassis"
	desc = "The wooden base of a display case."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	var/obj/item/electronics/airlock/electronics


/obj/structure/displaycase_chassis/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH) //The player can only deconstruct the wooden frame
		to_chat(user, span_notice("You start disassembling [src]..."))
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 30))
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			new /obj/item/stack/sheet/mineral/wood(get_turf(src), 5)
			qdel(src)

	else if(istype(I, /obj/item/electronics/airlock))
		to_chat(user, span_notice("You start installing the electronics into [src]..."))
		I.play_tool_sound(src)
		if(do_after(user, 30, target = src) && user.transferItemToLoc(I,src))
			electronics = I
			to_chat(user, span_notice("You install the airlock electronics."))

	else if(istype(I, /obj/item/stock_parts/card_reader))
		var/obj/item/stock_parts/card_reader/C = I
		to_chat(user, span_notice("You start adding [C] to [src]..."))
		if(do_after(user, 20, target = src))
			var/obj/structure/displaycase/forsale/sale = new(src.loc)
			if(electronics)
				electronics.forceMove(sale)
				sale.electronics = electronics
				if(electronics.one_access)
					sale.req_one_access = electronics.accesses
				else
					sale.req_access = electronics.accesses
			qdel(src)
			qdel(C)

	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 10)
			to_chat(user, span_warning("You need ten glass sheets to do this!"))
			return
		to_chat(user, span_notice("You start adding [G] to [src]..."))
		if(do_after(user, 20, target = src))
			G.use(10)
			var/obj/structure/displaycase/noalert/display = new(src.loc)
			if(electronics)
				electronics.forceMove(display)
				display.electronics = electronics
				if(electronics.one_access)
					display.req_one_access = electronics.accesses
				else
					display.req_access = electronics.accesses
			qdel(src)
	else
		return ..()

//The lab cage and captain's display case do not spawn with electronics, which is why req_access is needed.
/obj/structure/displaycase/captain
	start_showpiece_type = /obj/item/weapon/gun/energy/laser/selfcharging/captain
	req_access = list(access_cent_specops) //this was intentional, presumably to make it slightly harder for caps to grab their gun roundstart

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."
	start_showpiece_type = /obj/item/clothing/mask/facehugger/lamarr
	req_access = list(access_rd)

/obj/structure/displaycase/noalert
	alert = FALSE

/obj/item/showpiece_dummy/Initialize(mapload, path)
	. = ..()
	var/obj/item/I = path
	name = initial(I.name)
	icon = initial(I.icon)
	icon_state = initial(I.icon_state)

/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for prized possessions. It taunts you to kick it."
	density = TRUE
	anchored = TRUE
	unacidable = 1//Dissolving the case would also delete the gun.
	max_integrity = 60
	integrity_failure = 0.5
	resistance_flags = UNACIDABLE | CAN_BE_HIT

	var/occupied = 1
	var/destroyed = 0

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassboxb[src.occupied]"
	else
		src.icon_state = "glassbox[src.occupied]"
	return

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glasshit.ogg', VOL_EFFECTS_MASTER, 75, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/displaycase/atom_break()
	..()
	if(destroyed || flags & NODECONSTRUCT)
		return
	density = FALSE
	destroyed = TRUE
	new /obj/item/weapon/shard(loc)
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	update_icon()

/obj/structure/displaycase/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	if(occupied)
		new /obj/item/weapon/gun/energy/laser/selfcharging/captain(loc)
		occupied = FALSE
	if(!destroyed)
		new /obj/item/weapon/shard(loc)
	..()

/obj/structure/displaycase/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/displaycase/attack_hand(mob/user)
	if(destroyed && occupied)
		new /obj/item/weapon/gun/energy/laser/selfcharging/captain(loc)
		occupied = FALSE
		to_chat(user, "<b>You deactivate the hover field built into the case.</b>")
		add_fingerprint(user)
		update_icon()
		return
	user.SetNextMove(CLICK_CD_MELEE)
	visible_message("<span class='userdanger'>[user] kicks the display case.</span>")
	take_damage(2, BRUTE, MELEE)


