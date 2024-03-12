var/global/list/image/ghost_sightless_images = list() //this is a list of images for things ghosts should still be able to see even without ghost sight

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank"
	plane = GHOST_PLANE
	stat = DEAD
	density = FALSE
	canmove = 0
	blinded = 0
	anchored = TRUE	//  don't get pushed around
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100
	hud_type = /datum/hud/ghost
	invisibility = INVISIBILITY_OBSERVER
	show_examine_log = FALSE
	var/can_reenter_corpse
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

	var/ghostvision = 1 //is the ghost able to see things humans can't?

	var/next_point_to = 0

	var/datum/orbit_menu/orbit_menu

	var/obj/item/device/multitool/adminMulti = null //Wew, personal multiotool for ghosts!

	var/image/body_icon

/mob/dead/observer/atom_init()
	invisibility = INVISIBILITY_OBSERVER

	verbs += /mob/dead/observer/proc/dead_tele

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

		// copy for future use
		body_icon = image(icon, icon_state)
		body_icon.copy_overlays(body)

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

	var/image/I = image(initial(icon), src, "ghost")
	I.plane = GHOST_ILLUSION_PLANE
	I.alpha = 200
	// s = short buffer
	var/s = add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/see_ghosts, "see_ghosts", I)
	var/datum/atom_hud/alternate_appearance/basic/see_ghosts/AA = s
	AA.set_image_layering(GHOST_ILLUSION_PLANE) // I don't want to add more arguments to the constructor

/mob/dead/observer/Destroy()
	if(data_hud)
		remove_data_huds()
	observer_list -= src
	if(orbit_menu)
		SStgui.close_uis(orbit_menu)
		QDEL_NULL(orbit_menu)
	if(mind && mind.current && isliving(mind.current))
		var/mob/living/M = mind.current
		M.med_hud_set_status()
	QDEL_NULL(adminMulti)
	return ..()

/mob/dead/observer/Life()
	if(client)
		var/turf/T = get_turf(src)
		if(T && last_z != T.z)
			update_z(T.z)

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
		var/atom/target = locate(href_list["track"])
		if(target != src)
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

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0)
	return TRUE

/mob/proc/ghostize(can_reenter_corpse = TRUE, bancheck = FALSE, timeofdeath = world.time)
	if(!key)
		return

	logout_reason = logout_reason || (can_reenter_corpse ? LOGOUT_REENTER : LOGOUT_GHOST)

	if(!(ckey in admin_datums) && bancheck == TRUE && jobban_isbanned(src, "Observer"))
		var/mob/M = mousize()
		if((config.allow_drone_spawn) || !jobban_isbanned(src, ROLE_DRONE))
			var/response = tgui_alert(M, "Do you want to become a maintenance drone?","Are you sure you want to beep?", list("Beep!","Nope!"))
			if(response == "Beep!")
				M.dronize()
				qdel(M)
		return

	var/mob/dead/observer/ghost = new(src)	//Transfer safety to observer spawning proc.
	set_EyesVision(transition_time = 0)
	SStgui.on_transfer(src, ghost)
	ghost.can_reenter_corpse = can_reenter_corpse
	ghost.timeofdeath = timeofdeath
	ghost.key = key
	ghost.playsound_stop(CHANNEL_AMBIENT)
	ghost.playsound_stop(CHANNEL_AMBIENT_LOOP)
	if(client && !ghost.client.holder && !config.antag_hud_allowed)		// For new ghosts we remove the verb from even showing up if it's not allowed.
		ghost.verbs -= /mob/dead/observer/verb/toggle_antagHUD			// Poor guys, don't know what they are missing!
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

	if(HAS_TRAIT(src, TRAIT_NO_SOUL))
		to_chat(src, "<span class='red'>Вы не можете покинуть тело. У Вас нет души.</span>")
		return

	if(stat == DEAD)
		if(fake_death)
			var/response = tgui_alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to play this round for another 30 minutes! You can't change your mind so choose wisely!)","Are you sure you want to ghost?", list("Stay in body","Ghost"))
			if(response != "Ghost")
				return	//didn't want to ghost after-all
			ghostize(can_reenter_corpse = FALSE)
		else
			ghostize(can_reenter_corpse = TRUE)
	else
		var/response = tgui_alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to play this round for another 30 minutes! You can't change your mind so choose wisely!)","Are you sure you want to ghost?", list("Stay in body","Ghost"))
		if(response != "Ghost")
			return	//didn't want to ghost after-all

		if(isrobot(usr))
			var/mob/living/silicon/robot/robot = usr
			robot.set_all_components(FALSE)
		else if(!immune_to_ssd)
			SetCrawling(TRUE)
			Sleeping(2 SECONDS)

		var/leave_type = "Ghosted"
		if(istype(loc, /obj/machinery/cryopod))
			leave_type = "Ghosted in Cryopod"
		SSStatistics.add_leave_stat(mind, leave_type)
		ghostize(can_reenter_corpse = FALSE)

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
		for(var/hud in get_all_antag_huds())
			var/datum/atom_hud/antag/H = hud
			H.remove_hud_from(src)
		to_chat(src, "<span class='info'><B>AntagHUD Disabled</B></span>")
	else
		M.antagHUD = TRUE
		for(var/hud in get_all_antag_huds())
			var/datum/atom_hud/antag/H = hud
			H.add_hud_to(src)
		to_chat(src, "<span class='info'><B>AntagHUD Enabled</B></span>")

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
	if(!isobserver(usr))
		to_chat(usr, "Not when you're not dead!")
		return
	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(30)
		usr.verbs += /mob/dead/observer/proc/dead_tele

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

	forceMove(target)
	orbit(target, orbitsize, FALSE, 20, 36)

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

	if(isobserver(usr)) //Make sure they're an observer!
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

/mob/dead/observer/verb/toggle_icon()
	set category = "Ghost"
	set name = "Toggle Ghost Icon"
	set desc = "Choise ghost icon."

	var/list/custom_sprites = get_accepted_custom_items_by_type(ckey, FLUFF_TYPE_GHOST)

	if(!length(custom_sprites))
		if(config.customitems_info_url)
			to_chat(src, "<span class='notice'>You don't have any custom ghost sprites. <a href='[config.customitems_info_url]'>Read more about Fluff</a> and how to get them.</span>")
		else
			to_chat(src, "<span class='notice'>You don't have any custom ghost sprites.</span>")

	if(body_icon)
		custom_sprites += "--body--"

	custom_sprites += "--ghost--"

	var/select = input("Select icon.", "Select") as null|anything in custom_sprites

	if(!select)
		return

	cut_overlays()

	if(select == "--body--")
		icon = body_icon.icon
		icon_state = body_icon.icon_state
		copy_overlays(body_icon)
	else if (select == "--ghost--")
		icon = initial(icon)
		icon_state = "ghost"
	else
		var/datum/custom_item/custom = select
		icon = custom.icon
		icon_state = custom.icon_state


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

	if(!isobserver(usr)) return

	var/turf/t = get_turf(src)
	if(t)
		print_atmos_analysis(src, atmosanalyzer_scan(t))

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
		if(IAN.client)
			continue
		phoron_dog = IAN
		break

	if(phoron_dog)
		message_admins("[src.ckey] joined the game as [phoron_dog] [ADMIN_JMP(phoron_dog)] [ADMIN_FLW(phoron_dog)].")
		phoron_dog.ckey = src.ckey
	else
		to_chat(src, "<span class='notice'><B>Living and available Ian not found.</B></span>")

/mob/dead/observer/pointed(atom/A)
	if(next_point_to > world.time)
		return FALSE
	if(!..())
		return FALSE
	emote_dead("points to [A]")
	next_point_to = world.time + 2 SECONDS
	return TRUE

/mob/dead/observer/point_at(atom/pointed_atom)
	..(pointed_atom, /obj/effect/decal/point/ghost)

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

	if (stat == CONSCIOUS)
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
	update_sight()
	to_chat(usr, "You [(ghostvision?"now":"no longer")] have ghost vision.")

/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"
	updateghostsight()

/mob/dead/observer/proc/updateghostsight()
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	update_sight()


/mob/dead/observer/update_sight()
	..()
	if (!ghostvision)
		see_invisible = SEE_INVISIBLE_LIVING
	else
		see_invisible = SEE_INVISIBLE_OBSERVER
	updateghostimages()

/proc/updateallghostimages()
	for (var/mob/dead/observer/O in player_list)
		O.updateghostimages()

/mob/dead/observer/proc/updateghostimages()
	if (!client)
		return
	if (!ghostvision)
		client.images |= ghost_sightless_images
	else
		//add images for the 60inv things ghosts can normally see when darkness is enabled so they can see them now
		client.images -= ghost_sightless_images

/mob/dead/observer/IsAdvancedToolUser()
	return IsAdminGhost(src)

/mob/dead/observer/verb/mafia_game_signup()
	set category = "Ghost"
	set name = "Signup for Mafia"
	set desc = "Sign up for a game of Mafia to pass the time while dead."

	mafia_signup()

/mob/dead/observer/proc/mafia_signup()
	if(!client)
		return
	if(!isobserver(src))
		to_chat(usr, "<span class='warning'>You must be a ghost to join mafia!</span>")
		return
	var/datum/mafia_controller/game = global.mafia_game //this needs to change if you want multiple mafia games up at once.
	if(!game)
		game = create_mafia_game()
	game.tgui_interact(usr)

/mob/dead/observer/verb/open_spawners_menu()
	set name = "Spawners Menu"
	set desc = "See all currently available spawners"
	set category = "Ghost"

	if(!spawners_menu)
		spawners_menu = new()

	spawners_menu.tgui_interact(src)

/mob/dead/observer/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Station Time: [worldtime2text()]")

/mob/dead/observer/verb/change_view_range()
	set name = "Change View Range"
	set desc = "Change your view range"
	set category = "Ghost"

	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM])
		to_chat(usr, "<span class='warning'>That verb is currently globally disabled.</span>")
		return

	var/max_view_range = client.supporter ? config.ghost_max_view_supporter : config.ghost_max_view

	var/viewx = clamp(input("Enter view width ([world.view]-[max_view_range])") as num|null, world.view, max_view_range) * 2 + 1
	var/viewy = clamp(input("Enter view height ([world.view]-[max_view_range])") as num|null, world.view, max_view_range) * 2 + 1

	if(!client)
		return
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM])
		return

	client.change_view("[viewx]x[viewy]")
	if(client.prefs.auto_fit_viewport)
		client.fit_viewport()
