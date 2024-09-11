/atom/movable/screen/close
	name = "close"
	icon_state = "x"

/atom/movable/screen/close/action()
	if(master)
		var/obj/item/weapon/storage/S = master
		S.close(usr)

/atom/movable/screen/storage
	name = "storage"
	var/obj/item/last_outlined // for removing outline from item

/atom/movable/screen/storage/Destroy()
	last_outlined = null
	return ..()

/atom/movable/screen/storage/action(location, control, params)
	if(world.time <= usr.next_move)
		return
	if(usr.incapacitated())
		return
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(I, usr, params)
			usr.next_move = world.time+2
			return

		var/obj/item/weapon/storage/S = master
		if(!S || !S.storage_ui)
			return
		// Taking something out of the storage screen (including clicking on item border overlay)
		var/list/PM = params2list(params)
		var/list/screen_loc_params = splittext(PM[SCREEN_LOC], ",")
		var/list/screen_loc_X = splittext(screen_loc_params[1],":")
		var/click_x = text2num(screen_loc_X[1])*32+text2num(screen_loc_X[2]) - 144

		for(var/i=1,i<=S.storage_ui.click_border_start.len,i++)
			if (S.storage_ui.click_border_start[i] <= click_x && click_x <= S.storage_ui.click_border_end[i] && i <= S.contents.len)
				I = S.contents[i]
				if (I)
					I.Click(location, control, params)
					return

/atom/movable/screen/storage/MouseEntered(location, control, params)
	. = ..()
	if(!master)
		return
	var/obj/item/weapon/storage/S = master
	if(!S || !S.storage_ui)
		return
	// Taking something out of the storage screen (including clicking on item border overlay)
	var/list/PM = params2list(params)
	var/list/screen_loc_params = splittext(PM[SCREEN_LOC], ",")
	var/list/screen_loc_X = splittext(screen_loc_params[1],":")
	var/click_x = text2num(screen_loc_X[1])*32+text2num(screen_loc_X[2]) - 144

	var/obj/item/I
	for(var/i in 1 to S.storage_ui.click_border_start.len)
		if (S.storage_ui.click_border_start[i] <= click_x && click_x <= S.storage_ui.click_border_end[i] && i <= S.contents.len)
			I = S.contents[i]
			if (I)
				last_outlined = I
				if(usr.incapacitated() || istype(usr.loc, /obj/mecha))
					I.apply_outline(COLOR_RED_LIGHT)
				else
					I.apply_outline()
				return

/atom/movable/screen/storage/MouseExited()
	. = ..()
	last_outlined?.remove_outline()
	last_outlined = null

/atom/movable/screen/storage/MouseDrop()
	. = ..()
	last_outlined?.remove_outline()
	last_outlined = null
