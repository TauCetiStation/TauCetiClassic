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

	var/splinted = (status & ORGAN_SPLINTED)
	if((splinted || bnd_overlay) && !(obscured && obscured["flags"][body_part]))
		dat += "<br><b>[name]:</b>"
		if(splinted)
			dat += " <a href='?src=\ref[src];remove_inv=[slot_splints]'>Remove Splints</a>"
		if(bnd_overlay && wounds.len)
			dat += " <a href='?src=\ref[src];remove_inv=[slot_bandages]'>Remove Bandages</a>"

	for(var/x in i_slots)
		var/slot_name = parse_slot_name(x)
		if(obscured && obscured[x])
			dat += "<br><font color=grey><b>[slot_name]:</b> Obscured</font>"
		else if(item_in_slot[slot_w_uniform] && (x == slot_l_store || x == slot_r_store)) // oh dear, those hardcoded pockets...
			dat += "<br><b>[slot_name]:</b> <a href='?src=\ref[src];remove_inv=[x]'>Check Pocket</a> <a href='?src=\ref[src];add_inv=[x]'>Put in Pocket</a>"
		else
			var/obj/item/I = i_slots[x]
			if(I && !(I.flags & ABSTRACT))
				dat += "<br><b>[slot_name]:</b> <a href='?src=\ref[src];remove_inv=[x]'>[I]</a>"
				if(owner)
					if(I.slot_equipped == slot_w_uniform)
						if(owner.w_uniform.has_sensor == 1)
							dat += " <a href='?src=\ref[src];remove_inv=[x];misc=sensors'>Sensors</a> "
						if(owner.w_uniform.hastie)
							dat += " <a href='?src=\ref[src];remove_inv=[x];misc=accessory'>Remove Accessory</a>"
					if(owner.wear_mask && (owner.wear_mask.flags & MASKINTERNALS) && istype(I, /obj/item/weapon/tank))
						dat += " <a href='?src=\ref[src];remove_inv=[x];misc=[MASKINTERNALS]'>[I == owner.internal ? "Unset Internal" : "Set Internal"]</a>"
				dat += " (<a href='?src=\ref[src];remove_inv=[x];misc=examine'>E</a>)"
			else
				dat += "<br><b>[slot_name]:</b> <a href='?src=\ref[src];add_inv=[x]'>Nothing</a>"

	return dat

/obj/item/bodypart/Topic(href, href_list)
	var/mob/user = usr

	if(href_list["close"])
		user << browse(null, "window=limb_inventory")
		user.unset_machine(src)
		return

	if(href_list["refresh"])
		show_inv(user)

	if(href_list["remove_inv"])
		un_equip_or_action(user, href_list["remove_inv"], null, href_list["misc"])

	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]
		var/item_to_add = user.get_active_hand()
		if(!item_to_add)
			to_chat(user, "<span class='red'>You have nothing in your hand to put [add_to == slot_l_store ? "in" : add_to == slot_r_store ? "in" : "on"] its [parse_slot_name(add_to)].</span>")
			return
		un_equip_or_action(user, add_to, item_to_add)

/obj/item/bodypart/proc/un_equip_or_action(mob/living/who, where, obj/item/this_item, misc)
	if(!who || !where || who.incapacitated() || is_stump() || !(ishuman(who) || ismonkey(who) || isrobot(who)))
		return

	if(who.is_busy(owner, where, TRUE))
		return

	if(owner)
		if(!owner.Adjacent(who) || who == owner)
			return
	else
		if(src.loc != who)
			return

	if(misc == "examine")
		var/obj/item/item = item_in_slot[where]
		if(item)
			var/list/obscured = check_obscured_slots()
			if(obscured && obscured[where])
				return
			if(owner)
				who.visible_message("<span class='notice'>[who] examines [owner]'s [parse_slot_name(where)].", "<span class='notice'>You carefully examine [owner]'s [parse_slot_name(where)].")
			who.examinate(item)
			return

	var/action_delay = HUMAN_STRIP_DELAY
	if(this_item)
		if(istype(this_item, src.type)) // i put yo hand in hand which holds hand which we put in hand.
			return
		if(where == slot_l_store || where == slot_r_store)
			action_delay /= 2
		else if(!this_item.limb_can_equip(src, where, TRUE))
			return
		if(this_item.un_equip_time > action_delay)
			action_delay = this_item.un_equip_time
		this_item.add_fingerprint(who)
		who.visible_message("<span class='danger'>[who] is trying to put \a [this_item] on [owner ? owner : src].</span>")
	else
		var/obj/item/I = who.get_active_hand()
		if(I && I.w_class >= ITEM_SIZE_NORMAL)
			to_chat(who, "<span class='warning'>Size of [I] disallows you to interact with [owner ? owner : src] inventory, remove it.</span>")
			return

		if(where == slot_splints || where == slot_bandages)
			who.visible_message("<span class='danger'>[who] is trying to remove [owner ? owner : src]'s [where]!")
		else if(where == slot_l_store || where == slot_r_store)
			who.visible_message("<span class='danger'>[who] is trying to empty [owner ? owner : src]'s pocket.</span>")
			action_delay /= 2
			var/obj/item/item = item_in_slot[where]
			if(item)
				item.add_fingerprint(who)
		else
			var/obj/item/item = item_in_slot[where]
			if(item)
				if(owner && misc)
					if(misc == "[MASKINTERNALS]")
						if(item == owner.internal)
							who.visible_message("<span class='danger'>[who] is trying to remove [owner]'s internals</span>")
						else
							who.visible_message("<span class='danger'>[who] is trying to set on [owner]'s internals.</span>")
					else if(misc == "sensors")
						who.visible_message("<span class='danger'>[who] is trying to set [owner]'s suit sensors!</span>")
					else if(misc == "accessory")
						who.visible_message("<span class='danger'>[who] is trying to take off \a [owner.w_uniform.hastie] from [owner]'s suit!</span>")
				else
					who.visible_message("<span class='danger'>[who] is trying to take off \a [item] from [owner ? owner : src]!</span>")
				if(item.un_equip_time > action_delay)
					action_delay = item.un_equip_time
				item.add_fingerprint(who)
			else // invalid or nothing in slot
				return

	if(owner)
		if(!do_mob(who, owner, action_delay, target_slot = where))
			return
	else if(!do_after(who, action_delay, target = src))
		return

	do_un_equip_or_action(who, where, this_item, misc)

/obj/item/bodypart/proc/do_un_equip_or_action(mob/living/who, where, obj/item/this_item, misc)
	if(!who || !where)
		return
	if(this_item)
		if(who.get_active_hand() != this_item)
			return


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
		if(this_item.limb_can_equip(src, where, TRUE))
			if(where == slot_handcuffed && owner && istype(this_item, /obj/item/weapon/handcuffs))
				var/grabbing = FALSE
				for (var/obj/item/weapon/grab/G in owner.grabbed_by)
					if (G.loc == who && G.state >= GRAB_AGGRESSIVE)
						grabbing = TRUE
				if (!grabbing)
					to_chat(who, "<span class='warning'>Your grasp was broken before you could restrain [owner]!</span>")
					return
			if(who.temporarilyRemoveItemFromInventory(this_item))
				this_item.equip_to_slot_if_possible(who, src, where)
				if(owner)
					owner.attack_log += text("\[[time_stamp()]\] <font color='blue'>[who.name] ([who.ckey]) placed on our (slot: [where]) ([this_item])</font>")
				who.attack_log += text("\[[time_stamp()]\] <font color='blue'>Placed on [owner ? owner.name + "'s" + "([owner.ckey])" : src.name] (Slot: [where]) ([this_item])</font>")
		else
			return
	else
		var/obj/item/I = who.get_active_hand()
		if(I && I.w_class >= ITEM_SIZE_NORMAL)
			return
		if(where == slot_splints || where == slot_bandages) // TODO make them as real attached items, instead of vars.
			if(where == slot_splints)
				if (status & ORGAN_SPLINTED)
					status &= ~ORGAN_SPLINTED
					var/obj/item/W = new /obj/item/stack/medical/splint(amount = 1)
					W.loc = owner ? owner.loc : who.loc
					W.add_fingerprint(who)
			if(where == slot_bandages)
				if(bnd_overlay && wounds.len)
					for(var/datum/wound/W in wounds)
						if(W.bandaged)
							W.bandaged = 0
					if(owner)
						owner.update_bodypart(body_zone)
						owner.attack_log += "\[[time_stamp()]\] <font color='blue'>Has had their [where] removed by [who.name] ([who.ckey])</font>"
					else
						update_limb()
					who.attack_log += "\[[time_stamp()]\] <font color='blue'>Removed [owner ? owner.name + "'s" + "([owner.ckey])" : src.name] [where].</font>"
		else
			var/obj/item/item_to_strip = item_in_slot[where]
			if(item_to_strip)
				if(owner && misc)
					var/list/obscured = check_obscured_slots()
					if(obscured && obscured[where])
						return
					if(misc == "[MASKINTERNALS]" && istype(item_to_strip, /obj/item/weapon/tank))
						owner.set_internals(item_to_strip, who)
					else if(misc == "sensors")
						owner.w_uniform.set_sensors(who)
					else if(misc == "accessory")
						owner.w_uniform.hastie.on_removed(who)
						owner.w_uniform.hastie = null
						owner.w_uniform.update_inv_item(slot_w_uniform)
				else
					if(item_to_strip.remove_from(FALSE, (owner ? owner.loc : who.loc), FALSE, owner))
						if(owner)
							owner.attack_log += "\[[time_stamp()]\] <font color='blue'>Has had their (slot: [where]) ([item_to_strip]) removed by [who.name] ([who.ckey])</font>"
						who.attack_log += "\[[time_stamp()]\] <font color='blue'>Removed [owner ? owner.name + "'s" + "([owner.ckey])" : src.name] (slot: [where]) ([item_to_strip])</font>"
					else
						who.visible_message("<span class='danger'>[who] fails to take off \a [item_to_strip] from [owner ? owner : src]!</span>")
						return
			else
				return

	if(owner)
		for(var/mob/M in range(1, get_turf(owner ? owner : src)))
			if(M.machine == owner)
				owner.show_inv(M)
	else if(who.machine == src)
		show_inv(who)
