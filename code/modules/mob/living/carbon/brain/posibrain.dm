/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "engineering=4;materials=4;bluespace=2;programming=4"

	var/searching = 0
	var/askDelay = 10 * 60 * 1
	mob/living/carbon/brain/brainmob = null
	req_access = list(access_robotics)
	locked = 0
	mecha = null//This does not appear to be used outside of reference in mecha.dm.

	var/ping_cd = 0//attack_ghost cooldown


/obj/item/device/mmi/posibrain/attack_self(mob/user)
	if(brainmob && !brainmob.key && searching == 0)
		//Start the process of searching for a new user.
		to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start the positronic brain's boot process.</span>")
		icon_state = "posibrain-searching"
		src.searching = 1
		src.request_player()
		addtimer(CALLBACK(src, .proc/reset_search), 600)

/obj/item/device/mmi/posibrain/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
			continue
		if(jobban_isbanned(O, ROLE_PAI))
			continue
		if(role_available_in_minutes(O, ROLE_PAI))
			continue
		if(O.client)
			var/client/C = O.client
			if(!C.prefs.ignore_question.Find(IGNORE_POSBRAIN) && (ROLE_GHOSTLY in C.prefs.be_role))
				INVOKE_ASYNC(src, .proc/question, C)

/obj/item/device/mmi/posibrain/proc/question(client/C)
	if(!C)	return
	var/response = alert(C, "Someone is requesting a personality for a positronic brain. Would you like to play as one?", "Positronic brain request", "No", "Yes", "Never for this round")
	if(!C || brainmob.key || 0 == searching)	return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
	if(response == "Yes")
		transfer_personality(C.mob)
	else if (response == "Never for this round")
		C.prefs.ignore_question += IGNORE_POSBRAIN


/obj/item/device/mmi/posibrain/transfer_identity(mob/living/carbon/H)
	brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI","HBL","MSO","CHRI","CDB","XSI","ORNG","GUN","KOR","MET","FRE","XIS","SLI","PKP","HOG","RZH","MRPR","JJR","FIRC","INC","PHL","BGB","ANTR","MIW","JRD","CHOC","ANCL","JLLO","JNLG","KOS","TKRG","XAL","STLP","CBOS","DUNC","FXMC","DRSD","XHS","BOB","EXAD","JMAD"))]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.dna = H.dna
	brainmob.timeofhostdeath = H.timeofdeath
	brainmob.stat = CONSCIOUS
	brainmob.robot_talk_understand = 1
	name = "positronic brain ([brainmob.name])"
	if(brainmob.mind)
		brainmob.mind.assigned_role = "Positronic Brain"
	if(H.mind)
		H.mind.transfer_to(brainmob)
	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a metal cube.</span>")
	icon_state = "posibrain-occupied"
	return

/obj/item/device/mmi/posibrain/proc/transfer_personality(mob/candidate)

	src.searching = 0
	src.brainmob.mind = candidate.mind
	//src.brainmob.key = candidate.key
	src.brainmob.ckey = candidate.ckey
	src.name = "positronic brain ([src.brainmob.name])"

	to_chat(src.brainmob, "<b>You are a positronic brain, brought into existence on [station_name()].</b>")
	to_chat(src.brainmob, "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>")
	to_chat(src.brainmob, "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>")
	to_chat(src.brainmob, "<b>Use say :b to speak to other artificial intelligences.</b>")
	src.brainmob.mind.assigned_role = "Positronic Brain"

	visible_message("<span class='notice'>\The [src] chimes quietly.</span>")
	icon_state = "posibrain-occupied"

/obj/item/device/mmi/posibrain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.

	if(src.brainmob && src.brainmob.key) return

	src.searching = 0
	icon_state = "posibrain"

	visible_message("<span class='notice'>\The [src] buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>")

/obj/item/device/mmi/posibrain/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n[desc]</span>\n"

	if(src.brainmob && src.brainmob.key)
		switch(src.brainmob.stat)
			if(CONSCIOUS)
				if(!src.brainmob.client)
					msg += "<span class='warning'>It appears to be in stand-by mode.</span>\n" //afk
			if(UNCONSCIOUS)
				msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)
				msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	msg += "<span class='info'>*---------*</span>"
	to_chat(user, msg)

/obj/item/device/mmi/posibrain/emp_act(severity)
	if(!src.brainmob)
		return
	else
		switch(severity)
			if(1)
				src.brainmob.emp_damage += rand(20,30)
			if(2)
				src.brainmob.emp_damage += rand(10,20)
			if(3)
				src.brainmob.emp_damage += rand(0,10)
	..()

/obj/item/device/mmi/posibrain/attack_ghost(mob/dead/observer/O)
	if(!ping_cd)
		ping_cd = 1
		spawn(50)
			ping_cd = 0
		audible_message("<span class='notice'>\The [src] pings softly.</span>", deaf_message = "\The [src] indicator blinks.")
		playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, 10, FALSE)

/obj/item/device/mmi/posibrain/atom_init()

	brainmob = new(src)
	brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI","HBL","MSO","CHRI","CDB","XSI","ORNG","GUN","KOR","MET","FRE","XIS","SLI","PKP","HOG","RZH","MRPR","JJR","FIRC","INC","PHL","BGB","ANTR","MIW","JRD","CHOC","ANCL","JLLO","JNLG","KOS","TKRG","XAL","STLP","CBOS","DUNC","FXMC","DRSD","XHS","BOB","EXAD","JMAD"))]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.loc = src
	brainmob.container = src
	brainmob.robot_talk_understand = 1
	brainmob.stat = CONSCIOUS
	brainmob.silent = 0
	dead_mob_list -= brainmob

	. = ..()
