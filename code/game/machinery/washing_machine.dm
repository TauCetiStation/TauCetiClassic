var/global/list/dyed_item_types = list(
	DYED_UNIFORM = list(
		DYE_RED = ,
		DYE_ORANGE = ,
		DYE_YELLOW = ,
		DYE_GREEN = ,
		DYE_BLUE = ,
		DYE_PURPLE = ,
		DYE_WHITE = ,
		DYE_MIME = ,
		DYE_RAINBOW = ,
		DYE_CARGO = ,
		DYE_CAPTAIN = ,
		DYE_HOP = ,
		DYE_HOS = ,
		DYE_CE = ,
		DYE_RD = ,
		DYE_CMO = ,
		DYE_QM = ,
		DYE_GREENCOAT = ,
		DYE_REDCOAT = ,
		DYE_CLOWN = ,
		DYE_IAA = ,
		DYE_CENTCOMM = ,
		DYE_FAKECENTCOM = ,
		DYE_SYNDICATE = ,
	),
	DYED_GLOVES = list(
		DYE_RED = /obj/item/clothing/gloves/red,
		DYE_ORANGE = /obj/item/clothing/gloves/orange,
		DYE_YELLOW = list(/obj/item/clothing/gloves/yellow, /obj/item/clothing/gloves/fyellow),
		DYE_GREEN = /obj/item/clothing/gloves/green,
		DYE_BLUE = /obj/item/clothing/gloves/blue,
		DYE_PURPLE = /obj/item/clothing/gloves/purple,
		DYE_WHITE = /obj/item/clothing/gloves/white,
		DYE_MIME = /obj/item/clothing/gloves/red,
		DYE_RAINBOW = /obj/item/clothing/gloves/rainbow,
		DYE_CARGO = /obj/item/clothing/gloves/brown,
		DYE_CAPTAIN = /obj/item/clothing/gloves/captain,
		DYE_HOP = /obj/item/clothing/gloves/grey,
		DYE_HOS = /obj/item/clothing/gloves/black/hos,
		DYE_CE = /obj/item/clothing/gloves/black/ce,
		DYE_RD = /obj/item/clothing/gloves/grey,
		DYE_CMO = /obj/item/clothing/gloves/latex,
		DYE_QM = /obj/item/clothing/gloves/brown,
		DYE_CLOWN = /obj/item/clothing/gloves/rainbow,
		DYE_SYNDICATE = /obj/item/clothing/gloves/combat,
	),
	DYED_FINGERLESS_GLOVES = list(
		DYE_RED = ,
		DYE_ORANGE = ,
		DYE_YELLOW = ,
		DYE_GREEN = ,
		DYE_BLUE = ,
		DYE_PURPLE = ,
		DYE_WHITE = ,
		DYE_MIME = ,
		DYE_RAINBOW = ,
		DYE_CARGO = ,
		DYE_CAPTAIN = ,
		DYE_HOP = ,
		DYE_HOS = ,
		DYE_CE = ,
		DYE_RD = ,
		DYE_CMO = ,
		DYE_QM = ,
		DYE_GREENCOAT = ,
		DYE_REDCOAT = ,
		DYE_CLOWN = ,
		DYE_IAA = ,
		DYE_CENTCOMM = ,
		DYE_FAKECENTCOM = ,
		DYE_SYNDICATE = ,
	),
	DYED_BEDSHEET = list(
		DYE_RED = /obj/item/weapon/bedsheet/red,
		DYE_ORANGE = /obj/item/weapon/bedsheet/orange,
		DYE_YELLOW = /obj/item/weapon/bedsheet/yellow,
		DYE_GREEN = /obj/item/weapon/bedsheet/green,
		DYE_BLUE = /obj/item/weapon/bedsheet/blue,
		DYE_PURPLE = /obj/item/weapon/bedsheet/purple,
		DYE_WHITE = /obj/item/weapon/bedsheet,
		DYE_MIME = /obj/item/weapon/bedsheet/mime,
		DYE_RAINBOW = /obj/item/weapon/bedsheet/rainbow,
		DYE_CARGO = /obj/item/weapon/bedsheet/brown,
		DYE_CAPTAIN = /obj/item/weapon/bedsheet/captain,
		DYE_HOS = /obj/item/weapon/bedsheet/hos,
		DYE_CE = /obj/item/weapon/bedsheet/ce,
		DYE_RD = /obj/item/weapon/bedsheet/rd,
		DYE_CMO = /obj/item/weapon/bedsheet/medical,
		DYE_QM = /obj/item/weapon/bedsheet/brown,
		DYE_CLOWN = /obj/item/weapon/bedsheet/clown,
		DYE_CENTCOMM = /obj/item/weapon/bedsheet/centcom,
		DYE_FAKECENTCOM = list(/obj/item/weapon/bedsheet/gar, /obj/item/weapon/bedsheet/cult, /obj/item/weapon/bedsheet/wiz),
		DYE_SYNDICATE = /obj/item/weapon/bedsheet/syndie,
	),
	DYED_SOFTCAP = list(
		DYE_RED = /obj/item/clothing/head/soft/red,
		DYE_ORANGE = /obj/item/clothing/head/soft/orange,
		DYE_YELLOW = /obj/item/clothing/head/soft/yellow,
		DYE_GREEN = /obj/item/clothing/head/soft/green,
		DYE_BLUE = /obj/item/clothing/head/soft/blue,
		DYE_PURPLE = /obj/item/clothing/head/soft/purple,
		DYE_MIME = /obj/item/clothing/head/soft/mime,
		DYE_RAINBOW = /obj/item/clothing/head/soft/rainbow,
		DYE_CARGO = /obj/item/clothing/head/soft,
		DYE_CMO = /obj/item/clothing/head/soft/paramed,
		DYE_QM = /obj/item/clothing/head/soft,
		DYE_CLOWN = /obj/item/clothing/head/soft/rainbow,
		DYE_CENTCOMM = /obj/item/clothing/head/soft/nt_pmc_cap,
		DYE_FAKECENTCOM = /obj/item/clothing/head/soft/sec/corp,
	),
)

/obj/machinery/washing_machine
	name = "Washing Machine"
	desc = "Washes your bloody clothes."
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = TRUE
	anchored = TRUE
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

/obj/machinery/washing_machine/Destroy()
	QDEL_NULL(crayon)
	return ..()

/obj/machinery/washing_machine/proc/get_wash_color()
	if(!crayon)
		return null

	if(istype(crayon,/obj/item/toy/crayon))
		var/obj/item/toy/crayon/CR = crayon
		return CR.colourName

	if(istype(crayon,/obj/item/weapon/stamp))
		var/obj/item/weapon/stamp/ST = crayon
		return ST.dye_color

	return null

/obj/machinery/washing_machine/proc/wash(atom/A, w_color)
	A.clean_blood()

	if(!isitem(A))
		return
	var/obj/item/I = A
	I.wash_act(w_color)

/obj/machinery/washing_machine/verb/start()
	set name = "Start Washing"
	set category = "Object"
	set src in oview(1)

	if(!isliving(usr)) //ew ew ew usr, but it's the only way to check.
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

	var/w_color = get_wash_color()

	for(var/I as anything in contents)
		wash(I, w_color)

	if(crayon)
		QDEL_NULL(crayon)

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
	if(istype(W,/obj/item/toy/crayon) ||istype(W,/obj/item/weapon/stamp))
		if( state in list(	1, 3, 6 ) )
			if(!crayon)
				user.drop_from_inventory(W, src)
				crayon = W
			else
				..()
		else
			..()
	else if(istype(W,/obj/item/weapon/grab))
		if( (state == 1) && hacked)
			var/obj/item/weapon/grab/G = W
			if(ishuman(G.assailant) && (iscorgi(G.affecting) || isIAN(G.affecting)))
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

		//YES, it's hardcoded... saves a var/can_be_washed for every single clothing item.
		if ( istype(W,/obj/item/clothing/suit/space ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/syndicatefake ) )
			to_chat(user, "This item does not fit.")
			return
//		if ( istype(W,/obj/item/clothing/suit/powered ) )
//			user << "This item does not fit."
//			return
		if ( istype(W,/obj/item/clothing/suit/cyborg_suit ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/bomb_suit ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/armor ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/armor ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/mask/gas ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/mask/cigarette ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/head/syndicatefake ) )
			to_chat(user, "This item does not fit.")
			return
//		if ( istype(W,/obj/item/clothing/head/powered ) )
//			user << "This item does not fit."
//			return
		if ( istype(W,/obj/item/clothing/head/helmet ) )
			to_chat(user, "This item does not fit.")
			return
		if (istype(W, /obj/item/clothing/gloves/pipboy))
			to_chat(user, "This item does not fit.")
			return
		if(!W.canremove) //if "can't drop" item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in the washing machine!</span>")
			return

		if(contents.len < 5)
			if ( state in list(1, 3) )
				user.drop_from_inventory(W, src)
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
