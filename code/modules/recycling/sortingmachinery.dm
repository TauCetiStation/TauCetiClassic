/obj/structure/bigDelivery
	desc = "A big wrapped package."
	name = "large parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = 1
	var/sortTag = ""
	flags = NOBLUDGEON
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/structure/bigDelivery/proc/dump()
	for(var/atom/movable/AM in contents)
		if(istype(AM, /obj/structure/closet))
			var/obj/structure/closet/O = AM
			O.welded = 0
		AM.forceMove(get_turf(src))

/obj/structure/bigDelivery/Destroy()
	dump()
	return ..()

/obj/structure/bigDelivery/attack_hand(mob/user)
	if(contents.len > 0)
		dump()
	else
		to_chat(user, "<span class='notice'>The parcel was empty!</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', VOL_EFFECTS_MASTER)
	qdel(src)

/obj/structure/bigDelivery/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = W
		if(src.sortTag != O.currTag)
			to_chat(user, "<span class='notice'>*[O.currTag]*</span>")
			src.sortTag = O.currTag
			playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)

	else if(istype(W, /obj/item/weapon/pen))
		var/str = sanitize_safe(input(usr,"Label text?","Set label",""), MAX_NAME_LEN)
		if(!str || !length(str))
			to_chat(usr, "<span class='warning'>Invalid text.</span>")
			return
		for(var/mob/M in viewers())
			to_chat(M, "<span class='notice'>[user] labels [src] as [str].</span>")
		src.name = "[src.name] ([str])"

/obj/item/smallDelivery
	desc = "A small wrapped package."
	name = "small parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrateSmall"
	var/sortTag = ""

/obj/item/smallDelivery/proc/dump(mob/user)
	for(var/atom/movable/AM in contents)
		if(user && user.put_in_active_hand(AM))
			AM.add_fingerprint(user)
		else
			AM.forceMove(src.loc)

/obj/item/smallDelivery/Destroy()
	dump()
	return ..()

/obj/item/smallDelivery/attack_self(mob/user)
	if(contents.len > 0)
		user.drop_from_inventory(src)
		dump(user)
	else
		to_chat(user, "<span class='notice'>The parcel was empty!</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', VOL_EFFECTS_MASTER)
	qdel(src)

/obj/item/smallDelivery/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I
		if(src.sortTag != O.currTag)
			to_chat(user, "<span class='notice'>*[O.currTag]*</span>")
			sortTag = O.currTag
			playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)

	else if(istype(I, /obj/item/weapon/pen))
		var/str = sanitize_safe(input(usr,"Label text?","Set label",""), MAX_NAME_LEN)
		if(!str || !length(str))
			to_chat(usr, "<span class='warning'>Invalid text.</span>")
			return
		for(var/mob/M in viewers())
			to_chat(M, "<span class='notice'>[user] labels [src] as [str].</span>")
		name = "[name] ([str])"

	else
		return ..()

/obj/item/weapon/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	w_class = ITEM_SIZE_NORMAL
	var/amount = 25.0


/obj/item/weapon/packageWrap/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
		return
	if(istype(target, /obj/item/smallDelivery) || istype(target,/obj/structure/bigDelivery) \
	|| istype(target, /obj/item/weapon/gift) || istype(target, /obj/item/weapon/evidencebag))
		return
	if(!isobj(target))
		return
	var/obj/O = target
	if(O.anchored)
		return
	if(O in user)
		return
	if(user in O) //no wrapping closets that you are inside - it's not physically possible
		return

	user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [src.name] on \ref[O]</font>")


	if (istype(O, /obj/item))
		var/obj/item/I = target
		if (src.amount > 1)
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(I.loc))	//Aaannd wrap it up!
			if(!istype(I.loc, /turf))
				if(user.client)
					user.client.screen -= I
			P.w_class = I.w_class
			if(P.w_class <= ITEM_SIZE_TINY)
				P.icon_state = "deliverycrate1"
			else if (P.w_class <= ITEM_SIZE_SMALL)
				P.icon_state = "deliverycrate2"
			else if (P.w_class <= ITEM_SIZE_NORMAL)
				P.icon_state = "deliverycrate3"
			else
				P.icon_state = "deliverycrate4"
			I.loc = P
			var/i = round(I.w_class)
			if(i in list(1,2,3,4,5))
				P.icon_state = "deliverycrate[i]"
			P.add_fingerprint(usr)
			I.add_fingerprint(usr)
			src.add_fingerprint(usr)
			src.amount -= 1
	else if (istype(O, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = target
		if (src.amount > 3 && !C.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(C.loc))
			P.icon_state = "deliverycrate"
			C.loc = P
			src.amount -= 3
		else if(src.amount < 3)
			to_chat(user, "<span class='notice'>You need more paper.</span>")
	else if (istype (O, /obj/structure/closet))
		var/obj/structure/closet/C = target
		if(src.amount < 3)
			to_chat(user, "<span class='notice'>You need more paper.</span>")
			return
		else if(C.welded)
			to_chat(user, "<span class='notice'>You cannot wrap a welded closet.</span>")
			return
		else if (!C.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(C.loc))
			C.welded = 1
			C.loc = P
			src.amount -= 3
	else
		to_chat(user, "<span class='notice'>The object you are trying to wrap is unsuitable for the sorting machinery!</span>")
	if (src.amount <= 0)
		new /obj/item/weapon/c_tube( src.loc )
		qdel(src)
		return
	return

/obj/item/weapon/packageWrap/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "<span class='notice'>There are [amount] units of package wrap left!</span>")


/obj/item/device/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon_state = "dest_tagger"
	var/currTag = 0

	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	m_amt = 3000
	g_amt = 1300
	origin_tech = "materials=1;engineering=1"

/obj/item/device/destTagger/proc/openwindow(mob/user)
	var/dat = "<tt><center><h1><b>TagMaster 2.3</b></h1></center>"

	dat += "<table style='width:100%; padding:4px;'><tr>"
	for(var/i = 1, i <= tagger_locations.len, i++)
		dat += "<td><a href='?src=\ref[src];nextTag=[tagger_locations[i]]'>[tagger_locations[i]]</a></td>"

		if (i%4==0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? currTag : "None"]</tt>"

	user << browse(dat, "window=destTagScreen;size=450x350")
	onclose(user, "destTagScreen")

/obj/item/device/destTagger/attack_self(mob/user)
	openwindow(user)
	return

/obj/item/device/destTagger/Topic(href, href_list)
	src.add_fingerprint(usr)
	if(href_list["nextTag"] && (href_list["nextTag"] in tagger_locations))
		src.currTag = href_list["nextTag"]
	openwindow(usr)

/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = 1
	icon_state = "intake"

	var/c_mode = 0

/obj/machinery/disposal/deliveryChute/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/disposal/deliveryChute/atom_init_late()
	trunk = locate() in loc
	if(trunk)
		trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/deliveryChute/Destroy()
	if(trunk)
		trunk.linked = null
	return ..()

/obj/machinery/disposal/deliveryChute/interact()
	return

/obj/machinery/disposal/deliveryChute/update()
	return

/obj/machinery/disposal/deliveryChute/Bumped(atom/movable/AM) //Go straight into the chute
	if(istype(AM, /obj/item/projectile) || istype(AM, /obj/effect))	return
	switch(dir)
		if(NORTH)
			if(AM.loc.y != src.loc.y+1) return
		if(EAST)
			if(AM.loc.x != src.loc.x+1) return
		if(SOUTH)
			if(AM.loc.y != src.loc.y-1) return
		if(WEST)
			if(AM.loc.x != src.loc.x-1) return

	if(istype(AM, /obj))
		var/obj/O = AM
		O.loc = src
	else if(istype(AM, /mob))
		var/mob/M = AM
		M.loc = src
	src.flush()

/obj/machinery/disposal/deliveryChute/flush()
	flushing = 1
	flick("intake-closing", src)
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
												// travels through the pipes.
	air_contents = new()		// new empty gas resv.

	sleep(10)
	playsound(src, 'sound/machines/disposalflush.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	sleep(5) // wait for animation to finish

	H.init(src)	// copy the contents of disposer to holder

	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update()
	return

/obj/machinery/disposal/deliveryChute/attackby(obj/item/I, mob/user)
	if(!I || !user)
		return

	if(isscrewdriver(I))
		if(c_mode==0)
			c_mode=1
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "You remove the screws around the power connection.")
			return
		else if(c_mode==1)
			c_mode=0
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "You attach the screws around the power connection.")
			return
	else if(iswelder(I) && c_mode==1 && !user.is_busy())
		var/obj/item/weapon/weldingtool/W = I
		if(W.use(0,user))
			to_chat(user, "You start slicing the floorweld off the delivery chute.")
			if(W.use_tool(src, user, 20, volume = 100))
				to_chat(user, "You sliced the floorweld off the delivery chute.")
				var/obj/structure/disposalconstruct/C = new (src.loc)
				C.ptype = 8 // 8 =  Delivery chute
				C.update()
				C.anchored = 1
				C.density = 1
				qdel(src)
			return
		else
			to_chat(user, "You need more welding fuel to complete this task.")
			return
