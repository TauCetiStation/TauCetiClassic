/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = SIZE_SMALL
	origin_tech = "engineering=4;materials=4;bluespace=2;programming=4"

	var/searching = 0
	brainmob = null
	req_access = list(access_robotics)
	locked = 0

	var/ping_cd = 0//attack_ghost cooldown


/obj/item/device/mmi/posibrain/attack_self(mob/user)
	if(brainmob && !brainmob.key && searching == 0)
		//Start the process of searching for a new user.
		to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start the positronic brain's boot process.</span>")
		icon_state = "posibrain-searching"
		searching = TRUE
		request_player()
		addtimer(CALLBACK(src, PROC_REF(reset_search)), 300)

/obj/item/device/mmi/posibrain/proc/request_player()
	var/list/candidates = pollGhostCandidates("Someone is requesting a personality for a positronic brain. Would you like to play as one?", ROLE_GHOSTLY, IGNORE_POSBRAIN, 200, TRUE)
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

	src.searching = FALSE
	src.brainmob.key = candidate.key
	src.name = "positronic brain ([src.brainmob.name])"

	to_chat(src.brainmob, "<b>You are a positronic brain, brought into existence on [station_name()].</b>")
	to_chat(src.brainmob, "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>")
	to_chat(src.brainmob, "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>")
	src.brainmob.mind.assigned_role = "Positronic Brain"

	brainmob.mind.skills.add_available_skillset(/datum/skillset/cyborg)
	brainmob.mind.skills.maximize_active_skills()
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
		switch(brainmob.stat != CONSCIOUS)
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
	if(ping_cd)
		return
	ping_cd = 1
	VARSET_IN(src, ping_cd, 0, 5 SECONDS)
	audible_message("<span class='notice'>\The [src] pings softly.</span>", deaf_message = "\The [src] indicator blinks.")
	playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, 30, FALSE)
	if(can_waddle())
		var/static/list/waddle_angles = list(-32, -22, 22, 32)
		waddle(pick(waddle_angles), 0)

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
