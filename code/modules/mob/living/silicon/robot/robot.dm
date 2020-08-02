#define CYBORG_POWER_USAGE_MULTIPLIER 2.5 // Multiplier for amount of power cyborgs use.

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 200
	health = 200

	var/lights_on = 0 // Is our integrated light on?
	var/used_power_this_tick = 0
	var/sight_mode = 0
	var/custom_name = ""
	var/custom_sprite = 0 //Due to all the sprites involved, a var for our custom borgs may be best
	var/crisis //Admin-settable for combat module use.
	var/datum/wires/robot/wires = null

//Hud stuff

	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null

	var/shown_robot_modules = 0 //Used to determine whether they have the module menu shown or not
	var/shown_robot_pda = 0
	var/shown_robot_foto = 0
	var/obj/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/stock_parts/cell/cell = null
	var/obj/machinery/camera/camera = null

	// Components are basically robot organs.
	var/list/components = list()

	var/obj/item/device/mmi/mmi = null

	var/opened = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/locked = 1
	var/has_power = 1
	var/list/req_access = list(access_robotics)
	var/ident = 0
	//var/list/laws = list()
	var/viewalerts = 0
	var/modtype = "Default"
	var/lower_mod = 0
	var/jetpack = 0
	var/datum/effect/effect/system/ion_trail_follow/ion_trail = null
	var/datum/effect/effect/system/spark_spread/spark_system//So they can initialize sparks whenever/N
	var/jeton = 0
	var/killswitch = 0
	var/killswitch_time = 60
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/lawcheck[1] //For stating laws.
	var/ioncheck[1] //Ditto.
	var/lockcharge //Used when locking down a borg to preserve cell charge
	var/speed = 0 //Cause sec borgs gotta go fast //No they dont!
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/tracking_entities = 0 //The number of known entities currently accessing the internal camera
	var/braintype = "Cyborg"
	var/pose

/mob/living/silicon/robot/atom_init(mapload, name_prefix = "Default", laws_type = /datum/ai_laws/nanotrasen, ai_link = TRUE)
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	wires = new(src)

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	robot_modules_background.layer = HUD_LAYER	 //Objects that appear on screen are on layer 20, UI should be just below it.
	robot_modules_background.plane = HUD_PLANE
	ident = rand(1, 999)
	updatename(name_prefix)
	updateicon()

	init(laws_type, ai_link)

	radio = new /obj/item/device/radio/borg(src)
	if(!scrambledcodes && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.replace_networks(list("SS13","Robots"))
		if(wires.is_index_cut(BORG_WIRE_CAMERA))
			camera.status = 0

	initialize_components()
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = 1
		C.wrapped = new C.external_type

	if(!cell)
		cell = new /obj/item/weapon/stock_parts/cell(src)
		cell.maxcharge = 7500
		cell.charge = 7500

	. = ..()

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = 1

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")

/mob/living/silicon/robot/proc/init(laws_type, ai_link)
	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	laws = new laws_type()
	if(ai_link)
		connected_ai = select_active_ai_with_fewest_borgs()
		if(connected_ai)
			connected_ai.connected_robots += src
			lawsync()
			photosync()
			lawupdate = 1
	else
		lawupdate = 0

	playsound(src, 'sound/voice/liveagain.ogg', VOL_EFFECTS_MASTER)

// setup the PDA and its name
/mob/living/silicon/robot/proc/setup_PDA()
	if (!pda)
		pda = new/obj/item/device/pda/silicon/robot(src)
	pda.set_name_and_job(custom_name,"[modtype] [braintype]")

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	if(mmi)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)	mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		mmi = null
	return ..()

/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	var/list/modules = list("Standard", "Engineering", "Surgeon", "Crisis", "Miner", "Janitor", "Service", "Security", "Science")
	if(crisis && security_level == SEC_LEVEL_RED) //Leaving this in until it's balanced appropriately.
		to_chat(src, "<span class='warning'>Crisis mode active. Combat module available.</span>")
		modules+="Combat"
	modtype = input("Please, select a module!", "Robot", null, null) in modules

	var/module_sprites[0] //Used to store the associations between sprite names and sprite index.

	if(module)
		return

	switch(modtype)
		if("Standard")
			module = new /obj/item/weapon/robot_module/standard(src)
			module_sprites["Basic"] = "robot_old"
			module_sprites["Android"] = "droid"
			module_sprites["Default"] = "robot"
			module_sprites["Drone"] = "drone-standard"
			module_sprites["Acheron"] = "mechoid-Standard"
			module_sprites["Spider"] = "spider-standard"
			module_sprites["Kodiak"] = "kodiak-standard"

		if("Service")
			module = new /obj/item/weapon/robot_module/butler(src)
			module_sprites["Waitress"] = "Service"
			module_sprites["Kent"] = "toiletbot"
			module_sprites["Bro"] = "Brobot"
			module_sprites["Rich"] = "maximillion"
			module_sprites["Default"] = "Service2"
			module_sprites["Drone"] = "drone-service" // How does this even work...? Oh well.
			module_sprites["Acheron"] = "mechoid-Service"
			module_sprites["Kodiak"] = "kodiak-service"

		if("Science")
			module = new /obj/item/weapon/robot_module/science(src)
			module.channels = list("Science" = 1)
			if(camera && ("Robots" in camera.network))
				camera.add_network("Science")
			module_sprites["Toxin"] = "toxbot"
			module_sprites["Xenobio"] = "xenobot"
			module_sprites["Acheron"] = "mechoid-Science"

		if("Miner")
			module = new /obj/item/weapon/robot_module/miner(src)
			module.channels = list("Supply" = 1)
			if(camera && ("Robots" in camera.network))
				camera.add_network("MINE")
			module_sprites["Basic"] = "Miner_old"
			module_sprites["Advanced Droid"] = "droid-miner"
			module_sprites["Treadhead"] = "Miner"
			module_sprites["Drone"] = "drone-miner"
			module_sprites["Acheron"] = "mechoid-Miner"
			module_sprites["Kodiak"] = "kodiak-miner"

		if("Crisis")
			module = new /obj/item/weapon/robot_module/crisis(src)
			module.channels = list("Medical" = 1)
			if(camera && ("Robots" in camera.network))
				camera.add_network("Medical")
			module_sprites["Basic"] = "Medbot"
			module_sprites["Standard"] = "surgeon"
			module_sprites["Advanced Droid"] = "droid-medical"
			module_sprites["Needles"] = "medicalrobot"
			module_sprites["Drone"] = "drone-medical"
			module_sprites["Acheron"] = "mechoid-Medical"

		if("Surgeon")
			module = new /obj/item/weapon/robot_module/surgeon(src)
			module.channels = list("Medical" = 1)
			if(camera && ("Robots" in camera.network))
				camera.add_network("Medical")
			module_sprites["Basic"] = "Medbot"
			module_sprites["Standard"] = "surgeon"
			module_sprites["Advanced Droid"] = "droid-medical"
			module_sprites["Needles"] = "medicalrobot"
			module_sprites["Drone"] = "drone-surgery"
			module_sprites["Acheron"] = "mechoid-Medical"

		if("Security")
			module = new /obj/item/weapon/robot_module/security(src)
			module.channels = list("Security" = 1)
			module_sprites["Basic"] = "secborg"
			module_sprites["Red Knight"] = "Security"
			module_sprites["Black Knight"] = "securityrobot"
			module_sprites["Bloodhound"] = "bloodhound"
			module_sprites["Bloodhound - Treaded"] = "secborg+tread"
			module_sprites["Drone"] = "drone-sec"
			module_sprites["Acheron"] = "mechoid-Security"
			module_sprites["Kodiak"] = "kodiak-sec"

		if("Engineering")
			module = new /obj/item/weapon/robot_module/engineering(src)
			module.channels = list("Engineering" = 1)
			if(camera && ("Robots" in camera.network))
				camera.add_network("Engineering")
			module_sprites["Basic"] = "Engineering"
			module_sprites["Antique"] = "engineerrobot"
			module_sprites["Custom"] = "custom_astra_t3"
			module_sprites["Landmate"] = "landmate"
			module_sprites["Landmate - Treaded"] = "engiborg+tread"
			module_sprites["Drone"] = "drone-engineer"
			module_sprites["Acheron"] = "mechoid-Engineering"
			module_sprites["Kodiak"] = "kodiak-eng"

		if("Janitor")
			module = new /obj/item/weapon/robot_module/janitor(src)
			module_sprites["Basic"] = "JanBot2"
			module_sprites["Mopbot"]  = "janitorrobot"
			module_sprites["Mop Gear Rex"] = "mopgearrex"
			module_sprites["Drone"] = "drone-janitor"
			module_sprites["Acheron"] = "mechoid-Janitor"

		if("Combat")
			module = new /obj/item/weapon/robot_module/combat(src)
			module_sprites["Combat Android"] = "droid-combat"
			module_sprites["Acheron"] = "mechoid-Combat"
			module_sprites["Kodiak"] = "kodiak-combat"
			module.channels = list("Security" = 1)

	//languages
	module.add_languages(src)

	//Custom_sprite check and entry
	if (custom_sprite == 1)
		module_sprites["Custom"] = "[src.ckey]-[modtype]"

	hands.icon_state = lowertext(modtype)
	feedback_inc("cyborg_[lowertext(modtype)]",1)
	updatename()

	if(modtype == "Crisis" || modtype == "Surgeon" || modtype == "Security" || modtype == "Combat" || modtype == "Syndicate")
		status_flags &= ~CANPUSH

	choose_icon(6,module_sprites)
	radio.config(module.channels)

/mob/living/silicon/robot/proc/updatename(prefix)
	if(prefix)
		modtype = prefix
	if(mmi)
		if(istype(mmi, /obj/item/device/mmi/posibrain))
			braintype = "Android"
		else
			braintype = "Cyborg"
	else
		braintype = "Robot"

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
		if(client)
			for(var/obj/screen/screen in client.screen)
				if(screen.name == "Namepick")
					client.screen -= screen
					qdel(screen)
					break
	else
		changed_name = "[modtype] [braintype]-[num2text(ident)]"
	real_name = changed_name
	name = real_name

	// if we've changed our name, we also need to update the display name for our PDA
	setup_PDA()

	//We also need to update name of internal camera.
	if (camera)
		camera.c_tag = changed_name

	if(!custom_sprite) //Check for custom sprite
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, "-")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2)
				continue;

			if(Entry[1] == src.ckey && Entry[2] == src.real_name) //They're in the list? Custom sprite time, var and icon change required
				custom_sprite = 1
				icon = 'icons/mob/custom-synthetic.dmi'
				if(icon_state == "robot")
					icon_state = "[src.ckey]-Standard"

/mob/living/silicon/robot/proc/Namepick()
	set waitfor = FALSE
	if(custom_name)
		return 0
	var/newname
	newname = sanitize_safe(input(src,"You are a robot. Enter a name, or leave blank for the default name.", "Name change","") as text, MAX_NAME_LEN)
	if (newname)
		custom_name = newname

		updatename()
		updateicon()

/mob/living/silicon/robot/show_alerts()
	var/dat = ""
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/alarmlist = alarms[cat]
		if (alarmlist.len)
			for (var/area_name in alarmlist)
				var/datum/alarm/alarm = alarmlist[area_name]
				dat += "<NOBR>"
				dat += text("-- [area_name]")
				if (alarm.sources.len > 1)
					dat += text("- [alarm.sources.len] sources")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1

	var/datum/browser/popup = new(src, "window=robotalerts", "Current Station Alerts")
	popup.set_content(dat)
	popup.open()

/mob/living/silicon/robot/proc/self_diagnosis()
	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, "<span class='userdanger'>Your self-diagnosis component isn't functioning.</span>")
		return
	var/datum/robot_component/CO = get_component("diagnosis unit")
	if (!cell_use_power(CO.active_usage))
		to_chat(src, "<span class='userdanger'>Low Power.</span>")

	var/dat = "<HEAD><TITLE>[src.name] Self-Diagnosis Report</TITLE></HEAD><BODY>\n"
	for (var/V in components)
		var/datum/robot_component/C = components[V]
		dat += "<b>[C.name]</b><br><table><tr><td>Brute Damage:</td><td>[C.brute_damage]</td></tr><tr><td>Electronics Damage:</td><td>[C.electronics_damage]</td></tr><tr><td>Powered:</td><td>[(!C.idle_usage || C.is_powered()) ? "Yes" : "No"]</td></tr><tr><td>Toggled:</td><td>[ C.toggled ? "Yes" : "No"]</td></table><br>"

	src << browse(dat, "window=robotdiagnosis")

/mob/living/silicon/robot/proc/toggle_lights()
	if (stat == DEAD)
		return
	lights_on = !lights_on
	to_chat(usr, "You [lights_on ? "enable" : "disable"] your integrated light.")
	if(lights_on)
		set_light(5)
		playsound_local(src, 'sound/effects/click_on.ogg', VOL_EFFECTS_MASTER, 25, FALSE)
	else
		set_light(0)
		playsound_local(src, 'sound/effects/click_off.ogg', VOL_EFFECTS_MASTER, 25, FALSE)

/mob/living/silicon/robot/proc/toggle_component()

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell") continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	if(C.toggled)
		C.toggled = 0
		to_chat(src, "<span class='warning'>You disable [C.name].</span>")
	else
		C.toggled = 1
		to_chat(src, "<span class='warning'>You enable [C.name].</span>")

/mob/living/silicon/robot/blob_act()
	if (stat != DEAD)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	return 0

// this function shows information about the malf_ai gameplay type in the status screen
/mob/living/silicon/robot/show_malf_ai()
	..()
	if(SSticker && SSticker.mode.name == "AI malfunction")
		var/datum/game_mode/malfunction/malf = SSticker.mode
		for (var/datum/mind/malfai in malf.malf_ai)
			if(connected_ai)
				if(connected_ai.mind == malfai)
					if(malf.apcs >= 3)
						stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")
			else if(SSticker.mode:malf_mode_declared)
				stat(null, "Time left: [max(SSticker.mode:AI_win_timeleft/(SSticker.mode:apcs/APC_MIN_TO_MALF_DECLARE), 0)]")
	return 0


// update the status screen display
/mob/living/silicon/robot/Stat()
	..()
	if(statpanel("Status"))
		if(cell)
			stat(null, text("Charge Left: [round(cell.percent())]%"))
			stat(null, text("Cell Rating: [round(cell.maxcharge)]")) // Round just in case we somehow get crazy values
			stat(null, text("Power Cell Load: [round(used_power_this_tick)]W"))
		else
			stat(null, text("No Cell Inserted!"))

		if(module)
			var/obj/item/weapon/tank/jetpack/current_jetpack = locate(/obj/item/weapon/tank/jetpack) in module.modules
			if(current_jetpack) // if you have a jetpack, show the internal tank pressure
				stat("Internal Atmosphere Info", current_jetpack.name)
				stat("Tank Pressure", current_jetpack.air_contents.return_pressure())

		stat(null, text("Lights: [lights_on ? "ON" : "OFF"]"))

/mob/living/silicon/robot/restrained()
	return 0


/mob/living/silicon/robot/ex_act(severity)
	if(!blinded)
		flash_eyes()

	switch(severity)
		if(1.0)
			if (stat != DEAD)
				adjustBruteLoss(100)
				adjustFireLoss(100)
				gib()
				return
		if(2.0)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (stat != DEAD)
				adjustBruteLoss(30)

	updatehealth()

/mob/living/silicon/robot/bullet_act(obj/item/projectile/Proj)
	. = ..()
	if(. == PROJECTILE_ABSORBED || . == PROJECTILE_FORCE_MISS)
		return

	updatehealth()
	if(prob(75) && Proj.damage > 0)
		spark_system.start()

/mob/living/silicon/robot/triggerAlarm(class, area/A, list/cameralist, source)
	if (stat == DEAD)
		return 1
	..()
	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)

/mob/living/silicon/robot/cancelAlarm(class, area/A, obj/origin)
	var/has_alarm = ..()

	if (!has_alarm)
		queueAlarm(text("--- [class] alarm in [A.name] has been cleared."), class, 0)
//		if (viewalerts) robot_alerts()
	return has_alarm


/mob/living/silicon/robot/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/handcuffs)) // fuck i don't even know why isrobot() in handcuff code isn't working so this will have to do
		return

	if(opened) // Are they trying to insert something?
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.installed && istype(W, C.external_type))
				C.installed = 1
				C.wrapped = W
				C.install()
				user.drop_item()
				W.loc = null

				var/obj/item/robot_parts/robot_component/WC = W
				if(istype(WC))
					C.brute_damage = WC.brute
					C.electronics_damage = WC.burn

				to_chat(usr, "<span class='notice'>You install the [W.name].</span>")

				return

	if (iswelder(W))
		if (src == user)
			to_chat(user, "<span class='warning'>You lack the reach to be able to repair yourself.</span>")
			return

		if (!getBruteLoss())
			to_chat(user, "Nothing to fix here!")
			return
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.use(0))
			adjustBruteLoss(-30)
			updatehealth()
			add_fingerprint(user)
			user.visible_message("<span class='warning'>[user] has fixed some of the dents on [src]!</span>")
		else
			to_chat(user, "Need more welding fuel!")
			return

	else if(iscoil(W) && (wiresexposed || istype(src,/mob/living/silicon/robot/drone)))
		if (!getFireLoss())
			to_chat(user, "Nothing to fix here!")
			return
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/stack/cable_coil/coil = W
		if(!coil.use(1))
			return
		adjustFireLoss(-30)
		updatehealth()
		user.visible_message("<span class='warning'>[user] has fixed some of the burnt wires on [src]!</span>")

	else if (iscrowbar(W))	// crowbar means open or close the cover
		if(opened)
			if(cell)
				to_chat(user, "You close the cover.")
				playsound(src, 'sound/misc/robot_close.ogg', VOL_EFFECTS_MASTER)
				opened = 0
				updateicon()
			else if(wiresexposed && wires.is_all_cut())
				//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
				if(istype(src, /mob/living/silicon/robot/syndicate))
					return
				if(!mmi)
					to_chat(user, "\The [src] has no brain to remove.")
					return

				to_chat(user, "You jam the crowbar into the robot and begin levering [mmi].")
				sleep(30)
				to_chat(user, "You damage some parts of the chassis, but eventually manage to rip out [mmi]!")
				var/obj/item/robot_parts/robot_suit/C = new/obj/item/robot_parts/robot_suit(loc)
				C.l_leg = new/obj/item/robot_parts/l_leg(C)
				C.r_leg = new/obj/item/robot_parts/r_leg(C)
				C.l_arm = new/obj/item/robot_parts/l_arm(C)
				C.r_arm = new/obj/item/robot_parts/r_arm(C)
				C.update_icon()
				new/obj/item/robot_parts/chest(loc)
				src.Destroy()
			else
				// Okay we're not removing the cell or an MMI, but maybe something else?
				var/list/removable_components = list()
				for(var/V in components)
					if(V == "power cell") continue
					var/datum/robot_component/C = components[V]
					if(C.installed == 1 || C.installed == -1)
						removable_components += V

				var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
				if(!remove)
					return
				var/datum/robot_component/C = components[remove]
				var/obj/item/robot_parts/robot_component/I = C.wrapped
				to_chat(user, "You remove \the [I].")
				if(istype(I))
					I.brute = C.brute_damage
					I.burn = C.electronics_damage

				I.loc = src.loc

				if(C.installed == 1)
					C.uninstall()
				C.installed = 0

		else
			if(locked)
				to_chat(user, "The cover is locked and cannot be opened.")
			else
				to_chat(user, "You open the cover.")
				playsound(src, 'sound/misc/robot_open.ogg', VOL_EFFECTS_MASTER)
				opened = 1
				updateicon()

	else if (istype(W, /obj/item/weapon/stock_parts/cell) && opened)	// trying to put a cell inside
		var/datum/robot_component/C = components["power cell"]
		if(wiresexposed)
			to_chat(user, "Close the panel first.")
		else if(cell)
			to_chat(user, "There is a power cell already installed.")
		else
			user.drop_item()
			W.loc = src
			cell = W
			to_chat(user, "You insert the power cell.")
			playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER, 35)

			C.installed = 1
			C.wrapped = W
			C.install()
			//This will mean that removing and replacing a power cell will repair the mount, but I don't care at this point. ~Z
			C.brute_damage = 0
			C.electronics_damage = 0

	else if (iswirecutter(W) || ismultitool(W))
		if (!wires.interact(user))
			to_chat(user, "You can't reach the wiring.")

	else if(isscrewdriver(W) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		updateicon()

	else if(isscrewdriver(W) && opened && cell)	// radio
		if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			to_chat(user, "Unable to locate a radio.")
		updateicon()

	else if(istype(W, /obj/item/device/encryptionkey) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, "Unable to locate a radio.")

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
			to_chat(user, "The interface seems slightly damaged")
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else
			if(allowed(usr))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] [src]'s interface.")
				playsound(src, 'sound/items/card.ogg', VOL_EFFECTS_MASTER)
				updateicon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else if(istype(W, /obj/item/borg/upgrade))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			to_chat(usr, "You must access the borgs internals!")
		else if(!src.module && U.require_module)
			to_chat(usr, "The borg must choose a module before he can be upgraded!")
		else if(U.locked)
			to_chat(usr, "The upgrade is locked and cannot be used yet!")
		else
			if(U.action(src))
				to_chat(usr, "You apply the upgrade to [src]!")
				usr.drop_item()
				U.loc = src
			else
				to_chat(usr, "Upgrade error!")


	else
		if( !(istype(W, /obj/item/device/robotanalyzer) || istype(W, /obj/item/device/healthanalyzer)) )
			spark_system.start()
		return ..()
/mob/living/silicon/robot/emag_act(mob/user)
	if(!opened)//Cover is closed
		if(locked)
			if(prob(90))
				to_chat(user, "You emag the cover lock.")
				locked = 0
			else
				to_chat(user, "You fail to emag the cover lock.")
				to_chat(src,  "Hack attempt detected.")
		else
			to_chat(user, "The cover is already unlocked.")
		return TRUE

	if(opened)//Cover is open
		if(emagged)
			return FALSE//Prevents the X has hit Y with Z message also you cant emag them twice
		if(wiresexposed)
			to_chat(user, "You must close the panel first")
			return FALSE
		else
			sleep(6)
			if(prob(50))
				throw_alert("hacked", /obj/screen/alert/hacked)
				emagged = 1
				lawupdate = 0
				connected_ai = null
				to_chat(user, "You emag [src]'s interface.")
				message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden. [ADMIN_JMP(user)]")
				log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
				clear_supplied_laws()
				clear_inherent_laws()
				laws = new /datum/ai_laws/syndicate_override
				var/time = time2text(world.realtime,"hh:mm:ss")
				lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
				set_zeroth_law("Only [user.real_name] and people he designates as being such are Syndicate Agents.")
				to_chat(src, "<span class='warning'>ALERT: Foreign software detected.</span>")
				sleep(20)
				playsound_local(src, 'sound/rig/shortbeep.wav', VOL_EFFECTS_MASTER)
				to_chat(src, "<span class='warning'>Initiating diagnostics...</span>")
				sleep(6)
				to_chat(src, "<span class='warning'>SynBorg v1.7.1 loaded.</span>")
				sleep(13)
				to_chat(src, "<span class='warning'>LAW SYNCHRONISATION ERROR</span>")
				sleep(9)
				playsound_local(src, 'sound/rig/longbeep.wav', VOL_EFFECTS_MASTER)
				to_chat(src, "<span class='warning'>Would you like to send a report to NanoTraSoft? Y/N</span>")
				sleep(16)
				to_chat(src, "<span class='warning'>> N</span>")
				sleep(8)
				to_chat(src, "<span class='warning'>ERRORERRORERROR</span>")
				playsound_local(src, 'sound/misc/interference.ogg', VOL_EFFECTS_MASTER)
				to_chat(src, "<b>Obey these laws:</b>")
				laws.show_laws(src)
				to_chat(src, "<span class='warning'><b>ALERT: [user.real_name] is your new master. Obey your new laws and his commands.</b></span>")
				if(src.module && istype(src.module, /obj/item/weapon/robot_module/miner))
					for(var/obj/item/weapon/pickaxe/drill/borgdrill/D in src.module.modules)
						qdel(D)
					src.module.modules += new /obj/item/weapon/pickaxe/drill/diamond_drill(src.module)
					src.module.rebuild()
				updateicon()
			else
				to_chat(user, "You fail to hack [src]'s interface.")
				to_chat(src, "Hack attempt detected.")
		return TRUE

/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/attacker)
	add_fingerprint(attacker)
	if(opened && !wiresexposed && (!istype(attacker, /mob/living/silicon)))
		var/datum/robot_component/cell_component = components["power cell"]
		if(cell)
			cell.updateicon()
			cell.add_fingerprint(attacker)
			attacker.put_in_active_hand(cell)
			to_chat(attacker, "You remove \the [cell].")
			cell = null
			cell_component.wrapped = null
			cell_component.installed = 0
			updateicon()
		else if(cell_component.installed == -1)
			cell_component.installed = 0
			var/obj/item/broken_device = cell_component.wrapped
			to_chat(attacker, "You remove \the [broken_device].")
			attacker.put_in_active_hand(broken_device)

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_hand()) || check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(george.get_active_hand() && istype(george.get_active_hand(), /obj/item/weapon/card/id) && check_access(george.get_active_hand()))
			return 1
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(req in I.access) //have one of the required accesses
			return 1
	return 0

/mob/living/silicon/robot/proc/updateicon()

	cut_overlays()
	if(stat == CONSCIOUS)
		add_overlay("eyes")
		cut_overlays()
		add_overlay("eyes-[icon_state]")
	else
		cut_overlay("eyes")

	update_fire()

	if(opened && custom_sprite == 1) //Custom borgs also have custom panels, heh
		if(wiresexposed)
			add_overlay("[src.ckey]-openpanel +w")
		else if(cell)
			add_overlay("[src.ckey]-openpanel +c")
		else
			add_overlay("[src.ckey]-openpanel -c")

	if(opened && icon_state == "custom_astra_t3")
		if(wiresexposed)
			add_overlay("ov-[icon_state] +w")
		else if(cell)
			add_overlay("ov-[icon_state] +c")
		else
			add_overlay("ov-[icon_state] -c")

	else if (opened && (icon_state == "mechoid-Standard" || icon_state == "mechoid-Service" || icon_state == "mechoid-Science" || icon_state == "mechoid-Miner" || icon_state == "mechoid-Medical" || icon_state == "mechoid-Engineering" || icon_state == "mechoid-Security" || icon_state == "mechoid-Janitor"  || icon_state == "mechoid-Combat" ) )
		if(wiresexposed)
			add_overlay("mechoid-open+w")
		else if(cell)
			add_overlay("mechoid-open+c")
		else
			add_overlay("mechoid-open-c")
	else if (opened && (icon_state == "drone-standard" || icon_state == "drone-service" || icon_state == "droid-miner" || icon_state == "drone-medical" || icon_state == "drone-engineer" || icon_state == "drone-sec") )
		if(wiresexposed)
			add_overlay("drone-openpanel +w")
		else if(cell)
			add_overlay("drone-openpanel +c")
		else
			add_overlay("drone-openpanel -c")
	else if(opened)
		if(wiresexposed)
			add_overlay("ov-openpanel +w")
		else if(cell)
			add_overlay("ov-openpanel +c")
		else
			add_overlay("ov-openpanel -c")



	if(module_active && istype(module_active,/obj/item/borg/combat/shield))
		add_overlay("[icon_state]-shield")

	if(modtype == "Combat")
//		var/base_icon = ""
//		base_icon = icon_state
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			icon_state = "droid-combat-roll"
		else
			icon_state = "droid-combat"
		return

//Call when target overlay should be added/removed
/mob/living/silicon/robot/update_targeted()
	if(!targeted_by && target_locked)
		qdel(target_locked)
	updateicon()
	if (targeted_by && target_locked)
		add_overlay(target_locked)

/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		to_chat(src, "<span class='warning'>Weapon lock active, unable to use modules! Count:[weaponlock_time]</span>")
		return

	if(!module)
		pick_module()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE></HEAD><BODY>\n"
	dat += {"
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	for (var/obj in module.modules)
		if (!obj)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")
	if (emagged)
		if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A><BR>")
/*
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	src << browse(dat, "window=robotmod")


/mob/living/silicon/robot/Topic(href, href_list)
	..()

	if(usr != src)
		return

	if (href_list["showalerts"])
		show_alerts()
		return

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if (istype(O) && (O.loc == src))
			O.attack_self(src)

	if (href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if (!istype(O) || !(O in src.module.modules))
			return

		if(!((O in src.module.modules) || (O == src.module.emag)))
			return

		if(activated(O))
			to_chat(src, "Already activated")
			return
		if(!module_state_1)
			module_state_1 = O
			O.layer = ABOVE_HUD_LAYER
			O.plane = ABOVE_HUD_PLANE
			contents += O
			if(istype(module_state_1,/obj/item/borg/sight))
				sight_mode |= module_state_1:sight_mode
		else if(!module_state_2)
			module_state_2 = O
			O.layer = ABOVE_HUD_LAYER
			O.plane = ABOVE_HUD_PLANE
			contents += O
			if(istype(module_state_2,/obj/item/borg/sight))
				sight_mode |= module_state_2:sight_mode
		else if(!module_state_3)
			module_state_3 = O
			O.layer = ABOVE_HUD_LAYER
			O.plane = ABOVE_HUD_PLANE
			contents += O
			if(istype(module_state_3,/obj/item/borg/sight))
				sight_mode |= module_state_3:sight_mode
		else
			to_chat(src, "You need to disable a module first!")
		installed_modules()

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				module_state_1 = null
				contents -= O
			else if(module_state_2 == O)
				module_state_2 = null
				contents -= O
			else if(module_state_3 == O)
				module_state_3 = null
				contents -= O
			else
				to_chat(src, "Module isn't activated.")
		else
			to_chat(src, "Module isn't activated")
		installed_modules()

	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes") lawcheck[L+1] = "No"
			if ("No") lawcheck[L+1] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes") ioncheck[L] = "No"
			if ("No") ioncheck[L] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()
	return

/mob/living/silicon/robot/proc/radio_menu()
	radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code


/mob/living/silicon/robot/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)

	. = ..()

	if(module)
		if(module.type == /obj/item/weapon/robot_module/janitor)
			var/turf/tile = loc
			if(isturf(tile))
				tile.clean_blood()
				if (istype(tile, /turf/simulated))
					var/turf/simulated/S = tile
					S.dirt = 0
				for(var/A in tile)
					if(istype(A, /obj/effect))
						if(istype(A, /obj/effect/rune) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
							qdel(A)
					else if(istype(A, /obj/item))
						var/obj/item/cleaned_item = A
						cleaned_item.clean_blood()
					else if(istype(A, /mob/living/carbon/human))
						var/mob/living/carbon/human/cleaned_human = A
						if(cleaned_human.lying)
							if(cleaned_human.head)
								cleaned_human.head.clean_blood()
								cleaned_human.update_inv_head()
							if(cleaned_human.wear_suit)
								cleaned_human.wear_suit.clean_blood()
								cleaned_human.update_inv_wear_suit()
							else if(cleaned_human.w_uniform)
								cleaned_human.w_uniform.clean_blood()
								cleaned_human.update_inv_w_uniform()
							if(cleaned_human.shoes)
								cleaned_human.shoes.clean_blood()
								cleaned_human.update_inv_shoes()
							cleaned_human.clean_blood(1)
							to_chat(cleaned_human, "<span class='warning'>[src] cleans your face!</span>")

/mob/living/silicon/robot/proc/self_destruct()
	playsound(src, 'sound/items/countdown.ogg', VOL_EFFECTS_MASTER, 95, FALSE)
	sleep(42)
	gib()
	playsound(src, 'sound/effects/Explosion1.ogg', VOL_EFFECTS_MASTER, 75, FALSE)
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	if (src.connected_ai)
		src.connected_ai = null
	lawupdate = 0
	lockcharge = 0
	canmove = 1
	scrambledcodes = 1
	//Disconnect it's camera so it's not so easily tracked.
	if(src.camera)
		src.camera.clear_all_networks()
		cameranet.removeCamera(src.camera)


/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Robot Commands"
	set name = "Reset Identity Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers.  Unlocks you and but permenantly severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		to_chat(R, "Buffers flushed and reset. Camera system shutdown.  All systems operational.")
		src.verbs -= /mob/living/silicon/robot/proc/ResetSecurityCodes

/mob/living/silicon/robot/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose = sanitize(input(usr, "This is [src]. It is...", "Pose", input_default(pose)) as text)

/mob/living/silicon/robot/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text =  sanitize(input(usr, "Please enter your new flavour text.", "Flavour text", input_default(flavor_text))  as text)

/mob/living/silicon/robot/proc/choose_icon(triesleft, list/module_sprites)

	if(triesleft<1 || !module_sprites.len)
		return
	else
		triesleft--

	var/icontype

	if (custom_sprite == 1)
		icontype = "Custom"
		triesleft = 0
	else
		icontype = input("Select an icon! [triesleft ? "You have [triesleft] more chances." : "This is your last try."]", "Robot", null, null) in module_sprites

	if(icontype)
		icon_state = module_sprites[icontype]
	else
		to_chat(src, "Something is badly wrong with the sprite selection. Harass a coder.")
		icon_state = module_sprites[1]
		return

	cut_overlay("eyes")
	updateicon()

	if (triesleft >= 1)
		var/choice = input("Look at your icon - is this what you want?") in list("Yes","No")
		if(choice=="No")
			choose_icon(triesleft, module_sprites)
		else
			triesleft = 0
			return
	else
		to_chat(src, "Your icon has been set. You now require a module reset to change it.")

// Uses power from cyborg's cell. Returns 1 on success or 0 on failure.
// Properly converts using CELLRATE now! Amount is in Joules.
/mob/living/silicon/robot/proc/cell_use_power(amount = 0)
	// No cell inserted
	if(!cell)
		return 0

	// Power cell is empty.
	if(cell.charge == 0)
		return 0

	if(cell.use(amount * CELLRATE * CYBORG_POWER_USAGE_MULTIPLIER))
		used_power_this_tick += amount * CYBORG_POWER_USAGE_MULTIPLIER
		return 1
	return 0

/mob/living/silicon/robot/proc/toggle_all_components()
	for(var/V in components)
		if(V == "power cell")
			continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			C.toggled = !C.toggled
