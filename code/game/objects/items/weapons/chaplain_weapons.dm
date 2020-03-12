/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	slot_flags = SLOT_FLAGS_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	light_color = "#4c4cff"
	light_power = 3
	w_class = ITEM_SIZE_SMALL
	var/last_process = 0
	var/datum/cult/reveal/power
	var/static/list/scum

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='userdanger'>[user] is impaling himself with the [name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/atom_init()
	. = ..()
	if(!scum)
		scum = typecacheof(list(/mob/living/simple_animal/construct, /obj/structure/cult, /obj/effect/rune, /mob/dead/observer))
	power = new(src)

/obj/item/weapon/nullrod/equipped(mob/user, slot)
	if(user.mind && user.mind.assigned_role == "Chaplain")
		START_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/nullrod/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(power)
	return ..()

/obj/item/weapon/nullrod/dropped(mob/user)
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/nullrod/process()
	if(last_process + 60 >= world.time)
		return
	last_process = world.time
	var/turf/turf = get_turf(loc)
	for(var/A in range(6, turf))
		if(iscultist(A) || is_type_in_typecache(A, scum))
			set_light(3)
			addtimer(CALLBACK(src, .atom/proc/set_light, 0), 20)
			return

/obj/item/weapon/nullrod/attack(mob/M, mob/living/user) //Paste from old-code to decult with a null rod.
	if (!(ishuman(user) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "<span class='danger'> You don't have the dexterity to do this!</span>")
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had the [name] used on him by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) used [name] on [M.name] ([M.ckey])", user)

	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='danger'>The rod slips out of your hand and hits your head.</span>")
		user.adjustBruteLoss(10)
		user.Paralyse(20)
		return

	if (M.stat != DEAD)
		if((M.mind in ticker.mode.cult) && user.mind && user.mind.assigned_role == "Chaplain" && prob(33))
			to_chat(M, "<span class='danger'>The power of [src] clears your mind of the cult's influence!</span>")
			to_chat(user, "<span class='danger'>You wave [src] over [M]'s head and see their eyes become clear, their mind returning to normal.</span>")
			ticker.mode.remove_cultist(M.mind)
		else
			to_chat(user, "<span class='danger'>The rod appears to do nothing.</span>")
		M.visible_message("<span class='danger'>[user] waves [src] over [M.name]'s head</span>")

/obj/item/weapon/nullrod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (proximity_flag && istype(target, /turf/simulated/floor) && user.mind && user.mind.assigned_role == "Chaplain")
		to_chat(user, "<span class='notice'>You hit the floor with the [src].</span>")
		power.action(user, 1)

/obj/item/weapon/nullrod/staff
	name = "staff"
	desc = "staff"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "talking_staff"
	item_state = "talking_staff"
	w_class = ITEM_SIZE_NORMAL
	var/god_name = "Christ"
	var/mob/living/simple_animal/shade/brainmob = null
	req_access = list(access_chapel_office)

	var/searching = FALSE
	var/askDelay = 10 * 60 * 1
	var/locked = FALSE
	var/ping_cd = FALSE//attack_ghost cooldown


/obj/item/weapon/nullrod/staff/attackby(obj/item/weapon/W, mob/living/carbon/human/user)
	if(user.mind.assigned_role == "Chaplain" && istype(W, /obj/item/weapon/storage/bible))
		if(brainmob && !brainmob.key && searching == FALSE)
			//Start the process of searching for a new user.
			to_chat(user, "<span class='notice'>You attempt to wake the spirit of the staff...</span>")
			icon_state = "posibrain-searching" //TODO
			src.searching = TRUE
			var/obj/item/weapon/storage/bible/B = W
			src.god_name = B.deity_name
			src.request_player()
			addtimer(CALLBACK(src, .proc/reset_search), 600)

/obj/item/weapon/nullrod/staff/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(O.has_enabled_antagHUD == TRUE && config.antag_hud_restricted)
			continue
		if(jobban_isbanned(O, ROLE_PAI))
			continue
		if(role_available_in_minutes(O, ROLE_PAI))
			continue
		if(O.client)
			var/client/C = O.client
			if(!C.prefs.ignore_question.Find("chstaff") && (ROLE_PAI in C.prefs.be_role))
				INVOKE_ASYNC(src, .proc/question, C)

/obj/item/weapon/nullrod/staff/proc/question(client/C)
	if(!C)	return
	var/response = alert(C, "Someone is requesting a your soul in mysteory staff?", "Staff request", "No", "Yees", "Never for this round")
	if(!C || brainmob.key || searching == FALSE)	return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
	if(response == "Yees")
		transfer_personality(C.mob)
	else if (response == "Never for this round")
		C.prefs.ignore_question += "chstaff"

/obj/item/weapon/nullrod/staff/proc/transfer_personality(mob/candidate)
	searching = FALSE
	brainmob.mind = candidate.mind
	brainmob.ckey = candidate.ckey
	brainmob.name = god_name
	brainmob.real_name = god_name
	brainmob.stat = CONSCIOUS
	brainmob.mutations.Add(XRAY)
	brainmob.mind.assigned_role = "Chaplain`s staff"
	candidate.cancel_camera()
	candidate.reset_view()

	name = "staff of [god_name]"
	to_chat(brainmob, "<b>You are a positronic brain, brought into existence on [station_name()].</b>") //TODO
	to_chat(brainmob, "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>")
	to_chat(brainmob, "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>")
	to_chat(brainmob, "<b>Use say :b to speak to other artificial intelligences.</b>")
	visible_message("<span class='notice'>\The [src] chimes quietly.</span>")

	icon_state = "posibrain-occupied" //TODO

/obj/item/weapon/nullrod/staff/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	if(src.brainmob && src.brainmob.key) return

	src.searching = FALSE

	icon_state = "talking_staff"
	visible_message("<span class='notice'>\The [src] buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>") //TODO

/obj/item/weapon/nullrod/staff/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n[desc]</span>\n" //TODO

	if(src.brainmob && src.brainmob.key)
		switch(src.brainmob.stat)
			if(CONSCIOUS)
				if(!src.brainmob.client)
					msg += "<span class='warning'>It appears to be in stand-by mode.</span>\n" //afk //TODO
			if(UNCONSCIOUS)
				msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)
				msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"

	msg += "<span class='info'>*---------*</span>"
	to_chat(user, msg)

/obj/item/weapon/nullrod/staff/attack_ghost(mob/dead/observer/O)
	//DEBUGG
	icon_state = "posibrain-searching" //TODO
	src.searching = TRUE
	src.request_player()

	if(!ping_cd)
		ping_cd = TRUE
		spawn(50)
			ping_cd = TRUE
		audible_message("<span class='notice'>\The [src] pings softly.</span>", deaf_message = "\The [src] indicator blinks.") //TODO

/obj/item/weapon/nullrod/staff/atom_init()
	. = ..()
	brainmob = new(src)
	brainmob.desc = "Haaallelujah, Haaaallelujah, you have come!"
	brainmob.status_flags |= GODMODE
	brainmob.loc = src
	brainmob.melee_damage_lower = 0
	brainmob.melee_damage_upper = 0
	dead_mob_list -= brainmob

/obj/item/weapon/nullrod/staff/Destroy()
	for(var/mob/living/simple_animal/shade/brainmob in contents)
		to_chat(brainmob, "<span class='userdanger'>You were destroyed!</span>")
		qdel(brainmob)
	return ..()
