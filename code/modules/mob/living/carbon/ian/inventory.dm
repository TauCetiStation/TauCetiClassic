/mob/living/carbon/ian/show_inv(mob/user)
	if(user.incapacitated() || !Adjacent(usr))
		return

	user.set_machine(src)

	var/list/i_slots = list("Head" = head, "Mouth" = mouth, "Neck"  = neck, "Back"  = back)

	var/dat = ""
	for(var/x in i_slots)
		if(i_slots[x])
			dat += "<br><b>[x]:</b> (<a href='?src=\ref[src];remove_inv=[x]'>[i_slots[x]]</a>)"
		else
			dat += "<br><b>[x]:</b> <a href='?src=\ref[src];add_inv=[x]'>Nothing</a>"

	dat += "<br><br><a href='?src=\ref[src];refresh=1'>Refresh</a>"
	dat += "<br><a href='?src=\ref[src];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "dog", name, 325, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/ian/Topic(href, href_list)
	if(href_list["close"])
		usr << browse(null, "window=dog")
		usr.unset_machine(src)
		return

	if(usr.incapacitated() || !Adjacent(usr) || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
		return

	if(href_list["refresh"])
		show_inv(usr)
	else if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		if(get_slot_ref(remove_from))
			un_equip_or_action(usr, remove_from)
	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]
		var/obj/item/item_to_add = usr.get_active_hand()
		if(!item_to_add || (item_to_add.flags & (ABSTRACT | DROPDEL)))
			to_chat(usr, "<span class='red'>You have nothing in your hand to put on its [add_to].</span>")
			return
		if(get_slot_ref(add_to))
			to_chat(usr, "<span class='red'>It's is already wearing something.</span>")
			return
		else
			un_equip_or_action(usr, add_to, item_to_add)

//Returns the thing in our active hand (errr... mouth!)
/mob/living/carbon/ian/get_active_hand()
	return mouth

//Returns the thing in our inactive hand (errr... mouth!)
/mob/living/carbon/ian/get_inactive_hand()
	return mouth

//Drops the item in our active hand (errr... mouth!)
/mob/living/carbon/ian/drop_item(atom/Target)
	return drop_from_inventory(mouth, Target)

/mob/living/carbon/ian/restrained()
	if(handcuffed || facehugger) // Oh wow, whats this on my faaaaaaace?
		return TRUE
	return FALSE

/mob/living/carbon/ian/proc/un_equip_or_action(mob/living/who, where, obj/item/this_item)
	if(!who || !where || isanimal(who))
		return

	if(who.isHandsBusy)
		return
	who.isHandsBusy = TRUE

	if(!Adjacent(who))
		return

	if(this_item)
		var/message = "<span class='danger'>[who] is trying to put \a [this_item] on [src].</span>"
		if(where == "dnainjector")
			message = "<span class='danger'>[who] is trying to inject [src] with the [this_item]!</span>"
		this_item.add_fingerprint(who)
		who.visible_message(message)
	else
		if(where == "CPR")
			if(!cpr_time)
				return
			cpr_time = FALSE
			who.visible_message("<span class='danger'>[who] is trying perform CPR on [src]!</span>")
		else
			var/obj/item/slot_ref = get_slot_ref(where)
			if(slot_ref)
				who.visible_message(text("<span class='danger'>[] is trying to take off \a [] from []'s []!</span>", who, slot_ref, src, lowertext(where)))
				slot_ref.add_fingerprint(who)
			else
				who.isHandsBusy = FALSE //invalid slot
				return

	if(do_after(who, HUMAN_STRIP_DELAY, target = src))
		do_un_equip_or_action(who, where, this_item)

	who.isHandsBusy = FALSE
	cpr_time = TRUE

/mob/living/carbon/ian/proc/do_un_equip_or_action(mob/living/who, where, obj/item/this_item)
	if(!who || !where)
		return
	if(!Adjacent(who))
		return
	if(this_item && who.get_active_hand() != this_item)
		return
	if(who.incapacitated())
		return

	var/obj/item/slot_ref = get_slot_ref(where)
	if(slot_ref)
		if(!slot_ref.canremove)
			who.visible_message(text("<span class='danger'>[] fails to take off \a [] from []'s [lowertext(where)]!</span>", who, slot_ref, src))
			return
		else
			remove_from_mob(slot_ref)
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their [where] ([slot_ref]) removed by [who.name] ([who.ckey])</font>")
			who.attack_log += text("\[[time_stamp()]\] <font color='red'>Removed [src.name]'s ([src.ckey]) [where] ([slot_ref])</font>")
	else
		switch(where)
			if("CPR")
				if(src.health > config.health_threshold_dead && src.health < config.health_threshold_crit)
					var/suff = min(src.getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
					src.adjustOxyLoss(-suff)
					src.updatehealth()
					who.visible_message("<span class='warning'>[who] performs CPR on [src]!</span>")
					to_chat(src, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
					to_chat(who, "<span class='warning'>Repeat at least every 7 seconds.</span>")
			if("dnainjector")
				var/obj/item/weapon/dnainjector/S = this_item
				if(!istype(S))
					S.inuse = FALSE
					return
				S.inject(src, who)
				if(S.s_time >= world.time + 30)
					S.inuse = FALSE
					return
				S.s_time = world.time
				who.visible_message("<span class='warning'>[who] injects [src] with the DNA Injector!</span>")
				S.inuse = FALSE
			else
				if(this_item.mob_can_equip(src, get_slot_id(where)))
					if(where == "Neck")
						if(istype(this_item, /obj/item/weapon/handcuffs))
							var/grabbing = FALSE
							for (var/obj/item/weapon/grab/G in src.grabbed_by)
								if (G.loc == who && G.state >= GRAB_AGGRESSIVE)
									grabbing = TRUE
							if (!grabbing)
								to_chat(who, "<span class='warning'>Your grasp was broken before you could restrain [src]!</span>")
								return
					who.remove_from_mob(this_item)
					equip_to_slot_if_possible(this_item, get_slot_id(where))
					src.attack_log += text("\[[time_stamp()]\] <font color='orange'>[who.name] ([who.ckey]) placed on our [where] ([slot_ref])</font>")
					who.attack_log += text("\[[time_stamp()]\] <font color='red'>Placed on [src.name]'s ([src.ckey]) [where] ([slot_ref])</font>")

	if(usr.machine == src && in_range(src, usr))
		show_inv(usr)

/mob/living/carbon/ian/proc/get_slot_ref(slot)
	switch(slot)
		if("Head")
			return head
		if("Mouth")
			return mouth
		if("Neck")
			return neck
		if("Back")
			return back

/mob/living/carbon/ian/proc/get_slot_id(slot)
	switch(slot)
		if("Head")
			return slot_head
		if("Mouth")
			return slot_mouth
		if("Neck")
			return slot_neck
		if("Back")
			return slot_back

/mob/living/carbon/ian/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!slot)
		return
	if(!istype(W))
		return

	// I sincerely regret this do not look a line lower or you will too. ~Luduk.
	if(istype(W, /obj/item/nymph_morph_ball))
		var/obj/item/nymph_morph_ball/NM = W
		W = NM.morphed_into
		drop_from_inventory(NM, W)
	// Madness ends here, and that's good.

	if(W == mouth)
		src.mouth = null
		update_inv_mouth() //So items actually disappear from mouth.

	W.screen_loc = null // will get moved if inventory is visible

	W.loc = src

	switch(slot)
		if(slot_head)
			if(istype(W, /obj/item/clothing/mask/facehugger))
				facehugger = TRUE
			head = W
			W.equipped(src, slot)
			update_inv_head()
		if(slot_mouth)
			mouth = W
			W.equipped(src, slot)
			update_inv_mouth()
		if(slot_neck)
			if(istype(W, /obj/item/weapon/handcuffs))
				handcuffed = W
			neck = W
			W.equipped(src, slot)
			update_inv_neck()
		if(slot_back)
			back = W
			W.equipped(src, slot)
			update_inv_back()
		else
			to_chat(usr, "<span class='red'>You are trying to equip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	W.layer = ABOVE_HUD_LAYER
	W.plane = ABOVE_HUD_PLANE
	W.appearance_flags = APPEARANCE_UI

//Puts the item into our active hand (errr... mouth!) if possible. returns 1 on success.
/mob/living/carbon/ian/put_in_active_hand(obj/item/W)
	if(lying && !(W.flags&ABSTRACT))
		return FALSE
	if(!istype(W))
		return FALSE
	if(W.anchored)
		return FALSE
	if(!mouth)
		W.loc = src
		mouth = W
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		W.appearance_flags = APPEARANCE_UI
		W.equipped(src,slot_mouth)
		if(client)
			client.screen |= W
		if(pulling == W)
			stop_pulling()
		update_inv_mouth()
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return TRUE
	return FALSE

/mob/living/carbon/ian/put_in_inactive_hand(obj/item/W)
	return put_in_active_hand(W)

/mob/living/carbon/ian/put_in_hands(obj/item/W)
	if(!W)
		return FALSE
	if(put_in_active_hand(W))
		return TRUE
	else
		W.forceMove(get_turf(src))
		W.layer = initial(W.layer)
		W.plane = initial(W.plane)
		W.appearance_flags = initial(W.appearance_flags)
		W.dropped()
		return FALSE

/mob/living/carbon/ian/u_equip(obj/W)
	if (W == head)
		facehugger = FALSE
		head = null
		update_inv_head()
	else if (W == neck)
		handcuffed = null
		neck = null
		update_inv_neck()
	else if (W == mouth)
		mouth = null
		update_inv_mouth()
	else if (W == back)
		back = null
		update_inv_back()

/mob/living/carbon/ian/proc/update_corgi_ability()
	name = real_name
	desc = initial(desc)
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "shivers")

	if(!head)
		return

	if(head.flags_inv & HIDEFACE)
		name = "Ianknown"
		return

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a HAT is removed.
	switch(head.type)
		if(/obj/item/clothing/head/caphat, /obj/item/clothing/head/collectable/captain)
			name = "Captain [real_name]"
			desc = "Probably better than the last captain."
		if(/obj/item/clothing/head/kitty, /obj/item/clothing/head/collectable/kitty)
			name = "Runtime"
			emote_see = list("coughs up a furball", "stretches")
			emote_hear = list("purrs")
			speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
			desc = "It's a cute little kitty-cat! ... wait ... what the hell?"
		if(/obj/item/clothing/head/rabbitears, /obj/item/clothing/head/collectable/rabbitears)
			name = "Hoppy"
			emote_see = list("twitches its nose", "hops around a bit")
			desc = "This is hoppy. It's a corgi-...urmm... bunny rabbit"
		if(/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret)
			name = "Yann"
			desc = "Mon dieu! C'est un chien!"
			speak = list("le woof!", "le bark!", "JAPPE!!")
			emote_see = list("cowers in fear", "surrenders", "plays dead","looks as though there is a wall in front of him")
		if(/obj/item/clothing/head/det_hat)
			name = "Detective [real_name]"
			desc = "[name] sees through your lies..."
			emote_see = list("investigates the area","sniffs around for clues","searches for scooby snacks")
		if(/obj/item/clothing/head/nursehat)
			name = "Nurse [real_name]"
			desc = "[name] needs 100cc of beef jerky...STAT!"
		if(/obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate)
			name = "[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]"
			desc = "Yaarghh!! Thar' be a scurvy dog!"
			emote_see = list("hunts for treasure","stares coldly...","gnashes his tiny corgi teeth")
			emote_hear = list("growls ferociously", "snarls")
			speak = list("Arrrrgh!!","Grrrrrr!")
		if(/obj/item/clothing/head/ushanka)
			name = "[pick("Comrade","Commissar","Glorious Leader")] [real_name]"
			desc = "A follower of Karl Barx."
			emote_see = list("contemplates the failings of the capitalist economic model", "ponders the pros and cons of vangaurdism")
		if(/obj/item/clothing/head/collectable/police)
			name = "Officer [real_name]"
			emote_see = list("drools","looks for donuts")
			desc = "Stop right there criminal scum!"
		if(/obj/item/clothing/head/wizard/fake,	/obj/item/clothing/head/wizard,	/obj/item/clothing/head/collectable/wizard)
			name = "Grandwizard [real_name]"
			speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI  NATH!")
		if(/obj/item/weapon/bedsheet)
			name = "\improper Ghost"
			speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
			emote_see = list("stumbles around", "shivers")
			emote_hear = list("howls","groans")
			desc = "Spooky!"
		if(/obj/item/clothing/head/helmet/space/santahat)
			name = "Rudolph the Red-Nosed Corgi"
			emote_hear = list("barks christmas songs", "yaps")
			desc = "He has a very shiny nose."
		if(/obj/item/clothing/head/soft)
			name = "Corgi Tech [real_name]"
			desc = "The reason your yellow gloves have chew-marks."
