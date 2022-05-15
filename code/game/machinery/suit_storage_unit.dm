//////////////////////////////////////
// SUIT STORAGE UNIT /////////////////
//////////////////////////////////////


/obj/machinery/suit_storage_unit
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "suit_storage_map" //order is: [has helmet][has suit][has human][is open][is locked][is UV cycling][is powered][is dirty/broken] [is superUVcycling]
	anchored = TRUE
	density = TRUE
	var/mob/living/carbon/OCCUPANT = null
	var/obj/item/clothing/suit/space/SUIT = null
	var/SUIT_TYPE = null
	var/obj/item/clothing/head/helmet/space/HELMET = null
	var/HELMET_TYPE = null
	var/obj/item/clothing/mask/MASK = null  //All the stuff that's gonna be stored insiiiiiiiiiiiiiiiiiiide, nyoro~n
	var/MASK_TYPE = null //Erro's idea on standarising SSUs whle keeping creation of other SSU types easy: Make a child SSU, name it something then set the TYPE vars to your desired suit output. New() should take it from there by itself.
	var/isopen = FALSE
	var/locked = FALSE
	var/isUV = 0
	var/issuperUV = 0
	var/safetieson = TRUE
	var/ispowered = TRUE
	var/overlay_color
	var/panelopen = FALSE
	var/isbroken = FALSE
	var/cycletime_left = 0

//The units themselves/////////////////

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
	cut_overlays()

	if(overlay_color)
		var/image/I = image(icon, icon_state = "color_grayscale")
		I.color = overlay_color
		add_overlay(I)

	if(panelopen)
		add_overlay("panel")
	if(isopen)
		if(HELMET)
			add_overlay("helmet")
		if(SUIT)
			add_overlay("suit")

	icon_state = isopen ? "open" : "closed"

	if(!ispowered)
		add_overlay("nopower")
	else
		// Add lights overlays
		if(HELMET)
			add_overlay("light1")
		if(SUIT)
			add_overlay("light2")

		if(isUV || issuperUV)
			add_overlay("working")


/obj/machinery/suit_storage_unit/power_change()
	if( powered() )
		ispowered = 1
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			ispowered = 0
			stat |= NOPOWER
			locked = 0
			isopen = 1
			dump_everything()
			update_icon()
			update_power_use()
	update_power_use()


/obj/machinery/suit_storage_unit/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(prob(50))
				dump_everything() //So suits dont survive all the time
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				dump_everything()
				qdel(src)

/obj/machinery/suit_storage_unit/ui_interact(mob/user)
	var/dat = ""

	if(panelopen) //The maintenance panel is open. Time for some shady stuff
		dat+= "<B>Maintenance panel controls</B><HR>"
		dat+= "<span class='grey'>The panel is ridden with controls, button and meters, labeled in strange signs and symbols that <BR>you cannot understand. Probably the manufactoring world's language.<BR> Among other things, a few controls catch your eye.</span><BR><BR>"
		dat+= text("A small dial with a \"WARNING\" symbol embroidded on it. It's pointing towards a gauge that reads [].<BR><A class='blue' href='?src=\ref[];toggleUV=1'> Turn towards []</A><BR>",(issuperUV ? "15nm" : "185nm"),src,(issuperUV ? "185nm" : "15nm") )
		dat+= text("A thick old-style button, with 2 grimy LED lights next to it. The [] LED is on.<BR><A class='blue' href='?src=\ref[];togglesafeties=1'>Press button</a>",(safetieson? "<span class='green'><B>GREEN</B></span>" : "<span class='red'><B>RED</B></span>"),src)
	else if(isUV) //The thing is running its cauterisation cycle. You have to wait.
		dat+= "<span class='red'><B>Unit is cauterising contents with selected UV ray intensity. Please wait.</span></B><BR>"
	else
		if(!isbroken)
			dat+= "<span class='blue'><font size = 4><B>U-Stor-It Suit Storage Unit, model DS1900</B></font></span><BR>"
			dat+= "<B>Welcome to the Unit control panel.</B><HR>"
			dat+= text("Helmet storage compartment: <B>[]</B><BR>",(HELMET ? HELMET.name : "<span class='grey'>No helmet detected.</span>") )
			if(HELMET && isopen)
				dat+=text("<A href='?src=\ref[];dispense_helmet=1'>Dispense helmet</A><BR>",src)
			dat+= text("Suit storage compartment: <B>[]</B><BR>",(SUIT ? SUIT.name : "<span class='grey'>No exosuit detected.</span>") )
			if(SUIT && isopen)
				dat+=text("<A href='?src=\ref[];dispense_suit=1'>Dispense suit</A><BR>",src)
			dat+= text("Breathmask storage compartment: <B>[]</B><BR>",(MASK ? MASK.name : "<span class='grey'>No breathmask detected.</span>") )
			if(MASK && isopen)
				dat+=text("<A href='?src=\ref[];dispense_mask=1'>Dispense mask</A><BR>",src)
			if(OCCUPANT)
				dat+= "<HR><B><span class='red'>WARNING: Biological entity detected inside the Unit's storage. Please remove.</B></span><BR>"
				dat+= "<A href='?src=\ref[src];eject_guy=1'>Eject extra load</A>"
			dat+= text("<HR>Unit is: [] - <A href='?src=\ref[];toggle_open=1'>[] Unit</A> ",(isopen ? "Open" : "Closed"),src,(isopen ? "Close" : "Open"))
			if(isopen)
				dat+="<HR>"
			else
				dat+= text(" - <A class='orange' href='?src=\ref[];toggle_lock=1'>*[] Unit*</A><HR>",src,(locked ? "Unlock" : "Lock") )
			dat+= text("Unit status: []",(locked? "<span class='red'><B>**LOCKED**</B></span><BR>" : "<span class='green'><B>**UNLOCKED**</B></span><BR>") )
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
	if(!panelopen)
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
		if(issuperUV)
			to_chat(user, "You slide the dial back towards \"185nm\".")
			issuperUV = 0
		else
			to_chat(user, "You crank the dial all the way up to \"15nm\".")
			issuperUV = 1
		return


/obj/machinery/suit_storage_unit/proc/togglesafeties(mob/user)
//	var/protected = 0
//	var/mob/living/carbon/human/H = user
	if(!panelopen) //Needed check due to bugs
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
		safetieson = !safetieson


/obj/machinery/suit_storage_unit/proc/dispense_helmet(mob/user)
	if(!HELMET)
		return //Do I even need this sanity check? Nyoro~n
	else
		HELMET.loc = loc
		HELMET = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_suit(mob/user)
	if(!SUIT)
		return
	else
		SUIT.loc = loc
		SUIT = null
		return


/obj/machinery/suit_storage_unit/proc/dispense_mask(mob/user)
	if(!MASK)
		return
	else
		MASK.loc = loc
		MASK = null
		return


/obj/machinery/suit_storage_unit/proc/dump_everything()
	locked = 0 //locks go free
	if(SUIT)
		SUIT.loc = loc
		SUIT = null
	if(HELMET)
		HELMET.loc = loc
		HELMET = null
	if(MASK)
		MASK.loc = loc
		MASK = null
	if(OCCUPANT)
		eject_occupant(OCCUPANT)
	return


/obj/machinery/suit_storage_unit/proc/toggle_open(mob/user)
	if(locked || isUV)
		to_chat(user, "<font color='red'>Unable to open unit.</font>")
		return
	if(OCCUPANT)
		eject_occupant(user)
		return  // eject_occupant opens the door, so we need to return
	isopen = !isopen
	return


/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user)
	if(OCCUPANT && safetieson)
		to_chat(user, "<font color='red'>The Unit's safety protocols disallow locking when a biological form is detected inside its compartments.</font>")
		return
	if(isopen)
		return
	locked = !locked
	return


/obj/machinery/suit_storage_unit/proc/start_UV(mob/user)
	if(isUV || isopen) //I'm bored of all these sanity checks
		return
	if(OCCUPANT && safetieson)
		to_chat(user, "<font color='red'><B>WARNING:</B> Biological entity detected in the confines of the Unit's storage. Cannot initiate cycle.</font>")
		return
	if(!HELMET && !MASK && !SUIT && !OCCUPANT ) //shit's empty yo
		to_chat(user, "<font color='red'>Unit storage bays empty. Nothing to disinfect -- Aborting.</font>")
		return
	to_chat(user, "You start the Unit's cauterisation cycle.")
	cycletime_left = 20
	isUV = 1
	if(OCCUPANT && !locked)
		locked = 1 //Let's lock it for good measure
	update_icon()
	updateUsrDialog()

	var/i //our counter
	for(i=0,i<4,i++)
		sleep(50)
		if(OCCUPANT)
			if(issuperUV)
				var/burndamage = rand(28,35)
				OCCUPANT.take_bodypart_damage(0, burndamage)
				OCCUPANT.emote("scream")
			else
				var/burndamage = rand(6,10)
				OCCUPANT.take_bodypart_damage(0, burndamage)
				OCCUPANT.emote("scream")
		if(i==3) //End of the cycle
			if(!issuperUV)
				if(HELMET)
					HELMET.clean_blood()
				if(SUIT)
					SUIT.clean_blood()
				if(MASK)
					MASK.clean_blood()
			else //It was supercycling, destroy everything
				if(HELMET)
					HELMET = null
				if(SUIT)
					SUIT = null
				if(MASK)
					MASK = null
				visible_message("<font color='red'>With a loud whining noise, the Suit Storage Unit's door grinds open. Puffs of ashen smoke come out of its chamber.</font>", 3)
				isbroken = 1
				isopen = 1
				locked = 0
				eject_occupant(OCCUPANT) //Mixing up these two lines causes bug. DO NOT DO IT.
			isUV = 0 //Cycle ends
	update_icon()
	updateUsrDialog()
	return

/*	spawn(200) //Let's clean dat shit after 20 secs  //Eh, this doesn't work
		if(HELMET)
			HELMET.clean_blood()
		if(SUIT)
			SUIT.clean_blood()
		if(MASK)
			MASK.clean_blood()
		isUV = 0 //Cycle ends
		update_icon()
		updateUsrDialog()

	var/i
	for(i=0,i<4,i++) //Gradually give the guy inside some damaged based on the intensity
		spawn(50)
			if(OCCUPANT)
				if(issuperUV)
					OCCUPANT.take_bodypart_damage(0, 40)
					to_chat(user, "Test. You gave him 40 damage")
				else
					OCCUPANT.take_bodypart_damage(0, 8)
					to_chat(user, "Test. You gave him 8 damage")
	return*/


/obj/machinery/suit_storage_unit/proc/cycletimeleft()
	if(cycletime_left >= 1)
		cycletime_left--
	return cycletime_left


/obj/machinery/suit_storage_unit/proc/eject_occupant(mob/user)
	if (locked)
		return

	if (!OCCUPANT)
		return
//	for(var/obj/O in src)
//		O.loc = loc

	if (OCCUPANT.client)
		if(user != OCCUPANT)
			to_chat(OCCUPANT, "<font color='blue'>The machine kicks you out!</font>")
		if(user.loc != loc)
			to_chat(OCCUPANT, "<font color='blue'>You leave the not-so-cozy confines of the SSU.</font>")

		OCCUPANT.client.eye = OCCUPANT.client.mob
		OCCUPANT.client.perspective = MOB_PERSPECTIVE
	OCCUPANT.loc = loc
	OCCUPANT = null
	if(!isopen)
		isopen = 1
	update_icon()
	return


/obj/machinery/suit_storage_unit/container_resist()
	var/mob/living/user = usr
	if(locked)
		if(user.is_busy()) return
		user.next_move = world.time + 100
		user.last_special = world.time + 100
		var/breakout_time = 2
		to_chat(user, "<span class='notice'>You start kicking against the doors to escape! (This will take about [breakout_time] minutes.)</span>")
		visible_message("You see [user] kicking against the doors of the [src]!")
		if(do_after(user,(breakout_time*60*10),target=src))
			if(!user || user.incapacitated() || user.loc != src || isopen || !locked)
				return
			else
				isopen = 1
				locked = 0
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
	if (!isopen)
		to_chat(usr, "<font color='red'>The unit's doors are shut.</font>")
		return
	if (!ispowered || isbroken)
		to_chat(usr, "<font color='red'>The unit is not operational.</font>")
		return
	if ( (OCCUPANT) || (HELMET) || (SUIT) )
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
		OCCUPANT = usr
		isopen = 0 //Close the thing after the guy gets inside
		update_icon()

//		for(var/obj/O in src)
//			qdel(O)

		add_fingerprint(usr)
		updateUsrDialog()
		return
	else
		OCCUPANT = null //Testing this as a backup sanity test
	return


/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user)
	if(!ispowered)
		return
	if(isscrewdriver(I))
		panelopen = !panelopen
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, text("<font color='blue'>You [] the unit's maintenance panel.</font>",(panelopen ? "open up" : "close") ))
		updateUsrDialog()
		return
	if ( istype(I, /obj/item/weapon/grab) )
		var/obj/item/weapon/grab/G = I
		if( !(ismob(G.affecting)) )
			return
		user.SetNextMove(CLICK_CD_MELEE)
		if (!isopen)
			to_chat(usr, "<font color='red'>The unit's doors are shut.</font>")
			return
		if (!ispowered || isbroken)
			to_chat(usr, "<font color='red'>The unit is not operational.</font>")
			return
		if ( (OCCUPANT) || (HELMET) || (SUIT) ) //Unit needs to be absolutely empty
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
			OCCUPANT = M
			isopen = 0 //close ittt

			//for(var/obj/O in src)
			//	O.loc = loc
			add_fingerprint(user)
			qdel(G)
			updateUsrDialog()
			update_icon()
			return
		return
	if( istype(I,/obj/item/clothing/suit/space) )
		if(!isopen)
			return
		var/obj/item/clothing/suit/space/S = I
		if(SUIT)
			to_chat(user, "<font color='blue'>The unit already contains a suit.</font>")
			return
		to_chat(user, "You load the [S.name] into the storage compartment.")
		user.drop_from_inventory(S, src)
		SUIT = S
		update_icon()
		updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/head/helmet) )
		if(!isopen)
			return
		var/obj/item/clothing/head/helmet/H = I
		if(HELMET)
			to_chat(user, "<font color='blue'>The unit already contains a helmet.</font>")
			return
		to_chat(user, "You load the [H.name] into the storage compartment.")
		user.drop_from_inventory(H, src)
		HELMET = H
		update_icon()
		updateUsrDialog()
		return
	if( istype(I,/obj/item/clothing/mask) )
		if(!isopen)
			return
		var/obj/item/clothing/mask/M = I
		if(MASK)
			to_chat(user, "<font color='blue'>The unit already contains a mask.</font>")
			return
		to_chat(user, "You load the [M.name] into the storage compartment.")
		user.drop_from_inventory(M, src)
		MASK = M
		update_icon()
		updateUsrDialog()
		return
	update_icon()
	updateUsrDialog()
	return


/obj/machinery/suit_storage_unit/attack_paw(mob/user)
	to_chat(user, "<span class='info'>The console controls are far too complicated for your tiny brain!</span>")
	return

/obj/machinery/suit_storage_unit/standard_unit
	SUIT_TYPE = /obj/item/clothing/suit/space/globose
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/globose
	MASK_TYPE = /obj/item/clothing/mask/breath
	overlay_color = "#d3d3d3"

/obj/machinery/suit_storage_unit/syndicate_unit
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/syndi
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/syndi
	MASK_TYPE = /obj/item/clothing/mask/gas/syndicate
	overlay_color = "#d04044"

/obj/machinery/suit_storage_unit/science
	SUIT_TYPE = /obj/item/clothing/suit/space/globose/science
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/globose/science
	MASK_TYPE = /obj/item/clothing/mask/breath
	overlay_color = "#aa66be"

/obj/machinery/suit_storage_unit/science/rig
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/science
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/science

/obj/machinery/suit_storage_unit/science/rig/rd
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/science/rd
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/science/rd

/obj/machinery/suit_storage_unit/engineering
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/engineering
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/engineering
	MASK_TYPE = /obj/item/clothing/mask/gas/coloured

/obj/machinery/suit_storage_unit/engineering/ce
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/engineering/chief
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/engineering/chief
	overlay_color = "#ffffff"

/obj/machinery/suit_storage_unit/atmos
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/atmos
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/atmos
	MASK_TYPE = /obj/item/clothing/mask/breath
	overlay_color = "#4f9d91"

/obj/machinery/suit_storage_unit/medical
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/medical
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/medical
	MASK_TYPE = /obj/item/clothing/mask/breath
	overlay_color = "#d3d3d3"

/obj/machinery/suit_storage_unit/medical/cmo
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/medical/cmo
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/medical/cmo
	overlay_color = "#99ccff"

/obj/machinery/suit_storage_unit/security
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/security
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/security
	MASK_TYPE = /obj/item/clothing/mask/gas/sechailer
	overlay_color = "#d04044"

/obj/machinery/suit_storage_unit/security/hos
	SUIT_TYPE = /obj/item/clothing/suit/space/rig/security/hos
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/rig/security/hos
	overlay_color = "#1d1d23"

/obj/machinery/suit_storage_unit/mining
	SUIT_TYPE = /obj/item/clothing/suit/space/globose/mining
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/globose/mining
	MASK_TYPE = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/recycler
	SUIT_TYPE = /obj/item/clothing/suit/space/globose/recycler
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/globose/recycler
	MASK_TYPE = /obj/item/clothing/mask/breath
	overlay_color = "#f56300"

/obj/machinery/suit_storage_unit/skrell
	SUIT_TYPE = /obj/item/clothing/suit/space/skrell/white
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/skrell/white
	MASK_TYPE = /obj/item/clothing/mask/breath
	overlay_color = "#76c5b6"

/obj/machinery/suit_storage_unit/skrell/black
	SUIT_TYPE = /obj/item/clothing/suit/space/skrell/black
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/skrell/black

/obj/machinery/suit_storage_unit/unathi
	SUIT_TYPE = /obj/item/clothing/suit/space/unathi/rig_cheap
	HELMET_TYPE = /obj/item/clothing/head/helmet/space/unathi/helmet_cheap
	overlay_color = "#2e6232"
