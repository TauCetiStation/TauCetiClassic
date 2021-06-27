
#define MAX_NOTICES	5

/obj/structure/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon."
	icon = 'icons/obj/objects.dmi'
	icon_state = "nboard00"
	density = FALSE
	anchored = TRUE
	var/list/notices
	var/base_icon_state = "nboard0"

/obj/structure/noticeboard/atom_init()
	. = ..()

	// Grab any mapped notices.
	notices = list()
	for(var/obj/item/weapon/paper/note in get_turf(src))
		note.forceMove(src)
		LAZYADD(notices, note)
		if(length(notices) >= MAX_NOTICES)
			break

	update_icon()

/obj/structure/noticeboard/proc/add_paper(atom/movable/paper, skip_icon_update)
	if(istype(paper))
		LAZYDISTINCTADD(notices, paper)
		paper.forceMove(src)
		if(!skip_icon_update)
			update_icon()

/obj/structure/noticeboard/Destroy()
	QDEL_NULL(notices)
	. = ..()

/obj/structure/noticeboard/proc/remove_paper(atom/movable/paper, skip_icon_update)
	if(istype(paper) && paper.loc == src)
		paper.loc = get_turf(src)
		LAZYREMOVE(notices, paper)
		if(!skip_icon_update)
			update_icon()

/obj/structure/noticeboard/update_icon()
	icon_state = "[base_icon_state][length(notices)]"

//attaching papers!!
/obj/structure/noticeboard/attackby(obj/item/weapon/O, mob/user)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/photo))
		if(jobban_isbanned(user, "Graffiti"))
			to_chat(user, "<span class='warning'>You are banned from leaving persistent information across rounds.</span>")
		else
			if(length(notices) < MAX_NOTICES && user.unEquip(O, src))
				add_fingerprint(user)
				add_paper(O)
				to_chat(user, "<span class='notice'>You pin [O] to [src].</span>")
			else
				to_chat(user, "<span class='warning'>You hesitate, certain [O] will not be seen among the many others already attached to \the [src].</span>")
		return
	return ..()

/obj/structure/noticeboard/examine(mob/user)
	tgui_interact(user)
	return list()

/obj/structure/noticeboard/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NoticeBoard", name)
		ui.open()

/obj/structure/noticeboard/attack_hand(user)
	examine(user)

/obj/structure/noticeboard/tgui_data(mob/user)
	var/list/data = list()
	var/list/tgui_notices = list()

	for(var/obj/item/I in notices)
		tgui_notices.Add(list(list(
			"ispaper" = istype(I, /obj/item/weapon/paper),
			"isphoto" = istype(I, /obj/item/weapon/photo),
			"name" = I.name,
			"ref" = "\ref[I]",
		)))
	data["notices"] = tgui_notices

	return data

/obj/structure/noticeboard/tgui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("remove")
			if(!in_range(src, usr))
				return FALSE
			var/obj/item/I = locate(params["ref"])
			remove_paper(I)
			if(istype(I))
				usr.put_in_hands(I)
			add_fingerprint(usr)
			. = TRUE

		if("look")
			var/obj/item/weapon/photo/P = locate(params["ref"])
			if(P && P.loc == src)
				P.show(usr)
			. = TRUE

		if("write")
			if(!in_range(src, usr))
				return FALSE
			var/obj/item/P = locate(params["ref"])
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
				. = TRUE

		if("read")
			var/obj/item/weapon/paper/P = locate(params["ref"])
			if(P && P.loc == src)
				P.examine(usr)
			. = TRUE
