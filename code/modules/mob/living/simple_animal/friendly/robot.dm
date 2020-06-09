/mob/living/simple_animal/det5
	name = "DET5"
	icon_state = "robot_rd"
	icon_living = "robot_rd"
	icon_dead = "robot_rd_died"
	desc = "Digital Explorer Theory - 5. Its a robot with shiny wheels. Sometimes sparks fly out of its hull."

	speak = list("Beep", "Beep-beep", "Beeeepsky",
				 "One...two...three...more...",
				 "Z-z-z-zero", "One...null...Beep",
				 "Analyzing...", "Successfully",
				 "...this is a joke", "La la la...beep",
				 "Boom...", "Not enough time",
				 "Science time", "ED-209 protect me", "Director, where are researches?")

	speak_emote = list("beeps", "rang out")
	emote_hear = list("raises manipulators", "twists the scanner")
	emote_see = list("spinning around", "turns the indicator on and off")
	speak_chance = 10
	turns_per_move = 3
	see_in_dark = 6
	health = 70
	maxHealth = 70
	response_help  = "is played"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	minbodytemp = 198	// Below -75 Degrees Celcius
	maxbodytemp = 423	// Above 150 Degrees Celcius
	var/emagged = 0    // Trigger EMAG used
	var/commandtrigger = 0    // Used command
	var/searchfortarget = 0	   //  if this is TRUE, robot will be searching for target to explode.
	var/act_emag
	var/obj/machinery/computer/rdconsole/rdconsole = null

/mob/living/simple_animal/det5/Life()
	..()
	if(health <= 0)
		return
	// spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

/mob/living/simple_animal/det5/proc/print() //proc print det5 robot
	var/obj/item/weapon/paper/O = new /obj/item/weapon/paper(get_turf(src))
	var/dat
	for(var/tech_tree_id in rdconsole.files.tech_trees)
		var/datum/tech/T = rdconsole.files.tech_trees[tech_tree_id]
		if(!T.shown)
			continue
		dat += "[T.name]<BR>"
		dat +=  "* Level: [T.level]<BR>"
		dat +=  "* Summary: [T.desc]<HR>"
	dat += "</div>"
	O.info = dat
	O.update_icon()

/mob/living/simple_animal/det5/death()
	..()
	visible_message("<span class='bold'>[src]</span> rang out <span class='bold'>d-d-d-data received...d-d-d-destruction</span>")
	new /obj/effect/decal/cleanable/blood/gibs/robot(loc)// drob blood robots
	new /obj/effect/gibspawner/robot(loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	rdconsole = null
	qdel(src)
	return

/mob/living/simple_animal/det5/attackby(obj/item/W, mob/user)
	if(ismultitool(W))
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/computer/rdconsole))
			rdconsole = M.buffer
			M.buffer = null
			to_chat(user, "<span class='notice'>You upload the data from the [W.name]'s buffer.</span>")
	else
		..()

/mob/living/simple_animal/det5/helpReaction(mob/living/carbon/human/attacker)
	det5controll(attacker)

/mob/living/simple_animal/det5/HasProximity(atom/movable/AM)	// Trigger move
	if(searchfortarget == 1)
		if(istype(AM, /mob/living/carbon) && !(AM.name == act_emag))	//do not explode EMAG USER
			searchfortarget = 0
			explode()

/mob/living/simple_animal/det5/proc/explode()	// explode
	visible_message("<span class='bold'>[src]</span> rang out <span class='userdanger'>The #xplosi@n is prep@red, @-a-activate</span>")
	explosion(get_turf(src), 0, 2, 2, 2, 1)
	death()

/mob/living/simple_animal/det5/emag_act(mob/user)
	if(!emagged && emagged < 2)
		act_emag = user.name
		emagged = 1
		to_chat(user, "<span class='bold'>[src]</span> rang out <span class='userdanger'>B-b-b-broken pro#oco%s %%ctivated</span>")
		return TRUE
	return FALSE

/mob/living/simple_animal/det5/proc/det5controll(user)	// Used Controller (Input command)
	if(health <=0)
		return
	if(emagged != 1)
		commandtrigger = input("Enter the command.", , "Cancel") in list("Moving stop/start", "Speak stop/start", "Secretary (preparation of reports)", "Cancel")
	else
		commandtrigger = input("Enter the command.", , "Cancel") in list("Moving stop/start", "Speak stop/start", "Secretary (preparation of reports)", "Explode (50s)", "Explode (using motion sensor)", "Cancel")

	switch(commandtrigger)
		if("Moving stop/start")
			if(turns_per_move == 1)
				turns_per_move = 100
				to_chat(user, "<span class='bold'>[src]</span> rang out <span class='bold'>Moving mode is off</span>")
				commandtrigger = 0
			else
				turns_per_move = 1
				to_chat(user, "<span class='bold'>[src]</span> rang out <span class='bold'>Moving mode is on</span>")
				commandtrigger = 0
		if("Speak stop/start")
			if(speak_chance == 15)
				speak_chance = 0
				to_chat(user, "<span class='bold'>[src]</span> rang out <span class='bold'>Speech mode is off</span>")
				commandtrigger = 0
			else
				speak_chance = 15
				to_chat(user, "<span class='bold'>[src]</span> rang out <span class='bold'>Speech mode is on</span>")
				commandtrigger = 0
		if("Secretary (preparation of reports)")
			if(rdconsole == null)
				to_chat(user, "<span class='bold'>[src]</span> rang out <span class='bold'>Console not found</span>")
			else
				to_chat(user, "<span class='bold'>[src]</span> rang out <span class='bold'>Print report</span>")
				print()
			commandtrigger = 0
		if("Explode (50s)")
			if(emagged == 1)
				to_chat(user, "<span class='bold'>[src]</span> rang out <span class='userdanger'>Self-d#str@ct pr@t@col a-a-a-activated</span>")
				sleep(500)
				src.explode()
				commandtrigger = 0
		if("Explode (using motion sensor)")
			if(emagged == 1)
				to_chat(user, "<span class='bold'>[src]</span> rang out <span class='userdanger'>Self-d##struct m@de with t@rget @ctiv@t#d</span>")
				searchfortarget = 1
				commandtrigger = 0
