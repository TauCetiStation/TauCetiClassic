/obj/item/bodypart/attack_self(mob/user)
	show_inv(user)

/obj/item/bodypart/proc/show_inv(mob/user)
	var/dat = get_inv_menu(user)

	if(!dat)
		return

	dat += "<br><br><a href='?src=\ref[src];refresh=1'>Refresh</a>"
	dat += "<br><a href='?src=\ref[src];close=1'>Close</a>"

	user.set_machine(src)

	var/datum/browser/popup = new(user, "limb_inventory", owner ? owner.name : name, 500, 600)
	popup.set_content(dat)
	popup.open()

/obj/item/bodypart/proc/get_inv_menu(user)
	var/list/i_slots = item_in_slot
	var/list/obscured = check_obscured_slots()

	var/dat
	for(var/x in i_slots - slot_in_backpack)
		if(obscured && obscured[x])
			dat += "<br><font color=grey><b>[x]:</b> Obscured</font>"
		else
			var/obj/item/I = i_slots[x]
			if(I)
				dat += "<br><b>[x]:</b> <a href='?src=\ref[src];remove_inv=[x]'>[I]</a>"
			else
				dat += "<br><b>[x]:</b> <a href='?src=\ref[src];add_inv=[x]'>Nothing</a>"
	return dat

/obj/item/bodypart/Topic(href, href_list)
	var/mob/user = usr

	if(href_list["close"])
		user << browse(null, "window=limb_inventory")
		user.unset_machine(src)
		return

	if(href_list["refresh"])
		show_inv(user)

	else if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		un_equip_or_action(user, remove_from)

	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]
		var/item_to_add = user.get_active_hand()
		if(!item_to_add)
			to_chat(user, "<span class='red'>You have nothing in your hand to put on its [add_to].</span>")
			return
		un_equip_or_action(user, add_to, item_to_add)

/obj/item/bodypart/proc/un_equip_or_action(mob/living/who, where, obj/item/this_item)
	if(!who || !where || who.incapacitated() || is_stump() || !(ishuman(who) || ismonkey(who) || isrobot(who)))
		return

	if(owner)
		who.is_busy(owner, where, TRUE)
		if(!owner.Adjacent(who))
			return
	else

		if(src.loc != who || who.is_busy())
			return

	var/action_delay = HUMAN_STRIP_DELAY
	if(this_item)
		if(who.is_busy(owner, where))
			return
		if(!this_item.limb_can_equip(src, where))
			return
		if(this_item.un_equip_time > action_delay)
			action_delay = this_item.un_equip_time
		this_item.add_fingerprint(who)
		who.visible_message("<span class='danger'>[who] is trying to put \a [this_item] on [src].</span>")
	else
		if(who.is_busy(owner, where, TRUE))
			return
		var/obj/item/item = item_in_slot[where]
		if(item)
			if(item.un_equip_time > action_delay)
				action_delay = item.un_equip_time
			who.visible_message("<span class='danger'>[who] is trying to take off \a [item] from [owner ? owner : src]!</span>")
			item.add_fingerprint(who)
		else // invalid or nothing in slot
			return

	if(owner)
		if(!do_mob(who, owner, action_delay, target_slot = where))
			return
	else if(!do_after(who, action_delay, target = src))
		return

	do_un_equip_or_action(who, where, this_item)

/obj/item/bodypart/proc/do_un_equip_or_action(mob/living/who, where, obj/item/this_item)
	if(!who || !where)
		return
	if(this_item && who.get_active_hand() != this_item)
		return

	var/obj/item/item_to_strip = item_in_slot[where]
	if(item_to_strip)
		if(item_to_strip.remove_from(FALSE, owner ? owner.loc : who.loc, FALSE, owner))//, force, newloc, no_move)
			if(owner)
				owner.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their [where] ([item_to_strip]) removed by [who.name] ([who.ckey])</font>")
			who.attack_log += text("\[[time_stamp()]\] <font color='red'>Removed [owner ? owner.name + "'s" + "([owner.ckey])" : src.name] [where] ([item_to_strip])</font>")
		else
			who.visible_message("<span class='danger'>[who] fails to take off \a [item_to_strip] from [owner ? owner : src]!</span>")
			return
	else
		//switch(where)
			//if("CPR")
			//	if(src.health > config.health_threshold_dead && src.health < config.health_threshold_crit)
			//		var/suff = min(src.getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
			//		src.adjustOxyLoss(-suff)
			//		src.updatehealth()
			//		who.visible_message("<span class='warning'>[who] performs CPR on [src]!</span>")
			//		to_chat(src, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
			//		to_chat(who, "<span class='warning'>Repeat at least every 7 seconds.</span>")
			//if("dnainjector")
			//	var/obj/item/weapon/dnainjector/S = this_item
			//	if(!istype(S))
			//		S.inuse = FALSE
			//		return
			//	S.inject(src, who)
			//	if(S.s_time >= world.time + 30)
			//		S.inuse = FALSE
			//		return
			//	S.s_time = world.time
			//	who.visible_message("<span class='warning'>[who] injects [src] with the DNA Injector!</span>")
			//	S.inuse = FALSE
			//else
		if(this_item.limb_can_equip(src, where))
		//if(this_item.mob_can_equip(src, get_slot_id(where)))
			if(where == slot_handcuffed && owner && istype(this_item, /obj/item/weapon/handcuffs))
				var/grabbing = FALSE
				for (var/obj/item/weapon/grab/G in owner.grabbed_by)
					if (G.loc == who && G.state >= GRAB_AGGRESSIVE)
						grabbing = TRUE
				if (!grabbing)
					to_chat(who, "<span class='warning'>Your grasp was broken before you could restrain [owner]!</span>")
					return
			if(who.temporarilyRemoveItemFromInventory(this_item))
				equip_to_slot_if_possible(who, this_item, where)
				if(owner)
					owner.attack_log += text("\[[time_stamp()]\] <font color='orange'>[who.name] ([who.ckey]) placed on our [where] ([this_item])</font>")
				who.attack_log += text("\[[time_stamp()]\] <font color='red'>Placed on [owner ? owner.name + "'s" + "([owner.ckey])" : src.name] [where] ([this_item])</font>")

	if(owner)
		for(var/mob/M in range(1, get_turf(owner ? owner : src)))
			if(M.machine == owner)
				owner.show_inv(M)
	else if(who.machine == src)
		show_inv(who)
