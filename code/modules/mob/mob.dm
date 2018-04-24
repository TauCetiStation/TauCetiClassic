/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	mob_list -= src
	dead_mob_list -= src
	living_mob_list -= src
	ghostize(bancheck = TRUE)
	return ..()

/mob/atom_init()
	spawn()
		if(client) animate(client, color = null, time = 0)
	mob_list += src
	if(stat == DEAD)
		dead_mob_list += src
	else
		living_mob_list += src
	. = ..()

/mob/proc/Cell()
	set category = "Admin"
	set hidden = TRUE

	if(!isturf(loc))
		return 0

	var/turf/T = loc

	var/datum/gas_mixture/env = T.return_air()

	var/t = "<span class='notice'>Coordinates: [T.x],[T.y],[T.z]</span>\n"
	t += "<span class='warning'>Temperature: [env.temperature]</span>\n"
	t += "<span class='warning'>Pressure: [env.return_pressure()]kPa</span>\n"
	for(var/g in env.gas)
		t += "<span class='notice'>[g]: [env.gas[g]] / [env.gas[g] * R_IDEAL_GAS_EQUATION * env.temperature / env.volume]kPa</span>\n"

	usr.show_message(t, 1)

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)

	if(!client)
		return FALSE

	if(type)
		if((type & 1) && ((sdisabilities & BLIND) || blinded || paralysis) )//Vision related
			if(!alt)
				return FALSE
			else
				msg = alt
				type = alt_type
		if((type & 2) && ((sdisabilities & DEAF) || ear_deaf))//Hearing related
			if (!alt)
				return FALSE
			else
				msg = alt
				type = alt_type
				if (((type & 1) && (sdisabilities & BLIND)))
					return FALSE
	// Added voice muffling for Issue 41.
	if(stat == UNCONSCIOUS || sleeping > 0)
		msg = "<I>... You can almost hear someone talking ...</I>"
	to_chat(src, msg)
	return msg

/mob/living/carbon/show_message(msg, type, alt, alt_type)
	. = ..()
	if(. && length(parasites))
		for(var/M in parasites)
			to_chat(M, .)
// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(message, self_message, blind_message)
	for(var/mob/M in viewers(src))
		var/msg = message
		if(self_message && M == src)
			msg = self_message
		M.show_message(msg, 1, blind_message, 2)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(message, blind_message)
	for(var/mob/M in viewers(src))
		M.show_message(message, 1, blind_message, 2)

// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/mob/audible_message(message, deaf_message, hearing_distance, self_message)
	var/range = world.view
	if(hearing_distance)
		range = hearing_distance
	for(var/mob/M in get_hearers_in_view(range, src))
		var/msg = message
		if(self_message && M == src)
			msg = self_message
		M.show_message(msg, 2, deaf_message, 1)

// Show a message to all mobs in earshot of this atom
// Use for objects performing audible actions
// message is the message output to anyone who can hear.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/atom/proc/audible_message(message, deaf_message, hearing_distance)
	var/range = world.view
	if(hearing_distance)
		range = hearing_distance
	for(var/mob/M in get_hearers_in_view(range, src))
		M.show_message(message, 2, deaf_message, 1)

/mob/proc/findname(msg)
	for(var/mob/M in mob_list)
		if(M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
	set waitfor = 0
	return

/mob/proc/incapacitated(restrained_type = ARMS)
	return

/mob/proc/restrained()
	return

/mob/proc/reset_view(atom/A)
	if(client)
		if(istype(A, /atom/movable))
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
	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand&&!(l_hand.flags&ABSTRACT)) 	? l_hand	: "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand&&!(r_hand.flags&ABSTRACT))		? r_hand	: "Nothing"]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(entity_ja(dat), text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return

/mob/proc/ret_grab(obj/effect/list_container/mobl/L, flag)
	if(!(istype(l_hand, /obj/item/weapon/grab) || istype(r_hand, /obj/item/weapon/grab)))
		if(!L)
			return null
		else
			return L.container
	else
		if(!L)
			L = new /obj/effect/list_container/mobl(null)
			L.container += src
			L.master = src
		if(istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if(!L.container.Find(G.affecting))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if(istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
			if(!L.container.Find(G.affecting))
				L.container += G.affecting
				if(G.affecting)
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
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(istype(loc,/obj/mecha))
		return

	if(hand)
		var/obj/item/W = l_hand
		if(W)
			W.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/W = r_hand
		if(W)
			W.attack_self(src)
			update_inv_r_hand()
	if(next_move < world.time)
		next_move = world.time + 2
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

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

	msg = sanitize(msg)

	if(msg && mind)
		mind.store_memory(msg)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/proc/store_memory(msg, popup)
	msg = sanitize(msg)

	if(length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if(popup)
		memory()

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		to_chat(usr, "No.")
	var/msg = sanitize(input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",input_default(flavor_text)) as message|null)

	if(msg)
		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text && flavor_text != "") // don't spam people that don't use it!
		to_chat(src, "<h2 class='alert'>OOC Warning:</h2>")
		to_chat(src, "<span class='alert'>Your flavor text is likely out of date! <a href='byond://?src=\ref[src];flavor_change=1'>Change</a></span>")

/mob/proc/print_flavor_text()
	if(flavor_text && flavor_text != "")
		var/msg = flavor_text
		if(lentext(msg) <= 40)
			return "\blue [msg]"
		else
			return "\blue [copytext(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a>"

//mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/A as mob|obj|turf in view())
	set name = "Examine"
	set category = "IC"

	if(sdisabilities & BLIND || blinded || stat == UNCONSCIOUS)
		to_chat(usr, "<span class='notice'>Something is there but you can't see it.</span>")
		return

	face_atom(A)
	A.examine(src)

/mob/verb/pointed(atom/A as mob|obj|turf in oview())
	set name = "Point To"
	set category = "Object"

	if(!usr || !isturf(usr.loc))
		return
	if(usr.stat || usr.restrained())
		return
	if(usr.status_flags & FAKEDEATH)
		return
	if(!(A in oview(usr.loc)))
		return
	if(istype(A, /obj/effect/decal/point))
		return

	var/tile = get_turf(A)
	if(!tile)
		return

	var/obj/P = new /obj/effect/decal/point(tile)
	P.pixel_x = A.pixel_x
	P.pixel_y = A.pixel_y

	QDEL_IN(P, 20)

	usr.visible_message("<span class='notice'><b>[usr]</b> points to [A].</span>")

	if(isliving(A))
		for(var/mob/living/carbon/slime/S in oview())
			if(usr in S.Friends)
				S.last_pointed = A

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if(!abandon_allowed)
		to_chat(usr, "\blue Respawn is disabled.")
		return
	if(stat != DEAD || !ticker)
		to_chat(usr, "\blue <B>You must be dead to use this!</B>")
		return
	if(ticker && istype(ticker.mode, /datum/game_mode/meteor))
		to_chat(usr, "\blue Respawn is disabled for this roundtype.")
		return
	else
		var/deathtime = world.time - src.timeofdeath
		if(istype(src,/mob/dead/observer))
			var/mob/dead/observer/G = src
			if(G.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
				to_chat(usr, "\blue <B>Upon using the antagHUD you forfeighted the ability to join the round.</B>")
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

	log_game("[usr.name]/[usr.key] used abandon mob.")

	to_chat(usr, "\blue <B>Make sure to play a different character, and please roleplay correctly!</B>")

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	client.screen.Cut()
	client.screen += client.void
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/dead/new_player/M = new /mob/dead/new_player()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		qdel(M)
		return

	M.key = key
//	M.Login()	//wat
	return

/mob/verb/observe()
	set name = "Observe"
	set category = "OOC"
	var/is_admin = FALSE

	if(client.holder && (client.holder.rights & R_ADMIN))
		is_admin = TRUE
	else if(stat != DEAD || isnewplayer(src) || jobban_isbanned(src, "Observer"))
		to_chat(usr, "\blue You must be observing to use this!")
		return

	if(is_admin && stat == DEAD)
		is_admin = FALSE

	var/list/creatures = getpois()

	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	var/ok = "[is_admin ? "Admin Observe" : "Observe"]"
	eye_name = input("Please, select a player!", ok, null, null) as null|anything in creatures

	if(!eye_name)
		return

	var/mob/mob_eye = creatures[eye_name]

	if(client && mob_eye)
		client.eye = mob_eye
		if(is_admin)
			client.adminobs = 1
			if(mob_eye == client.mob || client.eye == client.mob)
				client.adminobs = 0

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_view(null)
	unset_machine()
	if(istype(src, /mob/living))
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
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	if(href_list["flavor_more"])
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", name, entity_ja(flavor_text)), text("window=[];size=500x200", name))

		onclose(usr, "[name]")
	if(href_list["flavor_change"])
		update_flavor_text()
//	..()
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
	if(!AM || !src || src == AM || !isturf(AM.loc))	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return
	if(!AM.anchored)
		AM.add_fingerprint(src)

		// If we're pulling something then drop what we're currently pulling and pull this instead.
		if(pulling)
			// Are we trying to pull something we are already pulling? Then just stop here, no need to continue.
			if(AM == pulling)
				return
			stop_pulling()

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

		count_pull_debuff()

/mob/verb/stop_pulling()
	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null
		if(pullin)
			pullin.update_icon(src)
		count_pull_debuff()

/mob/proc/count_pull_debuff()
	return

/mob/proc/can_use_hands()
	return

/mob/proc/is_active()
	return (usr.stat <= 0)

/mob/proc/is_dead()
	return stat == DEAD

/mob/proc/is_mechanical()
	if(mind && (mind.assigned_role == "Cyborg" || mind.assigned_role == "AI"))
		return 1
	return istype(src, /mob/living/silicon) || get_species() == IPC

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
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	dizziness = min(1000, dizziness + amount)	// store what will be new value
													// clamped to max 1000
	if(dizziness > 100 && !is_dizzy)
		spawn(0)
			dizzy_process()


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
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	jitteriness = min(1000, jitteriness + amount)	// store what will be new value
													// clamped to max 1000
	if(jitteriness > 100 && !is_jittery)
		spawn(0)
			jittery_process()


// Typo from the oriignal coder here, below lies the jitteriness process. So make of his code what you will, the previous comment here was just a copypaste of the above.
/mob/proc/jittery_process()
	is_jittery = TRUE
	while(jitteriness > 100)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 100)
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
		stat(null, "Server Time: [time2text(world.realtime, "YYYY-MM-DD hh:mm")]")
		if(client)
			stat(null, "Your in-game age: [client.player_ingame_age]")
			if(client.holder)
				if(ticker.mode && ticker.mode.config_tag == "malfunction")
					var/datum/game_mode/malfunction/GM = ticker.mode
					if(GM.malf_mode_declared)
						stat(null, "Time left: [max(GM.AI_win_timeleft / (GM.apcs / APC_MIN_TO_MALF_DECLARE), 0)]")
				if(SSshuttle.online && SSshuttle.location < 2)
					var/timeleft = SSshuttle.timeleft()
					if(timeleft)
						stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

	if(client && client.holder)
		if((client.holder.rights & R_ADMIN))
			if(statpanel("MC"))
				stat("CPU:", "[world.cpu]")
				if(client.holder.rights & R_DEBUG)
					stat("Location:", "([x], [y], [z])")
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
						for(var/datum/subsystem/SS in Master.subsystems)
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
	if(stat==2)							return 0
	if(anchored)						return 0
	if(monkeyizing)						return 0
	if(restrained())					return 0
	return 1

// Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
// We need speed out of this proc, thats why using incapacitated() helper here is a bad idea.
/mob/proc/update_canmove(no_transform = FALSE)

	var/ko = weakened || paralysis || stat || (status_flags & FAKEDEATH)

	lying = (ko || crawling || resting) && !captured && !buckled && !pinned.len
	canmove = !(ko || resting || stunned || captured || pinned.len)
	anchored = captured || pinned.len

	if(buckled)
		if(buckled.buckle_lying != -1)
			lying = buckled.buckle_lying
		canmove = canmove && buckled.buckle_movable
		anchored = anchored || buckled.buckle_movable

		if(istype(buckled, /obj/vehicle))
			var/obj/vehicle/V = buckled
			if(!canmove)
				V.unload(src)
			else
				pixel_y = V.mob_offset_y
		else
			if(istype(buckled, /obj/structure/stool/bed/chair))
				var/obj/structure/stool/bed/chair/C = buckled
				if(C.flipped)
					lying = 1

	density = !lying

	if(lying && ((l_hand && l_hand.canremove) || (r_hand && r_hand.canremove)) && !isalien(src))
		drop_l_hand()
		drop_r_hand()

	for(var/obj/item/weapon/grab/G in grabbed_by)
		if(G.state >= GRAB_AGGRESSIVE)
			canmove = FALSE
			if(G.state == GRAB_NECK && G.assailant.zone_sel.selecting == BP_CHEST)
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
	return canmove


/mob/proc/facedir(ndir)
	if(!canface())
		return 0
	dir = ndir
	if(buckled && buckled.buckle_movable)
		buckled.dir = ndir
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

// ========== STUN ==========
/mob/proc/Stun(amount, updating = 1, ignore_canstun = 0, lock = null)
	if(!isnull(lock))
		if(lock)
			status_flags |= LOCKSTUN
		else
			status_flags &= ~LOCKSTUN
	else if(status_flags & LOCKSTUN)
		return

	if(status_flags & CANSTUN || ignore_canstun)
		stunned = max(max(stunned, amount), 0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		if(updating)
			update_canmove()
	else
		stunned = 0

/mob/proc/SetStunned(amount, updating = 1, ignore_canstun = 0, lock = null) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(!isnull(lock))
		if(lock)
			status_flags |= LOCKSTUN
		else
			status_flags &= ~LOCKSTUN
	else if(status_flags & LOCKSTUN)
		return

	if(status_flags & CANSTUN || ignore_canstun)
		stunned = max(amount, 0)
		if(updating)
			update_canmove()
	else
		stunned = 0

/mob/proc/AdjustStunned(amount, updating = 1, ignore_canstun = 0, lock = null)
	if(!isnull(lock))
		if(lock)
			status_flags |= LOCKSTUN
		else
			status_flags &= ~LOCKSTUN
	else if(status_flags & LOCKSTUN)
		return

	if(status_flags & CANSTUN || ignore_canstun)
		stunned = max(stunned + amount, 0)
		if(updating)
			update_canmove()
	else
		stunned = 0

// ========== WEAKEN ==========
/mob/proc/Weaken(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(max(weakened, amount), 0)
		update_canmove() // updates lying, canmove and icons
	else
		weakened = 0

/mob/proc/SetWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(amount, 0)
		update_canmove()
	else
		weakened = 0

/mob/proc/AdjustWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(weakened + amount, 0)
		update_canmove()
	else
		weakened = 0

// ========== PARALYSE ==========
/mob/proc/Paralyse(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(max(paralysis, amount), 0)
	else
		paralysis = 0

/mob/proc/SetParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(amount, 0)
	else
		paralysis = 0

/mob/proc/AdjustParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(paralysis + amount, 0)
	else
		paralysis = 0

// ========== SLEEPING ==========
/mob/proc/Sleeping(amount)
	if(status_flags & CANPARALYSE) // because sleeping and paralysis are very similar statuses and i see no point in separate flags at this time (anyway, golems mostly).
		sleeping = max(max(sleeping, amount), 0)
	else
		sleeping = 0

/mob/proc/SetSleeping(amount)
	if(status_flags & CANPARALYSE)
		sleeping = max(amount, 0)
	else
		sleeping = 0

/mob/proc/AdjustSleeping(amount)
	if(status_flags & CANPARALYSE)
		sleeping = max(sleeping + amount, 0)
	else
		sleeping = 0

// ========== RESTING ==========
/mob/proc/Resting(amount)
	resting = max(max(resting, amount), 0)
	return

/mob/proc/SetResting(amount)
	resting = max(amount, 0)
	return

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount, 0)
	return

// =============================

/mob/proc/get_species()
	return ""

/mob/proc/flash_weak_pain()
	flick("weak_pain",pain)

/mob/proc/get_visible_implants(class = 0)
	var/list/visible_implants = list()
	for(var/obj/item/O in embedded)
		if(O.w_class > class)
			visible_implants += O
	return visible_implants

mob/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.next_move = world.time + 20

	if(usr.stat == UNCONSCIOUS)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/list/valid_objects = list()
	var/self = FALSE

	if(S == U)
		self = TRUE // Removing object from yourself.

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

	if(!do_after(U, 80, target = S))
		return
	if(!selection || !S || !U)
		return

	if(self)
		visible_message("<span class='warning'><b>[src] rips [selection] out of their body.</b></span>","<span class='warning'><b>You rip [selection] out of your body.</b></span>")
	else
		visible_message("<span class='warning'><b>[usr] rips [selection] out of [src]'s body.</b></span>","<span class='warning'><b>[usr] rips [selection] out of your body.</b></span>")
	valid_objects = get_visible_implants(0)
	if(valid_objects.len == 1) //Yanking out last object - removing verb.
		src.verbs -= /mob/proc/yank_out_object
		clear_alert("embeddedobject")

	if(istype(src, /mob/living/carbon/human))

		var/mob/living/carbon/human/H = src
		var/obj/item/organ/external/BP

		for(var/obj/item/organ/external/limb in H.bodyparts) //Grab the organ holding the implant.
			for(var/obj/item/weapon/O in limb.implants)
				if(O == selection)
					BP = limb

		BP.implants -= selection
		for(var/datum/wound/wound in BP.wounds)
			wound.embedded_objects -= selection

		H.shock_stage += 20
		BP.take_damage((selection.w_class * 3), null, DAM_EDGE, "Embedded object extraction")

		if(prob(selection.w_class * 5) && BP.sever_artery()) // I'M SO ANEMIC I COULD JUST -DIE-.
			H.custom_pain("Something tears wetly in your [BP.name] as [selection] is pulled free!", 1)

		if(ishuman(U))
			var/mob/living/carbon/human/human_user = U
			human_user.bloody_hands(H)

	selection.loc = get_turf(src)

	for(var/obj/item/weapon/O in pinned)
		if(O == selection)
			pinned -= O
		if(!pinned.len)
			anchored = 0
	return 1

/mob/proc/get_ghost(even_if_they_cant_reenter = 0)
	if(mind)
		for(var/mob/dead/observer/G in dead_mob_list)
			if(G.mind == mind)
				if(G.can_reenter_corpse || even_if_they_cant_reenter)
					return G
				break

/mob/proc/AddSpell(obj/effect/proc_holder/spell/spell)
	spell_list += spell
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

/mob/proc/set_EyesVision(preset = null, transition_time = 5)
	if(!client) return
	if(ishuman(src) && druggy)
		var/datum/ColorMatrix/DruggyMatrix = new(pick("bgr_d","brg_d","gbr_d","grb_d","rbg_d","rgb_d"))
		var/multiplied
		if(preset)
			var/datum/ColorMatrix/CM = new(preset)
			multiplied = matrixMultiply(DruggyMatrix.matrix, CM.matrix)
		animate(client, color = multiplied ? multiplied : DruggyMatrix.matrix, time = 40)
	else if(preset)
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
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
			if(A)
				client.perspective = EYE_PERSPECTIVE
				client.eye = A

//You can buckle on mobs if you're next to them since most are dense
/mob/buckle_mob(mob/living/M)
	if(M.buckled)
		return 0
	var/turf/T = get_turf(src)
	if(M.loc != T)
		var/old_density = density
		density = 0
		var/can_step = step_towards(M, T)
		density = old_density
		if(!can_step)
			return 0
	return ..()

//Default buckling shift visual for mobs
/mob/post_buckle_mob(mob/living/M)
	if(M == buckled_mob) //post buckling
		M.pixel_y = initial(M.pixel_y) + 9
		if(M.layer < layer)
			M.layer = layer + 0.1
	else //post unbuckling
		M.layer = initial(M.layer)
		M.plane = initial(M.plane)
		M.pixel_y = initial(M.pixel_y)

/mob/proc/can_unbuckle(mob/user)
	return 1

/*
/mob/living/on_varedit(modified_var)
	switch(modified_var)
		if("weakened")
			SetWeakened(weakened)
		if("stunned")
			SetStunned(stunned)
		if("paralysis")
			SetParalysis(paralysis)
		if("sleeping")
			SetSleeping(sleeping)
		if("eye_blind")
			set_blindness(eye_blind)
		if("eye_damage")
			set_eye_damage(eye_damage)
		if("eye_blurry")
			set_blurriness(eye_blurry)
		if("ear_deaf")
			setEarDamage(-1, ear_deaf)
		if("ear_damage")
			setEarDamage(ear_damage, -1)
		if("maxHealth")
			updatehealth()
		if("resize")
			update_transform()*/
