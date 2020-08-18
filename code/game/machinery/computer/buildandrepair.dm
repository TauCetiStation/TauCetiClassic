//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/structure/computerframe
	density = 1
	anchored = 0
	name = "Computer-frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/circuitboard/circuit = null
//	weight = 1.0E8

/obj/item/weapon/circuitboard
	density = 0
	anchored = 0
	w_class = ITEM_SIZE_SMALL
	name = "Circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	origin_tech = "programming=2"
	var/id = null
	var/frequency = null
	var/build_path = null
	var/board_type = "computer"
	var/list/req_components = null
	var/powernet = null
	var/list/records = null
	var/frame_desc = null
	var/contain_parts = 1

/obj/item/weapon/circuitboard/turbine_computer
	name = "circuit board (Turbine Computer)"
	build_path = /obj/machinery/computer/turbine_computer
	origin_tech = "programming=4;engineering=4;power=4"
/obj/item/weapon/circuitboard/telesci_console
	name = "circuit board (Telescience Console)"
	build_path = /obj/machinery/computer/telescience
	origin_tech = "programming=3;bluespace=2"
/obj/item/weapon/circuitboard/message_monitor
	name = "Circuit board (Message Monitor)"
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/camera_advanced
	name = "circuit board (Advanced Camera Console)"
	build_path = /obj/machinery/computer/camera_advanced
	req_access = list(access_security)
/obj/item/weapon/circuitboard/camera_advanced/xenobio
	name = "circuit board (Slime management console)"
	build_path = /obj/machinery/computer/camera_advanced/xenobio
	origin_tech = "biotech=3;bluespace=3"
/obj/item/weapon/circuitboard/security
	name = "Circuit board (Security)"
	build_path = /obj/machinery/computer/security
	var/network = list("SS13")
	req_access = list(access_security)
	var/locked = 1
	var/emagged = 0
/obj/item/weapon/circuitboard/aicore
	name = "Circuit board (AI core)"
	origin_tech = "programming=4;biotech=2"
	board_type = "other"
/obj/item/weapon/circuitboard/aiupload
	name = "Circuit board (AI Upload)"
	build_path = /obj/machinery/computer/aiupload
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/borgupload
	name = "Circuit board (Cyborg Upload)"
	build_path = /obj/machinery/computer/borgupload
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/med_data
	name = "Circuit board (Medical Records)"
	build_path = /obj/machinery/computer/med_data
/obj/item/weapon/circuitboard/pandemic
	name = "Circuit board (PanD.E.M.I.C. 2200)"
	build_path = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/scan_consolenew
	name = "Circuit board (DNA Machine)"
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/communications
	name = "Circuit board (Communications)"
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=2;magnets=2"
	var/cooldown = 0

/obj/item/weapon/circuitboard/communications/atom_init()
	. = ..()
	circuitboard_communications_list += src
	START_PROCESSING(SSobj, src)

/obj/item/weapon/circuitboard/communications/Destroy()
	circuitboard_communications_list -= src

	for(var/obj/machinery/computer/communications/commconsole in communications_list)
		if(istype(commconsole.loc,/turf))
			return ..()

	for(var/obj/item/weapon/circuitboard/communications/commboard in circuitboard_communications_list)
		if((istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage)))
			return ..()

	for(var/mob/living/silicon/ai/shuttlecaller in ai_list)
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			return ..()

	if(SSticker.mode.name == "revolution" || SSticker.mode.name == "AI malfunction" || sent_strike_team)
		return ..()

	SSshuttle.incall(2)
	log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
	message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
	captain_announce("The emergency shuttle has been called. It will arrive in [shuttleminutes2text()] minutes.", sound = "emer_shut_called")

	return ..()

/obj/item/weapon/circuitboard/communications/process()
	cooldown = max(cooldown - 1, 0)

/obj/item/weapon/circuitboard/card
	name = "Circuit board (ID Computer)"
	build_path = /obj/machinery/computer/card
/obj/item/weapon/circuitboard/card/centcom
	name = "Circuit board (CentCom ID Computer)"
	build_path = /obj/machinery/computer/card/centcom
//obj/item/weapon/circuitboard/shield
//	name = "Circuit board (Shield Control)"
//	build_path = /obj/machinery/computer/stationshield
/obj/item/weapon/circuitboard/teleporter
	name = "Circuit board (Teleporter)"
	build_path = /obj/machinery/computer/teleporter
	origin_tech = "programming=2;bluespace=2"
/obj/item/weapon/circuitboard/secure_data
	name = "Circuit board (Security Records)"
	build_path = /obj/machinery/computer/secure_data
/obj/item/weapon/circuitboard/skills
	name = "Circuit board (Employment Records)"
	build_path = /obj/machinery/computer/skills
/obj/item/weapon/circuitboard/stationalert
	name = "Circuit board (Station Alerts)"
	build_path = /obj/machinery/computer/station_alert
/obj/item/weapon/circuitboard/air_management
	name = "Circuit board (Atmospheric monitor)"
	build_path = /obj/machinery/computer/general_air_control
/obj/item/weapon/circuitboard/injector_control
	name = "Circuit board (Injector control)"
	build_path = /obj/machinery/computer/general_air_control/fuel_injection
/obj/item/weapon/circuitboard/atmos_alert
	name = "Circuit board (Atmospheric Alert)"
	build_path = /obj/machinery/computer/atmos_alert
/obj/item/weapon/circuitboard/pod
	name = "Circuit board (Massdriver control)"
	build_path = /obj/machinery/computer/pod
/obj/item/weapon/circuitboard/robotics
	name = "Circuit board (Robotics Control)"
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/drone_control
	name = "Circuit board (Drone Control)"
	build_path = /obj/machinery/computer/drone_control
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/cloning
	name = "Circuit board (Cloning)"
	build_path = /obj/machinery/computer/cloning
	origin_tech = "programming=3;biotech=3"
/obj/item/weapon/circuitboard/arcade
	name = "Circuit board (Arcade)"
	build_path = /obj/machinery/computer/arcade
	origin_tech = "programming=1"
/obj/item/weapon/circuitboard/turbine_control
	name = "Circuit board (Turbine control)"
	build_path = /obj/machinery/computer/turbine_computer
/obj/item/weapon/circuitboard/solar_control
	name = "Circuit board (Solar Control)"  //name fixed 250810
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"
/obj/item/weapon/circuitboard/powermonitor
	name = "Circuit board (Power Monitor)"  //name fixed 250810
	build_path = /obj/machinery/computer/monitor
/obj/item/weapon/circuitboard/olddoor
	name = "Circuit board (DoorMex)"
	build_path = /obj/machinery/computer/pod/old
/obj/item/weapon/circuitboard/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	build_path = /obj/machinery/computer/pod/old/syndicate
/obj/item/weapon/circuitboard/swfdoor
	name = "Circuit board (Magix)"
	build_path = /obj/machinery/computer/pod/old/swf
/obj/item/weapon/circuitboard/prisoner
	name = "Circuit board (Prisoner Management)"
	build_path = /obj/machinery/computer/prisoner
/obj/item/weapon/circuitboard/rdconsole
	name = "Circuit Board (RD Console)"
	build_path = /obj/machinery/computer/rdconsole/core
/obj/item/weapon/circuitboard/mecha_control
	name = "Circuit Board (Exosuit Control Console)"
	build_path = /obj/machinery/computer/mecha
/obj/item/weapon/circuitboard/rdservercontrol
	name = "Circuit Board (R&D Server Control)"
	build_path = /obj/machinery/computer/rdservercontrol
/obj/item/weapon/circuitboard/crew
	name = "Circuit board (Crew monitoring computer)"
	build_path = /obj/machinery/computer/crew
	origin_tech = "programming=3;biotech=2;magnets=2"
/obj/item/weapon/circuitboard/mech_bay_power_console
	name = "Circuit board (Mech Bay Power Control Console)"
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=2;powerstorage=3"
/obj/item/weapon/circuitboard/computer/cargo/request
	name = "Circuit board (Supply ordering console)"
	build_path = /obj/machinery/computer/cargo/request
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/computer/cargo
	name = "Circuit board (Supply shuttle console)"
	build_path = /obj/machinery/computer/cargo
	origin_tech = "programming=3"
	var/contraband_enabled = FALSE
	var/hacked = FALSE
/obj/item/weapon/circuitboard/computer/stockexchange
	name = "Circuit board (Stock exchange computer)"
	build_path = /obj/machinery/computer/stockexchange
	origin_tech = "programming=3"
/*/obj/item/weapon/circuitboard/research_shuttle
	name = "Circuit board (Research Shuttle)"
	build_path = /obj/machinery/computer/research_shuttle
	origin_tech = "programming=2"*/
/obj/item/weapon/circuitboard/operating
	name = "Circuit board (Operating Computer)"
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/comm_monitor
	name = "Circuit board (Telecommunications Monitor)"
	build_path = /obj/machinery/computer/telecomms/monitor
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/comm_server
	name = "Circuit board (Telecommunications Server Monitor)"
	build_path = /obj/machinery/computer/telecomms/server
	origin_tech = "programming=3"

/obj/item/weapon/circuitboard/curefab
	name = "Circuit board (Cure fab)"
	build_path = /obj/machinery/computer/curer
/obj/item/weapon/circuitboard/splicer
	name = "Circuit board (Disease Splicer)"
	build_path = /obj/machinery/computer/diseasesplicer

/*/obj/item/weapon/circuitboard/mining_shuttle
	name = "Circuit board (Mining Shuttle)"
	build_path = /obj/machinery/computer/mining_shuttle
	origin_tech = "programming=2"*/

/obj/item/weapon/circuitboard/mine_sci_shuttle
	name = "Circuit board (Mining Shuttle)"
	build_path = /obj/machinery/computer/mine_sci_shuttle
	origin_tech = "programming=2"

/obj/item/weapon/circuitboard/mine_sci_shuttle/flight_comp
	name = "Circuit board (Mining Shuttle flight computer)"
	build_path = /obj/machinery/computer/mine_sci_shuttle/flight_comp
	origin_tech = "programming=2"

/obj/item/weapon/circuitboard/HolodeckControl // Not going to let people get this, but it's just here for future
	name = "Circuit board (Holodeck Control)"
	build_path = /obj/machinery/computer/HolodeckControl
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/aifixer
	name = "Circuit board (AI Integrity Restorer)"
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=3;biotech=2"
/obj/item/weapon/circuitboard/area_atmos
	name = "Circuit board (Area Air Control)"
	build_path = /obj/machinery/computer/area_atmos
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/libraryconsole
	name = "circuit board (Library Visitor Console)"
	build_path = /obj/machinery/computer/libraryconsole
	origin_tech = "programming=1"


/obj/item/weapon/circuitboard/computer/cargo/attackby(obj/item/I, mob/user, params)
	if(ismultitool(I))
		var/catastasis = src.contraband_enabled
		var/opposite_catastasis
		if(catastasis)
			opposite_catastasis = "STANDARD"
			catastasis = "BROAD"
		else
			opposite_catastasis = "BROAD"
			catastasis = "STANDARD"

		switch( alert("Current receiver spectrum is set to: [catastasis]","Multitool-Circuitboard interface","Switch to [opposite_catastasis]","Cancel") )
		//switch( alert("Current receiver spectrum is set to: " {(src.contraband_enabled) ? ("BROAD") : ("STANDARD")} , "Multitool-Circuitboard interface" , "Switch to " {(src.contraband_enabled) ? ("STANDARD") : ("BROAD")}, "Cancel") )
			if("Switch to STANDARD","Switch to BROAD")
				src.contraband_enabled = !src.contraband_enabled

			if("Cancel")
				return

	else
		return ..()

/obj/item/weapon/circuitboard/computer/cargo/emag_act(mob/user)
	if(hacked)
		return FALSE
	to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
	hacked = TRUE
	contraband_enabled = TRUE
	return TRUE

/obj/item/weapon/circuitboard/libraryconsole/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		if(build_path == /obj/machinery/computer/libraryconsole/bookmanagement)
			name = "circuit board (Library Visitor Console)"
			build_path = /obj/machinery/computer/libraryconsole
			to_chat(user, "<span class='notice'>Defaulting access protocols.</span>")
		else
			name = "circuit board (Book Inventory Management Console)"
			build_path = /obj/machinery/computer/libraryconsole/bookmanagement
			to_chat(user, "<span class='notice'>Access protocols successfully updated.</span>")
	else
		return ..()

/obj/item/weapon/circuitboard/security/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/card/id))
		if(emagged)
			to_chat(user, "<span class='warning'>Circuit lock does not respond.</span>")
			return
		if(check_access(I))
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "" : "un"]lock the circuit controls.</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
	else if(ismultitool(I))
		if(locked)
			to_chat(user, "<span class='warning'>Circuit controls are locked.</span>")
			return
		var/existing_networks = jointext(network,",")
		var/input = sanitize_safe(input(usr, "Which networks would you like to connect this camera console circuit to? Seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Multitool-Circuitboard interface", input_default(existing_networks)), MAX_LNAME_LEN)
		if(!input)
			to_chat(usr, "No input found please hang up and try your call again.")
			return
		var/list/tempnetwork = splittext(input, ",")
		tempnetwork = difflist(tempnetwork,RESTRICTED_CAMERA_NETWORKS,1)
		if(tempnetwork.len < 1)
			to_chat(usr, "No network found please hang up and try your call again.")
			return
		network = tempnetwork
	else
		return ..()

/obj/item/weapon/circuitboard/security/emag_act(mob/user)
	if(emagged)
		to_chat(user, "Circuit lock is already removed.")
		return FALSE
	to_chat(user, "<span class='notice'>You override the circuit lock and open controls.</span>")
	emagged = 1
	locked = 0
	return TRUE

/obj/item/weapon/circuitboard/rdconsole/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		user.visible_message("<span class='notice'>\the [user] adjusts the jumper on the [src]'s access protocol pins.</span>", "<span class='notice'>You adjust the jumper on the access protocol pins.</span>")
		switch(src.build_path)

			if(/obj/machinery/computer/rdconsole/core)
				src.name = "Circuit Board (RD Console - Robotics)"
				src.build_path = /obj/machinery/computer/rdconsole/robotics
				to_chat(user, "<span class='notice'>Access protocols set to robotics.</span>")

			if(/obj/machinery/computer/rdconsole/robotics)
				src.name = "Circuit Board (RD Console - Mining)"
				src.build_path = /obj/machinery/computer/rdconsole/mining
				to_chat(user, "<span class='notice'>Access protocols set to mining.</span>")

			if(/obj/machinery/computer/rdconsole/mining)
				src.name = "Circuit Board (RD Console)"
				src.build_path = /obj/machinery/computer/rdconsole/core
				to_chat(user, "<span class='notice'>Access protocols set to default.</span>")

		/*if(src.build_path == /obj/machinery/computer/rdconsole/core)
			src.name = "Circuit Board (RD Console - Robotics)"
			src.build_path = /obj/machinery/computer/rdconsole/robotics
			to_chat(user, "<span class='notice'>Access protocols set to robotics.</span>")
		else
			src.name = "Circuit Board (RD Console)"
			src.build_path = /obj/machinery/computer/rdconsole/core
			to_chat(user, "<span class='notice'>Access protocols set to default.</span>")*/
	else
		return ..()

/obj/structure/computerframe/attackby(obj/item/P, mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>It's too complicated for you.</span>")
		return

	if((state != 0) && (state != 1) && iswrench(P))
		if(user.is_busy(src))
			return

		var/list/possible_directions = list()
		for(var/direction_to_check in (cardinal - NORTH - dir))
			possible_directions += dir2text(direction_to_check)

		var/dir_choise = input(user, "Choose the direction where to turn \the [src].", "Choose the direction.", null) as null|anything in possible_directions

		if(!dir_choise || !user || !(user in range(1, src)) || user.is_busy(src))
			return

		if(P.use_tool(src, user, 20, volume = 50) && src && P)
			user.visible_message("<span class='notice'>[user] turns \the [src] [dir_choise].</span>", "<span class='notice'>You turn \the [src] [dir_choise].</span>")
			dir = text2dir(dir_choise)

		return

	switch(state)
		if(0)
			if(iswrench(P))
				if(user.is_busy(src))
					return
				if(P.use_tool(src, user, 20, volume = 50))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					src.anchored = 1
					src.state = 1
			if(iswelder(P))
				var/obj/item/weapon/weldingtool/WT = P
				if(WT.use(0, user))
					to_chat(user, "<span class='notice'>You start deconstruct the frame.</span>")
					if(WT.use_tool(src, user, 20, volume = 50))
						to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
						new /obj/item/stack/sheet/metal( src.loc, 5 )
						qdel(src)
		if(1)
			if(iswrench(P))
				if(user.is_busy(src))
					return
				if(P.use_tool(src, user, 20, volume = 50))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					src.anchored = 0
					src.state = 0
			if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "computer")
					playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
					icon_state = "1"
					circuit = P
					user.drop_item()
					circuit.add_fingerprint(user)
					P.loc = null
				else
					to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
			if(isscrewdriver(P) && circuit)
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				src.state = 2
				src.icon_state = "2"
			if(iscrowbar(P) && circuit)
				playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				src.state = 1
				src.icon_state = "0"
				circuit.loc = src.loc
				src.circuit = null
		if(2)
			if(isscrewdriver(P) && circuit)
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				src.state = 1
				src.icon_state = "1"
			if(iscoil(P))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					if(user.is_busy(src))
						return
					playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					if(C.use_tool(src, user, 20, amount = 5, volume = 50))
						to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
						src.state = 3
						src.icon_state = "3"
		if(3)
			if(iswirecutter(P))
				playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				src.state = 2
				src.icon_state = "2"
				new /obj/item/stack/cable_coil/random(loc, 5)

			if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if(G.get_amount() >= 2)
					if(user.is_busy(src)) return
					if(G.use_tool(src, user, 20, amount = 2, volume = 50))
						to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
						src.state = 4
						src.icon_state = "4"
		if(4)
			if(iscrowbar(P))
				playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass( src.loc, 2 )
			if(isscrewdriver(P))
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/obj/machinery/computer/new_computer = new src.circuit.build_path (src.loc, circuit)
				new_computer.dir = dir
				transfer_fingerprints_to(new_computer)
				qdel(src)

/obj/structure/computerframe/verb/rotate()
	set category = "Object"
	set name = "Rotate"
	set src in oview(1)

	// virtual present
	if (isAI(usr) || ispAI(usr))
		return
	// state restrict
	if(!in_range(src, usr) || usr.incapacitated() || usr.lying || usr.is_busy(src))
		return
	// species restrict
	if(!usr.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>It's too complicated for you.</span>")
		return

	var/obj/item/I = usr.get_active_hand()

	if (!I || !iswrench(I))
		to_chat(usr, "<span class='warning'>You need to hold a wrench in your active hand to do this.</span>")
		return

	var/list/possible_directions = list()
	for(var/direction_to_check in (cardinal - NORTH - dir))
		possible_directions += dir2text(direction_to_check)

	var/dir_choise = input(usr, "Choose the direction where to turn \the [src].", "Choose the direction.", null) as null|anything in possible_directions

	if(!dir_choise || !usr || !(usr in range(1, src)) || usr.is_busy(src))
		return

	if(I.use_tool(src, usr, 20, volume = 50) && src && I)
		usr.visible_message("<span class='notice'>[usr] turns \the [src] [dir_choise].</span>", "<span class='notice'>You turn \the [src] [dir_choise].</span>")
		dir = text2dir(dir_choise)
