/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	var/id = null
	var/height = 0							//the 'height' of the ladder. higher numbers are considered physically higher
	var/obj/structure/ladder/down = null	//the ladder below this one
	var/obj/structure/ladder/up = null		//the ladder above this one

	var/static/list/ladders = list()

/obj/structure/ladder/New(nid, nheight)
	ladders += src

	if(nid)
		id = nid

	if(nheight)
		height = nheight

	if(!id)
		return

	spawn(8)
		for(var/obj/structure/ladder/L in ladders)
			if(L.id == id)
				if(L.height == (height - 1))
					Connect_down(L)
					continue
				if(L.height == (height + 1))
					Connect_up(L)
					continue

			if(up && down)	//if both our connections are filled
				break
		update_icon()

/obj/structure/ladder/Destroy()
	Disconnect_All()
	ladders -= src
	return ..()

/obj/structure/ladder/proc/Connect_down(obj/structure/ladder/Target)
	if(Target)
		down = Target
		Target.up = src
		Target.update_icon()
	update_icon()

/obj/structure/ladder/proc/Connect_up(obj/structure/ladder/Target)
	if(Target)
		up = Target
		Target.down = src
		Target.update_icon()
	update_icon()

/obj/structure/ladder/proc/Disconnect_All()
	Disconnect_up()
	Disconnect_down()

/obj/structure/ladder/proc/Disconnect_down()
	if(down)
		down.up = null
		down.update_icon()
	down = null
	update_icon()

/obj/structure/ladder/proc/Disconnect_up()
	if(up)
		up.down = null
		up.update_icon()
	up = null
	update_icon()

/obj/structure/ladder/update_icon()
	icon_state = "ladder[up ? 1 : 0][down ? 1 : 0]"

/obj/structure/ladder/attack_hand(mob/user)
	if(up && down)
		switch( alert("Go up or down the ladder?", "Ladder", "Up", "Down", "Cancel") )
			if("Up")
				user.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
									 "<span class='notice'>You climb up \the [src]!</span>")
				user.loc = get_turf(up)
				up.add_fingerprint(user)
			if("Down")
				user.visible_message("<span class='notice'>[user] climbs down \the [src]!</span>", \
									 "<span class='notice'>You climb down \the [src]!</span>")
				user.loc = get_turf(down)
				down.add_fingerprint(user)
			if("Cancel")
				return

	else if(up)
		user.visible_message("<span class='notice'>[user] climbs up \the [src]!</span>", \
							 "<span class='notice'>You climb up \the [src]!</span>")
		user.loc = get_turf(up)
		up.add_fingerprint(user)

	else if(down)
		user.visible_message("<span class='notice'>[user] climbs down \the [src]!</span>", \
							 "<span class='notice'>You climb down \the [src]!</span>")
		user.loc = get_turf(down)
		down.add_fingerprint(user)

	add_fingerprint(user)

/obj/structure/ladder/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/ladder/attackby(obj/item/weapon/W, mob/user)
	return attack_hand(user)
