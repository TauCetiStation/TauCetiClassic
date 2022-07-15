/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = SIZE_SMALL
	origin_tech = "engineering=4;materials=4;bluespace=2;programming=4"

	var/searching = FALSE
	brainmob = null
	req_access = list(access_robotics)
	locked = 0
	mecha = null //This does not appear to be used outside of reference in mecha.dm.

	var/ping_cd = FALSE //attack_ghost cooldown


/obj/item/device/mmi/posibrain/attack_self(mob/user)
	if(brainmob && !brainmob.key && !searching)
		//Start the process of searching for a new user.
		to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start the positronic brain's boot process.</span>")
		icon_state = "posibrain-searching"
		searching = TRUE
		request_player()
		addtimer(CALLBACK(src, .proc/reset_search), 30 SECONDS)

/obj/item/device/mmi/posibrain/proc/request_player()
	var/list/candidates = pollGhostCandidates(Question = "Хотите \"ожить\" в виде позитронного мозга?", \
	                                          role_name = "Позитронный мозг", \
	                                          be_role = ROLE_GHOSTLY, \
	                                          Ignore_Role = IGNORE_POSBRAIN, \
	                                          poll_time = 20 SECONDS, \
	                                          check_antaghud = TRUE, \
	                                          add_spawner = TRUE, \
	                                          positions = list(src))
	for(var/mob/M in candidates) // No random
		transfer_personality(M)
		break

/obj/item/device/mmi/posibrain/transfer_identity(mob/living/carbon/H)
	brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI","HBL","MSO","CHRI","CDB","XSI","ORNG","GUN","KOR","MET","FRE","XIS","SLI","PKP","HOG","RZH","MRPR","JJR","FIRC","INC","PHL","BGB","ANTR","MIW","JRD","CHOC","ANCL","JLLO","JNLG","KOS","TKRG","XAL","STLP","CBOS","DUNC","FXMC","DRSD","XHS","BOB","EXAD","JMAD"))]-"
	var/number = rand(1, 999)
	if(number < 10)
		brainmob.name = "[brainmob.name]00[number]"
	else if(number < 100)
		brainmob.name = "[brainmob.name]0[number]"
	else
		brainmob.name = "[brainmob.name][number]"
	brainmob.real_name = brainmob.name
	brainmob.dna = H.dna
	brainmob.timeofhostdeath = H.timeofdeath
	brainmob.stat = CONSCIOUS
	name = "positronic brain ([brainmob.name])"
	if(brainmob.mind)
		brainmob.mind.assigned_role = "Positronic Brain"
	if(H.mind)
		H.mind.transfer_to(brainmob)
	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a metal cube.</span>")
	icon_state = "posibrain-occupied"
	return

/obj/item/device/mmi/posibrain/proc/transfer_personality(mob/candidate)
	searching = FALSE
	brainmob.key = candidate.key
	name = "positronic brain ([brainmob.name])"

	to_chat(brainmob, "<b>You are a positronic brain, brought into existence on [station_name()].</b>")
	to_chat(brainmob, "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>")
	to_chat(brainmob, "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>")
	brainmob.mind.assigned_role = "Positronic Brain"

	brainmob.mind.skills.add_available_skillset(/datum/skillset/cyborg)
	brainmob.mind.skills.maximize_active_skills()
	visible_message("<span class='notice'>\The [src] chimes quietly.</span>")
	icon_state = "posibrain-occupied"

/obj/item/device/mmi/posibrain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	if(brainmob && brainmob.key)
		return

	searching = FALSE
	icon_state = "posibrain"

	visible_message("<span class='notice'>\The [src] buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>")

/obj/item/device/mmi/posibrain/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n[desc]</span>\n"

	if(brainmob && brainmob.key)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!brainmob.client)
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
	if(!brainmob)
		return

	switch(severity)
		if(1)
			brainmob.emp_damage += rand(20,30)
		if(2)
			brainmob.emp_damage += rand(10,20)
		if(3)
			brainmob.emp_damage += rand(0,10)
	..()

/obj/item/device/mmi/posibrain/attack_ghost(mob/dead/observer/O)
	if(!ping_cd)
		ping_cd = TRUE
		VARSET_IN(src, ping_cd, FALSE, 5 SECONDS)
		audible_message("<span class='notice'>\The [src] pings softly.</span>", deaf_message = "\The [src] indicator blinks.")
		playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, 10, FALSE)

/obj/item/device/mmi/posibrain/atom_init()
	brainmob = new(src)
	brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI","HBL","MSO","CHRI","CDB","XSI","ORNG","GUN","KOR","MET","FRE","XIS","SLI","PKP","HOG","RZH","MRPR","JJR","FIRC","INC","PHL","BGB","ANTR","MIW","JRD","CHOC","ANCL","JLLO","JNLG","KOS","TKRG","XAL","STLP","CBOS","DUNC","FXMC","DRSD","XHS","BOB","EXAD","JMAD"))]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.loc = src
	brainmob.container = src
	brainmob.stat = CONSCIOUS
	brainmob.silent = 0
	dead_mob_list -= brainmob

	. = ..()
