/*
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
*/
/*
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
		var/item_to_add = usr.get_active_hand()
		if(!item_to_add)
			to_chat(usr, "<span class='red'>You have nothing in your hand to put on its [add_to].</span>")
			return
		if(get_slot_ref(add_to))
			to_chat(usr, "<span class='red'>It's is already wearing something.</span>")
			return
		else
			un_equip_or_action(usr, add_to, item_to_add)
*/
//Returns the thing in our active hand (errr... mouth!)
//mob/living/carbon/ian/get_active_hand()
//	return mouth

//Returns the thing in our inactive hand (errr... mouth!)
//mob/living/carbon/ian/get_inactive_hand()
//	return mouth

//Drops the item in our active hand (errr... mouth!)
//mob/living/carbon/ian/drop_item()
//	return dropItemToGround(mouth)

/mob/living/carbon/ian/restrained()
	if(handcuffed || facehugger) // Oh wow, whats this on my faaaaaaace?
		return TRUE
	return FALSE

/*
/mob/living/carbon/ian/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!slot)
		return
	if(!istype(W))
		return

	if(W == mouth)
		src.mouth = null

	W.screen_loc = null // will get moved if inventory is visible

	W.loc = src

	switch(slot)
		if(slot_head)
			if(istype(W, /obj/item/clothing/mask/facehugger))
				facehugger = TRUE
			head = W
			W.equipped(src, slot)
		if(slot_mouth)
			mouth = W
			W.equipped(src, slot)
		if(slot_neck)
			if(istype(W, /obj/item/weapon/handcuffs))
				handcuffed = W
			neck = W
			W.equipped(src, slot)
		if(slot_back)
			back = W
			W.equipped(src, slot)
		else
			to_chat(usr, "<span class='red'>You are trying to equip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	W.layer = ABOVE_HUD_LAYER
	W.plane = ABOVE_HUD_PLANE
	W.appearance_flags = APPEARANCE_UI*/

//Puts the item into our active hand (errr... mouth!) if possible. returns 1 on success.
/*/mob/living/carbon/ian/put_in_active_hand(obj/item/W)
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
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return TRUE
	return FALSE*/

//mob/living/carbon/ian/put_in_inactive_hand(obj/item/W)
//	return put_in_active_hand(W)

/*/mob/living/carbon/ian/put_in_hands(obj/item/W)
	if(!W)
		return FALSE
	if(put_in_active_hand(W))
		return TRUE
	else
		W.forceMove(get_turf(src))
		W.layer = initial(W.layer)
		W.plane = initial(W.plane)
		W.appearance_flags = 0
		W.dropped()
		return FALSE*/

/*/mob/living/carbon/ian/u_equip(obj/W)
	if (W == head)
		facehugger = FALSE
		head = null
	else if (W == neck)
		handcuffed = null
		neck = null
	else if (W == mouth)
		mouth = null
	else if (W == back)
		back = null*/

/mob/living/carbon/ian/proc/update_corgi_ability()
	name = real_name
	desc = initial(desc)
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "shivers")

	var/obj/item/head = get_equipped_item(slot_head)
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
