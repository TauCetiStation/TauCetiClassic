var/global/list/image/ghost_darkness_images = list() //this is a list of images for things ghosts should still be able to see when they toggle darkness
var/global/list/image/ghost_sightless_images = list() //this is a list of images for things ghosts should still be able to see even without ghost sight

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank"
	layer = MOB_LAYER // on tg it is FLOAT LAYER
	plane = FLOAT_PLANE
	stat = DEAD
	density = FALSE
	canmove = 0
	blinded = 0
	anchored = TRUE	//  don't get pushed around
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100
	hud_type = /datum/hud/ghost
	invisibility = INVISIBILITY_OBSERVER
	var/can_reenter_corpse
	var/datum/hud/living/carbon/hud = null // hud
	var/bootime = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/has_enabled_antagHUD = 0
	var/list/datahuds = list(DATA_HUD_SECURITY, DATA_HUD_MEDICAL_ADV, DATA_HUD_DIAGNOSTIC, DATA_HUD_HOLY) // Data huds allowed all ghost
	var/data_hud = FALSE
	var/antagHUD = FALSE
	universal_speak = 1
	var/golem_rune = null //Used to check, if we already queued as a golem.

	var/image/ghostimage = null //this mobs ghost image, for deleting and stuff
	var/ghostvision = 1 //is the ghost able to see things humans can't?
	var/seedarkness = 1
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/datum/orbit_menu/orbit_menu

	var/obj/item/device/multitool/adminMulti = null //Wew, personal multiotool for ghosts!

/mob/dead/observer/atom_init()
	invisibility = INVISIBILITY_OBSERVER

	add_verb(/mob/dead/observer/proc/dead_tele)

	ghostimage = image(icon, src, "ghost")
	ghost_darkness_images |= ghostimage
	updateallghostimages()

	var/turf/T
	var/mob/body = loc
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?
		attack_log = body.attack_log	//preserve our attack logs by copying them to our ghost

		if(ishuman(body))
			copy_overlays(body)
		else
			icon = body.icon
			icon_state = body.icon_state
			copy_overlays(body)

		cut_overlay(list(body.typing_indicator, body.stat_indicator))

		alpha = 127

		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				if(gender == MALE)
					name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
				else
					name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

	if(!T)
		T = pick(latejoin)			//Safety in case we cannot find the body's position

	loc = T

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
	real_name = name

	dead_mob_list += src

	update_all_alt_apperance()

	. = ..()

	observer_list += src

/mob/dead/observer/Destroy()
	if(data_hud)
		remove_data_huds()
	observer_list -= src
	if (ghostimage)
		ghost_darkness_images -= ghostimage
		qdel(ghostimage)
		ghostimage = null
		updateallghostimages()
	if(orbit_menu)
		SStgui.close_uis(orbit_menu)
		QDEL_NULL(orbit_menu)
	if(mind && mind.current && isliving(mind.current))
		var/mob/living/M = mind.current
		M.med_hud_set_status()
	QDEL_NULL(adminMulti)
	return ..()

//this is called when a ghost is drag clicked to something.
/mob/dead/observer/MouseDrop(atom/over)
	if(!usr || !over) return
	if (isobserver(usr) && usr.client.holder && isliving(over))
		if (usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()

/mob/dead/observer/Topic(href, href_list)
	if(usr != src)
		return

	if(href_list["track"])
		var/mob/target = locate(href_list["track"]) in mob_list
		if(istype(target) && (target != src))
			ManualFollow(target)
			return

	if(href_list["x"] && href_list["y"] && href_list["z"])
		var/tx = text2num(href_list["x"])
		var/ty = text2num(href_list["y"])
		var/tz = text2num(href_list["z"])
		var/turf/target = locate(tx, ty, tz)
		if(istype(target))
			forceMove(target)
			return

	if(href_list["ghostplayerobservejump"])
		var/atom/movable/target = locate(href_list["ghostplayerobservejump"])
		if(!target)
			return

		var/turf/T = get_turf(target)
		forceMove(T)

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/mob/proc/ghostize(can_reenter_corpse = TRUE, bancheck = FALSE)
	if(key)
		if(!(ckey in admin_datums) && bancheck == TRUE && jobban_isbanned(src, "Observer"))
			var/mob/M = mousize()
			if((config.allow_drone_spawn) || !jobban_isbanned(src, ROLE_DRONE))
				var/response = tgui_alert(M, "Do you want to become a maintenance drone?","Are you sure you want to beep?", list("Beep!","Nope!"))
				if(response == "Beep!")
					M.dronize()
					qdel(M)
			return
		var/mob/dead/observer/ghost = new(src)	//Transfer safety to observer spawning proc.
		SStgui.on_transfer(src, ghost)
		ghost.can_reenter_corpse = can_reenter_corpse
		ghost.timeofdeath = src.timeofdeath //BS12 EDIT
		ghost.key = key
		ghost.playsound_stop(CHANNEL_AMBIENT)
		ghost.playsound_stop(CHANNEL_AMBIENT_LOOP)
		if(client && !ghost.client.holder && !config.antag_hud_allowed)		// For new ghosts we remove the verb from even showing up if it's not allowed.
			ghost.remove_verb(/mob/dead/observer/verb/toggle_antagHUD)			// Poor guys, don't know what they are missing!
		return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	if(!(ckey in admin_datums) && jobban_isbanned(src, "Observer"))
		to_chat(src, "<span class='red'>You have been banned from observing.</span>")
		return
	if(stat == DEAD)
		if(fake_death)
			var/response = tgui_alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to play this round for another 30 minutes! You can't change your mind so choose wisely!)","Are you sure you want to ghost?", list("Stay in body","Ghost"))
			if(response != "Ghost")
				return	//didn't want to ghost after-all
			var/mob/dead/observer/ghost = ghostize(can_reenter_corpse = FALSE)
			ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.
		else
			ghostize(can_reenter_corpse = TRUE)
	else
		var/response = tgui_alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to play this round for another 30 minutes! You can't change your mind so choose wisely!)","Are you sure you want to ghost?", list("Stay in body","Ghost"))
		if(response != "Ghost")
			return	//didn't want to ghost after-all

		if(isrobot(usr))
			var/mob/living/silicon/robot/robot = usr
			robot.toggle_all_components()
		else
			resting = 1
			Sleeping(2 SECONDS)
		var/mob/dead/observer/ghost = ghostize(can_reenter_corpse = FALSE)						//0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
		ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.
	return


/mob/dead/observer/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = TRUE
	set_dir(Dir)
	if(NewLoc)
		loc = NewLoc
		for(var/obj/effect/step_trigger/S in NewLoc)
			S.Crossed(src)
		update_parallax_contents()
		return
	loc = get_turf(src) //Get out of closets and such as a ghost
	if((Dir & NORTH) && y < world.maxy)
		y++
	else if((Dir & SOUTH) && y > 1)
		y--
	if((Dir & EAST) && x < world.maxx)
		x++
	else if((Dir & WEST) && x > 1)
		x--

	for(var/obj/effect/step_trigger/S in locate(x, y, z))	//<-- this is dumb
		S.Crossed(src)


/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)	return
	if(!(mind && mind.current && can_reenter_corpse))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return
	if(mind.current.key && mind.current.key[1] != "@")	//makes sure we don't accidentally kick any clients
		to_chat(usr, "<span class='warning'>Another consciousness is in your body... it is resisting you.</span>")
		return
	SStgui.on_transfer(src, mind.current)
	mind.current.key = key
	return 1

/mob/dead/observer/proc/show_data_huds()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = global.huds[hudtype]
		H.add_hud_to(src)

/mob/dead/observer/proc/remove_data_huds()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = global.huds[hudtype]
		H.remove_hud_from(src)

/mob/dead/observer/verb/toggle_allHUD()
	set category = "Ghost"
	set name = "Toggle HUDs"
	set desc = "Toggles all HUD allowing you to see how everyone is doing."
	if(!client)
		return

	if(client.has_antag_hud())
		to_chat(usr, "Please disable antag-HUD or combo-HUDs in the admin tab.")
		return

	if(data_hud)
		data_hud = !data_hud
		remove_data_huds()
		to_chat(src, "<span class='info'><B>HUDs Disabled</B></span>")
	else
		data_hud = !data_hud
		show_data_huds()
		to_chat(src, "<span class='info'><B>HUDs Enabled</B></span>")

/mob/dead/observer/verb/toggle_antagHUD()
	set category = "Ghost"
	set name = "Toggle AntagHUD"
	set desc = "Toggles AntagHUD allowing you to see who is the antagonist."

	if(!client)
		return
	if(!config.antag_hud_allowed && !client.holder)
		to_chat(src, "<span class='red'>Admins have disabled this for this round.</span>")
		return
	var/mob/dead/observer/M = src
	if(jobban_isbanned(M, "AntagHUD"))
		to_chat(src, "<span class='danger'>You have been banned from using this feature.</span>")
		return
	if(config.antag_hud_restricted && !M.has_enabled_antagHUD && !client.holder)
		var/response = tgui_alert(src, "If you turn this on, you will not be able to take any part in the round.","Do you want to on this feature?", list("Yes","No"))
		if(response == "No")
			return
		M.can_reenter_corpse = FALSE
	if(!M.has_enabled_antagHUD && !client.holder)
		M.has_enabled_antagHUD = TRUE
	if(M.antagHUD)
		M.antagHUD = FALSE
		for(var/datum/atom_hud/antag/H in global.huds)
			H.remove_hud_from(src)
		to_chat(src, "<span class='info'><B>AntagHUD Disabled</B></span>")
	else
		M.antagHUD = TRUE
		for(var/datum/atom_hud/antag/H in global.huds)
			H.add_hud_to(src)
		to_chat(src, "<span class='info'><B>AntagHUD Enabled</B></span>")

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
	if(!istype(usr, /mob/dead/observer))
		to_chat(usr, "Not when you're not dead!")
		return
	usr.remove_verb(/mob/dead/observer/proc/dead_tele)
	spawn(30)
		usr.add_verb(/mob/dead/observer/proc/dead_tele)

	var/A = tgui_input_list(usr, "Area to jump to", "BOOYEA", ghostteleportlocs)
	if(!A)
		return
	var/area/thearea = ghostteleportlocs[A]
	if(!thearea)
		return

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L += T

	if(!L || !L.len)
		to_chat(usr, "<span class='warning'>No area available.</span>")

	usr.forceMove(pick(L))
	update_parallax_contents()

/mob/dead/observer/verb/follow()
	set name = "Orbit" // "Haunt"
	set category = "Ghost"
	set desc = "Follow and orbit a mob."

	if(!orbit_menu)
		orbit_menu = new(src)

	orbit_menu.tgui_interact(src)


// This is the ghost's follow verb with an argument
/mob/dead/observer/proc/ManualFollow(atom/movable/target)
	if (!istype(target))
		return

	var/icon/I = icon(target.icon,target.icon_state,target.dir)

	var/orbitsize = (I.Width() + I.Height()) * 0.5
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

	if(orbiting && orbiting.orbiting != target)
		to_chat(src, "<span class='notice'>Now orbiting [target].</span>")

	var/rot_seg

	switch(ghost_orbit)
		if(GHOST_ORBIT_TRIANGLE)
			rot_seg = 3
		if(GHOST_ORBIT_SQUARE)
			rot_seg = 4
		if(GHOST_ORBIT_PENTAGON)
			rot_seg = 5
		if(GHOST_ORBIT_HEXAGON)
			rot_seg = 6
		else //Circular
			rot_seg = 36 //360/10 bby, smooth enough aproximation of a circle

	forceMove(target)
	orbit(target, orbitsize, FALSE, 20, rot_seg)

/mob/dead/observer/orbit()
	set_dir(SOUTH) // Reset dir so the right directional sprites show up
	..()

/mob/dead/observer/stop_orbit()
	..()
	pixel_y = 0

/mob/dead/observer/verb/jumptomob() //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob."

	if(istype(usr, /mob/dead/observer)) //Make sure they're an observer!
		var/list/dest = list() //List of possible destinations (mobs)
		var/target = null	   //Chosen target.

		dest += getpois(mobs_only = TRUE) //Fill list, prompt user with list
		target = tgui_input_list(usr, "Please, select a player!", "Jump to Mob", dest)

		if (!target)//Make sure we actually have a target
			return
		else
			var/mob/M = dest[target] //Destination mob
			var/mob/A = src			 //Source mob
			var/turf/T = get_turf(M) //Turf of the destination mob

			if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
				A.forceMove(T)
				A.update_parallax_contents()
			else
				to_chat(A, "This mob is not located in the game world.")

/*
/mob/dead/observer/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time) return
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
		bootime = world.time + 600
		return
	//Maybe in the future we can add more <i>spooky</i> code here!
	return
*/

/mob/dead/observer/memory()
	set hidden = 1
	to_chat(src, "<span class='red'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/add_memory()
	set hidden = 1
	to_chat(src, "<span class='red'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/verb/analyze_air()
	set name = "Analyze Air"
	set category = "Ghost"

	if(!istype(usr, /mob/dead/observer)) return

	var/turf/t = get_turf(src)
	if(t)
		print_atmos_analysis(src, atmosanalyzer_scan(t))

/mob/dead/observer/verb/become_mouse()
	set name = "Become mouse"
	set category = "Ghost"

	if(jobban_isbanned(src, "Mouse"))
		to_chat(src, "<span class='warning'>You have been banned from being mouse.</span>")
		return

	if(config.disable_player_mice)
		to_chat(src, "<span class='warning'>Spawning as a mouse is currently disabled.</span>")
		return

	var/mob/dead/observer/M = usr
	if(config.antag_hud_restricted && M.has_enabled_antagHUD == 1)
		to_chat(src, "<span class='warning'>antagHUD restrictions prevent you from spawning in as a mouse.</span>")
		return

	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You may only spawn again as a mouse more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>")
		return

	var/response = tgui_alert(src, "Are you -sure- you want to become a mouse?","Are you sure you want to squeek?", list("Squeek!","Nope!"))
	if(response != "Squeek!")
		return  //Hit the wrong key...again.

	mousize()

/mob/proc/mousize()
	//find a viable mouse candidate
	var/mob/living/simple_animal/mouse/host
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in machines)
		if(!v.welded && v.z == src.z)
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_animal/mouse(vent_found.loc)
	else
		to_chat(src, "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>")

	if(host)
		if(config.uneducated_mice)
			host.universal_understand = 0
		host.ckey = src.ckey
		to_chat(host, "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>")
	return host

/mob/dead/observer/proc/ianize()
	set name = "Become Ian"
	set category = "Ghost"

	if(!abandon_allowed)
		to_chat(src, "<span class='notice'>Respawn is disabled.</span>")
		return

	if(has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		to_chat(src, "<span class='notice'><B>Upon using the antagHUD you forfeighted the ability to join the round.</B></span>")
		return

	if(!SSticker.mode)
		to_chat(src, "<span class='notice'>Please wait until game is started.</span>")
		return

	var/response = tgui_alert(src, "You want to find Bag Boss?","Do you want to be Ian?", list("Soap Pain!","Nope!"))
	if(response != "Soap Pain!")
		return

	var/mob/living/carbon/ian/phoron_dog
	for(var/mob/living/carbon/ian/IAN in alive_mob_list) // Incase there is multi_ians, what should NOT ever happen normally!
		if(IAN.mind) // Mind means someone was or is in a body.
			continue
		phoron_dog = IAN
		break

	if(phoron_dog)
		message_admins("[src.ckey] joined the game as [phoron_dog] [ADMIN_JMP(phoron_dog)] [ADMIN_FLW(phoron_dog)].")
		phoron_dog.ckey = src.ckey
	else
		to_chat(src, "<span class='notice'><B>Living and available Ian not found.</B></span>")

/mob/dead/observer/verb/view_manfiest()
	set name = "View Crew Manifest"
	set category = "Ghost"

	var/dat = data_core.html_manifest(OOC=1)

	var/datum/browser/popup = new(src, "manifest", "Crew Manifest", 370, 420, ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

//Used for drawing on walls with blood puddles as a spooky ghost.
/mob/dead/observer/verb/bloody_doodle()
	set category = "Ghost"
	set name = "Write in blood"
	set desc = "If the round is sufficiently spooky, write a short message in blood on the floor or a wall. Remember, no IC in OOC or OOC in IC."

	if(!(config.cult_ghostwriter))
		to_chat(src, "<span class='red'>That verb is not currently permitted.</span>")
		return

	if (!src.stat)
		return

	if (usr != src)
		return //something is terribly wrong

	var/ghosts_can_write = FALSE
	if(global.cult_religion)
		var/count = 0
		for(var/mob/M in global.cult_religion.members)
			if(M && M.mind && M.ckey && M.stat != DEAD)
				count++

		if(count > config.cult_ghostwriter_req_cultists)
			ghosts_can_write = TRUE

	if(!ghosts_can_write)
		to_chat(src, "<span class='red'>Вуаль еще не ослабла.</span>")
		return

	var/type = pick(subtypesof(/datum/dirt_cover))
	var/datum/dirt_cover/color = new type()
	var/datum/dirt_cover/doodle_color = new /datum/dirt_cover(color)
	qdel(color)

	var/max_length = 50
	var/message = sanitize(input(src, "Напишите сообщение. Оно не должно быть более 50 символов.", "Писание кровью", ""))

	if(message)
		var/turf/simulated/T = get_turf(src)
		if(!istype(T))
			to_chat(src, "<span class='warning'>Вы не можете здесь рисовать.</span>")
			return
		var/num_doodles = 0
		for(var/obj/effect/decal/cleanable/blood/writing/W in T)
			num_doodles++
		if(num_doodles > 4)
			to_chat(src, "<span class='warning'>Не хватает места для еще одной надписи.</span>")
			return

		if(length_char(message) > max_length)
			message = "[copytext_char(message, 1, max_length+1)]~"
			to_chat(src, "<span class='warning'>Вам не хватило крови дописать.</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basedatum = new/datum/dirt_cover(doodle_color)
		W.update_icon()
		W.message = message
		W.add_hiddenprint(src)
		W.visible_message("<span class='red'>Невидимые пальцы что-то рисуют кровью на [T]...</span>")

/mob/dead/observer/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts."
	set category = "Ghost"
	ghostvision = !(ghostvision)
	updateghostsight()
	to_chat(usr, "You [(ghostvision?"now":"no longer")] have ghost vision.")

/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"
	seedarkness = !(seedarkness)
	updateghostsight()

/mob/dead/observer/proc/updateghostsight()
	if (!seedarkness)
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	else
		see_invisible = SEE_INVISIBLE_OBSERVER
		if (!ghostvision)
			see_invisible = SEE_INVISIBLE_LIVING
	updateghostimages()

/proc/updateallghostimages()
	for (var/mob/dead/observer/O in player_list)
		O.updateghostimages()

/mob/dead/observer/proc/updateghostimages()
	if (!client)
		return
	if (seedarkness || !ghostvision)
		client.images -= ghost_darkness_images
		client.images |= ghost_sightless_images
	else
		//add images for the 60inv things ghosts can normally see when darkness is enabled so they can see them now
		client.images -= ghost_sightless_images
		client.images |= ghost_darkness_images
		if (ghostimage)
			client.images -= ghostimage //remove ourself

/mob/dead/observer/IsAdvancedToolUser()
	return IsAdminGhost(src)

/mob/dead/observer/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Station Time: [worldtime2text()]")
