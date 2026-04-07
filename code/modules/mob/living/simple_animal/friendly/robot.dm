ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/det5, chief_animal_list)
/mob/living/simple_animal/det5
	name = "DET5"
	icon_state = "robot_rd"
	icon_living = "robot_rd"
	icon_dead = "robot_rd_died"
	desc = "Теория цифровых проводников - 5. Робот с блестящими колесами. Иногда из его корпуса вылетают искры."

	speak = list("Бип", "Буп", "Биииибски...",
				 "Раз...два...три...четыре...пять...",
				 "Но-о-о-оль", "Один...нуль...Бип",
				 "Анализирую...", "Успешно",
				 "...это была шутка", "Ла ла ла... Бип",
				 "Бум...", "Нет времени",
				 "Время науки", "ED-209, защити меня", "Директор, где изучения?",
				 "Ресурсы были?", "Бомбы взрывали?", "Форон в токсинной...",
				 "Мехов изучили?", "РПЕД изучили?", "РД, когда улучшения?")

	speak_emote = list("бикает", "пищит")
	emote_hear = list("жужит манипуляторами", "щёлкает сканером")
	emote_see = list("крутится", "включает и выключает индикатор")
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
	var/act_emag
	var/obj/machinery/computer/rdconsole/rdconsole = null

	var/datum/proximity_monitor/proximity_monitor

/mob/living/simple_animal/det5/Destroy()
	QDEL_NULL(proximity_monitor)
	return ..()

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
	visible_message("<span class='bold'>[src]</span> пищит <span class='bold'>Д-д-д-данные получены. У-у-у-уничтожение...</span>")
	new /obj/effect/decal/cleanable/blood/gibs/robot(loc)// drob blood robots
	new /obj/effect/gibspawner/robot(loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	rdconsole = null
	qdel(src)
	return

/mob/living/simple_animal/det5/attackby(obj/item/W, mob/user)
	if(ispulsing(W))
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
	if(iscarbon(AM) && !(AM.name == act_emag))	//do not explode EMAG USER
		explode()

/mob/living/simple_animal/det5/proc/explode()	// explode
	visible_message("<span class='bold'>[src]</span> пищит <span class='userdanger'>В@ры# п!дгот$влен, а-а-ак>ив&ция...</span>")
	explosion(get_turf(src), 0, 2, 2, 2)
	death()

/mob/living/simple_animal/det5/emag_act(mob/user)
	if(!emagged && emagged < 2)
		act_emag = user.name
		emagged = 1
		to_chat(user, "<span class='bold'>[src]</span> пищит <span class='userdanger'>В-в-в-!злома$ные про@ок№лы акт#ви*ов$ны...</span>")
		return TRUE
	return FALSE

/mob/living/simple_animal/det5/proc/det5controll(user)	// Used Controller (Input command)
	if(health <=0)
		return
	if(emagged != 1)
		commandtrigger = input("Введите команду.", , "Отмена") in list("Движение стоп/старт", "Говорить стоп/старт", "Секретарь (подготовка отчетов)", "Отмена")
	else
		commandtrigger = input("Введите команду.", , "Отмена") in list("Движение стоп/старт", "Говорить стоп/старт", "Секретарь (подготовка отчетов)", "Взрыв (50с)", "Взрыв (с датчиком движения)", "Отмена")

	switch(commandtrigger)
		if("Движение стоп/старт")
			if(turns_per_move == 1)
				turns_per_move = 100
				to_chat(user, "<span class='bold'>[src]</span> пищит <span class='bold'>Режим движения отключен</span>")
				commandtrigger = 0
			else
				turns_per_move = 1
				to_chat(user, "<span class='bold'>[src]</span> пищит <span class='bold'>Режим движения активирован</span>")
				commandtrigger = 0
		if("Говорить стоп/старт")
			if(speak_chance == 15)
				speak_chance = 0
				to_chat(user, "<span class='bold'>[src]</span> пищит <span class='bold'>Режим речи отключен</span>")
				commandtrigger = 0
			else
				speak_chance = 15
				to_chat(user, "<span class='bold'>[src]</span> пищит <span class='bold'>Режим речи активирован</span>")
				commandtrigger = 0
		if("Секретарь (подготовка отчетов)")
			if(rdconsole == null)
				to_chat(user, "<span class='bold'>[src]</span> пищит <span class='bold'>Консоль не найдена</span>")
			else
				to_chat(user, "<span class='bold'>[src]</span> пищит <span class='bold'>Печать отчета</span>")
				print()
			commandtrigger = 0
		if("Взрыв (50с)")
			if(emagged == 1)
				to_chat(user, "<span class='bold'>[src]</span> пищит <span class='userdanger'>П#ото@ол сам!ун$что%ен&я а-а-акт%вир?вн</span>")
				sleep(500)
				explode()
				commandtrigger = 0
		if("Взрыв (с датчиком движения)")
			if(emagged == 1)
				to_chat(user, "<span class='bold'>[src]</span> пищит <span class='userdanger'>П#ото@ол сам!ун$что%ен&я c це%ью а-а-акт%вир?вн</span>")
				if(!proximity_monitor)
					proximity_monitor = new(src, 1)
				commandtrigger = 0
