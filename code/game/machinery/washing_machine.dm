/obj/machinery/washing_machine
	name = "Washing Machine"
	desc = "Washes your bloody clothes."
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = 1
	anchored = 1.0
	use_power = NO_POWER_USE
	var/state = 1
	//1 = empty, open door
	//2 = empty, closed door
	//3 = full, open door
	//4 = full, closed door
	//5 = running
	//6 = blood, open door
	//7 = blood, closed door
	//8 = blood, running
	var/panel = 0
	//0 = closed
	//1 = open
	var/hacked = 1 //Bleh, screw hacking, let's have it hacked by default.
	//0 = not hacked
	//1 = hacked
	var/gibs_ready = 0
	var/obj/crayon

/obj/machinery/washing_machine/verb/start()
	set name = "Start Washing"
	set category = "Object"
	set src in oview(1)

	if(!istype(usr, /mob/living)) //ew ew ew usr, but it's the only way to check.
		return

	if( state != 4 )
		to_chat(usr, "The washing machine cannot run in this state.")
		return

	if( locate(/mob,contents) )
		state = 8
	else
		state = 5
	update_icon()
	playsound(src, 'sound/items/washingmachine.ogg', VOL_EFFECTS_MASTER)
	sleep(210)
	for(var/atom/A in contents)
		A.clean_blood()

	for(var/obj/item/I in contents)
		I.decontaminate()
		I.wet = 0

	var/wash_color
	if(istype(crayon,/obj/item/toy/crayon))
		var/obj/item/toy/crayon/CR = crayon
		wash_color = CR.colour
	for (var/obj/item/clothing/C in contents)
		if(C.can_be_colored == TRUE)
			C.icon_state = "color"
			C.item_color ="color"
			C.color = wash_color
		if (istype (C, /obj/item/clothing/under))
			C.item_state ="w_suit"
			C.name = C.colored_name
		if (istype (C, /obj/item/clothing/shoes))
			C.item_state =""
			C.name = C.colored_name
		if (istype (C, /obj/item/clothing/gloves))
			C.name = C.colored_name
		qdel(crayon)
		crayon = null


	if( locate(/mob,contents) )
		state = 7
		gibs_ready = 1
	else
		state = 4
	update_icon()

/obj/machinery/washing_machine/verb/climb_out()
	set name = "Climb out"
	set category = "Object"
	set src in usr.loc

	sleep(20)
	if(state in list(1,3,6) )
		usr.loc = src.loc


/obj/machinery/washing_machine/update_icon()
	icon_state = "wm_[state][panel]"

/obj/machinery/washing_machine/attackby(obj/item/weapon/W, mob/user)
	/*if(isscrewdriver(W))
		panel = !panel
		to_chat(user, "<span class='notice'>you [panel ? </span>"open" : "close"] the [src]'s maintenance panel")*/
	if (istype (W, /obj/item/toy/crayon))
		if( state in list(	1, 3, 6 ))
			if(!crayon)
				user.drop_item()
				crayon = W
				crayon.loc = src
			else
				..()
		else
			..()
	else if(istype(W,/obj/item/weapon/grab))
		if( (state == 1) && hacked)
			var/obj/item/weapon/grab/G = W
			if(ishuman(G.assailant) && iscorgi(G.affecting))
				G.affecting.loc = src
				qdel(G)
				state = 3
		else
			..()

	else if(istype(W,/obj/item/stack/sheet/hairlesshide) || \
		istype(W,/obj/item/clothing/under) || \
		istype(W,/obj/item/clothing/mask) || \
		istype(W,/obj/item/clothing/head) || \
		istype(W,/obj/item/clothing/gloves) || \
		istype(W,/obj/item/clothing/shoes) || \
		istype(W,/obj/item/clothing/suit) || \
		istype(W,/obj/item/weapon/bedsheet))

		var/obj/item/clothing/C = W


		if(!C.can_be_washed)
			to_chat(user, "<span class='notice'>\ You cant put [W] in the washing machine!</span>")
			return

		if(!C.canremove)
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in the washing machine!</span>")
			return

		if(contents.len < 5)
			if ( state in list(1, 3) )
				user.drop_item()
				W.loc = src
				state = 3
			else
				to_chat(user, "<span class='notice'>You can't put the item in right now.</span>")
		else
			to_chat(user, "<span class='notice'>The washing machine is full.</span>")
	else
		..()
	update_icon()

/obj/machinery/washing_machine/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()

/obj/machinery/washing_machine/attack_hand(mob/user)
	if(..())
		return 1
	user.SetNextMove(CLICK_CD_RAPID)
	switch(state)
		if(1)
			state = 2
		if(2)
			state = 1
			for(var/atom/movable/O in contents)
				O.loc = src.loc
		if(3)
			state = 4
		if(4)
			state = 3
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1
		if(5)
			to_chat(user, "<span class='warning'>The [src] is busy.</span>")
		if(6)
			state = 7
		if(7)
			if(gibs_ready)
				gibs_ready = 0
				if(locate(/mob,contents))
					var/mob/M = locate(/mob,contents)
					M.gib()
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1

	update_icon()
