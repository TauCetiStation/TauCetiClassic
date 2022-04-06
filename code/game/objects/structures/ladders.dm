/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	anchored = TRUE
	var/id = null
	var/height = 0							//the 'height' of the ladder. higher numbers are considered physically higher
	var/obj/structure/ladder/down = null	//the ladder below this one
	var/obj/structure/ladder/up = null		//the ladder above this one

/obj/structure/ladder/atom_init()
	ladder_list += src
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/ladder/atom_init_late()
	for(var/obj/structure/ladder/L in ladder_list)
		if(L.id == id)
			if(L.height == (height - 1))
				down = L
				continue
			if(L.height == (height + 1))
				up = L
				continue

		if(up && down)	//if both our connections are filled
			break
	update_icon()

/obj/structure/ladder/Destroy()
	ladder_list -= src
	return ..()

/obj/structure/ladder/update_icon()
	if(up && down)
		icon_state = "ladder11"

	else if(up)
		icon_state = "ladder10"

	else if(down)
		icon_state = "ladder01"

	else	//wtf make your ladders properly assholes
		icon_state = "ladder00"

/obj/structure/ladder/attack_hand(mob/user)
	if(up && down)
		switch(tgui_alert(usr, "Go up or down the ladder?", "Ladder", list("Up", "Down", "Cancel")) )
			if("Up")
				climb_ladder(user, up)
			if("Down")
				climb_ladder(user, down)
			if("Cancel")
				return

	else if(up)
		climb_ladder(user, up)

	else if(down)
		climb_ladder(user, down)

	add_fingerprint(user)

/obj/structure/ladder/proc/climb_ladder(mob/user, obj/structure/ladder/destination)
	destination.add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] tries to climb the ladder.</span>")
	destination.visible_message("<span class='warning'>Someone is trying to climb the ladder!</span>")
	playsound(src, 'sound/effects/ladder.ogg', VOL_EFFECTS_MASTER)
	playsound(destination, 'sound/effects/ladder.ogg', VOL_EFFECTS_MASTER)
	if(!user.is_busy() && do_after(user, 15, target = src))
		if(user.pulling)
			user.pulling.forceMove(get_turf(destination))
		user.forceMove(get_turf(destination))
		user.visible_message("<span class='notice'>[user] climbs the ladder.</span>")
		handle_teleport_grab(get_turf(destination), user, victim_spread = FALSE)

/obj/structure/ladder/attack_paw(mob/user)
	return attack_hand(user)
