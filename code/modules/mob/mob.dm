/**
  * Delete a mob
  *
  * Removes mob from the following global lists
  * * global.mob_list
  * * global.dead_mob_list
  * * global.alive_mob_list
  * Clears alerts for this mob
  *
  * Parent call
  */
/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	global.mob_list -= src
	global.dead_mob_list -= src
	global.alive_mob_list -= src
	for(var/alert in alerts)
		clear_alert(alert, TRUE)
	remote_control = null
	QDEL_NULL(hud_used)
	ghostize(bancheck = TRUE)
	my_religion?.remove_member(src)

	// I dont known how
	global.player_list -= src

	if(mind)
		if(mind.current == src)
			mind.set_current(null)
		if(mind.original == src)
			mind.original = null

	for(var/datum/action/action as anything in actions)
		action.Remove(src)

	if(buckled) // simpler version of /unbuckle_mob
		buckled.buckled_mob = null
		SEND_SIGNAL(buckled, COMSIG_MOVABLE_UNBUCKLE, src)
		buckled.post_buckle_mob(src)
		buckled = null

	return ..()


/mob/examine(mob/user)
	. = ..()
	if(w_class)
		to_chat(user, "It is a [get_size_flavor()] sized creature.")

/mob/atom_init()
	spawn()
		if(client)
			animate(client, color = null, time = 0)
	mob_list += src
	if(stat == DEAD)
		dead_mob_list += src
	else
		alive_mob_list += src
	. = ..()
	prepare_huds()
	update_all_alt_apperance()

	init_languages()

/mob/proc/Cell()
	set category = "Admin"
	set hidden = TRUE

	if(!isturf(loc))
		return 0

	var/turf/T = loc

	var/datum/gas_mixture/env = T.return_air()

	var/t = "<span class='notice'>Coordinates: [COORD(T)]</span>\n"
	t += "<span class='warning'>Temperature: [env.temperature]</span>\n"
	t += "<span class='warning'>Pressure: [env.return_pressure()]kPa</span>\n"
	for(var/g in env.gas)
		t += "<span class='notice'>[g]: [env.gas[g]] / [env.gas[g] * R_IDEAL_GAS_EQUATION * env.temperature / env.volume]kPa</span>\n"

	to_chat(usr, t)

// Show IC message to mob (if you need to show message to multiple mobs around - audible_message()/visible_message() is your choice)
// Messages can be of different types, just use suitable for you SHOWMSG_* define as second parameter
// You can pass multiple messages with different types, just alternate them, for example:
// show_message("message", SHOWMSG_VISUAL, "message2", SHOWMSG_AUDIO, "message3", SHOWMSG_FEEL)
// SHOWMSG_ALWAYS can be used for fallback message in last priority
// Message types are bitflags, so you can specify multiple types for messages, ex. SHOWMSG_VISUAL | SHOWMSG_FEEL:
// show_message("message", SHOWMSG_AUDIO, "message2", SHOWMSG_VISUAL | SHOWMSG_FEEL)
// User will see first message with suitable type for his (dis)abilities, so sort messages in priority
// If you don't need all this, want to show just a feedback or OOC message - use to_chat()

/mob/proc/show_message()
	ASSERT(!(args.len % 2))

	if(!client && !length(src.parasites))
		return FALSE

	var/msg
	var/type

	for(var/i = 1; i < args.len; i += 2)
		if(!args[i]) // visible_message() & audible_message() has null as msg by default
			continue

		type = args[i + 1]

		if((type & SHOWMSG_VISUAL) && !(sdisabilities & BLIND) && !blinded && !paralysis) // Vision related
			msg = args[i]
			break

		if((type & SHOWMSG_AUDIO) && !(sdisabilities & DEAF) && !ear_deaf) // Hearing related
			if(stat == UNCONSCIOUS)
				msg = "<i>... You can almost hear something ...</i>"
			else
				msg = args[i]
			break

		if(type & SHOWMSG_FEEL) // todo: species check (IPC)?
			msg = args[i]
			break

	if(!msg)
		return FALSE

	to_chat(src, msg)
	return list(msg, type) // should pass args to parasites

/mob/living/carbon/show_message()
	. = ..()
	if(. && length(parasites))
		for(var/mob/living/M in parasites) // todo: need to combine parasites mechanic with /obj/item/weapon/holder (PASSEMOTES) and maybe .contents too (tg HEAR_1)
			M.show_message(arglist(.))

/obj/item/weapon/holder/proc/show_message()
	for(var/mob/living/M in contents)
		M.show_message(arglist(args))

/obj/item/alien_embryo/proc/show_message() // not used?
	for(var/mob/living/M in contents)
		M.show_message(arglist(args))

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
// WHY this self_message/blind_message/deaf_message so inconsistent as positional args!
// todo:
// * need to combine visible_message/audible_message to one proc (something like show_message) (maybe it will be a mess because of *_distance ?)
// * need some version combined with playsound (one cycle for audio message and sound)
/mob/visible_message(message, self_message, blind_message, viewing_distance = world.view, list/ignored_mobs, runechat_msg)
	for(var/mob/M in (viewers(get_turf(src), viewing_distance) - ignored_mobs)) //todo: get_hearers_in_view() (tg)

		if((!(M.sdisabilities & BLIND) && !M.blinded && !M.paralysis) && runechat_msg)
			M.show_runechat_message(src, null, runechat_msg, null, SHOWMSG_VISUAL)

		if(M == src && self_message)
			to_chat(M, self_message)
			continue

		M.show_message(message, SHOWMSG_VISUAL, blind_message, SHOWMSG_AUDIO)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(message, blind_message, viewing_distance = world.view, list/ignored_mobs, runechat_msg)
	//todo: for range<=1 combine SHOWMSG_FEEL with SHOWMSG_VISUAL like in custom_emote?
	for(var/mob/M in (viewers(get_turf(src), viewing_distance) - ignored_mobs)) //todo: get_hearers_in_view() (tg)
		M.show_message(message, SHOWMSG_VISUAL, blind_message, SHOWMSG_AUDIO)

		if((!(M.sdisabilities & BLIND) && !M.blinded && !M.paralysis) && runechat_msg)
			M.show_runechat_message(src, null, runechat_msg, null, SHOWMSG_VISUAL)

// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/mob/audible_message(message, self_message, deaf_message, hearing_distance = world.view, list/ignored_mobs, runechat_msg, deaf_runechat_msg)
	for(var/mob/M in (get_hearers_in_view(hearing_distance, src) - ignored_mobs))

		if((M.sdisabilities & DEAF || M.ear_deaf) && deaf_runechat_msg)
			M.show_runechat_message(src, null, deaf_runechat_msg, null, SHOWMSG_VISUAL)
		else
			if(runechat_msg)
				M.show_runechat_message(src, null, runechat_msg, null, SHOWMSG_VISUAL)

		if(self_message && M == src)
			to_chat(M, self_message)
			continue

		var/turf/T = get_turf(M)
		if (T.sound_coefficient == 0.0)
			M.show_message(deaf_message, SHOWMSG_VISUAL)
		else
			M.show_message(message, SHOWMSG_AUDIO, deaf_message, SHOWMSG_VISUAL)

// Show a message to all mobs in earshot of this atom
// Use for objects performing audible actions
// message is the message output to anyone who can hear.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/atom/proc/audible_message(message, deaf_message, hearing_distance = world.view, list/ignored_mobs, runechat_msg, deaf_runechat_msg)
	for(var/mob/M in (get_hearers_in_view(hearing_distance, src) - ignored_mobs))
		M.show_message(message, SHOWMSG_AUDIO, deaf_message, SHOWMSG_VISUAL)

		if((M.sdisabilities & DEAF || M.ear_deaf) && deaf_runechat_msg)
			M.show_runechat_message(src, null, deaf_runechat_msg, null, SHOWMSG_VISUAL)
		else
			if(runechat_msg)
				M.show_runechat_message(src, null, runechat_msg, null, SHOWMSG_VISUAL)

/mob/proc/findname(msg)
	for(var/mob/M as anything in mob_list)
		if(M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
	set waitfor = 0
	return

/mob/proc/incapacitated(restrained_type = ARMS)
	return FALSE

/mob/proc/restrained()
	return

/mob/proc/reset_view(atom/A, force_remote_viewing)
	if(client)
		if(isatom(A))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if(isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return

/mob/proc/show_inv(mob/user)
	return

/mob/proc/ret_grab(obj/effect/list_container/mobl/L, flag)
	var/list/grabs = GetGrabs()
	if(!length(grabs))
		if(!L)
			return null
		else
			return L.container
	else
		if(!L)
			L = new /obj/effect/list_container/mobl(null)
			L.container += src
			L.master = src
		for(var/obj/item/weapon/grab/G in grabs)
			if(!L.container.Find(G.affecting))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if(!flag)
			if(L.master == src)
				var/list/temp = list(  )
				temp += L.container
				//L = null
				qdel(L)
				return temp
			else
				return L.container
	return

/mob/verb/mode()
	set name = "Click On Held Object"
	set category = "IC"

	var/obj/item/W = get_active_hand()
	if(!W)
		return

	ClickOn(W)

/mob/verb/click_on_self()
	set name = "Click On Self"
	set category = "IC"

	ClickOn(usr)

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = replacetext(sanitize(msg, extra = FALSE), "\n", "<br>")

	if(msg && mind)
		mind.store_memory(msg)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		to_chat(usr, "No.")
	var/msg = sanitize(input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",input_default(flavor_text)) as message|null)

	if(msg)
		flavor_text = msg

/mob/proc/print_flavor_text()
	if(flavor_text && flavor_text != "")
		var/msg = flavor_text
		if(length_char(msg) <= 40)
			return "<span class='notice'>[msg]</span>"
		else
			return "<span class='notice'>[copytext_char(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a></span>"

//mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/A as mob|obj|turf in view())
	set name = "Examine"
	set category = "IC"

	if((sdisabilities & BLIND || blinded) && !in_range(A, usr) || stat == UNCONSCIOUS)
		to_chat(usr, "<span class='notice'>Something is there but you can't see it.</span>")
		return

	face_atom(A)
	A.examine(src)
	SEND_SIGNAL(A, COMSIG_PARENT_POST_EXAMINE, src)
	SEND_SIGNAL(src, COMSIG_PARENT_POST_EXAMINATE, A)
	if(!show_examine_log)
		return
	var/mob/living/carbon/human/H = src
	if(ishuman(src))
		if(H.head && H.head.flags_inv && HIDEEYES)
			return
		if(H.wear_mask && H.wear_mask.flags_inv && HIDEEYES)
			return
	if(!A.z) //no message if we examine something in a backpack
		return
	if(stat == CONSCIOUS)
		last_examined = A.name
	visible_message("<span class='small'><b>[src]</b> looks at <b>[A]</b>.</span>")

/mob/verb/pointed(atom/A as mob|obj|turf in view())
	set name = "Point To"
	set category = "Object"

	if(istype(A, /obj/effect/decal/point))
		return FALSE

	if(!can_point)
		return FALSE
	// Removes an ability to point to the object which is out of our sight.
	// Mostly for cases when we have mesons, thermals etc. equipped.
	if(client && !(A in view(client.view, src)))
		return FALSE

	point_at(A)

	// TODO: replace with a "COMSIG_MOB_POINTED" signal
	if (isliving(A))
		for (var/mob/living/carbon/slime/S in oview())
			if (usr in S.Friends)
				S.last_pointed = A

	return TRUE

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if(!abandon_allowed)
		to_chat(usr, "<span class='notice'>Respawn is disabled.</span>")
		return
	if(stat != DEAD || !SSticker)
		to_chat(usr, "<span class='notice'><B>You must be dead to use this!</B></span>")
		return
	else
		var/deathtime = world.time - src.timeofdeath
		if(isobserver(src))
			var/mob/dead/observer/G = src
			if(G.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
				to_chat(usr, "<span class='notice'><B>Upon using the antagHUD you forfeighted the ability to join the round.</B></span>")
				return
		var/deathtimeminutes = round(deathtime / 600)
		var/pluralcheck = "minute"
		if(deathtimeminutes == 0)
			pluralcheck = ""
		else if(deathtimeminutes == 1)
			pluralcheck = " [deathtimeminutes] minute and"
		else if(deathtimeminutes > 1)
			pluralcheck = " [deathtimeminutes] minutes and"
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10, 1)

		if(deathtime < config.deathtime_required && !(client.holder && (client.holder.rights & R_ADMIN)))	//Holders with R_ADMIN can give themselvs respawn, so it doesn't matter
			to_chat(usr, "You have been dead for[pluralcheck] [deathtimeseconds] seconds.")
			to_chat(usr, "You must wait 30 minutes to respawn!")
			return
		else
			to_chat(usr, "You can respawn now, enjoy your new life!")

	log_game("[key_name(usr)] used abandon mob.")

	to_chat(usr, "<span class='notice'><B>Make sure to play a different character, and please roleplay correctly!</B></span>")

	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		return
	client.screen.Cut()
	client.screen += client.void
	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		return

	var/mob/dead/new_player/M = new /mob/dead/new_player()
	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		qdel(M)
		return

	// New life, new quality.
	client.prefs.selected_quality_name = null

	M.key = key
	M.name = M.key
//	M.Login()	//wat
	return

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_view(null)
	unset_machine()
	if(isliving(src))
		var/mob/living/M = src
		if(M.cameraFollow)
			M.cameraFollow = null

//suppress the .click/dblclick macros so people can't use them to identify the location of items or aimbot
/mob/verb/DisClick(argu = null as anything, sec = "" as text, number1 = 0 as num, number2 = 0 as num)
	set name = ".click"
	set hidden = TRUE
	set category = null
	return

/mob/verb/DisDblClick(argu = null as anything, sec = "" as text, number1 = 0 as num, number2 = 0 as num)
	set name = ".dblclick"
	set hidden = TRUE
	set category = null
	return

/mob/Topic(href, href_list)
	if (href_list["refresh"])
		if(machine && in_range(src, usr)) // ? i'm sure changing this to Adjacent() will bug something
			show_inv(machine)

	if(href_list["flavor_more"])
		var/datum/browser/popup = new(usr, "window=flavor [name]", "Flavor [name]", 500, 200, ntheme = CSS_THEME_LIGHT)
		popup.set_content(flavor_text)
		popup.open()
	return


/mob/proc/pull_damage()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if((H.health - H.halloss) <= config.health_threshold_softcrit)
			for(var/bodypart_name in H.bodyparts_by_name)
				var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart_name]
				if(H.lying)
					if((((BP.status & ORGAN_BROKEN) && !(BP.status & ORGAN_SPLINTED)) || (BP.status & ORGAN_BLEEDING)) && ((H.getBruteLoss() + H.getFireLoss()) >= 100))
						return 1
		return 0

/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr)
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(isAI(M))
		return
	show_inv(usr)

//this and stop_pulling really ought to be /mob/living procs
/mob/proc/start_pulling(atom/movable/AM)
	if(!AM.can_be_pulled || src == AM || !isturf(AM.loc))	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return
	if(!AM.anchored)
		if(ismob(AM))
			var/mob/M = AM
			if(get_size_ratio(M, src) > pull_size_ratio)
				to_chat(src, "<span class=warning>You are too small in comparison to [M] to pull them!</span>")
				return
			if(M.buckled) // If we are trying to pull something that is buckled we will pull the thing its buckled to
				start_pulling(M.buckled)
				return

		AM.add_fingerprint(src)

		// If we're pulling something then drop what we're currently pulling and pull this instead.
		if(pulling)
			// Are we trying to pull something we are already pulling? Then just stop here, no need to continue.
			if(AM == pulling)
				return
			stop_pulling()

		if(SEND_SIGNAL(src, COMSIG_LIVING_START_PULL, AM) & COMPONENT_PREVENT_PULL)
			return
		if(SEND_SIGNAL(AM, COMSIG_ATOM_START_PULL, src) & COMPONENT_PREVENT_PULL)
			return

		src.pulling = AM
		AM.pulledby = src
		if(pullin)
			pullin.update_icon(src)
		if(ismob(AM))
			var/mob/M = AM
			if(!iscarbon(src))
				M.LAssailant = null
			else
				M.LAssailant = usr

		src.pulling = AM
		AM.pulledby = src

		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.pull_damage())
				to_chat(src, "<span class='danger'>Pulling \the [H] in their current condition would probably be a bad idea.</span>")

/mob/verb/stop_pulling()
	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		SEND_SIGNAL(src, COMSIG_LIVING_STOP_PULL, pulling)
		SEND_SIGNAL(pulling, COMSIG_ATOM_STOP_PULL, src)

		// What if the signals above somehow deleted pulledby?
		if(pulling)
			pulling.pulledby = null
			pulling = null
		if(pullin)
			pullin.update_icon(src)

/mob/proc/count_pull_debuff()
	return 0

/mob/proc/can_use_hands()
	return

/mob/proc/is_active()
	return (usr.stat <= CONSCIOUS)

/mob/proc/is_dead()
	return stat == DEAD

/mob/proc/is_mechanical()
	if(mind && (mind.assigned_role == "Cyborg" || mind.assigned_role == "AI"))
		return 1
	return issilicon(src) || get_species() == IPC

/mob/proc/is_ready()
	return client && !!mind

/mob/proc/get_gender()
	return gender

/mob/proc/see(message)
	if(!is_active())
		return 0
	to_chat(src, message)
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/*
adds a dizziness amount to a mob
use this rather than directly changing var/dizziness
since this ensures that the dizzy_process proc is started
currently only humans get dizzy

value of dizziness ranges from 0 to 1000
below 100 is not dizzy
*/
/mob/proc/make_dizzy(amount)
	return

/*
dizzy process - wiggles the client's pixel offset over time
spawned from make_dizzy(), will terminate automatically when dizziness gets <100
note dizziness decrements automatically in the mob's Life() proc.
*/
/mob/proc/dizzy_process()
	is_dizzy = TRUE
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = FALSE
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0

// jitteriness - copy+paste of dizziness

/mob/proc/make_jittery(amount)
	return

// Typo from the oriignal coder here, below lies the jitteriness process. So make of his code what you will, the previous comment here was just a copypaste of the above.
/mob/proc/jittery_process()
	is_jittery = TRUE
	while(jitteriness > 30)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 30)
		pixel_x = rand(-amplitude, amplitude)
		pixel_y = rand(-amplitude/3, amplitude/3)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_jittery = FALSE
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)

/mob/Stat()
	..()

	if(statpanel("Status"))
		if(global.round_id)
			stat(null, "Round ID: #[global.round_id]")
		stat(null, "Server Time: [time2text(world.realtime, "YYYY-MM-DD hh:mm")]")
		if(client)
			stat(null, "Your in-game age: [isnum(client.player_ingame_age) ? client.player_ingame_age : 0]")
			stat(null, "Map: [SSmapping.config?.map_name || "Loading..."]")
			var/datum/map_config/cached = SSmapping.next_map_config
			if(cached)
				stat(null, "Next Map: [cached.map_name]")
			if(client.holder)
				if (config.registration_panic_bunker_age)
					stat(null, "Registration panic bunker age: [config.registration_panic_bunker_age]")
				var/datum/faction/malf_silicons/GM = find_faction_by_type(/datum/faction/malf_silicons)
				if(GM?.malf_mode_declared)
					stat(null, "Time left: [max(GM.AI_win_timeleft / (SSticker.hacked_apcs / APC_MIN_TO_MALF_DECLARE), 0)]")
				if(SSshuttle.online && SSshuttle.location < 2)
					stat(null, "ETA-[shuttleeta2text()]")

			if(SSmapping.loaded_map_module)
				SSmapping.loaded_map_module.stat_entry(src)

	if(client && client.holder)
		if(statpanel("Tickets"))
			global.ahelp_tickets.stat_entry()
		if(client.holder.rights & R_ADMIN)
			if(statpanel("MC"))
				stat("CPU:", "[world.cpu]")
				if(client.holder.rights & R_DEBUG)
					stat("Location:", "[COORD(src)]")
					stat("Instances:", "[world.contents.len]")
					config.stat_entry()
					stat(null)
					if(Master)
						Master.stat_entry()
					else
						stat("Master Controller:", "ERROR")
					if(Failsafe)
						Failsafe.stat_entry()
					else
						stat("Failsafe Controller:", "ERROR")
					if(Master)
						stat(null)
						for(var/datum/controller/subsystem/SS in Master.subsystems)
							if(SS.flags & SS_SHOW_IN_MC_TAB)
								SS.stat_entry()
					cameranet.stat_entry()

	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			statpanel(listed_turf.name, null, listed_turf)
			for(var/atom/A in listed_turf)
				if(!A.mouse_opacity)
					continue
				if(A.invisibility > see_invisible)
					continue
				if(is_type_in_list(A, shouldnt_see))
					continue
				statpanel(listed_turf.name, null, A)

	if(spell_list.len)
		for(var/obj/effect/proc_holder/spell/S in spell_list)
			switch(S.charge_type)
				if("recharge")
					statpanel(S.panel,"[S.charge_counter/10.0]/[S.charge_max/10]",S)
				if("charges")
					statpanel(S.panel,"[S.charge_counter]/[S.charge_max]",S)
				if("holdervar")
					statpanel(S.panel,"[S.holder_var_type] [S.holder_var_amount]",S)

// facing verbs
/mob/proc/canface()
	if(!canmove)						return 0
	if(client.moving)					return 0
	if(world.time < client.move_delay)	return 0
	if(stat==DEAD)						return 0
	if(anchored)						return 0
	if(notransform)						return 0
	if(restrained())					return 0
	return 1

// Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
// We need speed out of this proc, thats why using incapacitated() helper here is a bad idea.
/mob/proc/update_canmove(no_transform = FALSE)

	var/ko = paralysis || stat || (status_flags & FAKEDEATH)

	anchored = HAS_TRAIT(src, TRAIT_ANCHORED)
	lying = (ko || weakened || crawling) && !anchored
	canmove = !(ko || anchored || HAS_TRAIT(src, TRAIT_IMMOBILIZED))

	if(buckled)
		if(buckled.buckle_lying != -1)
			lying = buckled.buckle_lying
		canmove = canmove && buckled.buckle_movable
		anchored = anchored || !buckled.buckle_movable

		if(istype(buckled, /obj/vehicle))
			var/obj/vehicle/V = buckled
			if(!canmove)
				V.unload(src)
			else
				pixel_y = V.mob_offset_y

	density = !lying

	if(lying != was_lying)
		if(lying)
			SEND_SIGNAL(src, COMSIG_MOB_STATUS_LYING)
		else
			SEND_SIGNAL(src, COMSIG_MOB_STATUS_NOT_LYING)
		was_lying = lying


	for(var/obj/item/weapon/grab/G in grabbed_by)
		if(G.state >= GRAB_AGGRESSIVE)
			canmove = FALSE
			if(G.state == GRAB_NECK && G.assailant.get_targetzone() == BP_CHEST)
				lying = FALSE
				density = TRUE
			break

	//Temporarily moved here from the various life() procs
	//I'm fixing stuff incrementally so this will likely find a better home.
	//It just makes sense for now. ~Carn

	if(!no_transform && lying != lying_prev)
		update_transform()
	if(update_icon)	//forces a full overlay update
		update_icon = FALSE
		regenerate_icons()


/mob/proc/facedir(ndir)
	if(!canface())
		return 0
	set_dir(ndir)
	if(buckled && buckled.buckle_movable)
		buckled.set_dir(ndir)
		buckled.handle_rotation()
	client.move_delay += movement_delay()
	return 1


/mob/verb/eastface()
	set hidden = 1
	return facedir(EAST)


/mob/verb/westface()
	set hidden = 1
	return facedir(WEST)


/mob/verb/northface()
	set hidden = 1
	return facedir(NORTH)


/mob/verb/southface()
	set hidden = 1
	return facedir(SOUTH)


/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return 0

// ======STATUS_FLAGS=======
/mob/proc/remove_status_flags(remove_flags)
	if(remove_flags & CANSTUN)
		SetStunned(0, TRUE)
	if(remove_flags & CANWEAKEN)
		SetWeakened(0, TRUE)
	if(remove_flags & CANPARALYSE)
		SetParalysis(0, TRUE)
	status_flags &= ~remove_flags
	if(remove_flags & (CANSTUN|CANPARALYSE|CANWEAKEN|FAKEDEATH))
		update_canmove()

/mob/proc/add_status_flags(add_flags)
	if(add_flags & GODMODE)
		stuttering = 0
	if(add_flags & FAKEDEATH)
		update_canmove()
	status_flags |= add_flags

// ========== CRAWLING ==========
/mob/proc/SetCrawling(value)
	crawling = value
	if(value)
		pass_flags |= PASSCRAWL
	else
		pass_flags &= ~PASSCRAWL
// ========== DRUGGINESS ==========
/mob/proc/adjustDrugginess(amount)
	druggy = max(druggy + amount, 0)
	updateDrugginesOverlay()

/mob/proc/setDrugginess(amount)
	druggy = max(amount, 0)
	updateDrugginesOverlay()

/mob/proc/updateDrugginesOverlay()
	if(druggy && get_species(src) != SKRELL)
		overlay_fullscreen("high", /atom/movable/screen/fullscreen/high)
		throw_alert("high", /atom/movable/screen/alert/high)
	else
		clear_fullscreen("high")
		clear_alert("high")

// ========== STUTTERING ==========
/mob/proc/Stuttering(amount)
	if(status_flags & GODMODE)
		return
	stuttering = max(stuttering, amount, 0)

/mob/proc/AdjustStuttering(amount)
	if(status_flags & GODMODE)
		return
	stuttering = max(stuttering + amount, 0)

/mob/proc/setStuttering(amount)
	if(status_flags & GODMODE)
		return
	stuttering = max(amount, 0)

//========== Shock Stage =========
/mob/proc/AdjustShockStage(amount)
	return

/mob/proc/SetShockStage(amount)
	return

//======= Bodytemperature =======
/mob/proc/adjust_bodytemperature(amount, min_temp=0, max_temp=INFINITY)
	if(amount > 0)
		if(bodytemperature < max_temp)
			bodytemperature = min(max_temp, bodytemperature + amount)
	else
		if(bodytemperature > min_temp)
			bodytemperature = max(min_temp, bodytemperature + amount)

// =============================

/mob/proc/get_species()
	return ""

/mob/proc/get_visible_implants(class = 0)
	var/list/visible_implants = list()
	for(var/obj/item/O in embedded)
		if(O.w_class > class)
			visible_implants += O
	return visible_implants

/mob/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.next_move = world.time + 20

	if(usr.incapacitated())
		to_chat(usr, "You can not do this while being incapacitated!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/list/valid_objects
	var/self = S == U // Removing object from yourself.

	valid_objects = get_visible_implants(1)
	if(!valid_objects.len)
		if(self)
			to_chat(src, "You have nothing stuck in your body that is large enough to remove.")
		else
			to_chat(U, "[src] has nothing stuck in their wounds that is large enough to remove.")
		return

	var/obj/item/weapon/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	if(self)
		to_chat(src, "<span class='warning'>You attempt to get a good grip on the [selection] in your body.</span>")
	else
		to_chat(U, "<span class='warning'>You attempt to get a good grip on the [selection] in [S]'s body.</span>")

	if(!do_skilled(U, S, SKILL_TASK_DIFFICULT, list(/datum/skill/medical = SKILL_LEVEL_TRAINED), -0.2))
		return
	if(QDELETED(S) || QDELETED(U) || selection.loc != S)
		return

	if(self)
		visible_message("<span class='warning'><b>[src] rips [selection] out of their body.</b></span>","<span class='warning'><b>You rip [selection] out of your body.</b></span>")
	else
		visible_message("<span class='warning'><b>[usr] rips [selection] out of [src]'s body.</b></span>","<span class='warning'><b>[usr] rips [selection] out of your body.</b></span>")

	embedded -= selection

	if(ishuman(src))

		var/mob/living/carbon/human/H = src
		var/obj/item/organ/external/BP

		for(var/obj/item/organ/external/limb in H.bodyparts) //Grab the organ holding the implant.
			if(selection in limb.implants)
				BP = limb
				break

		BP.implants -= selection
		H.sec_hud_set_implants()
		for(var/datum/wound/wound in BP.wounds)
			wound.embedded_objects -= selection

		H.AdjustShockStage(20)
		BP.take_damage((selection.w_class * 3), null, DAM_EDGE, "Embedded object extraction")

		if(prob(selection.w_class * 5) && BP.sever_artery()) // I'M SO ANEMIC I COULD JUST -DIE-.
			H.custom_pain("Something tears wetly in your [BP.name] as [selection] is pulled free!", 1)

		if(ishuman(U))
			var/mob/living/carbon/human/human_user = U
			human_user.bloody_hands(H)

	selection.forceMove(get_turf(S))

	valid_objects = get_visible_implants(1)
	if(!valid_objects.len) //Yanked out last object - removing verb.
		src.verbs -= /mob/proc/yank_out_object
		clear_alert("embeddedobject")

///Get the ghost of this mob (from the mind)
/mob/proc/get_ghost(even_if_they_cant_reenter, ghosts_with_clients)
	if(mind)
		return mind.get_ghost(even_if_they_cant_reenter, ghosts_with_clients)

/mob/proc/GetSpell(spell_type)
	for(var/obj/effect/proc_holder/spell/spell in spell_list)
		if(spell.type == spell_type)
			return spell

	if(mind)
		for(var/obj/effect/proc_holder/spell/spell in mind.spell_list)
			if(spell.type == spell_type)
				return spell
	return FALSE

/mob/proc/AddSpell(obj/effect/proc_holder/spell/spell)
	spell_list += spell
	if(mind)
		mind.spell_list += spell	//Connect spell to the mind for transfering action buttons between mobs
	if(!spell.action)
		spell.action = new/datum/action/spell_action
		spell.action.target = spell
		spell.action.name = spell.name
		spell.action.button_icon = spell.action_icon
		spell.action.button_icon_state = spell.action_icon_state
		spell.action.background_icon_state = spell.action_background_icon_state
	if(isliving(src))
		spell.action.Grant(src)
	return

/mob/proc/RemoveSpell(obj/effect/proc_holder/spell/S)
	spell_list -= S
	if(mind)
		mind.spell_list -= S
		if(isliving(mind.current))
			var/mob/living/L = mind.current
			if(S.action)
				S.action.Remove(L)
	qdel(S)

/mob/proc/ClearSpells()
	for(var/spell in spell_list)
		spell_list -= spell
		qdel(spell)

	if(mind)
		for(var/obj/effect/proc_holder/spell/S in mind.spell_list)
			mind.spell_list -= S
			if(isliving(mind.current))
				var/mob/living/L = mind.current
				if(S.action)
					S.action.Remove(L)
			qdel(S)

/mob/proc/set_EyesVision(preset = null, transition_time = 5)
	if(!client) return
	if(preset)
		var/datum/ColorMatrix/CM = new(preset)
		animate(client, color = CM.matrix, time = transition_time)
	else
		animate(client, color = null, time = transition_time)

/mob/proc/instant_vision_update(state=null, atom/A)
	if(!client || isnull(state))
		return

	switch(state)
		if(0)
			if(!blinded)
				clear_fullscreen("blind", 0)
			client.eye = client.mob
			client.perspective = MOB_PERSPECTIVE
		if(1)
			if(XRAY in mutations)
				return
			else
				overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
				if(A)
					client.perspective = EYE_PERSPECTIVE
				client.eye = A

//You can buckle on mobs if you're next to them since most are dense
/mob/buckle_mob(mob/living/M)
	if(M.buckled)
		return FALSE
	var/turf/T = get_turf(src)
	if(M.loc != T)
		var/old_density = density
		density = FALSE
		var/can_step = step_towards(M, T)
		density = old_density
		if(!can_step)
			return FALSE
	return ..()

//Default buckling shift visual for mobs
/mob/post_buckle_mob(mob/living/M)
	if(M == buckled_mob) //post buckling
		M.pixel_y = initial(M.pixel_y) + 9
		if(M.layer < layer)
			M.layer = layer + 0.1
	else //post unbuckling
		M.layer = M.default_layer
		M.pixel_y = M.default_pixel_y

/mob/proc/can_unbuckle(mob/user)
	return TRUE

/mob/proc/get_targetzone()
	return null

/mob/proc/update_stat()
	return

/mob/proc/can_pickup(obj/O)
	return Adjacent(O)

/atom/movable/proc/is_facehuggable()
	return FALSE

// Return null if mob of this type can not scramble messages.
/mob/proc/get_scrambled_message(message, datum/language/speaking = null)
	return speaking ? speaking.scramble(message) : stars(message)

/**
  * Prepare the huds for this atom
  *
  * Goes through hud_possible list and adds the images to the hud_list variable (if not already
  * cached)
  */
/atom/proc/prepare_huds()
	if(hud_list || !hud_possible)
		return

	hud_list = list()
	for(var/hud in hud_possible)
		var/hint = hud_possible[hud]
		switch(hint)
			if(HUD_LIST_LIST)
				hud_list[hud] = list()
			else
				var/image/I = image('icons/hud/hud.dmi', src, "")
				I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
				hud_list[hud] = I

/mob/keybind_face_direction(direction)
	facedir(direction)

///Spin this mob around it's central axis
/mob/proc/spin(spintime, speed)
	set waitfor = 0
	var/D = dir
	if((spintime < 1) || (speed < 1) || !spintime|| !speed)
		return

	flags |= IS_SPINNING
	while(spintime >= speed)
		sleep(speed)
		switch(D)
			if(NORTH)
				D = EAST
			if(SOUTH)
				D = WEST
			if(EAST)
				D = SOUTH
			if(WEST)
				D = NORTH
		set_dir(D)
		spintime -= speed
	flags &= ~IS_SPINNING

/mob/proc/in_interaction_vicinity(atom/target)
	return Adjacent(target)

/mob/proc/confuse_input(dir)
	return input_offsets["[dir]"]

/mob/proc/randomise_inputs()
	if(!confused)
		return
	if(next_randomise_inputs > world.time)
		return

	next_randomise_inputs = world.time + randomise_inputs_cooldown

	input_offsets = list()
	var/list/pos_dirs = list() + cardinal

	for(var/d in cardinal)
		var/map_to = pick(pos_dirs)
		input_offsets["[d]"] = map_to
		pos_dirs -= map_to

	addtimer(CALLBACK(src, PROC_REF(randomise_inputs)), randomise_inputs_cooldown)

/mob/proc/AdjustConfused(amount)
	confused += amount
	if(confused < 0)
		confused = 0

	if(confused > 0)
		randomise_inputs()
	else
		input_offsets = null
		next_randomise_inputs = world.time

/mob/proc/SetConfused(value)
	confused = value

	if(confused > 0)
		randomise_inputs()
	else
		input_offsets = null
		next_randomise_inputs = world.time

/mob/proc/MakeConfused(value)
	confused = max(value, confused)

	if(confused > 0)
		randomise_inputs()
	else
		input_offsets = null
		next_randomise_inputs = world.time

/mob/proc/parse_language(message)
	if(forced_language)
		return list(message, all_languages[forced_language])

	var/datum/language/speaking = parse_language_code(message)
	if(speaking)
		var/new_msg = copytext_char(message, 2 + length_char(speaking.key))
		return list(new_msg, speaking)

	if(default_language)
		return list(message, all_languages[default_language])

	var/datum/species/S = all_species[get_species()]
	if(S && S.species_common_language)
		return list(message, all_languages[S.language])

	if(common_language)
		return list(message, all_languages[common_language])

	return list(message, null)

/mob/proc/set_lastattacker_info(mob/M)
	lastattacker_name = M.real_name
	lastattacker_key = M.key

/mob/proc/m_intent_delay()
	. = 0
	switch(m_intent)
		if("run")
			if(drowsyness > 0)
				. += 6
			. += config.run_speed
		if("walk")
			. += config.walk_speed

// return TRUE if we failed our interaction
/mob/proc/interact_prob_brain_damage(atom/object)
	return FALSE
