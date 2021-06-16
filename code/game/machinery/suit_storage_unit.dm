//////////////////////////////////////
// SUIT STORAGE UNIT /////////////////
//////////////////////////////////////


/obj/machinery/suit_storage_unit
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "suitstorage000000100" //order is: [has helmet][has suit][has human][is open][is locked][is UV cycling][is powered][is dirty/broken] [is superUVcycling]
	anchored = TRUE
	density = TRUE
	var/mob/living/carbon/human/OCCUPANT = null
	var/obj/item/clothing/suit/space/SUIT = null
	var/SUIT_TYPE = null
	var/obj/item/clothing/head/helmet/space/HELMET = null
	var/HELMET_TYPE = null
	var/obj/item/clothing/mask/MASK = null  //All the stuff that's gonna be stored insiiiiiiiiiiiiiiiiiiide, nyoro~n
	var/MASK_TYPE = null //Erro's idea on standarising SSUs whle keeping creation of other SSU types easy: Make a child SSU, name it something then set the TYPE vars to your desired suit output. New() should take it from there by itself.
	var/isopen = 0
	var/islocked = 0
	var/isUV = 0
	var/ispowered = 1 //starts powered
	var/isbroken = 0
	var/issuperUV = 0
	var/panelopen = 0
	var/safetieson = 1
	var/cycletime_left = 0


//The units themselves/////////////////

/obj/machinery/suit_storage_unit/standard_unit
	SUIT_TYPE = /obj/item/clothing/suit/space/globose
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/globose
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/syndicate_unit
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/syndi
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/syndi
	MASK_TYPE = /obj/item/clothing/mask/gas/syndicate

/obj/machinery/suit_storage_unit/science
	SUIT_TYPE = /obj/item/clothing/suit/space/globose/science
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/globose/science
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/atom_init()
	. = ..()
	if(SUIT_TYPE)
		SUIT = new SUIT_TYPE(src)
	if(HELMET_TYPE)
		HELMET = new HELMET_TYPE(src)
	if(MASK_TYPE)
		MASK = new MASK_TYPE(src)
	update_icon()

/obj/machinery/suit_storage_unit/update_icon()
	var/hashelmet = 0
	var/hassuit = 0
	var/hashuman = 0
	if(HELMET)
		hashelmet = 1
	if(SUIT)
		hassuit = 1
	if(OCCUPANT)
		hashuman = 1
	icon_state = text("suitstorage[][][][][][][][][]",hashelmet,hassuit,hashuman,src.isopen,src.islocked,src.isUV,src.ispowered,src.isbroken,src.issuperUV)


/obj/machinery/suit_storage_unit/power_change()
	if( powered() )
		src.ispowered = 1
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			src.ispowered = 0
			stat |= NOPOWER
			src.islocked = 0
			src.isopen = 1
			dump_everything()
			update_icon()
			update_power_use()
	update_power_use()


/obj/machinery/suit_storage_unit/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(50))
				dump_everything() //So suits dont survive all the time
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				dump_everything()
				qdel(src)
			return
		else
			return

/obj/machinery/suit_storage_unit/ui_interact(mob/user)
	var/dat = ""

	if(src.panelopen) //The maintenance panel is open. Time for some shady stuff
		dat+= "<B>Maintenance panel controls</B><HR>"
		dat+= "<span class='grey'>The panel is ridden with controls, button and meters, labeled in strange signs and symbols that <BR>you cannot understand. Probably the manufactoring world's language.<BR> Among other things, a few controls catch your eye.</span><BR><BR>"
		dat+= text("A small dial with a \"WARNING\" symbol embroidded on it. It's pointing towards a gauge that reads [].<BR><A class='blue' href='?src=\ref[];toggleUV=1'> Turn towards []</A><BR>",(src.issuperUV ? "15nm" : "185nm"),src,(src.issuperUV ? "185nm" : "15nm") )
		dat+= text("A thick old-style button, with 2 grimy LED lights next to it. The [] LED is on.<BR><A class='blue' href='?src=\ref[];togglesafeties=1'>Press button</a>",(src.safetieson? "<span class='green'><B>GREEN</B></span>" : "<span class='red'><B>RED</B></span>"),src)
	else if(src.isUV) //The thing is running its cauterisation cycle. You have to wait.
		dat+= "<span class='red'><B>Unit is cauterising contents with selected UV ray intensity. Please wait.</span></B><BR>"
	else
		if(!src.isbroken)
			dat+= "<span class='blue'><font size = 4><B>U-Stor-It Suit Storage Unit, model DS1900</B></font></span><BR>"
			dat+= "<B>Welcome to the Unit control panel.</B><HR>"
			dat+= text("Helmet storage compartment: <B>[]</B><BR>",(src.HELMET ? HELMET.name : "<span class='grey'>No helmet detected.</span>") )
			if(HELMET && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_helmet=1'>Dispense helmet</A><BR>",src)
			dat+= text("Suit storage compartment: <B>[]</B><BR>",(src.SUIT ? SUIT.name : "<span class='grey'>No exosuit detected.</span>") )
			if(SUIT && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_suit=1'>Dispense suit</A><BR>",src)
			dat+= text("Breathmask storage compartment: <B>[]</B><BR>",(src.MASK ? MASK.name : "<span class='grey'>No breathmask detected.</span>") )
			if(MASK && src.isopen)
				dat+=text("<A href='?src=\ref[];dispense_mask=1'>Dispense mask</A><BR>",src)
			if(src.OCCUPANT)
				dat+= "<HR><B><span class='red'>WARNING: Biological entity detected inside the Unit's storage. Please remove.</B></span><BR>"
				dat+= "<A href='?src=\ref[src];eject_guy=1'>Eject extra load</A>"
			dat+= text("<HR>Unit is: [] - <A href='?src=\ref[];toggle_open=1'>[] Unit</A> ",(src.isopen ? "Open" : "Closed"),src,(src.isopen ? "Close" : "Open"))
			if(src.isopen)
				dat+="<HR>"
			else
				dat+= text(" - <A class='orange' href='?src=\ref[];toggle_lock=1'>*[] Unit*</A><HR>",src,(src.islocked ? "Unlock" : "Lock") )
			dat+= text("Unit status: []",(src.islocked? "<span class='red'><B>**LOCKED**</B></span><BR>" : "<span class='green'><B>**UNLOCKED**</B></span><BR>") )
			dat+= text("<A href='?src=\ref[];start_UV=1'>Start Disinfection cycle</A><BR>",src)
		else //Ohhhh shit it's dirty or broken! Let's inform the guy.
			dat+= "<span class='red'><B>Unit chamber is too contaminated to continue usage. Please call for a qualified individual to perform maintenance.</span></B><BR><BR>"

	var/datum/browser/popup = new(user, "window=suit_storage_unit", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/suit_storage_unit/Topic(href, href_list) //I fucking HATE this proc
	. = ..()
	if(!.)
		return

	if (href_list["toggleUV"])
		toggleUV(usr)
	else if (href_list["togglesafeties"])
		togglesafeties(usr)
	else if (href_list["dispense_helmet"])
		dispense_helmet(usr)
	else if (href_list["dispense_suit"])
		dispense_suit(usr)
	else if (href_list["dispense_mask"])
		dispense_mask(usr)
	else if (href_list["toggle_open"])
		toggle_open(usr)
	else if (href_list["toggle_lock"])
		toggle_lock(usr)
	else if (href_list["start_UV"])
		start_UV(usr)
	else if (href_list["eject_guy"])
		eject_occupant(usr)

	updateUsrDialog()
	update_icon()


/obj/machinery/suit_storage_unit/proc/toggleUV(mob/user)
//	var/protected = 0
//	var/mob/living/carbon/human/H = user
	if(!src.panelopen)
		return

	/*if(istype(H)) //Let's check if the guy's wearing electrically insulated gloves
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(istype(G,/obj/item/clothing/gloves/yellow))
				protected = 1

	if(!protected)
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		to_chat(user, "<font color='red'>You try to touch the controls but you get zapped. There must be a short circuit somewhere.</font>")
		return*/
	else  //welp, the guy is protected, we can continue
		if(src.issuperUV)
			to_chat(user, "You slide the dial back towards \"185nm\".")
			src.issuperUV = 0
		else
			to_chat(user, "You crank the dial all the way up to \"15nm\".")
			src.issuperUV = 1
		return


/obj/machinery/suit_storage_unit/proc/togglesafeties(mob/user)
//	var/protected = 0
//	var/mob/living/carbon/human/H = user
	if(!src.panelopen) //Needed check due to bugs
		return

	/*if(istype(H)) //Let's check if the guy's wearing electrically insulated gloves
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(istype(G,/obj/item/clothing/gloves/yellow) )
				protected = 1

	if(!protected)
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		to_chat(user, "<font color='red'>You try to touch the controls but you get zapped. There must be a short circuit somewhere.</font>")
		return*/
	else
		to_chat(user, "You push the button. The coloured LED next to it changes.")
		src.safetieson = !src.safetieson


/obj/machinery/suit_storage_unit/proc/dispense_helmet(mob/user)
	if(!src.HELMET)
		return //Do I even need this sanity check? Nyoro~n
	else
		src.HELMET.loc = src.loc
		src.HELMET = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_suit(mob/user)
	if(!src.SUIT)
		return
	else
		src.SUIT.loc = src.loc
		src.SUIT = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_mask(mob/user)
	if(!src.MASK)
		return
	else
		src.MASK.loc = src.loc
		src.MASK = null
		return


/obj/machinery/suit_storage_unit/proc/dump_everything()
	src.islocked = 0 //locks go free
	if(src.SUIT)
		src.SUIT.loc = src.loc
		src.SUIT = null
	if(src.HELMET)
		src.HELMET.loc = src.loc
		src.HELMET = null
	if(src.MASK)
		src.MASK.loc = src.loc
		src.MASK = null
	if(src.OCCUPANT)
		eject_occupant(OCCUPANT)
	return


/obj/machinery/suit_storage_unit/proc/toggle_open(mob/user)
	if(src.islocked || src.isUV)
		to_chat(user, "<font color='red'>Unable to open unit.</font>")
		return
	if(src.OCCUPANT)
		eject_occupant(user)
		return  // eject_occupant opens the door, so we need to return
	src.isopen = !src.isopen
	return


/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user)
	if(src.OCCUPANT && src.safetieson)
		to_chat(user, "<font color='red'>The Unit's safety protocols disallow locking when a biological form is detected inside its compartments.</font>")
		return
	if(src.isopen)
		return
	src.islocked = !src.islocked
	return


/obj/machinery/suit_storage_unit/proc/start_UV(mob/user)
	if(src.isUV || src.isopen) //I'm bored of all these sanity checks
		return
	if(src.OCCUPANT && src.safetieson)
		to_chat(user, "<font color='red'><B>WARNING:</B> Biological entity detected in the confines of the Unit's storage. Cannot initiate cycle.</font>")
		return
	if(!src.HELMET && !src.MASK && !src.SUIT && !src.OCCUPANT ) //shit's empty yo
		to_chat(user, "<font color='red'>Unit storage bays empty. Nothing to disinfect -- Aborting.</font>")
		return
	to_chat(user, "You start the Unit's cauterisation cycle.")
	src.cycletime_left = 20
	src.isUV = 1
	if(src.OCCUPANT && !src.islocked)
		src.islocked = 1 //Let's lock it for good measure
	update_icon()
	updateUsrDialog()

	var/i //our counter
	for(i=0,i<4,i++)
		sleep(50)
		if(src.OCCUPANT)
			if(src.issuperUV)
				var/burndamage = rand(28,35)
				OCCUPANT.take_bodypart_damage(0, burndamage)
				OCCUPANT.emote("scream")
			else
				var/burndamage = rand(6,10)
				OCCUPANT.take_bodypart_damage(0, burndamage)
				OCCUPANT.emote("scream")
		if(i==3) //End of the cycle
			if(!src.issuperUV)
				if(src.HELMET)
					HELMET.clean_blood()
				if(src.SUIT)
					SUIT.clean_blood()
				if(src.MASK)
					MASK.clean_blood()
			else //It was supercycling, destroy everything
				if(src.HELMET)
					src.HELMET = null
				if(src.SUIT)
					src.SUIT = null
				if(src.MASK)
					src.MASK = null
				visible_message("<font color='red'>With a loud whining noise, the Suit Storage Unit's door grinds open. Puffs of ashen smoke come out of its chamber.</font>", 3)
				src.isbroken = 1
				src.isopen = 1
				src.islocked = 0
				eject_occupant(OCCUPANT) //Mixing up these two lines causes bug. DO NOT DO IT.
			src.isUV = 0 //Cycle ends
	update_icon()
	updateUsrDialog()
	return

/*	spawn(200) //Let's clean dat shit after 20 secs  //Eh, this doesn't work
		if(src.HELMET)
			HELMET.clean_blood()
		if(src.SUIT)
			SUIT.clean_blood()
		if(src.MASK)
			MASK.clean_blood()
		src.isUV = 0 //Cycle ends
		update_icon()
		updateUsrDialog()

	var/i
	for(i=0,i<4,i++) //Gradually give the guy inside some damaged based on the intensity
		spawn(50)
			if(src.OCCUPANT)
				if(src.issuperUV)
					OCCUPANT.take_bodypart_damage(0, 40)
					to_chat(user, "Test. You gave him 40 damage")
				else
					OCCUPANT.take_bodypart_damage(0, 8)
					to_chat(user, "Test. You gave him 8 damage")
	return*/


/obj/machinery/suit_storage_unit/proc/cycletimeleft()
	if(src.cycletime_left >= 1)
		src.cycletime_left--
	return src.cycletime_left


/obj/machinery/suit_storage_unit/proc/eject_occupant(mob/user)
	if (src.islocked)
		return

	if (!src.OCCUPANT)
		return
//	for(var/obj/O in src)
//		O.loc = src.loc

	if (src.OCCUPANT.client)
		if(user != OCCUPANT)
			to_chat(OCCUPANT, "<font color='blue'>The machine kicks you out!</font>")
		if(user.loc != src.loc)
			to_chat(OCCUPANT, "<font color='blue'>You leave the not-so-cozy confines of the SSU.</font>")

		src.OCCUPANT.client.eye = src.OCCUPANT.client.mob
		src.OCCUPANT.client.perspective = MOB_PERSPECTIVE
	src.OCCUPANT.loc = src.loc
	src.OCCUPANT = null
	if(!src.isopen)
		src.isopen = 1
	update_icon()
	return


/obj/machinery/suit_storage_unit/container_resist()
	var/mob/living/user = usr
	if(islocked)
		if(user.is_busy()) return
		user.next_move = world.time + 100
		user.last_special = world.time + 100
		var/breakout_time = 2
		to_chat(user, "<span class='notice'>You start kicking against the doors to escape! (This will take about [breakout_time] minutes.)</span>")
		visible_message("You see [user] kicking against the doors of the [src]!")
		if(do_after(user,(breakout_time*60*10),target=src))
			if(!user || user.incapacitated() || user.loc != src || isopen || !islocked)
				return
			else
				isopen = 1
				islocked = 0
				visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
		else
			return
	eject_occupant(user)
	add_fingerprint(user)
	updateUsrDialog()
	update_icon()
	return


/obj/machinery/suit_storage_unit/verb/move_inside()
	set name = "Hide in Suit Storage Unit"
	set category = "Object"
	set src in oview(1)

	if (usr.incapacitated())
		return
	if (!src.isopen)
		to_chat(usr, "<font color='red'>The unit's doors are shut.</font>")
		return
	if (!src.ispowered || src.isbroken)
		to_chat(usr, "<font color='red'>The unit is not operational.</font>")
		return
	if ( (src.OCCUPANT) || (src.HELMET) || (src.SUIT) )
		to_chat(usr, "<font color='red'>It's too cluttered inside for you to fit in!</font>")
		return
	if(usr.is_busy()) return
	visible_message("[usr] starts squeezing into the suit storage unit!", 3)
	if(do_after(usr, 10, target = src))
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
//		usr.metabslow = 1
		src.OCCUPANT = usr
		src.isopen = 0 //Close the thing after the guy gets inside
		update_icon()

//		for(var/obj/O in src)
//			qdel(O)

		add_fingerprint(usr)
		updateUsrDialog()
		return
	else
		src.OCCUPANT = null //Testing this as a backup sanity test
	return


/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user)
	if(!src.ispowered)
		return
	if(isscrewdriver(I))
		src.panelopen = !src.panelopen
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, text("<font color='blue'>You [] the unit's maintenance panel.</font>",(src.panelopen ? "open up" : "close") ))
		updateUsrDialog()
		return
	if ( istype(I, /obj/item/weapon/grab) )
		var/obj/item/weapon/grab/G = I
		if( !(ismob(G.affecting)) )
			return
		user.SetNextMove(CLICK_CD_MELEE)
		if (!src.isopen)
			to_chat(usr, "<font color='red'>The unit's doors are shut.</font>")
			return
		if (!src.ispowered || src.isbroken)
			to_chat(usr, "<font color='red'>The unit is not operational.</font>")
			return
		if ( (src.OCCUPANT) || (src.HELMET) || (src.SUIT) ) //Unit needs to be absolutely empty
			to_chat(user, "<font color='red'>The unit's storage area is too cluttered.</font>")
			return
		if(user.is_busy()) return
		visible_message("[user] starts putting [G.affecting.name] into the Suit Storage Unit.", 3)
		if(I.use_tool(src, user, 20, volume = 50))
			if(!G || !G.affecting) return //derpcheck
			var/mob/M = G.affecting
			if (M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
			src.OCCUPANT = M
			src.isopen = 0 //close ittt

			//for(var/obj/O in src)
			//	O.loc = src.loc
			add_fingerprint(user)
			qdel(G)
			updateUsrDialog()
			update_icon()
			return
		return
	if( istype(I,/obj/item/clothing/suit/space) )
		if(!src.isopen)
			return
		var/obj/item/clothing/suit/space/S = I
		if(src.SUIT)
			to_chat(user, "<font color='blue'>The unit already contains a suit.</font>")
			return
		to_chat(user, "You load the [S.name] into the storage compartment.")
		user.drop_from_inventory(S, src)
		src.SUIT = S
		update_icon()
		updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/head/helmet) )
		if(!src.isopen)
			return
		var/obj/item/clothing/head/helmet/H = I
		if(src.HELMET)
			to_chat(user, "<font color='blue'>The unit already contains a helmet.</font>")
			return
		to_chat(user, "You load the [H.name] into the storage compartment.")
		user.drop_from_inventory(H, src)
		src.HELMET = H
		update_icon()
		updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/mask) )
		if(!src.isopen)
			return
		var/obj/item/clothing/mask/M = I
		if(src.MASK)
			to_chat(user, "<font color='blue'>The unit already contains a mask.</font>")
			return
		to_chat(user, "You load the [M.name] into the storage compartment.")
		user.drop_from_inventory(M, src)
		src.MASK = M
		update_icon()
		updateUsrDialog()
		return
	update_icon()
	updateUsrDialog()
	return


/obj/machinery/suit_storage_unit/attack_paw(mob/user)
	to_chat(user, "<span class='info'>The console controls are far too complicated for your tiny brain!</span>")
	return
