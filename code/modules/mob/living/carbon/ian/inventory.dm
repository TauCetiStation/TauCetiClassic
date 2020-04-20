/mob/living/carbon/ian/show_inv(mob/user)
	user.set_machine(src)
	var/list/dat = list()

	dat += "<table>"
	dat += "<tr><td><B>Mouth:</B></td><td><A href='?src=\ref[src];item=[SLOT_MOUTH]'>[(mouth && !(mouth.flags & ABSTRACT)) ? mouth : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=\ref[src];item=[SLOT_BACK]'>[(back && !(back.flags & ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A></td></tr>"
	dat += "<tr><td><B>Head:</B></td><td><A href='?src=\ref[src];item=[SLOT_HEAD]'>[(head && !(head.flags & ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"
	dat += "<tr><td><B>Neck (ID):</B></td><td><A href='?src=\ref[src];item=[SLOT_NECK]'>[(neck && !(neck.flags & ABSTRACT)) ? neck : "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += {"</table>
	<A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat.Join())
	popup.open()

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

/mob/living/carbon/ian/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!slot)
		return
	if(!istype(W))
		return

	if(W == mouth)
		src.mouth = null
		update_inv_mouth() //So items actually disappear from mouth.

	W.screen_loc = null // will get moved if inventory is visible

	W.loc = src

	switch(slot)
		if(SLOT_HEAD)
			if(istype(W, /obj/item/clothing/mask/facehugger))
				facehugger = TRUE
			head = W
			W.equipped(src, slot)
			update_inv_head()
		if(SLOT_MOUTH)
			mouth = W
			W.equipped(src, slot)
			update_inv_mouth()
		if(SLOT_NECK)
			if(istype(W, /obj/item/weapon/handcuffs))
				handcuffed = W
			neck = W
			W.equipped(src, slot)
			update_inv_neck()
		if(SLOT_BACK)
			back = W
			W.equipped(src, slot)
			update_inv_back()
		else
			to_chat(usr, "<span class='red'>You are trying to equip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	W.layer = ABOVE_HUD_LAYER
	W.plane = ABOVE_HUD_PLANE
	W.appearance_flags = APPEARANCE_UI
	W.slot_equipped = slot

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
		W.slot_equipped = SLOT_MOUTH
		W.equipped(src,SLOT_MOUTH)
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
		W.slot_equipped = initial(W.slot_equipped)
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
		if(/obj/item/clothing/head/beret/red, /obj/item/clothing/head/collectable/beret)
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
			name = "Ghost"
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
