/datum/storage_ui/default
	var/list/is_seeing = new/list() //List of mobs which are currently seeing the contents of this item's storage

	var/obj/screen/storage/boxes
	var/obj/screen/storage/storage_start //storage UI
	var/obj/screen/storage/storage_continue
	var/obj/screen/storage/storage_end
	var/obj/screen/stored_start
	var/obj/screen/stored_continue
	var/obj/screen/stored_end
	var/obj/screen/close/closer


/datum/storage_ui/default/New(var/storage)
	..()
	boxes = new /obj/screen/storage(  )
	boxes.name = "storage"
	boxes.master = storage
	boxes.icon_state = "block"
	boxes.screen_loc = "7,7 to 10,8"
	boxes.layer = HUD_LAYER
	boxes.plane = HUD_PLANE

	storage_start = new /obj/screen/storage(  )
	storage_start.name = "storage"
	storage_start.master = storage
	storage_start.icon_state = "storage_start"
	storage_start.screen_loc = "7,7 to 10,8"
	storage_start.layer = HUD_LAYER
	storage_start.plane = HUD_PLANE
	storage_continue = new /obj/screen/storage(  )
	storage_continue.name = "storage"
	storage_continue.master = storage
	storage_continue.icon_state = "storage_continue"
	storage_continue.screen_loc = "7,7 to 10,8"
	storage_continue.layer = HUD_LAYER
	storage_continue.plane = HUD_PLANE
	storage_end = new /obj/screen/storage(  )
	storage_end.name = "storage"
	storage_end.master = storage
	storage_end.icon_state = "storage_end"
	storage_end.screen_loc = "7,7 to 10,8"
	storage_end.layer = HUD_LAYER
	storage_end.plane = HUD_PLANE

	stored_start = new //we just need these to hold the icon
	stored_start.icon_state = "stored_start"
	stored_start.layer = HUD_LAYER
	stored_start.plane = HUD_PLANE
	stored_continue = new
	stored_continue.icon_state = "stored_continue"
	stored_continue.layer = HUD_LAYER
	stored_continue.plane = HUD_PLANE
	stored_end = new
	stored_end.icon_state = "stored_end"
	stored_end.layer = HUD_LAYER
	stored_end.plane = HUD_PLANE

	closer = new /obj/screen/close(  )
	closer.master = storage
	closer.icon_state = "x"
	closer.layer = HUD_LAYER
	closer.plane = HUD_PLANE

/datum/storage_ui/default/Destroy()
	close_all()
	QDEL_NULL(boxes)
	QDEL_NULL(storage_start)
	QDEL_NULL(storage_continue)
	QDEL_NULL(storage_end)
	QDEL_NULL(stored_start)
	QDEL_NULL(stored_continue)
	QDEL_NULL(stored_end)
	QDEL_NULL(closer)
	. = ..()

/datum/storage_ui/default/on_open(var/mob/user)
	if (user.s_active)
		user.s_active.close(user)

/datum/storage_ui/default/after_close(var/mob/user)
	user.s_active = null

/datum/storage_ui/default/on_insertion(var/mob/user)
	//if(user.s_active)
	//	user.s_active.show_to(user)
	for(var/mob/M in can_see_contents())
		M.s_active.show_to(M)

/datum/storage_ui/default/on_pre_remove(var/mob/user, var/obj/item/W)
	for(var/mob/M in can_see_contents())
		if(M.client)
			M.client.screen -= W

/datum/storage_ui/default/on_post_remove(var/mob/user)
	if(user.s_active)
		user.s_active.show_to(user)

/datum/storage_ui/default/on_hand_attack(var/mob/user)
	for(var/mob/M in range(1))
		if (M.s_active == storage)
			storage.close(M)

/datum/storage_ui/default/show_to(var/mob/user)
	if(user.s_active != storage)
		for(var/obj/item/I in storage)
			if(I.on_found(user))
				return
	if(user.s_active)
		user.s_active.hide_from(user)
	user.client.screen -= boxes
	user.client.screen -= storage_start
	user.client.screen -= storage_continue
	user.client.screen -= storage_end
	user.client.screen -= closer
	user.client.screen -= storage.contents
	user.client.screen += closer
	user.client.screen += storage.contents
	if(storage.storage_slots)
		user.client.screen += boxes
	else
		user.client.screen += storage_start
		user.client.screen += storage_continue
		user.client.screen += storage_end
	is_seeing |= user
	user.s_active = storage

/datum/storage_ui/default/hide_from(var/mob/user)
	is_seeing -= user
	if(!user.client)
		return
	user.client.screen -= boxes
	user.client.screen -= storage_start
	user.client.screen -= storage_continue
	user.client.screen -= storage_end
	user.client.screen -= closer
	user.client.screen -= storage.contents
	if(user.s_active == storage)
		user.s_active = null

//Creates the storage UI
/datum/storage_ui/default/prepare_ui()
	//if storage slots is null then use the storage space UI, otherwise use the slots UI
	if(storage.storage_slots == null)
		space_orient_objs()
	else
		slot_orient_objs()

/datum/storage_ui/default/close_all()
	for(var/mob/M in can_see_contents())
		storage.close(M)
		. = 1

/datum/storage_ui/default/proc/can_see_contents()
	var/list/cansee = list()
	for(var/mob/M in is_seeing)
		if(M.s_active == storage && M.client)
			cansee |= M
		else
			is_seeing -= M
	return cansee

//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/datum/storage_ui/default/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes.screen_loc = "[tx]:,[ty] to [mx],[my]"
	for(var/obj/O in storage.contents)
		O.screen_loc = "[cx],[cy]"
		//O.hud_layerise()
		O.layer = ABOVE_HUD_LAYER
		O.plane = ABOVE_HUD_PLANE
		cx++
		if (cx > mx)
			cx = tx
			cy--
	closer.screen_loc = "[mx+1],[my]"
	return

//This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/datum/storage_ui/default/proc/slot_orient_objs()
	var/adjusted_contents = storage.contents.len
	click_border_start.Cut()
	click_border_end.Cut()

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(storage.display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		var/obj_index = 0
		for(var/obj/item/I in storage.contents)
			obj_index++
			var/found = 0
			for(var/datum/numbered_display/ND in numbered_contents)
				if(ND.sample_object.type == I.type)
					ND.number++
					found = 1
					break
			if(!found)
				adjusted_contents++
				numbered_contents.Add( new/datum/numbered_display(I, obj_index) )

	var/row_num = 0
	var/col_count = min(7,storage.storage_slots) -1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	arrange_item_slots(row_num, col_count, numbered_contents)

//This proc draws out the inventory and places the items on it. It uses the standard position.
/datum/storage_ui/default/proc/arrange_item_slots(var/rows, var/cols, list/obj/item/display_contents)
	var/cx = 4
	var/cy = 2+rows
	boxes.screen_loc = "4:16,2:16 to [4+cols]:16,[2+rows]:16"

	if(storage.display_contents_with_number)
		click_border_start.len = storage.contents.len
		click_border_end.len = storage.contents.len
		for(var/datum/numbered_display/ND in display_contents)
			ND.sample_object.screen_loc = "[cx]:16,[cy]:16"
			ND.sample_object.maptext = "<font color='white'>[(ND.number > 1)? "[ND.number]" : ""]</font>"
			ND.sample_object.layer = ABOVE_HUD_LAYER
			ND.sample_object.plane = ABOVE_HUD_PLANE
			click_border_start[ND.sample_object_index] = (cx-4)*32
			click_border_end[ND.sample_object_index] = (cx-4)*32+32
			cx++
			if (cx > (4+cols))
				cx = 4
				cy--
	else
		for(var/obj/O in storage.contents)
			O.screen_loc = "[cx]:16,[cy]:16"
			O.maptext = ""
			O.layer = ABOVE_HUD_LAYER
			O.plane = ABOVE_HUD_PLANE
			click_border_start += (cx-4)*32
			click_border_end += (cx-4)*32+32
			cx++
			if (cx > (4+cols))
				cx = 4
				cy--

	closer.screen_loc = "[4+cols+1]:16,2:16"

/datum/numbered_display
	var/obj/item/sample_object
	var/sample_object_index = 1
	var/number

/datum/numbered_display/New(obj/item/sample, soi)
	if(!istype(sample))
		qdel(src)
	sample_object = sample
	sample_object_index = soi
	number = 1

/datum/storage_ui/default/proc/space_orient_objs()

	var/baseline_max_storage_space = DEFAULT_BOX_STORAGE //storage size corresponding to 224 pixels
	var/storage_cap_width = 2 //length of sprite for start and end of the box representing total storage space
	var/stored_cap_width = 4 //length of sprite for start and end of the box representing the stored item
	var/storage_width = min( round( 224 * storage.max_storage_space/baseline_max_storage_space ,1) ,284) //length of sprite for the box representing total storage space

	click_border_start.Cut()
	click_border_end.Cut()
	storage_start.cut_overlays()

	var/matrix/M = matrix()
	M.Scale((storage_width-storage_cap_width*2+3)/32,1)
	storage_continue.transform = M

	storage_start.screen_loc = "4:16,2:16"
	storage_continue.screen_loc = "4:[round(storage_cap_width+(storage_width-storage_cap_width*2)/2+2)],2:16"
	storage_end.screen_loc = "4:[19+storage_width-storage_cap_width],2:16"

	var/startpoint = 0
	var/endpoint = 1

	for(var/obj/item/O in storage.contents)
		startpoint = endpoint + 1
		endpoint += storage_width * O.get_storage_cost()/storage.max_storage_space

		click_border_start.Add(startpoint)
		click_border_end.Add(endpoint)

		var/matrix/M_start = matrix()
		var/matrix/M_continue = matrix()
		var/matrix/M_end = matrix()
		M_start.Translate(startpoint,0)
		M_continue.Scale(CEIL(endpoint-startpoint-stored_cap_width*2)/32,1)
		M_continue.Translate(startpoint+stored_cap_width+(endpoint-startpoint-stored_cap_width*2)/2 - 16,0)
		M_end.Translate(endpoint-stored_cap_width,0)
		stored_start.transform = M_start
		stored_continue.transform = M_continue
		stored_end.transform = M_end
		storage_start.add_overlay(stored_start)
		storage_start.add_overlay(stored_continue)
		storage_start.add_overlay(stored_end)

		O.screen_loc = "4:[round((startpoint+endpoint)/2)],2:16"
		O.maptext = ""
		O.layer = ABOVE_HUD_LAYER
		O.plane = HUD_PLANE

	closer.screen_loc = "4:[storage_width+19],2:16"
