
#define NOTICEBOARD_MAX_NOTICES	30

/obj/item/noticeboard_frame
	name = "noticeboard frame"
	desc = "Used for building noticeboards."
	icon = 'icons/obj/notice_board.dmi'
	icon_state = "notice_board_wood"
	flags = CONDUCT

	var/material
	var/noticeboard

	max_integrity = 150
	resistance_flags = CAN_BE_HIT

/obj/item/noticeboard_frame/attackby(obj/item/I, mob/user, params)
	if(iswrenching(I))
		user.SetNextMove(CLICK_CD_RAPID)
		deconstruct(TRUE)
		return
	return ..()

/obj/item/noticeboard_frame/deconstruct(disassembled)
	new material(get_turf(loc), disassembled ? 10 : 5)
	..()

/obj/item/noticeboard_frame/proc/try_build(mob/user, turf/on_wall)
	if(!in_range(user, on_wall))
		return

	var/ndir = get_dir(on_wall,user)
	if (!(ndir in cardinal))
		return

	var/turf/T = get_turf_loc(user)
	if (!isfloorturf(T))
		to_chat(user, "<span class='warning'>Noticeboard cannot be placed on this spot.</span>")
		return

	if(gotwallitem(T, ndir))
		to_chat(user, "<span class='warning'>There's already an item on this wall!</span>")
		return

	new noticeboard(T, ndir, TRUE)

	qdel(src)

/obj/item/noticeboard_frame/wood
	material = /obj/item/stack/sheet/wood
	noticeboard = /obj/structure/noticeboard

/obj/item/noticeboard_frame/plastic
	material = /obj/item/stack/sheet/mineral/plastic
	noticeboard = /obj/structure/noticeboard/plastic



/obj/structure/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon."
	icon = 'icons/obj/notice_board.dmi'
	icon_state = "notice_board_wood"
	density = FALSE
	anchored = TRUE

	var/list/notices

	var/list/notice_hashes_to_notes
	var/list/notice_hashes_to_ckeys

	var/list/hash_removal_timers

	var/list/icon/paper_icons

	var/list/icon/photo_icons

	var/datum/atom_hud/alternate_appearance/basic/exclude_ckeys/quest

	var/obj/item/noticeboard_frame/frame_type = /obj/item/noticeboard_frame/wood

	var/static/list/note_typecache

	max_integrity = 150
	resistance_flags = CAN_BE_HIT

/obj/structure/noticeboard/atom_init(mapload, dir, building)
	. = ..()

	if(dir)
		set_dir(dir)

	if(building)
		pixel_x = (dir & 3) ? 0 : (dir == 4 ? -32 : 32)
		pixel_y = (dir & 3) ? (dir ==1 ? -32 : 32) : 0

	var/image/quest_image = image(icon, src, "notice_board_attention_mark")
	quest_image.layer = layer + 0.1
	quest = new("quest\ref[src]", quest_image, null)
	quest.theImage.alpha = 0

	if(!note_typecache)
		var/list/note_types = list(
			/obj/item/weapon/paper,
			/obj/item/weapon/photo,
			/obj/item/weapon/paper_bundle,
		)
		note_typecache = list()
		for(var/type in note_types)
			note_typecache += typecacheof(type)

/obj/structure/noticeboard/Destroy()
	for(var/timer in hash_removal_timers)
		deltimer(timer)

	QDEL_LIST(notices)
	for(var/hash in paper_icons)
		var/I = paper_icons[hash]
		qdel(I)
	paper_icons = null

	for(var/hash in photo_icons)
		var/I = photo_icons[hash]
		qdel(I)
	photo_icons = null

	QDEL_NULL(quest)

	return ..()

/obj/structure/noticeboard/proc/get_content(atom/movable/note)
	if(istype(note, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = note
		return P.name + P.info
	if(istype(note, /obj/item/weapon/photo))
		// no easy was to hash photo's contents, so if you insert
		// the same photo, no quest-alarm, but if you make two
		// photos of the same place - alarm.
		// no way to prevent this. very sad, very sad
		return "\ref[note]"
	if(istype(note, /obj/item/weapon/paper_bundle))
		var/obj/item/weapon/paper_bundle/PB = note
		var/list/hashes = list()
		for(var/page in PB.pages)
			hashes += get_content(page)

		hashes = sortList(hashes, cmp=GLOBAL_PROC_REF(cmp_text_asc))

		var/hashstr = ""
		for(var/hash in hashes)
			hashstr += hash
		return PB.name + hashstr

/obj/structure/noticeboard/proc/add_icon(atom/movable/note)
	var/list/add_to
	var/image/I
	if(istype(note, /obj/item/weapon/paper) || istype(note, /obj/item/weapon/paper_bundle))
		I = image(icon, src, "notice_board_paper")
		I.pixel_x = rand(0, 19)
		I.pixel_y = rand(0, 6)
		LAZYINITLIST(paper_icons)
		add_to = paper_icons
	else if(istype(note, /obj/item/weapon/photo))
		I = image(icon, src, "notice_board_photo")
		I.pixel_x = rand(0, 18)
		I.pixel_y = rand(0, 6)
		LAZYINITLIST(photo_icons)
		add_to = photo_icons

	/*
	thanks overlay caching stuff I can't rotate my stuff now cool ~Luduk

	var/matrix/M = matrix()
	M.Turn(rand(-5, 5))

	I.transform = M
	*/

	var/note_ref = "\ref[note]"
	add_to[note_ref] = I
	add_overlay(I)

/obj/structure/noticeboard/proc/pop_icon(atom/movable/note)
	var/list/pop_from
	if(istype(note, /obj/item/weapon/paper) || istype(note, /obj/item/weapon/paper_bundle))
		pop_from = paper_icons
	else if(istype(note, /obj/item/weapon/photo))
		pop_from = photo_icons

	var/note_ref = "\ref[note]"
	cut_overlay(pop_from[note_ref])
	qdel(pop_from[note_ref])
	LAZYREMOVE(pop_from, note_ref)

// Note is a photo, paper, or a bundle.
/obj/structure/noticeboard/proc/add_note(atom/movable/note)
	var/note_hash = md5(get_content(note))

	LAZYSET(notices, note, note_hash)
	note.forceMove(src)

	quest.theImage.alpha = 255

	add_icon(note)

	var/timer = LAZYACCESS(hash_removal_timers, note_hash)
	if(timer)
		deltimer(timer)

	LAZYINITLIST(notice_hashes_to_notes)
	LAZYADD(notice_hashes_to_notes[note_hash], note)

	var/list/already_seen = LAZYACCESS(notice_hashes_to_ckeys, note_hash)

	if(already_seen)
		quest.ckeys = already_seen.Copy()
	else
		quest.ckeys = null

	for(var/viewer in player_list)
		var/mob/M = viewer
		if(quest.mobShouldSee(M))
			quest.add_hud_to(M)

/obj/structure/noticeboard/proc/remove_note(atom/movable/note)
	note.forceMove(get_turf(src))
	LAZYREMOVE(notices, note)
	if(!notices)
		quest.theImage.alpha = 0

	pop_icon(note)

	var/note_hash = md5(get_content(note))

	LAZYREMOVE(notice_hashes_to_notes[note_hash], note)
	UNSETEMPTY(notice_hashes_to_notes)

	if(!notice_hashes_to_notes)
		LAZYSET(hash_removal_timers, note_hash, addtimer(CALLBACK(src, PROC_REF(remove_hash), note_hash), 2 MINUTES, TIMER_STOPPABLE))

/obj/structure/noticeboard/proc/remove_hash(note_hash)
	LAZYREMOVE(hash_removal_timers, note_hash)
	LAZYREMOVE(notice_hashes_to_ckeys, note_hash)

/obj/structure/noticeboard/proc/add_viewer(mob/viewer)
	if(!viewer.ckey)
		return
	if(!quest.mobShouldSee(viewer))
		return

	LAZYINITLIST(notice_hashes_to_ckeys)
	for(var/note in notices)
		var/note_hash = notices[note]
		LAZYSET(notice_hashes_to_ckeys[note_hash], viewer.ckey, TRUE)

	quest.remove_hud_from(viewer, TRUE)
	LAZYSET(quest.ckeys, viewer.ckey, TRUE)

//attaching papers!!
/obj/structure/noticeboard/attackby(obj/item/I, mob/user)
	if(iswrenching(I) && !user.is_busy() && do_after(user, 40, TRUE, src, FALSE, TRUE))
		deconstruct(TRUE)
		return

	if(!is_type_in_typecache(I, note_typecache))
		return ..()

	if(length(notices) >= NOTICEBOARD_MAX_NOTICES)
		to_chat(user, "<span class='warning'>You hesitate, certain [I] will not be seen among the many others already attached to \the [src].</span>")
		return
	if(length(hash_removal_timers) >= NOTICEBOARD_MAX_NOTICES)
		to_chat(user, "<span class='warning'>You hesitate, certain [I] will not be noticed when so many papers were attached and remove from \the [src].</span>")
		return
	if(!user.drop_from_inventory(I, src))
		return

	add_fingerprint(user)
	add_note(I)
	to_chat(user, "<span class='notice'>You pin [I] to [src].</span>")

/obj/structure/noticeboard/deconstruct(disassembled)
	if(!(flags & NODECONSTRUCT))
		var/obj/frame = new frame_type(loc)
		if(!disassembled)
			frame.deconstruct(FALSE)
	for(var/notice in notices)
		remove_note(notices[notice])
	..()

/obj/structure/noticeboard/examine(mob/user)
	var/datum/tgui/ui = tgui_interact(user)
	if(ui.status < UI_UPDATE)
		return
	add_viewer(user)

/obj/structure/noticeboard/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NoticeBoard", name)
		ui.open()

	return ui

/obj/structure/noticeboard/attack_hand(user)
	examine(user)

/obj/structure/noticeboard/tgui_data(mob/user)
	var/list/data = list()
	var/list/tgui_notices = list()

	for(var/obj/item/I in notices)
		tgui_notices.Add(list(list(
			"ispaper" = istype(I, /obj/item/weapon/paper),
			"isphoto" = istype(I, /obj/item/weapon/photo),
			"isbundle" = istype(I, /obj/item/weapon/paper_bundle),
			"name" = I.name,
			"ref" = "\ref[I]",
		)))
	data["notices"] = tgui_notices

	return data

/obj/structure/noticeboard/tgui_act(action, params)
	. = ..()
	if(.)
		return

	if(!in_range(src, usr))
		return FALSE

	switch(action)
		if("remove")
			var/obj/item/I = locate(params["ref"])
			if(I && I.loc == src)
				remove_note(I)
				usr.put_in_hands(I)
				add_fingerprint(usr)
				return TRUE

		if("look")
			var/obj/item/weapon/photo/P = locate(params["ref"])
			if(!istype(P))
				return FALSE
			if(P && P.loc == src)
				P.show(usr)
				return TRUE

		if("write")
			var/obj/item/weapon/paper/P = locate(params["ref"])
			if(!istype(P))
				return FALSE
			if((P && P.loc == src)) //if the paper's on the board
				if(istype(usr.r_hand, /obj/item/weapon/pen)) //and you're holding a pen
					add_fingerprint(usr)
					P.attackby(usr.r_hand, usr) //then do ittttt
				else
					if(istype(usr.l_hand, /obj/item/weapon/pen)) //check other hand for pen
						add_fingerprint(usr)
						P.attackby(usr.l_hand, usr)
					else
						to_chat(usr, "<span class='notice'>You'll need something to write with!</span>")
				return TRUE

		if("read")
			var/obj/item/P = locate(params["ref"])
			if(P && P.loc == src)
				P.examine(usr)
				return TRUE

/obj/structure/noticeboard/plastic
	icon_state = "notice_board_plastic"
	frame_type = /obj/item/noticeboard_frame/plastic

/obj/structure/noticeboard/bar
	icon_state = "notice_board_bar"
	frame_type = /obj/item/noticeboard_frame/plastic

/obj/structure/noticeboard/chaplain
	icon_state = "notice_board_chapel"
	frame_type = /obj/item/noticeboard_frame/wood

#undef NOTICEBOARD_MAX_NOTICES
